import 'dart:io';
import 'package:flutter/foundation.dart';
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

    // مراقبة حالة المزامنة لمعرفة سبب عدم ظهور البيانات
    db.statusStream.listen((status) {
      debugPrint('Orbit PowerSync: Connected: ${status.connected}, Last Synced: ${status.lastSyncedAt}, Error: ${status.downloadError}');
    });

    // Connect automatically if session exists
    final currentSession = Supabase.instance.client.auth.currentSession;
    if (currentSession != null) {
      connect();
      // محاولة إصلاح الصور العالقة عند التشغيل
      reconcilePendingImages();
    }
  }

  /// وظيفة مخصصة للبحث عن الصور التي لم تُرفع بسبب انقطاع النت ورفعها يدوياً
  Future<void> reconcilePendingImages() async {
    try {
      final supabase = Supabase.instance.client;
      // البحث عن مساحات العمل التي تملك مسار صورة محلي
      final results = await db.execute(
        "SELECT id, image_url FROM workspaces WHERE image_url IS NOT NULL AND image_url NOT LIKE 'http%' AND image_url NOT LIKE 'assets/%'"
      );

      if (results.isEmpty) return;

      for (var row in results) {
        final String id = row['id'];
        final String localPath = row['image_url'];
        final File file = File(localPath);

        if (!file.existsSync()) continue;

        debugPrint('Orbit Sync: Recovering stuck image for workspace $id');

        final String fileName = '${id}_recovered_${DateTime.now().millisecondsSinceEpoch}${extension(localPath)}';
        final String storagePath = 'workspace_images/$fileName';

        // 1. الرفع لـ Supabase Storage
        await supabase.storage.from('workspaces').upload(storagePath, file);
        final String publicUrl = supabase.storage.from('workspaces').getPublicUrl(storagePath);

        // 2. تحديث قاعدة البيانات المحلية
        await db.execute('UPDATE workspaces SET image_url = ? WHERE id = ?', [publicUrl, id]);

        // 3. تحديث السيرفر (Supabase) لضمان وصولها للكل
        await supabase.from('workspaces').update({'image_url': publicUrl}).eq('id', id);

        debugPrint('Orbit Sync: Successfully recovered image for $id');
      }
    } catch (e) {
      debugPrint('Orbit Sync Error during recovery: $e');
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
