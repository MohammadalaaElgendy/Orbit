import '../../../../shared/models/user.dart' as model;
import '../../data/sources/local/user_dao.dart';
import '../../../../core/data/database/app_database.dart' as db;
import 'package:drift/drift.dart';

class UserRepository {
  final UserDao _userDao;

  UserRepository(this._userDao);

  Future<void> createUser(model.User user) async {
    await _userDao.create(db.UsersCompanion(
      id: Value(user.id),
      name: Value(user.name),
      email: Value(user.email),
      avatarUrl: Value(user.avatarUrl),
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
    );
  }

  Future<List<model.User>> searchUsers(String query) async {
    final rows = await _userDao.searchUsers(query);
    return rows
        .map((row) => model.User(
              id: row.id,
              name: row.name,
              email: row.email,
              avatarUrl: row.avatarUrl,
            ))
        .toList();
  }
}
