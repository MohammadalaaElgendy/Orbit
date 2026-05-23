import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/database/powersync_schema.dart' as ps_schema;
import '../data/database/powersync_connector.dart';

class SyncService {
  late final PowerSyncDatabase db;
  bool _isInitialized = false;

  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    final dir = await getApplicationSupportDirectory();
    final path = join(dir.path, 'orbit-sync.db');

    db = PowerSyncDatabase(schema: ps_schema.schema, path: path);
    await db.initialize();
    _isInitialized = true;

    // Connect automatically if session exists
    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession != null) {
      connect();
    }
  }

  void connect() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final connector = SupabaseConnector(Supabase.instance.client);
      db.connect(connector: connector);
    }
  }

  void disconnect() {
    db.disconnect();
  }

  Future<void> disconnectAndClear() async {
    await db.disconnectAndClear();
  }
}
