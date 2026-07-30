class AppConstants {
  AppConstants._();

  // =====================================================
  // APPLICATION
  // =====================================================

  static const String appName =
      'EventEase Admin';

  static const String appTagLine =
      'Manage Your Event Business Efficiently';

  static const String version =
      '1.0.0';

  static const String buildNumber =
      '1';

  // =====================================================
  // PAGINATION
  // =====================================================

  static const int defaultPage = 1;

  static const int defaultLimit = 20;

  static const int maxPageSize = 100;

  // =====================================================
  // DATE FORMATS
  // =====================================================

  static const String dateFormat =
      'dd-MM-yyyy';

  static const String dateTimeFormat =
      'dd-MM-yyyy hh:mm a';

  static const String serverDateFormat =
      'yyyy-MM-dd';

  static const String serverDateTimeFormat =
      'yyyy-MM-ddTHH:mm:ss';

  // =====================================================
  // ANIMATION
  // =====================================================

  static const int splashDuration = 3;

  static const int animationDuration =
      300;

  static const int snackbarDuration =
      3;

  // =====================================================
  // FILE UPLOAD
  // =====================================================

  static const int maxImageSize =
      5 * 1024 * 1024;

  static const int maxDocumentSize =
      10 * 1024 * 1024;

  static const List<String>
      allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  static const List<String>
      allowedDocumentExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
  ];

  // =====================================================
  // IMAGE
  // =====================================================

  static const String placeholderImage =
      'assets/images/placeholder.png';

  static const String logo =
      'assets/images/logo.png';

  static const String logoDark =
      'assets/images/logo_dark.png';

  static const String avatar =
      'assets/images/avatar.png';

  // =====================================================
  // ADMIN ROLES
  // =====================================================

  static const String superAdmin =
      'super_admin';

  static const String admin =
      'admin';

  static const String moderator =
      'moderator';

  static const String supportManager =
      'support_manager';

  static const String financeManager =
      'finance_manager';

  // =====================================================
  // USER STATUS
  // =====================================================

  static const String active =
      'active';

  static const String inactive =
      'inactive';

  static const String blocked =
      'blocked';

  static const String deleted =
      'deleted';

  // =====================================================
  // PROVIDER STATUS
  // =====================================================

  static const String pending =
      'pending';

  static const String approved =
      'approved';

  static const String rejected =
      'rejected';

  static const String suspended =
      'suspended';

  // =====================================================
  // BOOKING STATUS
  // =====================================================

  static const String bookingPending =
      'pending';

  static const String bookingConfirmed =
      'confirmed';

  static const String bookingCompleted =
      'completed';

  static const String bookingCancelled =
      'cancelled';

  // =====================================================
  // ORDER STATUS
  // =====================================================

  static const String orderPlaced =
      'placed';

  static const String orderProcessing =
      'processing';

  static const String orderShipped =
      'shipped';

  static const String orderDelivered =
      'delivered';

  static const String orderCancelled =
      'cancelled';

  // =====================================================
  // PAYMENT STATUS
  // =====================================================

  static const String paymentPending =
      'pending';

  static const String paymentSuccess =
      'success';

  static const String paymentFailed =
      'failed';

  static const String paymentRefunded =
      'refunded';

  // =====================================================
  // PAYMENT METHODS
  // =====================================================

  static const String razorpay =
      'razorpay';

  static const String stripe =
      'stripe';

  static const String upi =
      'upi';

  static const String card =
      'card';

  static const String netBanking =
      'net_banking';

  static const String cash =
      'cash';

  // =====================================================
  // SETTLEMENT STATUS
  // =====================================================

  static const String settlementPending =
      'pending';

  static const String settlementApproved =
      'approved';

  static const String settlementPaid =
      'paid';

  static const String settlementRejected =
      'rejected';

  // =====================================================
  // SUPPORT STATUS
  // =====================================================

  static const String ticketOpen =
      'open';

  static const String ticketInProgress =
      'in_progress';

  static const String ticketResolved =
      'resolved';

  static const String ticketClosed =
      'closed';

  // =====================================================
  // PRIORITY
  // =====================================================

  static const String low =
      'low';

  static const String medium =
      'medium';

  static const String high =
      'high';

  static const String critical =
      'critical';

  // =====================================================
  // REPORT FORMATS
  // =====================================================

  static const String pdf =
      'pdf';

  static const String excel =
      'excel';

  static const String csv =
      'csv';

  // =====================================================
  // ANALYTICS RANGE
  // =====================================================

  static const String daily =
      'daily';

  static const String weekly =
      'weekly';

  static const String monthly =
      'monthly';

  static const String yearly =
      'yearly';

  // =====================================================
  // NOTIFICATION TYPES
  // =====================================================

  static const String push =
      'push';

  static const String email =
      'email';

  static const String sms =
      'sms';

  static const String broadcast =
      'broadcast';

  // =====================================================
  // DRAWER SETTINGS
  // =====================================================

  static const double drawerWidth =
      280;

  static const double collapsedDrawerWidth =
      90;

  // =====================================================
  // DASHBOARD
  // =====================================================

  static const int dashboardCardCount =
      4;

  static const int latestRecordsLimit =
      10;

  // =====================================================
  // CACHE
  // =====================================================

  static const Duration cacheDuration =
      Duration(minutes: 10);

  // =====================================================
  // REGEX
  // =====================================================

  static const String emailRegex =
      r'^[\w\.-]+@[\w\.-]+\.\w+$';

  static const String phoneRegex =
      r'^[0-9]{10}$';

  // =====================================================
  // DEFAULT VALUES
  // =====================================================

  static const String defaultCurrency =
      'INR';

  static const String defaultLanguage =
      'en';

  static const String timezone =
      'Asia/Kolkata';

  // =====================================================
  // SUPPORT
  // =====================================================

  static const String supportEmail =
      'support@eventease.com';

  static const String supportPhone =
      '+91XXXXXXXXXX';
}