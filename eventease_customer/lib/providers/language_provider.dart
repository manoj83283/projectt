import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider() {
    loadLanguage();
  }

  static const String _languageKey =
      'selected_language';

  Locale _locale = const Locale('en');

  bool _isLoading = false;

  // ==========================================
  // SUPPORTED LANGUAGES
  // ==========================================

  static const List<Locale>
      supportedLocales = [
    Locale('en'),
    Locale('te'),
    Locale('hi'),
    Locale('ta'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('bn'),
    Locale('gu'),
    Locale('pa'),
    Locale('or'),
  ];

  // ==========================================
  // LANGUAGE MAP
  // ==========================================

  static const Map<String, String>
      languageNames = {
    'en': 'English',
    'te': 'Telugu',
    'hi': 'Hindi',
    'ta': 'Tamil',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'mr': 'Marathi',
    'bn': 'Bengali',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'or': 'Odia',
  };

  // ==========================================
  // GETTERS
  // ==========================================

  Locale get locale => _locale;

  bool get isLoading => _isLoading;

  String get languageCode =>
      _locale.languageCode;

  String get languageName =>
      languageNames[
          _locale.languageCode] ??
      'English';

  // ==========================================
  // SET LOADING
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // LOAD LANGUAGE
  // ==========================================

  Future<void> loadLanguage() async {
    try {
      _setLoading(true);

      final prefs =
          await SharedPreferences
              .getInstance();

      final code =
          prefs.getString(
                _languageKey,
              ) ??
              'en';

      _locale = Locale(code);

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CHANGE LANGUAGE
  // ==========================================

  Future<void> changeLanguage(
    String languageCode,
  ) async {
    _locale = Locale(languageCode);

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      _languageKey,
      languageCode,
    );

    notifyListeners();
  }

  // ==========================================
  // ENGLISH
  // ==========================================

  Future<void> setEnglish() async {
    await changeLanguage('en');
  }

  // ==========================================
  // TELUGU
  // ==========================================

  Future<void> setTelugu() async {
    await changeLanguage('te');
  }

  // ==========================================
  // HINDI
  // ==========================================

  Future<void> setHindi() async {
    await changeLanguage('hi');
  }

  // ==========================================
  // TAMIL
  // ==========================================

  Future<void> setTamil() async {
    await changeLanguage('ta');
  }

  // ==========================================
  // KANNADA
  // ==========================================

  Future<void> setKannada() async {
    await changeLanguage('kn');
  }

  // ==========================================
  // MALAYALAM
  // ==========================================

  Future<void> setMalayalam() async {
    await changeLanguage('ml');
  }

  // ==========================================
  // MARATHI
  // ==========================================

  Future<void> setMarathi() async {
    await changeLanguage('mr');
  }

  // ==========================================
  // BENGALI
  // ==========================================

  Future<void> setBengali() async {
    await changeLanguage('bn');
  }

  // ==========================================
  // GUJARATI
  // ==========================================

  Future<void> setGujarati() async {
    await changeLanguage('gu');
  }

  // ==========================================
  // PUNJABI
  // ==========================================

  Future<void> setPunjabi() async {
    await changeLanguage('pa');
  }

  // ==========================================
  // ODIA
  // ==========================================

  Future<void> setOdia() async {
    await changeLanguage('or');
  }

  // ==========================================
  // RESET
  // ==========================================

  Future<void> reset() async {
    await changeLanguage('en');
  }
}