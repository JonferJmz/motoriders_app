import 'package:flutter/material.dart';
import 'package:motoriders_app/screens/notifications_screen.dart';
import 'package:motoriders_app/services/notification_service.dart';

class NotificationBadgeIcon extends StatefulWidget {
  const NotificationBadgeIcon({Key? key}) : super(key: key);

  @override
  State<NotificationBadgeIcon> createState() => _NotificationBadgeIconState();
}

class _NotificationBadgeIconState extends State<NotificationBadgeIcon> {
  final NotificationService _service = NotificationService();

  @override
  void initState() {
    super.initState();
    // Carga inicial
    _service.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _service.unreadCountNotifier,
      builder: (context, count, child) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () async { // ✅ Convertimos a async
                // 1. Navegamos a la pantalla
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );

                // 2. AL VOLVER: Forzamos la actualización localmente
                // Esto quita el punto rojo inmediatamente visualmente
                _service.unreadCountNotifier.value = 0;

                // 3. Y pedimos al servidor que confirme el estado real
                _service.getNotifications();
              },
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}