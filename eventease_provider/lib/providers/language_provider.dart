import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  // =========================================================
  // SUPPORTED LANGUAGES
  // =========================================================

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'Hindi',
    'te': 'Telugu',
    'ta': 'Tamil',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'mr': 'Marathi',
    'bn': 'Bengali',
  };

  // =========================================================
  // SUPPORTED LOCALES
  // =========================================================

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('te'),
    Locale('ta'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('bn'),
  ];

  // =========================================================
  // LOAD LANGUAGE
  // =========================================================

  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final code =
          prefs.getString(_languageKey) ?? 'en';

      if (supportedLanguages.containsKey(code)) {
        _locale = Locale(code);
      } else {
        _locale = const Locale('en');
      }

      notifyListeners();
    } catch (_) {}
  }

  // =========================================================
  // CHANGE LANGUAGE
  // =========================================================

  Future<void> changeLanguage(
    String code,
  ) async {
    try {
      if (!supportedLanguages.containsKey(code)) {
        return;
      }

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        _languageKey,
        code,
      );

      _locale = Locale(code);

      notifyListeners();
    } catch (_) {}
  }

  // =========================================================
  // SET LOCALE
  // =========================================================

  Future<void> setLocale(
    Locale locale,
  ) async {
    await changeLanguage(
      locale.languageCode,
    );
  }

  // =========================================================
  // RESET LANGUAGE
  // =========================================================

  Future<void> resetLanguage() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove(_languageKey);

      _locale = const Locale('en');

      notifyListeners();
    } catch (_) {}
  }

  // =========================================================
  // CHECK SELECTED
  // =========================================================

  bool isSelected(String code) {
    return _locale.languageCode == code;
  }

  // =========================================================
  // LANGUAGE NAME
  // =========================================================

  String getLanguageName(String code) {
    return supportedLanguages[code] ??
        'English';
  }

  // =========================================================
  // NATIVE LANGUAGE NAME
  // =========================================================

  String getNativeLanguageName(
    String code,
  ) {
    switch (code) {
      case 'en':
        return 'English';

      case 'hi':
        return 'हिन्दी';

      case 'te':
        return 'తెలుగు';

      case 'ta':
        return 'தமிழ்';

      case 'kn':
        return 'ಕನ್ನಡ';

      case 'ml':
        return 'മലയാളം';

      case 'mr':
        return 'मराठी';

      case 'bn':
        return 'বাংলা';

      default:
        return 'English';
    }
  }

  // =========================================================
  // CURRENT LANGUAGE
  // =========================================================

  String get currentLanguageName =>
      getLanguageName(
        _locale.languageCode,
      );

  String get currentNativeLanguageName =>
      getNativeLanguageName(
        _locale.languageCode,
      );

  // =========================================================
  // UI OPTIONS
  // =========================================================

  List<Map<String, String>> get languageOptions {
    return supportedLanguages.entries.map((entry) {
      return {
        'code': entry.key,
        'name': entry.value,
        'nativeName':
            getNativeLanguageName(entry.key),
      };
    }).toList();
  }
}