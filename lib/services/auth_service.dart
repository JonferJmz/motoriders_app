
import 'dart:convert';
import 'package:crypto/crypto.dart';

// --- SERVICIO DE AUTENTICACIÓN (SIMULADO) ---

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() {
    return _instance;
  }
  AuthService._internal();

  final List<Map<String, String>> _users = [
    {
      "email": "test@test.com",
      "passwordHash": sha256.convert(utf8.encode("password123")).toString(),
      "username": "ShadowRider"
    },
    {
      "email": "huesomillonario666@gmail.com",
      "passwordHash": sha256.convert(utf8.encode("Banana#23")).toString(),
      "username": "jonfer119"
    }
  ];

  Future<String> login(String identifier, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = _users.firstWhere(
      (user) => user['email'] == identifier || user['username'] == identifier,
      orElse: () => {},
    );

    if (user.isEmpty) {
      return "Error: Usuario no encontrado.";
    }

    final providedPasswordHash = sha256.convert(utf8.encode(password)).toString();
    if (user['passwordHash'] == providedPasswordHash) {
      return "Success";
    } else {
      return "Error: Contraseña incorrecta.";
    }
  }

  Future<String> register(String username, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_users.any((user) => user['email'] == email)) {
      return "Error: El correo electrónico ya está en uso.";
    }
    if (_users.any((user) => user['username'] == username)) {
      return "Error: El nombre de usuario ya está en uso.";
    }

    final passwordHash = sha256.convert(utf8.encode(password)).toString();
    _users.add({
      "username": username,
      "email": email,
      "passwordHash": passwordHash,
    });
    return "Success";
  }

  Future<void> logout() async {}

  bool isAdmin() {
    return false;
  }
}
