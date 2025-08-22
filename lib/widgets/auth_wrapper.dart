import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
