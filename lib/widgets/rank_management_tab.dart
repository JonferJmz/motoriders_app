
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/models/rank_model.dart';
import 'package:motoriders_app/services/club_service.dart';
import 'package:motoriders_app/widgets/edit_rank_dialog.dart';

class RankManagementTab extends StatefulWidget {
  final Club club;
  const RankManagementTab({super.key, required this.club});

  @override
  State<RankManagementTab> createState() => _RankManagementTabState();
}

class _RankManagementTabState extends State<RankManagementTab> {
  final ClubService _clubService = ClubService();
  late Future<List<Rank>> _ranksFuture;

  @override
  void initState() {
    super.initState();
    _loadRanks();
  }

  void _loadRanks() {
    setState(() {
      _ranksFuture = _clubService.getRanksForClub(widget.club.id);
    });
  }

  void _showEditRankDialog({Rank? rank}) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditRankDialog(rank: rank),
    );

    if (result != null && result.isNotEmpty) {
      if (rank == null) { // Creando nuevo rango
        final newRank = Rank(id: 'temp-${DateTime.now().millisecondsSinceEpoch}', name: result);
        await _clubService.addRankToClub(widget.club.id, newRank);
      } else { // Actualizando rango existente
        final updatedRank = rank;
        updatedRank.name = result;
        await _clubService.updateRankInClub(widget.club.id, updatedRank);
      }
      _loadRanks();
    }
  }

  void _showDeleteConfirmationDialog(Rank rank) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar el rango "${rank.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _clubService.deleteRankFromClub(widget.club.id, rank.id);
      _loadRanks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditRankDialog(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Rank>>(
        future: _ranksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay rangos para este club. Presiona + para crear uno.'));
          }

          final ranks = snapshot.data!;

          return ListView.builder(
            itemCount: ranks.length,
            itemBuilder: (context, index) {
              final rank = ranks[index];
              return ListTile(
                leading: Icon(Icons.military_tech, color: rank.color),
                title: Text(rank.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => _showEditRankDialog(rank: rank),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmationDialog(rank),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
