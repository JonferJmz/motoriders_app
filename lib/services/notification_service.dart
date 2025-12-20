import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:motoriders_app/models/notification_model.dart';

class NotificationService {
  // ⚠️ TU IP CORRECTA
  static const String baseUrl = 'http://192.168.1.200:8000';
  final _storage = const FlutterSecureStorage();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ValueNotifier para actualizar el UI en tiempo real
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  Future<List<NotificationModel>> getNotifications() async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/notifications');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<NotificationModel> notifs = body.map((item) => NotificationModel.fromJson(item)).toList();

        // Actualizar el contador global
        int unread = notifs.where((n) => !n.isRead).length;
        unreadCountNotifier.value = unread;

        return notifs;
      }
      return [];
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }

  // Llama al nuevo endpoint
  Future<void> markAllAsRead() async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/notifications/mark-all-read');

    try {
      final response = await http.put(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        unreadCountNotifier.value = 0; // Limpia el punto rojo inmediatamente
      }
    } catch (e) {
      print("Error marking all read: $e");
    }
  }
}