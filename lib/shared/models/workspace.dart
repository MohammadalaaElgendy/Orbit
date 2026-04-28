class Workspace {
  final String id;
  final String name;
  final String description;
  final String? imageUrl; // For custom images/patterns

  Workspace({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
  });
}
