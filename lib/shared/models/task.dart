enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String milestoneId;
  final String? parentTaskId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final List<Task> subtasks;

  Task({
    required this.id,
    required this.milestoneId,
    this.parentTaskId,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.subtasks = const [],
  });
}
