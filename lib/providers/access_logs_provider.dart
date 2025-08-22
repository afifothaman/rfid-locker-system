import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccessLogsProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> _todayLogs = [];
  bool _isLoading = false;
  String? _error;

  List<QueryDocumentSnapshot> get todayLogs => _todayLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get todayCount => _todayLogs.length;

  // Fetch and filter today's logs
  Future<void> fetchTodayLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get user's access logs
      final snapshot = await FirebaseFirestore.instance
          .collection('access_logs')
          .where('userId', isEqualTo: user.uid)
          .limit(500)
          .get();

      final allLogs = snapshot.docs;
      
      // Filter for today's logs with proper timezone handling
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      _todayLogs = allLogs.where((doc) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        
        if (timestamp == null) return false;
        
        // Convert to local time for proper comparison
        final localTimestamp = timestamp.toLocal();
        
        // Check if log is from today (after start of day)
        return localTimestamp.isAfter(startOfDay) || localTimestamp.isAtSameMomentAs(startOfDay);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stream version for real-time updates
  Stream<List<QueryDocumentSnapshot>> getTodayLogsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('access_logs')
        .where('userId', isEqualTo: user.uid)
        .limit(100) // Reduced limit for faster loading
        .snapshots()
        .map((snapshot) {
      try {
        final allLogs = snapshot.docs;
        
        // Filter for today's logs with simpler logic
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        
        final todayLogs = allLogs.where((doc) {
          try {
            final data = doc.data();
            final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
            
            if (timestamp == null) return false;
            
            // Simple comparison without timezone conversion for now
            return timestamp.isAfter(startOfDay);
          } catch (e) {
            return false; // Skip problematic logs
          }
        }).toList();

        // Update internal state
        _todayLogs = todayLogs;
        
        return todayLogs;
      } catch (e) {
        return <QueryDocumentSnapshot>[];
      }
    }).handleError((error) {
      return <QueryDocumentSnapshot>[];
    });
  }
}