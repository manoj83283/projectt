import '../core/constants/api_constants.dart';

enum ApiEnvironment {
  development,
  staging,
  production,
}

class ApiConfig {
  ApiConfig._();

  // =====================================================
  // ACTIVE API ENVIRONMENT
  // =====================================================

  static const ApiEnvironment environment =
      ApiEnvironment.production;

  // =====================================================
  // BASE URLS
  // =====================================================

  static const String developmentBaseUrl =
      ApiConstants.devBaseUrl;

  static const String stagingBaseUrl =
      ApiConstants.stagingBaseUrl;

  static const String productionBaseUrl =
      ApiConstants.prodBaseUrl;

  // =====================================================
  // ACTIVE BASE URL
  // =====================================================

  static String get baseUrl {
    switch (environment) {
      case ApiEnvironment.development:
        return developmentBaseUrl;

      case ApiEnvironment.staging:
        return stagingBaseUrl;

      case ApiEnvironment.production:
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
  // TIMEOUT CONFIG
  // =====================================================

  static const int connectTimeout =
      ApiConstants.connectTimeout;

  static const int receiveTimeout =
      ApiConstants.receiveTimeout;

  static const int sendTimeout =
      ApiConstants.sendTimeout;

  // =====================================================
  // API HEADERS
  // =====================================================

  static const String authorization =
      ApiConstants.authorization;

  static const String bearer =
      ApiConstants.bearer;

  static const String contentType =
      ApiConstants.contentType;

  static const String accept =
      ApiConstants.accept;

  static const String applicationJson =
      ApiConstants.applicationJson;

  static const String multipartFormData =
      ApiConstants.multipartFormData;

  // =====================================================
  // DEFAULT HEADERS
  // =====================================================

  static Map<String, dynamic> get defaultHeaders {
    return {
      accept: applicationJson,
      contentType: applicationJson,
    };
  }

  // =====================================================
  // AUTH HEADER
  // =====================================================

  static Map<String, dynamic> authHeaders(
    String token,
  ) {
    return {
      authorization: '$bearer $token',
      accept: applicationJson,
      contentType: applicationJson,
    };
  }

  // =====================================================
  // MULTIPART HEADERS
  // =====================================================

  static Map<String, dynamic> multipartHeaders({
    String? token,
  }) {
    final headers = {
      accept: applicationJson,
      contentType: multipartFormData,
    };

    if (token != null &&
        token.isNotEmpty) {
      headers[authorization] =
          '$bearer $token';
    }

    return headers;
  }

  // =====================================================
  // PAGINATION DEFAULTS
  // =====================================================

  static const int defaultPage =
      ApiConstants.defaultPage;

  static const int defaultLimit =
      ApiConstants.defaultLimit;

  static const int maxLimit =
      ApiConstants.maxLimit;

  // =====================================================
  // API VERSION
  // =====================================================

  static const String apiVersion =
      'v1';

  static const String adminPrefix =
      '/admin';

  // =====================================================
  // AUTH ENDPOINTS
  // =====================================================

  static const String login =
      ApiConstants.login;

  static const String logout =
      ApiConstants.logout;

  static const String refreshToken =
      ApiConstants.refreshToken;

  static const String forgotPassword =
      ApiConstants.forgotPassword;

  static const String verifyOtp =
      ApiConstants.verifyOtp;

  static const String resetPassword =
      ApiConstants.resetPassword;

  static const String profile =
      ApiConstants.profile;

  static const String updateProfile =
      ApiConstants.updateProfile;

  static const String changePassword =
      ApiConstants.changePassword;

  // =====================================================
  // DASHBOARD ENDPOINTS
  // =====================================================

  static const String dashboard =
      ApiConstants.dashboard;

  static const String dashboardSummary =
      ApiConstants.dashboardSummary;

  static const String dashboardAnalytics =
      ApiConstants.dashboardAnalytics;

  // =====================================================
  // RESOURCE ENDPOINTS
  // =====================================================

  static const String customers =
      ApiConstants.customers;

  static const String providers =
      ApiConstants.providers;

  static const String admins =
      ApiConstants.admins;

  static const String categories =
      ApiConstants.categories;

  static const String services =
      ApiConstants.services;

  static const String bookings =
      ApiConstants.bookings;

  static const String orders =
      ApiConstants.orders;

  static const String payments =
      ApiConstants.payments;

  static const String settlements =
      ApiConstants.settlements;

  static const String coupons =
      ApiConstants.coupons;

  static const String banners =
      ApiConstants.banners;

  static const String reviews =
      ApiConstants.reviews;

  static const String notifications =
      ApiConstants.notifications;

  static const String supportTickets =
      ApiConstants.supportTickets;

  static const String kyc =
      ApiConstants.kyc;

  static const String reports =
      ApiConstants.reports;

  static const String analytics =
      ApiConstants.analytics;

  static const String settings =
      ApiConstants.settings;

  // =====================================================
  // UPLOAD ENDPOINTS
  // =====================================================

  static const String uploadFile =
      ApiConstants.uploadFile;

  static const String uploadImage =
      ApiConstants.uploadImage;

  static const String uploadDocument =
      ApiConstants.uploadDocument;

  // =====================================================
  // QUERY PARAM HELPERS
  // =====================================================

  static Map<String, dynamic> paginationParams({
    int page = defaultPage,
    int limit = defaultLimit,
    String? search,
    String? status,
  }) {
    return {
      'page': page,
      'limit': limit,
      if (search != null &&
          search.trim().isNotEmpty)
        'search': search.trim(),
      if (status != null &&
          status.trim().isNotEmpty)
        'status': status.trim(),
    };
  }

  static Map<String, dynamic> dateRangeParams({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return {
      if (startDate != null)
        'startDate':
            startDate.toIso8601String(),
      if (endDate != null)
        'endDate':
            endDate.toIso8601String(),
    };
  }

  static Map<String, dynamic> filterParams({
    int page = defaultPage,
    int limit = defaultLimit,
    String? search,
    String? status,
    String? categoryId,
    String? providerId,
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return {
      'page': page,
      'limit': limit,
      if (search != null &&
          search.trim().isNotEmpty)
        'search': search.trim(),
      if (status != null &&
          status.trim().isNotEmpty)
        'status': status.trim(),
      if (categoryId != null &&
          categoryId.trim().isNotEmpty)
        'categoryId': categoryId.trim(),
      if (providerId != null &&
          providerId.trim().isNotEmpty)
        'providerId': providerId.trim(),
      if (customerId != null &&
          customerId.trim().isNotEmpty)
        'customerId': customerId.trim(),
      if (startDate != null)
        'startDate':
            startDate.toIso8601String(),
      if (endDate != null)
        'endDate':
            endDate.toIso8601String(),
    };
  }

  // =====================================================
  // URL HELPERS
  // =====================================================

  static String buildUrl(
    String endpoint,
  ) {
    return '$baseUrl$endpoint';
  }

  static String resourceById({
    required String resource,
    required String id,
  }) {
    return '$resource/$id';
  }

  static String customerById(
    String id,
  ) {
    return '$customers/$id';
  }

  static String providerById(
    String id,
  ) {
    return '$providers/$id';
  }

  static String adminById(
    String id,
  ) {
    return '$admins/$id';
  }

  static String categoryById(
    String id,
  ) {
    return '$categories/$id';
  }

  static String serviceById(
    String id,
  ) {
    return '$services/$id';
  }

  static String bookingById(
    String id,
  ) {
    return '$bookings/$id';
  }

  static String orderById(
    String id,
  ) {
    return '$orders/$id';
  }

  static String paymentById(
    String id,
  ) {
    return '$payments/$id';
  }

  static String settlementById(
    String id,
  ) {
    return '$settlements/$id';
  }

  static String couponById(
    String id,
  ) {
    return '$coupons/$id';
  }

  static String bannerById(
    String id,
  ) {
    return '$banners/$id';
  }

  static String reviewById(
    String id,
  ) {
    return '$reviews/$id';
  }

  static String notificationById(
    String id,
  ) {
    return '$notifications/$id';
  }

  static String ticketById(
    String id,
  ) {
    return '$supportTickets/$id';
  }

  static String kycById(
    String id,
  ) {
    return '$kyc/$id';
  }

  static String reportById(
    String id,
  ) {
    return '$reports/$id';
  }

  // =====================================================
  // ENVIRONMENT HELPERS
  // =====================================================

  static bool get isDevelopment {
    return environment ==
        ApiEnvironment.development;
  }

  static bool get isStaging {
    return environment ==
        ApiEnvironment.staging;
  }

  static bool get isProduction {
    return environment ==
        ApiEnvironment.production;
  }

  static String get environmentName {
    switch (environment) {
      case ApiEnvironment.development:
        return 'Development';

      case ApiEnvironment.staging:
        return 'Staging';

      case ApiEnvironment.production:
        return 'Production';
    }
  }

  // =====================================================
  // CONFIG SUMMARY
  // =====================================================

  static Map<String, dynamic> summary() {
    return {
      'environment': environmentName,
      'baseUrl': baseUrl,
      'socketUrl': socketUrl,
      'connectTimeout': connectTimeout,
      'receiveTimeout': receiveTimeout,
      'sendTimeout': sendTimeout,
      'defaultPage': defaultPage,
      'defaultLimit': defaultLimit,
      'maxLimit': maxLimit,
    };
  }
}