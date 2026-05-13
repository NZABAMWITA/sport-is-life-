import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    _saveToFirestore(); // ✅ Save to Firestore
    _saveToPrefs(); // ✅ Local backup
    notifyListeners();
  }

  void updateProfile(UserProfile updatedProfile) {
    _userProfile = updatedProfile;
    _saveToFirestore(); // ✅ Save to Firestore
    _saveToPrefs(); // ✅ Local backup
    notifyListeners();
  }

  void logWorkout(int minutes) {
    if (_userProfile != null) {
      _userProfile!.logWorkout(minutes);
      _saveToFirestore(); // ✅ Save to Firestore
      _saveToPrefs();
      notifyListeners();
    }
  }

  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }

  // ✅ NEW: Save profile to Firestore
  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _userProfile == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(_userProfile!.toJson(), SetOptions(merge: true));
      print('✅ Profile saved to Firestore for user: ${user.uid}');
    } catch (e) {
      print('❌ Error saving profile to Firestore: $e');
    }
  }

  // ✅ NEW: Load profile from Firestore (primary) or SharedPreferences (backup)
  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // First, try to load from Firestore
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _userProfile = UserProfile.fromJson(data);
          print('✅ Profile loaded from Firestore for user: $uid');
        }
      } else {
        // If not in Firestore, try SharedPreferences
        await _loadFromPrefs(uid);
      }
    } catch (e) {
      print('❌ Error loading from Firestore: $e');
      // Fallback to SharedPreferences
      await _loadFromPrefs(uid);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Keep SharedPreferences as backup (offline fallback)
  Future<void> _saveToPrefs() async {
    if (_userProfile == null) return;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_userProfile!.toJson());
    await prefs.setString('user_profile_${_userProfile!.uid}', jsonString);
  }

  Future<void> _loadFromPrefs(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user_profile_$uid');
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _userProfile = UserProfile.fromJson(json);
        print('✅ Profile loaded from SharedPreferences for user: $uid');

        // Sync to Firestore if loaded from local
        if (_userProfile != null) {
          await _saveToFirestore();
        }
      } catch (e) {
        print('Error loading profile from SharedPreferences: $e');
      }
    } else {
      print('⚠️ No profile found for user: $uid');
    }
  }
}
