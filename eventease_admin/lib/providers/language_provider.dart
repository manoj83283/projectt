import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  // =====================================================
  // GETTERS
  // =====================================================

  Locale get locale => _locale;

  String get currentLanguageCode =>
      _locale.languageCode;

  bool get isEnglish =>
      _locale.languageCode == 'en';

  bool get isHindi =>
      _locale.languageCode == 'hi';

  bool get isTelugu =>
      _locale.languageCode == 'te';

  bool get isTamil =>
      _locale.languageCode == 'ta';

  bool get isKannada =>
      _locale.languageCode == 'kn';

  bool get isMalayalam =>
      _locale.languageCode == 'ml';

  // =====================================================
  // SUPPORTED LANGUAGES
  // =====================================================

  static const List<Locale>
      supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('te'),
    Locale('ta'),
    Locale('kn'),
    Locale('ml'),
  ];

  // =====================================================
  // CHANGE LANGUAGE
  // =====================================================

  Future<void> changeLanguage(
    String languageCode,
  ) async {
    _locale = Locale(languageCode);

    notifyListeners();
  }

  // =====================================================
  // SET LOCALE
  // =====================================================

  Future<void> setLocale(
    Locale locale,
  ) async {
    _locale = locale;

    notifyListeners();
  }

  // =====================================================
  // ENGLISH
  // =====================================================

  Future<void> setEnglish() async {
    _locale = const Locale('en');

    notifyListeners();
  }

  // =====================================================
  // HINDI
  // =====================================================

  Future<void> setHindi() async {
    _locale = const Locale('hi');

    notifyListeners();
  }

  // =====================================================
  // TELUGU
  // =====================================================

  Future<void> setTelugu() async {
    _locale = const Locale('te');

    notifyListeners();
  }

  // =====================================================
  // TAMIL
  // =====================================================

  Future<void> setTamil() async {
    _locale = const Locale('ta');

    notifyListeners();
  }

  // =====================================================
  // KANNADA
  // =====================================================

  Future<void> setKannada() async {
    _locale = const Locale('kn');

    notifyListeners();
  }

  // =====================================================
  // MALAYALAM
  // =====================================================

  Future<void> setMalayalam() async {
    _locale = const Locale('ml');

    notifyListeners();
  }

  // =====================================================
  // LANGUAGE NAME
  // =====================================================

  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'hi':
        return 'Hindi';

      case 'te':
        return 'Telugu';

      case 'ta':
        return 'Tamil';

      case 'kn':
        return 'Kannada';

      case 'ml':
        return 'Malayalam';

      default:
        return 'English';
    }
  }

  // =====================================================
  // RESET
  // =====================================================

  Future<void> resetLanguage() async {
    _locale = const Locale('en');

    notifyListeners();
  }
}