import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';

class DailyActivityScreen extends StatefulWidget {
  const DailyActivityScreen({super.key});

  @override
  State<DailyActivityScreen> createState() => _DailyActivityScreenState();
}

class _DailyActivityScreenState extends State<DailyActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateTime _selectedDate = DateTime.now();

  // Color scheme
  final Color _primaryColor = const Color(0xFFFF6B6B); // Coral red
  final Color _secondaryColor = const Color(0xFF4ECDC4); // Mint
  final Color _accentColor = const Color(0xFFFFE66D); // Sunny yellow
  final Color _backgroundColor = const Color(0xFFF7F9FC); // Light gray-blue

  // Activity types with beautiful icons and colors
  final List<Map<String, dynamic>> _activityTypes = [
    {
      'name': 'Walking',
      'icon': Icons.directions_walk,
      'color': const Color(0xFF4CAF50),
      'met': 3.5,
      'emoji': '🚶'
    },
    {
      'name': 'Running',
      'icon': Icons.directions_run,
      'color': const Color(0xFF2196F3),
      'met': 7.0,
      'emoji': '🏃'
    },
    {
      'name': 'Cycling',
      'icon': Icons.directions_bike,
      'color': const Color(0xFFFF9800),
      'met': 6.0,
      'emoji': '🚲'
    },
    {
      'name': 'Swimming',
      'icon': Icons.pool,
      'color': const Color(0xFF00BCD4),
      'met': 5.0,
      'emoji': '🏊'
    },
    {
      'name': 'Yoga',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF9C27B0),
      'met': 2.5,
      'emoji': '🧘'
    },
    {
      'name': 'Strength',
      'icon': Icons.fitness_center,
      'color': const Color(0xFFF44336),
      'met': 4.0,
      'emoji': '💪'
    },
    {
      'name': 'Stretching',
      'icon': Icons.accessibility_new,
      'color': const Color(0xFF009688),
      'met': 2.0,
      'emoji': '🤸'
    },
    {
      'name': 'Dancing',
      'icon': Icons.music_note,
      'color': const Color(0xFFE91E63),
      'met': 4.5,
      'emoji': '💃'
    },
    {
      'name': 'HIIT',
      'icon': Icons.flash_on,
      'color': const Color(0xFFFF5722),
      'met': 8.0,
      'emoji': '⚡'
    },
    {
      'name': 'Meditation',
      'icon': Icons.spa,
      'color': const Color(0xFF607D8B),
      'met': 1.5,
      'emoji': '🧠'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) return 'Today';
    if (selected == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (selected == today.add(const Duration(days: 1))) return 'Tomorrow';

    return DateFormat('EEEE, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Daily Activity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Today', icon: Icon(Icons.wb_sunny)),
            Tab(text: 'Log', icon: Icon(Icons.add_circle)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: profile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Complete your profile first',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(profile),
                _buildLogTab(profile),
                _buildHistoryTab(profile),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tabController.animateTo(1);
        },
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // ==================== TODAY TAB ====================
  Widget _buildTodayTab(UserProfile profile) {
    final todayActivities = _getActivitiesForDate(profile, DateTime.now());
    final totalMinutes =
        todayActivities.fold<int>(0, (sum, a) => sum + (a['duration'] as int));
    final totalCalories =
        todayActivities.fold<int>(0, (sum, a) => sum + (a['calories'] as int));
    final goal = profile.dailyTimeAvailable ?? 30;
    final progress = totalMinutes / goal;
    final percentComplete = (progress * 100).clamp(0, 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Motivational header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.white, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      _getMotivationalMessage(percentComplete),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getMotivationalSubMessage(percentComplete),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Progress card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                        'Minutes', '$totalMinutes', Icons.timer, _primaryColor),
                    _buildStatCard('Calories', '$totalCalories',
                        Icons.local_fire_department, _secondaryColor),
                    _buildStatCard(
                        'Goal', '$goal min', Icons.flag, _accentColor),
                  ],
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: progress >= 1.0
                                ? [Colors.green, Colors.lightGreen]
                                : [_primaryColor, _secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: progress >= 1.0
                                  ? Colors.green.withOpacity(0.3)
                                  : _primaryColor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0 min',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      progress >= 1.0
                          ? '🎉 Goal Achieved!'
                          : '$percentComplete% of $goal min',
                      style: TextStyle(
                        color: progress >= 1.0 ? Colors.green : _primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$goal min',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Today's activities header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.list_alt, color: _primaryColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Today\'s Activities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (todayActivities.isNotEmpty)
                Text(
                  '${todayActivities.length} activities',
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Activities list
          if (todayActivities.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 60,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activities yet today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to log your workout',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => _tabController.animateTo(1),
                    icon: const Icon(Icons.add),
                    label: const Text('Log Activity'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayActivities.length,
              itemBuilder: (context, index) {
                final activity = todayActivities[index];
                return _buildActivityCard(activity);
              },
            ),
        ],
      ),
    );
  }

  // ==================== LOG TAB ====================
  Widget _buildLogTab(UserProfile profile) {
    String selectedType = 'Walking';
    int duration = 15;
    int perceivedEffort = 5;
    TextEditingController notesController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_secondaryColor, _secondaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Log Your Workout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Every minute counts toward your goals!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Activity type selector
          const Text(
            'What did you do?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _activityTypes.length,
              itemBuilder: (context, index) {
                final type = _activityTypes[index];
                final isSelected = selectedType == type['name'];
                return GestureDetector(
                  onTap: () => setState(() => selectedType = type['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? type['color'].withOpacity(0.1)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? type['color'] : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          type['emoji'],
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type['name'],
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isSelected ? type['color'] : Colors.grey[600],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Duration and effort cards
          Row(
            children: [
              Expanded(
                child: _buildLogCard(
                  title: 'Duration',
                  icon: Icons.timer,
                  value: '$duration min',
                  child: Slider(
                    value: duration.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    activeColor: _primaryColor,
                    inactiveColor: Colors.grey[300],
                    onChanged: (value) =>
                        setState(() => duration = value.round()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLogCard(
                  title: 'Effort',
                  icon: Icons.favorite,
                  value: '$perceivedEffort/10',
                  child: Slider(
                    value: perceivedEffort.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: _getEffortColor(perceivedEffort),
                    inactiveColor: Colors.grey[300],
                    onChanged: (value) =>
                        setState(() => perceivedEffort = value.round()),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Notes field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.note, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Notes (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'How did it feel? Any achievements?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _secondaryColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // XP preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accentColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You\'ll earn:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${duration * perceivedEffort ~/ 2} XP',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Log button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _logActivity(
                profile,
                selectedType,
                duration,
                perceivedEffort,
                notesController.text,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Text(
                '✓ Log Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HISTORY TAB (COMPLETELY FIXED) ====================
  Widget _buildHistoryTab(UserProfile profile) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> weeklyData = [];
    int totalWeekMinutes = 0;

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final minutes = profile.activityLog[dateStr] ?? 0;
      totalWeekMinutes += minutes;
      weeklyData.add({
        'date': date,
        'minutes': minutes,
        'day': DateFormat('E').format(date),
        'dayNum': date.day,
      });
    }

    final maxMinutes = weeklyData.isEmpty
        ? 1
        : weeklyData
            .map((d) => d['minutes'] as int)
            .reduce((a, b) => a > b ? a : b);

    // Get sorted entries for history
    final sortedEntries = profile.activityLog.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekly summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_secondaryColor, _secondaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'This Week',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$totalWeekMinutes min',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weeklyData.map((data) {
                      final height = maxMinutes == 0
                          ? 0
                          : (data['minutes'] / maxMinutes) * 80;

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: height,
                              width: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: data['minutes'] > 0
                                      ? [
                                          Colors.white,
                                          Colors.white.withOpacity(0.8)
                                        ]
                                      : [
                                          Colors.white.withOpacity(0.3),
                                          Colors.white.withOpacity(0.1)
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['day'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${data['minutes']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // History header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.history, color: _secondaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Activity History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Activity history list
          if (profile.activityLog.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(Icons.history, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No activity history yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            // FIXED: Properly structured history list
            Column(
              children: sortedEntries.map((entry) {
                final date = DateTime.parse(entry.key);
                final activities = _getActivitiesForDate(profile, date);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: _primaryColor.withOpacity(0.1),
                        child: Text(
                          '${entry.value}',
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        DateFormat('EEEE, MMM d, yyyy').format(date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${entry.value} minutes • ${activities.length} activities',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      children: activities.map((activity) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  (activity['color'] as Color).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity['icon'],
                              color: activity['color'],
                              size: 16,
                            ),
                          ),
                          title: Text(activity['type']),
                          subtitle: Text(activity['time']),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${activity['duration']} min',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${activity['calories']} cal',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (activity['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            activity['icon'],
            color: activity['color'],
            size: 28,
          ),
        ),
        title: Text(
          activity['type'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.timer, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${activity['duration']} min',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(width: 12),
            Icon(Icons.local_fire_department,
                size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${activity['calories']} cal',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              activity['time'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        onTap: () => _showActivityDetails(context, activity),
      ),
    );
  }

  Widget _buildLogCard({
    required String title,
    required IconData icon,
    required String value,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
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
              Row(
                children: [
                  Icon(icon, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  List<Map<String, dynamic>> _getActivitiesForDate(
      UserProfile profile, DateTime date) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final minutes = profile.activityLog[dateStr] ?? 0;

    List<Map<String, dynamic>> activities = [];

    if (minutes > 0) {
      int remaining = minutes;
      final random = Random(date.millisecondsSinceEpoch);

      while (remaining > 0) {
        final duration = min(random.nextInt(20) + 5, remaining);
        final typeIndex = random.nextInt(_activityTypes.length);
        final type = _activityTypes[typeIndex];

        activities.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString() +
              activities.length.toString(),
          'type': type['name'],
          'icon': type['icon'],
          'color': type['color'],
          'emoji': type['emoji'],
          'duration': duration,
          'calories': (duration * type['met'] * 3.5).round(),
          'time': '${random.nextInt(12) + 1}:${[
            0,
            15,
            30,
            45
          ][random.nextInt(4)]} ${random.nextBool() ? 'AM' : 'PM'}',
        });

        remaining -= duration;
      }
    }

    return activities;
  }

  String _getMotivationalMessage(int percent) {
    if (percent == 0) return "Ready to start? 🌅";
    if (percent < 25) return "Great start! Keep going! 💪";
    if (percent < 50) return "You're making progress! 🔥";
    if (percent < 75) return "Almost there! You've got this! ⭐";
    if (percent < 100) return "So close to your goal! 🎯";
    return "Goal achieved! You're amazing! 🏆";
  }

  String _getMotivationalSubMessage(int percent) {
    if (percent == 0) return "Every journey begins with a single step";
    if (percent < 25) return "You've started, now keep the momentum";
    if (percent < 50) return "Halfway there - you're doing great!";
    if (percent < 75) return "Keep pushing, you're almost there";
    if (percent < 100) return "Just a little more to reach your goal";
    return "You crushed it today! Time to celebrate";
  }

  Color _getEffortColor(int effort) {
    if (effort <= 3) return Colors.green;
    if (effort <= 6) return Colors.orange;
    return Colors.red;
  }

  void _showActivityDetails(
      BuildContext context, Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      activity['emoji'] ?? '💪',
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['type'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        activity['time'],
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                      Icons.timer, '${activity['duration']} min', 'Duration'),
                ),
                Expanded(
                  child: _buildDetailItem(Icons.local_fire_department,
                      '${activity['calories']} cal', 'Calories'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _logActivity(
    UserProfile profile,
    String type,
    int duration,
    int effort,
    String notes,
  ) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    // Update the activity log
    profile.activityLog[dateStr] =
        (profile.activityLog[dateStr] ?? 0) + duration;

    // Calculate XP
    final xpGained = duration * effort ~/ 2;
    profile.addExperience(xpGained);

    // Update challenges
    profile.updateChallengeProgress('daily_30min', duration);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: _secondaryColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity Logged!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '+$xpGained XP • $duration minutes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _secondaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Switch back to Today tab
    _tabController.animateTo(0);
  }
}
