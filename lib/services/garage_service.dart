import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GarageService {
  // ⚠️ TU IP
  static const String baseUrl = 'http://192.168.1.200:8000';
  final _storage = const FlutterSecureStorage();

  // ✅ CORREGIDO: Retorna int? (ID de la moto) en lugar de bool
  Future<int?> createMotorcycle(String nickname, String brand, String model, int year, double price) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/motorcycles/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "nickname": nickname,
          "brand": brand,
          "model": model,
          "year": year,
          "purchase_price": price
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id']; // Devuelve el ID para subir foto después
      }
      return null;
    } catch (e) {
      print("Error creating motorcycle: $e");
      return null;
    }
  }

  // Subir foto de moto
  Future<bool> uploadMotorcycleImage(int motoId, String filePath) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/motorcycles/$motoId/image');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print("Error uploading moto image: $e");
      return false;
    }
  }

  // Dar "Gas" a una moto
  Future<bool> toggleGas(int motoId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/motorcycles/$motoId/gas');

    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token'
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}