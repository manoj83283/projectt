class RouteConfig {
  RouteConfig._();

  // =====================================================
  // INITIAL ROUTE
  // =====================================================

  static const String initialRoute =
      splash;

  // =====================================================
  // SPLASH
  // =====================================================

  static const String splash =
      '/splash';

  // =====================================================
  // AUTH
  // =====================================================

  static const String login =
      '/login';

  static const String register =
      '/register';

  static const String otp =
      '/otp';

  static const String forgotPassword =
      '/forgot-password';

  static const String resetPassword =
      '/reset-password';

  // =====================================================
  // DASHBOARD
  // =====================================================

  static const String dashboard =
      '/dashboard';

  // =====================================================
  // SERVICES
  // =====================================================

  static const String myServices =
      '/my-services';

  static const String addService =
      '/add-service';

  static const String editService =
      '/edit-service';

  static const String serviceDetails =
      '/service-details';

  // =====================================================
  // BOOKINGS
  // =====================================================

  static const String bookings =
      '/bookings';

  static const String bookingDetails =
      '/booking-details';

  // =====================================================
  // ORDERS
  // =====================================================

  static const String orders =
      '/orders';

  static const String orderDetails =
      '/order-details';

  // =====================================================
  // CUSTOMERS
  // =====================================================

  static const String customers =
      '/customers';

  static const String customerDetails =
      '/customer-details';

  // =====================================================
  // EARNINGS
  // =====================================================

  static const String earnings =
      '/earnings';

  static const String transactions =
      '/transactions';

  // =====================================================
  // REVIEWS
  // =====================================================

  static const String reviews =
      '/reviews';

  // =====================================================
  // CHAT
  // =====================================================

  static const String chatList =
      '/chat-list';

  static const String chatScreen =
      '/chat-screen';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const String notifications =
      '/notifications';

  // =====================================================
  // AVAILABILITY
  // =====================================================

  static const String availability =
      '/availability';

  // =====================================================
  // PROFILE
  // =====================================================

  static const String profile =
      '/profile';

  static const String editProfile =
      '/edit-profile';

  static const String settings =
      '/settings';

  static const String helpSupport =
      '/help-support';

  // =====================================================
  // ADDITIONAL SETTINGS
  // =====================================================

  static const String changePassword =
      '/change-password';

  static const String privacyPolicy =
      '/privacy-policy';

  static const String termsConditions =
      '/terms-conditions';

  static const String about =
      '/about';

  // =====================================================
  // ROUTE GROUPS
  // =====================================================

  static const List<String> authRoutes = [
    splash,
    login,
    register,
    otp,
    forgotPassword,
    resetPassword,
  ];

  static const List<String> protectedRoutes = [
    dashboard,
    myServices,
    addService,
    editService,
    serviceDetails,
    bookings,
    bookingDetails,
    orders,
    orderDetails,
    customers,
    customerDetails,
    earnings,
    transactions,
    reviews,
    chatList,
    chatScreen,
    notifications,
    availability,
    profile,
    editProfile,
    settings,
    helpSupport,
    changePassword,
    privacyPolicy,
    termsConditions,
    about,
  ];

  // =====================================================
  // DASHBOARD TAB INDEXES
  // =====================================================

  static const int homeTab = 0;

  static const int bookingsTab = 1;

  static const int ordersTab = 2;

  static const int chatsTab = 3;

  static const int profileTab = 4;

  // =====================================================
  // DEEP LINK PARAM KEYS
  // =====================================================

  static const String serviceId =
      'serviceId';

  static const String bookingId =
      'bookingId';

  static const String orderId =
      'orderId';

  static const String customerId =
      'customerId';

  static const String reviewId =
      'reviewId';

  static const String chatRoomId =
      'chatRoomId';

  static const String notificationId =
      'notificationId';

  // =====================================================
  // HELPERS
  // =====================================================

  static bool isAuthRoute(
    String route,
  ) {
    return authRoutes.contains(route);
  }

  static bool isProtectedRoute(
    String route,
  ) {
    return protectedRoutes.contains(route);
  }

  static bool requiresAuthentication(
    String route,
  ) {
    return protectedRoutes.contains(route);
  }

  static bool isDashboardRoute(
    String route,
  ) {
    return route == dashboard;
  }

  static bool isProfileRoute(
    String route,
  ) {
    return route == profile ||
        route == editProfile ||
        route == settings ||
        route == helpSupport;
  }

  static bool isChatRoute(
    String route,
  ) {
    return route == chatList ||
        route == chatScreen;
  }

  static bool isBookingRoute(
    String route,
  ) {
    return route == bookings ||
        route == bookingDetails;
  }

  static bool isOrderRoute(
    String route,
  ) {
    return route == orders ||
        route == orderDetails;
  }

  // =====================================================
  // ALL ROUTES
  // =====================================================

  static const List<String> allRoutes = [
    splash,
    login,
    register,
    otp,
    forgotPassword,
    resetPassword,
    dashboard,
    myServices,
    addService,
    editService,
    serviceDetails,
    bookings,
    bookingDetails,
    orders,
    orderDetails,
    customers,
    customerDetails,
    earnings,
    transactions,
    reviews,
    chatList,
    chatScreen,
    notifications,
    availability,
    profile,
    editProfile,
    settings,
    helpSupport,
    changePassword,
    privacyPolicy,
    termsConditions,
    about,
  ];
}