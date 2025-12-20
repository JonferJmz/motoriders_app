class ChatMessage {
  final int id;
  final String user;
  final String message;
  final DateTime timestamp;
  final bool isDeleted;
  final bool isEdited;

  ChatMessage({
    required this.id,
    required this.user,
    required this.message,
    required this.timestamp,
    this.isDeleted = false,
    this.isEdited = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // ⚠️ AQUÍ ESTABA EL DETALLE:
    // Esta lógica blindada lee el ID sea texto o número, y si falla no pone 0
    int parsedId = 0;
    if (json['id'] != null) {
      parsedId = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0;
    }

    return ChatMessage(
      id: parsedId,
      // Soporte para nombres variados (el backend a veces dice 'user' y a veces 'sender_username')
      user: json['user'] ?? json['sender_username'] ?? 'Anónimo',
      // Soporte para contenido variado
      message: json['message'] ?? json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isDeleted: json['is_deleted'] ?? false,
      isEdited: json['is_edited'] ?? false,
    );
  }
}