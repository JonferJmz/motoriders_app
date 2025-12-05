
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/models/user_model.dart';
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/services/user_service.dart';
import 'package:motoriders_app/widgets/post_card.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class GarageProfileScreen extends StatefulWidget {
  final VoidCallback? logout;
  final VoidCallback? toggleTheme;
  final String? userId; // Opcional, para visitar perfiles de otros

  const GarageProfileScreen({super.key, this.logout, this.toggleTheme, this.userId});

  @override
  State<GarageProfileScreen> createState() => _GarageProfileScreenState();
}

class _GarageProfileScreenState extends State<GarageProfileScreen> {
  final UserService _userService = UserService();
  final FeedService _feedService = FeedService();
  late Future<User> _userFuture;
  late Future<List<Post>> _postsFuture;
  late Future<bool> _isFollowingFuture;
  late String _profileUserId;
  bool _isCurrentUserProfile = false;

  @override
  void initState() {
    super.initState();
    const currentUserId = 'user1'; 
    _profileUserId = widget.userId ?? currentUserId;
    _isCurrentUserProfile = _profileUserId == currentUserId;
    _loadData();
  }

  void _loadData() {
    _userFuture = _userService.getUserProfile(_profileUserId);
    // CORRECCIÓN: Se llama a la función con el nombre correcto: getGlobalFeedPosts
    _postsFuture = _feedService.getGlobalFeedPosts(); // Simulado para mostrar todos los posts
    if (!_isCurrentUserProfile) {
      _isFollowingFuture = _userService.isFollowing(_profileUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text("No se pudo cargar el perfil.")));
        }
        final user = snapshot.data!;
        return _buildProfileScaffold(context, user);
      },
    );
  }

  Scaffold _buildProfileScaffold(BuildContext context, User user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, user),
          SliverToBoxAdapter(child: _buildUserInfo(context, user)),
          SliverToBoxAdapter(child: const Padding(padding: EdgeInsets.all(16.0), child: Text("Publicaciones", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
          _buildUserPosts(),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, User user) {
    return SliverAppBar(
      expandedHeight: 200.0, floating: false, pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, elevation: 1,
      actions: _isCurrentUserProfile ? [
        IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        IconButton(icon: const Icon(Icons.logout), onPressed: widget.logout),
        IconButton(icon: const Icon(Icons.brightness_6_outlined), onPressed: widget.toggleTheme),
      ] : [],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(user.coverPhotoUrl, fit: BoxFit.cover, color: Colors.black.withOpacity(0.4), colorBlendMode: BlendMode.darken),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true, titlePadding: const EdgeInsets.only(left: 0, bottom: 16),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, User user) {
    return Container(
      transform: Matrix4.translationValues(0.0, -40.0, 0.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          CircleAvatar(radius: 42, backgroundColor: Theme.of(context).scaffoldBackgroundColor, child: CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.avatarUrl))),
          const SizedBox(height: 16),
          Text(user.bio, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
          const SizedBox(height: 20),
          _buildStatsRow(user),
          if (!_isCurrentUserProfile) const SizedBox(height: 20),
          if (!_isCurrentUserProfile) _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return FutureBuilder<bool>(
      future: _isFollowingFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 48); // Placeholder
        final isFollowing = snapshot.data!;
        return ElevatedButton(
          onPressed: () {
            setState(() {
              if (isFollowing) {
                _userService.unfollowUser(_profileUserId);
              } else {
                _userService.followUser(_profileUserId);
              }
              _isFollowingFuture = _userService.isFollowing(_profileUserId);
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey[700] : AppColors.teslaRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          ),
          child: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
        );
      },
    );
  }

  Widget _buildStatsRow(User user) { return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStatItem("Posts", user.postCount.toString()), _buildStatItem("Clubs", user.clubCount.toString()), _buildStatItem("Km Recorridos", "${(user.kilometersRidden / 1000).toStringAsFixed(1)}k")]); }
  Widget _buildStatItem(String label, String value) { return Column(children: [Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600]))]); }
  Widget _buildUserPosts() { return FutureBuilder<List<Post>>(future: _postsFuture, builder: (context, snapshot) { if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())); final posts = snapshot.data!; return SliverList(delegate: SliverChildBuilderDelegate((context, index) { return PostCard(post: posts[index]); }, childCount: posts.length)); }); }
}
