class ApiConstants {
  ApiConstants._();

  // =====================================================
  // ENVIRONMENTS
  // =====================================================

  static const String devBaseUrl =
      'http://localhost:5000/api';

  static const String stagingBaseUrl =
      'https://staging-api.eventease.com/api';

  static const String prodBaseUrl =
      'https://api.eventease.com/api';

  // =====================================================
  // ACTIVE BASE URL
  // =====================================================

  static const String baseUrl =
      prodBaseUrl;

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
  // AUTH
  // =====================================================

  static const String login =
      '/admin/auth/login';

  static const String logout =
      '/admin/auth/logout';

  static const String refreshToken =
      '/admin/auth/refresh-token';

  static const String forgotPassword =
      '/admin/auth/forgot-password';

  static const String verifyOtp =
      '/admin/auth/verify-otp';

  static const String resetPassword =
      '/admin/auth/reset-password';

  static const String profile =
      '/admin/auth/profile';

  static const String updateProfile =
      '/admin/auth/profile/update';

  static const String changePassword =
      '/admin/auth/change-password';

  // =====================================================
  // DASHBOARD
  // =====================================================

  static const String dashboard =
      '/admin/dashboard';

  static const String dashboardSummary =
      '/admin/dashboard/summary';

  static const String dashboardAnalytics =
      '/admin/dashboard/analytics';

  // =====================================================
  // CUSTOMERS
  // =====================================================

  static const String customers =
      '/admin/customers';

  static const String customerDetails =
      '/admin/customers';

  static const String customerAnalytics =
      '/admin/customers/analytics';

  // =====================================================
  // PROVIDERS
  // =====================================================

  static const String providers =
      '/admin/providers';

  static const String providerDetails =
      '/admin/providers';

  static const String providerApprove =
      '/admin/providers/approve';

  static const String providerReject =
      '/admin/providers/reject';

  static const String providerKyc =
      '/admin/providers/kyc';

  // =====================================================
  // ADMINS
  // =====================================================

  static const String admins =
      '/admin/admins';

  static const String adminRoles =
      '/admin/admins/roles';

  static const String adminPermissions =
      '/admin/admins/permissions';

  // =====================================================
  // CATEGORIES
  // =====================================================

  static const String categories =
      '/admin/categories';

  static const String categoryReorder =
      '/admin/categories/reorder';

  // =====================================================
  // SERVICES
  // =====================================================

  static const String services =
      '/admin/services';

  static const String serviceApprove =
      '/admin/services/approve';

  static const String serviceReject =
      '/admin/services/reject';

  // =====================================================
  // BOOKINGS
  // =====================================================

  static const String bookings =
      '/admin/bookings';

  static const String bookingAnalytics =
      '/admin/bookings/analytics';

  // =====================================================
  // ORDERS
  // =====================================================

  static const String orders =
      '/admin/orders';

  static const String orderAnalytics =
      '/admin/orders/analytics';

  // =====================================================
  // PAYMENTS
  // =====================================================

  static const String payments =
      '/admin/payments';

  static const String refunds =
      '/admin/payments/refunds';

  static const String revenueAnalytics =
      '/admin/payments/revenue';

  // =====================================================
  // SETTLEMENTS
  // =====================================================

  static const String settlements =
      '/admin/settlements';

  static const String settlementAnalytics =
      '/admin/settlements/analytics';

  // =====================================================
  // COUPONS
  // =====================================================

  static const String coupons =
      '/admin/coupons';

  static const String validateCoupon =
      '/admin/coupons/validate';

  // =====================================================
  // BANNERS
  // =====================================================

  static const String banners =
      '/admin/banners';

  static const String bannerAnalytics =
      '/admin/banners/analytics';

  // =====================================================
  // REVIEWS
  // =====================================================

  static const String reviews =
      '/admin/reviews';

  static const String reviewAnalytics =
      '/admin/reviews/analytics';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const String notifications =
      '/admin/notifications';

  static const String sendNotification =
      '/admin/notifications/send';

  static const String notificationAnalytics =
      '/admin/notifications/analytics';

  // =====================================================
  // SUPPORT
  // =====================================================

  static const String supportTickets =
      '/admin/support';

  static const String supportAnalytics =
      '/admin/support/analytics';

  // =====================================================
  // KYC
  // =====================================================

  static const String kyc =
      '/admin/kyc';

  static const String approveKyc =
      '/admin/kyc/approve';

  static const String rejectKyc =
      '/admin/kyc/reject';

  // =====================================================
  // REPORTS
  // =====================================================

  static const String reports =
      '/admin/reports';

  static const String exportReport =
      '/admin/reports/export';

  // =====================================================
  // ANALYTICS
  // =====================================================

  static const String analytics =
      '/admin/analytics';

  static const String realtimeAnalytics =
      '/admin/analytics/realtime';

  // =====================================================
  // FILE UPLOADS
  // =====================================================

  static const String uploadFile =
      '/uploads';

  static const String uploadImage =
      '/uploads/image';

  static const String uploadDocument =
      '/uploads/document';

  // =====================================================
  // SETTINGS
  // =====================================================

  static const String settings =
      '/admin/settings';

  static const String appSettings =
      '/admin/settings/application';

  // =====================================================
  // HEADERS
  // =====================================================

  static const String authorization =
      'Authorization';

  static const String bearer =
      'Bearer';

  static const String contentType =
      'Content-Type';

  static const String applicationJson =
      'application/json';

  static const String multipartFormData =
      'multipart/form-data';

  static const String accept =
      'Accept';

  // =====================================================
  // PAGINATION
  // =====================================================

  static const int defaultPage = 1;

  static const int defaultLimit = 20;

  static const int maxLimit = 100;
}