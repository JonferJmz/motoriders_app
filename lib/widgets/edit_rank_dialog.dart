
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/rank_model.dart';

class EditRankDialog extends StatefulWidget {
  final Rank? rank;

  const EditRankDialog({super.key, this.rank});

  @override
  State<EditRankDialog> createState() => _EditRankDialogState();
}

class _EditRankDialogState extends State<EditRankDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.rank?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rank == null ? 'Crear Rango' : 'Editar Rango'),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nombre del Rango'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Devolvemos el nuevo nombre al presionar Guardar
            if (_nameController.text.isNotEmpty) {
              Navigator.of(context).pop(_nameController.text);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
