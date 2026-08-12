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
      environment == ApiEnvironment.development;

  static bool get isStaging =>
      environment == ApiEnvironment.staging;

  static bool get isProduction =>
      environment == ApiEnvironment.production;

  // =====================================================
  // LOCAL DEVELOPMENT HOSTS
  // =====================================================

  /// Flutter Web running on Chrome/Edge from same machine as backend.
  static const String webLocalHost =
      'http://localhost:5000';

  /// Android Emulator uses this IP to access host machine localhost.
  static const String androidEmulatorHost =
      'http://10.0.2.2:5000';

  /// iOS Simulator can use localhost/127.0.0.1.
  static const String iosSimulatorHost =
      'http://127.0.0.1:5000';

  /// Your current WiFi IPv4 address from ipconfig.
  /// Use this for physical Android/iOS devices on the same WiFi.
  static const String localWifiHost =
      'http://192.168.1.37:5000';

  /// Optional office/VPN/private network IP.
  static const String officeNetworkHost =
      'http://10.152.35.172:5000';

  // =====================================================
  // REMOTE HOSTS
  // =====================================================

  static const String stagingHost =
      'https://staging-api.eventease.com';

  static const String productionHost =
      'https://api.eventease.com';

  // =====================================================
  // OPTIONAL BUILD-TIME OVERRIDE
  // =====================================================
  //
  // You can run:
  //
  // flutter run -d chrome --dart-define=API_HOST=http://192.168.1.37:5000
  //
  // Or production:
  //
  // flutter build web --dart-define=API_HOST=https://api.eventease.com
  //
  // If API_HOST is empty, automatic detection below will be used.

  static const String _apiHostOverride =
      String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );

  // =====================================================
  // DEVICE TARGET DETECTION
  // =====================================================

  /// Set this to true when testing on a physical Android/iOS device.
  ///
  /// Android emulator needs:
  /// http://10.0.2.2:5000
  ///
  /// Physical device needs your WiFi IP:
  /// http://192.168.1.37:5000
  static const bool usePhysicalDeviceHost = false;

  /// Set this to true if you are working from office/VPN network.
  static const bool useOfficeNetworkHost = false;

  // =====================================================
  // HOST URL
  // =====================================================

  static String get hostUrl {
    if (_apiHostOverride.isNotEmpty) {
      return _apiHostOverride;
    }

    switch (environment) {
      case ApiEnvironment.production:
        return productionHost;

      case ApiEnvironment.staging:
        return stagingHost;

      case ApiEnvironment.development:
        return _developmentHost;
    }
  }

  static String get _developmentHost {
    if (kIsWeb) {
      return webLocalHost;
    }

    if (useOfficeNetworkHost) {
      return officeNetworkHost;
    }

    if (usePhysicalDeviceHost) {
      return localWifiHost;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidEmulatorHost;

      case TargetPlatform.iOS:
        return iosSimulatorHost;

      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return webLocalHost;
    }
  }

  // =====================================================
  // BASE URLS
  // =====================================================

  /// Backend API base URL.
  ///
  /// Your backend currently uses:
  /// app.use("/api/auth", authRoutes)
  ///
  /// So use /api, not /api/v1.
  static String get baseUrl {
    return '$hostUrl/api';
  }

  /// Socket.IO base URL.
  static String get socketUrl {
    return hostUrl;
  }

  /// Static upload/image base URL.
  static String get imageBaseUrl {
    return '$hostUrl/uploads/';
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

  static const int maxReconnectAttempts = 10;

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

  static const double defaultLatitude = 17.385044;

  static const double defaultLongitude = 78.486671;

  static const double searchRadiusKm = 50.0;

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

  static const bool enableCrashlytics = true;

  static const bool enableAnalytics = true;

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

  static const int maxMessageLength = 1000;

  static const int typingTimeoutSeconds = 3;

  // =====================================================
  // BOOKING CONFIG
  // =====================================================

  static const int maxBookingDays = 365;

  static const int cancelBeforeHours = 24;

  static const int settlementDays = 3;

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const bool enablePushNotifications = true;

  static const bool enableEmailNotifications = true;

  static const bool enableSmsNotifications = false;

  // =====================================================
  // LOGGING
  // =====================================================

  static bool get enableLogs => !kReleaseMode;

  static bool get enableApiLogs => !kReleaseMode;

  static bool get enableSocketLogs => !kReleaseMode;

  // =====================================================
  // DEFAULT HEADERS
  // =====================================================

  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // =====================================================
  // BUILD INFO
  // =====================================================

  static Map<String, dynamic> buildInfo() {
    return {
      'environment': environment.name,
      'hostUrl': hostUrl,
      'baseUrl': baseUrl,
      'socketUrl': socketUrl,
      'imageBaseUrl': imageBaseUrl,
      'isDevelopment': isDevelopment,
      'isStaging': isStaging,
      'isProduction': isProduction,
      'kIsWeb': kIsWeb,
      'targetPlatform': defaultTargetPlatform.name,
      'usePhysicalDeviceHost': usePhysicalDeviceHost,
      'useOfficeNetworkHost': useOfficeNetworkHost,
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
Environment          : ${environment.name}
Target Platform      : ${defaultTargetPlatform.name}
Web                  : $kIsWeb
Host URL             : $hostUrl
Base URL             : $baseUrl
Socket URL           : $socketUrl
Image Base URL       : $imageBaseUrl
Production           : $isProduction
Physical Device Host : $usePhysicalDeviceHost
Office Network Host  : $useOfficeNetworkHost
=================================
''');
  }
}