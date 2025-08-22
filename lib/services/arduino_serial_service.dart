import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/locker_assignment_model.dart';
import '../services/access_log_service.dart';

class ArduinoSerialService {
  static String _portName = 'COM3'; // Update this to your actual COM port
  static const int _baudRate = 115200; // ESP8266 baud rate
  
  // SerialPort? _serialPort;
  // SerialPortReader? _serialReader;
  StreamController<String>? _dataController;
  final AccessLogService _accessLogService = AccessLogService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isConnected = false;
  String? _currentLockerId;
  
  // Getters
  bool get isConnected => _isConnected;
  Stream<String>? get dataStream => _dataController?.stream;
  String get portName => _portName;
  
  /// Configure serial port (call before connect)
  static void setPortName(String portName) {
    _portName = portName;
  }
  
  /// Initialize serial connection to Arduino using flutter_libserialport
  Future<bool> connect({String? lockerId}) async {
    try {
      _currentLockerId = lockerId;
      _dataController = StreamController<String>.broadcast();
      
      _serialPort = SerialPort(_portName);
      if (!_serialPort!.openReadWrite()) {
        _isConnected = false;
        return false;
      }
      _serialPort!.config.baudRate = _baudRate;
      _serialReader = SerialPortReader(_serialPort!);
      _serialReader!.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _handleArduinoData,
            onError: _handleError,
            onDone: _handleDisconnection,
          );
      _isConnected = true;
      await Future.delayed(const Duration(milliseconds: 1000));
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }
  
  /// Disconnect from Arduino
  Future<void> disconnect() async {
    try {
      _serialReader?.close();
      _serialPort?.close();
      await _dataController?.close();
      _isConnected = false;
    } catch (e) {
      // Error during disconnection
    }
  }
  
  /// Send command to Arduino
  Future<void> sendCommand(String command) async {
    if (!_isConnected || _serialPort == null) {
      throw Exception('Arduino not connected');
    }
    try {
      // Write command with newline
      final cmd = (command + '\n').codeUnits;
      _serialPort!.write(cmd);
      _dataController?.add('SENT: $command');
    } catch (e) {
      _dataController?.add('ERROR: Failed to send command - $e');
      rethrow;
    }
  }
  
  /// Handle incoming data from Arduino
  void _handleArduinoData(String data) async {
    _dataController?.add(data);
    
    try {
      if (data.startsWith('RFID_SCAN:')) {
        // Extract UID from RFID scan
        String uid = data.substring('RFID_SCAN:'.length).trim();
        await processRFIDScan(uid);
      } else if (data.startsWith('TAMPER_ALERT:')) {
        // Handle tamper alert
        await _handleTamperAlert(data);
      } else if (data.startsWith('STATUS_REPORT:')) {
        // Handle status report
        _handleStatusReport(data);
      }
    } catch (e) {
      _dataController?.add('Error processing Arduino data: $e');
    }
  }

  /// Process RFID scan with tap-to-toggle functionality
  Future<void> processRFIDScan(String rfidUid) async {
    try {
      _dataController?.add('Processing RFID: $rfidUid');
      
      // Check Firebase for user with this RFID
      final userQuery = await _firestore
          .collection('users')
          .where('rfidUid', isEqualTo: rfidUid.toUpperCase())
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      
      if (userQuery.docs.isEmpty) {
        _dataController?.add('RFID not registered or user not active');
        await sendCommand('ACCESS_DENIED');
        await _logAccess(rfidUid, 'denied', 'RFID not registered or user not active');
        return;
      }
      
      final userDoc = userQuery.docs.first;
      final userId = userDoc.id;
      final userData = userDoc.data();
      final userName = userData['name'] ?? 'Unknown User';
      
      // Check for active locker assignment
      final assignmentQuery = await _firestore
          .collection('lockerAssignments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      
      if (assignmentQuery.docs.isEmpty) {
        _dataController?.add('No locker assigned to user: $userName');
        await sendCommand('ACCESS_DENIED');
        await _logAccess(rfidUid, 'denied', 'No locker assigned to this user', userId: userId, userName: userName);
        return;
      }
      
      final assignmentDoc = assignmentQuery.docs.first;
      final assignmentData = assignmentDoc.data();
      final expiresAt = assignmentData['expiresAt'] as Timestamp?;
      
      // Check if assignment is expired
      if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
        _dataController?.add('Locker assignment expired for user: $userName');
        await sendCommand('ACCESS_DENIED');
        await _logAccess(rfidUid, 'denied', 'Locker assignment has expired', userId: userId, userName: userName);
        return;
      }
      
      // Access granted - toggle lock state
      _dataController?.add('Access granted for user: $userName - Toggling lock');
      await sendCommand('ACCESS_GRANTED');
      await _logAccess(rfidUid, 'allowed', 'Valid assignment found - Lock toggled', userId: userId, userName: userName);
      
    } catch (e) {
      _dataController?.add('Error processing RFID: $e');
      await sendCommand('ACCESS_DENIED');
      await _logAccess(rfidUid, 'denied', 'System error occurred');
    }
  }

  /// Handle tamper alert
  Future<void> _handleTamperAlert(String data) async {
    try {
      final alertMessage = data.substring('TAMPER_ALERT:'.length).trim();
      
      // Log security event to Firebase
      await _firestore.collection('security_events').add({
        'type': 'tamper_alert',
        'lockerId': _currentLockerId,
        'message': alertMessage,
        'severity': 'high',
        'timestamp': FieldValue.serverTimestamp(),
        'resolved': false,
      });
      
      _dataController?.add('Security alert logged: $alertMessage');
      
    } catch (e) {
      _dataController?.add('Error handling tamper alert: $e');
    }
  }

  /// Handle status report
  void _handleStatusReport(String data) {
    try {
      // Process status data as needed
    } catch (e) {
      _dataController?.add('Error parsing status report: $e');
    }
  }

  /// Handle connection errors
  void _handleError(dynamic error) {
    _isConnected = false;
  }
  
  /// Handle disconnection
  void _handleDisconnection() {
    _isConnected = false;
  }

  /// Log access attempt to Firebase
  Future<void> _logAccess(String rfidUid, String result, String reason, {String? userId, String? userName}) async {
    try {
      await _accessLogService.logAccess(
        userId: userId ?? 'unknown',
        userName: userName ?? 'Unknown User',
        rfidUid: rfidUid,
        result: result,
        details: reason,
        lockerId: _currentLockerId,
      );
      _dataController?.add('Access logged: $result - $reason');
    } catch (e) {
      _dataController?.add('Failed to log access: $e');
    }
  }
}