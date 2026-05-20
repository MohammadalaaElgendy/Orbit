import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/user.dart' as model;
import '../../data/sources/local/user_dao.dart';
import '../../../../core/data/database/app_database.dart' as db;
import 'package:drift/drift.dart';

class UserRepository {
  final UserDao _userDao;

  UserRepository(this._userDao);

  Future<void> createUser(model.User user) async {
    await _userDao.upsert(db.UsersCompanion(
      id: Value(user.id),
      name: Value(user.name),
      email: Value(user.email),
      avatarUrl: Value(user.avatarUrl),
      isVerified: Value(user.isVerified),
      authProvider: Value(user.authProvider),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Stream<List<model.User>> watchUsers() {
    return _userDao.watchAll().map((rows) => rows
        .map((row) => model.User(
              id: row.id,
              name: row.name,
              email: row.email,
              avatarUrl: row.avatarUrl,
              isVerified: row.isVerified,
              authProvider: row.authProvider,
            ))
        .toList());
  }

  Future<model.User?> getUserById(String id) async {
    final row = await _userDao.getById(id);
    if (row == null) return null;
    return model.User(
      id: row.id,
      name: row.name,
      email: row.email,
      avatarUrl: row.avatarUrl,
      isVerified: row.isVerified,
      authProvider: row.authProvider,
    );
  }

  Future<model.User?> getUserByEmail(String email) async {
    final row = await _userDao.getByEmail(email);
    if (row == null) return null;
    return model.User(
      id: row.id,
      name: row.name,
      email: row.email,
      avatarUrl: row.avatarUrl,
      isVerified: row.isVerified,
      authProvider: row.authProvider,
    );
  }

  Future<List<model.User>> searchUsers(String query) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // إذا كان الاستعلام ليس إيميلاً صالحاً، لا تبحث أصلاً حفاظاً على الخصوصية
    if (!query.contains('@') || !query.contains('.')) return [];

    // البحث في سوبابيس عن إيميل مطابق تماماً
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('email', query.trim()) // بحث دقيق (Exact Match)
          .neq('id', currentUserId ?? '') // منع البحث عن النفس
          .limit(1);

      if ((response as List).isEmpty) return [];

      final data = response.first;
      return [
        model.User(
          id: data['id'],
          name: data['full_name'] ?? 'User',
          email: data['email'] ?? '',
          avatarUrl: data['avatar_url'],
          isVerified: true,
        )
      ];
    } catch (e) {
      debugPrint('Remote search failed: $e');
      return [];
    }
  }
}
