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
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Task>> watchAll() {
    return (select(tasks)).watch();
  }

  Stream<List<Task>> watchByMilestone(String milestoneId) {
    return (select(tasks)
          ..where((t) => t.milestoneId.equals(milestoneId)))
        .watch();
  }

  Stream<List<TaskWithSubtaskCounts>> watchSubtasksWithCounts(String parentId) {
    final subtasksTable = alias(tasks, 'st');
    
    final subtaskCount = subtasksTable.id.count();
    final completedSubtasks = subtasksTable.id.count(filter: subtasksTable.status.equals('done'));

    final query = select(tasks).join([
      leftOuterJoin(
        subtasksTable,
        subtasksTable.parentTaskId.equalsExp(tasks.id),
      ),
    ]);

    query.where(tasks.parentTaskId.equals(parentId));
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
        subtasksTable.parentTaskId.equalsExp(tasks.id),
      ),
    ]);

    query.where(tasks.milestoneId.equals(milestoneId) & tasks.parentTaskId.isNull());
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
    return (select(tasks)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<int> softDeleteByWorkspace(String workspaceId) {
    return (delete(tasks)..where((t) => t.workspaceId.equals(workspaceId))).go();
  }

  Future<void> unassignTasks(String workspaceId, String userId) async {
    final currentUserId = attachedDatabase.userId;
    if (currentUserId == null) return;

    // Allowed if:
    // 1. User is unassigning themselves
    // 2. User is an admin in the workspace
    if (currentUserId != userId) {
      final isAdmin = await _isUserAdmin(currentUserId, workspaceId);
      if (!isAdmin) {
        throw Exception('Security Error: Only admins can unassign tasks of other members');
      }
    }

    await (update(tasks)
          ..where((t) => t.workspaceId.equals(workspaceId) & t.assigneeId.equals(userId)))
        .write(const TasksCompanion(assigneeId: Value(null)));
  }

  Future<bool> _isUserAdmin(String userId, String workspaceId) async {
    // We can query the workspace_members table directly from here 
    // since both tables are in the same database.
    // We need to access the table through the attached database.
    final query = select(attachedDatabase.workspaceMembers)
      ..where((t) =>
          t.userId.equals(userId) &
          t.workspaceId.equals(workspaceId) &
          t.role.equals('admin'));
    
    // Also check if user is the owner of the workspace
    final wsQuery = select(attachedDatabase.workspaces)
      ..where((t) => t.id.equals(workspaceId) & t.ownerId.equals(userId));

    final memberResult = await query.getSingleOrNull();
    final ownerResult = await wsQuery.getSingleOrNull();

    return memberResult != null || ownerResult != null;
  }
}
