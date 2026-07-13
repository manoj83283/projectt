import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(
    BuildContext context,
  ) {
    return Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    )!;
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('te'),
    Locale('ta'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('bn'),
  ];

  static const LocalizationsDelegate<AppLocalizations>
      delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>>
      _localizedValues = {
    'en': {
      'app_name': 'EventEase',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'home': 'Home',
      'profile': 'Profile',
      'bookings': 'Bookings',
      'cart': 'Cart',
      'notifications': 'Notifications',
      'chat': 'Chat',
      'search': 'Search',
      'book_now': 'Book Now',
      'add_to_cart': 'Add To Cart',
      'checkout': 'Checkout',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit_profile': 'Edit Profile',
      'language': 'Language',
      'settings': 'Settings',
      'help_support': 'Help & Support',
      'privacy_policy': 'Privacy Policy',
      'terms_conditions': 'Terms & Conditions',
      'featured_services': 'Featured Services',
      'categories': 'Categories',
      'see_all': 'See All',
      'my_bookings': 'My Bookings',
    },

    'hi': {
      'app_name': 'इवेंटईज़',
      'login': 'लॉगिन',
      'register': 'पंजीकरण',
      'logout': 'लॉगआउट',
      'home': 'होम',
      'profile': 'प्रोफ़ाइल',
      'bookings': 'बुकिंग्स',
      'cart': 'कार्ट',
      'notifications': 'सूचनाएं',
      'chat': 'चैट',
      'search': 'खोजें',
      'book_now': 'अभी बुक करें',
      'add_to_cart': 'कार्ट में जोड़ें',
      'checkout': 'चेकआउट',
      'save': 'सेव करें',
      'cancel': 'रद्द करें',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'language': 'भाषा',
      'settings': 'सेटिंग्स',
      'help_support': 'सहायता',
      'privacy_policy': 'गोपनीयता नीति',
      'terms_conditions': 'नियम और शर्तें',
      'featured_services': 'विशेष सेवाएं',
      'categories': 'श्रेणियां',
      'see_all': 'सभी देखें',
      'my_bookings': 'मेरी बुकिंग्स',
    },

    'te': {
      'app_name': 'ఈవెంట్ ఈజ్',
      'login': 'లాగిన్',
      'register': 'నమోదు',
      'logout': 'లాగౌట్',
      'home': 'హోమ్',
      'profile': 'ప్రొఫైల్',
      'bookings': 'బుకింగ్స్',
      'cart': 'కార్ట్',
      'notifications': 'నోటిఫికేషన్స్',
      'chat': 'చాట్',
      'search': 'శోధన',
      'book_now': 'ఇప్పుడే బుక్ చేయండి',
      'add_to_cart': 'కార్ట్‌లో జోడించండి',
      'checkout': 'చెల్లింపు',
      'save': 'సేవ్',
      'cancel': 'రద్దు',
      'edit_profile': 'ప్రొఫైల్ సవరించు',
      'language': 'భాష',
      'settings': 'సెట్టింగ్స్',
      'help_support': 'సహాయం',
      'privacy_policy': 'గోప్యతా విధానం',
      'terms_conditions': 'నిబంధనలు',
      'featured_services': 'ప్రత్యేక సేవలు',
      'categories': 'వర్గాలు',
      'see_all': 'అన్నీ చూడండి',
      'my_bookings': 'నా బుకింగ్స్',
    },

    'ta': {
      'app_name': 'இவென்ட் ஈஸ்',
      'login': 'உள்நுழை',
      'register': 'பதிவு செய்யவும்',
      'logout': 'வெளியேறு',
      'home': 'முகப்பு',
    },

    'kn': {
      'app_name': 'ಈವೆಂಟ್ ಈಸ್',
      'login': 'ಲಾಗಿನ್',
      'register': 'ನೋಂದಣಿ',
      'logout': 'ಲಾಗ್ ಔಟ್',
      'home': 'ಮುಖಪುಟ',
    },

    'ml': {
      'app_name': 'ഇവന്റ് ഈസ്',
      'login': 'ലോഗിൻ',
      'register': 'രജിസ്റ്റർ',
      'logout': 'ലോഗൗട്ട്',
      'home': 'ഹോം',
    },

    'mr': {
      'app_name': 'इव्हेंट ईज',
      'login': 'लॉगिन',
      'register': 'नोंदणी',
      'logout': 'लॉगआउट',
      'home': 'मुख्यपृष्ठ',
    },

    'bn': {
      'app_name': 'ইভেন্ট ইজ',
      'login': 'লগইন',
      'register': 'নিবন্ধন',
      'logout': 'লগআউট',
      'home': 'হোম',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get appName =>
      translate('app_name');

  String get login =>
      translate('login');

  String get register =>
      translate('register');

  String get logout =>
      translate('logout');

  String get home =>
      translate('home');

  String get profile =>
      translate('profile');

  String get bookings =>
      translate('bookings');

  String get cart =>
      translate('cart');

  String get notifications =>
      translate('notifications');

  String get chat =>
      translate('chat');

  String get search =>
      translate('search');

  String get bookNow =>
      translate('book_now');

  String get addToCart =>
      translate('add_to_cart');

  String get checkout =>
      translate('checkout');

  String get save =>
      translate('save');

  String get cancel =>
      translate('cancel');

  String get editProfile =>
      translate('edit_profile');

  String get language =>
      translate('language');

  String get settings =>
      translate('settings');

  String get helpSupport =>
      translate('help_support');

  String get privacyPolicy =>
      translate('privacy_policy');

  String get termsConditions =>
      translate('terms_conditions');

  String get featuredServices =>
      translate('featured_services');

  String get categories =>
      translate('categories');

  String get seeAll =>
      translate('see_all');

  String get myBookings =>
      translate('my_bookings');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any(
      (e) => e.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(
    Locale locale,
  ) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations>
        old,
  ) {
    return false;
  }
}

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc =>
      AppLocalizations.of(this);
}