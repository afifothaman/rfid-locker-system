import 'package:cloud_firestore/cloud_firestore.dart';

enum UserStatus { pending, active, rejected }
enum UserRole { user, admin, manager }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? ic;
  final String? phoneNumber;
  final UserStatus status;
  final UserRole role;
  final String? rfidUid;
  final DateTime? expiryDate;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.ic,
    this.phoneNumber,
    this.status = UserStatus.pending,
    this.role = UserRole.user,
    this.rfidUid,
    this.expiryDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'ic': ic,
      'phoneNumber': phoneNumber,
      'status': status.toString().split('.').last,
      'role': role.toString().split('.').last,
      'rfidUid': rfidUid?.toUpperCase(),
      'expiryDate': expiryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      ic: map['ic'],
      phoneNumber: map['phoneNumber'],
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == 'UserStatus.${map['status']}',
        orElse: () => UserStatus.pending,
      ),
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.user,
      ),
      rfidUid: map['rfidUid']?.toString().toUpperCase(),
      expiryDate: map['expiryDate'] != null 
          ? (map['expiryDate'] is String 
              ? DateTime.parse(map['expiryDate']) 
              : (map['expiryDate'] as Timestamp).toDate())
          : null,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is String 
              ? DateTime.parse(map['createdAt']) 
              : (map['createdAt'] as Timestamp).toDate())
          : DateTime.now(),
    );
  }
}
