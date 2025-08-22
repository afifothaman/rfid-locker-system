import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all users (admin only)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Get pending users (admin only)
  Stream<List<UserModel>> getPendingUsers() {
    return _firestore
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Get current user data
  Stream<UserModel?> getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    });
  }

  // Update user status (admin only)
  Future<void> updateUserStatus(String userId, String status) async {
    await _firestore.collection('users').doc(userId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete user (admin only)
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap({
        'id': doc.id,
        ...doc.data()!,
      });
    }
    return null;
  }

  // Search users by name or email
  Stream<List<UserModel>> searchUsers(String query) {
    return _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Get users count by status
  Future<Map<String, int>> getUsersCountByStatus() async {
    final activeQuery = await _firestore
        .collection('users')
        .where('status', isEqualTo: 'active')
        .get();
    
    final pendingQuery = await _firestore
        .collection('users')
        .where('status', isEqualTo: 'pending')
        .get();
    
    final rejectedQuery = await _firestore
        .collection('users')
        .where('status', isEqualTo: 'rejected')
        .get();

    return {
      'active': activeQuery.docs.length,
      'pending': pendingQuery.docs.length,
      'rejected': rejectedQuery.docs.length,
      'total': activeQuery.docs.length + pendingQuery.docs.length + rejectedQuery.docs.length,
    };
  }

  // Check if RFID UID already exists (conflict detection)
  Future<bool> isRfidUidExists(String rfidUid, {String? excludeUserId}) async {
    if (rfidUid.isEmpty) return false;
    
    final normalizedUid = rfidUid.toUpperCase().trim();
    
    final query = await _firestore
        .collection('users')
        .where('rfidUid', isEqualTo: normalizedUid)
        .get();
    
    // If excluding a user (for updates), filter them out
    if (excludeUserId != null) {
      return query.docs.any((doc) => doc.id != excludeUserId);
    }
    
    return query.docs.isNotEmpty;
  }

  // Get user by RFID UID (admin only - returns full details)
  Future<UserModel?> getUserByRfidUid(String rfidUid) async {
    if (rfidUid.isEmpty) return null;
    
    final normalizedUid = rfidUid.toUpperCase().trim();
    
    final query = await _firestore
        .collection('users')
        .where('rfidUid', isEqualTo: normalizedUid)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return UserModel.fromMap({
        'id': doc.id,
        ...doc.data(),
      });
    }
    
    return null;
  }

  // Update user RFID UID with conflict checking (privacy-safe)
  Future<Map<String, dynamic>> updateUserRfidUid(String userId, String rfidUid, {bool isAdmin = false}) async {
    try {
      final normalizedUid = rfidUid.toUpperCase().trim();
      
      // Check if RFID UID already exists (excluding current user)
      final exists = await isRfidUidExists(normalizedUid, excludeUserId: userId);
      
      if (exists) {
        if (isAdmin) {
          // Admin can see full details
          final conflictUser = await getUserByRfidUid(normalizedUid);
          return {
            'success': false,
            'error': 'RFID_UID_EXISTS',
            'message': 'RFID UID "$normalizedUid" is already registered to ${conflictUser?.name ?? "another user"}',
            'conflictUser': conflictUser?.toMap(),
            'showDetails': true,
          };
        } else {
          // Regular users see generic message (privacy-safe)
          return {
            'success': false,
            'error': 'RFID_UID_EXISTS',
            'message': 'RFID UID "$normalizedUid" is already registered to another user',
            'conflictUser': null,
            'showDetails': false,
          };
        }
      }
      
      // Update the RFID UID
      await _firestore.collection('users').doc(userId).update({
        'rfidUid': normalizedUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'success': true,
        'message': 'RFID UID updated successfully',
        'rfidUid': normalizedUid,
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'UPDATE_FAILED',
        'message': 'Failed to update RFID UID: ${e.toString()}',
      };
    }
  }
}