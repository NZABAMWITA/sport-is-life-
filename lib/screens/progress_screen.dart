import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';
import 'dart:math';
import 'dart:async';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTimeRange = 0; // 0 = week, 1 = month, 2 = year
  bool _showAllTime = false;
  final bool _showConfetti = false;
  String? _levelUpMessage;
  Timer? _confettiTimer;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _dailyChallenges = [
    {
      'id': 'daily_30min',
      'title': '30-Minute Workout',
      'description': 'Complete 30 minutes of exercise today',
      'icon': Icons.timer,
      'color': Colors.orange,
      'target': 30,
      'reward': '50 XP',
    },
    {
      'id': 'daily_strength',
      'title': 'Strength Day',
      'description': 'Complete 2 strength exercises',
      'icon': Icons.fitness_center,
      'color': Colors.green,
      'target': 2,
      'reward': '30 XP',
    },
    {
      'id': 'daily_balance',
      'title': 'Balance Practice',
      'description': 'Do 1 balance exercise',
      'icon': Icons.balance,
      'color': Colors.purple,
      'target': 1,
      'reward': '20 XP',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confettiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final profile = userProvider.userProfile;

        if (profile == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Your Progress'),
              backgroundColor: Colors.blue,
            ),
            body: const Center(
              child: Text('Complete your profile to see progress.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Progress'),
            backgroundColor: Colors.blue,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _buildTimeRangeSelector(),
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLevelCard(profile),
                    const SizedBox(height: 20),
                    _buildChallengesSection(profile),
                    const SizedBox(height: 24),
                    _buildStatsGrid(profile),
                    const SizedBox(height: 24),
                    _buildChartSection(profile),
                    const SizedBox(height: 24),
                    _buildAchievementsSection(profile),
                    const SizedBox(height: 24),
                    _buildRecentActivity(profile),
                  ],
                ),
              ),
              if (_showConfetti) _buildConfettiOverlay(),
              if (_levelUpMessage != null) _buildLevelUpMessage(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${profile.level}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.experiencePoints} / ${profile.expForNextLevel} XP',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: profile.levelProgress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next level: ${profile.expForNextLevel - profile.experiencePoints} XP',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🔥 Keep going!',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
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
                '🎯 Daily Challenges',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'New daily',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._dailyChallenges
              .map((challenge) => _buildChallengeItem(profile, challenge)),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(
      UserProfile profile, Map<String, dynamic> challenge) {
    final progress = profile.challengeProgress[challenge['id']] ?? 0;
    final isCompleted = profile.completedChallenges[challenge['id']] ?? false;
    final target = challenge['target'] as int;
    final progressPercent = (progress / target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: challenge['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              challenge['icon'],
              color: isCompleted ? Colors.green : challenge['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        challenge['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isCompleted ? Colors.green : Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        challenge['reward'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  challenge['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Colors.green : challenge['color'],
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$progress/$target',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeRangeChip('Week', 0),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTimeRangeChip('Month', 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTimeRangeChip('Year', 2),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeChip(String label, int index) {
    final isSelected = _selectedTimeRange == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTimeRange = index;
          _showAllTime = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(UserProfile profile) {
    final now = DateTime.now();
    int thisWeekTotal = 0;
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final key = date.toIso8601String().split('T')[0];
      thisWeekTotal += profile.activityLog[key] ?? 0;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Workouts',
          '${profile.totalWorkouts}',
          Icons.fitness_center,
          Colors.blue,
          'All time',
        ),
        _buildStatCard(
          'Current Streak',
          '${profile.streakDays} days',
          Icons.local_fire_department,
          Colors.orange,
          'Best: ${_calculateBestStreak(profile)} days',
        ),
        _buildStatCard(
          'This Week',
          '$thisWeekTotal min',
          Icons.timer,
          Colors.green,
          '${(thisWeekTotal / 150 * 100).round()}% of goal',
        ),
        _buildStatCard(
          'Last Workout',
          _formatLastWorkout(profile.lastWorkoutDate),
          Icons.history,
          Colors.purple,
          profile.lastWorkoutDate != null ? 'Keep going!' : 'Start now!',
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(UserProfile profile) {
    final chartData = _getChartData(profile);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
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
              Text(
                _getChartTitle(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_showAllTime)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAllTime = true;
                    });
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartData.maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} min',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < chartData.labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              chartData.labels[value.toInt()],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 10 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 10,
                  drawVerticalLine: false,
                ),
                barGroups: chartData.barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏆 Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAchievementChip(
                'First Workout',
                profile.totalWorkouts >= 1,
                Icons.emoji_events,
                Colors.amber,
              ),
              _buildAchievementChip(
                '5 Workouts',
                profile.totalWorkouts >= 5,
                Icons.fitness_center,
                Colors.green,
              ),
              _buildAchievementChip(
                '10 Workouts',
                profile.totalWorkouts >= 10,
                Icons.stars,
                Colors.blue,
              ),
              _buildAchievementChip(
                '3 Day Streak',
                profile.streakDays >= 3,
                Icons.local_fire_department,
                Colors.orange,
              ),
              _buildAchievementChip(
                '7 Day Streak',
                profile.streakDays >= 7,
                Icons.whatshot,
                Colors.red,
              ),
              _buildAchievementChip(
                '30 Day Streak',
                profile.streakDays >= 30,
                Icons.workspace_premium,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementChip(
      String label, bool achieved, IconData icon, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            achieved ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achieved ? color : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: achieved ? color : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: achieved ? color : Colors.grey,
              fontWeight: achieved ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (achieved) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.check_circle,
              size: 14,
              color: Colors.green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentActivity(UserProfile profile) {
    final recentLogs = profile.activityLog.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final recent = recentLogs.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No activity yet. Start your first workout!',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...recent.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildConfettiOverlay() {
    return IgnorePointer(
      child: Container(
        color: Colors.transparent,
        child: CustomPaint(
          painter: ConfettiPainter(),
          size: MediaQuery.of(context).size,
        ),
      ),
    );
  }

  Widget _buildLevelUpMessage() {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          return Opacity(
            opacity: value < 0.8 ? 1.0 : (1.0 - (value - 0.8) * 5),
            child: Transform.scale(
              scale: 1 + (value * 0.3),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  _levelUpMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getChartTitle() {
    if (_showAllTime) return 'All Time Activity';
    switch (_selectedTimeRange) {
      case 0:
        return 'This Week';
      case 1:
        return 'This Month';
      case 2:
        return 'This Year';
      default:
        return 'Activity';
    }
  }

  ChartData _getChartData(UserProfile profile) {
    final now = DateTime.now();
    List<String> labels = [];
    List<double> values = [];
    double maxY = 10;

    if (_showAllTime) {
      for (int i = 29; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final key = date.toIso8601String().split('T')[0];
        final value = profile.activityLog[key]?.toDouble() ?? 0;
        values.add(value);
        if (i % 5 == 0) {
          labels.add('${date.day}/${date.month}');
        } else {
          labels.add('');
        }
        if (value > maxY) maxY = value;
      }
    } else {
      switch (_selectedTimeRange) {
        case 0:
          for (int i = 6; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            final key = date.toIso8601String().split('T')[0];
            final value = profile.activityLog[key]?.toDouble() ?? 0;
            values.add(value);
            labels.add(_getDayLabel(date.weekday));
            if (value > maxY) maxY = value;
          }
          break;
        case 1:
          for (int i = 29; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            final key = date.toIso8601String().split('T')[0];
            final value = profile.activityLog[key]?.toDouble() ?? 0;
            values.add(value);
            if (i % 5 == 0) {
              labels.add('${date.day}/${date.month}');
            } else {
              labels.add('');
            }
            if (value > maxY) maxY = value;
          }
          break;
        case 2:
          for (int i = 11; i >= 0; i--) {
            final month = DateTime(now.year, now.month - i, 1);
            double total = 0;
            for (int d = 1; d <= _daysInMonth(month); d++) {
              final date = DateTime(month.year, month.month, d);
              final key = date.toIso8601String().split('T')[0];
              total += profile.activityLog[key] ?? 0;
            }
            values.add(total);
            labels.add(_getMonthLabel(month.month));
            if (total > maxY) maxY = total;
          }
          break;
      }
    }

    maxY = ((maxY / 10).ceil() * 10).toDouble();

    final barGroups = values.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
            width: _showAllTime ? 8 : 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return ChartData(labels, barGroups, maxY);
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  String _getDayLabel(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
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

  String _formatLastWorkout(String? isoDate) {
    if (isoDate == null) return 'Never';
    try {
      final date = DateTime.parse(isoDate);
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
    } catch (e) {
      return 'Unknown';
    }
  }

  int _calculateBestStreak(UserProfile profile) {
    final sortedDates = profile.activityLog.keys.toList()..sort();
    if (sortedDates.isEmpty) return 0;

    int bestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final prev = DateTime.parse(sortedDates[i - 1]);
      final curr = DateTime.parse(sortedDates[i]);

      if (curr.difference(prev).inDays == 1) {
        currentStreak++;
        bestStreak = max(bestStreak, currentStreak);
      } else {
        currentStreak = 1;
      }
    }

    return bestStreak;
  }
}

class ChartData {
  final List<String> labels;
  final List<BarChartGroupData> barGroups;
  final double maxY;

  ChartData(this.labels, this.barGroups, this.maxY);
}

class ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 50; i++) {
      final x = (random.nextDouble() * size.width).toDouble();
      final y =
          (random.nextDouble() * size.height - (now % 1000) / 10).toDouble();

      final paint = Paint()
        ..color = Colors.primaries[random.nextInt(Colors.primaries.length)]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), random.nextDouble() * 8 + 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
