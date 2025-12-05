
enum NotificationType { reaction, comment, follow, mention }

class Notification {
  final String id;
  final NotificationType type;
  final String authorName;
  final String authorAvatarUrl;
  final String content; // Ej: "le ha encantado tu publicación" o el texto del comentario
  final String? postReferenceId; // Para navegar a la publicación si aplica
  final DateTime timestamp;
  bool isRead;

  Notification({
    required this.id,
    required this.type,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    this.postReferenceId,
    required this.timestamp,
    this.isRead = false,
  });
}
