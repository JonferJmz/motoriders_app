
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/screens/explore_clubs_screen.dart';
import 'package:motoriders_app/services/club_service.dart';
import 'package:motoriders_app/widgets/club_list_tile.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final ClubService _clubService = ClubService();
  late Future<List<Club>> _myClubsFuture;

  @override
  void initState() {
    super.initState();
    _myClubsFuture = _clubService.getMyClubs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Clubes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExploreClubsScreen()));
        },
        label: const Text('Explorar'),
        icon: const Icon(Icons.explore_outlined),
      ),
      body: FutureBuilder<List<Club>>(
        future: _myClubsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar tus clubes.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aún no te has unido a ningún club.'));
          }

          final clubs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100), // <-- ESPACIO DE SEGURIDAD
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              return ClubListTile(club: clubs[index]);
            },
          );
        },
      ),
    );
  }
}
