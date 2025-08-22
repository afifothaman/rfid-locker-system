import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'utils/arduino_test_utility.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/access_logs_provider.dart';

// Localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'languages/app_localizations.dart';

// Services
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/locker_service.dart';

// Firebase Options
import 'firebase_options.dart';
import 'widgets/auth_wrapper.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations - only for mobile
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization failed - handle gracefully
  }

  // Initialize Notification Service
  try {
    await NotificationService().initialize();
  } catch (e) {
    // Notification service initialization failed - handle gracefully
  }

  // Initialize Locker Service (check for auto-return lockers)
  try {
    final LockerService lockerService = LockerService();
    await lockerService.checkAndAutoReturnLockers();
  } catch (e) {
    // Locker service initialization failed - handle gracefully
  }

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AccessLogsProvider()),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: Provider.of<AuthService>(context, listen: false),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return MaterialApp(
      title: 'RFID Locker System',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      
      // Localization support
      locale: languageProvider.currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        // Admin routes removed - implement these later
        // '/admin/login': (context) => const AdminLoginScreen(),
        // '/admin/dashboard': (context) => const AdminDashboardScreen(),
      },
      builder: (context, child) {
        // Apply text scaling based on device settings
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(mediaQuery.textScaler.scale(1.0).clamp(0.9, 1.1)),
          ),
          child: child!,
        );
      },
    );
  }
}
