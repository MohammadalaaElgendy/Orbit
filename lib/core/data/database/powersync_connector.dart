import 'dart:async';
import 'dart:convert';
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
        debugPrint('SupabaseConnector: No session found');
        return null;
      }

      if (_lastReturnedToken != null && _lastReturnedToken == session.accessToken) {
        debugPrint('SupabaseConnector: Token was rejected. Refreshing session manually...');
        try {
           final response = await supabase.auth.refreshSession();
           session = response.session;
        } catch (e) {
           debugPrint('SupabaseConnector: Manual refresh failed: $e');
           await Future.delayed(const Duration(seconds: 5));
           session = supabase.auth.currentSession;
        }
      }

      if (session == null) return null;
      _lastReturnedToken = session.accessToken;

      return PowerSyncCredentials(
        endpoint: 'https://6a10976463989ab5d2f1e091.powersync.journeyapps.com',
        token: session.accessToken,
        userId: session.user.id,
        expiresAt: DateTime.now().add(const Duration(minutes: 50)),
      );
    } catch (e) {
      debugPrint('SupabaseConnector: Error during fetchCredentials: $e');
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
      // الرفع داخل مجلد workspace_images داخل الـ bucket
      final String storagePath = 'workspace_images/$fileName';
      
      await supabase.storage.from('workspaces').upload(storagePath, file);
      
      final String publicUrl = supabase.storage.from('workspaces').getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      debugPrint('SupabaseConnector: Error uploading file: $e');
      // لا نرجع null هنا، بل نعيد رمي الخطأ لكي يقوم باور سينك بإعادة المحاولة لاحقاً
      rethrow;
    }
  }

  Future<void> _deleteFileFromStorage(String? imageUrl) async {
    // التأكد أن الرابط هو رابط ويب وليس مسار محلي أو أصل من أصول التطبيق
    if (imageUrl == null || !imageUrl.startsWith('http')) return;
    
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;
      
      // نبحث عن اسم الـ bucket في المسار لنعرف بداية مسار الملف الحقيقي
      final int bucketIndex = segments.indexOf('workspaces');
      
      if (bucketIndex != -1 && segments.length > bucketIndex + 1) {
        // نستخرج المسار الكامل للملف (مثلاً: workspace_images/file.jpg)
        final String storagePath = segments.sublist(bucketIndex + 1).join('/');
        
        // التحقق من أن المسار يشير لملف وليس مجلد (يحتوي على نقطة للامتداد)
        if (storagePath.contains('.')) {
          await supabase.storage.from('workspaces').remove([storagePath]);
          debugPrint('SupabaseConnector: [SAFE DELETE] Removed specific file: $storagePath');
        } else {
          debugPrint('SupabaseConnector: [SAFETY BLOCK] Prevented folder deletion attempt: $storagePath');
        }
      }
    } catch (e) {
      debugPrint('SupabaseConnector: Error deleting file from storage: $e');
    }
  }

  @override
  Future<void> uploadData(PowerSyncDatabase db) async {
    final batch = await db.getCrudBatch();
    if (batch == null) return;

    try {
      for (var row in batch.crud) {
        final table = supabase.from(row.table);
        if (row.table == 'users') continue;

        final Map<String, dynamic> data = Map.from(row.opData ?? {});
        data['id'] = row.id;

        if (row.op == UpdateType.put || row.op == UpdateType.patch) {
          // الرفع عند الإضافة أو التعديل
          final remoteUrl = await _uploadFileIfNeeded(row.table, row.id, data);
          if (remoteUrl != null) {
            data['image_url'] = remoteUrl;
            await db.execute('UPDATE workspaces SET image_url = ? WHERE id = ?', [remoteUrl, row.id]);
          }

          // الحذف من الاستورج في حالة الـ Soft Delete (تحديث deleted_at)
          if (row.table == 'workspaces' && data.containsKey('deleted_at') && data['deleted_at'] != null) {
            final result = await db.execute('SELECT image_url FROM workspaces WHERE id = ?', [row.id]);
            if (result.isNotEmpty) {
              final String? imageUrl = result.first['image_url'];
              await _deleteFileFromStorage(imageUrl);
            }
          }
        } else if (row.op == UpdateType.delete) {
          // الحذف من الاستورج في حالة الـ Hard Delete
          if (row.table == 'workspaces') {
             // ملاحظة: هنا قد لا نجد السطر في القاعدة المحلية لأنه حُذف بالفعل، 
             // لذا يفضل الاعتماد على الـ Soft Delete كما هو متبع في تطبيقك حالياً.
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

        data.forEach((key, value) {
          if (value is String && value.startsWith('[') && value.endsWith(']')) {
            try { data[key] = jsonDecode(value); } catch (_) {}
          }
        });

        switch (row.op) {
          case UpdateType.put:
            await table.upsert(data);
            break;
          case UpdateType.patch:
            await table.update(data).eq('id', row.id);
            break;
          case UpdateType.delete:
            await table.delete().eq('id', row.id);
            break;
        }
      }
      await batch.complete();
    } catch (e) {
      debugPrint('SupabaseConnector: Error uploading data: $e');
      rethrow;
    }
  }
}
