class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isVerified;
  final String? authProvider;
  final String? role; // تم إضافة الحقل هنا

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isVerified = false,
    this.authProvider,
    this.role,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    dynamic avatarUrl = _undefined,
    bool? isVerified,
    String? authProvider,
    dynamic role = _undefined,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl == _undefined ? this.avatarUrl : avatarUrl as String?,
      isVerified: isVerified ?? this.isVerified,
      authProvider: authProvider ?? this.authProvider,
      role: role == _undefined ? this.role : role as String?,
    );
  }
}

extension UserRoleX on User {
  bool get isAdmin => role == 'admin';
}

const _undefined = Object();
