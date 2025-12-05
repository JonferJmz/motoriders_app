
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/chat_message_model.dart';
import 'package:motoriders_app/screens/garage_profile_screen.dart';
import 'package:motoriders_app/services/chat_service.dart';

class ClubChatTab extends StatefulWidget {
  final String clubId;
  const ClubChatTab({super.key, required this.clubId});

  @override
  State<ClubChatTab> createState() => _ClubChatTabState();
}

class _ClubChatTabState extends State<ClubChatTab> {
  final ChatService _chatService = ChatService();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late Stream<List<ChatMessage>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = _chatService.getMessagesStream(widget.clubId);
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    _chatService.sendMessage(widget.clubId, _textController.text.trim());
    _textController.clear();
    // Pequeño delay para que el mensaje aparezca y luego hacer scroll
    Timer(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _messagesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Aún no hay mensajes. ¡Rompe el hielo!"));
              }
              final messages = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  // Simula que 'user1' es el usuario actual
                  final bool isMe = message.authorId == 'user1'; 
                  return _buildMessageBubble(message, isMe);
                },
              );
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GarageProfileScreen(userId: message.authorId))),
            child: CircleAvatar(backgroundImage: NetworkImage(message.authorAvatarUrl), radius: 16),
          ),
        Flexible(
          child: Card(
            color: isMe ? Theme.of(context).primaryColor.withOpacity(0.8) : Theme.of(context).cardColor,
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
              )
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe) Text(message.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueAccent)),
                  if (!isMe) const SizedBox(height: 4),
                  Text(message.text, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black12, offset: Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send), 
            color: Theme.of(context).primaryColor,
            onPressed: _sendMessage
          ),
        ],
      ),
    );
  }
}
