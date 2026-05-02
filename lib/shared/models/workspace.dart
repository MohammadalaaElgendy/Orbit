class Workspace {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workspace({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}
