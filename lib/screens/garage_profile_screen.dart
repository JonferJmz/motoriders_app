
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/motorcycle_model.dart';
import 'package:motoriders_app/screens/settings_screen.dart';
import 'package:motoriders_app/services/profile_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class GarageProfileScreen extends StatefulWidget {
  final VoidCallback logout;
  final VoidCallback toggleTheme;

  const GarageProfileScreen(
      {super.key, required this.logout, required this.toggleTheme});

  @override
  State<GarageProfileScreen> createState() => _GarageProfileScreenState();
}

class _GarageProfileScreenState extends State<GarageProfileScreen> {
  final ProfileService _profileService = ProfileService();
  Future<UserProfile>? _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _profileService.getUserProfile();
  }

  void _navigateToSettings(BuildContext context, UserProfile userProfile) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingsScreen(logout: widget.logout, toggleTheme: widget.toggleTheme);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFF5F5F7),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.teslaRed));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error al cargar el perfil.'));
          }

          final userProfile = snapshot.data!;
          return _buildProfileView(context, userProfile);
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, UserProfile userProfile) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CARRUSEL DE MOTOS ---
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: PageView.builder(
              itemCount: userProfile.motorcycles.length,
              itemBuilder: (context, index) {
                final motorcycle = userProfile.motorcycles[index];
                return _buildMotorcycleHeader(context, userProfile, motorcycle);
              },
            ),
          ),

          // --- SECCIÓN DE ESTADÍSTICAS SOCIALES ---
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatColumn("34", "Clubes"),
                  _buildStatColumn("1.2K", "Seguidores"),
                  _buildStatColumn("89", "Seguidos"),
                  GestureDetector(
                    onTap: () => _navigateToSettings(context, userProfile),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 5),
                          Text("Editar Perfil",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                ],
              )),

          const SizedBox(height: 100), // Espacio para scroll
        ],
      ),
    );
  }

  Widget _buildMotorcycleHeader(
      BuildContext context, UserProfile user, Motorcycle moto) {
    return Stack(
      children: [
        // FOTO DE LA MOTO (HEADER)
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(moto.imageUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        // DEGRADADO OSCURO
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 1.0],
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
              ),
            ),
          ),
        ),
        // DATOS DEL USUARIO Y MOTO
        Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(user.avatarUrl),
                    ),
                    const SizedBox(width: 10),
                    Text(user.username,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    _buildGlassTag(Icons.qr_code_scanner, "QR"),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  moto.nickname,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120, // Altura fija para la lista de mods
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: moto.modifications.length,
                    itemBuilder: (context, index) {
                      final mod = moto.modifications[index];
                      return Text('  • ${mod.title} (${mod.description})',
                          style: const TextStyle(
                              color: Colors.white70, height: 1.5));
                    },
                  ),
                )
              ],
            )),
        // Ojo: El botón de logout ya no está aquí
      ],
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildGlassTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.teslaRed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.teslaRed.withOpacity(0.4), blurRadius: 10)
        ],
      ),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
      ]),
    );
  }
}
