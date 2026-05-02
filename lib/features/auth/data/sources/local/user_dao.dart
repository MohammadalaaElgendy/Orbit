import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<int> create(UsersCompanion user) => into(users).insert(user);

  Future<bool> updateEntry(UsersCompanion user) => update(users).replace(user);

  Future<int> softDelete(String id) {
    return (update(users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Stream<List<User>> watchAll() {
    return (select(users)..where((t) => t.deletedAt.isNull())).watch();
  }

  Future<User?> getById(String id) {
    return (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<User?> getByEmail(String email) {
    return (select(users)..where((t) => t.email.equals(email))).getSingleOrNull();
  }
}
