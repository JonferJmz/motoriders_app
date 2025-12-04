
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/screens/comments_screen.dart';
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';
import 'package:motoriders_app/widgets/post_options_sheet.dart';
import 'package:motoriders_app/widgets/share_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FeedService _feedService = FeedService();
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
  }

  void _toggleLike() {
    // Lógica simulada
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        widget.post.likes++;
      } else {
        widget.post.likes--;
      }
    });
  }

  void _navigateToComments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommentsScreen(post: widget.post)),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShareSheet(post: widget.post),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => PostOptionsSheet(post: widget.post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(widget.post.authorAvatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(_getFormattedTimestamp(widget.post.timestamp), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              IconButton(onPressed: _showOptionsSheet, icon: const Icon(Icons.more_horiz)),
            ],
          ),
          const SizedBox(height: 15),
          Text(widget.post.text, style: const TextStyle(fontSize: 15, height: 1.4)),
          const SizedBox(height: 15),
          if (widget.post.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(widget.post.imageUrl!, fit: BoxFit.cover, width: double.infinity, height: 200),
            ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                widget.post.likes.toString(),
                _toggleLike,
                isActive: _isLiked,
              ),
              _buildActionButton(
                Icons.chat_bubble_outline,
                widget.post.comments.toString(),
                _navigateToComments,
              ),
              _buildActionButton(Icons.send_outlined, null, _showShareSheet),
            ],
          ),
        ],
      ),
    );
  }

  String _getFormattedTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 1) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  Widget _buildActionButton(IconData icon, String? count, VoidCallback onPressed, {bool isActive = false}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: isActive ? AppColors.teslaRed : Colors.grey[600], size: 22),
      label: Text(
        count ?? '',
        style: TextStyle(color: isActive ? AppColors.teslaRed : Colors.grey[600], fontWeight: FontWeight.bold),
      ),
    );
  }
}
