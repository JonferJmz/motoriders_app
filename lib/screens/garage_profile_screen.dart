import 'package:flutter/material.dart';
import 'package:motoriders_app/models/user_model.dart';
import 'package:motoriders_app/models/motorcycle_model.dart';
import 'package:motoriders_app/services/auth_service.dart';
import 'package:motoriders_app/services/user_service.dart';
import 'package:motoriders_app/services/garage_service.dart'; // ✅ Import necesario
import 'package:motoriders_app/screens/add_motorcycle_screen.dart';
import 'package:motoriders_app/screens/edit_profile_screen.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class GarageProfileScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback logout;

  const GarageProfileScreen({Key? key, required this.toggleTheme, required this.logout}) : super(key: key);

  @override
  _GarageProfileScreenState createState() => _GarageProfileScreenState();
}

class _GarageProfileScreenState extends State<GarageProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _user;
  List<Motorcycle> _motorcycles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getUserProfile();
    if (user != null) {
      final motos = await _userService.getUserMotorcycles(user.id);
      if (mounted) {
        setState(() {
          _user = user;
          _motorcycles = motos;
          _isLoading = false;
        });
      }
    }
  }

  double get _totalGarageValue {
    if (_motorcycles.isEmpty) return 0.0;
    return _motorcycles.map((m) => m.totalInvested).reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teslaRed))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(isDark),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(isDark),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "MI GARAJE",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: isDark ? Colors.white : Colors.black87
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMotorcycleScreen()));
                                _loadData();
                              },
                              icon: const Icon(Icons.add_circle, color: AppColors.teslaRed, size: 28)
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                _buildMotorcyclesList(isDark),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [Colors.grey[900]!, Colors.black]
                      : [AppColors.teslaRed.withOpacity(0.8), Colors.white],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () async {
                    // ✅ CORRECCIÓN: Pasamos los parámetros requeridos
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          currentName: _user?.fullName ?? "",
                          currentBio: _user?.bio ?? "",
                          currentAvatarUrl: _user?.avatarUrl,
                        )
                      )
                    );
                    _loadData();
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: _user?.avatarUrl != null
                            ? NetworkImage(_user!.avatarUrl!)
                            : null,
                        backgroundColor: Colors.grey[800],
                        child: _user?.avatarUrl == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.teslaRed, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _user?.fullName ?? "Rider",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "@${_user?.username}",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
                ),
                if (_user?.bio != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: Text(
                      _user!.bio!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.brightness_6, color: isDark ? Colors.white : Colors.white),
          onPressed: widget.toggleTheme,
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: widget.logout,
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Motos", "${_motorcycles.length}", isDark),
          _buildVerticalDivider(isDark),
          _buildStatItem("Valor Total", "\$${_totalGarageValue.toStringAsFixed(0)}", isDark, isMoney: true),
          _buildVerticalDivider(isDark),
          _buildStatItem("Mods", "${_motorcycles.fold(0, (sum, m) => sum + m.modsCount)}", isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark, {bool isMoney = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isMoney ? Colors.green[400] : (isDark ? Colors.white : Colors.black87)
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(height: 30, width: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]);
  }

  Widget _buildMotorcyclesList(bool isDark) {
    if (_motorcycles.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Column(
              children: [
                Icon(Icons.two_wheeler, size: 60, color: Colors.grey[700]),
                const SizedBox(height: 10),
                const Text("Tu garaje está vacío.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final moto = _motorcycles[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
              image: moto.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage("${GarageService.baseUrl}/${moto.imageUrl!}"),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken)
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Próximamente: Detalle y Mods")));
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.teslaRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          moto.brand.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        moto.nickname.isNotEmpty ? moto.nickname : "${moto.brand} ${moto.model}",
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${moto.model} • ${moto.year}",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const Divider(color: Colors.white30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flash_on, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text("${moto.gasCount} Gas", style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.build, color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Text("${moto.modsCount} Mods", style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: _motorcycles.length,
      ),
    );
  }
}