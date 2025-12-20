
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motoriders_app/models/post_model.dart';

class ShareSheet extends StatelessWidget {
  final Post post;
  const ShareSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Compartir", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text("Copiar Enlace"),
            onTap: () {
              final postUrl = "https://motoriders.app/post/${post.id}"; // URL simulada
              Clipboard.setData(ClipboardData(text: postUrl));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("¡Enlace copiado al portapapeles!")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Compartir en un Club"),
            onTap: () {
              // TODO: Implementar lógica para compartir en un club
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
