import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  // =====================================================
  // APPLICATION
  // =====================================================

  static const String appName = 'EventEase Customer';

  static const String appVersion = '1.0.0';

  static const bool enableApiLogging = true;

  static const int apiTimeoutSeconds = 30;

  // =====================================================
  // ENVIRONMENT
  // =====================================================

  static const String environment =
      String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String developmentEnvironment =
      'development';

  static const String stagingEnvironment =
      'staging';

  static const String productionEnvironment =
      'production';

  // =====================================================
  // LOCAL DEVELOPMENT HOSTS
  // =====================================================

  /*
   * Flutter Web and Windows:
   *
   * http://localhost:5000/api
   *
   * Android Emulator:
   *
   * http://10.0.2.2:5000/api
   *
   * Physical Android/iOS device:
   *
   * Replace 192.168.1.10 with the local IPv4 address
   * of the computer running the Node.js backend.
   *
   * Example:
   *
   * http://192.168.1.10:5000/api
   */

  static const String webDevelopmentUrl =
      'http://localhost:5000/api';

  static const String androidEmulatorDevelopmentUrl =
      'http://10.0.2.2:5000/api';

  static const String physicalDeviceDevelopmentUrl =
      'http://192.168.1.10:5000/api';

  static const String stagingUrl =
      'https://staging-api.eventease.com/api';

  static const String productionUrl =
      'https://api.eventease.com/api';

  // =====================================================
  // BASE URL
  // =====================================================

  /*
   * kIsWeb is a compile-time constant.
   *
   * Since you are currently running:
   *
   * flutter run -d chrome
   *
   * this returns:
   *
   * http://localhost:5000/api
   *
   * For Android emulator testing, run with:
   *
   * flutter run \
   *   --dart-define=API_BASE_URL=http://10.0.2.2:5000/api
   */

  static String get developmentUrl {
    const String configuredUrl =
        String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    if (configuredUrl.trim().isNotEmpty) {
      return _normalizeUrl(configuredUrl);
    }

    if (kIsWeb) {
      return webDevelopmentUrl;
    }

    /*
     * Default non-web local environment is Android emulator.
     *
     * For a physical device, provide API_BASE_URL using
     * --dart-define with the computer's local IPv4 address.
     */
    return androidEmulatorDevelopmentUrl;
  }

  static String get baseUrl {
    switch (environment.toLowerCase()) {
      case stagingEnvironment:
        return _normalizeUrl(stagingUrl);

      case productionEnvironment:
        return _normalizeUrl(productionUrl);

      case developmentEnvironment:
      default:
        return _normalizeUrl(developmentUrl);
    }
  }

  // =====================================================
  // SOCKET URL
  // =====================================================

  static const String webDevelopmentSocketUrl =
      'http://localhost:5000';

  static const String androidEmulatorSocketUrl =
      'http://10.0.2.2:5000';

  static const String physicalDeviceSocketUrl =
      'http://192.168.1.10:5000';

  static const String stagingSocketUrl =
      'https://staging-api.eventease.com';

  static const String productionSocketUrl =
      'https://api.eventease.com';

  static String get developmentSocketUrl {
    const String configuredUrl =
        String.fromEnvironment(
      'SOCKET_BASE_URL',
      defaultValue: '',
    );

    if (configuredUrl.trim().isNotEmpty) {
      return _normalizeUrl(configuredUrl);
    }

    if (kIsWeb) {
      return webDevelopmentSocketUrl;
    }

    return androidEmulatorSocketUrl;
  }

  static String get socketUrl {
    switch (environment.toLowerCase()) {
      case stagingEnvironment:
        return _normalizeUrl(stagingSocketUrl);

      case productionEnvironment:
        return _normalizeUrl(productionSocketUrl);

      case developmentEnvironment:
      default:
        return _normalizeUrl(
          developmentSocketUrl,
        );
    }
  }

  // =====================================================
  // SHARED PREFERENCES KEYS
  // =====================================================

  /*
   * These keys must never be dynamically changed.
   *
   * AuthService uses these same keys when saving and
   * restoring the customer access token and user profile.
   */

  static const String tokenKey =
      'eventease_customer_access_token';

  static const String refreshTokenKey =
      'eventease_customer_refresh_token';

  static const String userKey =
      'eventease_customer_user';

  static const String languageKey =
      'eventease_customer_language';

  static const String selectedLocationKey =
      'eventease_customer_selected_location';

  static const String onboardingCompletedKey =
      'eventease_customer_onboarding_completed';

  // =====================================================
  // API ENDPOINTS
  // =====================================================

  static const String signupEndpoint =
      '/auth/signup';

  static const String registerEndpoint =
      '/auth/register';

  static const String signinEndpoint =
      '/auth/signin';

  static const String profileEndpoint =
      '/auth/profile';

  static const String googleLoginEndpoint =
      '/auth/google-login';

  static const String refreshTokenEndpoint =
      '/auth/refresh-token';

  static const String logoutEndpoint =
      '/auth/logout';

  static const String forgotPasswordEndpoint =
      '/auth/forgot-password';

  static const String resetPasswordEndpoint =
      '/auth/reset-password';

  static const String changePasswordEndpoint =
      '/auth/change-password';

  static const String sendOtpEndpoint =
      '/auth/send-otp';

  static const String verifyOtpEndpoint =
      '/auth/verify-otp';

  static const String resendOtpEndpoint =
      '/auth/resend-otp';

  static const String checkEmailEndpoint =
      '/auth/check-email';

  static const String checkPhoneEndpoint =
      '/auth/check-phone';

  static const String fcmTokenEndpoint =
      '/auth/fcm-token';

  static const String deleteAccountEndpoint =
      '/auth/delete-account';

  static const String usersEndpoint =
      '/users';

  static const String categoriesEndpoint =
      '/categories';

  static const String servicesEndpoint =
      '/services';

  static const String bookingsEndpoint =
      '/bookings';

  static const String myBookingsEndpoint =
      '/bookings/my-bookings';

  static const String ordersEndpoint =
      '/orders';

  static const String myOrdersEndpoint =
      '/orders/my';

  static const String cartEndpoint =
      '/cart';

  static const String reviewsEndpoint =
      '/reviews';

  static const String addressesEndpoint =
      '/address';

  static const String chatEndpoint =
      '/chat';

  static const String notificationsEndpoint =
      '/notifications';

  static const String adminEndpoint =
      '/admin';

  // =====================================================
  // COMPLETE AUTH URLS
  // =====================================================

  static String get signup =>
      '$baseUrl$signupEndpoint';

  static String get register =>
      '$baseUrl$registerEndpoint';

  static String get signin =>
      '$baseUrl$signinEndpoint';

  static String get profile =>
      '$baseUrl$profileEndpoint';

  static String get googleLogin =>
      '$baseUrl$googleLoginEndpoint';

  static String get refreshToken =>
      '$baseUrl$refreshTokenEndpoint';

  static String get logout =>
      '$baseUrl$logoutEndpoint';

  // =====================================================
  // COMPLETE RESOURCE URLS
  // =====================================================

  static String get users =>
      '$baseUrl$usersEndpoint';

  static String get categories =>
      '$baseUrl$categoriesEndpoint';

  static String get services =>
      '$baseUrl$servicesEndpoint';

  static String get bookings =>
      '$baseUrl$bookingsEndpoint';

  static String get myBookings =>
      '$baseUrl$myBookingsEndpoint';

  static String get orders =>
      '$baseUrl$ordersEndpoint';

  static String get myOrders =>
      '$baseUrl$myOrdersEndpoint';

  static String get cart =>
      '$baseUrl$cartEndpoint';

  static String get reviews =>
      '$baseUrl$reviewsEndpoint';

  static String get address =>
      '$baseUrl$addressesEndpoint';

  static String get chat =>
      '$baseUrl$chatEndpoint';

  static String get notifications =>
      '$baseUrl$notificationsEndpoint';

  static String get admin =>
      '$baseUrl$adminEndpoint';

  // =====================================================
  // DYNAMIC RESOURCE URLS
  // =====================================================

  static String categoryById(String id) {
    return '$categoriesEndpoint/${id.trim()}';
  }

  static String categoryBySlug(String slug) {
    return '$categoriesEndpoint/slug/${slug.trim()}';
  }

  static String categoriesByType(String type) {
    return '$categoriesEndpoint/type/${type.trim()}';
  }

  static String serviceById(String serviceId) {
    return '$servicesEndpoint/${serviceId.trim()}';
  }

  static String providerServices(
    String providerId,
  ) {
    return '$servicesEndpoint/provider/${providerId.trim()}';
  }

  static String bookingById(String bookingId) {
    return '$bookingsEndpoint/${bookingId.trim()}';
  }

  static String orderById(String orderId) {
    return '$ordersEndpoint/${orderId.trim()}';
  }

  static String cartItem(String itemId) {
    return '$cartEndpoint/item/${itemId.trim()}';
  }

  static String reviewById(String id) {
    return '$reviewsEndpoint/${id.trim()}';
  }

  static String addressById(String id) {
    return '$addressesEndpoint/${id.trim()}';
  }

  static String roomMessages(String roomId) {
    return '$chatEndpoint/${roomId.trim()}';
  }

  // =====================================================
  // CART URLS
  // =====================================================

  static String get addToCart =>
      '$baseUrl$cartEndpoint/add';

  static String get cartSummary =>
      '$baseUrl$cartEndpoint/summary';

  static String get clearCart =>
      '$baseUrl$cartEndpoint/clear';

  // =====================================================
  // VALIDATION
  // =====================================================

  static bool get isDevelopment {
    return environment.toLowerCase() ==
        developmentEnvironment;
  }

  static bool get isStaging {
    return environment.toLowerCase() ==
        stagingEnvironment;
  }

  static bool get isProduction {
    return environment.toLowerCase() ==
        productionEnvironment;
  }

  static String _normalizeUrl(String url) {
    String normalizedUrl = url.trim();

    while (normalizedUrl.endsWith('/')) {
      normalizedUrl = normalizedUrl.substring(
        0,
        normalizedUrl.length - 1,
      );
    }

    return normalizedUrl;
  }
}

