
import 'package:flutter/material.dart';
import 'package:motoriders_app/services/club_service.dart';

class ClubMembersTab extends StatefulWidget {
  final String clubId;
  const ClubMembersTab({super.key, required this.clubId});

  @override
  State<ClubMembersTab> createState() => _ClubMembersTabState();
}

class _ClubMembersTabState extends State<ClubMembersTab> {
  final ClubService _clubService = ClubService();
  late Future<List<ClubMember>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _clubService.getMembersForClub(widget.clubId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ClubMember>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay miembros en este club."));
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
              title: Text(member.name),
              subtitle: Text(member.rank),
            );
          },
        );
      },
    );
  }
}
