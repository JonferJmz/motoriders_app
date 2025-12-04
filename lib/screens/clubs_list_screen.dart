
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/services/club_service.dart';
import 'package:motoriders_app/widgets/club_list_tile.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final ClubService _clubService = ClubService();
  Future<List<Club>>? _myClubsFuture;

  @override
  void initState() {
    super.initState();
    _myClubsFuture = _clubService.getMyClubs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Clubes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () { /* TODO: Implementar búsqueda de clubes */ },
          ),
        ],
      ),
      body: FutureBuilder<List<Club>>(
        future: _myClubsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No perteneces a ningún club.'));
          }

          final clubs = snapshot.data!;

          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              return ClubListTile(club: clubs[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar pantalla para crear club
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
