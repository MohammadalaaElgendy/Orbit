import '../../../../shared/models/task.dart' as model;
import '../../data/sources/local/task_dao.dart';
import '../../../../core/data/database/app_database.dart' as db;
import 'package:drift/drift.dart';

class TaskRepository {
  final TaskDao _taskDao;

  TaskRepository(this._taskDao);

  Future<void> createTask(model.Task task, String workspaceId) async {
    await _taskDao.create(db.TasksCompanion(
      id: Value(task.id),
      workspaceId: Value(workspaceId),
      milestoneId: Value(task.milestoneId),
      parentTaskId: Value(task.parentTaskId),
      title: Value(task.title),
      description: Value(task.description),
      assigneeId: Value(task.assigneeId),
      createdBy: Value(task.createdBy),
      priority: Value(task.priority.name),
      status: Value(task.status.name),
      startDate: Value(task.startDate?.toIso8601String()),
      dueDate: Value(task.dueDate?.toIso8601String()),
      createdAt: Value(task.createdAt.toIso8601String()),
      updatedAt: Value(task.updatedAt.toIso8601String()),
    ));
  }

  Stream<List<model.Task>> watchAllTasks() {
    return _taskDao.watchAll().map((rows) => rows.map(_mapToDomain).toList());
  }

  Stream<List<model.Task>> watchTasksByWorkspace(String workspaceId) {
    return _taskDao.watchByWorkspace(workspaceId).map((rows) => rows.map(_mapToDomain).toList());
  }

  Stream<List<model.Task>> watchRootTasksByMilestone(String milestoneId) {
    return _taskDao.watchRootTasksByMilestoneWithCounts(milestoneId).map((rows) => rows
        .map((row) => _mapToDomain(row.task, subtaskCount: row.subtaskCount, completedSubtasks: row.completedSubtasks))
        .toList());
  }

  Stream<List<model.Task>> watchSubtasks(String parentId) {
    return _taskDao.watchSubtasksWithCounts(parentId).map((rows) => rows
        .map((row) => _mapToDomain(row.task, subtaskCount: row.subtaskCount, completedSubtasks: row.completedSubtasks))
        .toList());
  }

  Stream<model.Task?> watchTaskById(String id) {
    return _taskDao.watchById(id).map((row) => row != null ? _mapToDomain(row) : null);
  }

  model.Task _mapToDomain(db.Task row, {int subtaskCount = 0, int completedSubtasks = 0}) {
    return model.Task(
      id: row.id,
      workspaceId: row.workspaceId, // تم الربط هنا
      milestoneId: row.milestoneId,
      parentTaskId: row.parentTaskId,
      title: row.title,
      description: row.description,
      assigneeId: row.assigneeId,
      createdBy: row.createdBy,
      status: model.TaskStatus.values.byName(row.status),
      priority: model.TaskPriority.values.byName(row.priority),
      startDate: row.startDate != null ? DateTime.parse(row.startDate!) : null,
      dueDate: row.dueDate != null ? DateTime.parse(row.dueDate!) : null,
      createdAt: DateTime.parse(row.createdAt),
      updatedAt: DateTime.parse(row.updatedAt),
      subtaskCount: subtaskCount,
      completedSubtasks: completedSubtasks,
    );
  }

  Future<void> updateTask(model.Task task) async {
    await _taskDao.updateEntry(db.TasksCompanion(
      id: Value(task.id),
      workspaceId: Value(task.workspaceId),
      milestoneId: Value(task.milestoneId),
      parentTaskId: Value(task.parentTaskId),
      title: Value(task.title),
      description: Value(task.description),
      assigneeId: Value(task.assigneeId),
      createdBy: Value(task.createdBy),
      priority: Value(task.priority.name),
      status: Value(task.status.name),
      startDate: Value(task.startDate?.toIso8601String()),
      dueDate: Value(task.dueDate?.toIso8601String()),
      createdAt: Value(task.createdAt.toIso8601String()),
      updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));

    // Cascade assigneeId change to all direct subtasks
    await (_taskDao.update(_taskDao.tasks)
          ..where((t) => t.parentTaskId.equals(task.id)))
        .write(db.TasksCompanion(
      assigneeId: Value(task.assigneeId),
      updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
  }

  Future<void> deleteTask(String id) async {
    await _taskDao.softDelete(id);
  }

  Future<model.Task?> getTaskById(String id) async {
    final row = await _taskDao.getById(id);
    if (row == null) return null;
    return _mapToDomain(row);
  }

  Future<List<model.Task>> getTaskTreeByMilestone(String milestoneId) async {
    final allTasksRows = await (_taskDao.select(_taskDao.tasks)
          ..where((t) => t.milestoneId.equals(milestoneId))).get();

    final allTasks = allTasksRows.map(_mapToDomain).toList();
    return _buildTree(allTasks, null);
  }

  List<model.Task> _buildTree(List<model.Task> allTasks, String? parentId) {
    return allTasks
        .where((t) => t.parentTaskId == parentId)
        .map((t) => t.copyWith(
              subtasks: _buildTree(allTasks, t.id),
            ))
        .toList();
  }
}
