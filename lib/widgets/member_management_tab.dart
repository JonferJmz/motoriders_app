
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/services/club_service.dart';

class MemberManagementTab extends StatefulWidget {
  final Club club;
  const MemberManagementTab({super.key, required this.club});

  @override
  State<MemberManagementTab> createState() => _MemberManagementTabState();
}

class _MemberManagementTabState extends State<MemberManagementTab> {
  final ClubService _clubService = ClubService();
  late Future<List<ClubMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _clubService.getMembersForClub(widget.club.id);
  }

  void _showMemberActions(ClubMember member) {
    // TODO: Implementar un diálogo con opciones para cambiar rango, expulsar, etc.
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ClubMember>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                backgroundImage: NetworkImage(member.avatarUrl),
              ),
              title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(member.rank),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMemberActions(member),
              ),
            );
          },
        );
      },
    );
  }
}
