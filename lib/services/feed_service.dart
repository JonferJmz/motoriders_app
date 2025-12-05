
import 'package:motoriders_app/models/comment_model.dart';
import 'package:motoriders_app/models/reaction_model.dart';
import 'package:motoriders_app/services/user_service.dart';
import '../models/post_model.dart';

class FeedService {
  // Simulación de una base de datos de posts
  final List<Post> _posts = [
    Post(
      id: 'post2', authorId: 'user3', authorName: 'RiderX', authorAvatarUrl: 'https://i.pravatar.cc/150?u=user3', 
      // AÑADIDO: Texto con Hashtag
      text: '¡Qué buena ruta la de hoy! Saliendo a explorar nuevos caminos. #RutaNocturna #MotoLife 🏍️💨', 
      imageUrls: ['https://picsum.photos/seed/moto1/600/800', 'https://picsum.photos/seed/moto2/600/800'], 
      timestamp: DateTime.now().subtract(const Duration(hours: 2)), clubId: 'club1', comments: 15, reactionCounts: { ReactionType.like: 75, ReactionType.love: 30, ReactionType.gas: 15 }, currentUserReaction: ReactionType.like),
    Post(id: 'post3', authorId: 'user2', authorName: 'Andrea GP', authorAvatarUrl: 'https://i.pravatar.cc/150?u=user2', text: 'Estrenando mi nueva moto. ¡Estoy enamorada! ❤️ #NuevaMoto', imageUrls: ['https://picsum.photos/seed/moto3/600/800'], timestamp: DateTime.now().subtract(const Duration(hours: 5)), comments: 32, reactionCounts: { ReactionType.love: 150, ReactionType.like: 45}),
    Post(id: 'post1', authorId: 'user1', authorName: 'jonfer119', authorAvatarUrl: 'https://i.pravatar.cc/150?u=user1', text: '¡Mi primera publicación en esta increíble app!', timestamp: DateTime.now().subtract(const Duration(minutes: 10)), comments: 2, reactionCounts: { ReactionType.like: 15 }),
  ];

  final UserService _userService = UserService();

  Future<List<Post>> getGlobalFeedPosts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return _posts;
  }

  Future<List<Post>> getFollowingFeedPosts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final followingIds = await _userService.getFollowingList();
    final userOwnId = 'user1';
    final feedIds = {...followingIds, userOwnId};
    
    final feedPosts = _posts.where((post) => feedIds.contains(post.authorId)).toList();
    feedPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return feedPosts;
  }
  
  // ... resto de funciones ...
  final Map<String, List<Comment>> _comments = {'post1': [Comment(id: 'c1', authorId: 'user2', authorName: 'Andrea GP', authorAvatarUrl: 'https://i.pravatar.cc/150?u=user2', text: '¡Bienvenido!', timestamp: DateTime.now().subtract(const Duration(minutes: 5)))]};
  Future<List<Post>> getPostsForClub(String clubId) async { await Future.delayed(const Duration(milliseconds: 300)); return _posts.where((p) => p.clubId == clubId).toList(); }
  Future<void> addPost(String text, {List<String> images = const []}) async { final newPost = Post(id: 'post${DateTime.now().millisecondsSinceEpoch}', authorId: 'user1', authorName: 'jonfer119', authorAvatarUrl: 'https://i.pravatar.cc/150?u=user1', text: text, imageUrls: images, timestamp: DateTime.now()); _posts.insert(0, newPost); }
  Future<void> addReaction(String postId, ReactionType reaction) async { await Future.delayed(const Duration(milliseconds: 200)); final post = _posts.firstWhere((p) => p.id == postId); post.currentUserReaction = reaction; post.reactionCounts.update(reaction, (value) => value + 1, ifAbsent: () => 1); }
  Future<void> removeReaction(String postId, ReactionType reaction) async { await Future.delayed(const Duration(milliseconds: 200)); final post = _posts.firstWhere((p) => p.id == postId); post.currentUserReaction = null; post.reactionCounts.update(reaction, (value) => value - 1); }
  Future<List<Comment>> getComments(String postId) async { await Future.delayed(const Duration(milliseconds: 200)); return _comments[postId] ?? []; }
  Future<void> addComment(String postId, String text) async { } 
}
