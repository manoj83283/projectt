import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';

enum AppEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  AppConfig._();

  // =====================================================
  // ACTIVE ENVIRONMENT
  // =====================================================

  static const AppEnvironment environment =
      AppEnvironment.production;

  // =====================================================
  // APP DETAILS
  // =====================================================

  static const String appName =
      AppConstants.appName;

  static const String appTagLine =
      AppConstants.appTagLine;

  static const String appVersion =
      AppConstants.version;

  static const String buildNumber =
      AppConstants.buildNumber;

  // =====================================================
  // API CONFIG
  // =====================================================

  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.development:
        return ApiConstants.devBaseUrl;

      case AppEnvironment.staging:
        return ApiConstants.stagingBaseUrl;

      case AppEnvironment.production:
        return ApiConstants.prodBaseUrl;
    }
  }

  static String get socketUrl {
    return baseUrl.replaceAll(
      '/api',
      '',
    );
  }

  static const int connectTimeout =
      ApiConstants.connectTimeout;

  static const int receiveTimeout =
      ApiConstants.receiveTimeout;

  static const int sendTimeout =
      ApiConstants.sendTimeout;

  // =====================================================
  // FEATURE FLAGS
  // =====================================================

  static const bool enableLogging =
      true;

  static const bool enableSocket =
      true;

  static const bool enablePushNotifications =
      true;

  static const bool enableAnalytics =
      true;

  static const bool enableCrashReporting =
      true;

  static const bool enableBiometricLogin =
      false;

  static const bool enableMaintenanceMode =
      false;

  static const bool enableMockData =
      false;

  // =====================================================
  // SECURITY
  // =====================================================

  static const bool forceHttps =
      true;

  static const bool enableCertificatePinning =
      false;

  static const bool enableTokenRefresh =
      true;

  static const bool autoLogoutOnUnauthorized =
      true;

  static const Duration sessionTimeout =
      Duration(hours: 12);

  static const Duration tokenRefreshThreshold =
      Duration(minutes: 5);

  // =====================================================
  // PAGINATION
  // =====================================================

  static const int defaultPage =
      AppConstants.defaultPage;

  static const int defaultLimit =
      AppConstants.defaultLimit;

  static const int maxPageSize =
      AppConstants.maxPageSize;

  // =====================================================
  // DASHBOARD
  // =====================================================

  static const int dashboardRefreshIntervalSeconds =
      30;

  static const int dashboardLatestRecordsLimit =
      AppConstants.latestRecordsLimit;

  static const int dashboardCardCount =
      AppConstants.dashboardCardCount;

  // =====================================================
  // FILE UPLOAD CONFIG
  // =====================================================

  static const int maxImageSize =
      AppConstants.maxImageSize;

  static const int maxDocumentSize =
      AppConstants.maxDocumentSize;

  static const List<String> allowedImageExtensions =
      AppConstants.allowedImageExtensions;

  static const List<String> allowedDocumentExtensions =
      AppConstants.allowedDocumentExtensions;

  // =====================================================
  // LOCALIZATION
  // =====================================================

  static const String defaultLanguage =
      AppConstants.defaultLanguage;

  static const String defaultCountryCode =
      'IN';

  static const List<String> supportedLanguages = [
    'en',
    'hi',
    'te',
    'ta',
    'kn',
    'ml',
  ];

  // =====================================================
  // CURRENCY
  // =====================================================

  static const String defaultCurrency =
      AppConstants.defaultCurrency;

  static const String currencySymbol =
      '₹';

  static const String currencyLocale =
      'en_IN';

  // =====================================================
  // DATE & TIME
  // =====================================================

  static const String timezone =
      AppConstants.timezone;

  static const String dateFormat =
      AppConstants.dateFormat;

  static const String dateTimeFormat =
      AppConstants.dateTimeFormat;

  static const String serverDateFormat =
      AppConstants.serverDateFormat;

  static const String serverDateTimeFormat =
      AppConstants.serverDateTimeFormat;

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const String notificationTopicAdmin =
      'admin';

  static const String notificationTopicProviders =
      'providers';

  static const String notificationTopicCustomers =
      'customers';

  static const String notificationTopicBookings =
      'bookings';

  static const String notificationTopicOrders =
      'orders';

  static const String notificationTopicPayments =
      'payments';

  // =====================================================
  // SOCKET EVENTS
  // =====================================================

  static const String socketAdminRoom =
      'admin-room';

  static const String socketDashboardRoom =
      'dashboard-room';

  static const String socketBookingRoom =
      'booking-room';

  static const String socketOrderRoom =
      'order-room';

  static const String socketPaymentRoom =
      'payment-room';

  static const String socketSupportRoom =
      'support-room';

  // =====================================================
  // CACHE CONFIG
  // =====================================================

  static const Duration cacheDuration =
      AppConstants.cacheDuration;

  static const bool enableDashboardCache =
      true;

  static const bool enableCategoryCache =
      true;

  static const bool enableSettingsCache =
      true;

  // =====================================================
  // EXPORT CONFIG
  // =====================================================

  static const String exportPdf =
      AppConstants.pdf;

  static const String exportExcel =
      AppConstants.excel;

  static const String exportCsv =
      AppConstants.csv;

  static const int exportMaxRecords =
      10000;

  // =====================================================
  // SUPPORT
  // =====================================================

  static const String supportEmail =
      AppConstants.supportEmail;

  static const String supportPhone =
      AppConstants.supportPhone;

  // =====================================================
  // DEBUG HELPERS
  // =====================================================

  static bool get isDevelopment {
    return environment ==
        AppEnvironment.development;
  }

  static bool get isStaging {
    return environment ==
        AppEnvironment.staging;
  }

  static bool get isProduction {
    return environment ==
        AppEnvironment.production;
  }

  static String get environmentName {
    switch (environment) {
      case AppEnvironment.development:
        return 'Development';

      case AppEnvironment.staging:
        return 'Staging';

      case AppEnvironment.production:
        return 'Production';
    }
  }

  static bool get shouldShowDebugBanner {
    return !isProduction;
  }

  static bool get shouldUseMockData {
    return enableMockData &&
        isDevelopment;
  }

  static bool get shouldEnableLogs {
    return enableLogging &&
        !isProduction;
  }

  // =====================================================
  // VALIDATION HELPERS
  // =====================================================

  static bool isSupportedLanguage(
    String languageCode,
  ) {
    return supportedLanguages.contains(
      languageCode,
    );
  }

  static bool isAllowedImageExtension(
    String extension,
  ) {
    return allowedImageExtensions.contains(
      extension.toLowerCase(),
    );
  }

  static bool isAllowedDocumentExtension(
    String extension,
  ) {
    return allowedDocumentExtensions.contains(
      extension.toLowerCase(),
    );
  }

  static bool isValidImageSize(
    int sizeInBytes,
  ) {
    return sizeInBytes <= maxImageSize;
  }

  static bool isValidDocumentSize(
    int sizeInBytes,
  ) {
    return sizeInBytes <= maxDocumentSize;
  }

  // =====================================================
  // CONFIG SUMMARY
  // =====================================================

  static Map<String, dynamic> summary() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'buildNumber': buildNumber,
      'environment': environmentName,
      'baseUrl': baseUrl,
      'socketUrl': socketUrl,
      'enableLogging': enableLogging,
      'enableSocket': enableSocket,
      'enablePushNotifications':
          enablePushNotifications,
      'enableAnalytics': enableAnalytics,
      'defaultLanguage': defaultLanguage,
      'defaultCurrency': defaultCurrency,
      'timezone': timezone,
    };
  }
}