enum EnvironmentType {
  development,
  staging,
  production,
}

class Environment {
  Environment._();

  // =====================================================
  // CURRENT ENVIRONMENT
  // =====================================================

  static const EnvironmentType current =
      EnvironmentType.production;

  // =====================================================
  // APP INFO
  // =====================================================

  static const String appName =
      'EventEase Admin';

  static const String packageName =
      'com.eventease.admin';

  static const String version =
      '1.0.0';

  static const String buildNumber =
      '1';

  // =====================================================
  // BASE URLS
  // =====================================================

  static const String developmentBaseUrl =
      'http://localhost:5000/api';

  static const String stagingBaseUrl =
      'https://staging-api.eventease.com/api';

  static const String productionBaseUrl =
      'https://api.eventease.com/api';

  static String get baseUrl {
    switch (current) {
      case EnvironmentType.development:
        return developmentBaseUrl;

      case EnvironmentType.staging:
        return stagingBaseUrl;

      case EnvironmentType.production:
        return productionBaseUrl;
    }
  }

  // =====================================================
  // SOCKET URL
  // =====================================================

  static String get socketUrl {
    return baseUrl.replaceAll(
      '/api',
      '',
    );
  }

  // =====================================================
  // ENVIRONMENT FLAGS
  // =====================================================

  static bool get isDevelopment =>
      current ==
      EnvironmentType.development;

  static bool get isStaging =>
      current ==
      EnvironmentType.staging;

  static bool get isProduction =>
      current ==
      EnvironmentType.production;

  static String get environmentName {
    switch (current) {
      case EnvironmentType.development:
        return 'Development';

      case EnvironmentType.staging:
        return 'Staging';

      case EnvironmentType.production:
        return 'Production';
    }
  }

  // =====================================================
  // LOGGING
  // =====================================================

  static bool get enableLogs =>
      !isProduction;

  static bool get enableApiLogs =>
      !isProduction;

  static bool get enableSocketLogs =>
      !isProduction;

  static bool get showDebugBanner =>
      !isProduction;

  // =====================================================
  // ANALYTICS
  // =====================================================

  static const bool enableAnalytics =
      true;

  static const bool enableCrashlytics =
      true;

  // =====================================================
  // FEATURE FLAGS
  // =====================================================

  static const bool enableRealtime =
      true;

  static const bool enableNotifications =
      true;

  static const bool enableFileUpload =
      true;

  static const bool enableExport =
      true;

  static const bool enableChat =
      true;

  static const bool enableKyc =
      true;

  // =====================================================
  // SECURITY
  // =====================================================

  static const bool forceHttps =
      true;

  static const bool enableTokenRefresh =
      true;

  static const bool autoLogoutOn401 =
      true;

  // =====================================================
  // API TIMEOUTS
  // =====================================================

  static const int connectTimeout =
      30000;

  static const int receiveTimeout =
      30000;

  static const int sendTimeout =
      30000;

  // =====================================================
  // CACHE
  // =====================================================

  static const Duration cacheDuration =
      Duration(minutes: 15);

  // =====================================================
  // DASHBOARD
  // =====================================================

  static const int dashboardRefreshTime =
      30;

  static const int realtimeRefreshTime =
      10;

  // =====================================================
  // PAGINATION
  // =====================================================

  static const int defaultPageSize =
      20;

  static const int maxPageSize =
      200;

  // =====================================================
  // FILES
  // =====================================================

  static const int maxImageSize =
      5 * 1024 * 1024;

  static const int maxDocumentSize =
      20 * 1024 * 1024;

  static const List<String>
      allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  static const List<String>
      allowedDocumentFormats = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
  ];

  // =====================================================
  // CURRENCY
  // =====================================================

  static const String currency =
      'INR';

  static const String currencySymbol =
      '₹';

  // =====================================================
  // LOCALIZATION
  // =====================================================

  static const String defaultLanguage =
      'en';

  static const List<String>
      supportedLanguages = [
    'en',
    'hi',
    'te',
    'ta',
    'kn',
    'ml',
  ];

  // =====================================================
  // EXPORT TYPES
  // =====================================================

  static const String pdf = 'pdf';
  static const String excel = 'excel';
  static const String csv = 'csv';

  // =====================================================
  // SUMMARY
  // =====================================================

  static Map<String, dynamic> summary() {
    return {
      'environment':
          environmentName,
      'appName': appName,
      'version': version,
      'buildNumber': buildNumber,
      'baseUrl': baseUrl,
      'socketUrl': socketUrl,
      'logsEnabled': enableLogs,
      'analyticsEnabled':
          enableAnalytics,
      'crashlyticsEnabled':
          enableCrashlytics,
      'realtimeEnabled':
          enableRealtime,
      'notificationsEnabled':
          enableNotifications,
    };
  }
}