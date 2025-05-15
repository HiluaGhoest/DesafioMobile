import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String LANGUAGE_CODE = 'languageCode';
  static const String COUNTRY_CODE = 'countryCode';
  
  Locale _locale = const Locale('en', '');
  Locale get locale => _locale;
  
  // Initialize from shared preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(LANGUAGE_CODE);
    final countryCode = prefs.getString(COUNTRY_CODE) ?? '';
    
    if (languageCode != null) {
      _locale = Locale(languageCode, countryCode);
      notifyListeners();
    }
  }
  
  // Change the app's locale
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    
    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_CODE, locale.languageCode);
    await prefs.setString(COUNTRY_CODE, locale.countryCode ?? '');
    
    notifyListeners();
  }

  // Get all supported locales
  static List<Locale> get supportedLocales => [
    const Locale('en', ''), // English
    const Locale('pt', ''), // Portuguese
    const Locale('es', ''), // Spanish
  ];
  
  // Get the locale name based on the language code
  String getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'pt': return 'Português';
      case 'es': return 'Español';
      default: return 'English';
    }
  }
}
