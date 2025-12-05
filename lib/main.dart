
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:motoriders_app/screens/clubs_list_screen.dart';
import 'package:motoriders_app/screens/garage_profile_screen.dart';
import 'package:motoriders_app/screens/home_feed_screen.dart';
import 'package:motoriders_app/screens/login_screen.dart';
import 'package:motoriders_app/screens/radar_map_screen.dart';
import 'package:motoriders_app/screens/register_screen.dart';
import 'package:motoriders_app/utils/app_colors.dart';
import 'package:motoriders_app/widgets/add_action_sheet.dart';

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

  void _toggleTheme() => setState(() => _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  void _onLoginSuccess() => setState(() => _isLoggedIn = true);
  void _onLogout() => setState(() => _isLoggedIn = false);

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

   ThemeData _buildTheme(Brightness brightness) { final isDark = brightness == Brightness.dark; return ThemeData(brightness: brightness, scaffoldBackgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7), primaryColor: AppColors.teslaRed, fontFamily: 'Inter', inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: isDark ? AppColors.darkCard.withOpacity(0.8) : Colors.white, hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))); }
}

class AuthWrapper extends StatefulWidget { final VoidCallback loginSuccess; const AuthWrapper({super.key, required this.loginSuccess}); @override State<AuthWrapper> createState() => _AuthWrapperState(); }
class _AuthWrapperState extends State<AuthWrapper> { bool _showLogin = true; void toggleView() => setState(() => _showLogin = !_showLogin); @override Widget build(BuildContext context) { if (_showLogin) { return LoginScreen(toggleView: toggleView, loginSuccess: widget.loginSuccess); } else { return RegisterScreen(toggleView: toggleView); } } }

// --- MainScreen RECONSTRUIDA CON ANIMACIONES ---

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
      HomeFeedScreen(),
      const RadarMapScreen(),
      ClubsListScreen(),
      GarageProfileScreen(logout: widget.logout, toggleTheme: widget.toggleTheme),
    ];
  }

  void _onItemTapped(int index) => setState(() => _currentIndex = index);
  void _showAddActionSheet() => showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => const AddActionSheet());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // Usamos AnimatedSwitcher para una transición suave entre pestañas
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation), child: child),
          );
        },
        child: IndexedStack(
          // Se necesita un Key único para que el AnimatedSwitcher detecte el cambio
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
      floatingActionButton: _buildCentralButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar(bool isDark) { /* ... CÓDIGO IDÉNTICO AL ANTERIOR ... */ return BottomAppBar(shape: const CircularNotchedRectangle(), notchMargin: 8.0, color: isDark ? const Color(0xFF2C2C2E) : Colors.white, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[_buildNavItem(Icons.home_filled, "Home", 0), _buildNavItem(Icons.map_outlined, "Mapa", 1), const SizedBox(width: 48), _buildNavItem(Icons.groups_2_outlined, "Clubs", 2), _buildNavItem(Icons.garage_outlined, "Garaje", 3)])); }
  Widget _buildNavItem(IconData icon, String label, int index) { final isSelected = _currentIndex == index; return Expanded(child: InkWell(onTap: () => _onItemTapped(index), borderRadius: BorderRadius.circular(50), child: Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[Icon(icon, color: isSelected ? AppColors.teslaRed : Colors.grey), const SizedBox(height: 2), Text(label, style: TextStyle(color: isSelected ? AppColors.teslaRed : Colors.grey, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))])))); }
  Widget _buildCentralButton() { return FloatingActionButton(onPressed: _showAddActionSheet, backgroundColor: AppColors.teslaRed, child: const Icon(Icons.add, color: Colors.white, size: 30), elevation: 2.0); }
}
