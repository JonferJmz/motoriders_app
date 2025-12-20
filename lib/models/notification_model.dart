import 'package:timeago/timeago.dart' as timeago; // Opcional si usas formateo aquí, pero el modelo básico no lo necesita.

class NotificationModel {
  final int id;
  final String type; // 'gas', 'like', 'comment'
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final int? relatedPostId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.relatedPostId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      message: json['message'],
      // Parseamos la fecha que viene del backend
      createdAt: DateTime.parse(json['created_at']),
      // Mapeamos 'is_read' (Python snake_case) a 'isRead' (Dart camelCase)
      isRead: json['is_read'] ?? false,
      relatedPostId: json['related_post_id'],
    );
  }
}