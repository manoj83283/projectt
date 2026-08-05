import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// ✅ SAFE ACCESS
  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );

    return instance ?? AppLocalizations(const Locale('en'));
  }

  /// ✅ SUPPORTED LANGUAGE CODES
  static const List<String> supportedLanguages = [
    'en',
    'hi',
    'te',
    'ta',
    'kn',
    'ml',
    'mr',
    'bn',
  ];

  /// ✅ REQUIRED BY main.dart
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

  static final Map<String, Map<String, String>> _localizedValues = {
    "en": {
      "home": "Home",
      "settings": "Settings",
      "logout": "Logout",
      "language": "Language",
    },
    "hi": {
      "home": "होम",
      "settings": "सेटिंग्स",
      "logout": "लॉगआउट",
      "language": "भाषा",
    },
    "te": {
      "home": "హోమ్",
      "settings": "సెట్టింగ్స్",
      "logout": "లాగౌట్",
      "language": "భాష",
    },
    "ta": {
      "home": "முகப்பு",
      "settings": "அமைப்புகள்",
      "logout": "வெளியேறு",
      "language": "மொழி",
    },
    "kn": {
      "home": "ಮುಖಪುಟ",
      "settings": "ಸೆಟ್ಟಿಂಗ್‌ಗಳು",
      "logout": "ಲಾಗ್‌ಔಟ್",
      "language": "ಭಾಷೆ",
    },
    "ml": {
      "home": "ഹോം",
      "settings": "സജ്ജീകരണങ്ങൾ",
      "logout": "ലോഗ്‌ഔട്ട്",
      "language": "ഭാഷ",
    },
    "mr": {
      "home": "होम",
      "settings": "सेटिंग्स",
      "logout": "लॉगआउट",
      "language": "भाषा",
    },
    "bn": {
      "home": "হোম",
      "settings": "সেটিংস",
      "logout": "লগআউট",
      "language": "ভাষা",
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues["en"]?[key] ??
        key;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLanguages.contains(
      locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}