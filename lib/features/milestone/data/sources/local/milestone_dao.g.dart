// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_dao.dart';

// ignore_for_file: type=lint
mixin _$MilestoneDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkspacesTable get workspaces => attachedDatabase.workspaces;
  $ProjectsTable get projects => attachedDatabase.projects;
  $MilestonesTable get milestones => attachedDatabase.milestones;
  $UsersTable get users => attachedDatabase.users;
  $TasksTable get tasks => attachedDatabase.tasks;
  MilestoneDaoManager get managers => MilestoneDaoManager(this);
}

class MilestoneDaoManager {
  final _$MilestoneDaoMixin _db;
  MilestoneDaoManager(this._db);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db.attachedDatabase, _db.workspaces);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db.attachedDatabase, _db.projects);
  $$MilestonesTableTableManager get milestones =>
      $$MilestonesTableTableManager(_db.attachedDatabase, _db.milestones);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
}
