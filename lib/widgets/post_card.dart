
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/models/reaction_model.dart';
import 'package:motoriders_app/screens/comments_screen.dart';
import 'package:motoriders_app/screens/search_screen.dart';
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FeedService _feedService = FeedService();
  final _reactionButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  ReactionType? _selectedReaction;
  final _fingerPositionController = StreamController<Offset>.broadcast();

  @override
  void dispose() {
    _fingerPositionController.close();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _handleReaction(ReactionType? reaction, {bool isFinal = false}) {
    if (isFinal) {
      if (reaction == null) return;
      setState(() {
        if (widget.post.currentUserReaction == reaction) {
          _feedService.removeReaction(widget.post.id, reaction);
          widget.post.reactionCounts.update(reaction, (v) => v - 1);
          widget.post.currentUserReaction = null;
        } else {
          if (widget.post.currentUserReaction != null) {
            _feedService.removeReaction(
                widget.post.id, widget.post.currentUserReaction!);
            widget.post.reactionCounts
                .update(widget.post.currentUserReaction!, (v) => v - 1);
          }
          _feedService.addReaction(widget.post.id, reaction);
          widget.post.reactionCounts
              .update(reaction, (v) => v + 1, ifAbsent: () => 1);
          widget.post.currentUserReaction = reaction;
        }
      });
    } else {
      _selectedReaction = reaction;
    }
  }

  void _showReactionBar() {
    final RenderBox renderBox =
        _reactionButtonKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    double left = position.dx - 40;
    if (left < 16) left = 16;
    if (left + 280 > screenWidth) left = screenWidth - 280 - 16;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy - 70,
        left: left,
        child: ReactionBar(
          onReactionSelected: (reaction) =>
              _handleReaction(reaction, isFinal: false),
          fingerPositionStream: _fingerPositionController.stream,
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideReactionBar() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 15),
          if (widget.post.text.isNotEmpty) _buildPostText(context),
          if (widget.post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 15),
            _buildImageGrid()
          ],
          _buildStats(),
          const Divider(),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildPostText(BuildContext context) {
    final List<TextSpan> textSpans = [];
    final words = widget.post.text.split(' ');

    for (var word in words) {
      if (word.startsWith('#') && word.length > 1) {
        textSpans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SearchScreen(initialQuery: word)));
              },
          ),
        );
      } else {
        textSpans.add(TextSpan(text: '$word '));
      }
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context)
            .style
            .copyWith(fontSize: 15, height: 1.4),
        children: textSpans,
      ),
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      CircleAvatar(radius: 22, backgroundImage: NetworkImage(widget.post.authorAvatarUrl)),
      const SizedBox(width: 12),
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(widget.post.authorName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text("Hace 1h",
                style: TextStyle(color: Colors.grey[600], fontSize: 12))
          ])),
      IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
    ]);
  }

  Widget _buildImageGrid() {
    final images = widget.post.imageUrls;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: images.length > 1 ? 2 : 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[800]),
                errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.grey)));
          }),
    );
  }

  Widget _buildStats() {
    final topReactions = widget.post.reactionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = widget.post.totalReactions;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(children: [
          if (total > 0)
            SizedBox(
              width: (topReactions.take(3).length * 16.0) + 4,
              height: 20,
              child: Stack(
                children: topReactions.take(3).toList().asMap().entries.map((entry) {
                  return Positioned(
                      left: entry.key * 15.0,
                      child: Text(_getReactionEmoji(entry.value.key),
                          style: const TextStyle(fontSize: 16)));
                }).toList(),
              ),
            ),
          if (total > 0) Text(total.toString()),
          const Spacer(),
          if (widget.post.comments > 0)
            Text("${widget.post.comments} comentarios")
        ]));
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: GestureDetector(
                onLongPressStart: (details) => _showReactionBar(),
                onLongPressMoveUpdate: (details) =>
                    _fingerPositionController.add(details.globalPosition),
                onLongPressEnd: (details) {
                  _hideReactionBar();
                  _handleReaction(_selectedReaction, isFinal: true);
                },
                onTap: () => _handleReaction(ReactionType.like, isFinal: true),
                child: Container(
                    color: Colors.transparent,
                    key: _reactionButtonKey,
                    child: _buildReactionButton())),
          ),
          _buildActionButton(
              Icons.chat_bubble_outline,
              "Comentar",
              () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommentsScreen(post: widget.post)))),
          _buildActionButton(Icons.send_outlined, "Compartir", () {})
        ]);
  }

  Widget _buildReactionButton() {
    final currentReaction = widget.post.currentUserReaction;
    final color = _getReactionColor(currentReaction, context);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_getReactionEmoji(currentReaction),
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            _getReactionName(currentReaction),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          )
        ]));
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.grey[600]),
        label: Text(label, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}

