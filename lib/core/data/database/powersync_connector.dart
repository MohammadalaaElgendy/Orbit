import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

/// Connector to sync data between PowerSync and Supabase
class SupabaseConnector extends PowerSyncBackendConnector {
  final SupabaseClient supabase;
  String? _lastReturnedToken;

  SupabaseConnector(this.supabase);

  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    try {
      Session? session = supabase.auth.currentSession;

      if (session == null) {
        if (kDebugMode) debugPrint('SupabaseConnector: No session found');
        return null;
      }

      if (_lastReturnedToken != null && _lastReturnedToken == session.accessToken) {
        if (kDebugMode) debugPrint('SupabaseConnector: Token was rejected. Refreshing session manually...');
        try {
           final response = await supabase.auth.refreshSession();
           session = response.session;
        } catch (e) {
           if (kDebugMode) debugPrint('SupabaseConnector: Manual refresh failed: $e');
           await Future.delayed(const Duration(seconds: 5));
           session = supabase.auth.currentSession;
        }
      }

      if (session == null) return null;
      _lastReturnedToken = session.accessToken;

      return PowerSyncCredentials(
        endpoint: 'https://6a10976463989ab5d2f1e08f.powersync.journeyapps.com',
        token: session.accessToken,
        userId: session.user.id,
        expiresAt: DateTime.now().add(const Duration(minutes: 50)),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SupabaseConnector: Error during fetchCredentials: $e');
      return null;
    }
  }

  Future<String?> _uploadFileIfNeeded(String table, String id, Map<String, dynamic> data) async {
    if (table != 'workspaces' || data['image_url'] == null) return null;

    final String path = data['image_url'];
    if (path.startsWith('http') || path.startsWith('assets/')) return null;

    try {
      final File file = File(path);
      if (!file.existsSync()) return null;

      final String fileName = '${id}_${DateTime.now().millisecondsSinceEpoch}${p.extension(path)}';
      final String storagePath = 'workspace_images/$fileName';
      
      await supabase.storage.from('workspaces').upload(storagePath, file);
      
      final String publicUrl = supabase.storage.from('workspaces').getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      if (kDebugMode) debugPrint('SupabaseConnector: Error uploading file: $e');
      rethrow;
    }
  }

  Future<void> _deleteFileFromStorage(String? imageUrl) async {
    if (imageUrl == null || !imageUrl.startsWith('http')) return;
    
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      final int bucketIndex = segments.indexOf('workspaces');
      
      if (bucketIndex != -1 && segments.length > bucketIndex + 1) {
        final String storagePath = segments.sublist(bucketIndex + 1).join('/');
        if (storagePath.contains('.')) {
          await supabase.storage.from('workspaces').remove([storagePath]);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('SupabaseConnector: Error deleting file from storage: $e');
    }
  }

  @override
  Future<void> uploadData(PowerSyncDatabase db) async {
    final batch = await db.getCrudBatch();
    if (batch == null) return;

    try {
      for (var row in batch.crud) {
        final table = supabase.from(row.table);
        final Map<String, dynamic> data = Map.from(row.opData ?? {});
        data['id'] = row.id;

        if (kDebugMode) debugPrint('SupabaseConnector: Uploading to ${row.table} (op: ${row.op.name})');

        if (row.op == UpdateType.put || row.op == UpdateType.patch) {
          final remoteUrl = await _uploadFileIfNeeded(row.table, row.id, data);
          if (remoteUrl != null) {
            data['image_url'] = remoteUrl;
            await db.execute('UPDATE workspaces SET image_url = ? WHERE id = ?', [remoteUrl, row.id]);
          }
        }

        // تحويل التواريخ
        for (var key in data.keys.toList()) {
          var value = data[key];
          if (value is int && (key.endsWith('_at') || key.endsWith('_date'))) {
            final ms = value.toString().length == 10 ? value * 1000 : value;
            data[key] = DateTime.fromMillisecondsSinceEpoch(ms).toUtc().toIso8601String();
          }
        }

        try {
          switch (row.op) {
            case UpdateType.put:
              await table.upsert(data);
              break;
            case UpdateType.patch:
              await table.update(data).eq('id', row.id);
              break;
            case UpdateType.delete:
              // قبل الحذف الفعلي للسجل، نمسح الملف من الـ Storage إن وجد
              if (row.table == 'workspaces') {
                final result = await supabase.from('workspaces').select('image_url').eq('id', row.id).maybeSingle();
                if (result != null && result['image_url'] != null) {
                  await _deleteFileFromStorage(result['image_url']);
                }
              }
              await table.delete().eq('id', row.id);
              break;
          }
        } catch (e) {
          if (e is PostgrestException && e.code == '23505') {
            continue;
          }
          // تقليل الضجيج: لو الخطأ RLS هنطبع سطر واحد بس ونعيد المحاولة بهدوء
          if (e is PostgrestException && e.code == '42501') {
            if (kDebugMode) debugPrint('Sync Pending: Table ${row.table} is waiting for Supabase RLS Fix (42501).');
          }
          rethrow;
        }
      }
      await batch.complete();
    } catch (e) {
      rethrow;
    }
  }
}
