import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../../utils/firebase_test.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/manage_lockers_screen.dart';
import '../admin/analytics_screen.dart';
import '../user/user_lockers_screen.dart';
import '../../languages/app_localizations.dart';
import '../../services/logout_service.dart';
import '../../services/admin_service.dart';
import '../../services/user_service.dart';
import 'locker_extension_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  void _checkAdminStatus() async {
    final adminService = AdminService();
    final isAdminUser = await adminService.isCurrentUserAdmin();
    if (mounted) {
      setState(() {
        isAdmin = isAdminUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    // final authProvider = context.watch<my_auth_provider.AuthProvider>();
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.train, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Rapid',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: 'KL',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF87CEEB),
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: ' Locker',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => LogoutService.showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(context, user),
            const SizedBox(height: 24),


            
            // Quick Actions
            Text(
              localizations.quickActions,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),

          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, User? user) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            const Color(0xFF3182CE),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.welcomeMessage,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String displayName = 'User';
                          
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final userData = snapshot.data!.data() as Map<String, dynamic>;
                            displayName = userData['name'] ?? user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
                          } else {
                            displayName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
                          }
                          
                          return Text(
                            displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Status Cards with Firebase Data - Only for Users
            if (!isAdmin) Row(
              children: [
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String status = 'Pending';
                      Color color = Colors.orange;
                      
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                        final userStatus = userData['status'] ?? 'pending';
                        
                        if (userStatus == 'active') {
                          status = 'Active';
                          color = Colors.green;
                        } else if (userStatus == 'rejected') {
                          status = 'Rejected';
                          color = Colors.red;
                        } else {
                          status = 'Pending';
                          color = Colors.orange;
                        }
                      }
                      
                      return _buildMiniStatCard(
                        localizations.accountStatus,
                        status,
                        Icons.person_outline,
                        color,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // User: Show Locker Assignment status
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('lockerAssignments')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .where('status', isEqualTo: 'active')
                        .snapshots(),
                    builder: (context, snapshot) {
                      // Simplified: Only show "Not Assigned" or "Locker [ID]"
                      // Loading and expired states both show as "Not Assigned"
                      
                      if (snapshot.connectionState == ConnectionState.waiting || 
                          !snapshot.hasData || 
                          snapshot.data!.docs.isEmpty) {
                        return _buildMiniStatCard(
                          'Locker',
                          'Not Assigned',
                          Icons.storage,
                          Colors.orange,
                        );
                      }
                      
                      final assignment = snapshot.data!.docs.first;
                      final assignmentData = assignment.data() as Map<String, dynamic>;
                      final lockerId = assignmentData['lockerId'] as String;
                      final expiresAt = assignmentData['expiresAt'] as Timestamp?;
                      
                      // Check if assignment is expired - if so, treat as "Not Assigned"
                      if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
                        return _buildMiniStatCard(
                          'Locker',
                          'Not Assigned',
                          Icons.storage,
                          Colors.orange,
                        );
                      }
                      
                      // Get locker name
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('lockers')
                            .doc(lockerId)
                            .snapshots(),
                        builder: (context, lockerSnapshot) {
                          if (lockerSnapshot.connectionState == ConnectionState.waiting) {
                            return _buildMiniStatCard(
                              'Locker',
                              'Loading...',
                              Icons.storage,
                              Colors.grey,
                            );
                          }
                          
                          String lockerName = 'Unknown';
                          if (lockerSnapshot.hasData && lockerSnapshot.data!.exists) {
                            final lockerData = lockerSnapshot.data!.data() as Map<String, dynamic>;
                            lockerName = lockerData['name'] ?? 'Unknown';
                          }
                          
                          return _buildMiniStatCard(
                            'Locker',
                            lockerName,
                            Icons.storage,
                            Colors.green,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: isAdmin ? [
        // Admin Actions
        _buildActionCard(
          context,
          'Manage Users',
          Icons.people,
          Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Manage Lockers',
          Icons.storage,
          Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageLockersScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Access Logs',
          Icons.assignment,
          Colors.green,
          onTap: () {
            _showAdminAccessLogs(context);
          },
        ),

        _buildActionCard(
          context,
          'System Analytics',
          Icons.analytics,
          Colors.deepOrange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnalyticsScreen(),
              ),
            );
          },
        ),

        _buildActionCard(
          context,
          'Create Sample Data',
          Icons.data_usage,
          Colors.orange,
          onTap: () {
            _createSampleData(context);
          },
        ),
      ] : [
        // User Actions
        _buildActionCard(
          context,
          localizations.updateRfidNumber,
          Icons.nfc,
          const Color(0xFF3182CE),
          onTap: () {
            _showUpdateRfidDialog(context);
          },
        ),
        _buildActionCard(
          context,
          localizations.myProfile,
          Icons.person_outline,
          Theme.of(context).primaryColor,
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        _buildActionCard(
          context,
          'Available Lockers',
          Icons.storage,
          Colors.deepPurple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserLockersScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          context,
          'Extend Time',
          Icons.access_time,
          Colors.orange,
          onTap: () {
            _showExtendTimeDialog(context);
          },
        ),
        _buildActionCard(
          context,
          localizations.accessHistory,
          Icons.history,
          Colors.green,
          onTap: () {
            _showAccessHistory(context);    
          },
        ),

      ],
    );
  }

  void _showExtendTimeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LockerExtensionDialog(),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  color.withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.8),
                        color,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon, 
                    color: Colors.white, 
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
  child: Text(
    title,
    style: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
    ),
    textAlign: TextAlign.center,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                _showAccessHistory(context);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildActivityItem(
                  context,
                  'Profile Created',
                  'Welcome to Smart Locker System',
                  Icons.person_add,
                  Colors.green,
                  'Just now',
                ),
                const Divider(),
                _buildActivityItem(
                  context,
                  'Setup Required',
                  'Complete your profile to access lockers',
                  Icons.warning_amber,
                  Colors.orange,
                  'Now',
                ),
                const Divider(),
                _buildActivityItem(
                  context,
                  'RFID Registration',
                  'Get your RFID card UID from staff',
                  Icons.nfc,
                  Colors.blue,
                  'Pending',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  // System Status Check Method (renamed from _testFirebase)
  void _checkSystemStatus(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Row(
          children: [
            Icon(Icons.health_and_safety, color: Colors.purple),
            SizedBox(width: 8),
            Text('System Status Check'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking system connectivity...'),
          ],
        ),
      ),
    );

    try {
      await FirebaseTest.testFirebaseConnection();
      await FirebaseTest.createTestUser();
      await FirebaseTest.createTestAccessLog();
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ System status: All services operational!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ System status: Issues detected - ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Create sample data (logs and lockers) for testing
  void _createSampleData(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Creating Sample Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Adding sample lockers and access logs...'),
          ],
        ),
      ),
    );

    try {
      final now = DateTime.now();
      final firestore = FirebaseFirestore.instance;
      
      // Get user data
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      String userName = 'Unknown User';
      String rfidUid = 'Not Set';
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        userName = userData['name'] ?? 'Unknown User';
        rfidUid = userData['rfidUid'] ?? 'Not Set';
      }

      // Create logs for different time periods
      final logsToCreate = [
        // Today
        {
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
          'result': 'allowed',
          'action': 'Locker Access',
        },
        {
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(hours: 5))),
          'result': 'denied',
          'action': 'Failed Access Attempt',
        },
        // Past Week
        {
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
          'result': 'allowed',
          'action': 'Locker Access',
        },
        {
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
          'result': 'allowed',
          'action': 'Locker Access',
        },
        // Past Month
        {
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 15))),
          'result': 'denied',
          'action': 'Access Denied - Card Expired',
        },
        {
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 25))),
          'result': 'allowed',
          'action': 'Locker Access',
        },
      ];

      // Create sample access logs
      for (var logData in logsToCreate) {
        await firestore.collection('access_logs').add({
          'userId': user.uid,
          'userName': userName,
          'rfidUid': rfidUid,
          'timestamp': logData['timestamp'],
          'result': logData['result'],
          'action': logData['action'],
          'reason': logData['result'] == 'denied' ? 'Test denial reason' : null,
        });
      }

      // Create sample lockers
      await FirebaseTest.createSampleLockers();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sample data created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to create sample logs: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Firebase Test Method (for admin use)
  void _testFirebase(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cloud, color: Colors.purple),
            SizedBox(width: 8),
            Text('Testing Firebase'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing Firebase connection...'),
          ],
        ),
      ),
    );

    try {
      await FirebaseTest.testFirebaseConnection();
      await FirebaseTest.createTestUser();
      await FirebaseTest.createTestAccessLog();
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Firebase test completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Firebase test failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // RFID Update Dialog with Conflict Detection
  void _showUpdateRfidDialog(BuildContext context) {
    final rfidController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    final userService = UserService();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.nfc, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Update RFID Number',
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your RFID card number:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rfidController,
                decoration: InputDecoration(
                  labelText: 'RFID Number',
                  hintText: 'e.g., A1B2C3D4',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.nfc),
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  // Auto-format to uppercase as user types
                  if (value != value.toUpperCase()) {
                    rfidController.value = rfidController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Get your RFID card number from RapidKL staff. Each RFID must be unique.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final rfidInput = rfidController.text.trim();
                if (rfidInput.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your RFID number'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                setState(() => isLoading = true);
                
                try {
                  if (user != null) {
                    // Use the new conflict detection method
                    final result = await userService.updateUserRfidUid(user.uid, rfidInput);
                    
                    if (result['success']) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      // Handle different error types
                      if (result['error'] == 'RFID_UID_EXISTS') {
                        if (result['showDetails'] == true) {
                          // Admin view with full details
                          _showRfidConflictDialog(context, result);
                        } else {
                          // Regular user view (privacy-safe)
                          _showPrivacySafeConflictDialog(context, result);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unexpected error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (mounted) setState(() => isLoading = false);
                }
              },
              child: isLoading 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // Show RFID conflict dialog with details (Admin only)
  void _showRfidConflictDialog(BuildContext context, Map<String, dynamic> conflictInfo) {
    final conflictUser = conflictInfo['conflictUser'];
    final rfidUid = conflictInfo['message'].toString().split('"')[1]; // Extract UID from message
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('RFID Already Exists'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nfc, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'RFID: $rfidUid',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This RFID number is already registered to:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  if (conflictUser != null) ...[
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          conflictUser['name'] ?? 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Text(conflictUser['email'] ?? 'No email'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please check your RFID number or contact RapidKL staff if you believe this is an error.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Different RFID'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close conflict dialog
              Navigator.pop(context); // Close RFID update dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  // Show privacy-safe conflict dialog (Regular users)
  void _showPrivacySafeConflictDialog(BuildContext context, Map<String, dynamic> conflictInfo) {
    final message = conflictInfo['message'].toString();
    final rfidUid = message.split('"')[1]; // Extract UID from message
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('RFID Already Exists'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nfc, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'RFID: $rfidUid',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This RFID number is already registered to another user.',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please double-check your RFID number or contact RapidKL staff if you believe this is an error.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Different RFID'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close conflict dialog
              Navigator.pop(context); // Close RFID update dialog
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  // Admin Access Logs - Shows all users' logs with detailed information
  void _showAdminAccessLogs(BuildContext context) {
    String selectedFilter = 'All Time';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.admin_panel_settings, color: Colors.blue),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Admin Access Logs',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 500,
            child: Column(
              children: [
                // Filter Dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      icon: const Icon(Icons.filter_list, color: Colors.blue),
                      items: const [
                        DropdownMenuItem(value: 'Today', child: Text('Today')),
                        DropdownMenuItem(value: 'Past Week', child: Text('Past Week')),
                        DropdownMenuItem(value: 'Past Month', child: Text('Past Month')),
                        DropdownMenuItem(value: 'All Time', child: Text('All Time')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Access Logs List (All Users)
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getAllAccessLogsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                'Unable to load access logs',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      
                      final allLogs = snapshot.data?.docs ?? [];
                      
                      // Apply client-side filtering
                      final filteredLogs = _filterLogsByTimePeriod(allLogs, selectedFilter);
                      
                      if (filteredLogs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment, color: Colors.grey[400], size: 64),
                              const SizedBox(height: 16),
                              Text(
                                'No access logs found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'for ${selectedFilter.toLowerCase()}',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index].data() as Map<String, dynamic>;
                          final timestamp = (log['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                          final isSuccess = log['result'] == 'allowed';
                          final action = log['action'] ?? 'Access Attempt';
                          final rfidUid = log['rfidUid'] ?? 'N/A';
                          final userName = log['userName'] ?? 'Unknown User';
                          final userId = log['userId'] ?? 'N/A';
                          final reason = log['reason'];
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: isSuccess ? Colors.green[100] : Colors.red[100],
                                child: Icon(
                                  isSuccess ? Icons.lock_open : Icons.lock,
                                  color: isSuccess ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                isSuccess ? 'Access Granted' : 'Access Denied',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSuccess ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('User: $userName'),
                                  Text('RFID: $rfidUid • ${_formatTimestamp(timestamp)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSuccess ? Icons.check_circle : Icons.cancel,
                                    color: isSuccess ? Colors.green : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red[400],
                                      size: 20,
                                    ),
                                    onPressed: () => _showDeleteLogConfirmation(
                                      context,
                                      filteredLogs[index].id,
                                      isSuccess ? 'Access Granted' : 'Access Denied',
                                      timestamp,
                                    ),
                                    tooltip: 'Delete log',
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow('User ID', userId),
                                      _buildDetailRow('User Name', userName),
                                      _buildDetailRow('RFID UID', rfidUid),
                                      _buildDetailRow('Action', action),
                                      _buildDetailRow('Result', isSuccess ? 'ALLOWED' : 'DENIED'),
                                      if (reason != null) _buildDetailRow('Reason', reason),
                                      _buildDetailRow('Timestamp', timestamp.toString()),
                                      _buildDetailRow('Date', _formatFullDate(timestamp)),
                                      _buildDetailRow('Time', _formatTime(timestamp)),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _showUserDetails(context, userId),
                                              icon: const Icon(Icons.person, size: 16),
                                              label: const Text('View User'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () => _exportLogDetails(log, timestamp),
                                              icon: const Icon(Icons.download, size: 16),
                                              label: const Text('Export'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  // Access History with Firebase Data
  void _showAccessHistory(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String selectedFilter = 'Today';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.history, color: Colors.orange),
              SizedBox(width: 8),
              Text('Access History'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 450,
            child: Column(
              children: [
                // Filter Dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      icon: const Icon(Icons.filter_list, color: Colors.orange),
                      items: const [
                        DropdownMenuItem(value: 'Today', child: Text('Today')),
                        DropdownMenuItem(value: 'Past Week', child: Text('Past Week')),
                        DropdownMenuItem(value: 'Past Month', child: Text('Past Month')),
                        DropdownMenuItem(value: 'All Time', child: Text('All Time')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Access History List
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: user == null ? Future.value([]) : _getUserLockerIds(user.uid),
                    builder: (context, assignmentSnapshot) {
                      if (assignmentSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (assignmentSnapshot.hasError) {
                        return Center(child: Text('Error: \\${assignmentSnapshot.error}'));
                      }
                      final lockerIds = assignmentSnapshot.data ?? [];
                      if (lockerIds.isEmpty) {
                        return Center(child: Text('No access history found (no locker assignments).'));
                      }
                      // Firestore whereIn only supports up to 10 values, so chunk if needed
                      List<Widget> logLists = [];
                      for (var i = 0; i < lockerIds.length; i += 10) {
                        final chunk = lockerIds.sublist(i, i + 10 > lockerIds.length ? lockerIds.length : i + 10);
                        logLists.add(
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('access_logs')
                                .where('lockerId', whereIn: chunk)
                                .limit(500)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(child: Text('Error: \\${snapshot.error}'));
                              }
                              final allLogs = snapshot.data?.docs ?? [];
                              final filteredLogs = _filterLogsByTimePeriod(allLogs, selectedFilter);
                              if (filteredLogs.isEmpty) {
                                return const SizedBox();
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredLogs.length,
                                itemBuilder: (context, index) {
                                  final log = filteredLogs[index].data() as Map<String, dynamic>;
                                  final timestamp = (log['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                                  final isSuccess = log['result'] == 'allowed';
                                  final action = log['action'] ?? 'Access Attempt';
                                  final rfidUid = log['rfidUid'] ?? 'N/A';
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isSuccess ? Colors.green[100] : Colors.red[100],
                                        child: Icon(
                                          isSuccess ? Icons.lock_open : Icons.lock,
                                          color: isSuccess ? Colors.green : Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        isSuccess ? 'Access Granted' : 'Access Denied',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isSuccess ? Colors.green[700] : Colors.red[700],
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('$action • RFID: $rfidUid'),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatTimestamp(timestamp),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          // Name intentionally hidden for privacy
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSuccess ? Icons.check_circle : Icons.cancel,
                                            color: isSuccess ? Colors.green : Colors.red,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red[400],
                                              size: 20,
                                            ),
                                            onPressed: () => _showDeleteLogConfirmation(
                                              context,
                                              filteredLogs[index].id,
                                              isSuccess ? 'Access Granted' : 'Access Denied',
                                              timestamp,
                                            ),
                                            tooltip: 'Delete log',
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }
                      return ListView(
                        shrinkWrap: true,
                        children: logLists,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  // Delete log confirmation dialog
  void _showDeleteLogConfirmation(
    BuildContext context,
    String logId,
    String logTitle,
    DateTime timestamp,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Access Log'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this access log?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(fontSize: 12, color: Colors.red[700]),
                    ),
                  ),
                ],
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
              try {
                await FirebaseFirestore.instance
                    .collection('access_logs')
                    .doc(logId)
                    .delete();
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Access log deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Failed to delete log: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }



  void _showUserAnalytics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Colors.purple),
            SizedBox(width: 8),
            Text('User Analytics'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading analytics: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              final users = snapshot.data?.docs ?? [];
              
              // Calculate statistics
              int totalUsers = users.length;
              int activeUsers = users.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == 'active';
              }).length;
              int pendingUsers = users.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == 'pending';
              }).length;
              int rejectedUsers = users.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['status'] == 'rejected';
              }).length;
              int usersWithRfid = users.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final rfidUid = data['rfidUid'] ?? '';
                return rfidUid.isNotEmpty;
              }).length;
              
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildAnalyticsCard('Total Users', totalUsers.toString(), Icons.people, Colors.blue),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard('Active Users', activeUsers.toString(), Icons.check_circle, Colors.green),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard('Pending Approval', pendingUsers.toString(), Icons.schedule, Colors.orange),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard('Rejected Users', rejectedUsers.toString(), Icons.cancel, Colors.red),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard('Users with RFID', usersWithRfid.toString(), Icons.nfc, Colors.purple),
                    const SizedBox(height: 24),
                    
                    // Recent registrations
                    const Text(
                      'Recent Registrations',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ...users.take(5).map((doc) {
                      final userData = doc.data() as Map<String, dynamic>;
                      final name = userData['name'] ?? 'No Name';
                      final email = userData['email'] ?? 'No Email';
                      final status = userData['status'] ?? 'pending';
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: status == 'active' 
                              ? Colors.green[100] 
                              : status == 'rejected'
                                  ? Colors.red[100]
                                  : Colors.orange[100],
                          child: Icon(
                            status == 'active' 
                                ? Icons.check_circle 
                                : status == 'rejected'
                                    ? Icons.cancel
                                    : Icons.schedule,
                            color: status == 'active' 
                                ? Colors.green 
                                : status == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                            size: 20,
                          ),
                        ),
                        title: Text(name, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(email, style: const TextStyle(fontSize: 12)),
                        trailing: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: status == 'active' 
                                ? Colors.green 
                                : status == 'rejected'
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
                ),
              );
            },
            child: const Text('Manage Users'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get all access logs for admin
  Stream<QuerySnapshot> _getAllAccessLogsStream() {
    return FirebaseFirestore.instance
        .collection('access_logs')
        .limit(500)
        .snapshots();
  }

  // Helper method to build detail rows in admin logs
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

  // Helper method to format full date
  String _formatFullDate(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  // Helper method to format time
  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }

  // Show user details dialog
  void _showUserDetails(BuildContext context, String userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person, color: Colors.blue),
            SizedBox(width: 8),
            Text('User Details'),
          ],
        ),
        content: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading user details...'),
                ],
              );
            }

            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text('User not found or error loading details'),
                ],
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Name', userData['name'] ?? 'N/A'),
                _buildDetailRow('Email', userData['email'] ?? 'N/A'),
                _buildDetailRow('IC Number', userData['ic'] ?? 'N/A'),
                _buildDetailRow('Phone', userData['phoneNumber'] ?? 'N/A'),
                _buildDetailRow('RFID UID', userData['rfidUid'] ?? 'Not Set'),
                _buildDetailRow('Status', userData['status'] ?? 'pending'),
                _buildDetailRow('Role', userData['role'] ?? 'user'),
                _buildDetailRow('Created', userData['createdAt'] != null 
                    ? _formatFullDate((userData['createdAt'] as Timestamp).toDate())
                    : 'N/A'),
              ],
            );
          },
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

  // Export log details (placeholder)
  void _exportLogDetails(Map<String, dynamic> log, DateTime timestamp) {
    // In a real app, this would generate and download a file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log details exported (feature coming soon)'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Export all logs (placeholder)
  void _exportAllLogs(BuildContext context) {
    // In a real app, this would generate and download a CSV/Excel file
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All logs export (feature coming soon)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Shared filtering function for today's logs
  List<QueryDocumentSnapshot> filterTodayLogs(List<QueryDocumentSnapshot> logs) {
    final todayStart = DateTime.now();
    final startOfDay = DateTime(todayStart.year, todayStart.month, todayStart.day);
    
    return logs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate().toLocal();
      return timestamp != null && timestamp.isAfter(startOfDay);
    }).toList();
  }

  // Helper method to filter logs client-side
  List<QueryDocumentSnapshot> _filterLogsByTimePeriod(List<QueryDocumentSnapshot> logs, String filter) {
    // First, sort all logs by timestamp (newest first)
    final sortedLogs = logs.toList();
    sortedLogs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;
      final aTime = (aData['timestamp'] as Timestamp?)?.toDate().toLocal();
      final bTime = (bData['timestamp'] as Timestamp?)?.toDate().toLocal();
      
      // Handle null timestamps by putting them at the end
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      
      return bTime.compareTo(aTime); // Newest first
    });

    // For "All Time", return all sorted logs
    if (filter == 'All Time') {
      return sortedLogs;
    }

    final now = DateTime.now();
    DateTime startDate;

    switch (filter) {
      case 'Today':
        // Use the shared filtering function for consistency
        return filterTodayLogs(sortedLogs);
      case 'Past Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Past Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Past Month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      default:
        return sortedLogs;
    }

    // Filter logs based on the time period
    return sortedLogs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
      
      // If timestamp is null, exclude it from filtered results
      if (timestamp == null) return false;
      
      // Include logs that are after OR at the start date (inclusive for Today)
      return timestamp.isAfter(startDate) || timestamp.isAtSameMomentAs(startDate);
    }).toList();
  }

  // Returns a Future that resolves to a list of lockerIds ever assigned to the user
  Future<List<String>> _getUserLockerIds(String userId) async {
    final assignmentSnapshot = await FirebaseFirestore.instance
        .collection('lockerAssignments')
        .where('userId', isEqualTo: userId)
        .get();
    final lockerIds = assignmentSnapshot.docs
        .map((doc) => doc['lockerId'] as String)
        .toSet()
        .toList();
    return lockerIds;
  }

  void _showHelpGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.help_outline, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Help & User Guide',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.deepPurple,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.deepPurple,
                        tabs: [
                          Tab(icon: Icon(Icons.info_outline), text: 'Getting Started'),
                          Tab(icon: Icon(Icons.nfc), text: 'RFID Access'),
                          Tab(icon: Icon(Icons.storage), text: 'Locker Usage'),
                          Tab(icon: Icon(Icons.help), text: 'FAQ'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildGettingStartedTab(),
                            _buildRfidAccessTab(),
                            _buildLockerUsageTab(),
                            _buildFaqTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGettingStartedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpSection(
            'Welcome to RFID Locker System',
            'This system allows you to securely access lockers using RFID cards or tags.',
            Icons.waving_hand,
            Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'Dashboard Overview',
            'Your dashboard shows:\n• Current locker assignment status\n• Recent access history\n• Quick actions for common tasks',
            Icons.dashboard,
            Colors.green,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'Account Activation Process',
            'To access lockers, your account must be ACTIVE:\n• After registration, your status is "Pending"\n• Admin will manually verify your IC number\n• Once verified, admin will update your status to "Active"\n• Only active users can access lockers',
            Icons.verified_user,
            Colors.green,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'RFID Card Registration',
            'After account activation:\n• Get your RFID card/tag from staff\n• Staff will register the RFID number in the system\n• Use "Update RFID Number" to link it to your account\n• Both ACTIVE status + registered RFID are required for locker access',
            Icons.nfc,
            Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'Getting Help',
            'Need assistance?\n• Use this help guide\n• Contact system administrator\n• Check FAQ section for common questions',
            Icons.support_agent,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildRfidAccessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpSection(
            'RFID Card Registration Process',
            'Complete RFID setup process:\n1. Ensure your account status is "Active" (verified by admin)\n2. Get RFID card/tag from staff (they register it in Firebase/Arduino)\n3. Use "Update RFID Number" to link card to your account\n4. Test access at your assigned locker',
            Icons.credit_card,
            Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'How to Access Lockers',
            'Using your RFID card:\n1. Hold your RFID card near the reader\n2. Wait for the green light/beep\n3. Open the locker door\n4. Close the door securely after use',
            Icons.nfc,
            Colors.green,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'Access Denied?',
            'If access is denied:\n• Check if your RFID is registered\n• Verify locker assignment is active\n• Ensure assignment hasn\'t expired\n• Contact administrator if issues persist',
            Icons.error_outline,
            Colors.red,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'Security Tips',
            '• Keep your RFID card secure\n• Don\'t share your card with others\n• Report lost cards immediately\n• Always close lockers properly',
            Icons.security,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildLockerUsageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpSection(
            'Locker Assignment',
            'Locker assignments are managed by administrators:\n• You\'ll be notified when assigned a locker\n• Check your dashboard for assignment details\n• Note the expiry date if applicable',
            Icons.assignment,
            Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'Using Your Locker',
            'Best practices:\n• Store only personal items\n• Don\'t leave valuables unattended\n• Clean up after use\n• Report any damage immediately',
            Icons.storage,
            Colors.green,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'Access History',
            'Track your locker usage:\n• View recent access attempts\n• Check access times and dates\n• Monitor successful/failed attempts\n• Export history if needed',
            Icons.history,
            Colors.purple,
          ),
          const SizedBox(height: 20),
          _buildHelpSection(
            'Assignment Expiry',
            'If your assignment expires:\n• You\'ll lose access to the locker\n• Remove all personal items before expiry\n• Contact administrator for extension\n• Check dashboard for expiry warnings',
            Icons.schedule,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFaqItem(
            'Why is my account status "Pending"?',
            'After registration, all accounts start with "Pending" status. The administrator needs to manually verify your IC number before activating your account. Only users with "Active" status can access lockers.',
          ),
          _buildFaqItem(
            'How do I get my account activated?',
            'Submit your registration with correct IC number. The administrator will manually verify your IC and update your status to "Active". Contact the administrator if your account remains pending for too long.',
          ),
          _buildFaqItem(
            'How do I get an RFID card?',
            'After your account is activated, get your RFID card/tag from the staff. The staff will register the RFID number in the system (Firebase/Arduino). Then use "Update RFID Number" to link it to your account.',
          ),
          _buildFaqItem(
            'Why can\'t I access lockers?',
            'To access lockers, you need BOTH: 1) Active account status (verified by admin), and 2) Registered RFID card (provided by staff and linked to your account). Both conditions must be met.',
          ),
          _buildFaqItem(
            'Can I change my RFID card?',
            'Yes, get a new RFID card from staff (they will register it in the system), then update your RFID number using "Update RFID Number" in Quick Actions.',
          ),
          _buildFaqItem(
            'What if I forget my RFID card?',
            'Unfortunately, you cannot access your locker without your registered RFID card. Contact the administrator for assistance.',
          ),
          _buildFaqItem(
            'How long do locker assignments last?',
            'Assignment duration varies based on your organization\'s policy. Check your dashboard for expiry information.',
          ),
          _buildFaqItem(
            'Can I share my locker with someone else?',
            'No, lockers are assigned to individuals only. Sharing access cards or locker access is not permitted for security reasons.',
          ),
          _buildFaqItem(
            'What should I do if my locker is not working?',
            'First, ensure your RFID card is properly registered and your assignment is active. If issues persist, contact the system administrator.',
          ),
          _buildFaqItem(
            'How can I see my access history?',
            'Use the "Access History" option in Quick Actions on your dashboard to view your recent locker access attempts.',
          ),
          _buildFaqItem(
            'Who can I contact for technical support?',
            'Contact your system administrator or IT support team for any technical issues or questions about the locker system.',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Q',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}