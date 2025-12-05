
import 'package:motoriders_app/models/notification_model.dart';

class NotificationService {
  final List<Notification> _notifications = [
    Notification(
      id: 'n1',
      type: NotificationType.follow,
      authorName: 'Andrea GP',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=60',
      content: 'ha comenzado a seguirte.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Notification(
      id: 'n2',
      type: NotificationType.reaction,
      authorName: 'RiderX',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=60',
      content: 'le ha encantado tu publicación.',
      postReferenceId: 'post1',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Notification(
      id: 'n3',
      type: NotificationType.comment,
      authorName: 'Carlos_MX',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=60',
      content: '¡Qué buena foto! ¿Dónde es eso?',
      postReferenceId: 'post2',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  Future<List<Notification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return _notifications;
  }

  Future<int> getUnreadNotificationCount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (var notification in _notifications) {
      notification.isRead = true;
    }
  }
}
