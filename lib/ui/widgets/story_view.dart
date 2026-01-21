import 'package:flutter/material.dart';
import 'dart:async';
import '../styles/app_theme.dart';

class StoryItem {
  final String title;
  final String content;
  final String? imageAsset;
  final Color backgroundColor;

  StoryItem({
    required this.title,
    required this.content,
    this.imageAsset,
    this.backgroundColor = AppTheme.primaryBrand,
  });
}

class StoryView extends StatefulWidget {
  final List<StoryItem> stories;
  final VoidCallback onComplete;

  const StoryView({
    super.key,
    required this.stories,
    required this.onComplete,
  });

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  int _currentIndex = 0;
  double _progress = 0.0;
  Timer? _timer;
  final int _storyDurationSeconds = 5;

  @override
  void initState() {
    super.initState();
    _startStory();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStory() {
    _progress = 0.0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.01 / (_storyDurationSeconds / 5); // Rough progress
        if (_progress >= 1.0) {
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _progress = 0.0;
      });
      _startStory();
    } else {
      _timer?.cancel();
      widget.onComplete();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _progress = 0.0;
      });
      _startStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content
          GestureDetector(
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 3) {
                _previousStory();
              } else {
                _nextStory();
              }
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    story.backgroundColor.withOpacity(0.8),
                    story.backgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      if (story.imageAsset != null) ...[
                        Center(
                          child: Image.asset(
                            story.imageAsset!,
                            height: 250,
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                      Text(
                        story.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        story.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.6,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Progress Bars
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: widget.stories.asMap().entries.map((entry) {
                  final idx = entry.key;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: idx == _currentIndex 
                            ? _progress.clamp(0.0, 1.0) 
                            : (idx < _currentIndex ? 1.0 : 0.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Close Button
          Positioned(
            top: 60,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              onPressed: widget.onComplete,
            ),
          ),
        ],
      ),
    );
  }
}
