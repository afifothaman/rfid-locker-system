import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../user/edit_profile_screen.dart';
import '../../services/logout_service.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  UserModel? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          setState(() {
            userData = UserModel.fromMap({
              'id': doc.id,
              ...doc.data()!,
            });
          });
        } else {
          // Create user document if it doesn't exist
          final newUser = UserModel(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
            phoneNumber: '',
            ic: '',
            rfidUid: '',
            status: UserStatus.pending,
            createdAt: DateTime.now(),
          );
          
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(newUser.toMap());
          
          setState(() {
            userData = newUser;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'My Profile',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              ).then((_) => _loadUserData());
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // RapidKL Profile Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor, // Red
                    const Color(0xFF3182CE), // Blue
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
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    
                    // User Name
                    Text(
                      userData?.name ?? 'N/A',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            userData?.status == UserStatus.active 
                                ? Icons.check_circle 
                                : userData?.status == UserStatus.rejected
                                    ? Icons.cancel
                                    : Icons.schedule,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            userData?.status == UserStatus.active 
                                ? 'Active' 
                                : userData?.status == UserStatus.rejected
                                    ? 'Rejected'
                                    : 'Pending Approval',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile Information
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Personal Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildInfoRow('Full Name', userData?.name ?? 'N/A', Icons.person),
                    _buildInfoRow('Email', userData?.email ?? 'N/A', Icons.email),
                    _buildInfoRow('Phone Number', userData?.phoneNumber?.isNotEmpty == true ? userData!.phoneNumber! : 'N/A', Icons.phone),
                    _buildInfoRow('IC Number', userData?.ic?.isNotEmpty == true ? userData!.ic! : 'N/A', Icons.credit_card),
                    _buildInfoRowWithAction('RFID Card UID', userData?.rfidUid?.isNotEmpty == true ? userData!.rfidUid! : 'N/A', Icons.nfc),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // User Information Card
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Getting Started',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTipItem('Complete your profile with IC and phone number'),
                    _buildTipItem('Get your RFID card number from RapidKL staff'),
                    _buildTipItem('Wait for admin approval to access lockers'),
                    _buildTipItem('Contact admin if you need assistance'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor, // Red
                          const Color(0xFF3182CE), // Blue
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        ).then((_) => _loadUserData());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: () => LogoutService.showLogoutDialog(context),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithAction(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (label == 'RFID Card UID')
                  IconButton(
                    onPressed: () => _showUpdateRfidDialog(context),
                    icon: Icon(
                      Icons.edit,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    tooltip: 'Update RFID',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: theme.primaryColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              const Text('Update RFID Number'),
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
                      
                      // Reload user data to reflect changes
                      _loadUserData();
                    } else {
                      // Handle different error types
                      if (result['error'] == 'RFID_UID_EXISTS') {
                        // Regular users always see privacy-safe dialog
                        _showRfidConflictDialog(context, result);
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

  // Show privacy-safe conflict dialog (Regular users)
  void _showRfidConflictDialog(BuildContext context, Map<String, dynamic> conflictInfo) {
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


}