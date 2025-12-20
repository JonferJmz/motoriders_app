import 'package:flutter/material.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/models/reaction_model.dart';
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/screens/comments_screen.dart';
import 'package:motoriders_app/screens/reaction_details_screen.dart';
import 'package:motoriders_app/utils/app_colors.dart';
import 'package:motoriders_app/widgets/animated_reaction_button.dart';
import 'package:motoriders_app/widgets/share_post_sheet.dart';
import 'package:motoriders_app/screens/public_profile_screen.dart'; // ✅ Nuevo Import
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FeedService _feedService = FeedService();
  late bool _isLiked;
  late int _likesCount;
  ReactionType? _currentReaction;

  @override
  void initState() {
    super.initState();
    _currentReaction = widget.post.myReaction != null
        ? ReactionConverter.fromString(widget.post.myReaction!)
        : null;
    _isLiked = _currentReaction != null;
    _likesCount = widget.post.likesCount;
  }

  void _onReactionSelected(ReactionType type) async {
    setState(() {
      if (_currentReaction == null) _likesCount++;
      _currentReaction = type;
      _isLiked = true;
    });

    final success = await _feedService.addReaction(widget.post.id, type);
    if (!success) {
      setState(() {
        _currentReaction = null;
        _isLiked = false;
        _likesCount--;
      });
    }
  }

  void _onReactionRemoved() async {
    final prevReaction = _currentReaction;
    setState(() {
      _currentReaction = null;
      _isLiked = false;
      _likesCount--;
    });

    final success = await _feedService.addReaction(widget.post.id, prevReaction ?? ReactionType.like);
    if (!success) {
      setState(() {
        _currentReaction = prevReaction;
        _isLiked = true;
        _likesCount++;
      });
    }
  }

  void _openShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SharePostSheet(post: widget.post),
    );
  }

  // ✅ Navegación al perfil
  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PublicProfileScreen(
        userId: widget.post.author.id,
        username: widget.post.author.username
      ))
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABECERA CON NAVEGACIÓN
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: GestureDetector(
              onTap: _goToProfile,
              child: CircleAvatar(
                backgroundImage: widget.post.author.avatarUrl != null
                    ? NetworkImage(widget.post.author.avatarUrl!)
                    : null,
                child: widget.post.author.avatarUrl == null ? const Icon(Icons.person) : null,
              ),
            ),
            title: GestureDetector(
              onTap: _goToProfile,
              child: Text(widget.post.author.fullName, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            ),
            subtitle: Text("@${widget.post.author.username} • ${timeago.format(widget.post.createdAt, locale: 'es')}", style: TextStyle(color: Colors.grey[600])),
          ),

          // TEXTO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(widget.post.text, style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
          ),

          // IMAGEN
          if (widget.post.imageUrl != null)
            Container(
              height: 300, width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(widget.post.imageUrl!), fit: BoxFit.cover),
              ),
            ),

          // CONTADORES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_likesCount > 0) {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => ReactionDetailsScreen(post: widget.post)));
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      if (_likesCount > 0) ...[
                         _buildTopReactionsIcons(),
                         const SizedBox(width: 6),
                      ],
                      Text(
                        "$_likesCount",
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(post: widget.post))),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    "${widget.post.commentsCount} comentarios",
                    style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // BOTONES DE ACCIÓN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedReactionButton(
                  initialReaction: _currentReaction,
                  onReactionSelected: _onReactionSelected,
                  onReactionRemoved: _onReactionRemoved,
                ),

                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(post: widget.post))),
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                  label: const Text("Comentar", style: TextStyle(color: Colors.grey)),
                ),

                TextButton.icon(
                  onPressed: _openShareSheet,
                  icon: const Icon(Icons.share, color: Colors.grey),
                  label: const Text("Compartir", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopReactionsIcons() {
    List<ReactionType> topReactions = [];
    if (_currentReaction != null) {
      topReactions.add(_currentReaction!);
    } else {
      topReactions.add(ReactionType.like);
    }
    if (_likesCount > 2 && !topReactions.contains(ReactionType.gas)) topReactions.add(ReactionType.gas);
    if (_likesCount > 5 && !topReactions.contains(ReactionType.love)) topReactions.add(ReactionType.love);
    if (topReactions.length > 3) topReactions = topReactions.sublist(0, 3);

    return SizedBox(
      width: 18.0 * topReactions.length + 2,
      height: 20,
      child: Stack(
        children: List.generate(topReactions.length, (index) {
          return Positioned(
            left: index * 16.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).cardColor, width: 1.5),
              ),
              child: _getSmallIcon(topReactions[index]),
            ),
          );
        }),
      ),
    );
  }

  Widget _getSmallIcon(ReactionType type) {
    switch (type) {
      case ReactionType.gas: return const Icon(Icons.flash_on, size: 16, color: Colors.amber);
      case ReactionType.love: return const Icon(Icons.favorite, size: 16, color: Colors.red);
      case ReactionType.haha: return Icon(Icons.sentiment_very_satisfied, size: 16, color: Colors.yellow[700]);
      case ReactionType.angry: return Icon(Icons.sentiment_very_dissatisfied, size: 16, color: Colors.deepOrange);
      default: return const Icon(Icons.thumb_up, size: 16, color: Colors.blue);
    }
  }
}