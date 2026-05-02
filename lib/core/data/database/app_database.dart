import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../features/auth/data/sources/local/user_dao.dart';
import '../../../features/workspace/data/sources/local/workspace_dao.dart';
import '../../../features/workspace/data/sources/local/project_dao.dart';
import '../../../features/milestone/data/sources/local/milestone_dao.dart';
import '../../../features/dashboard/data/sources/local/task_dao.dart';

part 'app_database.g.dart';

// --- Tables ---

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get avatarUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Workspaces extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkspaceMembers extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get role => text()(); // String enum
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text().references(Workspaces, #id)();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Milestones extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get name => text()();
  TextColumn get description => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get milestoneId => text().references(Milestones, #id)();
  TextColumn get parentTaskId => text().nullable().references(Tasks, #id)();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get assigneeId => text().nullable().references(Users, #id)();
  TextColumn get priority => text()(); // String enum
  TextColumn get status => text()(); // String enum
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SeedControl extends Table {
  TextColumn get id => text().withDefault(const Constant('main'))();
  BoolColumn get isSeeded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get seededAt => dateTime().nullable()();

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
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(workspaceMembers);
            await m.createTable(seedControl);
          } else if (from < 3) {
            // Ensure seedControl is created if version 2 was missed or failed
            await m.createTable(seedControl);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
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
      seededAt: Value(DateTime.now()),
    ));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'orbit.db'));
    return NativeDatabase.createInBackground(file);
  });
}
