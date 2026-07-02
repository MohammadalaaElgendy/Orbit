class Milestone {
  final String id;
  final String workspaceId; // تم إضافة الحقل هنا
  final String projectId;
  final String? projectName;
  final String? workspaceName;
  final String name;
  final String description;
  final DateTime? dueDate;
  final double progress;
  final int totalTasks;
  final int completedTasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  Milestone({
    required this.id,
    required this.workspaceId, // تم إضافة الحقل هنا
    required this.projectId,
    this.projectName,
    this.workspaceName,
    required this.name,
    required this.description,
    this.dueDate,
    this.progress = 0.0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Milestone copyWith({
    String? id,
    String? workspaceId,
    String? projectId,
    String? projectName,
    String? workspaceName,
    String? name,
    String? description,
    dynamic dueDate = _undefined,
    double? progress,
    int? totalTasks,
    int? completedTasks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      workspaceName: workspaceName ?? this.workspaceName,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate == _undefined ? this.dueDate : dueDate as DateTime?,
      progress: progress ?? this.progress,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const _undefined = Object();
