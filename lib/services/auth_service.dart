import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rfid_locker_system/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  void dispose() {
    // Add any cleanup logic here if needed
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Email & Password Sign Up
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String ic,
    required String phoneNumber,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore with additional fields
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'ic': ic,
          'phoneNumber': phoneNumber,
          'role': 'user',
          'status': 'pending', // New users need admin approval
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        rethrow;
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Clean up the user if Firestore document creation fails
      if (e.code != 'email-already-in-use' && _auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
      rethrow;
    } catch (e) {
      // Clean up the user if any other error occurs
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
      rethrow;
    }
  }

  // Email & Password Sign In
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // CRITICAL: Auto-create/merge user document after login
      // This prevents permission-denied errors in Firestore rules
      if (userCredential.user != null) {
        await _ensureUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }



  // Sign Out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
    ]);
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update User Profile
  Future<void> updateProfile({
    String? name,
  }) async {
    try {
      if (_auth.currentUser == null) return;
      if (name != null) await _auth.currentUser!.updateDisplayName(name);
    } catch (e) {
      rethrow;
    }
  }

  // Get User Data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // CRITICAL: Ensure user document exists after login (auto-healing pattern)
  // This prevents permission-denied errors in Firestore security rules
  Future<void> _ensureUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      // Always merge the 'id' field to fix legacy users and ensure rules work
      await userDoc.set({
        'id': user.uid,  // Critical: UID as both doc ID and field
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      // Log error but don't throw - user should still be able to login
      print('Warning: Could not ensure user document for ${user.uid}: $e');
    }
  }

  // Create or Update User Document in Firestore
  Future<void> _createUserDocument(
    User user, {
    String? name,
    String? email,
    String? photoURL,
  }) async {
    final userDoc = _firestore
        .collection('users')
        .doc(user.uid);

    final userData = {
      'id': user.uid,
      'name': name ?? user.displayName ?? 'User',
      'email': email ?? user.email,
      'photoURL': photoURL ?? user.photoURL,
      'status': 'pending',
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await userDoc.set(userData, SetOptions(merge: true));
  }

  // Update User Data
  Future<void> updateUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }
}
