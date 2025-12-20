import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motoriders_app/models/chat_message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // ✅ Necesario para WebSocket
import 'package:jwt_decoder/jwt_decoder.dart'; // ✅ Necesario para decodificar token

class ChatService {
  // ⚠️ TU IP
  static const String httpBaseUrl = 'http://192.168.1.200:8000';

  final _storage = const FlutterSecureStorage();
  WebSocketChannel? _channel;

  // ----------------------------------------------------------------
  // 1. FUNCIONES REST (HISTORIAL, CLUBS Y COMPARTIR)
  // ----------------------------------------------------------------

  Future<List<ChatMessage>> getChatHistory(String clubId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$httpBaseUrl/chat/$clubId');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ChatMessage.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error chat history: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMyClubsForShare() async {
    // Simulado o real
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': 'club_1', 'name': 'MotoClub GDL', 'image': 'https://i.pravatar.cc/150?u=club1'},
      {'id': 'club_2', 'name': 'Ruteros Oficial', 'image': 'https://i.pravatar.cc/150?u=club2'},
      {'id': 'club_3', 'name': 'Yamaha Fans', 'image': 'https://i.pravatar.cc/150?u=club3'},
    ];
  }

  Future<bool> sharePostToClub(String clubId, int postId) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$httpBaseUrl/chat/share_post');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "club_id": clubId,
          "post_id": postId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error sharing post: $e");
      return false;
    }
  }

  // ----------------------------------------------------------------
  // 2. FUNCIONES WEBSOCKET (CORREGIDO EL TIPO DE RETORNO)
  // ----------------------------------------------------------------

  // ✅ CORRECCIÓN: Ahora devuelve Future<WebSocketChannel> en lugar de Future<Stream>
  // Esto arregla el error "The getter 'stream' isn't defined" en tu tab.
  Future<WebSocketChannel> connectToClub(String clubId) async {
    final token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      throw Exception("No token found");
    }

    // Decodificar token para obtener username
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String username = decodedToken['sub'] ?? 'unknown';

    // Construir URL WebSocket
    final wsUrl = httpBaseUrl.replaceFirst('http', 'ws');
    final uri = Uri.parse('$wsUrl/ws/$clubId/$username');

    // Conectar
    _channel = WebSocketChannel.connect(uri);

    // ✅ Retornamos el CANAL completo, no solo el stream
    return _channel!;
  }

  void sendMessage(String text) {
    if (_channel != null && text.isNotEmpty) {
      _channel!.sink.add(text);
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
  }
}