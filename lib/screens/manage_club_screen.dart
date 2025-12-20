
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/widgets/member_management_tab.dart';
import 'package:motoriders_app/widgets/permission_management_tab.dart';
import 'package:motoriders_app/widgets/rank_management_tab.dart';

class ManageClubScreen extends StatefulWidget {
  final Club club;

  const ManageClubScreen({super.key, required this.club});

  @override
  State<ManageClubScreen> createState() => _ManageClubScreenState();
}

class _ManageClubScreenState extends State<ManageClubScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Miembros, Rangos, Permisos
      child: Scaffold(
        appBar: AppBar(
          title: Text("Gestionar: ${widget.club.name}"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.groups), text: "Miembros"),
              Tab(icon: Icon(Icons.military_tech), text: "Rangos"),
              Tab(icon: Icon(Icons.rule), text: "Permisos"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MemberManagementTab(club: widget.club),
            RankManagementTab(club: widget.club),
            PermissionManagementTab(club: widget.club),
          ],
        ),
      ),
    );
  }
}
