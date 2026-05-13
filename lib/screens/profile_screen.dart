import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';
import 'login_screen.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadProfile(user.uid);
      print('✅ Profile loaded in ProfileScreen');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;

    print(
        '👤 ProfileScreen - User: ${user?.uid}, Name: ${user?.displayName}, Email: ${user?.email}');
    print(
        '📊 Profile data: age=${profile?.age}, height=${profile?.height}, weight=${profile?.weight}');

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSetupScreen(
                    initialProfile: profile,
                  ),
                ),
              ).then((_) => _loadProfile()); // Reload after editing
            },
          ),
        ],
      ),
      body: profile == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No profile data found'),
                  const SizedBox(height: 8),
                  Text(
                    'Please set up your profile',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileSetupScreen(),
                        ),
                      ).then((_) => _loadProfile());
                    },
                    child: const Text('Setup Profile'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(user, profile),
                  const SizedBox(height: 20),
                  _buildStatsCards(profile),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    title: 'Basic Information',
                    icon: Icons.person,
                    children: [
                      _buildInfoRow('Age', '${profile.age} years'),
                      _buildInfoRow('Fitness Goal',
                          profile.fitnessGoal.replaceAll('_', ' ')),
                      _buildInfoRow(
                          'Preferred Location', profile.preferredLocation),
                      _buildInfoRow(
                          'Daily Time', '${profile.dailyTimeAvailable} min'),
                      _buildInfoRow(
                          'Equipment', profile.availableEquipment.join(', ')),
                    ],
                  ),
                  if (profile.height != null ||
                      profile.weight != null ||
                      profile.gender != null)
                    _buildInfoSection(
                      title: 'Physical Attributes',
                      icon: Icons.accessibility_new,
                      children: [
                        if (profile.height != null)
                          _buildInfoRow('Height', '${profile.height} cm'),
                        if (profile.weight != null)
                          _buildInfoRow('Weight', '${profile.weight} kg'),
                        if (profile.gender != null)
                          _buildInfoRow('Gender', profile.gender!),
                        if (profile.bloodType != null)
                          _buildInfoRow('Blood Type', profile.bloodType!),
                        if (profile.bodyType != null)
                          _buildInfoRow('Body Type', profile.bodyType!),
                        if (profile.restingHeartRate != null)
                          _buildInfoRow('Resting Heart Rate',
                              '${profile.restingHeartRate} bpm'),
                      ],
                    ),
                  if (profile.healthConditions.isNotEmpty ||
                      profile.chronicConditions.isNotEmpty ||
                      profile.currentInjuries.isNotEmpty)
                    _buildInfoSection(
                      title: 'Health & Medical',
                      icon: Icons.health_and_safety,
                      children: [
                        if (profile.healthConditions.isNotEmpty)
                          _buildInfoRow('Health Conditions',
                              profile.healthConditions.join(', ')),
                        if (profile.chronicConditions.isNotEmpty)
                          _buildInfoRow('Chronic Conditions',
                              profile.chronicConditions.join(', ')),
                        if (profile.currentInjuries.isNotEmpty)
                          _buildInfoRow('Current Injuries',
                              profile.currentInjuries.join(', ')),
                        if (profile.pastInjuries.isNotEmpty)
                          _buildInfoRow(
                              'Past Injuries', profile.pastInjuries.join(', ')),
                        if (profile.surgeries.isNotEmpty)
                          _buildInfoRow(
                              'Surgeries', profile.surgeries.join(', ')),
                        if (profile.medications.isNotEmpty)
                          _buildInfoRow(
                              'Medications', profile.medications.join(', ')),
                        if (profile.allergies.isNotEmpty)
                          _buildInfoRow(
                              'Allergies', profile.allergies.join(', ')),
                        if (profile.pregnancyStatus != null)
                          _buildInfoRow('Pregnancy Status',
                              profile.pregnancyStatus!.replaceAll('_', ' ')),
                        if (profile.disability != null)
                          _buildInfoRow('Disability',
                              profile.disability!.replaceAll('_', ' ')),
                      ],
                    ),
                  if (profile.fitnessLevel != null ||
                      profile.sportsPlayed.isNotEmpty ||
                      profile.workoutTypes.isNotEmpty)
                    _buildInfoSection(
                      title: 'Fitness Experience',
                      icon: Icons.fitness_center,
                      children: [
                        if (profile.fitnessLevel != null)
                          _buildInfoRow('Fitness Level', profile.fitnessLevel!),
                        if (profile.yearsActive != null)
                          _buildInfoRow(
                              'Years Active', '${profile.yearsActive} years'),
                        if (profile.sportsPlayed.isNotEmpty)
                          _buildInfoRow(
                              'Sports Played', profile.sportsPlayed.join(', ')),
                        if (profile.workoutTypes.isNotEmpty)
                          _buildInfoRow(
                              'Workout Types', profile.workoutTypes.join(', ')),
                        if (profile.maxBenchPress != null)
                          _buildInfoRow(
                              'Max Bench Press', '${profile.maxBenchPress} kg'),
                        if (profile.maxSquat != null)
                          _buildInfoRow('Max Squat', '${profile.maxSquat} kg'),
                        if (profile.runDistance != null)
                          _buildInfoRow(
                              'Max Run Distance', '${profile.runDistance} km'),
                      ],
                    ),
                  if (profile.workoutFrequency != null ||
                      profile.preferredTime != null ||
                      profile.preferredDays.isNotEmpty)
                    _buildInfoSection(
                      title: 'Schedule & Time',
                      icon: Icons.schedule,
                      children: [
                        if (profile.workoutFrequency != null)
                          _buildInfoRow('Workout Frequency',
                              '${profile.workoutFrequency}x/week'),
                        if (profile.workoutDuration != null)
                          _buildInfoRow('Workout Duration',
                              '${profile.workoutDuration} min'),
                        if (profile.preferredTime != null)
                          _buildInfoRow(
                              'Preferred Time', profile.preferredTime!),
                        if (profile.preferredDays.isNotEmpty)
                          _buildInfoRow('Preferred Days',
                              profile.preferredDays.join(', ')),
                        if (profile.weekendAvailability != null)
                          _buildInfoRow('Weekend Availability',
                              profile.weekendAvailability! ? 'Yes' : 'No'),
                      ],
                    ),
                  if (profile.primaryGoal != null ||
                      profile.targetWeight != null ||
                      profile.motivationLevel != null)
                    _buildInfoSection(
                      title: 'Goals & Motivation',
                      icon: Icons.flag,
                      children: [
                        if (profile.primaryGoal != null)
                          _buildInfoRow('Primary Goal',
                              profile.primaryGoal!.replaceAll('_', ' ')),
                        if (profile.secondaryGoal != null)
                          _buildInfoRow('Secondary Goal',
                              profile.secondaryGoal!.replaceAll('_', ' ')),
                        if (profile.targetWeight != null)
                          _buildInfoRow(
                              'Target Weight', '${profile.targetWeight} kg'),
                        if (profile.targetDate != null)
                          _buildInfoRow(
                              'Target Date', _formatDate(profile.targetDate!)),
                        if (profile.motivationLevel != null)
                          _buildInfoRow(
                              'Motivation Level', profile.motivationLevel!),
                        if (profile.challengePreference != null)
                          _buildInfoRow('Challenge Preference',
                              profile.challengePreference!),
                      ],
                    ),
                  const SizedBox(height: 20),
                  _buildSignOutButton(context, authService),
                  const SizedBox(height: 10),
                  _buildDebugButton(user, context),
                ],
              ),
            ),
    );
  }

  // Keep all your existing helper methods here (_buildProfileHeader, _buildStatsCards, etc.)
  // They remain exactly the same as in your original file

  Widget _buildProfileHeader(User? user, UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'No Email',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Level ${profile.level}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${profile.experiencePoints} XP',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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

  Widget _buildStatsCards(UserProfile profile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '${profile.totalWorkouts}',
            'Workouts',
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${profile.streakDays}',
            'Streak',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${profile.level}',
            'Level',
            Icons.emoji_events,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
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
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await authService.signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error signing out: $e')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Sign Out'),
      ),
    );
  }

  Widget _buildDebugButton(User? user, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (user == null) return;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('onboarding_${user.uid}');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Onboarding flag cleared. Restart the app.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        child: const Text('Reset Onboarding (Debug)'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
