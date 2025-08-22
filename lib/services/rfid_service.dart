import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/access_log_model.dart';
import '../models/user_model.dart';
import '../models/locker_assignment_model.dart';
import '../models/locker_model.dart';
import 'notification_service.dart';
import 'locker_assignment_service.dart';
import 'locker_service.dart';

class RfidService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final LockerAssignmentService _assignmentService = LockerAssignmentService();
  final LockerService _lockerService = LockerService();

  // Simulate RFID card scan and access attempt with new locker assignment logic
  Future<AccessResult> attemptAccess({
    required String rfidUid,
    String? lockerId,
  }) async {
    try {
      final normalizedRfidUid = rfidUid.toUpperCase();
      
      // Step 1: Check if RFID has an active assignment
      final assignment = await _assignmentService.getActiveAssignmentByRfid(normalizedRfidUid);
      
      if (assignment == null) {
        await _logAccess(
          rfidUid: normalizedRfidUid,
          result: AccessResult.denied,
          reason: 'No active locker assignment found for this RFID',
          lockerId: lockerId,
        );
        
        await _notificationService.showAccessDenied(
          reason: 'No locker assignment',
          timestamp: DateTime.now(),
        );
        
        return AccessResult.denied;
      }

      // Step 2: Check if assignment is for the correct locker (if lockerId is specified)
      if (lockerId != null && assignment.lockerId != lockerId) {
        await _logAccess(
          userId: assignment.userId,
          rfidUid: normalizedRfidUid,
          result: AccessResult.denied,
          reason: 'RFID assigned to different locker',
          lockerId: lockerId,
        );
        
        await _notificationService.showAccessDenied(
          reason: 'Wrong locker',
          timestamp: DateTime.now(),
        );
        
        return AccessResult.denied;
      }

      // Step 3: Check if assignment is expired
      if (assignment.isExpired) {
        await _assignmentService.updateAssignmentStatus(assignment.id, AssignmentStatus.expired);
        
        await _logAccess(
          userId: assignment.userId,
          rfidUid: normalizedRfidUid,
          result: AccessResult.denied,
          reason: 'Locker assignment has expired',
          lockerId: assignment.lockerId,
        );
        
        await _notificationService.showAccessDenied(
          reason: 'Assignment expired',
          timestamp: DateTime.now(),
        );
        
        return AccessResult.denied;
      }

      // Step 4: Get user details and check user status
      final userDoc = await _firestore.collection('users').doc(assignment.userId).get();
      
      if (!userDoc.exists) {
        await _logAccess(
          userId: assignment.userId,
          rfidUid: normalizedRfidUid,
          result: AccessResult.denied,
          reason: 'User not found',
          lockerId: assignment.lockerId,
        );
        
        await _notificationService.showAccessDenied(
          reason: 'User not found',
          timestamp: DateTime.now(),
        );
        
        return AccessResult.denied;
      }

      final user = UserModel.fromMap({
        'id': userDoc.id,
        ...userDoc.data()!,
      });

      // Step 5: Check if user account is active
      if (user.status != UserStatus.active) {
        await _logAccess(
          userId: user.id,
          userName: user.name,
          rfidUid: normalizedRfidUid,
          result: AccessResult.denied,
          reason: 'User account is not active',
          lockerId: assignment.lockerId,
        );
        
        await _notificationService.showAccessDenied(
          reason: 'Account not active',
          timestamp: DateTime.now(),
        );
        
        return AccessResult.denied;
      }

      // Step 6: All checks passed - Grant access and unlock locker
      final targetLockerId = lockerId ?? assignment.lockerId;
      
      // Update locker status to occupied
      await _lockerService.updateLockerStatus(targetLockerId, LockerStatus.occupied);
      
      // Log successful access
      await _logAccess(
        userId: user.id,
        userName: user.name,
        rfidUid: normalizedRfidUid,
        result: AccessResult.allowed,
        lockerId: targetLockerId,
      );
      
      // Show success notification
      final locker = await _lockerService.getLockerById(targetLockerId);
      await _notificationService.showAccessSuccess(
        lockerName: locker?.name ?? 'Locker $targetLockerId',
        timestamp: DateTime.now(),
      );
      
      return AccessResult.allowed;
      
    } catch (e) {
      await _logAccess(
        rfidUid: rfidUid.toUpperCase(),
        result: AccessResult.denied,
        reason: 'System error: ${e.toString()}',
        lockerId: lockerId,
      );
      
      await _notificationService.showAccessDenied(
        reason: 'System error',
        timestamp: DateTime.now(),
      );
      
      return AccessResult.denied;
    }
  }

  // Log access attempt
  Future<void> _logAccess({
    String? userId,
    String? userName,
    required String rfidUid,
    required AccessResult result,
    String? reason,
    String? lockerId,
  }) async {
    final log = AccessLog(
      id: '', // Firestore will generate this
      userId: userId ?? 'unknown',
      userName: userName,
      rfidUid: rfidUid,
      result: result,
      reason: reason,
    );

    await _firestore.collection('access_logs').add({
      ...log.toMap(),
      'lockerId': lockerId,
    });
  }

  // Get access logs for a user
  Future<List<AccessLog>> getUserAccessLogs(String userId) async {
    final query = await _firestore
        .collection('access_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();

    return query.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
  }

  // Get all access logs (admin only)
  Future<List<AccessLog>> getAllAccessLogs() async {
    final query = await _firestore
        .collection('access_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();

    return query.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
  }

  // Update user RFID UID
  Future<void> updateUserRfidUid(String userId, String rfidUid) async {
    await _firestore.collection('users').doc(userId).update({
      'rfidUid': rfidUid.toUpperCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}