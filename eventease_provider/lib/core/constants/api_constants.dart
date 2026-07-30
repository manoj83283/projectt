class ApiConstants {
  ApiConstants._();

  // =====================================================
  // BASE URLS
  // =====================================================

  static const String baseUrl =
      'https://api.eventease.com/api/v1';

  static const String socketUrl =
      'https://api.eventease.com';

  static const String imageBaseUrl =
      'https://api.eventease.com/uploads/';

  // =====================================================
  // AUTH
  // =====================================================

  static const String login =
      '/auth/login';

  static const String register =
      '/auth/register';

  static const String verifyOtp =
      '/auth/verify-otp';

  static const String resendOtp =
      '/auth/resend-otp';

  static const String forgotPassword =
      '/auth/forgot-password';

  static const String resetPassword =
      '/auth/reset-password';

  static const String refreshToken =
      '/auth/refresh-token';

  static const String logout =
      '/auth/logout';

  static const String profile =
      '/auth/profile';

  static const String updateProfile =
      '/auth/profile/update';

  static const String changePassword =
      '/auth/change-password';

  // =====================================================
  // PROVIDER
  // =====================================================

  static const String providerProfile =
      '/providers/profile';

  static const String updateProviderProfile =
      '/providers/profile';

  static const String providerDashboard =
      '/providers/dashboard';

  static const String updateAvailability =
      '/providers/availability';

  static const String uploadVerification =
      '/providers/verification';

  static const String providerStatistics =
      '/providers/statistics';

  // =====================================================
  // SERVICES
  // =====================================================

  static const String services =
      '/services';

  static const String createService =
      '/services';

  static const String serviceDetails =
      '/services';

  static const String updateService =
      '/services';

  static const String deleteService =
      '/services';

  static const String activateService =
      '/services/activate';

  static const String deactivateService =
      '/services/deactivate';

  static const String uploadServiceImages =
      '/services/images/upload';

  // =====================================================
  // BOOKINGS
  // =====================================================

  static const String bookings =
      '/bookings';

  static const String bookingDetails =
      '/bookings';

  static const String confirmBooking =
      '/bookings/confirm';

  static const String startBooking =
      '/bookings/start';

  static const String completeBooking =
      '/bookings/complete';

  static const String cancelBooking =
      '/bookings/cancel';

  // =====================================================
  // ORDERS
  // =====================================================

  static const String orders =
      '/orders';

  static const String orderDetails =
      '/orders';

  static const String confirmOrder =
      '/orders/confirm';

  static const String startOrder =
      '/orders/start';

  static const String completeOrder =
      '/orders/complete';

  static const String cancelOrder =
      '/orders/cancel';

  // =====================================================
  // CUSTOMERS
  // =====================================================

  static const String customers =
      '/customers';

  static const String customerDetails =
      '/customers';

  static const String customerBookings =
      '/customers/bookings';

  static const String customerOrders =
      '/customers/orders';

  // =====================================================
  // PAYMENTS
  // =====================================================

  static const String payments =
      '/payments';

  static const String paymentDetails =
      '/payments';

  static const String earnings =
      '/payments/earnings';

  static const String payoutRequest =
      '/payments/payout-request';

  static const String transactions =
      '/payments/transactions';

  static const String paymentHistory =
      '/payments/history';

  // =====================================================
  // REVIEWS
  // =====================================================

  static const String reviews =
      '/reviews';

  static const String replyReview =
      '/reviews/reply';

  static const String deleteReview =
      '/reviews/delete';

  static const String reviewAnalytics =
      '/reviews/analytics';

  // =====================================================
  // CHAT
  // =====================================================

  static const String chatRooms =
      '/chat/rooms';

  static const String messages =
      '/chat/messages';

  static const String sendMessage =
      '/chat/send';

  static const String uploadChatFile =
      '/chat/upload';

  static const String markMessagesRead =
      '/chat/read';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const String notifications =
      '/notifications';

  static const String markNotificationRead =
      '/notifications/read';

  static const String markAllNotificationsRead =
      '/notifications/read-all';

  static const String deleteNotification =
      '/notifications/delete';

  static const String notificationSettings =
      '/notifications/settings';

  // =====================================================
  // FILE UPLOADS
  // =====================================================

  static const String uploadImage =
      '/uploads/image';

  static const String uploadMultipleImages =
      '/uploads/images';

  static const String uploadDocument =
      '/uploads/document';

  // =====================================================
  // STATIC PAGES
  // =====================================================

  static const String privacyPolicy =
      '/settings/privacy-policy';

  static const String termsConditions =
      '/settings/terms-conditions';

  static const String helpSupport =
      '/settings/help-support';

  static const String appConfig =
      '/settings/config';

  // =====================================================
  // PAGINATION
  // =====================================================

  static const int defaultPage = 1;

  static const int defaultLimit = 10;

  static const int maxLimit = 100;

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
}