import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';
import 'dart:async';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Beautiful color scheme
  final Color _primaryColor = const Color(0xFF6C63FF); // Vibrant purple
  final Color _secondaryColor = const Color(0xFFFF6B6B); // Coral
  final Color _accentColor = const Color(0xFF4ECDC4); // Mint
  final Color _successColor = const Color(0xFF4CAF50); // Green
  final Color _warningColor = const Color(0xFFFFB74D); // Orange
  final Color _dangerColor = const Color(0xFFFF5252); // Red
  final Color _backgroundColor = const Color(0xFFF8F9FA); // Light background

  // Gradient colors for cards
  final List<Color> _gradientColors = [
    const Color(0xFF4158D0),
    const Color(0xFFC850C0),
    const Color(0xFFFFCC70),
  ];

  // Goal categories with beautiful icons and colors
  final List<Map<String, dynamic>> _goalCategories = [
    {'name': 'All', 'icon': Icons.circle, 'color': Colors.grey},
    {
      'name': 'Workout',
      'icon': Icons.fitness_center,
      'color': const Color(0xFF4158D0)
    },
    {
      'name': 'Weight',
      'icon': Icons.monitor_weight,
      'color': const Color(0xFFC850C0)
    },
    {
      'name': 'Nutrition',
      'icon': Icons.restaurant,
      'color': const Color(0xFFFFB74D)
    },
    {
      'name': 'Hydration',
      'icon': Icons.water_drop,
      'color': const Color(0xFF4ECDC4)
    },
    {
      'name': 'Sleep',
      'icon': Icons.night_shelter,
      'color': const Color(0xFF6C5CE7)
    },
    {
      'name': 'Steps',
      'icon': Icons.directions_walk,
      'color': const Color(0xFF00B894)
    },
    {
      'name': 'Mindfulness',
      'icon': Icons.self_improvement,
      'color': const Color(0xFFE84393)
    },
  ];

  // Sample goals
  List<Map<String, dynamic>> _userGoals = [];
  List<Map<String, dynamic>> _suggestedGoals = [];

  // Controllers
  final TextEditingController _goalTitleController = TextEditingController();
  final TextEditingController _goalTargetController = TextEditingController();
  final TextEditingController _goalProgressController = TextEditingController();
  String _selectedGoalCategory = 'Workout';
  DateTime _selectedGoalDeadline = DateTime.now().add(const Duration(days: 30));
  String _selectedGoalUnit = 'minutes';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserGoals();
    _loadSuggestedGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _goalTitleController.dispose();
    _goalTargetController.dispose();
    _goalProgressController.dispose();
    super.dispose();
  }

  void _loadUserGoals() {
    setState(() {
      _userGoals = [
        {
          'id': '1',
          'title': 'Complete 20 Workouts',
          'description': 'Finish 20 workouts this month',
          'category': 'Workout',
          'target': 20,
          'progress': 12,
          'unit': 'workouts',
          'deadline': DateTime.now().add(const Duration(days: 25)),
          'icon': Icons.fitness_center,
          'color': const Color(0xFF4158D0),
          'created': DateTime.now().subtract(const Duration(days: 5)),
          'status': 'active',
          'streak': 3,
        },
        {
          'id': '2',
          'title': 'Lose 5 kg',
          'description': 'Reach target weight of 70 kg',
          'category': 'Weight',
          'target': 5,
          'progress': 2.3,
          'unit': 'kg',
          'deadline': DateTime.now().add(const Duration(days: 60)),
          'icon': Icons.monitor_weight,
          'color': const Color(0xFFC850C0),
          'created': DateTime.now().subtract(const Duration(days: 10)),
          'status': 'active',
          'streak': 0,
        },
        {
          'id': '3',
          'title': 'Drink 8 Glasses Daily',
          'description': 'Stay hydrated every day',
          'category': 'Hydration',
          'target': 8,
          'progress': 6,
          'unit': 'glasses',
          'deadline': DateTime.now().add(const Duration(days: 1)),
          'icon': Icons.water_drop,
          'color': const Color(0xFF4ECDC4),
          'created': DateTime.now().subtract(const Duration(days: 3)),
          'status': 'active',
          'streak': 3,
        },
        {
          'id': '4',
          'title': 'Run 100 km',
          'description': 'Total running distance',
          'category': 'Workout',
          'target': 100,
          'progress': 45,
          'unit': 'km',
          'deadline': DateTime.now().add(const Duration(days: 45)),
          'icon': Icons.directions_run,
          'color': const Color(0xFFFFB74D),
          'created': DateTime.now().subtract(const Duration(days: 15)),
          'status': 'active',
          'streak': 0,
        },
        {
          'id': '5',
          'title': 'Meditate 30 Days',
          'description': 'Daily meditation practice',
          'category': 'Mindfulness',
          'target': 30,
          'progress': 12,
          'unit': 'days',
          'deadline': DateTime.now().add(const Duration(days: 18)),
          'icon': Icons.self_improvement,
          'color': const Color(0xFFE84393),
          'created': DateTime.now().subtract(const Duration(days: 12)),
          'status': 'active',
          'streak': 12,
        },
      ];
    });
  }

  void _loadSuggestedGoals() {
    setState(() {
      _suggestedGoals = [
        {
          'id': 's1',
          'title': 'Walk 10,000 Steps',
          'description': 'Daily step goal for better health',
          'category': 'Steps',
          'target': 10000,
          'unit': 'steps',
          'icon': Icons.directions_walk,
          'color': const Color(0xFF00B894),
          'difficulty': 'Easy',
          'duration': 'Daily',
          'popularity': 95,
        },
        {
          'id': 's2',
          'title': 'Workout 3x Weekly',
          'description': 'Build consistency in your routine',
          'category': 'Workout',
          'target': 3,
          'unit': 'workouts',
          'icon': Icons.fitness_center,
          'color': const Color(0xFF4158D0),
          'difficulty': 'Easy',
          'duration': 'Weekly',
          'popularity': 88,
        },
        {
          'id': 's3',
          'title': 'Lose 1 kg Weekly',
          'description': 'Healthy and sustainable weight loss',
          'category': 'Weight',
          'target': 1,
          'unit': 'kg',
          'icon': Icons.monitor_weight,
          'color': const Color(0xFFC850C0),
          'difficulty': 'Moderate',
          'duration': 'Weekly',
          'popularity': 92,
        },
        {
          'id': 's4',
          'title': 'Drink 2L Water',
          'description': 'Stay properly hydrated daily',
          'category': 'Hydration',
          'target': 8,
          'unit': 'glasses',
          'icon': Icons.water_drop,
          'color': const Color(0xFF4ECDC4),
          'difficulty': 'Easy',
          'duration': 'Daily',
          'popularity': 97,
        },
        {
          'id': 's5',
          'title': 'Sleep 8 Hours',
          'description': 'Improve recovery and energy',
          'category': 'Sleep',
          'target': 8,
          'unit': 'hours',
          'icon': Icons.night_shelter,
          'color': const Color(0xFF6C5CE7),
          'difficulty': 'Moderate',
          'duration': 'Daily',
          'popularity': 84,
        },
        {
          'id': 's6',
          'title': 'Run 5K in 30 min',
          'description': 'Improve your running speed',
          'category': 'Workout',
          'target': 5,
          'unit': 'km',
          'icon': Icons.directions_run,
          'color': const Color(0xFFFFB74D),
          'difficulty': 'Challenging',
          'duration': 'Monthly',
          'popularity': 76,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Goals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.3),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'MY GOALS', icon: Icon(Icons.flag)),
                Tab(text: 'SUGGESTED', icon: Icon(Icons.lightbulb)),
                Tab(text: 'CREATE', icon: Icon(Icons.add_circle)),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _primaryColor,
              _backgroundColor,
            ],
            stops: const [0.0, 0.2],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMyGoalsTab(profile),
            _buildSuggestedGoalsTab(profile),
            _buildCreateGoalTab(profile),
          ],
        ),
      ),
    );
  }

  // ==================== MY GOALS TAB ====================
  Widget _buildMyGoalsTab(UserProfile? profile) {
    final activeGoals =
        _userGoals.where((g) => g['status'] == 'active').toList();
    final completedGoals =
        _userGoals.where((g) => g['status'] == 'completed').toList();
    final totalGoals = _userGoals.length;
    final completedCount = completedGoals.length;
    final overallProgress = totalGoals == 0 ? 0.0 : completedCount / totalGoals;

    return Column(
      children: [
        // Overall progress card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedCount of $totalGoals',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_primaryColor),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: overallProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                      strokeWidth: 8,
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Active Goals header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Goals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${activeGoals.length} goals',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Active goals list
        Expanded(
          child: activeGoals.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activeGoals.length,
                  itemBuilder: (context, index) {
                    final goal = activeGoals[index];
                    return _buildGoalCard(goal);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final progress = goal['progress'] / goal['target'];
    final daysLeft = goal['deadline'].difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3 && daysLeft > 0;
    final isOverdue = daysLeft < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        goal['color'],
                        goal['color'].withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    goal['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Streak indicator
                if (goal['streak'] > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${goal['streak']}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Progress section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${goal['progress']} / ${goal['target']} ${goal['unit']}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(goal['color']),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Deadline indicator
                    Row(
                      children: [
                        Icon(
                          isOverdue
                              ? Icons.error
                              : (isUrgent
                                  ? Icons.warning
                                  : Icons.calendar_today),
                          size: 16,
                          color: isOverdue
                              ? _dangerColor
                              : (isUrgent ? _warningColor : Colors.grey[600]),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOverdue ? 'Overdue' : '$daysLeft days left',
                          style: TextStyle(
                            fontSize: 13,
                            color: isOverdue
                                ? _dangerColor
                                : (isUrgent ? _warningColor : Colors.grey[600]),
                            fontWeight: isOverdue || isUrgent
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),

                    // Action buttons
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.add,
                          color: goal['color'],
                          onPressed: () =>
                              _updateGoalProgress(goal, goal['progress'] + 1),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.check,
                          color: _successColor,
                          onPressed: () => _markGoalCompleted(goal),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  // ==================== SUGGESTED GOALS TAB ====================
  Widget _buildSuggestedGoalsTab(UserProfile? profile) {
    String selectedCategory = 'All';

    return Column(
      children: [
        // Category chips
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _goalCategories.length,
            itemBuilder: (context, index) {
              final category = _goalCategories[index];
              final isSelected = selectedCategory == category['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category['name']),
                  avatar: Icon(
                    category['icon'],
                    color: isSelected ? Colors.white : category['color'],
                    size: 14,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {},
                  backgroundColor: Colors.white,
                  selectedColor: category['color'],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 0,
                ),
              );
            },
          ),
        ),

        // Suggested goals grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _suggestedGoals.length,
            itemBuilder: (context, index) {
              final goal = _suggestedGoals[index];
              return _buildSuggestedGoalCard(goal);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedGoalCard(Map<String, dynamic> goal) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _addSuggestedGoal(goal),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and popularity
                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            goal['color'],
                            goal['color'].withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        goal['icon'],
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(goal['difficulty'])
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 10,
                            color: _getDifficultyColor(goal['difficulty']),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${goal['popularity']}%',
                            style: TextStyle(
                              fontSize: 9,
                              color: _getDifficultyColor(goal['difficulty']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  goal['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goal['description'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    // Duration badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: goal['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        goal['duration'],
                        style: TextStyle(
                          fontSize: 9,
                          color: goal['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Add button
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== CREATE GOAL TAB ====================
  Widget _buildCreateGoalTab(UserProfile? profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryColor,
                  const Color(0xFFC850C0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a New Goal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set a SMART goal to track your progress and stay motivated',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Form card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Goal title
                const Text(
                  'Goal Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _goalTitleController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Run 5km, Lose 2kg, Meditate daily',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),

                const SizedBox(height: 20),

                // Category
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _goalCategories.length,
                    itemBuilder: (context, index) {
                      final category = _goalCategories[index];
                      if (category['name'] == 'All') return const SizedBox();
                      final isSelected =
                          _selectedGoalCategory == category['name'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category['name']),
                          avatar: Icon(
                            category['icon'],
                            color:
                                isSelected ? Colors.white : category['color'],
                            size: 14,
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedGoalCategory = category['name'];
                            });
                          },
                          backgroundColor: Colors.grey[50],
                          selectedColor: category['color'],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[800],
                            fontSize: 13,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Target and unit
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _goalTargetController,
                            decoration: InputDecoration(
                              hintText: 'e.g., 30',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Unit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedGoalUnit,
                              isExpanded: true,
                              underline: const SizedBox(),
                              icon: Icon(Icons.arrow_drop_down,
                                  color: _primaryColor),
                              items: [
                                'minutes',
                                'hours',
                                'km',
                                'kg',
                                'workouts',
                                'days',
                                'glasses',
                                'steps',
                                'calories'
                              ].map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGoalUnit = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Deadline
                const Text(
                  'Target Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDeadline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: _primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            DateFormat('EEEE, MMMM d, yyyy')
                                .format(_selectedGoalDeadline),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Current progress (optional)
                const Text(
                  'Current Progress (optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _goalProgressController,
                  decoration: InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 20),

                // SMART tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: _primaryColor, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'SMART Goal Tips',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTipRow('S', 'pecific - Clear, well-defined goal'),
                      _buildTipRow('M', 'easurable - Track your progress'),
                      _buildTipRow(
                          'A', 'chievable - Realistic but challenging'),
                      _buildTipRow(
                          'R', 'elevant - Aligns with your fitness journey'),
                      _buildTipRow('T', 'ime-bound - Set a deadline'),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Create button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createNewGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Create Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flag,
              size: 60,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Active Goals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new goal or browse suggestions',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.lightbulb),
                label: const Text('Suggestions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _primaryColor,
                  elevation: 0,
                  side: BorderSide(color: _primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(2),
                icon: const Icon(Icons.add),
                label: const Text('Create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow(String letter, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'Challenging':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedGoalDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedGoalDeadline = picked;
      });
    }
  }

  void _updateGoalProgress(Map<String, dynamic> goal, double newProgress) {
    setState(() {
      goal['progress'] = newProgress.clamp(0.0, goal['target'] as double);
      if (goal['progress'] >= goal['target']) {
        goal['status'] = 'completed';
        _showSuccessDialog('Goal Completed! 🎉');
      }
    });
  }

  void _markGoalCompleted(Map<String, dynamic> goal) {
    setState(() {
      goal['progress'] = goal['target'];
      goal['status'] = 'completed';
    });
    _showSuccessDialog('Goal Completed! 🎉');
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Icon(
          Icons.emoji_events,
          size: 60,
          color: Colors.amber,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _addSuggestedGoal(Map<String, dynamic> goal) {
    final newGoal = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': goal['title'],
      'description': goal['description'],
      'category': goal['category'],
      'target': goal['target'],
      'progress': 0,
      'unit': goal['unit'],
      'deadline': DateTime.now().add(const Duration(days: 30)),
      'icon': goal['icon'],
      'color': goal['color'],
      'created': DateTime.now(),
      'status': 'active',
      'streak': 0,
    };

    setState(() {
      _userGoals.add(newGoal);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Goal added to your list!'),
            ),
          ],
        ),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    _tabController.animateTo(0);
  }

  void _createNewGoal() {
    if (_goalTitleController.text.isEmpty ||
        _goalTargetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final categoryData = _goalCategories.firstWhere(
      (c) => c['name'] == _selectedGoalCategory,
      orElse: () => _goalCategories[1],
    );

    final newGoal = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': _goalTitleController.text,
      'description': 'Custom goal',
      'category': _selectedGoalCategory,
      'target': double.parse(_goalTargetController.text),
      'progress': double.tryParse(_goalProgressController.text) ?? 0,
      'unit': _selectedGoalUnit,
      'deadline': _selectedGoalDeadline,
      'icon': categoryData['icon'],
      'color': categoryData['color'],
      'created': DateTime.now(),
      'status': 'active',
      'streak': 0,
    };

    setState(() {
      _userGoals.add(newGoal);
    });

    // Clear form
    _goalTitleController.clear();
    _goalTargetController.clear();
    _goalProgressController.clear();
    _selectedGoalCategory = 'Workout';
    _selectedGoalUnit = 'minutes';
    _selectedGoalDeadline = DateTime.now().add(const Duration(days: 30));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Goal created successfully!'),
            ),
          ],
        ),
        backgroundColor: _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    _tabController.animateTo(0);
  }
}
