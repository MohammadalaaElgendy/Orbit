class Milestone {
  final String id;
  final String projectId;
  final String name;
  final String description;
  final double progress;
  final int totalTasks;
  final int completedTasks;

  Milestone({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    this.progress = 0.0,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });
}
