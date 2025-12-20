import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/models/comment_model.dart';
import 'package:motoriders_app/models/reaction_model.dart';
import 'package:motoriders_app/models/reactor_user_model.dart';
import 'package:motoriders_app/services/auth_service.dart'; // ✅ Importar AuthService

class FeedService {
  // ⚠️ TU IP
  static const String baseUrl = 'http://192.168.1.200:8000';
  final _storage = const FlutterSecureStorage();

  Future<List<Post>> getGlobalFeedPosts({int limit = 10, int offset = 0}) async {
    return _fetchPosts('$baseUrl/posts/?limit=$limit&offset=$offset');
  }

  Future<List<Post>> getFollowingFeedPosts({int limit = 10, int offset = 0}) async {
    return _fetchPosts('$baseUrl/posts/?limit=$limit&offset=$offset');
  }

  Future<List<Post>> getPostsForClub(String clubId) async {
    return [];
  }

  Future<List<Post>> _fetchPosts(String urlString) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse(urlString);
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Post.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Error conexión feed: $e");
      return [];
    }
  }

  Future<String?> uploadImage(String filePath) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/upload/image');
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawUrl = data['url'];
        return '$baseUrl/$rawUrl';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createPost(String text, [String? imageUrl]) async {
    final token = await _storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/posts/');
    try {
      final body = jsonEncode({
        "text": text,
        "image_url": imageUrl,
      });
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }, body: body);

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addReaction(dynamic postId, ReactionType type) async {
    final token = await _storage.read(key: 'jwt_token');
    final int id = int.tryParse(postId.toString()) ?? 0;
    final String typeStr = type.toString().split('.').last;
    final url = Uri.parse('$baseUrl/posts/$id/react?type=$typeStr');

    try {
      final response = await http.post(url, headers: {'Authorization': 'Bearer $token'});

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Comment>> getComments(dynamic postId) async {
    final token = await _storage.read(key: 'jwt_token');
    final int id = int.tryParse(postId.toString()) ?? 0;
    final url = Uri.parse('$baseUrl/posts/$id/comments');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Comment.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Comment?> addComment(dynamic postId, String text) async {
    final token = await _storage.read(key: 'jwt_token');
    final int id = int.tryParse(postId.toString()) ?? 0;
    final url = Uri.parse('$baseUrl/posts/$id/comments');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({"text": text}),
      );

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      if (response.statusCode == 200) {
        return Comment.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ReactorUser>> getPostReactions(dynamic postId) async {
    final token = await _storage.read(key: 'jwt_token');
    final id = postId.toString();
    final url = Uri.parse('$baseUrl/posts/$id/reactions');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AuthService.checkSession(response.statusCode); // ✅ CHEQUEO DE SEGURIDAD

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ReactorUser.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error en getPostReactions: $e");
      return [];
    }
  }
}