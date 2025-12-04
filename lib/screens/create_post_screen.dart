
import 'package:flutter/material.dart';
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
  bool _canPost = false;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      if (mounted) {
        setState(() {
          _canPost = _textController.text.trim().isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _publishPost() async {
    if (!_canPost || _isPosting) return;

    setState(() {
      _isPosting = true;
    });

    await _feedService.addPost(_textController.text.trim());

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: _isPosting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Publicar'),
              onPressed: _canPost ? _publishPost : null,
              backgroundColor: _canPost ? AppColors.teslaRed : Colors.grey[700],
              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
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
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _textController,
                autofocus: true,
                maxLines: null, 
                decoration: const InputDecoration(
                  hintText: '¿Qué estás pensando, rider?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
