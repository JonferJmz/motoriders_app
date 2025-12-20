
import 'package:flutter/material.dart';
import 'package:motoriders_app/services/club_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class CreateClubScreen extends StatefulWidget {
  const CreateClubScreen({super.key});

  @override
  State<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ClubService _clubService = ClubService();
  bool _isPublic = true;
  bool _isSaving = false;

  Future<void> _saveClub() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      await _clubService.createClub(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
        _isPublic,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Nuevo Club"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Crear'),
              onPressed: _saveClub,
              backgroundColor: AppColors.teslaRed,
              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Club',
                prefixIcon: Icon(Icons.group_work),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción Corta',
                prefixIcon: Icon(Icons.info_outline),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La descripción es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Club Público'),
              subtitle: const Text('Cualquiera puede encontrarlo y unirse.'),
              value: _isPublic,
              onChanged: (bool value) {
                setState(() {
                  _isPublic = value;
                });
              },
              secondary: Icon(_isPublic ? Icons.lock_open : Icons.lock),
            ),
            // TODO: Añadir selector de logo, reglas, etc.
          ],
        ),
      ),
    );
  }
}
