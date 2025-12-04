
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:motoriders_app/screens/clubs_list_screen.dart';
import 'package:motoriders_app/screens/garage_profile_screen.dart';
import 'package:motoriders_app/screens/home_feed_screen.dart';
import 'package:motoriders_app/screens/login_screen.dart';
import 'package:motoriders_app/screens/radar_map_screen.dart';
import 'package:motoriders_app/screens/register_screen.dart';
import 'package:motoriders_app/services/auth_service.dart';
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
  bool _isLoggedIn = false;
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  void _onLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoRiders App',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
      home: _isLoggedIn 
          ? MainScreen(toggleTheme: _toggleTheme, logout: _onLogout) 
          : AuthWrapper(loginSuccess: _onLoginSuccess),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
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

  void toggleView() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

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

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return const HomeFeedScreen();
      case 1:
        return const RadarMapScreen();
      case 3:
        return const ClubsListScreen();
      case 4:
        return GarageProfileScreen(logout: widget.logout, toggleTheme: widget.toggleTheme);
      default:
        return const HomeFeedScreen();
    }
  }

  void _showAddActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      body: _buildScreen(_currentIndex),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_filled, 0, isDark),
                _buildNavItem(Icons.map_outlined, 1, isDark),
                _buildCentralButton(),
                _buildNavItem(Icons.groups_2_outlined, 3, isDark),
                _buildNavItem(Icons.garage_outlined, 4, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, bool isDark) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teslaRed.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? AppColors.teslaRed : (isDark ? Colors.white70 : Colors.black54),
        ),
      ),
    );
  }

  Widget _buildCentralButton() {
    return GestureDetector(
      onTap: _showAddActionSheet,
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.teslaRed, Color(0xFFFF4B1F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.teslaRed.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
