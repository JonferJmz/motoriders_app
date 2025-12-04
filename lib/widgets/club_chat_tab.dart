
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/chat_message_model.dart';
import 'package:motoriders_app/services/chat_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class ClubChatTab extends StatefulWidget {
  final String clubId;
  const ClubChatTab({super.key, required this.clubId});

  @override
  State<ClubChatTab> createState() => _ClubChatTabState();
}

class _ClubChatTabState extends State<ClubChatTab> {
  final ChatService _chatService = ChatService();
  final _messageController = TextEditingController();
  late Future<List<ChatMessage>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    _messagesFuture = _chatService.getMessagesForClub(widget.clubId);
    setState(() {});
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();
    _messageController.clear();

    await _chatService.sendMessage(widget.clubId, text);
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<ChatMessage>>(
            future: _messagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Aún no hay mensajes. ¡Inicia la conversación!"));
              }
              final messages = snapshot.data!;
              return ListView.builder(
                reverse: true, // Para que el chat se muestre desde abajo
                padding: const EdgeInsets.all(10.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  return _buildMessageBubble(message);
                },
              );
            },
          ),
        ),
        _buildMessageInputField(),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isSentByMe;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: isMe ? AppColors.teslaRed : AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(message.text, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Escribe un mensaje...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.teslaRed),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
