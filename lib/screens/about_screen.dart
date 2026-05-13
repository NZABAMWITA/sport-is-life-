import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _appVersion = '1.0.0';
  String _buildNumber = '1';
  String? _userRole;

  // Color scheme
  final Color _primaryColor = const Color(0xFF6C63FF); // Purple
  final Color _secondaryColor = const Color(0xFFFF6B6B); // Coral
  final Color _accentColor = const Color(0xFF4ECDC4); // Mint
  final Color _backgroundColor = const Color(0xFFF8F9FA); // Light background

  // Social media links
  final Map<String, String> _socialLinks = {
    'website': 'https://www.sportislife.app',
    'twitter': 'https://twitter.com/sportislife',
    'instagram': 'https://instagram.com/sportislife',
    'facebook': 'https://facebook.com/sportislife',
    'github': 'https://github.com/clement2599/sport_is_life',
    'youtube': 'https://youtube.com/@sportislife',
  };

  // REAL TEAM MEMBERS - Updated with Clement as lead
  final List<Map<String, String>> _teamMembers = [
    {
      'name': 'Clement NZABAMWITA',
      'role': 'Lead Developer & Founder',
      'email': 'nzabamwitaclement9@gmail.com',
      'avatar': 'C',
      'color': '#6C63FF',
      'bio':
          'Flutter developer passionate about creating fitness solutions that help people live healthier lives.',
      'github': 'clement2599',
      'twitter': '@clement_dev',
    },
    {
      'name': 'Dr. Marie Uwase',
      'role': 'Fitness & Nutrition Expert',
      'email': 'marie.uwase@sportislife.rw',
      'avatar': 'M',
      'color': '#FF6B6B',
      'bio':
          'Certified nutritionist and personal trainer with 10+ years of experience in health coaching.',
      'github': 'marieu',
      'twitter': '@dr_marie',
    },
    {
      'name': 'Jean Paul Habimana',
      'role': 'UI/UX Designer',
      'email': 'jp.habimana@sportislife.rw',
      'avatar': 'J',
      'color': '#4ECDC4',
      'bio':
          'Creative designer focused on making fitness tracking beautiful and intuitive for all users.',
      'github': 'jphabimana',
      'twitter': '@jp_design',
    },
    {
      'name': 'Diane Ishimwe',
      'role': 'Mobile Developer',
      'email': 'diane.ishimwe@sportislife.rw',
      'avatar': 'D',
      'color': '#FFB347',
      'bio':
          'Flutter developer specializing in performance optimization and smooth user experiences.',
      'github': 'dianeish',
      'twitter': '@diane_dev',
    },
  ];

  // Features list
  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.fitness_center,
      'title': 'Personalized Workouts',
      'description':
          'AI-powered exercise recommendations based on your profile',
      'color': Colors.blue,
    },
    {
      'icon': Icons.track_changes,
      'title': 'Progress Tracking',
      'description': 'Detailed charts and statistics of your fitness journey',
      'color': Colors.green,
    },
    {
      'icon': Icons.restaurant,
      'title': 'Nutrition Guide',
      'description': 'Personalized meal plans and nutrition tips',
      'color': Colors.orange,
    },
    {
      'icon': Icons.emoji_events,
      'title': 'Achievements',
      'description': 'Earn badges and rewards for your milestones',
      'color': Colors.purple,
    },
    {
      'icon': Icons.alarm,
      'title': 'Smart Reminders',
      'description': 'Get notified about workouts, water, and more',
      'color': Colors.teal,
    },
    {
      'icon': Icons.flag,
      'title': 'Goal Setting',
      'description': 'Set and track your fitness goals',
      'color': Colors.red,
    },
  ];

  // Real testimonials (can be updated with real user feedback)
  final List<Map<String, String>> _testimonials = [
    {
      'name': 'Alice Mukamana',
      'role': 'Premium User - Kigali',
      'text':
          'This app transformed my fitness journey! The personalized workouts are amazing.',
      'rating': '5',
      'avatar': 'A',
    },
    {
      'name': 'Peter Kagame',
      'role': 'Athlete - Musanze',
      'text':
          'Best fitness app I\'ve ever used. The progress tracking keeps me motivated!',
      'rating': '5',
      'avatar': 'P',
    },
    {
      'name': 'Grace Uwimana',
      'role': 'Yoga Instructor - Rubavu',
      'text':
          'The nutrition tips and meal plans are incredibly helpful. 10/10 recommend!',
      'rating': '5',
      'avatar': 'G',
    },
  ];

  // FAQ items
  final List<Map<String, String>> _faqItems = [
    {
      'question': 'How do I reset my progress?',
      'answer':
          'Go to Settings > Profile > Reset Progress. This will clear your workout history but keep your profile settings.',
    },
    {
      'question': 'Can I use the app offline?',
      'answer':
          'Yes! You can access saved exercises and track workouts offline. New content requires internet connection.',
    },
    {
      'question': 'Is my data secure?',
      'answer':
          'Absolutely! We use Firebase secure authentication and encryption to protect your personal information.',
    },
    {
      'question': 'How are exercises recommended?',
      'answer':
          'Our AI analyzes your age, health conditions, goals, and preferences to suggest the most suitable exercises.',
    },
    {
      'question': 'Can I sync across devices?',
      'answer':
          'Yes! Sign in with Google on any device to sync your progress automatically.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadAppInfo();
    _checkUserRole();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      print('Could not load package info: $e');
    }
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      _userRole = userDoc['role'] ?? 'user';
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'SPORT IS LIFE App Inquiry'},
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch email app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToAdmin() {
    Navigator.pushNamed(context, '/admin');
  }

  @override
  Widget build(BuildContext context) {
    final isCoach = _userRole == 'coach' || _userRole == 'admin';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareApp(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Logo and Name
            _buildAppHeader(),

            const SizedBox(height: 24),

            // App Stats
            _buildAppStats(),

            const SizedBox(height: 16),

            // NEW: Admin Panel Button (Only for Coaches)
            if (isCoach) _buildAdminPanelButton(),

            const SizedBox(height: 24),

            // Features Grid
            _buildFeaturesSection(),

            const SizedBox(height: 24),

            // Team Section
            _buildTeamSection(),

            const SizedBox(height: 24),

            // Testimonials
            _buildTestimonialsSection(),

            const SizedBox(height: 24),

            // FAQ Section
            _buildFAQSection(),

            const SizedBox(height: 24),

            // Social Links
            _buildSocialLinks(),

            const SizedBox(height: 24),

            // Rate App Card
            _buildRateAppCard(),

            const SizedBox(height: 24),

            // Legal Links
            _buildLegalLinks(),

            const SizedBox(height: 24),

            // Version Info
            _buildVersionInfo(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // NEW: Admin Panel Button Widget
  Widget _buildAdminPanelButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: _navigateToAdmin,
        icon: const Icon(Icons.admin_panel_settings, size: 24),
        label: const Text(
          'Coach Admin Panel',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _secondaryColor],
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
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_soccer,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'SPORT IS LIFE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version $_appVersion ($_buildNumber)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your personal fitness companion for all ages and abilities. '
            'Get personalized workouts, track progress, and achieve your fitness goals.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              '120+', 'Exercises', Icons.fitness_center, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('10k+', 'Users', Icons.people, Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('4.8', 'Rating', Icons.star, Colors.amber),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
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
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star, color: _primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Key Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _features.length,
          itemBuilder: (context, index) {
            final feature = _features[index];
            return Container(
              padding: const EdgeInsets.all(12),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (feature['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      feature['icon'],
                      color: feature['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feature['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature['description'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTeamSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.people, color: _secondaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Meet the Team',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _teamMembers.length,
          itemBuilder: (context, index) {
            final member = _teamMembers[index];
            return Container(
              padding: const EdgeInsets.all(12),
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
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(int.parse(
                              member['color']!.replaceFirst('#', '0xff'))),
                          Color(int.parse(
                                  member['color']!.replaceFirst('#', '0xff')))
                              .withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        member['avatar']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member['name']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    member['role']!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => _launchEmail(member['email']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email, size: 10, color: Colors.blue),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'User Reviews',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ..._testimonials.map((testimonial) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      testimonial['avatar']!,
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            testimonial['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 10, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  testimonial['rating']!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        testimonial['text']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        testimonial['role']!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.help, color: _accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _faqItems.length,
          itemBuilder: (context, index) {
            final faq = _faqItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: _accentColor.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: _accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    faq['question']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        faq['answer']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSocialLinks() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Connect With Us',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                Icons.language,
                'Website',
                Colors.blue,
                _socialLinks['website']!,
              ),
              _buildSocialButton(
                Icons.alternate_email,
                'Twitter',
                Colors.lightBlue,
                _socialLinks['twitter']!,
              ),
              _buildSocialButton(
                Icons.photo_camera,
                'Instagram',
                Colors.purple,
                _socialLinks['instagram']!,
              ),
              _buildSocialButton(
                Icons.facebook,
                'Facebook',
                Colors.indigo,
                _socialLinks['facebook']!,
              ),
              _buildSocialButton(
                Icons.code,
                'GitHub',
                Colors.black87,
                _socialLinks['github']!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      IconData icon, String label, Color color, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Column(
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
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateAppCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Love SPORT IS LIFE?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your rating helps us improve and reach more people!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _rateApp(),
                icon: const Icon(Icons.star),
                label: const Text('Rate Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _shareApp(),
                icon: const Icon(Icons.share, color: Colors.white),
                label:
                    const Text('Share', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
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

  Widget _buildLegalLinks() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => _showLegalDialog('Privacy Policy'),
            child: const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const Text('•', style: TextStyle(color: Colors.grey)),
          TextButton(
            onPressed: () => _showLegalDialog('Terms of Service'),
            child: const Text(
              'Terms of Service',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const Text('•', style: TextStyle(color: Colors.grey)),
          TextButton(
            onPressed: () => _showLegalDialog('Licenses'),
            child: const Text(
              'Licenses',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '© 2024 SPORT IS LIFE',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Made with ❤️ in Rwanda',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showLegalDialog(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
              'This is a placeholder for the $title. In a real app, this would contain the full legal document.\n\n'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for rating SPORT IS LIFE! ⭐'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareApp() async {
    const String shareText = '''
🏋️ **SPORT IS LIFE** - Your Personal Fitness Companion!

Join me on SPORT IS LIFE, the ultimate fitness app created by Clement NZABAMWITA and team that provides:
✅ Personalized workouts based on your profile
✅ Progress tracking with beautiful charts
✅ Nutrition tips and meal plans
✅ Smart reminders and goals
✅ 120+ exercises with video tutorials

Download now and start your fitness journey! 💪

https://play.google.com/store/apps/details?id=com.sport_is_life
''';

    try {
      await Share.share(
        shareText,
        subject: 'Check out SPORT IS LIFE app!',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
