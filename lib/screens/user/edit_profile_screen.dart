import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _icController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rfidUidController = TextEditingController();
  // final RfidService _rfidService = RfidService();

  bool _isLoading = false;
  bool _isLoadingData = true;
  UserModel? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() => _isLoadingData = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Load user data from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          _userData = UserModel.fromMap({
            'id': doc.id,
            ...doc.data()!,
          });
          
          // Populate form fields
          _nameController.text = _userData?.name ?? '';
          _emailController.text = _userData?.email ?? '';
          _icController.text = _userData?.ic ?? '';
          _phoneController.text = _userData?.phoneNumber ?? '';
          _rfidUidController.text = _userData?.rfidUid ?? '';
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
          
          _userData = newUser;
          _nameController.text = _userData?.name ?? '';
          _emailController.text = _userData?.email ?? '';
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
      setState(() => _isLoadingData = false);
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Update user data directly in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text.trim(),
          'ic': _icController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'rfidUid': _rfidUidController.text.trim().toUpperCase(),
        });

        // Update display name in Firebase Auth
        await user.updateDisplayName(_nameController.text.trim());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getStatusText() {
    if (_userData == null) return 'Loading...';
    
    switch (_userData!.status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.rejected:
        return 'Rejected';
      case UserStatus.pending:
      default:
        return 'Pending Approval';
    }
  }

  IconData _getStatusIcon() {
    if (_userData == null) return Icons.info_outline;
    
    switch (_userData!.status) {
      case UserStatus.active:
        return Icons.check_circle;
      case UserStatus.rejected:
        return Icons.cancel;
      case UserStatus.pending:
      default:
        return Icons.schedule;
    }
  }

  Color _getStatusColor() {
    if (_userData == null) return Colors.grey;
    
    switch (_userData!.status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.rejected:
        return Colors.red;
      case UserStatus.pending:
      default:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _icController.dispose();
    _phoneController.dispose();
    _rfidUidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'SAVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor, // Red
                            const Color(0xFF3182CE), // Blue
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF3182CE), // Blue
                              Theme.of(context).primaryColor, // Red
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email (Read-only)
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              
              // IC Number
              TextFormField(
                controller: _icController,
                decoration: InputDecoration(
                  labelText: 'IC Number',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: 'Enter your IC number',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 12) {
                    return 'IC number should be at least 12 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: 'Enter your phone number',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 10) {
                    return 'Phone number should be at least 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // RFID UID
              TextFormField(
                controller: _rfidUidController,
                decoration: InputDecoration(
                  labelText: 'RFID Card UID',
                  prefixIcon: const Icon(Icons.nfc),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: 'Enter RFID card UID from staff',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 4) {
                    return 'RFID UID should be at least 4 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Status (Read-only)
              TextFormField(
                initialValue: _getStatusText(),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Account Status',
                  prefixIcon: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 24),
              
              // Info Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Important Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• IC and RFID UID are required for locker access\n'
                        '• Admin approval is needed after updating RFID UID\n'
                        '• Contact staff to get your RFID card UID',
                        style: TextStyle(fontSize: 14),
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
}
