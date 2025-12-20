import 'package:flutter/material.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/models/reaction_model.dart';
import 'package:motoriders_app/models/reactor_user_model.dart';
import 'package:motoriders_app/services/feed_service.dart';

class ReactionDetailsScreen extends StatefulWidget {
  final Post post;

  const ReactionDetailsScreen({Key? key, required this.post}) : super(key: key);

  @override
  _ReactionDetailsScreenState createState() => _ReactionDetailsScreenState();
}

class _ReactionDetailsScreenState extends State<ReactionDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FeedService _feedService = FeedService();

  // Datos reales
  List<ReactorUser> _allReactors = [];
  bool _isLoading = true;

  // Tabs definidos
  final List<ReactionType> _tabs = [
    ReactionType.like,
    ReactionType.gas,
    ReactionType.love,
    ReactionType.haha,
    ReactionType.angry
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length + 1, vsync: this);
    _loadReactions();
  }

  Future<void> _loadReactions() async {
    try {
      // ✅ CORREGIDO: Convertimos a String para evitar el error de tipos
      final users = await _feedService.getPostReactions(widget.post.id.toString());
      if (mounted) {
        setState(() {
          _allReactors = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error cargando reacciones: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reacciones"),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelColor: isDark ? Colors.white : Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            // Tab TODOS
            _buildTabCount("Todos", _isLoading ? 0 : _allReactors.length),
            // Tabs ESPECÍFICOS
            ..._tabs.map((type) {
              int count = _isLoading ? 0 : _allReactors.where((u) => u.reaction == type).length;
              return Tab(
                child: Row(
                  children: [
                    _getIconForTab(type, size: 18),
                    const SizedBox(width: 6),
                    Text(count.toString()),
                  ],
                ),
              );
            })
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(null), // Null = Todos
                ..._tabs.map((type) => _buildUserList(type)), // Filtrados
              ],
            ),
    );
  }

  Widget _buildTabCount(String label, int count) {
    return Tab(
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 4),
          Text("($count)", style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _getIconForTab(ReactionType type, {double size = 20}) {
    switch (type) {
      case ReactionType.gas: return Icon(Icons.flash_on, color: Colors.amber, size: size);
      case ReactionType.love: return Icon(Icons.favorite, color: Colors.red, size: size);
      case ReactionType.haha: return Icon(Icons.sentiment_very_satisfied, color: Colors.yellow, size: size);
      case ReactionType.angry: return Icon(Icons.sentiment_very_dissatisfied, color: Colors.deepOrange, size: size);
      default: return Icon(Icons.thumb_up, color: Colors.blue, size: size);
    }
  }

  Widget _buildUserList(ReactionType? filter) {
    // Filtrado local de la lista completa descargada
    final filteredUsers = filter == null
        ? _allReactors
        : _allReactors.where((user) => user.reaction == filter).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_neutral, size: 60, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 10),
            const Text("Nadie ha reaccionado así.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: filteredUsers.length,
      separatorBuilder: (ctx, index) => const Divider(height: 1, indent: 70),
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            backgroundColor: Colors.grey[800],
            child: user.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          subtitle: Text("@${user.username}"),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
              ]
            ),
            child: _getIconForTab(user.reaction, size: 18),
          ),
          onTap: () {
            // Acción al tocar usuario (ir a perfil)
          },
        );
      },
    );
  }
}