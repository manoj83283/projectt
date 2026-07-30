import 'package:flutter/foundation.dart';

enum ApiEnvironment {
  development,
  staging,
  production,
}

class ApiConfig {
  ApiConfig._();

  // =====================================================
  // ENVIRONMENT
  // =====================================================

  static const ApiEnvironment environment =
      ApiEnvironment.development;

  static bool get isDevelopment =>
      environment ==
      ApiEnvironment.development;

  static bool get isStaging =>
      environment ==
      ApiEnvironment.staging;

  static bool get isProduction =>
      environment ==
      ApiEnvironment.production;

  // =====================================================
  // BASE URLS
  // =====================================================

  static String get baseUrl {
    switch (environment) {
      case ApiEnvironment.development:
        return 'http://10.0.2.2:5000/api/v1';

      case ApiEnvironment.staging:
        return 'https://staging-api.eventease.com/api/v1';

      case ApiEnvironment.production:
        return 'https://api.eventease.com/api/v1';
    }
  }

  static String get socketUrl {
    switch (environment) {
      case ApiEnvironment.development:
        return 'http://10.0.2.2:5000';

      case ApiEnvironment.staging:
        return 'https://staging-api.eventease.com';

      case ApiEnvironment.production:
        return 'https://api.eventease.com';
    }
  }

  static String get imageBaseUrl {
    switch (environment) {
      case ApiEnvironment.development:
        return 'http://10.0.2.2:5000/uploads/';

      case ApiEnvironment.staging:
        return 'https://staging-api.eventease.com/uploads/';

      case ApiEnvironment.production:
        return 'https://api.eventease.com/uploads/';
    }
  }

  // =====================================================
  // TIMEOUTS
  // =====================================================

  static const Duration connectTimeout =
      Duration(seconds: 30);

  static const Duration receiveTimeout =
      Duration(seconds: 30);

  static const Duration sendTimeout =
      Duration(seconds: 30);

  // =====================================================
  // SOCKET CONFIG
  // =====================================================

  static const int maxReconnectAttempts =
      10;

  static const Duration reconnectDelay =
      Duration(seconds: 5);

  static const Duration pingInterval =
      Duration(seconds: 25);

  // =====================================================
  // PAGINATION
  // =====================================================

  static const int defaultPage = 1;

  static const int defaultLimit = 10;

  static const int maxLimit = 100;

  // =====================================================
  // CACHE
  // =====================================================

  static const Duration cacheDuration =
      Duration(hours: 1);

  static const Duration dashboardCache =
      Duration(minutes: 15);

  // =====================================================
  // FILE UPLOAD RULES
  // =====================================================

  static const int maxImageSizeMB = 10;

  static const int maxVideoSizeMB = 100;

  static const int maxDocumentSizeMB = 25;

  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  static const List<String> allowedVideoFormats = [
    'mp4',
    'mov',
    'avi',
  ];

  static const List<String> allowedDocumentFormats = [
    'pdf',
    'doc',
    'docx',
  ];

  // =====================================================
  // GOOGLE MAPS
  // =====================================================

  static const String googleMapsApiKey =
      'YOUR_GOOGLE_MAPS_API_KEY';

  static const double defaultLatitude =
      17.385044;

  static const double defaultLongitude =
      78.486671;

  static const double searchRadiusKm =
      50.0;

  // =====================================================
  // CLOUDINARY
  // =====================================================

  static const String cloudinaryCloudName =
      'eventease';

  static const String cloudinaryUploadPreset =
      'eventease_uploads';

  static const String cloudinaryApiKey =
      'YOUR_CLOUDINARY_API_KEY';

  // =====================================================
  // FIREBASE
  // =====================================================

  static const bool enableFcm = true;

  static const bool enableCrashlytics =
      true;

  static const bool enableAnalytics =
      true;

  // =====================================================
  // RAZORPAY
  // =====================================================

  static const String razorpayKeyId =
      'rzp_test_xxxxxxxxxxxx';

  static const String currency = 'INR';

  // =====================================================
  // CHAT CONFIG
  // =====================================================

  static const int chatPageSize = 50;

  static const int maxMessageLength =
      1000;

  static const int typingTimeoutSeconds =
      3;

  // =====================================================
  // BOOKING CONFIG
  // =====================================================

  static const int maxBookingDays = 365;

  static const int cancelBeforeHours =
      24;

  static const int settlementDays = 3;

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const bool enablePushNotifications =
      true;

  static const bool enableEmailNotifications =
      true;

  static const bool enableSmsNotifications =
      false;

  // =====================================================
  // LOGGING
  // =====================================================

  static bool get enableLogs =>
      !kReleaseMode;

  static bool get enableApiLogs =>
      !kReleaseMode;

  static bool get enableSocketLogs =>
      !kReleaseMode;

  // =====================================================
  // DEFAULT HEADERS
  // =====================================================

  static const Map<String, String>
      defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // =====================================================
  // BUILD INFO
  // =====================================================

  static Map<String, dynamic> buildInfo() {
    return {
      'environment': environment.name,
      'baseUrl': baseUrl,
      'socketUrl': socketUrl,
      'isDevelopment': isDevelopment,
      'isProduction': isProduction,
    };
  }

  // =====================================================
  // DEBUG CONFIG
  // =====================================================

  static void printConfig() {
    if (!enableLogs) return;

    debugPrint('''
=================================
EVENTEASE API CONFIG
=================================
Environment : ${environment.name}
Base URL    : $baseUrl
Socket URL  : $socketUrl
Production  : $isProduction
=================================
''');
  }
}