import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motoriders_app/services/auth_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentBio;
  final String? currentAvatarUrl;
  final String? currentCoverUrl; // ✅ Campo Portada

  const EditProfileScreen({
    Key? key,
    required this.currentName,
    required this.currentBio,
    this.currentAvatarUrl,
    this.currentCoverUrl,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _bioController;

  File? _avatarImage;
  File? _coverImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _bioController = TextEditingController(text: widget.currentBio);
  }

  Future<void> _pickImage(bool isCover) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isCover) _coverImage = File(image.path);
        else _avatarImage = File(image.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    String? newAvatarUrl;
    String? newCoverUrl;

    // Subir Avatar si cambió
    if (_avatarImage != null) {
      newAvatarUrl = await _authService.uploadImage(_avatarImage!);
    }
    // Subir Portada si cambió
    if (_coverImage != null) {
      newCoverUrl = await _authService.uploadImage(_coverImage!);
    }

    final success = await _authService.updateProfile(
      fullName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      avatarUrl: newAvatarUrl,
      coverUrl: newCoverUrl,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al actualizar perfil"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ÁREA DE FOTOS
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // PORTADA
                    GestureDetector(
                      onTap: () => _pickImage(true), // true = portada
                      child: Container(
                        height: 160, width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 50),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(15),
                          image: _coverImage != null
                              ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover)
                              : (widget.currentCoverUrl != null
                                  ? DecorationImage(image: NetworkImage(widget.currentCoverUrl!), fit: BoxFit.cover)
                                  : null),
                        ),
                        child: _coverImage == null && widget.currentCoverUrl == null
                            ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: Colors.white54), Text("Portada", style: TextStyle(color: Colors.white54))]))
                            : null,
                      ),
                    ),
                    // AVATAR
                    GestureDetector(
                      onTap: () => _pickImage(false), // false = avatar
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4)
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _avatarImage != null
                              ? FileImage(_avatarImage!) as ImageProvider
                              : (widget.currentAvatarUrl != null ? NetworkImage(widget.currentAvatarUrl!) : null),
                          backgroundColor: Colors.grey[400],
                          child: _avatarImage == null && widget.currentAvatarUrl == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nombre Completo",
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                ),
                validator: (v) => v!.isEmpty ? "Ingresa un nombre" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Biografía (Bio)",
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.teslaRed),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("GUARDAR CAMBIOS", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}