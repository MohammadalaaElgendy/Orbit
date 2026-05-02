class Project {
  final String id;
  final String workspaceId;
  final String name;
  final String description;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.description,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });
}
