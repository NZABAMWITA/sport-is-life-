import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ ADDED
import 'package:onesignal_flutter/onesignal_flutter.dart'; // ✅ ADDED
import 'firebase_options.dart';
import 'services/notification_service.dart';
// Import screens and services
import 'screens/auth_wrapper.dart';
import 'screens/home_screen.dart';
import 'screens/main_tabs_screen.dart'; // ✅ ADDED THIS IMPORT
import 'screens/incoming_call_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_feedback_screen.dart';
import 'screens/admin/admin_push_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/call_service.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize OneSignal
  OneSignal.initialize('d56a0677-47ef-4b19-a29b-367224fd8414');

  // Request permission for notifications
  OneSignal.Notifications.requestPermission(true);

  // Debug logging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // ✅ Initialize notification service with callback
  await NotificationService.initialize(
    onNotificationTap: (payload) {
      print('🔔 Notification tapped with payload: $payload');
      _handleNotificationNavigation(payload);
    },
  );

  runApp(const MyApp());
}

// ✅ Handle navigation when notification is tapped
void _handleNotificationNavigation(String? payload) {
  print('📍 Navigating based on notification: $payload');
  // You can add navigation logic here based on payload
  // For example: if (payload == 'workout') { // navigate to workout screen }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        print('🌍 Global auth state changed: ${user?.uid ?? 'null'}');

        if (user != null) {
          _scheduleNotificationsForUser(user);
          _saveOneSignalId(user); // ✅ Save OneSignal ID
        } else {
          NotificationService.cancelAllNotifications();
          print('🔔 All notifications cancelled on sign out');
        }
      });

      _listenForIncomingCalls(context);
    });

    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'SPORT IS LIFE',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const RootScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/incoming-call': (context) => const IncomingCallScreen(callData: {}),
          '/admin': (context) => const AdminLoginScreen(),
          '/admin/feedback': (context) => const AdminFeedbackScreen(),
          '/admin/push': (context) => const AdminPushScreen(),
        },
      ),
    );
  }

  // ✅ Save OneSignal ID to Firestore
  void _saveOneSignalId(User user) async {
    try {
      final playerId = OneSignal.User.pushSubscription.id;
      if (playerId != null && playerId.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'oneSignalId': playerId,
          'oneSignalIdUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('✅ OneSignal ID saved: $playerId');
      } else {
        print('⚠️ OneSignal player ID not available yet');
      }
    } catch (e) {
      print('❌ Error saving OneSignal ID: $e');
    }
  }

  void _scheduleNotificationsForUser(User user) async {
    print('🔔 Scheduling automatic notifications for user: ${user.uid}');
    await Future.delayed(const Duration(seconds: 1));

    try {
      await NotificationService.scheduleDailyQuoteNotification();
      print('✅ Daily quote notification scheduled for 8:00 AM');

      await NotificationService.scheduleStreakReminder();
      print('✅ Streak reminder scheduled for 6:00 PM');

      await NotificationService.saveFCMTokenToFirestore(user.uid);
      print('✅ FCM token saved to Firestore');

      await NotificationService.sendWelcomeNotification();
      print('✅ Welcome notification sent');
    } catch (e) {
      print('❌ Error scheduling notifications: $e');
    }
  }

  void _listenForIncomingCalls(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    CallService.listenForIncomingCalls().listen((snapshot) {
      if (!snapshot.exists) return;

      final callData = snapshot.data() as Map<String, dynamic>;
      print('📞 Incoming call from: ${callData['fromName']}');

      if (Navigator.canPop(context)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IncomingCallScreen(callData: callData),
          ),
        );
      }
    });
  }
}

// RootScreen - determines if user is logged in or not
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ FIXED: Use MainTabsScreen instead of HomeScreen
    if (authProvider.user != null) {
      return const MainTabsScreen(); // ← CHANGED THIS
    }

    return const AuthWrapper();
  }
}
