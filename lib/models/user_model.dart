class User {
  final int id;
  final String username;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl; // ✅ CAMPO NUEVO

  User({
    required this.id,
    required this.username,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    this.coverUrl, // ✅ Constructor actualizado
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? 'Rider',
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      coverUrl: json['cover_url'], // ✅ Mapeo
    );
  }
}