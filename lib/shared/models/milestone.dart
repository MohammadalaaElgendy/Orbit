class Milestone {
  final String id;
  final String projectId;
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
    required this.projectId,
    required this.name,
    required this.description,
    this.dueDate,
    this.progress = 0.0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    required this.createdAt,
    required this.updatedAt,
  });
}
