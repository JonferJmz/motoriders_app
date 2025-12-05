
class Story {
  final String authorName;
  final String authorAvatarUrl;
  final String contentUrl;
  final DateTime timestamp;
  final bool isViewed;

  Story({
    required this.authorName,
    required this.authorAvatarUrl,
    required this.contentUrl,
    required this.timestamp,
    this.isViewed = false,
  });
}
