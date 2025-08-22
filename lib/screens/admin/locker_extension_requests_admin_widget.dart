import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/locker_assignment_model.dart';
import '../../models/user_model.dart';

class LockerExtensionRequestsAdminWidget extends StatelessWidget {
  const LockerExtensionRequestsAdminWidget({Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> _getAssignment(String assignmentId) async {
    final doc = await FirebaseFirestore.instance.collection('lockerAssignments').doc(assignmentId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<UserModel?> _getUser(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists ? UserModel.fromMap({'id': doc.id, ...doc.data()!}) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pending Locker Extension Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lockerExtensionRequests')
                  .where('status', isEqualTo: 'pending')
                  .orderBy('requestedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                print('DEBUG: Extension requests fetched: ' + (snapshot.data?.docs.length.toString() ?? 'null'));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No pending extension requests.');
                }
                final requests = snapshot.data!.docs;
print('DEBUG: All request docs:');
for (var doc in requests) {
  print(doc.data());
}
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final data = req.data() as Map<String, dynamic>;
                    final userId = data['userId'] ?? '';
                    final assignmentId = data['assignmentId'] ?? '';
                    final requestedDuration = data['requestedDuration'] ?? 0;
                    final lockerId = data['lockerId'] ?? '';
                    return FutureBuilder(
                      future: Future.wait([
                        _getAssignment(assignmentId),
                        _getUser(userId),
                      ]),
                      builder: (context, AsyncSnapshot<List<dynamic>> snap) {
                        if (!snap.hasData) {
                          return const ListTile(title: Text('Loading...'));
                        }
                        final assignment = snap.data![0] as Map<String, dynamic>?;
                        final user = snap.data![1] as UserModel?;
                        final userName = user?.name ?? 'Unknown';
                        final userEmail = user?.email ?? '';
                        final expiresAt = assignment?['expiresAt'] != null ? (assignment!['expiresAt'] as Timestamp).toDate() : null;
                        return ListTile(
                          leading: const Icon(Icons.access_time, color: Colors.orange),
                          title: Text('User: $userName'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (userEmail.isNotEmpty) Text(userEmail),
                              Text('Locker: $lockerId'),
                              if (expiresAt != null) Text('Current expiry: $expiresAt'),
                              Text('Requested extension: +${requestedDuration}h'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                tooltip: 'Approve',
                                onPressed: () async {
                                  final now = DateTime.now();
                                  final newExpiry = (expiresAt ?? now).add(Duration(hours: requestedDuration));
                                  // Update assignment expiry
                                  await FirebaseFirestore.instance.collection('lockerAssignments').doc(assignmentId).update({
                                    'expiresAt': Timestamp.fromDate(newExpiry),
                                    'updatedAt': FieldValue.serverTimestamp(),
                                  });
                                  // Mark request as approved
                                  await FirebaseFirestore.instance.collection('lockerExtensionRequests').doc(req.id).update({
                                    'status': 'approved',
                                    'approvedAt': FieldValue.serverTimestamp(),
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extension approved')));
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                tooltip: 'Reject',
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection('lockerExtensionRequests').doc(req.id).update({
                                    'status': 'rejected',
                                    'rejectedAt': FieldValue.serverTimestamp(),
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Extension rejected')));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
