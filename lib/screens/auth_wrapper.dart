import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_tabs_screen.dart';
import 'login_screen.dart';
import 'intro_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';

/// Decides whether to show intro or auth flow.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  Future<bool> _hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_intro') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSeenIntro(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final hasSeenIntro = snapshot.data ?? false;
        if (!hasSeenIntro) {
          // First launch – show intro slides
          return const IntroScreen();
        } else {
          // Intro already seen – go to auth flow
          return const AuthWrapper();
        }
      },
    );
  }
}

/// Handles authentication and ensures a default profile exists.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        print('👀 AuthWrapper building with user: ${user?.uid ?? 'null'}');

        if (user == null) {
          return const LoginScreen();
        }

        // Schedule default profile creation after the current frame is built.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          if (userProvider.userProfile == null) {
            final defaultProfile = UserProfile(
              uid: user.uid,
              displayName: user.displayName,
              email: user.email,
              age: 30,
              fitnessGoal: 'general_fitness',
              preferredLocation: 'home',
              healthConditions: [],
              dailyTimeAvailable: 15,
              availableEquipment: ['none'],
            );
            userProvider.setUserProfile(defaultProfile);
          }
        });

        // Go directly to main tabs – profile setup will be triggered by the Sports tab.
        return const MainTabsScreen();
      },
    );
  }
}
