
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/widgets/post_card.dart';

class ClubWallTab extends StatefulWidget {
  final String clubId;
  const ClubWallTab({super.key, required this.clubId});

  @override
  State<ClubWallTab> createState() => _ClubWallTabState();
}

class _ClubWallTabState extends State<ClubWallTab> {
  final FeedService _feedService = FeedService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _feedService.getPostsForClub(widget.clubId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aún no hay publicaciones en este club.'));
        }

        final posts = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostCard(post: posts[index]);
          },
        );
      },
    );
  }
}
