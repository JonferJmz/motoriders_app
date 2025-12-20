import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motoriders_app/services/garage_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class AddMotorcycleScreen extends StatefulWidget {
  const AddMotorcycleScreen({Key? key}) : super(key: key);

  @override
  _AddMotorcycleScreenState createState() => _AddMotorcycleScreenState();
}

class _AddMotorcycleScreenState extends State<AddMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final GarageService _garageService = GarageService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // 1. Crear moto
    final motoId = await _garageService.createMotorcycle(
      _nicknameController.text.trim(),
      _brandController.text.trim(),
      _modelController.text.trim(),
      int.tryParse(_yearController.text.trim()) ?? 2024,
      double.tryParse(_priceController.text.trim()) ?? 0.0,
    );

    if (motoId != null) {
      // 2. Subir foto si existe
      if (_image != null) {
        await _garageService.uploadMotorcycleImage(motoId, _image!.path);
      }
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al guardar moto"), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Moto"),
        backgroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    image: _image != null
                        ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                        : null,
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                            Text("Añadir Foto", style: TextStyle(color: Colors.grey))
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(controller: _nicknameController, decoration: InputDecoration(labelText: "Apodo (Opcional)", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.grey[100])),
              const SizedBox(height: 10),
              TextFormField(controller: _brandController, decoration: InputDecoration(labelText: "Marca", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.grey[100]), validator: (v) => v!.isEmpty ? "Requerido" : null),
              const SizedBox(height: 10),
              TextFormField(controller: _modelController, decoration: InputDecoration(labelText: "Modelo", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.grey[100]), validator: (v) => v!.isEmpty ? "Requerido" : null),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _yearController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Año", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.grey[100]))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFormField(controller: _priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Precio", filled: true, fillColor: isDark ? Colors.grey[900] : Colors.grey[100]))),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.teslaRed),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("GUARDAR MOTO", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}