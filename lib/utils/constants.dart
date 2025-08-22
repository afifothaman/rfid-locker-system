import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Smart Locker System';
  static const String appVersion = '1.0.0';

  // API Endpoints (if any)
  static const String baseUrl = 'https://api.example.com';

  // Local Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'theme_mode';

  // Form Validation
  static final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    caseSensitive: false,
  );

  static final RegExp phoneRegex = RegExp(r'^[0-9]{10,15}$');
  static final RegExp icNumberRegex = RegExp(r'^[0-9]{6}-[0-9]{2}-[0-9]{4}$');
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  // Error Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidIcNumber = 'Please enter a valid IC number (e.g., 900101-01-1234)';
  static const String weakPassword = 'Password must be at least 8 characters long and contain both letters and numbers';
  static const String passwordMismatch = 'Passwords do not match';

  // Default Padding
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets defaultHorizontalPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets defaultVerticalPadding = EdgeInsets.symmetric(vertical: 16.0);

  // Default Border Radius
  static const double defaultBorderRadius = 8.0;
  static BorderRadius borderRadius = BorderRadius.circular(defaultBorderRadius);
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // API Timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 10;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String accessLogsCollection = 'access_logs';
  static const String lockersCollection = 'lockers';
  static const String settingsCollection = 'settings';
}

class AppAssets {
  // Image Paths
  static const String logo = 'assets/images/logo.png';
  static const String placeholder = 'assets/images/placeholder.jpg';
  static const String defaultAvatar = 'assets/images/default_avatar.png';
  
  // Icon Paths
  static const String iconHome = 'assets/icons/home.svg';
  static const String iconProfile = 'assets/icons/profile.svg';
  static const String iconHistory = 'assets/icons/history.svg';
  static const String iconSettings = 'assets/icons/settings.svg';
  static const String iconLock = 'assets/icons/lock.svg';
  static const String iconUnlock = 'assets/icons/unlock.svg';
}

class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // User Routes
  static const String home = '/';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String accessHistory = '/access-history';
  
  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String userManagement = '/admin/users';
  static const String accessLogs = '/admin/access-logs';
  static const String lockerManagement = '/admin/lockers';
  static const String settings = '/admin/settings';
  
  // Other Routes
  static const String rfidScan = '/rfid-scan';
  static const String accessResult = '/access-result';
  static const String notFound = '/not-found';
}
