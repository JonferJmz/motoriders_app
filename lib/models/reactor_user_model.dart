import 'package:motoriders_app/models/reaction_model.dart';

class ReactorUser {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final ReactionType reaction;

  ReactorUser({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    required this.reaction,
  });

  factory ReactorUser.fromJson(Map<String, dynamic> json) {
    return ReactorUser(
      // Aseguramos que el ID sea String, incluso si viene como int
      id: json['user_id']?.toString() ?? '',
      name: json['full_name'] ?? 'Usuario',
      username: json['username'] ?? 'unknown',
      avatarUrl: json['avatar_url'],
      // Convertimos el string del backend (ej: "gas") al Enum ReactionType
      reaction: ReactionConverter.fromString(json['reaction_type'] ?? 'like'),
    );
  }
}