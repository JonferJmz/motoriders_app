
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/motorcycle_model.dart';
import 'package:motoriders_app/services/profile_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class AddMotorcycleScreen extends StatefulWidget {
  const AddMotorcycleScreen({super.key});

  @override
  State<AddMotorcycleScreen> createState() => _AddMotorcycleScreenState();
}

class _AddMotorcycleScreenState extends State<AddMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();

  final ProfileService _profileService = ProfileService();
  bool _isSaving = false;

  Future<void> _saveMotorcycle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final newMotorcycle = Motorcycle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nickname: _nicknameController.text,
        brand: _brandController.text,
        model: _modelController.text,
        year: int.tryParse(_yearController.text) ?? DateTime.now().year,
        modifications: [], // Se podrán añadir más adelante
      );

      await _profileService.addMotorcycle(newMotorcycle);

      if (mounted) {
        Navigator.of(context).pop();
        // Opcional: mostrar un SnackBar de éxito.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Añadir Nueva Moto"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Guardar'),
              onPressed: _saveMotorcycle,
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
          children: <Widget>[
            _buildTextFormField(controller: _nicknameController, label: 'Apodo de la Moto', icon: Icons.label_important_outline),
            const SizedBox(height: 20),
            _buildTextFormField(controller: _brandController, label: 'Marca', icon: Icons.branding_watermark),
            const SizedBox(height: 20),
            _buildTextFormField(controller: _modelController, label: 'Modelo', icon: Icons.motorcycle),
            const SizedBox(height: 20),
            _buildTextFormField(controller: _yearController, label: 'Año', icon: Icons.calendar_today, keyboardType: TextInputType.number),
            // TODO: Añadir campos para kilometraje, foto, etc.
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }
}
