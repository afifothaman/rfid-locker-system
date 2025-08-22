import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/locker_model.dart';

class LockerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, Timer> _autoReturnTimers = {};

  // Create a new locker
  Future<void> createLocker({
    required String name,
    required String location,
    LockerStatus status = LockerStatus.available,
  }) async {
    final locker = Locker(
      id: '', // Firestore will generate this
      name: name,
      location: location,
      status: status,
    );

    await _firestore.collection('lockers').add(locker.toMap());
  }

  // Get all lockers
  Stream<List<Locker>> getAllLockers() {
    return _firestore
        .collection('lockers')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Locker.fromDoc(doc)).toList();
    });
  }

  // Get locker by ID
  Future<Locker?> getLockerById(String lockerId) async {
    final doc = await _firestore.collection('lockers').doc(lockerId).get();
    if (doc.exists) {
      return Locker.fromDoc(doc);
    }
    return null;
  }

  // Update locker status
  Future<void> updateLockerStatus(String lockerId, LockerStatus status) async {
    final updateData = {
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // If setting to occupied, record the time
    if (status == LockerStatus.occupied) {
      updateData['occupiedAt'] = FieldValue.serverTimestamp();
      updateData['lastAccessAt'] = FieldValue.serverTimestamp();
      
      // Start auto-return timer (30 minutes)
      _startAutoReturnTimer(lockerId);
    } else if (status == LockerStatus.available) {
      updateData['occupiedAt'] = FieldValue.delete();
      
      // Cancel auto-return timer if exists
      _cancelAutoReturnTimer(lockerId);
    }

    await _firestore.collection('lockers').doc(lockerId).update(updateData);
  }

  // Update locker details
  Future<void> updateLocker(String lockerId, {
    String? name,
    String? location,
    LockerStatus? status,
  }) async {
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) updateData['name'] = name;
    if (location != null) updateData['location'] = location;
    if (status != null) {
      updateData['status'] = status.toString().split('.').last;
      
      // Handle status-specific updates
      if (status == LockerStatus.occupied) {
        updateData['occupiedAt'] = FieldValue.serverTimestamp();
        updateData['lastAccessAt'] = FieldValue.serverTimestamp();
        _startAutoReturnTimer(lockerId);
      } else if (status == LockerStatus.available) {
        updateData['occupiedAt'] = FieldValue.delete();
        _cancelAutoReturnTimer(lockerId);
      }
    }

    await _firestore.collection('lockers').doc(lockerId).update(updateData);
  }

  // Delete locker
  Future<void> deleteLocker(String lockerId) async {
    _cancelAutoReturnTimer(lockerId);
    await _firestore.collection('lockers').doc(lockerId).delete();
  }

  // Get lockers by status
  Stream<List<Locker>> getLockersByStatus(LockerStatus status) {
    return _firestore
        .collection('lockers')
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Locker.fromDoc(doc)).toList();
    });
  }

  // Get available lockers
  Stream<List<Locker>> getAvailableLockers() {
    return getLockersByStatus(LockerStatus.available);
  }

  // Get occupied lockers
  Stream<List<Locker>> getOccupiedLockers() {
    return getLockersByStatus(LockerStatus.occupied);
  }

  // Get locker statistics
  Future<Map<String, int>> getLockerStatistics() async {
    final allLockersQuery = await _firestore.collection('lockers').get();
    
    final stats = <String, int>{
      'total': 0,
      'available': 0,
      'occupied': 0,
      'maintenance': 0,
      'offline': 0,
    };

    for (var doc in allLockersQuery.docs) {
      final locker = Locker.fromDoc(doc);
      stats['total'] = (stats['total'] ?? 0) + 1;
      
      switch (locker.status) {
        case LockerStatus.available:
          stats['available'] = (stats['available'] ?? 0) + 1;
          break;
        case LockerStatus.occupied:
          stats['occupied'] = (stats['occupied'] ?? 0) + 1;
          break;
        case LockerStatus.maintenance:
          stats['maintenance'] = (stats['maintenance'] ?? 0) + 1;
          break;
        case LockerStatus.offline:
          stats['offline'] = (stats['offline'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  // Start auto-return timer for a locker (30 minutes)
  void _startAutoReturnTimer(String lockerId) {
    // Cancel existing timer if any
    _cancelAutoReturnTimer(lockerId);
    
    // Start new timer
    _autoReturnTimers[lockerId] = Timer(const Duration(minutes: 30), () async {
      try {
        await updateLockerStatus(lockerId, LockerStatus.available);
        _autoReturnTimers.remove(lockerId);
      } catch (e) {
        // Handle error silently
      }
    });
  }

  // Cancel auto-return timer for a locker
  void _cancelAutoReturnTimer(String lockerId) {
    final timer = _autoReturnTimers[lockerId];
    if (timer != null) {
      timer.cancel();
      _autoReturnTimers.remove(lockerId);
    }
  }

  // Check and auto-return lockers that should be available (run on app start)
  Future<void> checkAndAutoReturnLockers() async {
    final occupiedQuery = await _firestore
        .collection('lockers')
        .where('status', isEqualTo: 'occupied')
        .get();

    final batch = _firestore.batch();
    int updateCount = 0;

    for (var doc in occupiedQuery.docs) {
      final locker = Locker.fromDoc(doc);
      if (locker.shouldAutoReturn) {
        batch.update(doc.reference, {
          'status': 'available',
          'occupiedAt': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        updateCount++;
      } else if (locker.status == LockerStatus.occupied) {
        // Restart timer for still-occupied lockers
        final remainingTime = locker.occupiedAt!
            .add(const Duration(minutes: 30))
            .difference(DateTime.now());
        
        if (remainingTime.inMilliseconds > 0) {
          Timer(remainingTime, () async {
            try {
              await updateLockerStatus(locker.id, LockerStatus.available);
            } catch (e) {
              // Handle error silently
            }
          });
        }
      }
    }

    if (updateCount > 0) {
      await batch.commit();
    }
  }

  // Get lockers with real-time status based on assignments
  Stream<List<LockerWithStatus>> getLockersWithRealTimeStatus() {
    // Create a stream controller to manually trigger updates
    late StreamController<List<LockerWithStatus>> controller;
    StreamSubscription? lockersSubscription;
    StreamSubscription? assignmentsSubscription;
    
    Future<void> updateData() async {
      try {
        // Get all lockers
        final lockersSnapshot = await _firestore
            .collection('lockers')
            .orderBy('name')
            .get();
        
        List<LockerWithStatus> lockersWithStatus = [];
        
        for (var lockerDoc in lockersSnapshot.docs) {
          final locker = Locker.fromDoc(lockerDoc);
          
          // Check for active assignments
          final assignmentsQuery = await _firestore
              .collection('lockerAssignments')
              .where('lockerId', isEqualTo: locker.id)
              .where('status', isEqualTo: 'active')
              .get();
          
          // Check if there are valid (non-expired) assignments
          bool hasActiveAssignment = false;
          String? occupantName;
          String? occupantRfid;
          DateTime? assignedAt;
          DateTime? expiresAt;
          
          for (var assignmentDoc in assignmentsQuery.docs) {
            final assignmentData = assignmentDoc.data();
            final expiryDate = assignmentData['expiresAt'] as Timestamp?;
            final userId = assignmentData['userId'] as String?;
            
            // Check if assignment is not expired
            if (expiryDate == null || expiryDate.toDate().isAfter(DateTime.now())) {
              hasActiveAssignment = true;
              occupantRfid = assignmentData['rfidUid'] as String?;
              assignedAt = (assignmentData['createdAt'] as Timestamp?)?.toDate();
              expiresAt = expiryDate?.toDate();
              
              // Get user name
              if (userId != null) {
                final userDoc = await _firestore.collection('users').doc(userId).get();
                if (userDoc.exists) {
                  final userData = userDoc.data() as Map<String, dynamic>;
                  occupantName = userData['name'] as String?;
                }
              }
              break; // Take first active assignment
            }
          }
          
          // Determine real status - prioritize assignment-based logic
          LockerStatus realStatus;
          
          // If admin manually set to maintenance or offline, respect that
          if (locker.status == LockerStatus.maintenance || locker.status == LockerStatus.offline) {
            realStatus = locker.status;
          }
          // Otherwise, use assignment-based logic (this is the real status)
          else {
            realStatus = hasActiveAssignment ? LockerStatus.occupied : LockerStatus.available;
          }
          
          lockersWithStatus.add(LockerWithStatus(
            locker: locker,
            realStatus: realStatus,
            occupantName: occupantName ?? 'Not occupied',
            occupantRfid: occupantRfid ?? 'Not occupied',
            assignedAt: assignedAt,
            expiresAt: expiresAt,
          ));
        }
        
        if (!controller.isClosed) {
          controller.add(lockersWithStatus);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }
    
    controller = StreamController<List<LockerWithStatus>>(
      onListen: () {
        // Initial data load first (immediate)
        updateData();
        
        // Then listen to both lockers and assignments changes
        lockersSubscription = _firestore
            .collection('lockers')
            .snapshots()
            .listen((_) => updateData());
            
        assignmentsSubscription = _firestore
            .collection('lockerAssignments')
            .snapshots()
            .listen((_) => updateData());
      },
      onCancel: () {
        lockersSubscription?.cancel();
        assignmentsSubscription?.cancel();
      },
    );
    
    return controller.stream;
  }

  // Dispose all timers (call when app is closing)
  static void disposeAllTimers() {
    for (var timer in _autoReturnTimers.values) {
      timer.cancel();
    }
    _autoReturnTimers.clear();
  }
}

// Helper class to combine locker with real-time status
class LockerWithStatus {
  final Locker locker;
  final LockerStatus realStatus;
  final String occupantName;
  final String occupantRfid;
  final DateTime? assignedAt;
  final DateTime? expiresAt;
  
  LockerWithStatus({
    required this.locker,
    required this.realStatus,
    required this.occupantName,
    required this.occupantRfid,
    this.assignedAt,
    this.expiresAt,
  });
}