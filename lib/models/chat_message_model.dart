
class ChatMessage {
  final String id;
  final String authorName;
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;

  ChatMessage({
    required this.id,
    required this.authorName,
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
  });
}
