import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/access_log_model.dart';

class AccessLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Create access log
  Future<void> createAccessLog(AccessLog log) async {
    await _firestore.collection('access_logs').add(log.toMap());
  }

  // Get all access logs (admin only)
  Stream<List<AccessLog>> getAllAccessLogs() {
    return _firestore
        .collection('access_logs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
    });
  }

  // Get user's access logs
  Stream<List<AccessLog>> getUserAccessLogs(String userId) {
    return _firestore
        .collection('access_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
    });
  }

  // Get access logs for today
  Stream<List<AccessLog>> getTodayAccessLogs() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
    });
  }

  // Get access logs for yesterday
  Stream<List<AccessLog>> getYesterdayAccessLogs() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

    return _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
    });
  }

  // Get access logs for last week
  Stream<List<AccessLog>> getLastWeekAccessLogs() {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));

    return _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeek))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
    });
  }

  // Get access logs for last month
  Stream<List<AccessLog>> getLastMonthAccessLogs() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);

    return _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonth))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
    });
  }

  // Get access count for today
  Future<int> getTodayAccessCount() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final query = await _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return query.docs.length;
  }

  // Get access count for yesterday
  Future<int> getYesterdayAccessCount() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final startOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfDay = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

    final query = await _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return query.docs.length;
  }

  // Get access count for last week
  Future<int> getLastWeekAccessCount() async {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));

    final query = await _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeek))
        .get();

    return query.docs.length;
  }

  // Get access count for last month
  Future<int> getLastMonthAccessCount() async {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, now.day);

    final query = await _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonth))
        .get();

    return query.docs.length;
  }

  // Get access statistics
  Future<Map<String, dynamic>> getAccessStatistics() async {
    final todayCount = await getTodayAccessCount();
    final yesterdayCount = await getYesterdayAccessCount();
    final weekCount = await getLastWeekAccessCount();
    final monthCount = await getLastMonthAccessCount();

    // Get success/failure counts for today
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final successQuery = await _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('result', isEqualTo: 'allowed')
        .get();

    final failureQuery = await _firestore
        .collection('access_logs')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where('result', isEqualTo: 'denied')
        .get();

    return {
      'today': todayCount,
      'yesterday': yesterdayCount,
      'lastWeek': weekCount,
      'lastMonth': monthCount,
      'todaySuccess': successQuery.docs.length,
      'todayFailure': failureQuery.docs.length,
    };
  }

  // Get user's access count for today
  Future<int> getUserTodayAccessCount(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final query = await _firestore
        .collection('access_logs')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return query.docs.length;
  }

  // Filter access logs by result
  Stream<List<AccessLog>> getAccessLogsByResult(AccessResult result) {
    return _firestore
        .collection('access_logs')
        .where('result', isEqualTo: result.toString().split('.').last)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AccessLog.fromDoc(doc)).toList();
    });
  }

  // Log access attempt (used by Arduino service)
  Future<void> logAccess({
    required String userId,
    required String userName,
    String? lockerId, // Not used in current model but kept for compatibility
    required String rfidUid,
    required String result,
    String? method, // Not used in current model but kept for compatibility
    String? details,
  }) async {
    final accessLog = AccessLog(
      id: '', // Will be auto-generated by Firestore
      userId: userId,
      userName: userName,
      rfidUid: rfidUid,
      result: result == 'allowed' ? AccessResult.allowed : AccessResult.denied,
      timestamp: DateTime.now(),
      reason: details,
    );
    
    await createAccessLog(accessLog);
  }

  // Delete access log (admin only)
  Future<void> deleteAccessLog(String logId) async {
    await _firestore.collection('access_logs').doc(logId).delete();
  }
}