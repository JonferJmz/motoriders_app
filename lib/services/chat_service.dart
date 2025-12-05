
import 'package:motoriders_app/models/chat_message_model.dart';

class ChatService {
  // Simula una base de datos de mensajes por club
  final Map<String, List<ChatMessage>> _messages = {
    'club1': [
      ChatMessage(authorId: 'user2', authorName: 'Andrea GP', authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=60', text: '¡Hola a todos! ¿Alguien para una ruta el fin de semana?', timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
      ChatMessage(authorId: 'user3', authorName: 'RiderX', authorAvatarUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=60', text: 'Yo me apunto. ¿Ruta de montaña?', timestamp: DateTime.now().subtract(const Duration(minutes: 28))),
      ChatMessage(authorId: 'user1', authorName: 'jonfer119', authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=800&q=80', text: '¡Claro! Podríamos ir hacia el norte, las carreteras están geniales por ahí.', timestamp: DateTime.now().subtract(const Duration(minutes: 25))),
    ]
  };

  // Stream para notificar a la UI de nuevos mensajes (simulación de tiempo real)
  Stream<List<ChatMessage>> getMessagesStream(String clubId) async* {
    yield _messages[clubId] ?? [];
    // En un sistema real, aquí escucharías a un WebSocket o similar.
  }

  Future<void> sendMessage(String clubId, String text) async {
    final newMessage = ChatMessage(
      authorId: 'user1', // Simula que el usuario actual envía el mensaje
      authorName: 'jonfer119',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=800&q=80',
      text: text,
      timestamp: DateTime.now(),
    );
    
    if (_messages.containsKey(clubId)) {
      _messages[clubId]!.add(newMessage);
    } else {
      _messages[clubId] = [newMessage];
    }
    // En una app real, el stream se actualizaría automáticamente desde el servidor.
  }
}
