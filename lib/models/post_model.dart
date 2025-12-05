import 'package:motoriders_app/models/reaction_model.dart';

class Post {
  String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String text;
  final List<String> imageUrls;
  final DateTime timestamp;
  final String? location;
  final String? feeling;
  final List<String> taggedUsers;
  final String? clubId;
  int comments;

  // Nuevo sistema de reacciones
  final Map<ReactionType, int> reactionCounts;
  ReactionType? currentUserReaction; // Qué ha reaccionado el usuario actual

  Post({
    this.id = '',
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.text,
    this.imageUrls = const [],
    required this.timestamp,
    this.location,
    this.feeling,
    this.taggedUsers = const [],
    this.clubId,
    this.comments = 0,
    this.reactionCounts = const {},
    this.currentUserReaction,
  });

  // Getter para el total de reacciones
  int get totalReactions => reactionCounts.values.fold(0, (sum, count) => sum + count);
}
