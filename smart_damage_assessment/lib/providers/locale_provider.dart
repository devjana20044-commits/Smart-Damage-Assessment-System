import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app locale/language state
class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale? _locale;
  bool _isLoading = false;

  LocaleProvider() {
    _loadSavedLocale();
  }

  // Getters
  Locale? get locale => _locale;
  bool get isLoading => _isLoading;
  
  // Check if current locale is Arabic
  bool get isArabic => _locale?.languageCode == 'ar';

  /// Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localeKey);
      
      if (savedLocale != null) {
        // Parse locale string (e.g., 'en' or 'ar')
        _locale = Locale(savedLocale);
        print('🌍 LocaleProvider - Loaded saved locale: $savedLocale');
      } else {
        // Default to English
        _locale = const Locale('en');
        print('🌍 LocaleProvider - Using default locale: en');
      }
    } catch (e) {
      print('❌ LocaleProvider - Failed to load locale: $e');
      _locale = const Locale('en'); // Fallback
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Change app locale
  Future<void> changeLocale(Locale newLocale) async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
      
      _locale = newLocale;
      print('🌍 LocaleProvider - Changed locale to: ${newLocale.languageCode}');
      
      notifyListeners();
    } catch (e) {
      print('❌ LocaleProvider - Failed to change locale: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    final newLocale = isArabic ? const Locale('en') : const Locale('ar');
    await changeLocale(newLocale);
  }

  /// Get current language name
  String get currentLanguageName {
    if (isArabic) return 'العربية';
    return 'English';
  }

  /// Get current language code
  String get currentLanguageCode {
    return _locale?.languageCode ?? 'en';
  }

  /// Get supported locales
  static List<Locale> get supportedLocales {
    return const [
      Locale('en'), // English
      Locale('ar'), // Arabic
    ];
  }

  /// Get locale from string
  static Locale localeFromString(String localeString) {
    switch (localeString) {
      case 'ar':
        return const Locale('ar');
      default:
        return const Locale('en');
    }
  }

  /// Clear saved locale (reset to default)
  Future<void> clearLocale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
    _locale = const Locale('en');
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}