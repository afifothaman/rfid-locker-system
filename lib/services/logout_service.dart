import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LogoutService {
  static Future<void> showLogoutDialog(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.of(dialogContext).pop();
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext loadingContext) => const AlertDialog(
                  content: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Signing out...'),
                    ],
                  ),
                ),
              );
              
              try {
                // Perform logout
                await authProvider.signOut();
                
                // Close loading dialog
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                
                // Navigate to login screen and clear all routes
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                // Close loading dialog
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  /// Quick logout without confirmation dialog (for emergency cases)
  static Future<void> quickLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    try {
      await authProvider.signOut();
      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}