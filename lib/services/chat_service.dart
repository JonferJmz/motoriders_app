
import 'package:motoriders_app/models/chat_message_model.dart';

class ChatService {

  // Simula una base de datos de mensajes de chat por club
  final Map<String, List<ChatMessage>> _messages = {
    'club1': [
      ChatMessage(id: 'm1', authorName: 'Andrea GP', text: '¿Listos para la rodada del sábado?', timestamp: DateTime.now().subtract(const Duration(minutes: 5)), isSentByMe: false),
      ChatMessage(id: 'm2', authorName: 'jonfer119', text: '¡Más que listo! ¿A qué hora nos vemos?', timestamp: DateTime.now().subtract(const Duration(minutes: 4)), isSentByMe: true),
      ChatMessage(id: 'm3', authorName: 'Carlos_MX', text: 'Yo llego directo al punto de encuentro a las 9.', timestamp: DateTime.now().subtract(const Duration(minutes: 2)), isSentByMe: false),
    ]
  };

  Future<List<ChatMessage>> getMessagesForClub(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _messages[clubId] ?? [];
  }

  Future<void> sendMessage(String clubId, String text) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newMessage = ChatMessage(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'jonfer119', // TODO: Usar el usuario logueado
      text: text,
      timestamp: DateTime.now(),
      isSentByMe: true,
    );
    
    if (_messages.containsKey(clubId)) {
      _messages[clubId]!.add(newMessage);
    } else {
      _messages[clubId] = [newMessage];
    }
  }
}
