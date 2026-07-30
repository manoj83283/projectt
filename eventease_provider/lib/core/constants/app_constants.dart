class AppConstants {
  AppConstants._();

  // =====================================================
  // APP INFORMATION
  // =====================================================

  static const String appName =
      'EventEase Provider';

  static const String appVersion =
      '1.0.0';

  static const String packageName =
      'com.eventease.provider';

  static const String supportEmail =
      'support@eventease.com';

  static const String supportPhone =
      '+91 9876543210';

  static const String websiteUrl =
      'https://eventease.com';

  // =====================================================
  // API CONFIGURATION
  // =====================================================

  static const String baseUrl =
      'https://api.eventease.com/api/v1';

  static const String socketUrl =
      'https://api.eventease.com';

  static const String imageBaseUrl =
      'https://api.eventease.com/uploads/';

  // =====================================================
  // STORAGE KEYS
  // =====================================================

  static const String accessTokenKey =
      'access_token';

  static const String refreshTokenKey =
      'refresh_token';

  static const String userDataKey =
      'user_data';

  static const String isLoggedInKey =
      'is_logged_in';

  static const String languageKey =
      'language';

  static const String themeKey =
      'theme_mode';

  static const String notificationKey =
      'notification_enabled';

  // =====================================================
  // DEFAULT VALUES
  // =====================================================

  static const String defaultLanguage =
      'en';

  static const int defaultPage = 1;

  static const int defaultLimit = 10;

  static const int maxLimit = 100;

  // =====================================================
  // TIMEOUTS
  // =====================================================

  static const int connectTimeout =
      30000;

  static const int receiveTimeout =
      30000;

  static const int sendTimeout =
      30000;

  // =====================================================
  // DATE FORMATS
  // =====================================================

  static const String apiDateFormat =
      'yyyy-MM-dd';

  static const String displayDateFormat =
      'dd MMM yyyy';

  static const String displayDateTimeFormat =
      'dd MMM yyyy hh:mm a';

  // =====================================================
  // USER ROLES
  // =====================================================

  static const String providerRole =
      'provider';

  static const String customerRole =
      'customer';

  static const String adminRole =
      'admin';

  // =====================================================
  // BOOKING STATUS
  // =====================================================

  static const String pending =
      'pending';

  static const String confirmed =
      'confirmed';

  static const String inProgress =
      'in_progress';

  static const String completed =
      'completed';

  static const String cancelled =
      'cancelled';

  // =====================================================
  // PAYMENT STATUS
  // =====================================================

  static const String paid =
      'paid';

  static const String unpaid =
      'unpaid';

  static const String refunded =
      'refunded';

  static const String failed =
      'failed';

  // =====================================================
  // ORDER STATUS
  // =====================================================

  static const String orderPending =
      'pending';

  static const String orderConfirmed =
      'confirmed';

  static const String orderProcessing =
      'processing';

  static const String orderCompleted =
      'completed';

  static const String orderCancelled =
      'cancelled';

  // =====================================================
  // NOTIFICATION TYPES
  // =====================================================

  static const String bookingNotification =
      'booking';

  static const String paymentNotification =
      'payment';

  static const String orderNotification =
      'order';

  static const String reviewNotification =
      'review';

  static const String chatNotification =
      'chat';

  static const String systemNotification =
      'system';

  // =====================================================
  // SERVICE CATEGORIES
  // =====================================================

  static const List<String>
      serviceCategories = [
    'Convention Hall',
    'Resort',
    'Photographer',
    'Videographer',
    'Makeup Artist',
    'Decorator',
    'Catering',
    'DJ',
    'Live Band',
    'Event Planner',
    'Sound System',
    'Lighting',
    'Mehendi Artist',
    'Dance Group',
    'Anchor',
    'Travel Services',
    'Tent House',
    'Flower Decoration',
  ];

  // =====================================================
  // FILE SETTINGS
  // =====================================================

  static const int maxImageSizeMB = 10;

  static const int maxVideoSizeMB = 100;

  static const int maxDocumentSizeMB = 25;

  static const List<String>
      allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  static const List<String>
      allowedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
  ];

  // =====================================================
  // PAGINATION
  // =====================================================

  static const int bookingPageSize =
      20;

  static const int orderPageSize =
      20;

  static const int reviewPageSize =
      20;

  static const int chatPageSize =
      50;

  // =====================================================
  // GOOGLE MAPS
  // =====================================================

  static const double defaultLatitude =
      17.3850;

  static const double defaultLongitude =
      78.4867;

  static const double searchRadiusKm =
      50.0;

  // =====================================================
  // RAZORPAY
  // =====================================================

  static const String currency =
      'INR';

  static const String currencySymbol =
      '₹';

  // =====================================================
  // REGEX
  // =====================================================

  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$';

  static const String phonePattern =
      r'^[0-9]{10}$';

  // =====================================================
  // ANIMATION DURATIONS
  // =====================================================

  static const Duration shortAnimation =
      Duration(milliseconds: 300);

  static const Duration mediumAnimation =
      Duration(milliseconds: 500);

  static const Duration longAnimation =
      Duration(milliseconds: 800);

  // =====================================================
  // DASHBOARD CARDS
  // =====================================================

  static const int dashboardColumns = 2;

  static const double dashboardCardRadius =
      16.0;

  // =====================================================
  // CHAT
  // =====================================================

  static const int maxMessageLength =
      1000;

  static const int typingTimeoutSeconds =
      3;

  // =====================================================
  // APP LINKS
  // =====================================================

  static const String privacyPolicyUrl =
      'https://eventease.com/privacy-policy';

  static const String termsUrl =
      'https://eventease.com/terms';

  static const String helpCenterUrl =
      'https://eventease.com/help';

  // =====================================================
  // SUCCESS MESSAGES
  // =====================================================

  static const String loginSuccess =
      'Login successful';

  static const String profileUpdated =
      'Profile updated successfully';

  static const String bookingUpdated =
      'Booking updated successfully';

  static const String orderUpdated =
      'Order updated successfully';

  // =====================================================
  // ERROR MESSAGES
  // =====================================================

  static const String noInternet =
      'No internet connection';

  static const String serverError =
      'Something went wrong';

  static const String unauthorized =
      'Unauthorized access';

  static const String sessionExpired =
      'Session expired. Please login again.';
}