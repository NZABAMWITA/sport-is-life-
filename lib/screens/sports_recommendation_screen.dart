import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../services/recommendation_service.dart';
import '../models/exercise.dart';
import 'profile_setup_screen.dart';

class SportsRecommendationScreen extends StatefulWidget {
  const SportsRecommendationScreen({super.key});

  @override
  State<SportsRecommendationScreen> createState() =>
      _SportsRecommendationScreenState();
}

class _SportsRecommendationScreenState
    extends State<SportsRecommendationScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkProfileAndNavigate();
    });
  }

  Future<void> _checkProfileAndNavigate() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profile = userProvider.userProfile;

    if (profile == null || !profile.isComplete) {
      setState(() => _isLoading = true);

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
      );

      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userProfile;
    final recService = RecommendationService();

    if (user == null || !user.isComplete) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recommendations')),
        body: const Center(
          child: Text('Please complete your profile first.'),
        ),
      );
    }

    final allExercises = recService.getRecommendations(user);
    final quickWorkout = recService.getQuickWorkout(user);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Recommendations'),
        backgroundColor: Colors.green,
      ),
      body: allExercises.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No exercises match your current profile. Try adjusting your preferences.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (quickWorkout.isNotEmpty) ...[
                  const Text(
                    '⚡ Quick Workout',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...quickWorkout.map((ex) => ExerciseCard(exercise: ex)),
                  const SizedBox(height: 24),
                ],
                const Text(
                  '🏋️ All Suitable Exercises',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...allExercises.map((ex) => ExerciseCard(exercise: ex)),
              ],
            ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const ExerciseCard({super.key, required this.exercise});

  Future<void> _launchYouTube(BuildContext context) async {
    final Uri url = Uri.parse(exercise.videoUrl);
    if (!await canLaunchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch ${exercise.videoUrl}')),
      );
      return;
    }
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              exercise.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text('${exercise.duration} min')),
                const SizedBox(width: 8),
                Chip(label: Text(exercise.difficulty)),
                const SizedBox(width: 8),
                Chip(label: Text(exercise.category)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDetails(context, exercise),
                    child: const Text('Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _launchYouTube(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Watch Video'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markComplete(context, exercise),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Complete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Exercise exercise) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(exercise.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Duration: ${exercise.duration} minutes'),
              Text('Difficulty: ${exercise.difficulty}'),
              Text('Category: ${exercise.category}'),
              const SizedBox(height: 8),
              const Text('Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...exercise.instructions.map((step) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text('• $step'),
                  )),
              const SizedBox(height: 8),
              const Text('Benefits:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 4,
                children:
                    exercise.benefits.map((b) => Chip(label: Text(b))).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _markComplete(BuildContext context, Exercise exercise) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logWorkout(exercise.duration);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great job! You earned ${exercise.duration} minutes.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}