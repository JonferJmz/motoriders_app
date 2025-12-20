import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:motoriders_app/screens/clubs_list_screen.dart';
import 'package:motoriders_app/screens/garage_profile_screen.dart';
import 'package:motoriders_app/screens/home_feed_screen.dart';
import 'package:motoriders_app/screens/login_screen.dart';
import 'package:motoriders_app/screens/radar_map_screen.dart';
import 'package:motoriders_app/screens/register_screen.dart';
import 'package:motoriders_app/services/auth_service.dart'; // ✅ Importante
import 'package:motoriders_app/utils/app_colors.dart';
import 'package:motoriders_app/widgets/add_action_sheet.dart';

class CustomFabLocation extends FloatingActionButtonLocation {
  final FloatingActionButtonLocation location;
  final double offsetX;
  final double offsetY;

  CustomFabLocation(this.location, this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset originalOffset = location.getOffset(scaffoldGeometry);
    return Offset(originalOffset.dx + offsetX, originalOffset.dy + offsetY);
  }
}

void main() {
  runApp(const MotoApp());
}

class MotoApp extends StatefulWidget {
  const MotoApp({super.key});

  @override
  State<MotoApp> createState() => _MotoAppState();
}

class _MotoAppState extends State<MotoApp> {
  bool _isLoggedIn = true;
  ThemeMode _themeMode = ThemeMode.dark;
  final AuthService _authService = AuthService(); // Instancia para logout limpio

  @override
  void initState() {
    super.initState();
    // ✅ ESCUCHA ACTIVA: Si el token caduca en cualquier lugar, esto se dispara
    AuthService.sessionExpired.addListener(_onSessionExpired);
  }

  @override
  void dispose() {
    AuthService.sessionExpired.removeListener(_onSessionExpired);
    super.dispose();
  }

  void _onSessionExpired() {
    if (AuthService.sessionExpired.value) {
      // Si la alarma suena, forzamos logout
      _onLogout();
      // Reset del valor para evitar bucles
      AuthService.sessionExpired.value = false;
    }
  }

  void _toggleTheme() => setState(() => _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  void _onLoginSuccess() => setState(() => _isLoggedIn = true);

  void _onLogout() async {
    await _authService.logout(); // Limpia el token del celular
    setState(() => _isLoggedIn = false); // Cambia la pantalla a Login
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoRiders App',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
      home: _isLoggedIn ? MainScreen(toggleTheme: _toggleTheme, logout: _onLogout) : AuthWrapper(loginSuccess: _onLoginSuccess),
      debugShowCheckedModeBanner: false,
    );
  }

   ThemeData _buildTheme(Brightness brightness) {
     final isDark = brightness == Brightness.dark;
     return ThemeData(
       brightness: brightness,
       scaffoldBackgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
       primaryColor: AppColors.teslaRed,
       fontFamily: 'Inter',
       inputDecorationTheme: InputDecorationTheme(
         filled: true,
         fillColor: isDark ? AppColors.darkCard.withOpacity(0.8) : Colors.white,
         hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
       )
     );
   }
}

class AuthWrapper extends StatefulWidget {
  final VoidCallback loginSuccess;
  const AuthWrapper({super.key, required this.loginSuccess});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true;
  void toggleView() => setState(() => _showLogin = !_showLogin);
  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginScreen(toggleView: toggleView, loginSuccess: widget.loginSuccess);
    } else {
      return RegisterScreen(toggleView: toggleView);
    }
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback logout;
  const MainScreen({super.key, required this.toggleTheme, required this.logout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeFeedScreen(),
      const RadarMapScreen(),
      ClubsListScreen(),
      GarageProfileScreen(logout: widget.logout, toggleTheme: widget.toggleTheme),
    ];
  }

  void _onItemTapped(int index) => setState(() => _currentIndex = index);
  void _showAddActionSheet() => showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => const AddActionSheet());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildFloatingBottomNavBar(context),
      floatingActionButton: Transform.translate(
        offset: const Offset(20.0, 0.0),
        child: _buildCentralButton(),
      ),
      floatingActionButtonLocation: CustomFabLocation(FloatingActionButtonLocation.centerDocked, -25.0, 8.0),
    );
  }

  Widget _buildFloatingBottomNavBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10.0,
            color: isDark ? const Color(0xFF2C2C2E).withOpacity(0.85) : Colors.white.withOpacity(0.9),
            elevation: 0,
            child: SizedBox(
              height: 48.0,
              child: Row(
                children: <Widget>[
                  Expanded(child: _buildNavItem(Icons.home_filled, 0)),
                  Expanded(child: _buildNavItem(Icons.map_outlined, 1)),
                  const Expanded(child: SizedBox()),
                  Expanded(child: _buildNavItem(Icons.groups_2_outlined, 2)),
                  Expanded(child: _buildNavItem(Icons.garage_outlined, 3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(50),
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Icon(icon, color: isSelected ? AppColors.teslaRed : Colors.grey, size: 28),
        ),
      ),
    );
  }

  Widget _buildCentralButton() {
    return SizedBox(
      width: 56, height: 56,
      child: FloatingActionButton(
        heroTag: 'add_post_button',
        onPressed: _showAddActionSheet,
        backgroundColor: AppColors.teslaRed,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}