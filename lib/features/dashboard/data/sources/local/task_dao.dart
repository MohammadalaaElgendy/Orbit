import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<int> create(TasksCompanion task) => into(tasks).insert(task);

  Future<bool> updateEntry(TasksCompanion task) => update(tasks).replace(task);

  Future<int> softDelete(String id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Stream<List<Task>> watchAll() {
    return (select(tasks)..where((t) => t.deletedAt.isNull())).watch();
  }

  Stream<List<Task>> watchByMilestone(String milestoneId) {
    return (select(tasks)
          ..where((t) => t.milestoneId.equals(milestoneId) & t.deletedAt.isNull()))
        .watch();
  }

  Stream<List<Task>> watchSubtasks(String parentId) {
    return (select(tasks)
          ..where((t) => t.parentTaskId.equals(parentId) & t.deletedAt.isNull()))
        .watch();
  }

  Stream<List<Task>> watchRootTasksByMilestone(String milestoneId) {
    return (select(tasks)
          ..where((t) =>
              t.milestoneId.equals(milestoneId) &
              t.parentTaskId.isNull() &
              t.deletedAt.isNull()))
        .watch();
  }

  Future<Task?> getById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
