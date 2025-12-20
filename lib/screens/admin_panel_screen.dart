
import 'package:flutter/material.dart';
import 'package:motoriders_app/screens/manage_users_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administrador"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people_alt_outlined),
            title: const Text("Gestionar Usuarios"),
            subtitle: const Text("Ver, banear o eliminar usuarios."),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: const Text("Contenido Reportado"),
            subtitle: const Text("Revisar publicaciones o comentarios reportados."),
            onTap: () { /* TODO */ },
          ),
        ],
      ),
    );
  }
}

