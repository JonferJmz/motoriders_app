import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:motoriders_app/models/chat_message_model.dart';
import 'package:motoriders_app/services/chat_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ClubChatTab extends StatefulWidget {
  final String clubId;
  const ClubChatTab({super.key, required this.clubId});

  @override
  State<ClubChatTab> createState() => _ClubChatTabState();
}

class _ClubChatTabState extends State<ClubChatTab> {
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String? _myUsername;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  void _initChat() async {
    const storage = FlutterSecureStorage();
    _myUsername = await storage.read(key: 'username');

    // 1. Cargar historial
    final history = await _chatService.getChatHistory(widget.clubId);
    if (mounted) {
      setState(() {
        _messages.clear(); // ⚠️ LIMPIEZA CLAVE: Evita duplicados al recargar
        _messages.addAll(history);
      });
      _printDebugIds("Historial Cargado"); // Debug
      _scrollToBottom();
    }

    // 2. Conectar WebSocket
    final channel = await _chatService.connectToClub(widget.clubId);
    if (channel != null) {
      channel.stream.listen((data) {
        final jsonData = jsonDecode(data);

        // Si es actualización (borrado/editado)
        if (jsonData['is_deleted'] == true || jsonData['is_edited'] == true) {
          _updateMessageInList(jsonData);
        } else {
          // Es mensaje nuevo
          final newMessage = ChatMessage.fromJson(jsonData);

          // ⚠️ PREVENCIÓN DE DUPLICADOS: Solo agregamos si no existe ese ID
          final existe = _messages.any((m) => m.id == newMessage.id);
          if (!existe && mounted) {
            setState(() => _messages.add(newMessage));
            _scrollToBottom();
          }
        }
      }, onError: (error) => print("Error chat: $error"));
    }
  }

  void _updateMessageInList(Map<String, dynamic> json) {
    final id = json['id'];
    // Buscamos el índice exacto
    final index = _messages.indexWhere((msg) => msg.id == id);
    if (index != -1 && mounted) {
      setState(() {
        _messages[index] = ChatMessage.fromJson(json);
      });
    }
  }

  void _printDebugIds(String action) {
    // Esto mostrará en tu terminal los IDs reales que tiene la lista
    final ids = _messages.map((m) => m.id).toList();
    print("DEBUG ($action): IDs actuales en lista -> $ids");
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    _chatService.sendMessage(_textController.text.trim());
    _textController.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut
        );
      });
    }
  }

  Future<void> _deleteMessage(int messageId) async {
    print("DEBUG: Intentando borrar mensaje con ID: $messageId");

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    final url = Uri.parse('${ChatService.httpBaseUrl}/chat/message/$messageId');

    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        setState(() {
          _messages[index] = ChatMessage(
            id: _messages[index].id,
            user: _messages[index].user,
            message: _messages[index].message,
            timestamp: _messages[index].timestamp,
            isDeleted: true,
            isEdited: _messages[index].isEdited,
          );
        });
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al borrar (Backend rechazó)")));
    }
  }

  Future<void> _editMessage(int messageId, String newContent) async {
    print("DEBUG: Intentando editar mensaje con ID: $messageId");

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    final url = Uri.parse('${ChatService.httpBaseUrl}/chat/message/$messageId');

    final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({"content": newContent})
    );

    if (response.statusCode == 200) {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        setState(() {
          _messages[index] = ChatMessage(
            id: _messages[index].id,
            user: _messages[index].user,
            message: newContent,
            timestamp: _messages[index].timestamp,
            isDeleted: false,
            isEdited: true,
          );
        });
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al editar (Backend rechazó)")));
    }
  }

  void _showEditDialog(BuildContext context, ChatMessage msg) {
    final editController = TextEditingController(text: msg.message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar mensaje"),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _editMessage(msg.id, editController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teslaRed),
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(child: Text("Chat vacío...", style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isMe = msg.user == _myUsername;
              // ⚠️ USAMOS KEY PARA QUE FLUTTER NO SE PIERDA
              return _buildWhatsAppBubble(msg, isMe, isDark, key: ValueKey(msg.id));
            },
          ),
        ),
        _buildInputArea(isDark),
      ],
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: const InputDecoration(hintText: "Mensaje", border: InputBorder.none),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.teslaRed,
            radius: 24,
            child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _sendMessage),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppBubble(ChatMessage msg, bool isMe, bool isDark, {required Key key}) {
    final timeString = DateFormat('HH:mm').format(msg.timestamp.toLocal());
    final bubbleColor = isMe ? const Color(0xFF005C4B) : (isDark ? const Color(0xFF202C33) : Colors.white);
    final textColor = msg.isDeleted ? Colors.grey : (isMe ? Colors.white : (isDark ? Colors.white : Colors.black));
    final displayText = msg.isDeleted ? "🚫 Se eliminó este mensaje" : msg.message;

    return Align(
      key: key, // ⚠️ LA LLAVE ÚNICA SE APLICA AQUÍ
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          if (isMe && !msg.isDeleted) _showOptionsDialog(context, msg);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(12).copyWith(
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 1))],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe) ...[
                  Text(msg.user, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange[400])),
                  const SizedBox(height: 2),
                ],
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  children: [
                    Text(displayText, style: TextStyle(fontSize: 16, color: textColor, fontStyle: msg.isDeleted ? FontStyle.italic : FontStyle.normal)),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (msg.isEdited && !msg.isDeleted)
                            Text("editado  ", style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : Colors.grey[500], fontStyle: FontStyle.italic)),
                          Text("$timeString (ID: ${msg.id})", style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : Colors.grey[500])),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, ChatMessage msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Editar mensaje'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditDialog(context, msg);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar para todos', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteMessage(msg.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}