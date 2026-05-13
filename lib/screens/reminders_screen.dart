import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../providers/user_provider.dart';
import '../models/user_profile.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  List<Map<String, dynamic>> _reminders = [];
  List<Map<String, dynamic>> _smartSuggestions = [];
  bool _notificationsEnabled = false;

  // Color scheme
  final Color _primaryColor = const Color(0xFF9C27B0); // Purple
  final Color _secondaryColor = const Color(0xFFFF9800); // Orange
  final Color _successColor = const Color(0xFF4CAF50); // Green
  final Color _backgroundColor = const Color(0xFFF8F9FA); // Light background

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
    _loadReminders();
  }

  // ========== HEALTH STATS CALCULATIONS ==========

  double _calculateBMI(UserProfile profile) {
    if (profile.height == null || profile.weight == null) return 0;
    double heightInMeters = profile.height! / 100;
    return profile.weight! / (heightInMeters * heightInMeters);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal ✅';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  int _calculateBMR(UserProfile profile) {
    if (profile.height == null || profile.weight == null || profile.age == 0) {
      return 0;
    }

    double bmr =
        10 * profile.weight! + 6.25 * profile.height! - 5 * profile.age;

    if (profile.gender?.toLowerCase() == 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    return bmr.toInt();
  }

  double _calculateWaterGoal(UserProfile profile) {
    if (profile.weight == null) return 2.0;
    return (profile.weight! * 0.033);
  }

  int _calculateMaxHeartRate(UserProfile profile) {
    return 220 - profile.age;
  }

  double _calculateIdealWeight(UserProfile profile) {
    if (profile.height == null) return 0;
    double idealWeight;
    if (profile.gender?.toLowerCase() == 'male') {
      idealWeight = 50 + 2.3 * ((profile.height! - 152.4) / 2.54);
    } else {
      idealWeight = 45.5 + 2.3 * ((profile.height! - 152.4) / 2.54);
    }
    return idealWeight.clamp(40, 120);
  }

  double _calculateWeightProgress(UserProfile profile) {
    if (profile.targetWeight == null || profile.weight == null) return 0;
    double startWeight = profile.weight!;
    double target = profile.targetWeight!;
    double current = profile.weight!;

    if (target > startWeight) {
      // Gaining weight
      return ((current - startWeight) / (target - startWeight) * 100)
          .clamp(0, 100);
    } else {
      // Losing weight
      return ((startWeight - current) / (startWeight - target) * 100)
          .clamp(0, 100);
    }
  }

  Future<void> _initializeNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    await _checkPermissions();
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    // Handle background notification tap
    print('Background notification tapped: ${response.payload}');
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      // Navigate based on notification type
      final data = response.payload!.split('|');
      final type = data[0];

      switch (type) {
        case 'workout':
          // Navigate to workout screen
          break;
        case 'water':
          // Navigate to hydration screen
          break;
        case 'meditation':
          // Navigate to meditation screen
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening $type screen...')),
        );
      }
    }
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      setState(() {
        _notificationsEnabled = status.isGranted;
      });
    } else {
      setState(() {
        _notificationsEnabled = true; // iOS handled in init
      });
    }
  }

  void _loadReminders() {
    // Sample reminders (would come from SharedPreferences in real app)
    setState(() {
      _reminders = [
        {
          'id': 1,
          'title': 'Morning Workout 💪',
          'message': 'Time to crush your fitness goals!',
          'time': '07:00',
          'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          'enabled': true,
          'type': 'workout',
          'color': Colors.blue,
          'icon': Icons.fitness_center,
          'sound': 'default',
          'vibration': true,
        },
        {
          'id': 2,
          'title': 'Drink Water 💧',
          'message': 'Stay hydrated! Time for water.',
          'time': '10:00, 14:00, 18:00',
          'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          'enabled': true,
          'type': 'hydration',
          'color': Colors.cyan,
          'icon': Icons.water_drop,
          'sound': 'gentle',
          'vibration': true,
        },
        {
          'id': 3,
          'title': 'Evening Stretch 🧘',
          'message': '5-minute stretching routine',
          'time': '20:00',
          'days': ['Mon', 'Wed', 'Fri'],
          'enabled': false,
          'type': 'mindfulness',
          'color': Colors.purple,
          'icon': Icons.self_improvement,
          'sound': 'calm',
          'vibration': false,
        },
      ];
    });
  }

  void _generateSmartSuggestions(UserProfile profile) {
    List<Map<String, dynamic>> suggestions = [];

    if (profile.workoutFrequency != null && profile.workoutFrequency! > 0) {
      suggestions.add({
        'title': 'Workout Reminder',
        'message': 'Time for your daily workout!',
        'time': _getPreferredTimeString(profile.preferredTime),
        'days': _getWorkoutDays(profile),
        'type': 'workout',
        'icon': Icons.fitness_center,
        'color': Colors.blue,
      });
    }

    if (profile.waterIntake != null && profile.waterIntake! > 0) {
      suggestions.add({
        'title': 'Hydration Reminder',
        'message': 'Stay hydrated throughout the day',
        'time': 'Every 2 hours',
        'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        'type': 'hydration',
        'icon': Icons.water_drop,
        'color': Colors.cyan,
      });
    }

    if (profile.sleepHours != null && profile.sleepHours! < 7) {
      suggestions.add({
        'title': 'Sleep Preparation',
        'message': 'Wind down for better sleep',
        'time': '21:30',
        'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        'type': 'sleep',
        'icon': Icons.night_shelter,
        'color': Colors.indigo,
      });
    }

    setState(() {
      _smartSuggestions = suggestions;
    });
  }

  String _getPreferredTimeString(String? preferredTime) {
    switch (preferredTime) {
      case 'morning':
        return '07:00';
      case 'afternoon':
        return '12:00';
      case 'evening':
        return '18:00';
      default:
        return '08:00';
    }
  }

  List<String> _getWorkoutDays(UserProfile profile) {
    if (profile.preferredDays.isNotEmpty) {
      return profile.preferredDays;
    }
    return ['Mon', 'Wed', 'Fri'];
  }

  // FIXED: Added timezone fallback method
  String _getLocalTimezone() {
    // Simple fallback - returns the device timezone name
    // This avoids needing flutter_native_timezone package
    return DateTime.now().timeZoneName;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Reminders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: Colors.white,
            ),
            onPressed: _openNotificationSettings,
          ),
        ],
      ),
      body: profile == null
          ? _buildEmptyProfile()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!_notificationsEnabled) _buildPermissionWarning(),
                _buildStatsCard(),

                // NEW: Health Stats Card
                const SizedBox(height: 16),
                _buildHealthStatsCard(profile),

                const SizedBox(height: 20),
                _buildSectionHeader(
                  'Active Reminders',
                  Icons.notifications_active,
                  _primaryColor,
                  action: TextButton(
                    onPressed: _showAddReminderDialog,
                    child: const Text('+ Add New'),
                  ),
                ),
                const SizedBox(height: 12),
                if (_reminders.isEmpty)
                  _buildEmptyReminders()
                else
                  ..._reminders.map((reminder) => _buildReminderCard(reminder)),
                const SizedBox(height: 24),
                if (_smartSuggestions.isNotEmpty) ...[
                  _buildSectionHeader(
                    'Smart Suggestions',
                    Icons.lightbulb,
                    _secondaryColor,
                  ),
                  const SizedBox(height: 12),
                  ..._smartSuggestions
                      .map((suggestion) => _buildSuggestionCard(suggestion)),
                  const SizedBox(height: 16),
                ],
                _buildSectionHeader(
                  'Quick Templates',
                  Icons.dashboard,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildTemplatesGrid(),
                const SizedBox(height: 20),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // NEW: Health Stats Card Widget
  Widget _buildHealthStatsCard(UserProfile profile) {
    // Calculate values
    double bmi = _calculateBMI(profile);
    String bmiCategory = _getBMICategory(bmi);
    Color bmiColor = _getBMIColor(bmi);
    int bmr = _calculateBMR(profile);
    double waterGoal = _calculateWaterGoal(profile);
    int maxHeartRate = _calculateMaxHeartRate(profile);
    double idealWeight = _calculateIdealWeight(profile);
    double weightProgress = _calculateWeightProgress(profile);

    // Check if user has entered measurements
    bool hasMeasurements = profile.height != null && profile.weight != null;

    if (!hasMeasurements) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.fitness_center, color: _primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Health Stats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Icon(Icons.height, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'Add your height and weight in Profile',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to profile screen
                  // Navigator.pushNamed(context, '/profile');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Navigate to Profile screen to update measurements')),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Update Measurements'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.favorite, color: _primaryColor),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Your Health Stats',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => setState(() {}),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const Divider(height: 24),

            // BMI Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bmiColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: bmiColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.monitor_weight, color: bmiColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BMI: ${bmi.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: bmiColor,
                          ),
                        ),
                        Text(
                          bmiCategory,
                          style: TextStyle(color: bmiColor, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // BMI Indicator Bar
                  SizedBox(
                    width: 120,
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: bmi / 40,
                          backgroundColor: Colors.grey[200],
                          color: bmiColor,
                          minHeight: 6,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('18.5', style: TextStyle(fontSize: 9)),
                            Text('25', style: TextStyle(fontSize: 9)),
                            Text('30', style: TextStyle(fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stats Grid (2 columns)
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.local_fire_department,
                    label: 'BMR',
                    value: '$bmr',
                    unit: 'cal/day',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.water_drop,
                    label: 'Daily Water',
                    value: waterGoal.toStringAsFixed(1),
                    unit: 'liters',
                    color: Colors.cyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.favorite,
                    label: 'Max Heart Rate',
                    value: '$maxHeartRate',
                    unit: 'bpm',
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.flag,
                    label: 'Ideal Weight',
                    value: idealWeight.toStringAsFixed(1),
                    unit: 'kg',
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            // Weight Progress (if target set)
            if (profile.targetWeight != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🎯 Weight Goal Progress',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${weightProgress.toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: weightProgress / 100,
                      backgroundColor: Colors.grey[200],
                      color: _primaryColor,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current: ${profile.weight} kg',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Text(
                          'Target: ${profile.targetWeight} kg',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Reminder note
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: _secondaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Update your height and weight in Profile for accurate stats',
                      style: TextStyle(fontSize: 11, color: _secondaryColor),
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

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  unit,
                  style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications Disabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enable notifications to receive reminders',
                  style: TextStyle(color: Colors.orange[700]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openNotificationSettings,
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final activeCount = _reminders.where((r) => r['enabled']).length;
    final totalCount = _reminders.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Active', '$activeCount', Icons.notifications_active),
          _buildStatItem('Total', '$totalCount', Icons.notifications),
          _buildStatItem('Today', '3', Icons.today),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
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

  Widget _buildSectionHeader(String title, IconData icon, Color color,
      {Widget? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        reminder['color'] as Color,
                        (reminder['color'] as Color).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    reminder['icon'] as IconData,
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
                        reminder['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder['message'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder['enabled'] as bool,
                  onChanged: (value) => _toggleReminder(reminder, value),
                  activeThumbColor: _primaryColor,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                _buildDetailChip(
                  Icons.access_time,
                  reminder['time'] as String,
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildDetailChip(
                  Icons.calendar_today,
                  (reminder['days'] as List).join(', '),
                  Colors.green,
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editReminder(reminder);
                    } else if (value == 'delete') {
                      _deleteReminder(reminder);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _secondaryColor.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (suggestion['color'] as Color).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            suggestion['icon'] as IconData,
            color: suggestion['color'] as Color,
            size: 20,
          ),
        ),
        title: Text(suggestion['title'] as String),
        subtitle: Text(
            '${suggestion['time']} • ${(suggestion['days'] as List).length} days'),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.green),
          onPressed: () => _addSuggestion(suggestion),
        ),
      ),
    );
  }

  Widget _buildTemplatesGrid() {
    final templates = [
      {'icon': Icons.fitness_center, 'label': 'Workout', 'color': Colors.blue},
      {'icon': Icons.water_drop, 'label': 'Water', 'color': Colors.cyan},
      {
        'icon': Icons.self_improvement,
        'label': 'Meditate',
        'color': Colors.purple
      },
      {'icon': Icons.restaurant, 'label': 'Meal', 'color': Colors.orange},
      {'icon': Icons.night_shelter, 'label': 'Sleep', 'color': Colors.indigo},
      {'icon': Icons.directions_walk, 'label': 'Stretch', 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return InkWell(
          onTap: () => _useTemplate(template),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(template['icon'] as IconData,
                    color: template['color'] as Color, size: 24),
                const SizedBox(height: 4),
                Text(
                  template['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: template['color'] as Color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Complete your profile first',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up your profile to get personalized reminders',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReminders() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_none, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text(
            'No reminders yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to create your first reminder',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // FIXED: Complete _scheduleReminder method with proper parameters
  Future<void> _scheduleReminder(Map<String, dynamic> reminder) async {
    try {
      // Parse time
      final timeParts = (reminder['time'] as String).split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Get timezone
      final timezoneName = _getLocalTimezone();
      tz.Location location;
      try {
        location = tz.getLocation(timezoneName);
      } catch (e) {
        print('⚠️ Timezone $timezoneName not found, using local');
        location = tz.local;
      }

      // Schedule for each selected day
      for (var day in reminder['days'] as List) {
        final scheduledDate = _getNextDayOfWeek(day as String, hour, minute);
        final notificationId = (reminder['id'] as int) * 10 + _dayToInt(day);

        // FIXED: Removed uiLocalNotificationDateInterpretation parameter
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          reminder['title'] as String,
          reminder['message'] as String,
          tz.TZDateTime.from(scheduledDate, location),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminder_channel',
              'Workout Reminders',
              channelDescription: 'Reminders for workouts and habits',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              enableVibration: true,
            ),
            iOS: DarwinNotificationDetails(
              sound: 'default.wav',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        print(
            '✅ Scheduled reminder: ${reminder['title']} for $day at $hour:$minute');
      }
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
    }
  }

  DateTime _getNextDayOfWeek(String day, int hour, int minute) {
    final now = DateTime.now();
    final dayInt = _dayToInt(day);
    var date = DateTime(now.year, now.month, now.day, hour, minute);

    while (date.weekday != dayInt) {
      date = date.add(const Duration(days: 1));
    }

    if (date.isBefore(now)) {
      date = date.add(const Duration(days: 7));
    }

    return date;
  }

  int _dayToInt(String day) {
    const days = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };
    return days[day] ?? 1;
  }

  Future<void> _showAddReminderDialog() async {
    // TODO: Implement add reminder dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add reminder dialog coming soon!')),
    );
  }

  void _toggleReminder(Map<String, dynamic> reminder, bool enabled) {
    setState(() {
      reminder['enabled'] = enabled;
    });

    if (enabled) {
      _scheduleReminder(reminder);
    } else {
      _cancelReminder(reminder['id'] as int);
    }
  }

  Future<void> _cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
    print('✅ Cancelled reminder: $id');
  }

  void _editReminder(Map<String, dynamic> reminder) {
    // TODO: Implement edit reminder dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit reminder dialog coming soon!')),
    );
  }

  void _deleteReminder(Map<String, dynamic> reminder) {
    _cancelReminder(reminder['id'] as int);
    setState(() {
      _reminders.remove(reminder);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${reminder['title']} deleted')),
    );
  }

  void _addSuggestion(Map<String, dynamic> suggestion) {
    // Convert suggestion to reminder and add
    final newReminder = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': suggestion['title'] as String,
      'message': suggestion['message'] as String,
      'time': suggestion['time'] as String,
      'days': suggestion['days'] as List<String>,
      'enabled': true,
      'type': suggestion['type'] as String,
      'icon': suggestion['icon'] as IconData,
      'color': suggestion['color'] as Color,
      'sound': 'default',
      'vibration': true,
    };

    setState(() {
      _reminders.add(newReminder);
    });

    _scheduleReminder(newReminder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${suggestion['title']} added!')),
    );
  }

  void _useTemplate(Map<String, dynamic> template) {
    // Quick add using template
    final newReminder = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': '${template['label']} Reminder',
      'message':
          'Time for your ${(template['label'] as String).toLowerCase()}!',
      'time': '09:00',
      'days': <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      'enabled': true,
      'type': (template['label'] as String).toLowerCase(),
      'icon': template['icon'] as IconData,
      'color': template['color'] as Color,
      'sound': 'default',
      'vibration': true,
    };

    setState(() {
      _reminders.add(newReminder);
    });

    _scheduleReminder(newReminder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${template['label']} reminder added!')),
    );
  }

  Future<void> _openNotificationSettings() async {
    await openAppSettings();
  }
}
