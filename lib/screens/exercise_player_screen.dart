import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/user_provider.dart';
import 'dart:async';

class ExercisePlayerScreen extends StatefulWidget {
  final Exercise exercise;
  const ExercisePlayerScreen({super.key, required this.exercise});

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  late VideoPlayerController _controller;
  late Timer _timer;
  bool _isPlaying = false;
  bool _isCompleted = false;
  bool _isLoading = true;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();

    // Initialize video player with the online URL from the exercise
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.exercise.videoUrl),
    )..initialize().then((_) {
        setState(() {
          _isLoading = false;
          // Loop the video so it repeats
          _controller.setLooping(true);
        });
      }).catchError((error) {
        print('Error loading video: $error');
        setState(() {
          _isLoading = false;
        });
        // Show error dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showErrorDialog(context);
        });
      });

    // Set timer to exercise duration (minutes to seconds)
    _secondsRemaining = widget.exercise.duration * 60;

    // Start countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        // Optionally auto-complete or just stop timer
        timer.cancel();
      }
    });
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Video Error'),
        content: const Text(
            'Could not load the exercise video. You can still follow the instructions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _completeWorkout() {
    if (_isCompleted) return;
    setState(() {
      _isCompleted = true;
    });
    // Log the workout
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logWorkout(widget.exercise.duration);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Great job! You earned ${widget.exercise.duration} minutes.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.title),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Video player
          if (_isLoading)
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_controller.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          else
            Container(
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Text('Video not available'),
              ),
            ),

          // Play/pause button (only if video loaded)
          if (!_isLoading && _controller.value.isInitialized)
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 48),
              onPressed: _togglePlay,
            ),

          const SizedBox(height: 20),

          // Instructions (scrollable)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: widget.exercise.instructions
                          .map(
                            (step) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• '),
                                  Expanded(child: Text(step)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timer and complete button
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Time remaining: ${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isCompleted ? null : _completeWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Mark Complete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
