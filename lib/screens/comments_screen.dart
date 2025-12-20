import 'package:flutter/material.dart';
import 'package:motoriders_app/models/comment_model.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/screens/public_profile_screen.dart'; // ✅ Nuevo Import
import 'package:motoriders_app/utils/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsScreen extends StatefulWidget {
  final Post post;

  const CommentsScreen({Key? key, required this.post}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final FeedService _feedService = FeedService();
  final TextEditingController _commentController = TextEditingController();

  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final comments = await _feedService.getComments(widget.post.id);
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final newComment = await _feedService.addComment(widget.post.id, text);

    if (mounted) {
      setState(() => _isSending = false);

      if (newComment != null) {
        _commentController.clear();
        setState(() {
          _comments.add(newComment);
        });
        FocusScope.of(context).unfocus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al enviar comentario"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comentarios"),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.red))
                : _comments.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _comments.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return _buildCommentItem(comment, isDark);
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, -2))
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Escribe un comentario...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSending ? null : _sendComment,
                    icon: _isSending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ CLIC EN AVATAR
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PublicProfileScreen(
                userId: comment.author.id,
                username: comment.author.username
              ))
            );
          },
          child: CircleAvatar(
            radius: 18,
            backgroundImage: comment.author.avatarUrl != null
                ? NetworkImage(comment.author.avatarUrl!)
                : null,
            backgroundColor: Colors.grey[800],
            child: comment.author.avatarUrl == null
                ? const Icon(Icons.person, size: 20, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ CLIC EN NOMBRE
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PublicProfileScreen(
                            userId: comment.author.id,
                            username: comment.author.username
                          ))
                        );
                      },
                      child: Text(
                        comment.author.username,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    Text(
                      timeago.format(comment.createdAt, locale: 'es'),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 10),
          const Text("Sé el primero en comentar", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}