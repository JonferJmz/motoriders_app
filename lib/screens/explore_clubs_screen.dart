
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/services/club_service.dart';
import 'package:motoriders_app/widgets/club_list_tile.dart';

class ExploreClubsScreen extends StatefulWidget {
  const ExploreClubsScreen({super.key});

  @override
  State<ExploreClubsScreen> createState() => _ExploreClubsScreenState();
}

class _ExploreClubsScreenState extends State<ExploreClubsScreen> {
  final ClubService _clubService = ClubService();
  late Future<List<Club>> _clubsFuture;

  @override
  void initState() {
    super.initState();
    // En un futuro, aquí se llamarían a un método que traiga TODOS los clubes públicos
    _clubsFuture = _clubService.getMyClubs(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorar Clubes"),
      ),
      body: FutureBuilder<List<Club>>(
        future: _clubsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay clubes para explorar por ahora."));
          }

          final clubs = snapshot.data!;
          return ListView.builder(
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              // Usamos el mismo tile que ya teníamos, ¡eficiencia!
              return ClubListTile(club: clubs[index]);
            },
          );
        },
      ),
    );
  }
}
