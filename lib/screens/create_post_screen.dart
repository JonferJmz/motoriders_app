import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motoriders_app/services/feed_service.dart';
import 'package:motoriders_app/utils/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final FeedService _feedService = FeedService();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe algo o sube una foto')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? uploadedImageUrl;
    if (_selectedImage != null) {
      uploadedImageUrl = await _feedService.uploadImage(_selectedImage!.path);
      if (uploadedImageUrl == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error subiendo imagen')),
        );
        return;
      }
    }

    final success = await _feedService.createPost(text, uploadedImageUrl);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicado con éxito')),
        );
        // ⚠️ CLAVE: Devolvemos 'true' para avisar al Feed que recargue
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al publicar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Publicación"),
        backgroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: const Text("PUBLICAR", style: TextStyle(color: AppColors.teslaRed, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(color: AppColors.teslaRed),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "¿Qué estás pensando, Rider?",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: const CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            const Spacer(),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: AppColors.teslaRed, size: 30),
                  onPressed: _pickImage,
                ),
                const Text("Agregar foto", style: TextStyle(color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}