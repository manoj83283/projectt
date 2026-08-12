
class AppConstants {
  AppConstants._();

  // =====================================================
  // APP INFO
  // =====================================================

  static const String appName = 'EventEase';

  static const String appVersion = '1.0.0';

  static const String packageName =
      'com.eventease.customer';

  static const String companyName =
      'EventEase Technologies';

  // =====================================================
  // API
  // =====================================================

  static const String baseUrl =
      'https://api.eventease.com/api';

  static const String socketUrl =
      'https://api.eventease.com';

  static const Duration apiTimeout =
      Duration(seconds: 30);

  // =====================================================
  // PAGINATION
  // =====================================================

  static const int pageSize = 20;

  static const int maxPerPage = 100;

  // =====================================================
  // STORAGE KEYS
  // =====================================================

  static const String accessTokenKey =
      'access_token';

  static const String refreshTokenKey =
      'refresh_token';

  static const String userKey = 'user';

  static const String languageKey =
      'language';

  static const String themeKey = 'theme';

  static const String onboardingKey =
      'onboarding_completed';

  static const String locationKey =
      'user_location';

  static const String cartKey =
      'cart_data';

  // =====================================================
  // USER ROLES
  // =====================================================

  static const String customerRole =
      'customer';

  static const String providerRole =
      'provider';

  static const String adminRole =
      'admin';

  // =====================================================
  // BOOKING STATUS
  // =====================================================

  static const String pending =
      'pending';

  static const String confirmed =
      'confirmed';

  static const String assigned =
      'assigned';

  static const String inProgress =
      'in_progress';

  static const String completed =
      'completed';

  static const String cancelled =
      'cancelled';

  // =====================================================
  // PAYMENT STATUS
  // =====================================================

  static const String paymentPending =
      'payment_pending';

  static const String paymentSuccess =
      'payment_success';

  static const String paymentFailed =
      'payment_failed';

  static const String paymentRefunded =
      'payment_refunded';

  // =====================================================
  // PAYMENT METHODS
  // =====================================================

  static const String razorpay =
      'razorpay';

  static const String upi = 'upi';

  static const String creditCard =
      'credit_card';

  static const String debitCard =
      'debit_card';

  static const String wallet = 'wallet';

  static const String cash =
      'cash';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const String bookingNotification =
      'booking';

  static const String paymentNotification =
      'payment';

  static const String chatNotification =
      'chat';

  static const String offerNotification =
      'offer';

  static const String systemNotification =
      'system';

  // =====================================================
  // LANGUAGES
  // =====================================================

  static const List<Map<String, String>>
      supportedLanguages = [
    {
      'name': 'English',
      'code': 'en',
    },
    {
      'name': 'Hindi',
      'code': 'hi',
    },
    {
      'name': 'Telugu',
      'code': 'te',
    },
    {
      'name': 'Tamil',
      'code': 'ta',
    },
    {
      'name': 'Kannada',
      'code': 'kn',
    },
    {
      'name': 'Malayalam',
      'code': 'ml',
    },
    {
      'name': 'Marathi',
      'code': 'mr',
    },
    {
      'name': 'Bengali',
      'code': 'bn',
    },
  ];

  // =====================================================
  // DEFAULT VALUES
  // =====================================================

  static const double defaultRadius =
      12.0;

  static const double cardRadius =
      16.0;

  static const double appPadding =
      16.0;

  static const double buttonHeight =
      54.0;

  // =====================================================
  // IMAGE LIMITS
  // =====================================================

  static const int maxImageSizeMB = 10;

  static const int maxImagesUpload = 10;

  // =====================================================
  // LOCATION
  // =====================================================

  static const double defaultLatitude =
      17.3850;

  static const double defaultLongitude =
      78.4867;

  static const double nearbyRadiusKm =
      50.0;

  // =====================================================
  // RATING
  // =====================================================

  static const double minRating = 1.0;

  static const double maxRating = 5.0;

  // =====================================================
  // ORDER TYPES
  // =====================================================

  static const String bookingType =
      'booking';

  static const String groceryType =
      'grocery';

  static const String livestockType =
      'livestock';

  static const String eventType =
      'event';

  // =====================================================
  // SOCIAL LINKS
  // =====================================================

  static const String supportEmail =
      'support@eventease.com';

  static const String supportPhone =
      '+91 1800000000';

  static const String website =
      'https://eventease.com';

  // =====================================================
  // REGEX
  // =====================================================

  static const String emailRegex =
      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$';

  static const String mobileRegex =
      r'^[6-9]\d{9}$';

  static const String pincodeRegex =
      r'^[1-9][0-9]{5}$';

  static const String passwordRegex =
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$';
}