import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/locker_model.dart';
import '../../models/locker_assignment_model.dart';
import '../../services/locker_service.dart';
import '../../services/locker_assignment_service.dart';
import '../../services/user_service.dart';

class UserLockersScreen extends StatefulWidget {
  const UserLockersScreen({Key? key}) : super(key: key);

  @override
  State<UserLockersScreen> createState() => _UserLockersScreenState();
}

class _UserLockersScreenState extends State<UserLockersScreen> {
  final LockerService _lockerService = LockerService();
  final LockerAssignmentService _assignmentService = LockerAssignmentService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.storage, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'Available Lockers',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildMyCurrentBooking(),
          _buildSearchBar(),
          Expanded(child: _buildLockersList()),
        ],
      ),
    );
  }

  Widget _buildMyCurrentBooking() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<List<LockerAssignment>>(
      stream: _assignmentService.getUserAssignments(currentUser.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final activeAssignments = snapshot.data!
            .where((assignment) => assignment.isActiveAndValid)
            .toList();
            
        if (activeAssignments.isEmpty) return const SizedBox.shrink();
        
        final assignment = activeAssignments.first;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'My Current Booking',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<Locker?>(
                future: _lockerService.getLockerById(assignment.lockerId),
                builder: (context, lockerSnapshot) {
                  final lockerName = lockerSnapshot.data?.name ?? 'Unknown Locker';
                  final lockerLocation = lockerSnapshot.data?.location ?? 'Unknown Location';
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lockerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lockerLocation,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (assignment.expiresAt != null) ...[
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Expires: ${_formatDateTime(assignment.expiresAt!)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: assignment.expiresAt!.isBefore(DateTime.now().add(const Duration(hours: 2)))
                                    ? Colors.red[700]
                                    : Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showReleaseConfirmation(assignment),
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text('Release Early'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search lockers by name or location...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildLockersList() {
    return StreamBuilder<List<LockerWithStatus>>(
      stream: _lockerService.getLockersWithRealTimeStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading lockers: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final lockers = snapshot.data ?? [];
        
        // Filter lockers based on search query
        final filteredLockers = lockers.where((lockerWithStatus) {
          final name = lockerWithStatus.locker.name.toLowerCase();
          final location = lockerWithStatus.locker.location.toLowerCase();
          return name.contains(_searchQuery) || location.contains(_searchQuery);
        }).toList();
        
        if (filteredLockers.isEmpty) {
          return const Center(
            child: Text('No lockers found'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredLockers.length,
          itemBuilder: (context, index) {
            final lockerWithStatus = filteredLockers[index];
            return _buildLockerCard(lockerWithStatus);
          },
        );
      },
    );
  }

  Widget _buildLockerCard(LockerWithStatus lockerWithStatus) {
    final locker = lockerWithStatus.locker;
    final statusColor = Locker.getStatusColor(lockerWithStatus.realStatus);
    final statusName = Locker.getStatusDisplayName(lockerWithStatus.realStatus);
    final isAvailable = lockerWithStatus.realStatus == LockerStatus.available;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAvailable ? Icons.lock_open : Icons.lock,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locker.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        locker.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusName,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            // Show occupant info if occupied
            if (lockerWithStatus.realStatus == LockerStatus.occupied) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Currently occupied by: ${lockerWithStatus.occupantName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (lockerWithStatus.expiresAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Available after: ${_formatDateTime(lockerWithStatus.expiresAt!)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAvailable ? () => _showBookingDialog(locker) : null,
                icon: Icon(
                  isAvailable ? Icons.book_online : Icons.schedule,
                  size: 18,
                ),
                label: Text(
                  isAvailable ? 'Book Locker (24h)' : 'Not Available',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAvailable ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(Locker locker) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book ${locker.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Location: ${locker.location}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Booking Duration: 24 Hours',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Expires: ${_formatDateTime(DateTime.now().add(const Duration(hours: 24)))}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'After 24 hours, the locker will become available for others to book.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _bookLocker(locker, currentUser.uid);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _bookLocker(Locker locker, String userId) async {
    try {
      // Get user data for RFID
      final user = await _userService.getUserById(userId);
      if (user == null || user.rfidUid == null || user.rfidUid!.isEmpty) {
        _showSnackBar('You need an RFID card to book a locker. Please contact admin.', Colors.red);
        return;
      }

      // Check if user already has an active booking
      final existingAssignments = await FirebaseFirestore.instance
          .collection('lockerAssignments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      bool hasActiveBooking = false;
      for (var doc in existingAssignments.docs) {
        final assignment = LockerAssignment.fromDoc(doc);
        if (!assignment.isExpired) {
          hasActiveBooking = true;
          break;
        }
      }

      if (hasActiveBooking) {
        _showSnackBar('You already have an active booking. Release it first to book another locker.', Colors.orange);
        return;
      }

      // Create 24-hour booking
      await _assignmentService.createAssignment(
        lockerId: locker.id,
        userId: userId,
        rfidUid: user.rfidUid!,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      _showSnackBar('Locker booked successfully for 24 hours!', Colors.green);
    } catch (e) {
      _showSnackBar('Error booking locker: ${e.toString()}', Colors.red);
    }
  }

  void _showReleaseConfirmation(LockerAssignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Release Locker Early?'),
        content: const Text(
          'Are you sure you want to release this locker? This will make it available for others to book immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _releaseLocker(assignment);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Release'),
          ),
        ],
      ),
    );
  }

  Future<void> _releaseLocker(LockerAssignment assignment) async {
    try {
      // Expire the assignment
      await _assignmentService.updateAssignmentStatus(assignment.id, AssignmentStatus.expired);
      _showSnackBar('Locker released successfully!', Colors.green);
    } catch (e) {
      _showSnackBar('Error releasing locker: ${e.toString()}', Colors.red);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}