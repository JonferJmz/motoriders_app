import 'package:flutter/material.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/screens/create_post_screen.dart';
import 'package:motoriders_app/screens/notifications_screen.dart'; // ✅ Import necesario
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';
import 'package:motoriders_app/widgets/post_card.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FeedService _feedService = FeedService();

  Future<List<Post>>? _globalPostsFuture;
  Future<List<Post>>? _followingPostsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    setState(() {
      _globalPostsFuture = _feedService.getGlobalFeedPosts();
      _followingPostsFuture = _feedService.getFollowingFeedPosts();
    });
  }

  void _goToCreatePost() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result == true) {
      _loadFeeds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // ---------------------------------------------------------
      // AQUÍ ESTÁ LA BARRA SUPERIOR (APPBAR) CON LA CAMPANA 🔔
      // ---------------------------------------------------------
      appBar: AppBar(
        backgroundColor: Colors.black, // Fondo negro
        title: const Text(
          "MotoRiders",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        actions: [
          // Botón de búsqueda (opcional, para equilibrio visual)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Acción de búsqueda pendiente
            },
          ),
          // --- BOTÓN DE NOTIFICACIONES ---
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white), // Icono Blanco
                onPressed: () {
                  // Navegación a la pantalla de notificaciones
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              // Puntito rojo de "actividad"
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.teslaRed,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 10), // Espacio extra a la derecha
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.teslaRed,
          labelColor: AppColors.teslaRed,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Explorar"),
            Tab(text: "Siguiendo"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedList(_globalPostsFuture),
          _buildFeedList(_followingPostsFuture),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.teslaRed,
        heroTag: "unique_create_post_btn",
        onPressed: _goToCreatePost,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFeedList(Future<List<Post>>? future) {
    return FutureBuilder<List<Post>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.teslaRed));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error cargando feed: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return RefreshIndicator(
            onRefresh: _loadFeeds,
            color: AppColors.teslaRed,
            child: ListView(
              children: const [
                SizedBox(height: 100),
                Center(child: Text("Aún no hay publicaciones")),
              ],
            ),
          );
        }

        final posts = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _loadFeeds,
          color: AppColors.teslaRed,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          ),
        );
      },
    );
  }
}