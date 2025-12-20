class PostAuthor {
  final int id;
  final String username;
  final String fullName;
  final String? avatarUrl;

  PostAuthor({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Usuario',
      // El backend envía 'full_name', aquí lo convertimos a camelCase
      fullName: json['full_name'] ?? 'Desconocido',
      // El backend envía 'avatar_url'
      avatarUrl: json['avatar_url'],
    );
  }
}

class Post {
  final int id;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;
  final PostAuthor author;
  final int likesCount;
  final int commentsCount;
  final String? myReaction; // Puede ser 'gas', 'like', etc. o null

  Post({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.createdAt,
    required this.author,
    required this.likesCount,
    required this.commentsCount,
    this.myReaction,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      text: json['text'] ?? '',
      // Mapeo exacto de lo que envía Python (snake_case) a Dart (camelCase)
      imageUrl: json['image_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      author: PostAuthor.fromJson(json['author']),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      myReaction: json['my_reaction'],
    );
  }
}