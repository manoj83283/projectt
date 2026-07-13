class AppConstants {
  AppConstants._();

  // =====================================================
  // APP INFO
  // =====================================================

  static const String appName =
      'EventEase';

  static const String appTagLine =
      'Book Events & Services Easily';

  static const String appVersion =
      '1.0.0';

  // =====================================================
  // STORAGE KEYS
  // =====================================================

  static const String tokenKey =
      'auth_token';

  static const String userKey =
      'user_data';

  static const String languageKey =
      'selected_language';

  static const String themeKey =
      'theme_mode';

  static const String firstLaunchKey =
      'first_launch';

  // =====================================================
  // USER ROLES
  // =====================================================

  static const String userRole =
      'user';

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

  static const String accepted =
      'accepted';

  static const String rejected =
      'rejected';

  static const String completed =
      'completed';

  static const String cancelled =
      'cancelled';

  // =====================================================
  // PAYMENT STATUS
  // =====================================================

  static const String paymentPending =
      'pending';

  static const String paymentSuccess =
      'success';

  static const String paymentFailed =
      'failed';

  static const String paymentRefunded =
      'refunded';

  // =====================================================
  // NOTIFICATION TYPES
  // =====================================================

  static const String bookingNotification =
      'booking';

  static const String orderNotification =
      'order';

  static const String paymentNotification =
      'payment';

  static const String chatNotification =
      'chat';

  static const String reviewNotification =
      'review';

  static const String systemNotification =
      'system';

  // =====================================================
  // CATEGORY TYPES
  // =====================================================

  static const String venue =
      'venue';

  static const String professional =
      'professional';

  static const String service =
      'service';

  static const String product =
      'product';

  // =====================================================
  // PAGINATION
  // =====================================================

  static const int pageSize = 10;

  static const int maxItemsPerPage = 20;

  // =====================================================
  // SOCKET EVENTS
  // =====================================================

  static const String joinRoom =
      'joinRoom';

  static const String sendMessage =
      'sendMessage';

  static const String receiveMessage =
      'receiveMessage';

  static const String bookingUpdate =
      'bookingUpdate';

  static const String refreshServices =
      'refreshServices';

  static const String liveLocation =
      'liveLocation';

  // =====================================================
  // DATE FORMATS
  // =====================================================

  static const String dateFormat =
      'dd/MM/yyyy';

  static const String dateTimeFormat =
      'dd/MM/yyyy HH:mm';

  // =====================================================
  // SUPPORT
  // =====================================================

  static const String supportEmail =
      'support@eventease.com';

  static const String supportPhone =
      '+91XXXXXXXXXX';

  // =====================================================
  // ORDER TYPES
  // =====================================================

  static const String serviceOrder =
      'service';

  static const String productOrder =
      'product';

  // =====================================================
  // EVENT CATEGORIES
  // =====================================================

  static const List<String>
      eventCategories = [
    'Convention Hall',
    'Resort',
    'Hotel',
    'Photographer',
    'Videographer',
    'Makeup Artist',
    'Catering',
    'Decoration',
    'DJ',
    'Event Planner',
  ];

  // =====================================================
  // MARKETPLACE CATEGORIES
  // =====================================================

  static const List<String>
      productCategories = [
    'Vegetables',
    'Rice',
    'Chicken',
    'Goat',
    'Sheep',
    'Dairy Products',
  ];

  // =====================================================
  // SUPPORTED LANGUAGES
  // =====================================================

  static const List<String>
      supportedLanguages = [
    'English',
    'Hindi',
    'Telugu',
    'Tamil',
    'Kannada',
    'Malayalam',
    'Marathi',
    'Bengali',
  ];

  // =====================================================
  // IMAGE PLACEHOLDERS
  // =====================================================

  static const String placeholderImage =
      'assets/images/placeholder.png';

  static const String noDataImage =
      'assets/images/no_data.png';

  static const String noInternetImage =
      'assets/images/no_internet.png';

  static const String defaultAvatar =
      'assets/images/user_placeholder.png';
}