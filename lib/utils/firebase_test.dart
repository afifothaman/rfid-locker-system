import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTest {
  static Future<void> testFirebaseConnection() async {
    try {
      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      
      // Try to write a test document
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test successful',
      });
      
      // Test reading the document
      final doc = await firestore.collection('test').doc('connection').get();
      if (!doc.exists) {
        throw Exception('Failed to read test document');
      }
      
      // Clean up test document
      await firestore.collection('test').doc('connection').delete();
      
    } catch (e) {
      throw Exception('Firebase connection test failed: $e');
    }
  }
  
  static Future<void> createTestAccessLog() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      
      final firestore = FirebaseFirestore.instance;
      
      // Get user's actual data from Firestore
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      String userName = 'System Test User';
      String rfidUid = 'SYSTEM_TEST';
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        userName = userData['name'] ?? user.displayName ?? 'System Test User';
        rfidUid = userData['rfidUid'] ?? 'SYSTEM_TEST';
      }
      
      // Create a test access log with actual user data
      await firestore.collection('access_logs').add({
        'userId': user.uid,
        'userName': userName,
        'rfidUid': rfidUid.toUpperCase(),
        'result': 'allowed',
        'action': 'System Connectivity Test',
        'timestamp': FieldValue.serverTimestamp(),
        'reason': 'Firebase connectivity verification',
      });
      
    } catch (e) {
      throw Exception('Failed to create test access log: $e');
    }
  }

  static Future<void> createSampleLockers() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Check if lockers already exist
      final existingLockers = await firestore.collection('lockers').limit(1).get();
      if (existingLockers.docs.isNotEmpty) {
        return; // Lockers already exist, don't create duplicates
      }
      
      // Create sample lockers
      final sampleLockers = [
        {
          'name': 'Locker A1',
          'location': 'Ground Floor - Section A',
          'status': 'available',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Locker A2',
          'location': 'Ground Floor - Section A',
          'status': 'available',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Locker B1',
          'location': 'Ground Floor - Section B',
          'status': 'available',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Locker B2',
          'location': 'Ground Floor - Section B',
          'status': 'maintenance',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Locker C1',
          'location': 'First Floor - Section C',
          'status': 'available',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];
      
      // Add sample lockers to Firestore
      for (final lockerData in sampleLockers) {
        await firestore.collection('lockers').add(lockerData);
      }
      
    } catch (e) {
      throw Exception('Failed to create sample lockers: $e');
    }
  }
  
  static Future<void> createTestUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }
      
      final firestore = FirebaseFirestore.instance;
      
      // Check if user document already exists
      final existingDoc = await firestore.collection('users').doc(user.uid).get();
      
      if (existingDoc.exists) {
        return; // User document already exists
      }
      
      // Create user document with actual user data (only if it doesn't exist)
      await firestore.collection('users').doc(user.uid).set({
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'email': user.email ?? '',
        'ic': '', // Empty - user will fill this in their profile
        'phoneNumber': '', // Empty - user will fill this in their profile
        'rfidUid': '', // Empty - user will get this from staff
        'status': 'pending', // Default status for new users
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: false)); // Don't merge to avoid overwriting existing data
      
    } catch (e) {
      throw Exception('Failed to create test user: $e');
    }
  }
}