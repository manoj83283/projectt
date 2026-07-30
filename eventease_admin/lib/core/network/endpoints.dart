import '../constants/api_constants.dart';

class Endpoints {
  Endpoints._();

  // =====================================================
  // AUTH
  // =====================================================

  static const login =
      ApiConstants.login;

  static const logout =
      ApiConstants.logout;

  static const refreshToken =
      ApiConstants.refreshToken;

  static const forgotPassword =
      ApiConstants.forgotPassword;

  static const verifyOtp =
      ApiConstants.verifyOtp;

  static const resetPassword =
      ApiConstants.resetPassword;

  static const profile =
      ApiConstants.profile;

  static const changePassword =
      ApiConstants.changePassword;

  // =====================================================
  // DASHBOARD
  // =====================================================

  static const dashboard =
      ApiConstants.dashboard;

  static const dashboardSummary =
      ApiConstants.dashboardSummary;

  static const dashboardAnalytics =
      ApiConstants.dashboardAnalytics;

  // =====================================================
  // CUSTOMERS
  // =====================================================

  static const customers =
      ApiConstants.customers;

  static String customerById(
    String id,
  ) =>
      '${ApiConstants.customers}/$id';

  // =====================================================
  // PROVIDERS
  // =====================================================

  static const providers =
      ApiConstants.providers;

  static String providerById(
    String id,
  ) =>
      '${ApiConstants.providers}/$id';

  static String approveProvider(
    String id,
  ) =>
      '${ApiConstants.providerApprove}/$id';

  static String rejectProvider(
    String id,
  ) =>
      '${ApiConstants.providerReject}/$id';

  // =====================================================
  // ADMINS
  // =====================================================

  static const admins =
      ApiConstants.admins;

  static String adminById(
    String id,
  ) =>
      '${ApiConstants.admins}/$id';

  // =====================================================
  // CATEGORIES
  // =====================================================

  static const categories =
      ApiConstants.categories;

  static String categoryById(
    String id,
  ) =>
      '${ApiConstants.categories}/$id';

  // =====================================================
  // SERVICES
  // =====================================================

  static const services =
      ApiConstants.services;

  static String serviceById(
    String id,
  ) =>
      '${ApiConstants.services}/$id';

  // =====================================================
  // BOOKINGS
  // =====================================================

  static const bookings =
      ApiConstants.bookings;

  static String bookingById(
    String id,
  ) =>
      '${ApiConstants.bookings}/$id';

  // =====================================================
  // ORDERS
  // =====================================================

  static const orders =
      ApiConstants.orders;

  static String orderById(
    String id,
  ) =>
      '${ApiConstants.orders}/$id';

  // =====================================================
  // PAYMENTS
  // =====================================================

  static const payments =
      ApiConstants.payments;

  static String paymentById(
    String id,
  ) =>
      '${ApiConstants.payments}/$id';

  // =====================================================
  // SETTLEMENTS
  // =====================================================

  static const settlements =
      ApiConstants.settlements;

  static String settlementById(
    String id,
  ) =>
      '${ApiConstants.settlements}/$id';

  // =====================================================
  // COUPONS
  // =====================================================

  static const coupons =
      ApiConstants.coupons;

  static String couponById(
    String id,
  ) =>
      '${ApiConstants.coupons}/$id';

  // =====================================================
  // BANNERS
  // =====================================================

  static const banners =
      ApiConstants.banners;

  static String bannerById(
    String id,
  ) =>
      '${ApiConstants.banners}/$id';

  // =====================================================
  // REVIEWS
  // =====================================================

  static const reviews =
      ApiConstants.reviews;

  static String reviewById(
    String id,
  ) =>
      '${ApiConstants.reviews}/$id';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const notifications =
      ApiConstants.notifications;

  static const sendNotification =
      ApiConstants.sendNotification;

  static String notificationById(
    String id,
  ) =>
      '${ApiConstants.notifications}/$id';

  // =====================================================
  // SUPPORT
  // =====================================================

  static const supportTickets =
      ApiConstants.supportTickets;

  static String ticketById(
    String id,
  ) =>
      '${ApiConstants.supportTickets}/$id';

  // =====================================================
  // KYC
  // =====================================================

  static const kyc =
      ApiConstants.kyc;

  static String kycById(
    String id,
  ) =>
      '${ApiConstants.kyc}/$id';

  // =====================================================
  // REPORTS
  // =====================================================

  static const reports =
      ApiConstants.reports;

  static String reportById(
    String id,
  ) =>
      '${ApiConstants.reports}/$id';

  // =====================================================
  // ANALYTICS
  // =====================================================

  static const analytics =
      ApiConstants.analytics;

  static const realtimeAnalytics =
      ApiConstants.realtimeAnalytics;

  // =====================================================
  // FILE UPLOADS
  // =====================================================

  static const uploadFile =
      ApiConstants.uploadFile;

  static const uploadImage =
      ApiConstants.uploadImage;

  static const uploadDocument =
      ApiConstants.uploadDocument;

  // =====================================================
  // SETTINGS
  // =====================================================

  static const settings =
      ApiConstants.settings;

  static const appSettings =
      ApiConstants.appSettings;
}