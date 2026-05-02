enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String milestoneId;
  final String? parentTaskId;
  final String title;
  final String description;
  final String? assigneeId;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Task> subtasks;
  final int subtaskCount;
  final int completedSubtasks;

  Task({
    required this.id,
    required this.milestoneId,
    this.parentTaskId,
    required this.title,
    required this.description,
    this.assigneeId,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.startDate,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.subtasks = const [],
    this.subtaskCount = 0,
    this.completedSubtasks = 0,
  });
}
