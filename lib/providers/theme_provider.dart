import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }
  
  Future<void> _saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference(_isDarkMode);
    notifyListeners();
  }
  
  void setDarkMode() {
    if (!_isDarkMode) {
      _isDarkMode = true;
      _saveThemePreference(true);
      notifyListeners();
    }
  }
  
  void setLightMode() {
    if (_isDarkMode) {
      _isDarkMode = false;
      _saveThemePreference(false);
      notifyListeners();
    }
  }
  
  // Official RapidKL Colors
  static const Color rapidKLRed = Color(0xFFED1C24);    // Official RapidKL Red
  static const Color rapidKLBlue = Color(0xFF003DA5);   // Official RapidKL Blue
  static const Color rapidKLLightGrey = Color(0xFFF5F5F5);
  static const Color rapidKLDarkGrey = Color(0xFF2D2D2D);
  
  // RapidKL Light Theme - Modern Transport System Design
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: const MaterialColor(0xFFED1C24, {
      50: Color(0xFFFFF3F3),
      100: Color(0xFFFFE6E6),
      200: Color(0xFFFFCCCC),
      300: Color(0xFFFF9999),
      400: Color(0xFFFF6666),
      500: Color(0xFFED1C24), // Primary RapidKL Red
      600: Color(0xFFD41920),
      700: Color(0xFFBB161C),
      800: Color(0xFFA21318),
      900: Color(0xFF891014),
    }),
    primaryColor: rapidKLRed,
    colorScheme: ColorScheme.fromSeed(
      seedColor: rapidKLRed,
      secondary: rapidKLBlue,
      brightness: Brightness.light,
      surface: Colors.white,
      background: rapidKLLightGrey,
    ),
    scaffoldBackgroundColor: rapidKLLightGrey,
    
    // AppBar Theme - RapidKL Red Header
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: rapidKLRed,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      centerTitle: false,
    ),
    
    // Card Theme - Clean Transport Cards
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // rounded-2xl equivalent
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Input Theme - Modern Form Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: rapidKLBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey[500],
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.poppins(
        color: Colors.grey[700],
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Button Themes - Bold RapidKL Style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: rapidKLRed,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: rapidKLRed.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // rounded-2xl
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: rapidKLBlue,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: rapidKLBlue, width: 2),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: rapidKLBlue,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Text Theme - Poppins Font
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: rapidKLDarkGrey,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: rapidKLDarkGrey,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: rapidKLDarkGrey,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: rapidKLDarkGrey,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.grey[700],
      ),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: rapidKLDarkGrey,
      size: 24,
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: 1,
    ),
  );

  // RapidKL Dark Theme - Enhanced Visibility and Modern Design
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: const MaterialColor(0xFFFF4757, {
      50: Color(0xFFFFF5F5),
      100: Color(0xFFFFE8E8),
      200: Color(0xFFFFD1D1),
      300: Color(0xFFFFB3B3),
      400: Color(0xFFFF8585),
      500: Color(0xFFFF4757), // Brighter red for dark mode
      600: Color(0xFFE63946),
      700: Color(0xFFCC2936),
      800: Color(0xFFB31B26),
      900: Color(0xFF990D16),
    }),
    primaryColor: const Color(0xFFFF4757), // Brighter red for better visibility
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF4757),
      secondary: Color(0xFF64B5F6), // Lighter blue for better contrast
      surface: Color(0xFF1E1E1E), // True black background
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFE1E1E1),
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    
    // AppBar Theme - Consistent with light theme but darker
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: const Color(0xFFFF4757),
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    
    // Card Theme - Modern dark cards with excellent contrast
    cardTheme: CardThemeData(
      elevation: 4,
      color: const Color(0xFF1E1E1E), // Material 3 dark surface
      shadowColor: Colors.black.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2A2A2A), width: 1), // Subtle border
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Input Theme - High contrast form fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF404040), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF404040), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: const Color(0xFF9E9E9E),
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.poppins(
        color: const Color(0xFFE1E1E1),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // Button Themes - Enhanced for dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF4757),
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: const Color(0xFFFF4757).withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF64B5F6),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: Color(0xFF64B5F6), width: 2),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF64B5F6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Text Theme - High contrast text for excellent readability
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFFFFFF),
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE1E1E1),
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFE1E1E1),
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFE1E1E1),
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: const Color(0xFFBDBDBD),
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF9E9E9E),
      ),
    ),
    
    // Icon Theme - High contrast icons
    iconTheme: const IconThemeData(
      color: Color(0xFFE1E1E1),
      size: 24,
    ),
    
    // List Tile Theme - Better contrast for lists
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFFE1E1E1),
      iconColor: Color(0xFFE1E1E1),
      tileColor: Color(0xFF1E1E1E),
    ),
    
    // Divider Theme - Subtle but visible dividers
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A2A),
      thickness: 1,
      space: 1,
    ),
    
    // Switch Theme - Better visibility
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFFF4757);
        }
        return const Color(0xFF9E9E9E);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFFFF4757).withOpacity(0.5);
        }
        return const Color(0xFF404040);
      }),
    ),
  );
}
