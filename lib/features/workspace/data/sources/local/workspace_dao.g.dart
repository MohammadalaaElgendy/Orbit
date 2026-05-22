// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_dao.dart';

// ignore_for_file: type=lint
mixin _$WorkspaceDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $WorkspacesTable get workspaces => attachedDatabase.workspaces;
  $WorkspaceMembersTable get workspaceMembers =>
      attachedDatabase.workspaceMembers;
  WorkspaceDaoManager get managers => WorkspaceDaoManager(this);
}

class WorkspaceDaoManager {
  final _$WorkspaceDaoMixin _db;
  WorkspaceDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db.attachedDatabase, _db.workspaces);
  $$WorkspaceMembersTableTableManager get workspaceMembers =>
      $$WorkspaceMembersTableTableManager(
        _db.attachedDatabase,
        _db.workspaceMembers,
      );
}