// =====================================================
// BACKWARD COMPATIBILITY
// =====================================================

/*
 * Keep this class so older files that still reference
 * ApiConfig do not immediately fail.
 *
 * New and updated files should use AppConfig.
 */

class ApiConfig {
  ApiConfig._();

  static String get baseUrl =>
      AppConfig.baseUrl;

  static String get socketUrl =>
      AppConfig.socketUrl;

  static String get signup =>
      AppConfig.signup;

  static String get signin =>
      AppConfig.signin;

  static String get profile =>
      AppConfig.profile;

  static String get googleLogin =>
      AppConfig.googleLogin;

  static String get users =>
      AppConfig.users;

  static String get categories =>
      AppConfig.categories;

  static String get services =>
      AppConfig.services;

  static String get bookings =>
      AppConfig.bookings;

  static String get myBookings =>
      AppConfig.myBookings;

  static String get orders =>
      AppConfig.orders;

  static String get myOrders =>
      AppConfig.myOrders;

  static String get cart =>
      AppConfig.cart;

  static String get addToCart =>
      AppConfig.addToCart;

  static String get cartSummary =>
      AppConfig.cartSummary;

  static String get clearCart =>
      AppConfig.clearCart;

  static String get reviews =>
      AppConfig.reviews;

  static String get address =>
      AppConfig.address;

  static String get chat =>
      AppConfig.chat;

  static String get notifications =>
      AppConfig.notifications;

  static String get admin =>
      AppConfig.admin;

  static String categoryById(String id) {
    return AppConfig.categoryById(id);
  }

  static String categoryBySlug(String slug) {
    return AppConfig.categoryBySlug(slug);
  }

  static String categoriesByType(String type) {
    return AppConfig.categoriesByType(type);
  }

  static String serviceById(String serviceId) {
    return AppConfig.serviceById(serviceId);
  }

  static String providerServices(
    String providerId,
  ) {
    return AppConfig.providerServices(providerId);
  }

  static String bookingById(String bookingId) {
    return AppConfig.bookingById(bookingId);
  }

  static String orderById(String orderId) {
    return AppConfig.orderById(orderId);
  }

  static String cartItem(String itemId) {
    return AppConfig.cartItem(itemId);
  }

  static String reviewById(String id) {
    return AppConfig.reviewById(id);
  }

  static String addressById(String id) {
    return AppConfig.addressById(id);
  }

  static String roomMessages(String roomId) {
    return AppConfig.roomMessages(roomId);
  }
}