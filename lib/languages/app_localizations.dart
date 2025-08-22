import 'package:flutter/material.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

abstract class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    DefaultMaterialLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ms'),
  ];

  // Common
  String get appName;
  String get rapidKL;
  String get locker;
  String get settings;
  String get close;
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get update;
  String get loading;
  String get error;
  String get success;
  String get warning;
  String get info;

  // Authentication
  String get login;
  String get register;
  String get logout;
  String get email;
  String get password;
  String get confirmPassword;
  String get forgotPassword;
  String get createAccount;
  String get alreadyHaveAccount;
  String get dontHaveAccount;
  String get signInWithGoogle;
  String get welcomeBack;
  String get createNewAccount;

  // Dashboard
  String get dashboard;
  String get welcomeMessage;
  String get accountStatus;
  String get rfidCard;
  String get accessToday;
  String get quickActions;
  String get recentActivity;
  String get updateRfidNumber;
  String get myProfile;
  String get accessHistory;
  String get systemStatus;

  // Profile
  String get profile;
  String get name;
  String get phoneNumber;
  String get icNumber;
  String get rfidUid;
  String get status;
  String get active;
  String get pending;
  String get rejected;
  String get editProfile;
  String get updateProfile;

  // Settings
  String get appearance;
  String get darkMode;
  String get darkModeDescription;
  String get language;
  String get selectLanguage;
  String get notifications;
  String get enableNotifications;
  String get emailNotifications;
  String get pushNotifications;
  String get account;
  String get changePassword;
  String get system;
  String get privacyPolicy;
  String get termsOfService;
  String get aboutApp;

  // Access History
  String get accessGranted;
  String get accessDenied;
  String get today;
  String get pastWeek;
  String get pastMonth;
  String get allTime;
  String get noAccessHistory;
  String get unableToLoadHistory;

  // Admin
  String get adminDashboard;
  String get manageUsers;
  String get accessLogs;
  String get totalUsers;
  String get pendingUsers;
  String get activeUsers;
  String get userDetails;
  String get approve;
  String get reject;
  String get suspend;
  String get viewDetails;

  // Messages
  String get profileUpdatedSuccessfully;
  String get rfidUpdatedSuccessfully;
  String get passwordUpdatedSuccessfully;
  String get languageChanged;
  String get logoutConfirmation;
  String get deleteConfirmation;
  String get operationSuccessful;
  String get operationFailed;

  // Access Control Messages
  String get rfidNotRegistered;
  String get userNotActive;
  String get noLockerAssignment;
  String get lockerAssignmentExpired;
  String get systemError;
  String get accessGrantedMessage;
  String get accessDeniedMessage;

  // Additional UI Strings
  String get manageLockers;
  String get analytics;
  String get users;
  String get lockers;
  String get assignments;
  String get logs;
  String get refresh;
  String get filter;
  String get search;
  String get clear;
  String get apply;
  String get reset;

  // Form Labels and Validation
  String get fullName;
  String get enterFullName;
  String get pleaseEnterFullName;
  String get emailAddress;
  String get enterEmail;
  String get pleaseEnterEmail;
  String get pleaseEnterValidEmail;
  String get createPassword;
  String get pleaseEnterPassword;
  String get passwordMinLength;
  String get icNumberOptional;
  String get enterIcNumber;
  String get phoneNumberOptional;
  String get enterPhoneNumber;
  String get signIn;
  String get smartLockerSystem;
  String get accessLockerSystem;
  String get joinSmartLockerSystem;
  String get invalidEmailPassword;
  String get tooManyAttempts;
  String get errorOccurred;
  String get forgotPasswordSoon;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ms'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'ms':
        return AppLocalizationsMs();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}