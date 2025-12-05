
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
  final _textController = TextEditingController();
  final _feedService = FeedService();
  final _imagePicker = ImagePicker();
  
  List<XFile> _selectedImages = [];
  bool _isPosting = false;
  bool get _canPost => _textController.text.trim().isNotEmpty || _selectedImages.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) {
        setState(() {}); // Re-build to update the post button state
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _publishPost() async {
    if (!_canPost || _isPosting) return;

    setState(() {
      _isPosting = true;
    });

    // TODO: Update FeedService to handle images
    // For now, let's assume it takes the text and a list of file paths
    final imagePaths = _selectedImages.map((f) => f.path).toList();
    // await _feedService.addPost(_textController.text.trim(), images: imagePaths);
    await _feedService.addPost(_textController.text.trim());


    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Post'),
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: _isPosting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Publicar'),
              onPressed: _canPost ? _publishPost : null,
              backgroundColor: _canPost ? AppColors.teslaRed : Colors.grey[700],
              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=800&q=80'),
                      ),
                      SizedBox(width: 15),
                      Text('jonfer119', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _textController,
                    autofocus: true,
                    maxLines: null, 
                    minLines: 3,
                    decoration: const InputDecoration(
                      hintText: '¿Qué estás pensando, rider?',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedImages.isNotEmpty) _buildImagePreview(),
                ],
              ),
            ),
          ),
          _buildToolbar(isDark),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImages[index].path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.grey[100],
        border: Border(top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: AppColors.teslaRed),
            onPressed: _pickImages,
            tooltip: 'Añadir imágenes',
          ),
          IconButton(
            icon: Icon(Icons.location_on, color: Colors.grey[600]),
            onPressed: () { /* TODO: Implement location tagging */ },
            tooltip: 'Añadir ubicación',
          ),
        ],
      ),
    );
  }
}
