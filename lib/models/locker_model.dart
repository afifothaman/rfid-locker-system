import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum LockerStatus { available, occupied, maintenance, offline }

class Locker {
  final String id;
  final String name;
  final String location;
  final LockerStatus status;
  final DateTime? occupiedAt;
  final DateTime? lastAccessAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Locker({
    required this.id,
    required this.name,
    required this.location,
    this.status = LockerStatus.available,
    this.occupiedAt,
    this.lastAccessAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'status': status.toString().split('.').last,
      'occupiedAt': occupiedAt != null ? Timestamp.fromDate(occupiedAt!) : null,
      'lastAccessAt': lastAccessAt != null ? Timestamp.fromDate(lastAccessAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create from Map
  factory Locker.fromMap(Map<String, dynamic> map) {
    return Locker(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      status: LockerStatus.values.firstWhere(
        (e) => e.toString() == 'LockerStatus.${map['status']}',
        orElse: () => LockerStatus.available,
      ),
      occupiedAt: map['occupiedAt'] != null 
          ? (map['occupiedAt'] as Timestamp).toDate()
          : null,
      lastAccessAt: map['lastAccessAt'] != null 
          ? (map['lastAccessAt'] as Timestamp).toDate()
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
  factory Locker.fromDoc(DocumentSnapshot doc) {
    return Locker.fromMap({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  // Check if locker should auto-return to available (after 30 minutes)
  bool get shouldAutoReturn {
    if (status != LockerStatus.occupied || occupiedAt == null) return false;
    final thirtyMinutesAgo = DateTime.now().subtract(const Duration(minutes: 30));
    return occupiedAt!.isBefore(thirtyMinutesAgo);
  }

  // Copy with method for updates
  Locker copyWith({
    String? id,
    String? name,
    String? location,
    LockerStatus? status,
    DateTime? occupiedAt,
    DateTime? lastAccessAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Locker(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      occupiedAt: occupiedAt ?? this.occupiedAt,
      lastAccessAt: lastAccessAt ?? this.lastAccessAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Get status color for UI
  static getStatusColor(LockerStatus status) {
    switch (status) {
      case LockerStatus.available:
        return const Color(0xFF4CAF50); // Green
      case LockerStatus.occupied:
        return const Color(0xFFFF9800); // Orange
      case LockerStatus.maintenance:
        return const Color(0xFFF44336); // Red
      case LockerStatus.offline:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Get status display name
  static String getStatusDisplayName(LockerStatus status) {
    switch (status) {
      case LockerStatus.available:
        return 'Available';
      case LockerStatus.occupied:
        return 'Occupied';
      case LockerStatus.maintenance:
        return 'Maintenance';
      case LockerStatus.offline:
        return 'Offline';
    }
  }
}

