
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:motoriders_app/screens/add_motorcycle_screen.dart';
import 'package:motoriders_app/screens/create_club_screen.dart';
import 'package:motoriders_app/screens/create_post_screen.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class AddActionSheet extends StatelessWidget {
  const AddActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Crear Nuevo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.post_add,
                    label: 'Post',
                    onTap: () {
                      Navigator.of(context).pop(); // Cierra el panel
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.motorcycle,
                    label: 'Moto',
                    onTap: () {
                      Navigator.of(context).pop(); // Cierra el panel
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMotorcycleScreen()));
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.group_add,
                    label: 'Club',
                    onTap: () {
                      Navigator.of(context).pop(); // Cierra el panel
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateClubScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teslaRed.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teslaRed.withOpacity(0.5),
                  blurRadius: 15,
                )
              ]
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
