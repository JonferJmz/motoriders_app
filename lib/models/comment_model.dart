
class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String text;
  final DateTime timestamp;

  Comment({
    this.id = '',
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.text,
    required this.timestamp,
  });
}
