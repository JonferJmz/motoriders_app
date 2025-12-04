
class Post {
  String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final String? location;
  final String? feeling;
  final List<String> taggedUsers;
  final String? clubId;
  int likes;
  int comments;
  bool isLiked;

  Post({
    this.id = '',
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    this.location,
    this.feeling,
    this.taggedUsers = const [],
    this.clubId,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });
}
