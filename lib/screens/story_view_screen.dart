
import 'package:flutter/material.dart';
import 'package:motoriders_app/models/story_model.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Usaremos una librería de caché para un rendimiento óptimo

class StoryViewScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewScreen({super.key, required this.stories, this.initialIndex = 0});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(vsync: this);
    _playStory(widget.stories[_currentIndex]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _playStory(widget.stories[index]);
              },
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: widget.stories[index].contentUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white)),
                );
              },
            ),
            Positioned(
              top: 40.0,
              left: 10.0,
              right: 10.0,
              child: Column(
                children: [
                  Row(
                    children: widget.stories.asMap().entries.map((entry) {
                      return Expanded(child: StoryProgressBar(animationController: _animationController, position: entry.key, currentIndex: _currentIndex));
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  _buildUserInfo(widget.stories[_currentIndex])
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playStory(Story story) {
    _animationController.stop();
    _animationController.reset();
    _animationController.duration = const Duration(seconds: 5); // Cada historia dura 5 segundos
    _animationController.forward().whenComplete(_nextStory);
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;

    if (dx < screenWidth / 3) {
      _previousStory();
    } else if (dx > screenWidth * 2 / 3) {
      _nextStory();
    }
  }

  Widget _buildUserInfo(Story story) {
     return Row(
      children: [
        CircleAvatar(backgroundImage: CachedNetworkImageProvider(story.authorAvatarUrl), radius: 16),
        const SizedBox(width: 8),
        Text(story.authorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
        const Spacer(),
        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}

class StoryProgressBar extends StatelessWidget {
  final AnimationController animationController;
  final int position;
  final int currentIndex;

  const StoryProgressBar({super.key, required this.animationController, required this.position, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        height: 3.0,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: position < currentIndex
            ? const FractionallySizedBox(widthFactor: 1.0)
            : (position == currentIndex
                ? AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: animationController.value,
                        child: Container(color: Colors.white),
                      );
                    },
                  )
                : const SizedBox.shrink()),
      ),
    );
  }
}

