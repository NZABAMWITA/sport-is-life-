import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppAuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true; // ADDED: Loading state
  late StreamSubscription<User?> _authSubscription;

  AppAuthProvider() {
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print('📣 AppAuthProvider received: ${user?.uid ?? 'null'}');
      _user = user;
      _isLoading = false; // ADDED: Set loading to false when user is received
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading; // ADDED: Getter for loading state

  // ADDED: Method to manually set loading (if needed for sign in/out)
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
