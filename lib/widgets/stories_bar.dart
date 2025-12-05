
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/story_model.dart';
import 'package:motoriders_app/services/story_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';
import 'package:motoriders_app/screens/story_view_screen.dart'; // <-- IMPORTAMOS LA NUEVA PANTALLA

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
        if (!snapshot.hasData) {
          return const SizedBox(height: 110); // Espacio reservado mientras carga
        }
        final stories = snapshot.data!;
        return Container(
          height: 110,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            itemBuilder: (context, index) {
              // Filtramos la historia del usuario actual para la navegación
              final displayStories = stories.where((s) => s.contentUrl.isNotEmpty).toList();
              return _buildStoryItem(context, stories[index], displayStories, isFirst: index == 0);
            },
          ),
        );
      },
    );
  }

  Widget _buildStoryItem(BuildContext context, Story story, List<Story> displayStories, {bool isFirst = false}) {
    final bool isAddButton = isFirst;
    final bool isViewed = story.isViewed;

    return Padding(
      padding: EdgeInsets.only(left: isFirst ? 16.0 : 8.0, right: isFirst ? 8.0 : 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (isAddButton) {
                // TODO: Abrir cámara para crear historia
              } else {
                final initialIndex = displayStories.indexWhere((s) => s.contentUrl == story.contentUrl);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryViewScreen(stories: displayStories, initialIndex: initialIndex),
                  ),
                );
              }
            },
            child: Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isAddButton || isViewed
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.teslaRed, Colors.orangeAccent],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                color: isViewed ? Colors.grey[800] : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(story.authorAvatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: isAddButton
                    ? const Center(
                        child: Icon(Icons.add, color: Colors.white, size: 30),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(story.authorName, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
