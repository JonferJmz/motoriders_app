
import 'package:flutter/material.dart';
// CORRECCIÓN: Se importa el modelo con un prefijo para evitar conflictos.
import 'package:motoriders_app/models/notification_model.dart' as model;
import 'package:motoriders_app/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<model.Notification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _notificationService.getNotifications();
    _notificationService.markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: FutureBuilder<List<model.Notification>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data!;
          // CORRECCIÓN: Se usa el tipo prefijado para que el compilador entienda el where.
          final newNotifications = notifications.where((n) => !n.isRead).toList();
          final earlierNotifications = notifications.where((n) => n.isRead).toList();

          return ListView(
            children: [
              if (newNotifications.isNotEmpty)
                _buildSection('Nuevas', newNotifications),
              if (earlierNotifications.isNotEmpty)
                _buildSection('Anteriores', earlierNotifications),
              if (notifications.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(48.0), child: Text("No tienes notificaciones."))),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<model.Notification> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...notifications.map((n) => _buildNotificationTile(n)),
      ],
    );
  }

  Widget _buildNotificationTile(model.Notification notification) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(notification.authorAvatarUrl)),
          Positioned(
            bottom: -2, right: -2,
            child: _buildTypeIcon(notification.type),
          ),
        ],
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: notification.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: ' ${notification.content}'),
          ],
        ),
      ),
      subtitle: Text(_formatTimestamp(notification.timestamp)),
      onTap: () { /* TODO: Navegar al post o perfil */ },
    );
  }

  Widget _buildTypeIcon(model.NotificationType type) {
    IconData iconData;
    Color color;
    switch (type) {
      case model.NotificationType.reaction:
        iconData = Icons.favorite;
        color = Colors.pink;
        break;
      case model.NotificationType.comment:
        iconData = Icons.chat_bubble;
        color = Colors.blue;
        break;
      case model.NotificationType.follow:
        iconData = Icons.person_add;
        color = Colors.green;
        break;
      case model.NotificationType.mention:
        iconData = Icons.alternate_email;
        color = Colors.purple;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(2), 
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1)),
      child: Icon(iconData, color: color, size: 16),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m';
    return 'Ahora';
  }
}
