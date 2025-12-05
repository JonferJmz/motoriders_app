
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/screens/notifications_screen.dart';
import 'package:motoriders_app/screens/search_screen.dart';
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/services/notification_service.dart';
import 'package:motoriders_app/widgets/post_card.dart';
import 'package:motoriders_app/widgets/stories_bar.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

// RECONSTRUIDO CON PESTAÑAS "SIGUIENDO" Y "EXPLORAR"
class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MotoRiders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          // El botón de búsqueda ahora vive en la pestaña Explorar
          if (_tabController.index == 1) IconButton(icon: const Icon(Icons.search, size: 28), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()))),
          _NotificationButton(),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3.0,
          onTap: (_) => setState(() {}), // Para que la AppBar se redibuje y muestre/oculte el botón
          tabs: const [
            Tab(text: 'Siguiendo'),
            Tab(text: 'Explorar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FeedView(feedType: FeedType.following),
          _FeedView(feedType: FeedType.global, showStories: true), // El feed global es ahora "Explorar"
        ],
      ),
    );
  }
}

enum FeedType { global, following }

class _FeedView extends StatefulWidget {
  final FeedType feedType;
  final bool showStories;
  const _FeedView({required this.feedType, this.showStories = false});

  @override
  State<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<_FeedView> with AutomaticKeepAliveClientMixin {
  final FeedService _feedService = FeedService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _postsFuture = widget.feedType == FeedType.global 
        ? _feedService.getGlobalFeedPosts() 
        : _feedService.getFollowingFeedPosts();
  }

  Future<void> _refreshFeed() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() { _loadPosts(); });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _refreshFeed,
      child: CustomScrollView(
        slivers: [
          if (widget.showStories) const SliverToBoxAdapter(child: StoriesBar()),
          if (widget.showStories) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Divider(color: Colors.grey[800]))),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(48.0), child: Text(widget.feedType == FeedType.global ? 'No hay publicaciones.' : 'Aún no sigues a nadie o no han publicado.')) );
                final posts = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) => PostCard(post: posts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _NotificationButton extends StatefulWidget {
  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton> {
  final NotificationService _notificationService = NotificationService();
  late Future<int> _unreadNotificationsFuture;

  @override
  void initState() {
    super.initState();
    _unreadNotificationsFuture = _notificationService.getUnreadNotificationCount();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _unreadNotificationsFuture,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, size: 28),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                if (mounted) setState(() { _unreadNotificationsFuture = _notificationService.getUnreadNotificationCount(); });
              },
            ),
            if (count > 0)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                  child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ),
          ],
        );
      },
    );
  }
}
