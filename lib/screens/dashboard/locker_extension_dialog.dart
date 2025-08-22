import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LockerExtensionDialog extends StatefulWidget {
  const LockerExtensionDialog({Key? key}) : super(key: key);

  @override
  State<LockerExtensionDialog> createState() => _LockerExtensionDialogState();
}

class _LockerExtensionDialogState extends State<LockerExtensionDialog> {
  bool _loading = true;
  Map<String, dynamic>? _assignment;
  String? _lockerId;
  String? _assignmentId;
  String? _error;
  bool _submitting = false;
  String? _successMsg;

  @override
  void initState() {
    super.initState();
    _fetchAssignment();
  }

  Future<void> _fetchAssignment() async {
    setState(() { _loading = true; _error = null; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = 'User not logged in.';
        _loading = false;
      });
      return;
    }
    try {
      final query = await FirebaseFirestore.instance
          .collection('lockerAssignments')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        setState(() {
          _error = 'No active locker assignment found.';
          _loading = false;
        });
        return;
      }
      final doc = query.docs.first;
      setState(() {
        _assignment = doc.data();
        _assignmentId = doc.id;
        _lockerId = doc['lockerId'];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch assignment.';
        _loading = false;
      });
    }
  }

  Future<void> _submitExtension(Duration duration) async {
    if (_assignment == null || _lockerId == null || _assignmentId == null) return;
    setState(() { _submitting = true; _successMsg = null; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('lockerExtensionRequests').add({
        'userId': user.uid,
        'lockerId': _lockerId,
        'assignmentId': _assignmentId,
        'requestedDuration': duration.inHours,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _successMsg = 'Extension request sent!';
        _submitting = false;
      });
    } catch (e) {
      setState(() {
        _successMsg = null;
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.access_time, color: Colors.orange),
          SizedBox(width: 8),
          Text('Extend Locker Time'),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Text(_error!, style: const TextStyle(color: Colors.red))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Locker: ${_lockerId ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Expires: ' +
                          (_assignment?['expiresAt'] != null
                              ? (_assignment!['expiresAt'] as Timestamp).toDate().toString()
                              : '-')),
                      const SizedBox(height: 16),
                      if (_successMsg != null)
                        Text(_successMsg!, style: const TextStyle(color: Colors.green)),
                      if (_successMsg == null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select extension duration:'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              children: [
                                _extensionButton('1 hour', const Duration(hours: 1)),
                                _extensionButton('2 hours', const Duration(hours: 2)),
                                _extensionButton('10 hours', const Duration(hours: 10)),
                                _extensionButton('24 hours', const Duration(hours: 24)),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _extensionButton(String label, Duration duration) {
    return ElevatedButton(
      onPressed: _submitting
          ? null
          : () async {
              await _submitExtension(duration);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }
}
