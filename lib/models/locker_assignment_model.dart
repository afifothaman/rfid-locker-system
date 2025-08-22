import 'package:cloud_firestore/cloud_firestore.dart';

enum AssignmentStatus { active, expired }

class LockerAssignment {
  final String id;
  final String lockerId;
  final String userId;
  final String rfidUid;
  final AssignmentStatus status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LockerAssignment({
    required this.id,
    required this.lockerId,
    required this.userId,
    required this.rfidUid,
    this.status = AssignmentStatus.active,
    this.expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lockerId': lockerId,
      'userId': userId,
      'rfidUid': rfidUid.toUpperCase(),
      'status': status.toString().split('.').last,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Map
  factory LockerAssignment.fromMap(Map<String, dynamic> map) {
    return LockerAssignment(
      id: map['id'] ?? '',
      lockerId: map['lockerId'] ?? '',
      userId: map['userId'] ?? '',
      rfidUid: (map['rfidUid'] ?? '').toString().toUpperCase(),
      status: AssignmentStatus.values.firstWhere(
        (e) => e.toString() == 'AssignmentStatus.${map['status']}',
        orElse: () => AssignmentStatus.expired,
      ),
      expiresAt: map['expiresAt'] != null 
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Create from DocumentSnapshot
  factory LockerAssignment.fromDoc(DocumentSnapshot doc) {
    return LockerAssignment.fromMap({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  // Check if assignment is expired
  bool get isExpired {
    if (status == AssignmentStatus.expired) return true;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Check if assignment is active and not expired
  bool get isActiveAndValid {
    return status == AssignmentStatus.active && !isExpired;
  }

  // Copy with method for updates
  LockerAssignment copyWith({
    String? id,
    String? lockerId,
    String? userId,
    String? rfidUid,
    AssignmentStatus? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LockerAssignment(
      id: id ?? this.id,
      lockerId: lockerId ?? this.lockerId,
      userId: userId ?? this.userId,
      rfidUid: rfidUid ?? this.rfidUid,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}