import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RfidAccessResultScreen extends StatelessWidget {
  final String rfidUid;
  final bool isAccessGranted;
  final String reason;
  final DateTime timestamp;

  RfidAccessResultScreen({
    Key? key,
    required this.rfidUid,
    required this.isAccessGranted,
    required this.reason,
    DateTime? timestamp,
  })  : timestamp = timestamp ?? DateTime.now(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: isAccessGranted ? colorScheme.primaryContainer : colorScheme.errorContainer,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result Icon
            Icon(
              isAccessGranted ? Icons.lock_open : Icons.lock_outline,
              size: 120,
              color: isAccessGranted ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
            ),
            const SizedBox(height: 24),
            
            // Result Text
            Text(
              isAccessGranted ? 'ACCESS GRANTED' : 'ACCESS DENIED',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isAccessGranted ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            
            // Card with details
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // RFID UID
                  _buildDetailRow('RFID UID', rfidUid, context),
                  const Divider(),
                  
                  // Status
                  _buildDetailRow(
                    'Status',
                    isAccessGranted ? 'Approved' : 'Denied',
                    context,
                    isHighlighted: true,
                    isSuccess: isAccessGranted,
                  ),
                  const Divider(),
                  
                  // Reason
                  _buildDetailRow('Reason', reason, context),
                  const Divider(),
                  
                  // Timestamp
                  _buildDetailRow(
                    'Time',
                    DateFormat('MMM d, yyyy - hh:mm:ss a').format(timestamp),
                    context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  // Try Again Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Simulate scanning again
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isAccessGranted 
                              ? colorScheme.onPrimaryContainer 
                              : colorScheme.onErrorContainer,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'SCAN AGAIN',
                        style: TextStyle(
                          color: isAccessGranted 
                              ? colorScheme.onPrimaryContainer 
                              : colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Done Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to home/dashboard
                        Navigator.popUntil(
                          context, 
                          (route) => route.isFirst,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAccessGranted 
                            ? colorScheme.onPrimaryContainer 
                            : colorScheme.onErrorContainer,
                        foregroundColor: isAccessGranted 
                            ? colorScheme.primaryContainer 
                            : colorScheme.errorContainer,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'DONE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Admin Login Button (only show if access was denied)
            if (!isAccessGranted) ...[  
              TextButton(
                onPressed: () {
                  // Navigate to admin login
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const AdminLoginScreen(),
                  //   ),
                  // );
                },
                child: Text(
                  'Admin Login',
                  style: TextStyle(
                    color: colorScheme.onErrorContainer.withOpacity(0.8),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context, 
      {bool isHighlighted = false, bool isSuccess = false}) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
                color: isHighlighted
                    ? (isSuccess ? Colors.green[700] : Colors.red[700])
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
