
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/models/user_model.dart';
import 'package:motoriders_app/services/club_service.dart';
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/services/user_service.dart';
import 'package:motoriders_app/widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _query = widget.initialQuery!;
      if (widget.initialQuery!.startsWith('#')) {
        _tabController.animateTo(2); // Ir a la pestaña de Posts si es un hashtag
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Buscar usuarios, clubs, #tags...', border: InputBorder.none),
          onChanged: (value) => setState(() => _query = value),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Usuarios'),
            Tab(text: 'Clubs'),
            Tab(text: 'Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UserSearchTab(query: _query),
          _ClubSearchTab(query: _query),
          _PostSearchTab(query: _query),
        ],
      ),
    );
  }
}

// Pestañas de búsqueda individuales

class _UserSearchTab extends StatelessWidget {
  final String query;
  const _UserSearchTab({required this.query});

  @override
  Widget build(BuildContext context) {
    // Aquí iría la lógica de búsqueda real
    return Center(child: Text("Búsqueda de usuarios para: '$query'"));
  }
}

class _ClubSearchTab extends StatelessWidget {
  final String query;
  const _ClubSearchTab({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Búsqueda de clubs para: '$query'"));
  }
}

class _PostSearchTab extends StatelessWidget {
  final String query;
  const _PostSearchTab({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Búsqueda de posts para: '$query'"));
  }
}
