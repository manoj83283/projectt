import '../core/constants/api_config.dart';
import '../core/constants/app_constants.dart';

enum AppEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  AppConfig._();

  // =====================================================
  // ENVIRONMENT
  // =====================================================

  static const AppEnvironment environment =
      AppEnvironment.development;

  static bool get isDevelopment =>
      environment ==
      AppEnvironment.development;

  static bool get isStaging =>
      environment ==
      AppEnvironment.staging;

  static bool get isProduction =>
      environment ==
      AppEnvironment.production;

  // =====================================================
  // APP INFORMATION
  // =====================================================

  static String get appName =>
      AppConstants.appName;

  static String get version =>
      AppConstants.appVersion;

  static String get packageName =>
      AppConstants.packageName;

  // =====================================================
  // API CONFIGURATION
  // =====================================================

  static String get baseUrl =>
      ApiConfig.baseUrl;

  static String get socketUrl =>
      ApiConfig.socketUrl;

  static String get imageBaseUrl =>
      ApiConfig.imageBaseUrl;

  // =====================================================
  // NETWORK SETTINGS
  // =====================================================

  static Duration get connectTimeout =>
      ApiConfig.connectTimeout;

  static Duration get receiveTimeout =>
      ApiConfig.receiveTimeout;

  static Duration get sendTimeout =>
      ApiConfig.sendTimeout;

  // =====================================================
  // PAGINATION
  // =====================================================

  static int get defaultPage =>
      ApiConfig.defaultPage;

  static int get defaultLimit =>
      ApiConfig.defaultLimit;

  static int get maxLimit =>
      ApiConfig.maxLimit;

  // =====================================================
  // FILE UPLOAD SETTINGS
  // =====================================================

  static int get maxImageSizeMB =>
      ApiConfig.maxImageSizeMB;

  static int get maxVideoSizeMB =>
      ApiConfig.maxVideoSizeMB;

  static int get maxDocumentSizeMB =>
      ApiConfig.maxDocumentSizeMB;

  static List<String>
      get allowedImageFormats =>
          ApiConfig.allowedImageFormats;

  static List<String>
      get allowedDocuments =>
          ApiConfig.allowedDocuments;

  // =====================================================
  // GOOGLE MAPS
  // =====================================================

  static String get googleMapsApiKey =>
      ApiConfig.googleMapsApiKey;

  static double get defaultLatitude =>
      ApiConfig.defaultLatitude;

  static double get defaultLongitude =>
      ApiConfig.defaultLongitude;

  static double get searchRadiusKm =>
      ApiConfig.providerSearchRadiusKm;

  // =====================================================
  // CLOUDINARY
  // =====================================================

  static String get cloudinaryCloudName =>
      ApiConfig.cloudinaryCloudName;

  static String get cloudinaryUploadPreset =>
      ApiConfig.cloudinaryUploadPreset;

  // =====================================================
  // RAZORPAY
  // =====================================================

  static String get razorpayKeyId =>
      ApiConfig.razorpayKeyId;

  static String get currency =>
      ApiConfig.razorpayCurrency;

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static bool get enablePushNotifications =>
      ApiConfig.enablePushNotifications;

  static bool get enableEmailNotifications =>
      ApiConfig.enableEmailNotifications;

  static bool get enableSmsNotifications =>
      ApiConfig.enableSmsNotifications;

  // =====================================================
  // CHAT CONFIG
  // =====================================================

  static int get maxMessageLength =>
      ApiConfig.maxMessageLength;

  static int get messagePageSize =>
      ApiConfig.messagePageSize;

  // =====================================================
  // CACHE CONFIG
  // =====================================================

  static Duration get cacheDuration =>
      ApiConfig.cacheDuration;

  static Duration get dashboardCache =>
      ApiConfig.dashboardCache;

  // =====================================================
  // BOOKING RULES
  // =====================================================

  static int get bookingCancellationHours =>
      ApiConfig.bookingCancellationHours;

  static int get maxBookingDays =>
      ApiConfig.maxBookingDays;

  static int get settlementDays =>
      ApiConfig.paymentSettlementDays;

  // =====================================================
  // SUPPORT DETAILS
  // =====================================================

  static String get supportEmail =>
      ApiConfig.supportEmail;

  static String get supportPhone =>
      ApiConfig.supportPhone;

  static String get websiteUrl =>
      ApiConfig.websiteUrl;

  // =====================================================
  // LOGGING
  // =====================================================

  static bool get enableLogs =>
      ApiConfig.enableLogs;

  static bool get enableApiLogs =>
      ApiConfig.enableApiLogs;

  static bool get enableSocketLogs =>
      ApiConfig.enableSocketLogs;

  // =====================================================
  // APP LINKS
  // =====================================================

  static String get privacyPolicyUrl =>
      AppConstants.privacyPolicyUrl;

  static String get termsUrl =>
      AppConstants.termsUrl;

  static String get helpCenterUrl =>
      AppConstants.helpCenterUrl;

  // =====================================================
  // DEFAULT HEADERS
  // =====================================================

  static Map<String, String>
      get defaultHeaders =>
          ApiConfig.defaultHeaders;

  // =====================================================
  // BUILD INFO
  // =====================================================

  static Map<String, dynamic> buildInfo() {
    return {
      'appName': appName,
      'version': version,
      'environment': environment.name,
      'baseUrl': baseUrl,
      'socketUrl': socketUrl,
      'isProduction': isProduction,
      'isDevelopment': isDevelopment,
    };
  }

  // =====================================================
  // DEBUG PRINT CONFIG
  // =====================================================

  static void printConfig() {
    if (!enableLogs) return;

    // ignore: avoid_print
    print('''
==============================
EventEase App Configuration
==============================
App Name      : $appName
Version       : $version
Environment   : ${environment.name}
Base URL      : $baseUrl
Socket URL    : $socketUrl
Production    : $isProduction
==============================
''');
  }
}