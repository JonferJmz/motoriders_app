
import 'package:motoriders_app/models/user_model.dart';

class UserService {
  final Map<String, User> _users = {
    'user1': User(
      id: 'user1', name: 'jonfer119', 
      avatarUrl: 'https://i.pravatar.cc/150?u=user1', 
      coverPhotoUrl: 'https://picsum.photos/seed/cover1/800/600', 
      bio: 'Apasionado de las dos ruedas y las rutas sin fin. Buscando la próxima aventura. 🏍️💨', 
      postCount: 42, clubCount: 3, kilometersRidden: 12540),
     'user2': User(id: 'user2', name: 'Andrea GP', avatarUrl: 'https://i.pravatar.cc/150?u=user2', coverPhotoUrl: 'https://picsum.photos/seed/cover2/800/600'),
     'user3': User(id: 'user3', name: 'RiderX', avatarUrl: 'https://i.pravatar.cc/150?u=user3', coverPhotoUrl: 'https://picsum.photos/seed/cover3/800/600'),
  };

  final Set<String> _following = {'user2'};

  Future<User> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_users.containsKey(userId)) return _users[userId]!;
    throw Exception('Usuario no encontrado');
  }

  Future<bool> isFollowing(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _following.contains(userId);
  }

  Future<void> followUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _following.add(userId);
  }

  Future<void> unfollowUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _following.remove(userId);
  }

   Future<Set<String>> getFollowingList() async {
     await Future.delayed(const Duration(milliseconds: 100));
     return _following;
   }
}
