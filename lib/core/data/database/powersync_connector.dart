import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      // If token is same as last one, it's likely rejected. Try manual refresh.
      if (_lastReturnedToken != null && _lastReturnedToken == session.accessToken) {
        debugPrint('SupabaseConnector: Token was rejected. Refreshing session manually...');
        try {
           final response = await supabase.auth.refreshSession();
           session = response.session;
        } catch (e) {
           debugPrint('SupabaseConnector: Manual refresh failed: $e');
           // If manual refresh fails, wait a bit for SDK auto-refresh
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

        for (var key in data.keys.toList()) {
          var value = data[key];
          if (value is int && (key.endsWith('_at') || key.endsWith('_date'))) {
            final ms = value.toString().length == 10 ? value * 1000 : value;
            data[key] = DateTime.fromMillisecondsSinceEpoch(ms).toUtc().toIso8601String();
          }
        }

        data.forEach((key, value) {
          if (value is String && value.startsWith('[') && value.endsWith(']')) {
            try {
              data[key] = jsonDecode(value);
            } catch (_) {}
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
