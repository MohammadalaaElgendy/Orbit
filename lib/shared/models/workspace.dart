class Workspace {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String ownerId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Workspace({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.ownerId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Workspace copyWith({
    String? id,
    String? name,
    String? description,
    dynamic imageUrl = _undefined,
    String? ownerId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl == _undefined ? this.imageUrl : imageUrl as String?,
      ownerId: ownerId ?? this.ownerId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const _undefined = Object();
