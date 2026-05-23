import 'package:drift/drift.dart';
import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;

import '../../../features/auth/data/sources/local/user_dao.dart';
import '../../../features/workspace/data/sources/local/workspace_dao.dart';
import '../../../features/workspace/data/sources/local/project_dao.dart';
import '../../../features/milestone/data/sources/local/milestone_dao.dart';
import '../../../features/dashboard/data/sources/local/task_dao.dart';

part 'app_database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get avatarUrl => text().nullable()();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  TextColumn get authProvider => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Workspaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get ownerId => text().references(Users, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get createdBy => text().references(Users, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkspaceMembers extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get userId => text().references(Users, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get role => text()(); 
  TextColumn get createdAt => text()(); 
  TextColumn get updatedAt => text()(); 

  @override
  Set<Column> get primaryKey => {id};
}

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get color => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Milestones extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get projectId => text().references(Projects, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get milestoneId => text().references(Milestones, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get parentTaskId => text().nullable().references(Tasks, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get assigneeId => text().nullable().references(Users, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.setNull)();
  TextColumn get createdBy => text().references(Users, #id, onUpdate: KeyAction.cascade, onDelete: KeyAction.cascade)();
  TextColumn get priority => text()(); 
  TextColumn get status => text()(); 
  TextColumn get startDate => text().nullable()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class SeedControl extends Table {
  TextColumn get id => text().withDefault(const Constant('main'))();
  BoolColumn get isSeeded => boolean().withDefault(const Constant(false))();
  TextColumn get seededAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Users,
    Workspaces,
    WorkspaceMembers,
    Projects,
    Milestones,
    Tasks,
    SeedControl,
  ],
  daos: [
    UserDao,
    WorkspaceDao,
    ProjectDao,
    MilestoneDao,
    TaskDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(PowerSyncDatabase powersync) : super(SqliteAsyncDriftConnection(powersync)) {
    powersync.updates.listen((update) {
      final updatedTables = update.tables.map((t) => TableUpdate(t)).toSet();
      notifyUpdates(updatedTables);
    });
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // PowerSync handles schema
        },
      );

  Future<void> resetDatabase() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  Future<bool> isDatabaseSeeded() async {
    final result = await (select(seedControl)..where((t) => t.id.equals('main'))).getSingleOrNull();
    return result?.isSeeded ?? false;
  }

  Future<void> markAsSeeded() async {
    await into(seedControl).insertOnConflictUpdate(SeedControlCompanion(
      id: const Value('main'),
      isSeeded: const Value(true),
      seededAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
  }
}
