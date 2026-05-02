import '../../../../shared/models/task.dart' as model;
import '../../data/sources/local/task_dao.dart';
import '../../../../core/data/database/app_database.dart' as db;
import 'package:drift/drift.dart';

class TaskRepository {
  final TaskDao _taskDao;

  TaskRepository(this._taskDao);

  Future<void> createTask(model.Task task) async {
    await _taskDao.create(db.TasksCompanion(
      id: Value(task.id),
      milestoneId: Value(task.milestoneId),
      parentTaskId: Value(task.parentTaskId),
      title: Value(task.title),
      description: Value(task.description),
      assigneeId: Value(task.assigneeId),
      priority: Value(task.priority.name),
      status: Value(task.status.name),
      startDate: Value(task.startDate),
      dueDate: Value(task.dueDate),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
    ));
  }

  Stream<List<model.Task>> watchRootTasksByMilestone(String milestoneId) {
    return _taskDao.watchRootTasksByMilestone(milestoneId).map((rows) => rows
        .map((row) => _mapToDomain(row))
        .toList());
  }

  Stream<List<model.Task>> watchSubtasks(String parentId) {
    return _taskDao.watchSubtasks(parentId).map((rows) => rows
        .map((row) => _mapToDomain(row))
        .toList());
  }

  Future<void> updateTask(model.Task task) async {
    await _taskDao.updateEntry(db.TasksCompanion(
      id: Value(task.id),
      milestoneId: Value(task.milestoneId),
      parentTaskId: Value(task.parentTaskId),
      title: Value(task.title),
      description: Value(task.description),
      assigneeId: Value(task.assigneeId),
      priority: Value(task.priority.name),
      status: Value(task.status.name),
      startDate: Value(task.startDate),
      dueDate: Value(task.dueDate),
      createdAt: Value(task.createdAt),
      updatedAt: Value(DateTime.now()),
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

  model.Task _mapToDomain(db.Task row) {
    return model.Task(
      id: row.id,
      milestoneId: row.milestoneId,
      parentTaskId: row.parentTaskId,
      title: row.title,
      description: row.description,
      assigneeId: row.assigneeId,
      status: model.TaskStatus.values.byName(row.status),
      priority: model.TaskPriority.values.byName(row.priority),
      startDate: row.startDate,
      dueDate: row.dueDate,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<List<model.Task>> getTaskTreeByMilestone(String milestoneId) async {
    final query = _taskDao.select(_taskDao.tasks)
          ..where((t) => t.milestoneId.equals(milestoneId) & t.deletedAt.isNull());
    final allTasksRows = await query.get();

    final allTasks = allTasksRows.map(_mapToDomain).toList();
    return _buildTree(allTasks, null);
  }

  List<model.Task> _buildTree(List<model.Task> allTasks, String? parentId) {
    return allTasks
        .where((t) => t.parentTaskId == parentId)
        .map((t) => model.Task(
              id: t.id,
              milestoneId: t.milestoneId,
              parentTaskId: t.parentTaskId,
              title: t.title,
              description: t.description,
              assigneeId: t.assigneeId,
              status: t.status,
              priority: t.priority,
              startDate: t.startDate,
              dueDate: t.dueDate,
              createdAt: t.createdAt,
              updatedAt: t.updatedAt,
              subtasks: _buildTree(allTasks, t.id),
            ))
        .toList();
  }
}
