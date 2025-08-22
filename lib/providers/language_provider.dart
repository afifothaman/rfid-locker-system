import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'selectedLanguage';
  Locale _currentLocale = const Locale('en'); // Default to English
  
  Locale get currentLocale => _currentLocale;
  
  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ms'), // Bahasa Melayu
  ];
  
  LanguageProvider() {
    _loadLanguagePreference();
  }
  
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    
    // Find the locale based on language code
    _currentLocale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('en'),
    );
    
    notifyListeners();
  }
  
  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }
  
  Future<void> changeLanguage(String languageCode) async {
    final newLocale = supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => const Locale('en'),
    );
    
    if (newLocale != _currentLocale) {
      _currentLocale = newLocale;
      await _saveLanguagePreference(languageCode);
      notifyListeners();
    }
  }
  
  String get currentLanguageName {
    switch (_currentLocale.languageCode) {
      case 'ms':
        return 'Bahasa Melayu';
      case 'en':
      default:
        return 'English';
    }
  }
  
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isMalay => _currentLocale.languageCode == 'ms';
}