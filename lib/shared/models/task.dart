import 'package:orbit/l10n/app_localizations.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

extension TaskStatusExtension on TaskStatus {
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case TaskStatus.todo: return l10n.statusTodo;
      case TaskStatus.inProgress: return l10n.statusInProgress;
      case TaskStatus.done: return l10n.statusDone;
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case TaskPriority.low: return l10n.priorityLow;
      case TaskPriority.medium: return l10n.priorityMedium;
      case TaskPriority.high: return l10n.priorityHigh;
    }
  }
}

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
    String? workspaceId,
    String? milestoneId,
    dynamic parentTaskId = _undefined,
    String? title,
    String? description,
    dynamic assigneeId = _undefined,
    String? createdBy,
    TaskStatus? status,
    TaskPriority? priority,
    dynamic startDate = _undefined,
    dynamic dueDate = _undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Task>? subtasks,
    int? subtaskCount,
    int? completedSubtasks,
  }) {
    return Task(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      milestoneId: milestoneId ?? this.milestoneId,
      parentTaskId: parentTaskId == _undefined ? this.parentTaskId : parentTaskId as String?,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeId: assigneeId == _undefined ? this.assigneeId : assigneeId as String?,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate == _undefined ? this.startDate : startDate as DateTime?,
      dueDate: dueDate == _undefined ? this.dueDate : dueDate as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subtasks: subtasks ?? this.subtasks,
      subtaskCount: subtaskCount ?? this.subtaskCount,
      completedSubtasks: completedSubtasks ?? this.completedSubtasks,
    );
  }
}

const _undefined = Object();
