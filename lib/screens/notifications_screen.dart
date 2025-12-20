import 'package:flutter/material.dart';
import 'package:motoriders_app/models/notification_model.dart';
import 'package:motoriders_app/services/notification_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notifs = await _notificationService.getNotifications();

    if (mounted) {
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });

      // Si hay notificaciones sin leer, las marcamos todas como leídas
      bool hasUnread = notifs.any((n) => !n.isRead);
      if (hasUnread) {
        _notificationService.markAllAsRead();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    return Container(
                      color: notif.isRead
                          ? Colors.transparent
                          : (isDark ? Colors.grey[900] : Colors.blue[50]),
                      child: ListTile(
                        leading: _buildIcon(notif.type),
                        title: Text(
                          notif.message,
                          style: TextStyle(
                            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          timeago.format(notif.createdAt, locale: 'es'),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        onTap: () {
                          // Aquí iría la navegación al post
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildIcon(String type) {
    switch (type) {
      case 'gas': return const Icon(Icons.flash_on, color: Colors.amber);
      case 'love': return const Icon(Icons.favorite, color: Colors.red);
      case 'like': return const Icon(Icons.thumb_up, color: Colors.blue);
      case 'comment': return const Icon(Icons.comment, color: Colors.green);
      default: return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("No tienes notificaciones nuevas", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}