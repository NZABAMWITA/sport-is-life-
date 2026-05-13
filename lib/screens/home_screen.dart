import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';
import 'sports_recommendation_screen.dart';
import 'progress_screen.dart';
import 'daily_activity_screen.dart';
import 'nutrition_screen.dart';
import 'goals_screen.dart';
import 'reminders_screen.dart';
import 'feedback_screen.dart';
import 'about_screen.dart';
import 'dart:math';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentTipIndex = 0;
  Timer? _tipTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _motivationalTips = [
    {
      'title': '💪 Stay Consistent',
      'message': 'Even 10 minutes of exercise daily can transform your health!',
    },
    {
      'title': '🌟 Small Steps',
      'message': 'Progress, not perfection. Every workout counts!',
    },
    {
      'title': '💧 Hydrate',
      'message': 'Drink water before, during, and after your workout.',
    },
    {
      'title': '😴 Rest Day',
      'message': 'Recovery is just as important as the workout itself.',
    },
    {
      'title': '🎯 Set Goals',
      'message': 'Challenge yourself a little more each week.',
    },
  ];

  final List<Map<String, dynamic>> _allMenuItems = [
    {
      'title': 'Sports Recommendations',
      'icon': Icons.sports,
      'color': Colors.green,
      'screen': const SportsRecommendationScreen(),
      'description': 'Personalized exercises just for you',
    },
    {
      'title': 'Daily Activity',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'screen': const DailyActivityScreen(),
      'description': 'Track your daily workouts',
    },
    {
      'title': 'Progress Tracking',
      'icon': Icons.trending_up,
      'color': Colors.blue,
      'screen': const ProgressScreen(),
      'description': 'View your achievements',
    },
    {
      'title': 'Nutrition Tips',
      'icon': Icons.restaurant,
      'color': Colors.red,
      'screen': const NutritionScreen(),
      'description': 'Healthy eating guides',
    },
    {
      'title': 'Set Goals',
      'icon': Icons.flag,
      'color': Colors.teal,
      'screen': const GoalsScreen(),
      'description': 'Set and track fitness goals',
    },
    {
      'title': 'Reminders',
      'icon': Icons.alarm,
      'color': Colors.purple,
      'screen': const RemindersScreen(),
      'description': 'Never miss a workout',
    },
    {
      'title': 'Feedback',
      'icon': Icons.feedback,
      'color': Colors.brown,
      'screen': const FeedbackScreen(),
      'description': 'Help us improve',
    },
    {
      'title': 'About',
      'icon': Icons.info,
      'color': Colors.indigo,
      'screen': const AboutScreen(),
      'description': 'Learn more about the app',
    },
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _startTipRotation();
  }

  void _startTipRotation() {
    _tipTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _fadeController.forward().then((_) {
          setState(() {
            _currentTipIndex =
                (_currentTipIndex + 1) % _motivationalTips.length;
          });
          _fadeController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getRandomQuote() {
    final quotes = [
      "The only bad workout is the one that didn't happen.",
      "Your body can stand almost anything. It's your mind you have to convince.",
      "Don't wait for the perfect moment. Take the moment and make it perfect.",
      "Small daily improvements are the key to staggering long-term results.",
      "Movement is medicine for the body and mind.",
      "The pain you feel today will be the strength you feel tomorrow.",
    ];
    return quotes[Random().nextInt(quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final profile = userProvider.userProfile;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // ✅ FIXED: App Bar with proper sizing
            SliverAppBar(
              expandedHeight: 280, // ✅ Increased from 260 to 280
              floating: false,
              pinned: true,
              backgroundColor: Colors.blue,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                    left: 20, bottom: 20), // ✅ Reduced from 30 to 20
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // ✅ ADDED - Critical fix!
                  mainAxisAlignment: MainAxisAlignment.center, // ✅ CHANGED
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 14, // ✅ Reduced from 16 to 14
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4), // ✅ Reduced from 8 to 4
                    Text(
                      firebaseUser?.displayName?.split(' ')[0] ?? 'Athlete',
                      style: const TextStyle(
                        fontSize: 24, // ✅ Reduced from 32 to 24
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        right: -30,
                        top: -30,
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            Icons.sports_soccer,
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 30, // ✅ Adjusted from 40 to 30
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24, // ✅ Reduced from 28 to 24
                              backgroundImage: firebaseUser?.photoURL != null
                                  ? NetworkImage(firebaseUser!.photoURL!)
                                  : null,
                              child: firebaseUser?.photoURL == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white, size: 24)
                                  : null,
                            ),
                            const SizedBox(
                                width: 12), // ✅ Reduced from 15 to 12
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  firebaseUser?.displayName ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16, // ✅ Reduced from 18 to 16
                                  ),
                                ),
                                const SizedBox(
                                    height: 2), // ✅ Reduced from 4 to 2
                                Text(
                                  profile != null
                                      ? 'Level ${profile.level}'
                                      : 'Complete your profile',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12, // ✅ Reduced from 14 to 12
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon:
                      const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {
                    // Navigate to notifications screen
                  },
                ),
              ],
            ),

            // Main content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Motivational Quote Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.format_quote,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quote of the Day',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getRandomQuote(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Today's Summary Card (only if profile exists)
                  if (profile != null) ...[
                    _buildTodaySummary(profile),
                    const SizedBox(height: 20),
                  ],

                  // Featured Section Title
                  const Text(
                    'Explore Features',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid of menu items
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: _allMenuItems.length,
                    itemBuilder: (context, index) {
                      final item = _allMenuItems[index];
                      return _buildMenuItem(item);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Rotating Tips
                  _buildRotatingTips(),

                  const SizedBox(height: 20),

                  // Recent Activity Preview (if profile exists)
                  if (profile != null) ...[
                    _buildRecentActivityPreview(profile),
                    const SizedBox(height: 20),
                  ],

                  // Quick Stats (if profile exists)
                  if (profile != null) ...[
                    _buildQuickStats(profile),
                    const SizedBox(height: 20),
                  ],

                  // Space at bottom
                  const SizedBox(
                      height: 40), // ✅ Increased for better scrolling
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => item['screen']),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'],
                color: item['color'],
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['title'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item['description'],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(UserProfile profile) {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    final todayMinutes = profile.activityLog[today] ?? 0;
    final weeklyTotal = _getWeeklyTotal(profile);
    final weeklyGoal = profile.dailyTimeAvailable * 7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4158D0), Color(0xFFC850C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Progress",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '$todayMinutes',
                'Minutes',
                Icons.timer,
              ),
              _buildSummaryItem(
                '${profile.totalWorkouts}',
                'Workouts',
                Icons.fitness_center,
              ),
              _buildSummaryItem(
                '${profile.streakDays}',
                'Streak',
                Icons.local_fire_department,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Goal: $weeklyTotal/$weeklyGoal min',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: weeklyTotal / weeklyGoal,
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRotatingTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Colors.amber,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _motivationalTips[_currentTipIndex]['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _motivationalTips[_currentTipIndex]['message']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityPreview(UserProfile profile) {
    final recentLogs = profile.activityLog.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final recent = recentLogs.take(3).toList();

    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No recent activity. Start your first workout!',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgressScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recent.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(entry.key),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${entry.value} minutes',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${entry.value} min',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildQuickStats(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStatItem(
                '${profile.totalWorkouts}',
                'Total Workouts',
                Icons.fitness_center,
                Colors.blue,
              ),
              _buildQuickStatItem(
                '${profile.streakDays}',
                'Current Streak',
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildQuickStatItem(
                '${profile.level}',
                'Level',
                Icons.emoji_events,
                Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${profile.experiencePoints} / ${profile.expForNextLevel} XP to next level',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  int _getWeeklyTotal(UserProfile profile) {
    final now = DateTime.now();
    int total = 0;
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = date.toIso8601String().split('T')[0];
      total += profile.activityLog[key] ?? 0;
    }
    return total;
  }

  String _formatDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    final date =
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}';
  }
}
