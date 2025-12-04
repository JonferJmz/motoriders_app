
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/models/rank_model.dart';
import 'package:motoriders_app/services/club_service.dart';

class PermissionManagementTab extends StatefulWidget {
  final Club club;
  const PermissionManagementTab({super.key, required this.club});

  @override
  State<PermissionManagementTab> createState() => _PermissionManagementTabState();
}

class _PermissionManagementTabState extends State<PermissionManagementTab> {
  final ClubService _clubService = ClubService();
  late Future<List<Rank>> _ranksFuture;
  Rank? _selectedRank;

  @override
  void initState() {
    super.initState();
    _loadRanks();
  }

  void _loadRanks() {
    _ranksFuture = _clubService.getRanksForClub(widget.club.id);
    _ranksFuture.then((ranks) {
      if (ranks.isNotEmpty && mounted) {
        setState(() {
          _selectedRank ??= ranks.first;
        });
      }
    });
    setState(() {}); 
  }

  void _updatePermission(Function(Rank r) update) {
    if (_selectedRank == null) return;
    final updatedRank = _selectedRank!;
    update(updatedRank);
    _clubService.updateRankInClub(widget.club.id, updatedRank);
    setState(() {}); // Actualiza la UI inmediatamente
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Rank>>(
      future: _ranksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Crea un rango primero en la pestaña 'Rangos'."));
        }

        final ranks = snapshot.data!;
        if (_selectedRank == null && ranks.isNotEmpty) {
          _selectedRank = ranks.first;
        }

        return Column(
          children: [
            _buildRankSelector(ranks),
            if (_selectedRank != null)
              Expanded(
                child: _buildPermissionList(_selectedRank!),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRankSelector(List<Rank> ranks) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButton<Rank>(
        value: _selectedRank,
        isExpanded: true,
        items: ranks.map((rank) {
          return DropdownMenuItem<Rank>(
            value: rank,
            child: Text(rank.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: (Rank? newRank) {
          setState(() {
            _selectedRank = newRank;
          });
        },
      ),
    );
  }

  Widget _buildPermissionList(Rank rank) {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Invitar usuarios'),
          value: rank.canInvite,
          onChanged: (value) => _updatePermission((r) => r.canInvite = value),
        ),
        SwitchListTile(
          title: const Text('Expulsar miembros'),
          value: rank.canKick,
          onChanged: (value) => _updatePermission((r) => r.canKick = value),
        ),
        SwitchListTile(
          title: const Text('Banear miembros'),
          value: rank.canBan,
          onChanged: (value) => _updatePermission((r) => r.canBan = value),
        ),
        SwitchListTile(
          title: const Text('Editar información del Club'),
          value: rank.canEditClubInfo,
          onChanged: (value) => _updatePermission((r) => r.canEditClubInfo = value),
        ),
      ],
    );
  }
}
