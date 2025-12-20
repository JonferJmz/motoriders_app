
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/user_model.dart';
import 'package:motoriders_app/services/user_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final UserService _userService = UserService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _userService.getAllUsers();
  }

  void _showUserActions(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_search_outlined),
                title: const Text('Ver Perfil'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Implementar navegación al perfil del usuario
                },
              ),
              ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: const Text('Cambiar Rango'),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Implementar lógica para cambiar rango
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Banear Usuario', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: Implementar lógica de baneo
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar Usuarios"),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("No se pudieron cargar los usuarios."));
          }

          final users = snapshot.data!;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onLongPress: () => _showUserActions(context, user),
                  onTap: () => _showUserActions(context, user), // También con toque simple
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(user.avatarUrl),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(user.id, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_vert, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
