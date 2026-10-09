class RouteConfig {
  RouteConfig._();

  // =====================================================
  // SPLASH
  // =====================================================

  static const String splash = '/';

  // =====================================================
  // ONBOARDING
  // =====================================================

  static const String onboarding = '/onboarding';

  static const String languageSelection =
      '/language-selection';

  // =====================================================
  // AUTHENTICATION
  // =====================================================

  static const String login = '/login';

  static const String signup = '/signup';

  static const String forgotPassword =
      '/forgot-password';

  static const String otp = '/otp';

  static const String resetPassword =
      '/reset-password';

  // =====================================================
  // HOME
  // =====================================================

  static const String home = '/home';

  static const String search = '/search';

  static const String category = '/category';

  static const String notifications =
      '/notifications';

  // =====================================================
  // SERVICES
  // =====================================================

  static const String serviceList =
      '/service-list';

  static const String services =
      serviceList;

  static const String serviceDetails =
      '/service-details';

  static const String providerProfile =
      '/provider-profile';

  static const String serviceFilter =
      '/service-filter';

  static const String serviceGallery =
      '/service-gallery';

  // =====================================================
  // CUSTOMER BOOKINGS
  // =====================================================

  static const String booking =
      '/booking';

  static const String bookingDetails =
      '/booking-details';

  static const String myBookings =
      '/my-bookings';

  static const String bookings =
      myBookings;

  static const String trackBooking =
      '/track-booking';

  static const String orderSuccess =
      '/order-success';

  // =====================================================
  // LEGACY CUSTOMER ORDER ROUTES
  //
  // Customer application uses Booking terminology.
  // These legacy route paths are retained so older
  // navigation code can be redirected safely.
  // =====================================================

  static const String legacyMyOrders =
      '/my-orders';

  static const String legacyOrderDetails =
      '/order-details';

  static const String legacyTrackOrder =
      '/track-order';

  static const String myOrders =
      myBookings;

  static const String orders =
      myBookings;

  static const String orderDetails =
      bookingDetails;

  static const String trackOrder =
      trackBooking;

  // =====================================================
  // CART
  // =====================================================

  static const String cart =
      '/cart';

  static const String checkout =
      '/checkout';

  // =====================================================
  // CHAT
  // =====================================================

  static const String chat =
      '/chat';

  static const String chatList =
      '/chat-list';

  // =====================================================
  // REVIEWS
  // =====================================================

  static const String reviews =
      '/reviews';

  static const String ratingDialog =
      '/rating-dialog';

  // =====================================================
  // PROFILE
  // =====================================================

  static const String profile =
      '/profile';

  static const String editProfile =
      '/edit-profile';

  static const String address =
      '/address';

  static const String addresses =
      address;

  static const String addAddress =
      '/add-address';

  static const String settings =
      '/settings';

  static const String language =
      '/language';

  static const String changePassword =
      '/change-password';

  static const String helpSupport =
      '/help-support';

  static const String privacyPolicy =
      '/privacy-policy';

  static const String termsConditions =
      '/terms-conditions';

  // =====================================================
  // SUPPORT
  // =====================================================

  static const String help =
      '/help';

  static const String about =
      '/about';

  static const String faq =
      '/faq';

  static const String contactUs =
      '/contact-us';

  static const String blogs =
      '/blogs';

  // =====================================================
  // WALLET
  // =====================================================

  static const String wallet =
      '/wallet';

  static const String transactions =
      '/transactions';

  // =====================================================
  // COUPONS
  // =====================================================

  static const String coupons =
      '/coupons';

  // =====================================================
  // FAVORITES
  // =====================================================

  static const String favorites =
      '/favorites';

  // =====================================================
  // NOTIFICATION SETTINGS
  // =====================================================

  static const String notificationSettings =
      '/notification-settings';

  // =====================================================
  // SECURITY
  // =====================================================

  static const String security =
      '/security';

  // =====================================================
  // LEGAL
  // =====================================================

  static const String licenses =
      '/licenses';

  static const String refunds =
      '/refund-policy';

  // =====================================================
  // ERROR PAGES
  // =====================================================

  static const String notFound =
      '/not-found';

  static const String noInternet =
      '/no-internet';

  // =====================================================
  // AUTHENTICATION ROUTES
  // =====================================================

  static const List<String> authRoutes =
      <String>[
    splash,
    onboarding,
    languageSelection,
    login,
    signup,
    forgotPassword,
    otp,
    resetPassword,
  ];

  // =====================================================
  // HOME ROUTES
  // =====================================================

  static const List<String> homeRoutes =
      <String>[
    home,
    search,
    category,
    notifications,
  ];

  // =====================================================
  // SERVICE ROUTES
  // =====================================================

  static const List<String> serviceRoutes =
      <String>[
    serviceList,
    serviceDetails,
    providerProfile,
    serviceFilter,
    serviceGallery,
  ];

  // =====================================================
  // BOOKING ROUTES
  // =====================================================

  static const List<String> bookingRoutes =
      <String>[
    booking,
    bookingDetails,
    myBookings,
    trackBooking,
    orderSuccess,
  ];

  // =====================================================
  // LEGACY ORDER ROUTES
  // =====================================================

  static const List<String> legacyOrderRoutes =
      <String>[
    legacyMyOrders,
    legacyOrderDetails,
    legacyTrackOrder,
  ];

  // =====================================================
  // CART ROUTES
  // =====================================================

  static const List<String> cartRoutes =
      <String>[
    cart,
    checkout,
  ];

  // =====================================================
  // CHAT ROUTES
  // =====================================================

  static const List<String> chatRoutes =
      <String>[
    chat,
    chatList,
  ];

  // =====================================================
  // REVIEW ROUTES
  // =====================================================

  static const List<String> reviewRoutes =
      <String>[
    reviews,
    ratingDialog,
  ];

  // =====================================================
  // PROFILE ROUTES
  // =====================================================

  static const List<String> profileRoutes =
      <String>[
    profile,
    editProfile,
    address,
    addAddress,
    settings,
    language,
    changePassword,
    helpSupport,
    privacyPolicy,
    termsConditions,
  ];

  // =====================================================
  // SUPPORT ROUTES
  // =====================================================

  static const List<String> supportRoutes =
      <String>[
    help,
    about,
    faq,
    contactUs,
    blogs,
  ];

  // =====================================================
  // WALLET ROUTES
  // =====================================================

  static const List<String> walletRoutes =
      <String>[
    wallet,
    transactions,
  ];

  // =====================================================
  // MISCELLANEOUS ROUTES
  // =====================================================

  static const List<String> miscRoutes =
      <String>[
    coupons,
    favorites,
    notificationSettings,
    security,
    licenses,
    refunds,
    notFound,
    noInternet,
  ];

  // =====================================================
  // ALL ROUTES
  // =====================================================

  static const List<String> allRoutes =
      <String>[
    splash,
    onboarding,
    languageSelection,
    login,
    signup,
    forgotPassword,
    otp,
    resetPassword,
    home,
    search,
    category,
    notifications,
    serviceList,
    serviceDetails,
    providerProfile,
    serviceFilter,
    serviceGallery,
    booking,
    bookingDetails,
    myBookings,
    trackBooking,
    orderSuccess,
    legacyMyOrders,
    legacyOrderDetails,
    legacyTrackOrder,
    cart,
    checkout,
    chat,
    chatList,
    reviews,
    ratingDialog,
    profile,
    editProfile,
    address,
    addAddress,
    settings,
    language,
    changePassword,
    helpSupport,
    privacyPolicy,
    termsConditions,
    help,
    about,
    faq,
    contactUs,
    blogs,
    wallet,
    transactions,
    coupons,
    favorites,
    notificationSettings,
    security,
    licenses,
    refunds,
    notFound,
    noInternet,
  ];

  // =====================================================
  // NORMALIZE ROUTE
  // =====================================================

  static String normalizeRoute(
    String route,
  ) {
    final normalizedRoute =
        route.trim();

    if (normalizedRoute.isEmpty) {
      return splash;
    }

    if (normalizedRoute ==
        legacyMyOrders) {
      return myBookings;
    }

    if (normalizedRoute ==
        legacyOrderDetails) {
      return bookingDetails;
    }

    if (normalizedRoute ==
        legacyTrackOrder) {
      return trackBooking;
    }

    return normalizedRoute;
  }

  // =====================================================
  // AUTHENTICATION ROUTE CHECK
  // =====================================================

  static bool isAuthRoute(
    String route,
  ) {
    return authRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // HOME ROUTE CHECK
  // =====================================================

  static bool isHomeRoute(
    String route,
  ) {
    return homeRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // SERVICE ROUTE CHECK
  // =====================================================

  static bool isServiceRoute(
    String route,
  ) {
    return serviceRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // BOOKING ROUTE CHECK
  // =====================================================

  static bool isBookingRoute(
    String route,
  ) {
    return bookingRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // ORDER ROUTE CHECK
  //
  // Customer orders are normalized to bookings.
  // =====================================================

  static bool isOrderRoute(
    String route,
  ) {
    return bookingRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // LEGACY ORDER ROUTE CHECK
  // =====================================================

  static bool isLegacyOrderRoute(
    String route,
  ) {
    return legacyOrderRoutes.contains(
      route.trim(),
    );
  }

  // =====================================================
  // CART ROUTE CHECK
  // =====================================================

  static bool isCartRoute(
    String route,
  ) {
    return cartRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // CHAT ROUTE CHECK
  // =====================================================

  static bool isChatRoute(
    String route,
  ) {
    return chatRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // REVIEW ROUTE CHECK
  // =====================================================

  static bool isReviewRoute(
    String route,
  ) {
    return reviewRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // PROFILE ROUTE CHECK
  // =====================================================

  static bool isProfileRoute(
    String route,
  ) {
    return profileRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // SUPPORT ROUTE CHECK
  // =====================================================

  static bool isSupportRoute(
    String route,
  ) {
    return supportRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // WALLET ROUTE CHECK
  // =====================================================

  static bool isWalletRoute(
    String route,
  ) {
    return walletRoutes.contains(
      normalizeRoute(route),
    );
  }

  // =====================================================
  // KNOWN ROUTE CHECK
  // =====================================================

  static bool isKnownRoute(
    String route,
  ) {
    final originalRoute =
        route.trim();

    final normalizedRoute =
        normalizeRoute(
      originalRoute,
    );

    return allRoutes.contains(
          originalRoute,
        ) ||
        allRoutes.contains(
          normalizedRoute,
        );
  }

  // =====================================================
  // AUTHENTICATION REQUIREMENT
  // =====================================================

  static bool requiresAuthentication(
    String route,
  ) {
    return !isAuthRoute(
      route,
    );
  }

  // =====================================================
  // SAFE ROUTE
  // =====================================================

  static String safeRoute(
    String? route, {
    String fallback = home,
  }) {
    if (route == null ||
        route.trim().isEmpty) {
      return fallback;
    }

    final normalizedRoute =
        normalizeRoute(
      route,
    );

    if (!isKnownRoute(
      normalizedRoute,
    )) {
      return fallback;
    }

    return normalizedRoute;
  }

  // =====================================================
  // CUSTOMER HISTORY ROUTE
  // =====================================================

  static String customerHistoryRoute() {
    return myBookings;
  }

  // =====================================================
  // CUSTOMER BOOKING DETAILS ROUTE
  // =====================================================

  static String customerBookingDetailsRoute() {
    return bookingDetails;
  }

  // =====================================================
  // CUSTOMER BOOKING TRACKING ROUTE
  // =====================================================

  static String customerBookingTrackingRoute() {
    return trackBooking;
  }
}