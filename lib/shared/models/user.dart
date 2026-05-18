class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isVerified;
  final String? authProvider;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isVerified = false,
    this.authProvider,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    bool? isVerified,
    String? authProvider,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      authProvider: authProvider ?? this.authProvider,
    );
  }
}
