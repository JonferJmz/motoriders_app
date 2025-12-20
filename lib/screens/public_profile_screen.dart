import 'package:flutter/material.dart';
import 'package:motoriders_app/models/user_model.dart';
import 'package:motoriders_app/models/motorcycle_model.dart';
import 'package:motoriders_app/services/user_service.dart';

class PublicProfileScreen extends StatefulWidget {
  final int userId;
  final String username; // Para mostrar algo mientras carga

  const PublicProfileScreen({Key? key, required this.userId, required this.username}) : super(key: key);

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final UserService _userService = UserService();
  User? _user;
  List<Motorcycle> _motorcycles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await _userService.getUserProfile(widget.userId);
    final motos = await _userService.getUserMotorcycles(widget.userId);

    if (mounted) {
      setState(() {
        _user = user;
        _motorcycles = motos;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text(_isLoading ? "@${widget.username}" : _user?.username ?? "Perfil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // AVATAR
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _user?.avatarUrl != null
                        ? NetworkImage(_user!.avatarUrl!)
                        : null,
                    backgroundColor: Colors.grey[800],
                    child: _user?.avatarUrl == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 15),

                  // NOMBRE Y BIO
                  Text(
                    _user?.fullName ?? "Usuario",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                  ),
                  Text(
                    "@${_user?.username}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  if (_user?.bio != null) ...[
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        _user!.bio!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  const Divider(),

                  // SECCIÓN GARAJE
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "GARAJE (${_motorcycles.length})",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey)
                      ),
                    ),
                  ),

                  // LISTA DE MOTOS
                  if (_motorcycles.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Este usuario no tiene motos registradas aún.", style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _motorcycles.length,
                      itemBuilder: (context, index) {
                        final moto = _motorcycles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          child: ListTile(
                            leading: const Icon(Icons.motorcycle, color: Colors.red, size: 30),
                            title: Text(moto.nickname.isNotEmpty ? moto.nickname : "${moto.brand} ${moto.model}", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                            subtitle: Text("${moto.brand} ${moto.model} • ${moto.year}", style: TextStyle(color: Colors.grey[600])),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }
}