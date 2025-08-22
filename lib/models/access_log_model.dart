import 'package:cloud_firestore/cloud_firestore.dart';

enum AccessResult { allowed, denied }

class AccessLog {
  final String id;
  final String userId;
  final String? userName;
  final String? rfidUid;
  final DateTime timestamp;
  final AccessResult result;
  final String? reason;

  AccessLog({
    required this.id,
    required this.userId,
    this.userName,
    this.rfidUid,
    DateTime? timestamp,
    required this.result,
    this.reason,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rfidUid': rfidUid,
      'timestamp': Timestamp.fromDate(timestamp),
      'result': result.toString().split('.').last,
      'reason': reason,
    };
  }

  // Create from Map
  factory AccessLog.fromMap(Map<String, dynamic> map) {
    return AccessLog(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      rfidUid: map['rfidUid'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      result: AccessResult.values.firstWhere(
        (e) => e.toString() == 'AccessResult.${map['result']}',
        orElse: () => AccessResult.denied,
      ),
      reason: map['reason'],
    );
  }

  // Create from DocumentSnapshot
  factory AccessLog.fromDoc(DocumentSnapshot doc) {
    return AccessLog.fromMap({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }
}
