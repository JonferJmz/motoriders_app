import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motoriders_app/models/motorcycle_model.dart';
import 'package:motoriders_app/models/user_model.dart';
import 'package:motoriders_app/services/auth_service.dart'; // ✅ Importar AuthService

class UserService {
  // ⚠️ TU IP
  static const String baseUrl = 'http://192.168.1.200:8000';
  final _storage = const FlutterSecureStorage();

  Future<User?> getCurrentUser() async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/users/me');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Error fetching me: $e");
      return null;
    }
  }

  Future<User?> getUserProfile(int userId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/users/$userId/profile');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Error fetching user profile: $e");
      return null;
    }
  }

  Future<List<Motorcycle>> getUserMotorcycles(int userId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/users/$userId/motorcycles');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Motorcycle.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching user motos: $e");
      return [];
    }
  }
}