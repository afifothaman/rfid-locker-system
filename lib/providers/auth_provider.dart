import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required AuthService authService}) 
    : _authService = authService {
    _init();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Initialize auth state
  Future<void> _init() async {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String ic,
    required String phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        ic: ic,
        phoneNumber: phoneNumber,
      );
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();
      _user = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (_user == null) return;
      
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.updateUserData(userId: _user!.uid, data: data);
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile
  Future<void> updateProfile({String? name}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.updateProfile(name: name);
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get error message from exception
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return error.message ?? 'An error occurred. Please try again.';
      }
    }
    return error.toString();
  }
}
