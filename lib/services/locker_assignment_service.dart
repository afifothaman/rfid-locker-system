import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/locker_assignment_model.dart';

class LockerAssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new locker assignment
  Future<void> createAssignment({
    required String lockerId,
    required String userId,
    required String rfidUid,
    DateTime? expiresAt,
  }) async {
    final assignment = LockerAssignment(
      id: '', // Firestore will generate this
      lockerId: lockerId,
      userId: userId,
      rfidUid: rfidUid.toUpperCase(),
      status: AssignmentStatus.active,
      expiresAt: expiresAt,
    );

    // Create assignment and update locker status
    await _firestore.collection('lockerAssignments').add(assignment.toMap());
    
    // Update locker status to occupied
    await _firestore.collection('lockers').doc(lockerId).update({
      'status': 'occupied',
      'occupiedAt': FieldValue.serverTimestamp(),
      'lastAccessAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all assignments
  Stream<List<LockerAssignment>> getAllAssignments() {
    return _firestore
        .collection('lockerAssignments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LockerAssignment.fromDoc(doc)).toList();
    });
  }

  // Get assignments for a specific locker
  Stream<List<LockerAssignment>> getLockerAssignments(String lockerId) {
    return _firestore
        .collection('lockerAssignments')
        .where('lockerId', isEqualTo: lockerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LockerAssignment.fromDoc(doc)).toList();
    });
  }

  // Get assignments for a specific user
  Stream<List<LockerAssignment>> getUserAssignments(String userId) {
    return _firestore
        .collection('lockerAssignments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LockerAssignment.fromDoc(doc)).toList();
    });
  }

  // Get active assignment by RFID UID
  Future<LockerAssignment?> getActiveAssignmentByRfid(String rfidUid) async {
    final query = await _firestore
        .collection('lockerAssignments')
        .where('rfidUid', isEqualTo: rfidUid.toUpperCase())
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final assignment = LockerAssignment.fromDoc(query.docs.first);
    
    // Check if assignment is expired
    if (assignment.isExpired) {
      // Auto-expire the assignment
      await updateAssignmentStatus(assignment.id, AssignmentStatus.expired);
      return null;
    }

    return assignment;
  }

  // Update assignment status
  Future<void> updateAssignmentStatus(String assignmentId, AssignmentStatus status) async {
    await _firestore.collection('lockerAssignments').doc(assignmentId).update({
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update assignment expiry
  Future<void> updateAssignmentExpiry(String assignmentId, DateTime? expiresAt) async {
    await _firestore.collection('lockerAssignments').doc(assignmentId).update({
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete assignment
  Future<void> deleteAssignment(String assignmentId) async {
    await _firestore.collection('lockerAssignments').doc(assignmentId).delete();
  }

  // Check if user has active assignment for a locker
  Future<bool> hasActiveAssignment(String userId, String lockerId) async {
    final query = await _firestore
        .collection('lockerAssignments')
        .where('userId', isEqualTo: userId)
        .where('lockerId', isEqualTo: lockerId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;

    final assignment = LockerAssignment.fromDoc(query.docs.first);
    return !assignment.isExpired;
  }

  // Get assignment by ID
  Future<LockerAssignment?> getAssignmentById(String assignmentId) async {
    final doc = await _firestore.collection('lockerAssignments').doc(assignmentId).get();
    if (doc.exists) {
      return LockerAssignment.fromDoc(doc);
    }
    return null;
  }

  // Get active assignments count
  Future<int> getActiveAssignmentsCount() async {
    final query = await _firestore
        .collection('lockerAssignments')
        .where('status', isEqualTo: 'active')
        .get();

    // Filter out expired assignments
    int activeCount = 0;
    for (var doc in query.docs) {
      final assignment = LockerAssignment.fromDoc(doc);
      if (!assignment.isExpired) {
        activeCount++;
      }
    }

    return activeCount;
  }

  // Clean up expired assignments (run periodically)
  Future<void> cleanupExpiredAssignments() async {
    final query = await _firestore
        .collection('lockerAssignments')
        .where('status', isEqualTo: 'active')
        .get();

    final batch = _firestore.batch();
    int updateCount = 0;

    for (var doc in query.docs) {
      final assignment = LockerAssignment.fromDoc(doc);
      if (assignment.isExpired) {
        batch.update(doc.reference, {
          'status': 'expired',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        updateCount++;
      }
    }

    if (updateCount > 0) {
      await batch.commit();
    }
  }

  // Get assignments that expire soon (within 24 hours)
  Future<List<LockerAssignment>> getAssignmentsExpiringSoon() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    
    final query = await _firestore
        .collection('lockerAssignments')
        .where('status', isEqualTo: 'active')
        .where('expiresAt', isLessThanOrEqualTo: Timestamp.fromDate(tomorrow))
        .get();

    return query.docs.map((doc) => LockerAssignment.fromDoc(doc)).toList();
  }

  // Update assignment with multiple fields
  Future<void> updateAssignment(String assignmentId, {
    DateTime? expiresAt,
    AssignmentStatus? status,
    String? rfidUid,
  }) async {
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (expiresAt != null) {
      updates['expiresAt'] = Timestamp.fromDate(expiresAt);
    }

    if (status != null) {
      updates['status'] = status.toString().split('.').last;
    }

    if (rfidUid != null) {
      updates['rfidUid'] = rfidUid.toUpperCase();
    }

    await _firestore.collection('lockerAssignments').doc(assignmentId).update(updates);
  }

}
