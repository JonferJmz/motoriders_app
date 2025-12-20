
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/story_model.dart';
import 'package:motoriders_app/services/story_service.dart';

class StoriesBar extends StatefulWidget {
  const StoriesBar({super.key});

  @override
  State<StoriesBar> createState() => _StoriesBarState();
}

class _StoriesBarState extends State<StoriesBar> {
  final StoryService _storyService = StoryService();
  late Future<List<Story>> _storiesFuture;

  @override
  void initState() {
    super.initState();
    _storiesFuture = _storyService.getStories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Story>>(
      future: _storiesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final stories = snapshot.data!;

        return Container(
          height: 110,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return _buildStoryAvatar(stories[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildStoryAvatar(Story story) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 75,
        height: 94,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: story.isViewed ? Colors.grey.shade600 : Colors.pink,
                  width: 2.0,
                ),
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundImage: NetworkImage(story.authorAvatarUrl),
              ),
            ),
            const SizedBox(height: 5.0),
            Text(
              story.authorName,
              style: const TextStyle(
                fontSize: 12,
                height: 1.0, // Control explícito de la altura de línea
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
