
import 'package:flutter/material.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  final VoidCallback logout;

  const SettingsScreen({
    super.key,
    required this.toggleTheme,
    required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes"),
        backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F7),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader("Apariencia"),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: "Modo Oscuro",
            trailing: Switch(
              value: isDark,
              onChanged: (value) => toggleTheme(),
              activeColor: AppColors.teslaRed,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader("Cuenta"),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: "Cerrar Sesión",
            onTap: () {
              Navigator.of(context).pop();
              logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.white70 : Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
