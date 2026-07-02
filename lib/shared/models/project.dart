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

  Project copyWith({
    String? id,
    String? workspaceId,
    String? name,
    String? description,
    dynamic color = _undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color == _undefined ? this.color : color as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const _undefined = Object();
