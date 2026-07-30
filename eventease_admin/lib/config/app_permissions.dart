class AppPermissions {
  AppPermissions._();

  // =====================================================
  // DASHBOARD
  // =====================================================

  static const String dashboardView =
      'dashboard:view';

  static const String dashboardAnalytics =
      'dashboard:analytics';

  static const String dashboardReports =
      'dashboard:reports';

  // =====================================================
  // CUSTOMERS
  // =====================================================

  static const String customerView =
      'customer:view';

  static const String customerCreate =
      'customer:create';

  static const String customerEdit =
      'customer:edit';

  static const String customerDelete =
      'customer:delete';

  static const String customerBlock =
      'customer:block';

  // =====================================================
  // PROVIDERS
  // =====================================================

  static const String providerView =
      'provider:view';

  static const String providerCreate =
      'provider:create';

  static const String providerEdit =
      'provider:edit';

  static const String providerDelete =
      'provider:delete';

  static const String providerApprove =
      'provider:approve';

  static const String providerReject =
      'provider:reject';

  static const String providerBlock =
      'provider:block';

  static const String providerKyc =
      'provider:kyc';

  // =====================================================
  // ADMINS
  // =====================================================

  static const String adminView =
      'admin:view';

  static const String adminCreate =
      'admin:create';

  static const String adminEdit =
      'admin:edit';

  static const String adminDelete =
      'admin:delete';

  static const String adminManage =
      'admin:manage';

  // =====================================================
  // ROLES & PERMISSIONS
  // =====================================================

  static const String roleView =
      'role:view';

  static const String roleCreate =
      'role:create';

  static const String roleEdit =
      'role:edit';

  static const String roleDelete =
      'role:delete';

  static const String permissionManage =
      'permission:manage';

  // =====================================================
  // CATEGORIES
  // =====================================================

  static const String categoryView =
      'category:view';

  static const String categoryCreate =
      'category:create';

  static const String categoryEdit =
      'category:edit';

  static const String categoryDelete =
      'category:delete';

  // =====================================================
  // SERVICES
  // =====================================================

  static const String serviceView =
      'service:view';

  static const String serviceCreate =
      'service:create';

  static const String serviceEdit =
      'service:edit';

  static const String serviceDelete =
      'service:delete';

  static const String serviceApprove =
      'service:approve';

  // =====================================================
  // BOOKINGS
  // =====================================================

  static const String bookingView =
      'booking:view';

  static const String bookingCreate =
      'booking:create';

  static const String bookingEdit =
      'booking:edit';

  static const String bookingDelete =
      'booking:delete';

  static const String bookingManage =
      'booking:manage';

  static const String bookingCancel =
      'booking:cancel';

  // =====================================================
  // ORDERS
  // =====================================================

  static const String orderView =
      'order:view';

  static const String orderCreate =
      'order:create';

  static const String orderEdit =
      'order:edit';

  static const String orderDelete =
      'order:delete';

  static const String orderManage =
      'order:manage';

  static const String orderCancel =
      'order:cancel';

  // =====================================================
  // PAYMENTS
  // =====================================================

  static const String paymentView =
      'payment:view';

  static const String paymentManage =
      'payment:manage';

  static const String paymentRefund =
      'payment:refund';

  static const String settlementManage =
      'settlement:manage';

  // =====================================================
  // COUPONS
  // =====================================================

  static const String couponView =
      'coupon:view';

  static const String couponCreate =
      'coupon:create';

  static const String couponEdit =
      'coupon:edit';

  static const String couponDelete =
      'coupon:delete';

  // =====================================================
  // BANNERS
  // =====================================================

  static const String bannerView =
      'banner:view';

  static const String bannerCreate =
      'banner:create';

  static const String bannerEdit =
      'banner:edit';

  static const String bannerDelete =
      'banner:delete';

  // =====================================================
  // REVIEWS
  // =====================================================

  static const String reviewView =
      'review:view';

  static const String reviewDelete =
      'review:delete';

  static const String reviewModerate =
      'review:moderate';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const String notificationView =
      'notification:view';

  static const String notificationSend =
      'notification:send';

  static const String notificationDelete =
      'notification:delete';

  // =====================================================
  // SUPPORT
  // =====================================================

  static const String supportView =
      'support:view';

  static const String supportReply =
      'support:reply';

  static const String supportClose =
      'support:close';

  // =====================================================
  // KYC
  // =====================================================

  static const String kycView =
      'kyc:view';

  static const String kycApprove =
      'kyc:approve';

  static const String kycReject =
      'kyc:reject';

  // =====================================================
  // REPORTS
  // =====================================================

  static const String reportView =
      'report:view';

  static const String reportExport =
      'report:export';

  static const String reportDownload =
      'report:download';

  // =====================================================
  // ANALYTICS
  // =====================================================

  static const String analyticsView =
      'analytics:view';

  static const String analyticsExport =
      'analytics:export';

  // =====================================================
  // SETTINGS
  // =====================================================

  static const String settingsView =
      'settings:view';

  static const String settingsManage =
      'settings:manage';

  // =====================================================
  // PROFILE
  // =====================================================

  static const String profileView =
      'profile:view';

  static const String profileEdit =
      'profile:edit';

  static const String changePassword =
      'profile:change-password';

  // =====================================================
  // ACTIVITY LOGS
  // =====================================================

  static const String activityLogView =
      'activity-log:view';

  static const String auditLogView =
      'audit-log:view';

  // =====================================================
  // ALL PERMISSIONS
  // =====================================================

  static const List<String> allPermissions = [
    dashboardView,
    dashboardAnalytics,
    dashboardReports,

    customerView,
    customerCreate,
    customerEdit,
    customerDelete,
    customerBlock,

    providerView,
    providerCreate,
    providerEdit,
    providerDelete,
    providerApprove,
    providerReject,
    providerBlock,
    providerKyc,

    adminView,
    adminCreate,
    adminEdit,
    adminDelete,
    adminManage,

    roleView,
    roleCreate,
    roleEdit,
    roleDelete,
    permissionManage,

    categoryView,
    categoryCreate,
    categoryEdit,
    categoryDelete,

    serviceView,
    serviceCreate,
    serviceEdit,
    serviceDelete,
    serviceApprove,

    bookingView,
    bookingCreate,
    bookingEdit,
    bookingDelete,
    bookingManage,
    bookingCancel,

    orderView,
    orderCreate,
    orderEdit,
    orderDelete,
    orderManage,
    orderCancel,

    paymentView,
    paymentManage,
    paymentRefund,
    settlementManage,

    couponView,
    couponCreate,
    couponEdit,
    couponDelete,

    bannerView,
    bannerCreate,
    bannerEdit,
    bannerDelete,

    reviewView,
    reviewDelete,
    reviewModerate,

    notificationView,
    notificationSend,
    notificationDelete,

    supportView,
    supportReply,
    supportClose,

    kycView,
    kycApprove,
    kycReject,

    reportView,
    reportExport,
    reportDownload,

    analyticsView,
    analyticsExport,

    settingsView,
    settingsManage,

    profileView,
    profileEdit,
    changePassword,

    activityLogView,
    auditLogView,
  ];

  // =====================================================
  // DEFAULT ROLE PERMISSIONS
  // =====================================================

  static const List<String> superAdminPermissions =
      allPermissions;

  static const List<String> adminPermissions = [
    dashboardView,
    dashboardAnalytics,

    customerView,
    customerEdit,

    providerView,
    providerApprove,
    providerReject,

    bookingView,
    bookingManage,

    orderView,
    orderManage,

    paymentView,

    reportView,
    reportExport,

    analyticsView,

    notificationSend,

    supportView,
    supportReply,
  ];

  static const List<String> supportPermissions = [
    supportView,
    supportReply,
    supportClose,

    customerView,
    providerView,
  ];

  static const List<String> financePermissions = [
    paymentView,
    paymentManage,
    paymentRefund,
    settlementManage,

    reportView,
    reportExport,
  ];

  // =====================================================
  // HELPERS
  // =====================================================

  static bool hasPermission({
    required String permission,
    required List<String> permissions,
  }) {
    return permissions.contains(
      permission,
    );
  }

  static bool hasAnyPermission({
    required List<String> requiredPermissions,
    required List<String> permissions,
  }) {
    return requiredPermissions.any(
      permissions.contains,
    );
  }

  static bool hasAllPermissions({
    required List<String> requiredPermissions,
    required List<String> permissions,
  }) {
    return requiredPermissions.every(
      permissions.contains,
    );
  }
}