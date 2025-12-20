import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Librería externa
import 'package:motoriders_app/models/post_model.dart';
import 'package:motoriders_app/services/chat_service.dart';

class SharePostSheet extends StatefulWidget {
  final Post post;

  const SharePostSheet({Key? key, required this.post}) : super(key: key);

  @override
  State<SharePostSheet> createState() => _SharePostSheetState();
}

class _SharePostSheetState extends State<SharePostSheet> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _clubs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    // Cargamos los clubes donde podemos compartir
    final clubs = await _chatService.getMyClubsForShare();
    if (mounted) {
      setState(() {
        _clubs = clubs;
        _isLoading = false;
      });
    }
  }

  // Lógica para compartir externamente (WhatsApp, etc)
  void _shareExternally() {
    // Cerramos el sheet primero
    Navigator.pop(context);

    // Texto a compartir
    final String content = "Mira este post en MotoRiders: \n\n"
        "${widget.post.text}\n"
        "Autor: @${widget.post.author.username}";

    Share.share(content);
  }

  // Lógica para compartir internamente
  void _shareInternally(String clubId, String clubName) async {
    Navigator.pop(context); // Cerramos primero

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Enviando a $clubName..."), duration: const Duration(seconds: 1)),
    );

    final success = await _chatService.sharePostToClub(clubId, widget.post.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Compartido exitosamente"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al compartir"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y pequeña barra de arrastre
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Compartir en...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 20),

          // LISTA HORIZONTAL DE CLUBES / GRUPOS (Interno)
          SizedBox(
            height: 100,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _clubs.length + 1, // +1 para el botón "Más"
                    separatorBuilder: (_, __) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      // EL ÚLTIMO ITEM ES EL BOTÓN DE "+" (EXTERNO)
                      if (index == _clubs.length) {
                        return _buildOption(
                          icon: Icons.add,
                          color: Colors.grey[800]!,
                          label: "Más",
                          isExternal: true,
                          onTap: _shareExternally,
                        );
                      }

                      final club = _clubs[index];
                      return _buildOption(
                        imageUrl: club['image'],
                        label: club['name'],
                        isExternal: false,
                        onTap: () => _shareInternally(club['id'], club['name']),
                      );
                    },
                  ),
          ),

          const Divider(height: 30),

          // Opciones extra de lista vertical (Copiar enlace, Reportar, etc)
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text("Copiar enlace"),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enlace copiado al portapapeles")));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    String? imageUrl,
    IconData? icon,
    Color? color,
    required String label,
    required bool isExternal,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isExternal ? Colors.grey[200] : Colors.transparent,
              border: isExternal ? null : Border.all(color: Colors.amber, width: 2), // Borde ámbar para interno
              image: imageUrl != null
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: imageUrl == null
                ? Icon(icon, size: 30, color: Colors.black) // Icono "+"
                : null,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 60,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}