
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/post_model.dart';

class PostOptionsSheet extends StatelessWidget {
  final Post post;
  const PostOptionsSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // TODO: Determinar si el post es del usuario actual
    const bool isMyPost = true; 

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMyPost)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Eliminar Publicación', style: TextStyle(color: Colors.red)),
              onTap: () {
                // TODO: Lógica para eliminar post
                Navigator.of(context).pop();
              },
            ),
          if (!isMyPost)
            ListTile(
              leading: const Icon(Icons.person_remove_outlined),
              title: const Text('Dejar de seguir a este usuario'),
              onTap: () {
                // TODO: Lógica para dejar de seguir
                Navigator.of(context).pop();
              },
            ),
          if (!isMyPost)
             ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.orange),
              title: const Text('Reportar Publicación', style: TextStyle(color: Colors.orange)),
              onTap: () {
                // TODO: Lógica para reportar
                Navigator.of(context).pop();
              },
            ),
          const Divider(),
          ListTile(
            title: const Center(child: Text('Cancelar')),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
