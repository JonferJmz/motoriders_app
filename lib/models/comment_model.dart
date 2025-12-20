import 'package:motoriders_app/models/post_model.dart'; // Necesitamos PostAuthor de aquí

class Comment {
  final int id;
  final String text;
  final DateTime createdAt;
  final PostAuthor author; // ✅ Agregamos el Autor completo

  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.author,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      text: json['text'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      // Mapeamos el autor usando la misma clase que usamos en los Posts
      author: PostAuthor.fromJson(json['author']),
    );
  }
}