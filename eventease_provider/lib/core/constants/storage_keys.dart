class StorageKeys {
  StorageKeys._();

  // =====================================================
  // AUTHENTICATION
  // =====================================================

  static const String accessToken =
      'access_token';

  static const String refreshToken =
      'refresh_token';

  static const String userData =
      'user_data';

  static const String isLoggedIn =
      'is_logged_in';

  static const String rememberMe =
      'remember_me';

  static const String loginMethod =
      'login_method';

  // =====================================================
  // USER PROFILE
  // =====================================================

  static const String userId =
      'user_id';

  static const String userName =
      'user_name';

  static const String userEmail =
      'user_email';

  static const String userPhone =
      'user_phone';

  static const String userProfileImage =
      'user_profile_image';

  static const String userRole =
      'user_role';

  // =====================================================
  // PROVIDER PROFILE
  // =====================================================

  static const String providerId =
      'provider_id';

  static const String providerData =
      'provider_data';

  static const String businessName =
      'business_name';

  static const String businessAddress =
      'business_address';

  static const String businessCategory =
      'business_category';

  static const String providerVerificationStatus =
      'provider_verification_status';

  // =====================================================
  // APP SETTINGS
  // =====================================================

  static const String themeMode =
      'theme_mode';

  static const String language =
      'language';

  static const String locale =
      'locale';

  static const String currency =
      'currency';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const String notificationsEnabled =
      'notifications_enabled';

  static const String pushNotifications =
      'push_notifications';

  static const String emailNotifications =
      'email_notifications';

  static const String smsNotifications =
      'sms_notifications';

  static const String bookingNotifications =
      'booking_notifications';

  static const String paymentNotifications =
      'payment_notifications';

  static const String chatNotifications =
      'chat_notifications';

  // =====================================================
  // LOCATION
  // =====================================================

  static const String currentLatitude =
      'current_latitude';

  static const String currentLongitude =
      'current_longitude';

  static const String selectedAddress =
      'selected_address';

  static const String lastLocation =
      'last_location';

  // =====================================================
  // DASHBOARD
  // =====================================================

  static const String dashboardCache =
      'dashboard_cache';

  static const String dashboardLastSync =
      'dashboard_last_sync';

  // =====================================================
  // BOOKINGS
  // =====================================================

  static const String recentBookings =
      'recent_bookings';

  static const String bookingFilters =
      'booking_filters';

  // =====================================================
  // ORDERS
  // =====================================================

  static const String recentOrders =
      'recent_orders';

  static const String orderFilters =
      'order_filters';

  // =====================================================
  // SERVICES
  // =====================================================

  static const String servicesCache =
      'services_cache';

  static const String selectedService =
      'selected_service';

  // =====================================================
  // CHAT
  // =====================================================

  static const String chatDraft =
      'chat_draft';

  static const String recentChats =
      'recent_chats';

  static const String unreadMessages =
      'unread_messages';

  // =====================================================
  // SEARCH
  // =====================================================

  static const String searchHistory =
      'search_history';

  static const String recentSearches =
      'recent_searches';

  // =====================================================
  // APP STATE
  // =====================================================

  static const String onboardingCompleted =
      'onboarding_completed';

  static const String firstLaunch =
      'first_launch';

  static const String appVersion =
      'app_version';

  static const String lastOpened =
      'last_opened';

  // =====================================================
  // CACHE
  // =====================================================

  static const String categoriesCache =
      'categories_cache';

  static const String settingsCache =
      'settings_cache';

  static const String profileCache =
      'profile_cache';

  static const String notificationCache =
      'notification_cache';

  // =====================================================
  // PAYMENT
  // =====================================================

  static const String paymentMethod =
      'payment_method';

  static const String payoutAccount =
      'payout_account';

  static const String transactionHistory =
      'transaction_history';

  // =====================================================
  // SECURITY
  // =====================================================

  static const String biometricEnabled =
      'biometric_enabled';

  static const String pinCode =
      'pin_code';

  static const String sessionTimeout =
      'session_timeout';

  // =====================================================
  // ALL SHARED PREFERENCE KEYS
  // =====================================================

  static const List<String> sharedPrefKeys = [
    isLoggedIn,
    rememberMe,
    themeMode,
    language,
    locale,
    notificationsEnabled,
    pushNotifications,
    emailNotifications,
    smsNotifications,
    bookingNotifications,
    paymentNotifications,
    chatNotifications,
    onboardingCompleted,
    firstLaunch,
    dashboardCache,
    dashboardLastSync,
    searchHistory,
    recentSearches,
    appVersion,
    lastOpened,
  ];

  // =====================================================
  // ALL SECURE STORAGE KEYS
  // =====================================================

  static const List<String> secureStorageKeys = [
    accessToken,
    refreshToken,
    userData,
    providerData,
    pinCode,
    paymentMethod,
    payoutAccount,
  ];
}