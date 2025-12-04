
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/club_model.dart';
import 'package:motoriders_app/screens/manage_club_screen.dart';
import 'package:motoriders_app/utils/app_colors.dart';
import 'package:motoriders_app/widgets/club_chat_tab.dart';
import 'package:motoriders_app/widgets/club_members_tab.dart';
import 'package:motoriders_app/widgets/club_wall_tab.dart';


class ClubDetailsScreen extends StatelessWidget {
  final Club club;
  final bool _isCurrentUserAdmin = true; // Simulación

  const ClubDetailsScreen({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: _isCurrentUserAdmin ? FloatingActionButton.extended(
          onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => ManageClubScreen(club: club)));
          },
          label: const Text('Gestionar'),
          icon: const Icon(Icons.settings),
          backgroundColor: AppColors.teslaRed,
        ) : null,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(club.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        )),
                    background: Image.network(
                      club.logoUrl,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.5),
                      colorBlendMode: BlendMode.darken,
                    )),
                bottom: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.dynamic_feed), text: "Muro"),
                    Tab(icon: Icon(Icons.chat_bubble), text: "Chat"),
                    Tab(icon: Icon(Icons.groups), text: "Miembros"),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              ClubWallTab(clubId: club.id),
              ClubChatTab(clubId: club.id),
              ClubMembersTab(clubId: club.id),
            ],
          ),
        ),
      ),
    );
  }
}
