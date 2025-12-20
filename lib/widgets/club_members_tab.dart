
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/rank_model.dart';
import 'package:motoriders_app/services/club_service.dart';
import 'package:motoriders_app/widgets/edit_rank_dialog.dart';

class ClubMembersTab extends StatefulWidget {
  final String clubId;
  final bool isCurrentUserAdmin; // Lo pasamos como parámetro

  const ClubMembersTab({super.key, required this.clubId, this.isCurrentUserAdmin = false});

  @override
  State<ClubMembersTab> createState() => _ClubMembersTabState();
}

class _ClubMembersTabState extends State<ClubMembersTab> {
  final ClubService _clubService = ClubService();
  late Future<List<ClubMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    _membersFuture = _clubService.getMembersForClub(widget.clubId);
  }

  void _showMemberActions(BuildContext context, ClubMember member) {
    // No mostrar acciones para el propio usuario administrador
    if (member.id == 'user1') return; 

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.military_tech),
              title: const Text('Cambiar Rango'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showChangeRankDialog(context, member);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Expulsar del Club', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(ctx).pop();
                _showKickDialog(context, member);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangeRankDialog(BuildContext context, ClubMember member) async {
    final ranks = await _clubService.getRanksForClub(widget.clubId);
    final selectedRank = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar Rango de Miembro'),
          content: DropdownButton<String>(
            isExpanded: true,
            hint: const Text("Selecciona un rango"),
            value: member.rank,
            items: ranks.map((Rank rank) {
              return DropdownMenuItem<String>(
                value: rank.name,
                child: Text(rank.name),
              );
            }).toList(),
            onChanged: (String? newValue) {
               if (newValue != null) {
                Navigator.of(context).pop(newValue);
              }
            },
          ),
        );
      },
    );

    if (selectedRank != null) {
      await _clubService.updateMemberRank(widget.clubId, member.id, selectedRank);
      setState(() {
        _loadMembers(); // Recargar la lista
      });
    }
  }

  void _showKickDialog(BuildContext context, ClubMember member) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Expulsión'),
          content: Text('¿Estás seguro de que quieres expulsar a ${member.name} del club?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Expulsar', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _clubService.kickMember(widget.clubId, member.id);
                Navigator.of(context).pop();
                setState(() {
                  _loadMembers(); // Recargar la lista
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ClubMember>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
           return Center(child: Text("Error: ${snapshot.error.toString()}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Este club aún no tiene miembros."));
        }

        final members = snapshot.data!;
        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(member.avatarUrl.isNotEmpty ? member.avatarUrl : 'https://picsum.photos/200'),
              ),
              title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(member.rank),
              trailing: widget.isCurrentUserAdmin
                  ? IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showMemberActions(context, member),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
