enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  final String workspaceId; // تم إضافة الحقل هنا
  final String milestoneId;
  final String? parentTaskId;
  final String title;
  final String description;
  final String? assigneeId;
  final String createdBy;
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
    required this.workspaceId, // تم إضافة الحقل هنا
    required this.milestoneId,
    this.parentTaskId,
    required this.title,
    required this.description,
    this.assigneeId,
    required this.createdBy,
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

  Task copyWith({
    String? id,
    String? workspaceId, // تم إضافة الحقل هنا
    String? milestoneId,
    String? parentTaskId,
    String? title,
    String? description,
    String? assigneeId,
    String? createdBy,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Task>? subtasks,
    int? subtaskCount,
    int? completedSubtasks,
  }) {
    return Task(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId, // تم إضافة الحقل هنا
      milestoneId: milestoneId ?? this.milestoneId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeId: assigneeId ?? this.assigneeId,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtasks: subtasks ?? this.subtasks,
      subtaskCount: subtaskCount ?? this.subtaskCount,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
    );
  }
}
