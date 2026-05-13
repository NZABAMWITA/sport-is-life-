import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPushScreen extends StatefulWidget {
  const AdminPushScreen({super.key});

  @override
  State<AdminPushScreen> createState() => _AdminPushScreenState();
}

class _AdminPushScreenState extends State<AdminPushScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isSending = false;
  String _selectedTarget = 'all';
  String _selectedType = 'general';

  // ✅ OneSignal Configuration
  // Get these from: OneSignal Dashboard → Settings → Keys & IDs
  final String _oneSignalAppId = 'd56a0677-47ef-4b19-a29b-367224fd8414';
  final String _oneSignalApiKey =
      'os_v2_app_2vvam52h55frtiu3gzzcj7mecr7loequkxbuudmeqac5bvs4cwqp2oxqybeqjcm6enqlvc2lefu2pf6cgi5qiriezclhvx4yjry53ia';

  final List<Map<String, String>> _typeOptions = [
    {'value': 'general', 'label': 'General', 'icon': '📢'},
    {'value': 'workout', 'label': 'Workout', 'icon': '💪'},
    {'value': 'achievement', 'label': 'Achievement', 'icon': '🏆'},
    {'value': 'reminder', 'label': 'Reminder', 'icon': '⏰'},
    {'value': 'motivation', 'label': 'Motivation', 'icon': '✨'},
  ];

  Future<void> _sendPushNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill title and body')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // Get users based on target
      QuerySnapshot usersSnapshot;
      if (_selectedTarget == 'all') {
        usersSnapshot =
            await FirebaseFirestore.instance.collection('users').get();
      } else if (_selectedTarget == 'coaches') {
        usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'coach')
            .get();
      } else {
        usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .get();
      }

      // ✅ Collect OneSignal IDs (not FCM tokens)
      List<String> oneSignalIds = [];
      for (var doc in usersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final oneSignalId = data['oneSignalId'];
        if (oneSignalId != null &&
            oneSignalId is String &&
            oneSignalId.isNotEmpty) {
          oneSignalIds.add(oneSignalId);
        }
      }

      if (oneSignalIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No OneSignal IDs found. Users need to open the app first.'),
          ),
        );
        setState(() => _isSending = false);
        return;
      }

      // Show sending dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Sending Notifications'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Sending to ${oneSignalIds.length} devices...'),
            ],
          ),
        ),
      );

      // ✅ Send via OneSignal API
      final success = await _sendToOneSignal(
        oneSignalIds: oneSignalIds,
        title: _titleController.text,
        body: _bodyController.text,
        type: _selectedType,
      );

      // Close dialog
      if (mounted) Navigator.pop(context);

      // Show result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '✅ Sent to ${oneSignalIds.length} devices!'
                : '❌ Failed to send notifications'),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (success) {
        // Save to notification history
        await _saveToNotificationHistory(oneSignalIds.length);

        // Clear form
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ✅ Send using OneSignal API (simpler than FCM)
  Future<bool> _sendToOneSignal({
    required List<String> oneSignalIds,
    required String title,
    required String body,
    required String type,
  }) async {
    const String url = 'https://onesignal.com/api/v1/notifications';

    final Map<String, dynamic> payload = {
      'app_id': _oneSignalAppId,
      'include_player_ids': oneSignalIds,
      'contents': {'en': body},
      'headings': {'en': title},
      'data': {'type': type},
      'android_channel_id': 'sport_is_life_channel',
      'priority': 10,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_oneSignalApiKey',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ OneSignal notification sent: ${responseData['id']}');
        return true;
      } else {
        print('❌ OneSignal error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending to OneSignal: $e');
      return false;
    }
  }

  Future<void> _saveToNotificationHistory(int recipientCount) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('notification_history').add({
        'title': _titleController.text,
        'body': _bodyController.text,
        'target': _selectedTarget,
        'type': _selectedType,
        'sentBy': user?.uid,
        'sentByName': user?.displayName,
        'recipientCount': recipientCount,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Saved to notification history');
    } catch (e) {
      print('❌ Error saving history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Push Notification'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Target selection
              const Text('Target Audience',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All Users')),
                  ButtonSegment(value: 'coaches', label: Text('Coaches')),
                  ButtonSegment(value: 'users', label: Text('Regular Users')),
                ],
                selected: {_selectedTarget},
                onSelectionChanged: (Set<String> selection) {
                  setState(() => _selectedTarget = selection.first);
                },
              ),

              const SizedBox(height: 20),

              // Notification type
              const Text('Notification Type',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _typeOptions.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return FilterChip(
                    label: Text('${type['icon']} ${type['label']}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedType = type['value']!);
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Title field
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Notification Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),

              // Body field
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Notification Body',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Send button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendPushNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Send Notification'),
                ),
              ),

              const SizedBox(height: 20),

              // Info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'OneSignal Push Notifications',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.key, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Replace "YOUR_ONESIGNAL_REST_API_KEY" with your REST API Key from OneSignal Dashboard',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'OneSignal App ID is already configured: d56a0677-47ef-4b19-a29b-367224fd8414',
                            style: TextStyle(fontSize: 12, color: Colors.green),
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
    );
  }
}
