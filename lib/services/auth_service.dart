import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motoriders_app/models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.200:8000';
  final _storage = const FlutterSecureStorage();

  static final ValueNotifier<bool> sessionExpired = ValueNotifier(false);

  static void checkSession(int statusCode) {
    if (statusCode == 401) {
      sessionExpired.value = true;
    }
  }

  Future<String?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/token');
    try {
      final response = await http.post(
        url,
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['access_token']);
        return null;
      } else {
        try {
          final body = jsonDecode(response.body);
          return body['detail'] ?? "Credenciales incorrectas";
        } catch (_) {
          return "Error de autenticación (${response.statusCode})";
        }
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }

  Future<String?> register(String username, String email, String password, String fullName) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName
        }),
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        final body = jsonDecode(response.body);
        return body['detail'] ?? "Error al registrar usuario";
      }
    } catch (e) {
      return "Error de conexión: $e";
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    sessionExpired.value = false;
  }

  Future<User?> getUserProfile() async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/users/me');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      checkSession(response.statusCode);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Error getUserProfile: $e");
      return null;
    }
  }

  // ✅ NUEVA FUNCIÓN: Subir imágenes
  Future<String?> uploadImage(File file) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/upload/image');
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return '$baseUrl/${data['url']}';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ ACTUALIZADO: Soporta portada
  Future<bool> updateProfile({String? fullName, String? bio, String? avatarUrl, String? coverUrl}) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/users/me');

    try {
      final Map<String, dynamic> body = {};
      if (fullName != null) body['full_name'] = fullName;
      if (bio != null) body['bio'] = bio;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;
      if (coverUrl != null) body['cover_url'] = coverUrl; // ✅ Soporte Portada

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      checkSession(response.statusCode);

      return response.statusCode == 200;
    } catch (e) {
      print("Error updateProfile: $e");
      return false;
    }
  }
}