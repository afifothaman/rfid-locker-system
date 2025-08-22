import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/locker_model.dart';
import '../../models/locker_assignment_model.dart';
import '../../models/user_model.dart';
import '../../services/locker_service.dart';
import '../../services/locker_assignment_service.dart';
import '../../services/user_service.dart';
import 'locker_extension_requests_admin_widget.dart';


class ManageLockersScreen extends StatefulWidget {
  const ManageLockersScreen({Key? key}) : super(key: key);

  @override
  State<ManageLockersScreen> createState() => _ManageLockersScreenState();
}

class _ManageLockersScreenState extends State<ManageLockersScreen> {
  final LockerService _lockerService = LockerService();
  final LockerAssignmentService _assignmentService = LockerAssignmentService();
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.storage, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'Manage Lockers',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateLockerDialog(),
            tooltip: 'Add New Locker',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndStats(),
          // --- Locker Extension Requests ---
          const LockerExtensionRequestsAdminWidget(),
          Expanded(child: _buildLockersList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndStats() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search lockers by name or location...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Statistics Cards
          FutureBuilder<Map<String, int>>(
            future: _lockerService.getLockerStatistics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
              }
              
              final stats = snapshot.data!;
              return Row(
                children: [
                  Expanded(child: _buildStatCard('Total', stats['total'] ?? 0, Icons.storage, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Available', stats['available'] ?? 0, Icons.check_circle, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Occupied', stats['occupied'] ?? 0, Icons.lock, Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Maintenance', stats['maintenance'] ?? 0, Icons.build, Colors.red)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 110),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
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
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(locker.status),
            color: statusColor,
            size: 24,
          ),
        ),
        title: Text(
          locker.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(locker.location),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusName,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Show occupant info if occupied
            if (lockerWithStatus.realStatus == LockerStatus.occupied) ...[
              const SizedBox(height: 4),
              Text(
                'Occupant: ${lockerWithStatus.occupantName}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'RFID: ${lockerWithStatus.occupantRfid}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),

            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleLockerAction(locker, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),

            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        children: [
          _buildLockerDetails(locker),
        ],
      ),
    );
  }

  Widget _buildLockerDetails(Locker locker) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Locker Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Name', locker.name),
          _buildDetailRow('Location', locker.location),
          _buildDetailRow('Status', Locker.getStatusDisplayName(locker.status)),
          if (locker.occupiedAt != null)
            _buildDetailRow('Occupied Since', _formatDateTime(locker.occupiedAt!)),
          
          // Show expiry info from real-time status
          StreamBuilder<List<LockerWithStatus>>(
            stream: _lockerService.getLockersWithRealTimeStatus(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final lockerWithStatus = snapshot.data!.firstWhere(
                  (lws) => lws.locker.id == locker.id,
                  orElse: () => LockerWithStatus(
                    locker: locker,
                    realStatus: locker.status,
                    occupantName: 'Not occupied',
                    occupantRfid: 'Not occupied',
                  ),
                );
                
                if (lockerWithStatus.expiresAt != null) {
                  return Column(
                    children: [
                      _buildDetailRow('Expiry Date', _formatDate(lockerWithStatus.expiresAt!)),
                      _buildDetailRow('Expiry Time', _formatTime(lockerWithStatus.expiresAt!)),
                    ],
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAssignUserDialog(locker),
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Assign User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showChangeStatusDialog(locker),
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Change Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentTile(LockerAssignment assignment) {
    return FutureBuilder<UserModel?>(
      future: _userService.getUserById(assignment.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final userName = user?.name ?? 'Unknown User';
        final userEmail = user?.email ?? 'Unknown Email';
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.green[700],
                    child: const Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (value) {
                      switch (value) {
                        case 'unassign':
                          _showUnassignConfirmation(assignment);
                          break;
                        case 'extend':
                          _showExtendAssignmentDialog(assignment);
                          break;
                        case 'history':
                          _showAccessHistoryDialog(assignment);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'history',
                        child: Row(
                          children: [
                            Icon(Icons.history, size: 16),
                            SizedBox(width: 8),
                            Text('Access History'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'extend',
                        child: Row(
                          children: [
                            Icon(Icons.schedule, size: 16),
                            SizedBox(width: 8),
                            Text('Extend Assignment'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'unassign',
                        child: Row(
                          children: [
                            Icon(Icons.person_remove, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Unassign', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip('RFID: ${assignment.rfidUid}', Icons.credit_card, Colors.blue),
                  const SizedBox(width: 8),
                  if (assignment.expiresAt != null)
                    _buildInfoChip(
                      'Expiration Date: ${_formatDate(assignment.expiresAt!)}', 
                      Icons.calendar_today, 
                      assignment.expiresAt!.isBefore(DateTime.now().add(const Duration(days: 7))) 
                        ? Colors.orange 
                        : Colors.green
                    ),
                ],
              ),
              if (assignment.expiresAt != null) ...[
                const SizedBox(height: 4),
                _buildInfoChip(
                  'Expiration Time: ${_formatTime(assignment.expiresAt!)}',
                  Icons.schedule,
                  assignment.expiresAt!.isBefore(DateTime.now().add(const Duration(days: 7))) 
                    ? Colors.orange 
                    : Colors.grey,
                ),
              ],
              const SizedBox(height: 8),
              _buildRecentAccessInfo(assignment),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAccessInfo(LockerAssignment assignment) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('access_logs')
          .where('userId', isEqualTo: assignment.userId)
          .where('lockerId', isEqualTo: assignment.lockerId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'No recent access',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          );
        }

        final lastAccess = snapshot.data!.docs.first;
        final data = lastAccess.data() as Map<String, dynamic>;
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final result = data['result'] as String;

        return Row(
          children: [
            Icon(
              result == 'allowed' ? Icons.check_circle : Icons.cancel,
              size: 12,
              color: result == 'allowed' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              'Last access: ${_formatDateTime(timestamp)} ($result)',
              style: TextStyle(
                fontSize: 10,
                color: result == 'allowed' ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getStatusIcon(LockerStatus status) {
    switch (status) {
      case LockerStatus.available:
        return Icons.lock_open;
      case LockerStatus.occupied:
        return Icons.lock;
      case LockerStatus.maintenance:
        return Icons.build;
      case LockerStatus.offline:
        return Icons.power_off;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleLockerAction(Locker locker, String action) {
    switch (action) {
      case 'edit':
        _showEditLockerDialog(locker);
        break;

      case 'delete':
        _showDeleteConfirmation(locker);
        break;
    }
  }

  void _showCreateLockerDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Locker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Locker Name',
                hintText: 'e.g., Locker A1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., Ground Floor, Section A',
                border: OutlineInputBorder(),
              ),
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
              if (nameController.text.trim().isNotEmpty && 
                  locationController.text.trim().isNotEmpty) {
                try {
                  await _lockerService.createLocker(
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                  );
                  Navigator.pop(context);
                  _showSnackBar('Locker created successfully', Colors.green);
                } catch (e) {
                  _showSnackBar('Error creating locker: ${e.toString()}', Colors.red);
                }
              } else {
                _showSnackBar('Please fill in all fields', Colors.orange);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditLockerDialog(Locker locker) {
    final nameController = TextEditingController(text: locker.name);
    final locationController = TextEditingController(text: locker.location);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Locker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Locker Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
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
              if (nameController.text.trim().isNotEmpty && 
                  locationController.text.trim().isNotEmpty) {
                try {
                  await _lockerService.updateLocker(
                    locker.id,
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                  );
                  Navigator.pop(context);
                  _showSnackBar('Locker updated successfully', Colors.green);
                } catch (e) {
                  _showSnackBar('Error updating locker: ${e.toString()}', Colors.red);
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAssignUserDialog(Locker locker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign User to ${locker.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<List<UserModel>>(
            stream: _userService.getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final users = snapshot.data ?? [];
              final activeUsers = users.where((u) => u.status == UserStatus.active && u.rfidUid?.isNotEmpty == true).toList();
              
              if (activeUsers.isEmpty) {
                return const Center(
                  child: Text('No active users with RFID cards found'),
                );
              }
              
              return ListView.builder(
                itemCount: activeUsers.length,
                itemBuilder: (context, index) {
                  final user = activeUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U'),
                    ),
                    title: Text(user.name),
                    subtitle: Text('RFID: ${user.rfidUid}'),
                    onTap: () => _showAssignmentDetailsDialog(locker, user),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAssignmentDetailsDialog(Locker locker, UserModel user) {
    DateTime? expiryDate = DateTime.now().add(const Duration(hours: 24)); // Default 24 hours
    bool deletePreviousLogs = false; // Unchecked by default (preserve logs)
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Assign ${user.name} to ${locker.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User: ${user.name}'),
              Text('RFID: ${user.rfidUid}'),
              Text('Locker: ${locker.name}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: expiryDate != null,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          expiryDate = DateTime.now().add(const Duration(hours: 24));
                        } else {
                          expiryDate = null;
                        }
                      });
                    },
                  ),
                  const Text('Set expiry date'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: deletePreviousLogs,
                    onChanged: (value) {
                      setState(() {
                        deletePreviousLogs = value ?? true;
                      });
                    },
                  ),
                  const Text('Delete previous logs'),
                ],
              ),
              if (expiryDate != null) ...[
                ListTile(
                  title: Text('Expires: ${_formatDateTime(expiryDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: expiryDate!,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        // Preserve the time when changing date
                        expiryDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          expiryDate!.hour,
                          expiryDate!.minute,
                        );
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text('Time: ${_formatTime(expiryDate!)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(expiryDate!),
                    );
                    if (time != null) {
                      setState(() {
                        // Preserve the date when changing time
                        expiryDate = DateTime(
                          expiryDate!.year,
                          expiryDate!.month,
                          expiryDate!.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Check for existing assignments first
                final existingAssignments = await FirebaseFirestore.instance
                    .collection('lockerAssignments')
                    .where('lockerId', isEqualTo: locker.id)
                    .where('status', isEqualTo: 'active')
                    .get();

                bool hasActiveAssignments = false;
                String existingUserNames = '';
                
                for (var doc in existingAssignments.docs) {
                  final assignment = LockerAssignment.fromDoc(doc);
                  if (!assignment.isExpired) {
                    hasActiveAssignments = true;
                    // Get user name
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(assignment.userId)
                        .get();
                    if (userDoc.exists) {
                      final userData = userDoc.data() as Map<String, dynamic>;
                      final userName = userData['name'] ?? 'Unknown User';
                      existingUserNames += '• $userName (RFID: ${assignment.rfidUid})\n';
                    }
                  }
                }

                if (hasActiveAssignments) {
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('⚠️ Overwrite Existing Assignment?'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${locker.name} is currently assigned to:'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Text(
                              existingUserNames.trim(),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Assigning to ${user.name} will:'),
                          const Text('• Expire existing assignments'),
                          const SizedBox(height: 8),
                          const Text(
                            'This action cannot be undone. Continue?',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Yes, Overwrite'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed != true) return; // User cancelled
                }

                try {
                  // Delete previous logs if checkbox is ticked
                  if (deletePreviousLogs) {
                    await _deletePreviousLogs(locker.id, user.id);
                  }
                  
                  // Expire any existing assignments for this locker
                  await _expireExistingAssignments(locker.id);
                  
                  await _assignmentService.createAssignment(
                    lockerId: locker.id,
                    userId: user.id,
                    rfidUid: user.rfidUid!,
                    expiresAt: expiryDate,
                  );
                  Navigator.pop(context); // Close assignment dialog
                  Navigator.pop(context); // Close user selection dialog
                  _showSnackBar('User assigned successfully', Colors.green);
                } catch (e) {
                  _showSnackBar('Error assigning user: ${e.toString()}', Colors.red);
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeStatusDialog(Locker locker) {
    LockerStatus selectedStatus = locker.status;
    bool deletePreviousLogs = false; // Unchecked by default (preserve logs)
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Change Status for ${locker.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...LockerStatus.values.map((status) {
                return RadioListTile<LockerStatus>(
                  title: Text(Locker.getStatusDisplayName(status)),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: deletePreviousLogs,
                    onChanged: (value) {
                      setState(() {
                        deletePreviousLogs = value ?? true;
                      });
                    },
                  ),
                  const Text('Delete previous logs'),
                ],
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
              // Check if status is actually changing
              if (selectedStatus == locker.status && !deletePreviousLogs) {
                Navigator.pop(context);
                return;
              }

              // Show confirmation for significant changes
              bool needsConfirmation = false;
              String warningMessage = '';
              
              if (selectedStatus != locker.status) {
                needsConfirmation = true;
                warningMessage = 'Change status from "${Locker.getStatusDisplayName(locker.status)}" to "${Locker.getStatusDisplayName(selectedStatus)}"';
                
                if (selectedStatus != LockerStatus.occupied) {
                  warningMessage += '\n• This will expire all active assignments';
                }
              }
              


              if (needsConfirmation) {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('⚠️ Confirm Status Change for ${locker.name}'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('You are about to:'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Text(
                            warningMessage,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'This action cannot be undone. Continue?',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Yes, Continue'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return; // User cancelled
              }

              try {
                // Delete previous logs if checkbox is ticked
                if (deletePreviousLogs) {
                  await _deleteAllLockerLogs(locker.id);
                }
                
                // Expire existing assignments if changing to available/maintenance/offline
                if (selectedStatus != LockerStatus.occupied) {
                  await _expireExistingAssignments(locker.id);
                }
                
                await _lockerService.updateLockerStatus(locker.id, selectedStatus);
                Navigator.pop(context);
                _showSnackBar('Status updated successfully', Colors.green);
              } catch (e) {
                _showSnackBar('Error updating status: ${e.toString()}', Colors.red);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    ),
  );
}

void _showUnassignConfirmation(LockerAssignment assignment) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unassign User'),
      content: const Text('Are you sure you want to remove this assignment?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _assignmentService.updateAssignmentStatus(assignment.id, AssignmentStatus.expired);
              Navigator.pop(context);
              _showSnackBar('Assignment removed successfully', Colors.green);
            } catch (e) {
              _showSnackBar('Error removing assignment: ${e.toString()}', Colors.red);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
}

void _showDeleteConfirmation(Locker locker) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Locker'),
      content: Text('Are you sure you want to delete ${locker.name}? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _lockerService.deleteLocker(locker.id);
              Navigator.pop(context);
              _showSnackBar('Locker deleted successfully', Colors.green);
            } catch (e) {
              _showSnackBar('Error deleting locker: ${e.toString()}', Colors.red);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}





  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showExtendAssignmentDialog(LockerAssignment assignment) {
    DateTime newExpiryDate = assignment.expiresAt ?? DateTime.now().add(const Duration(days: 30));
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Extend Assignment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current expiry: ${assignment.expiresAt != null ? _formatDateTime(assignment.expiresAt!) : 'No expiry set'}'),
              const SizedBox(height: 16),
              ListTile(
                title: Text('New expiry: ${_formatDateTime(newExpiryDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: newExpiryDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(newExpiryDate),
                    );
                    if (time != null) {
                      setState(() {
                        newExpiryDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
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
                try {
                  await _assignmentService.updateAssignment(
                    assignment.id,
                    expiresAt: newExpiryDate,
                  );
                  Navigator.pop(context);
                  _showSnackBar('Assignment extended successfully', Colors.green);
                } catch (e) {
                  _showSnackBar('Error extending assignment: ${e.toString()}', Colors.red);
                }
              },
              child: const Text('Extend'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccessHistoryDialog(LockerAssignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('access_logs')
                .where('userId', isEqualTo: assignment.userId)
                .where('lockerId', isEqualTo: assignment.lockerId)
                .orderBy('timestamp', descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No access history found'));
              }

              final logs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final data = log.data() as Map<String, dynamic>;
                  final timestamp = (data['timestamp'] as Timestamp).toDate();
                  final result = data['result'] as String;
                  final method = data['method'] as String? ?? 'RFID';

                  return ListTile(
                    leading: Icon(
                      result == 'allowed' ? Icons.check_circle : Icons.cancel,
                      color: result == 'allowed' ? Colors.green : Colors.red,
                    ),
                    title: Text(_formatDateTime(timestamp)),
                    subtitle: Text('Method: $method'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: result == 'allowed' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        result.toUpperCase(),
                        style: TextStyle(
                          color: result == 'allowed' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Delete previous access logs for a locker and user
  Future<void> _deletePreviousLogs(String lockerId, String userId) async {
    try {
      final logsQuery = await FirebaseFirestore.instance
          .collection('access_logs')
          .where('lockerId', isEqualTo: lockerId)
          .where('userId', isEqualTo: userId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in logsQuery.docs) {
        batch.delete(doc.reference);
      }
      
      if (logsQuery.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      // Error deleting previous logs - handle silently
    }
  }

  // Expire existing assignments for a locker
  Future<void> _expireExistingAssignments(String lockerId) async {
    try {
      final assignmentsQuery = await FirebaseFirestore.instance
          .collection('lockerAssignments')
          .where('lockerId', isEqualTo: lockerId)
          .where('status', isEqualTo: 'active')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in assignmentsQuery.docs) {
        batch.update(doc.reference, {
          'status': 'expired',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      if (assignmentsQuery.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      // Error expiring existing assignments - handle silently
    }
  }

  // Delete all access logs for a locker
  Future<void> _deleteAllLockerLogs(String lockerId) async {
    try {
      final logsQuery = await FirebaseFirestore.instance
          .collection('access_logs')
          .where('lockerId', isEqualTo: lockerId)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in logsQuery.docs) {
        batch.delete(doc.reference);
      }
      
      if (logsQuery.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      // Error deleting locker logs - handle silently
    }
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
}
