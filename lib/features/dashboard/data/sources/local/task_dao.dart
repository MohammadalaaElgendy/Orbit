import 'package:drift/drift.dart';
import 'package:orbit/core/data/database/app_database.dart';

part 'task_dao.g.dart';

class TaskWithSubtaskCounts {
  final Task task;
  final int subtaskCount;
  final int completedSubtasks;

  TaskWithSubtaskCounts({
    required this.task,
    required this.subtaskCount,
    required this.completedSubtasks,
  });
}

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

  Stream<List<TaskWithSubtaskCounts>> watchSubtasksWithCounts(String parentId) {
    final subtasksTable = alias(tasks, 'st');
    
    final subtaskCount = subtasksTable.id.count();
    final completedSubtasks = subtasksTable.id.count(filter: subtasksTable.status.equals('done'));

    final query = select(tasks).join([
      leftOuterJoin(
        subtasksTable,
        subtasksTable.parentTaskId.equalsExp(tasks.id) & subtasksTable.deletedAt.isNull(),
      ),
    ]);

    query.where(tasks.parentTaskId.equals(parentId) & tasks.deletedAt.isNull());
    query.groupBy([tasks.id]);
    query.addColumns([subtaskCount, completedSubtasks]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TaskWithSubtaskCounts(
          task: row.readTable(tasks),
          subtaskCount: row.read(subtaskCount) ?? 0,
          completedSubtasks: row.read(completedSubtasks) ?? 0,
        );
      }).toList();
    });
  }

  Stream<List<TaskWithSubtaskCounts>> watchRootTasksByMilestoneWithCounts(String milestoneId) {
    final subtasksTable = alias(tasks, 'st');
    
    final subtaskCount = subtasksTable.id.count();
    final completedSubtasks = subtasksTable.id.count(filter: subtasksTable.status.equals('done'));

    final query = select(tasks).join([
      leftOuterJoin(
        subtasksTable,
        subtasksTable.parentTaskId.equalsExp(tasks.id) & subtasksTable.deletedAt.isNull(),
      ),
    ]);

    query.where(tasks.milestoneId.equals(milestoneId) & tasks.parentTaskId.isNull() & tasks.deletedAt.isNull());
    query.groupBy([tasks.id]);
    query.addColumns([subtaskCount, completedSubtasks]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TaskWithSubtaskCounts(
          task: row.readTable(tasks),
          subtaskCount: row.read(subtaskCount) ?? 0,
          completedSubtasks: row.read(completedSubtasks) ?? 0,
        );
      }).toList();
    });
  }

  Future<Task?> getById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<Task?> watchById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).watchSingleOrNull();
  }
}
