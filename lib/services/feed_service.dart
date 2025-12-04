
import 'package:motoriders_app/models/comment_model.dart';
import '../models/post_model.dart';

class FeedService {

  final List<Post> _posts = [
    Post(
      id: 'post1',
      authorId: 'user1',
      authorName: 'jonfer119',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=800&q=80',
      text: '¡Mi primera publicación en esta increíble app!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      likes: 15,
      comments: 2,
    ),
  ];

  final Map<String, List<Comment>> _comments = {
    'post1': [
      Comment(id: 'c1', authorId: 'user2', authorName: 'Andrea GP', authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=60', text: '¡Bienvenido!', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
    ]
  };


  Future<List<Post>> getFeedPosts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _posts;
  }

  Future<List<Post>> getPostsForClub(String clubId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _posts.where((p) => p.clubId == clubId).toList();
  }

  Future<void> addPost(String text) async {
    final newPost = Post(
      id: 'post${_posts.length+1}',
      authorId: 'user1',
      authorName: 'jonfer119',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=800&q=80',
      text: text,
      timestamp: DateTime.now(),
    );
    _posts.insert(0, newPost);
  }

   Future<void> toggleLikeStatus(String postId, String userId) async {
    // Lógica simulada
  }

  Future<List<Comment>> getComments(String postId) async {
     await Future.delayed(const Duration(milliseconds: 200));
    return _comments[postId] ?? [];
  }

  Future<void> addComment(String postId, String text) async {
    final newComment = Comment(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      authorId: 'user1',
      authorName: 'jonfer119',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=800&q=80',
      text: text,
      timestamp: DateTime.now(),
    );
     _comments[postId]?.add(newComment);
  }
}
