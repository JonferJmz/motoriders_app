
import 'package:motoriders_app/models/story_model.dart';

class StoryService {
  
  final List<Story> _stories = [
    Story(
      authorName: 'Tu Historia', 
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=user1',
      contentUrl: '', // URL vacía para indicar que es para añadir
      timestamp: DateTime.now(),
    ),
    Story(
      authorName: 'Andrea GP',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=user2',
      contentUrl: 'https://picsum.photos/seed/story1/900/1600',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Story(
      authorName: 'RiderX',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=user3',
      contentUrl: 'https://picsum.photos/seed/story2/900/1600',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      isViewed: true,
    ),
     Story(
      authorName: 'Carlos_MX',
      authorAvatarUrl: 'https://i.pravatar.cc/150?u=user4',
      contentUrl: 'https://picsum.photos/seed/story3/900/1600',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
  ];

  Future<List<Story>> getStories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _stories;
  }
}
