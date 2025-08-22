import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _currentUserModel;
  
  /// Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;
      
      final userData = userDoc.data()!;
      _currentUserModel = UserModel.fromMap({
        'id': user.uid,
        ...userData,
      });
      
      return _currentUserModel!.role == UserRole.admin;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if current user has admin or manager role
  Future<bool> isCurrentUserAdminOrManager() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;
      
      final userData = userDoc.data()!;
      _currentUserModel = UserModel.fromMap({
        'id': user.uid,
        ...userData,
      });
      
      return _currentUserModel!.role == UserRole.admin || 
             _currentUserModel!.role == UserRole.manager;
    } catch (e) {
      return false;
    }
  }
  
  /// Get current user model
  UserModel? get currentUserModel => _currentUserModel;
  
  /// Promote user to admin (only existing admin can do this)
  Future<void> promoteToAdmin(String userId) async {
    if (!await isCurrentUserAdmin()) {
      throw Exception('Only admins can promote users to admin');
    }
    
    await _firestore.collection('users').doc(userId).update({
      'role': UserRole.admin.toString().split('.').last,
    });
  }
  
  /// Promote user to manager (admin or manager can do this)
  Future<void> promoteToManager(String userId) async {
    if (!await isCurrentUserAdminOrManager()) {
      throw Exception('Only admins or managers can promote users to manager');
    }
    
    await _firestore.collection('users').doc(userId).update({
      'role': UserRole.manager.toString().split('.').last,
    });
  }
  
  /// Demote user to regular user (only admin can do this)
  Future<void> demoteToUser(String userId) async {
    if (!await isCurrentUserAdmin()) {
      throw Exception('Only admins can demote users');
    }
    
    await _firestore.collection('users').doc(userId).update({
      'role': UserRole.user.toString().split('.').last,
    });
  }
  
  /// Clear cached user data (call on logout)
  void clearCache() {
    _currentUserModel = null;
  }
}