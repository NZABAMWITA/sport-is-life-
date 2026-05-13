import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'notification_service.dart'; // ✅ Add this import

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GoogleSignIn initialization - works on mobile, ignored on web
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // ========== WEB SIGN-IN (using Firebase popup) ==========
        print('🌐 Signing in with Google on Web...');

        // Create a Google provider for web
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        // Sign in with popup (works perfectly on web)
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // ========== MOBILE/EMULATOR SIGN-IN ==========
        print('📱 Signing in with Google on Mobile...');

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          print('❌ Google sign-in canceled by user');
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // For mobile, we need both tokens or at least one
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // ========== COMMON POST-SIGN-IN CODE ==========
      final user = userCredential.user;

      if (user != null) {
        print('✅ Signed in user: ${user.uid}');
        print('✅ Display name: ${user.displayName}');
        print('✅ Email: ${user.email}');
        print('✅ Photo URL: ${user.photoURL}');

        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          print('✅ New user created');
          // ✅ Send welcome notification for new users
          await _triggerNotificationsOnSignIn(user, isNewUser: true);
        } else {
          print('✅ Existing user signed in');
          // ✅ Reschedule notifications for existing users
          await _triggerNotificationsOnSignIn(user, isNewUser: false);
        }
      }

      return user;
    } catch (e) {
      print('❌ Error signing in with Google: $e');
      return null;
    }
  }

  // ✅ NEW: Trigger notifications automatically on sign in
  Future<void> _triggerNotificationsOnSignIn(User user, {bool isNewUser = false}) async {
    print('🔔 Triggering notifications for user: ${user.uid}');
    
    try {
      // Small delay to ensure everything is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Cancel any existing notifications first
      await NotificationService.cancelAllNotifications();
      print('✅ Cleared existing notifications');
      
      // Schedule daily quote notification (8:00 AM)
      await NotificationService.scheduleDailyQuoteNotification();
      print('✅ Daily quote notification scheduled for 8:00 AM');
      
      // Schedule streak reminder (6:00 PM)
      await NotificationService.scheduleStreakReminder();
      print('✅ Streak reminder scheduled for 6:00 PM');
      
      // Save FCM token to Firestore for push notifications
      await NotificationService.saveFCMTokenToFirestore(user.uid);
      print('✅ FCM token saved to Firestore');
      
      // Send welcome notification (only for new users or always)
      if (isNewUser) {
        await NotificationService.sendWelcomeNotification();
        print('✅ Welcome notification sent to new user');
      } else {
        // For returning users, send a "welcome back" notification
        await NotificationService.sendWelcomeBackNotification();
        print('✅ Welcome back notification sent');
      }
      
      // Optional: Schedule weekly summary (Sunday at 7 PM)
      await NotificationService.scheduleWeeklySummary();
      print('✅ Weekly summary scheduled for Sunday');
      
      // Get and log pending notifications count
      final pending = await NotificationService.getPendingNotifications();
      print('📊 Total scheduled notifications: ${pending.length}');
      
    } catch (e) {
      print('❌ Error triggering notifications: $e');
    }
  }

  Future<void> signOut() async {
    try {
      // ✅ Cancel all notifications before signing out
      await NotificationService.cancelAllNotifications();
      print('🔔 All notifications cancelled before sign out');
      
      if (kIsWeb) {
        // Web sign-out (only Firebase)
        await _auth.signOut();
        print('✅ Signed out from web');
      } else {
        // Mobile sign-out (both Google and Firebase)
        await _googleSignIn.signOut();
        await _auth.signOut();
        print('✅ Signed out from mobile');
      }

      final currentUser = _auth.currentUser;
      print('Current user after signOut: ${currentUser?.uid ?? 'null'}');
    } catch (e) {
      print('❌ Sign out error: $e');

      // Emergency sign-out if normal fails
      try {
        await _auth.signOut();
        if (!kIsWeb) {
          await _googleSignIn.disconnect();
        }
        print('✅ Emergency sign-out successful');
      } catch (emergencyError) {
        print('❌ Emergency sign-out also failed: $emergencyError');
      }
    }
  }

  Future<bool> isSignedIn() async {
    if (kIsWeb) {
      // On web, just check Firebase
      return _auth.currentUser != null;
    } else {
      // On mobile, check both
      final currentUser = _auth.currentUser;
      final isGoogleSignedIn = await _googleSignIn.isSignedIn();

      print(
          'Auth status - Firebase: ${currentUser != null}, Google: $isGoogleSignedIn');

      return currentUser != null && isGoogleSignedIn;
    }
  }

  Future<User?> getCurrentUser({bool forceRefresh = false}) async {
    if (forceRefresh) {
      return await _auth.currentUser?.reload().then((_) => _auth.currentUser);
    }
    return _auth.currentUser;
  }

  Future<User?> signInWithGoogleWithErrorHandling() async {
    try {
      return await signInWithGoogle();
    } catch (e) {
      print('❌ Sign-in error handled: $e');

      try {
        if (kIsWeb) {
          await _auth.signOut();
        } else {
          await _googleSignIn.signOut();
          await _auth.signOut();
        }
        print('✅ Reset auth state, please try again');
      } catch (resetError) {
        print('❌ Could not reset auth state: $resetError');
      }

      return null;
    }
  }
}