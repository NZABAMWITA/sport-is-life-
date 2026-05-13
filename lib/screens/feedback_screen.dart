import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Color scheme
  final Color _primaryColor = const Color(0xFF6C63FF); // Purple
  final Color _secondaryColor = const Color(0xFFFF6B6B); // Coral
  final Color _successColor = const Color(0xFF4CAF50); // Green
  final Color _backgroundColor = const Color(0xFFF8F9FA); // Light background

  // Feedback form controllers
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  int _rating = 5;
  String _feedbackType = 'Suggestion';
  final List<XFile> _attachedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feedbackController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.userProfile;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Feedback & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
          tabs: const [
            Tab(text: '📝 Feedback', icon: Icon(Icons.feedback)),
            Tab(text: '❓ Help', icon: Icon(Icons.help)),
          ],
        ),
      ),
      body: profile == null
          ? _buildEmptyProfile()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFeedbackTab(profile),
                _buildHelpTab(profile),
              ],
            ),
    );
  }

  // ==================== TAB 1: FEEDBACK FORM ====================
  Widget _buildFeedbackTab(UserProfile profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryColor, _primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'We Value Your Feedback!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help us improve SPORT IS LIFE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Feedback Type
          const Text(
            'Feedback Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              'Suggestion',
              'Bug Report',
              'Feature Request',
              'Compliment',
              'Question',
            ].map((type) {
              final isSelected = _feedbackType == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _feedbackType = type;
                  });
                },
                selectedColor: _primaryColor,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Subject
          const Text(
            'Subject',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _subjectController,
            decoration: InputDecoration(
              hintText: 'Brief summary of your feedback',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // Rating
          const Text(
            'Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),

          const SizedBox(height: 20),

          // Feedback Details
          const Text(
            'Your Feedback',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _feedbackController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Tell us more...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          // Attach Images Section
          const Text(
            'Attach Images (optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAddImageButton(),
                ..._attachedImages.map((image) => _buildImagePreview(image)),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: HELP CENTER ====================
  Widget _buildHelpTab(UserProfile profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // FAQ Section
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(
          'How do I reset my progress?',
          'Go to Profile → Settings → Reset Progress',
        ),
        _buildFAQItem(
          'Can I use the app offline?',
          'Yes! Downloaded workouts and nutrition tips work offline.',
        ),
        _buildFAQItem(
          'How are exercises recommended?',
          'Our AI analyzes your profile, health conditions, and goals to suggest personalized workouts.',
        ),
        _buildFAQItem(
          'How do I contact support?',
          'Use the Feedback tab to send us a message.',
        ),

        const SizedBox(height: 24),

        // Contact Support
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@sportislife.com'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email support coming soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text('Live Chat'),
                  subtitle: const Text('24/7 Support'),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Live chat coming soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Report a Problem
        Card(
          elevation: 0,
          color: Colors.red.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Report a Problem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you encountered a bug or issue, please let us know',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _tabController.animateTo(0);
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('Report Issue'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child:
            const Icon(Icons.add_photo_alternate, color: Colors.grey, size: 32),
      ),
    );
  }

  Widget _buildImagePreview(XFile image) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(image.path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _attachedImages.remove(image);
              });
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feedback, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Complete your profile first',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up your profile to send feedback',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _attachedImages.add(image);
        });
      }
    } catch (e) {
      debugPrint("❌ Error picking image: $e");
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return imageUrls;

    for (int i = 0; i < _attachedImages.length; i++) {
      final image = _attachedImages[i];
      final fileName =
          'feedback_${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('feedback_images')
          .child(fileName);

      try {
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
        print('✅ Uploaded image $i: $url');
      } catch (e) {
        print('❌ Error uploading image $i: $e');
      }
    }

    return imageUrls;
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.isEmpty || _subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Show uploading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Submitting Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              if (_attachedImages.isNotEmpty)
                Text('Uploading ${_attachedImages.length} images...'),
              const Text('Please wait...'),
            ],
          ),
        ),
      );

      // Upload images to Firebase Storage
      List<String> imageUrls = await _uploadImages();

      // Save to Firestore with image URLs
      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userEmail': user.email ?? '',
        'type': _feedbackType,
        'subject': _subjectController.text,
        'feedback': _feedbackController.text,
        'rating': _rating,
        'imageUrls': imageUrls, // ✅ Store actual image URLs
        'attachments': imageUrls.length,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'isRead': false,
        'isReplied': false,
      });

      // Close dialog
      if (mounted) Navigator.pop(context);

      // Clear form
      _feedbackController.clear();
      _subjectController.clear();
      setState(() {
        _rating = 5;
        _feedbackType = 'Suggestion';
        _attachedImages.clear();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            imageUrls.isNotEmpty
                ? 'Thank you! Feedback with ${imageUrls.length} images sent.'
                : 'Thank you for your feedback!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Optional: Send notification to coaches
      await _notifyCoaches(imageUrls.length);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting feedback: $e'),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("❌ Error submitting feedback: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _notifyCoaches(int imageCount) async {
    try {
      final coaches = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'coach')
          .get();

      // This will be implemented with OneSignal in the admin panel
      print(
          '✅ Would notify ${coaches.docs.length} coaches about feedback with $imageCount images');
    } catch (e) {
      print('❌ Error notifying coaches: $e');
    }
  }
}