String _getReactionEmoji(ReactionType? type) {
  switch (type) {
    case ReactionType.like:
      return '👍';
    case ReactionType.love:
      return '❤️';
    case ReactionType.haha:
      return '😂';
    case ReactionType.gas:
      return '🏍️';
    case ReactionType.sad:
      return '😢';
    default:
      return '👍';
  }
}

String _getReactionName(ReactionType? type) {
  switch (type) {
    case ReactionType.like:
      return 'Me gusta';
    case ReactionType.love:
      return 'Me encanta';
    case ReactionType.haha:
      return 'Me divierte';
    case ReactionType.gas:
      return '¡Gas!';
    case ReactionType.sad:
      return 'Me entristece';
    default:
      return 'Me gusta';
  }
}

Color _getReactionColor(ReactionType? type, BuildContext context) {
  if (type == null) return Colors.grey[600]!;
  switch (type) {
    case ReactionType.like:
      return Colors.blue;
    case ReactionType.love:
      return Colors.red;
    case ReactionType.haha:
      return Colors.orange;
    case ReactionType.gas:
      return AppColors.teslaRed;
    case ReactionType.sad:
      return Colors.grey[700]!;
    default:
      return Colors.grey[600]!;
  }
}

class ReactionBar extends StatefulWidget {
  final Function(ReactionType?) onReactionSelected;
  final Stream<Offset> fingerPositionStream;
  const ReactionBar(
      {super.key,
      required this.onReactionSelected,
      required this.fingerPositionStream});
  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  ReactionType? _hoveredReaction;
  final List<GlobalKey> _reactionKeys =
      List.generate(ReactionType.values.length, (_) => GlobalKey());
  late StreamSubscription _fingerPositionSubscription;
  @override
  void initState() {
    super.initState();
    _fingerPositionSubscription =
        widget.fingerPositionStream.listen((fingerPosition) {
      ReactionType? newHoveredReaction;
      for (int i = 0; i < _reactionKeys.length; i++) {
        final key = _reactionKeys[i];
        final box = key.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero);
          if (fingerPosition.dx >= position.dx &&
              fingerPosition.dx <= position.dx + box.size.width &&
              fingerPosition.dy >= position.dy - 20 &&
              fingerPosition.dy <= position.dy + box.size.height + 20) {
            newHoveredReaction = ReactionType.values[i];
            break;
          }
        }
      }
      if (_hoveredReaction != newHoveredReaction) {
        setState(() {
          _hoveredReaction = newHoveredReaction;
        });
        widget.onReactionSelected(_hoveredReaction);
      }
    });
  }

  @override
  void dispose() {
    _fingerPositionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
            ]),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ReactionType.values.asMap().entries.map((entry) {
              return AnimatedScale(
                  scale: _hoveredReaction == entry.value ? 1.5 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Padding(
                      key: _reactionKeys[entry.key],
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(_getReactionEmoji(entry.value),
                          style: const TextStyle(fontSize: 30))));
            }).toList()));
  }
}
