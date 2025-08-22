import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'Admin Dashboard',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
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
          ),
          
          // Statistics Cards
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Total Users', Icons.people, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Pending', Icons.schedule, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Active', Icons.check_circle, Colors.green)),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading users: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                
                final users = snapshot.data?.docs ?? [];
                
                // Filter users based on search query
                final filteredUsers = users.where((doc) {
                  final userData = doc.data() as Map<String, dynamic>;
                  final name = (userData['name'] ?? '').toString().toLowerCase();
                  final email = (userData['email'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();
                
                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text('No users found'),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userDoc = filteredUsers[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final user = UserModel.fromMap({
                      'id': userDoc.id,
                      ...userData,
                    });
                    
                    return _buildUserCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, Color color) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        
        if (snapshot.hasData) {
          final users = snapshot.data!.docs;
          
          switch (title) {
            case 'Total Users':
              count = users.length;
              break;
            case 'Pending':
              count = users.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == 'pending';
              }).length;
              break;
            case 'Active':
              count = users.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == 'active';
              }).length;
              break;
          }
        }
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  count.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(UserModel user) {
    Color statusColor;
    IconData statusIcon;
    
    switch (user.status) {
      case UserStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case UserStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case UserStatus.pending:
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          user.name.isNotEmpty ? user.name : 'No Name',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.credit_card, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  user.ic?.isNotEmpty == true ? user.ic! : 'No IC',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.nfc, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  user.rfidUid?.isNotEmpty == true ? user.rfidUid! : 'No RFID',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(user, value),
          itemBuilder: (context) => [
            if (user.status == UserStatus.pending) ...[
              const PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Approve'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reject',
                child: Row(
                  children: [
                    Icon(Icons.close, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Reject'),
                  ],
                ),
              ),
            ],
            if (user.status == UserStatus.active) ...[
              const PopupMenuItem(
                value: 'suspend',
                child: Row(
                  children: [
                    Icon(Icons.pause, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Suspend'),
                  ],
                ),
              ),
            ],
            if (user.status == UserStatus.rejected) ...[
              const PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Approve'),
                  ],
                ),
              ),
            ],
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('View Details'),
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
      ),
    );
  }

  void _handleUserAction(UserModel user, String action) async {
    try {
      switch (action) {
        case 'approve':
          await _updateUserStatus(user.id, 'active');
          _showSnackBar('User approved successfully', Colors.green);
          break;
        case 'reject':
        case 'suspend':
          await _updateUserStatus(user.id, 'rejected');
          _showSnackBar('User status updated', Colors.orange);
          break;
        case 'view':
          _showUserDetails(user);
          break;
        case 'delete':
          _showDeleteConfirmation(user);
          break;
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _updateUserStatus(String userId, String status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', user.name),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Phone', user.phoneNumber ?? 'Not provided'),
            _buildDetailRow('IC Number', user.ic ?? 'Not provided'),
            _buildDetailRow('RFID UID', user.rfidUid ?? 'Not provided'),
            _buildDetailRow('Status', user.status.toString().split('.').last),
            _buildDetailRow('Created', user.createdAt.toString().split(' ')[0]),
          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .delete();
                Navigator.pop(context);
                _showSnackBar('User deleted successfully', Colors.green);
              } catch (e) {
                _showSnackBar('Error deleting user: ${e.toString()}', Colors.red);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}