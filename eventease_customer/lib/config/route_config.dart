class RouteConfig {
  RouteConfig._();

  // ==========================================
  // SPLASH
  // ==========================================

  static const String splash = '/';

  // ==========================================
  // ONBOARDING
  // ==========================================

  static const String onboarding = '/onboarding';

  static const String languageSelection = '/language-selection';

  // ==========================================
  // AUTH
  // ==========================================

  static const String login = '/login';

  static const String signup = '/signup';

  static const String forgotPassword = '/forgot-password';

  static const String otp = '/otp';

  static const String resetPassword = '/reset-password';

  // ==========================================
  // HOME
  // ==========================================

  static const String home = '/home';

  static const String search = '/search';

  static const String category = '/category';

  static const String notifications = '/notifications';

  // ==========================================
  // SERVICES
  // ==========================================

  static const String serviceList = '/service-list';

  // Alias for screens using RouteConfig.services
  static const String services = serviceList;

  static const String serviceDetails = '/service-details';

  static const String providerProfile = '/provider-profile';

  static const String serviceFilter = '/service-filter';

  static const String serviceGallery = '/service-gallery';

  // ==========================================
  // BOOKING
  // ==========================================

  static const String booking = '/booking';

  static const String bookingDetails = '/booking-details';

  static const String myBookings = '/my-bookings';

  // Alias for screens using RouteConfig.bookings
  static const String bookings = myBookings;

  static const String trackBooking = '/track-booking';

  static const String orderSuccess = '/order-success';

  // ==========================================
  // CART
  // ==========================================

  static const String cart = '/cart';

  static const String checkout = '/checkout';

  // ==========================================
  // ORDERS
  // ==========================================

  static const String myOrders = '/my-orders';

  // Alias for screens using RouteConfig.orders
  static const String orders = myOrders;

  static const String orderDetails = '/order-details';

  static const String trackOrder = '/track-order';

  // ==========================================
  // CHAT
  // ==========================================

  static const String chat = '/chat';

  static const String chatList = '/chat-list';

  // ==========================================
  // REVIEWS
  // ==========================================

  static const String reviews = '/reviews';

  static const String ratingDialog = '/rating-dialog';

  // ==========================================
  // PROFILE
  // ==========================================

  static const String profile = '/profile';

  static const String editProfile = '/edit-profile';

  static const String address = '/address';

  // Alias for screens using RouteConfig.addresses
  static const String addresses = address;

  static const String addAddress = '/add-address';

  static const String settings = '/settings';

  static const String language = '/language';

  static const String changePassword = '/change-password';

  static const String helpSupport = '/help-support';

  static const String privacyPolicy = '/privacy-policy';

  static const String termsConditions = '/terms-conditions';

  // ==========================================
  // SUPPORT
  // ==========================================

  static const String help = '/help';

  static const String about = '/about';

  // ==========================================
  // CMS
  // ==========================================

  static const String faq = '/faq';

  static const String contactUs = '/contact-us';

  static const String blogs = '/blogs';

  // ==========================================
  // WALLET
  // ==========================================

  static const String wallet = '/wallet';

  static const String transactions = '/transactions';

  // ==========================================
  // COUPONS
  // ==========================================

  static const String coupons = '/coupons';

  // ==========================================
  // FAVORITES
  // ==========================================

  static const String favorites = '/favorites';

  // ==========================================
  // NOTIFICATION SETTINGS
  // ==========================================

  static const String notificationSettings = '/notification-settings';

  // ==========================================
  // SECURITY
  // ==========================================

  static const String security = '/security';

  // ==========================================
  // LEGAL
  // ==========================================

  static const String licenses = '/licenses';

  static const String refunds = '/refund-policy';

  // ==========================================
  // ERROR PAGES
  // ==========================================

  static const String notFound = '/not-found';

  static const String noInternet = '/no-internet';

  // ==========================================
  // ROUTE GROUPS
  // ==========================================

  static const List<String> authRoutes = [
    splash,
    onboarding,
    languageSelection,
    login,
    signup,
    forgotPassword,
    otp,
    resetPassword,
  ];

  static const List<String> homeRoutes = [
    home,
    search,
    category,
    notifications,
  ];

  static const List<String> serviceRoutes = [
    serviceList,
    services,
    serviceDetails,
    providerProfile,
    serviceFilter,
    serviceGallery,
  ];

  static const List<String> bookingRoutes = [
    booking,
    bookingDetails,
    myBookings,
    bookings,
    trackBooking,
    orderSuccess,
  ];

  static const List<String> cartRoutes = [
    cart,
    checkout,
  ];

  static const List<String> orderRoutes = [
    myOrders,
    orders,
    orderDetails,
    trackOrder,
  ];

  static const List<String> chatRoutes = [
    chat,
    chatList,
  ];

  static const List<String> reviewRoutes = [
    reviews,
    ratingDialog,
  ];

  static const List<String> profileRoutes = [
    profile,
    editProfile,
    address,
    addresses,
    addAddress,
    settings,
    language,
    changePassword,
    helpSupport,
    privacyPolicy,
    termsConditions,
  ];

  static const List<String> supportRoutes = [
    help,
    about,
    faq,
    contactUs,
    blogs,
  ];

  static const List<String> walletRoutes = [
    wallet,
    transactions,
  ];

  static const List<String> miscRoutes = [
    coupons,
    favorites,
    notificationSettings,
    security,
    licenses,
    refunds,
    notFound,
    noInternet,
  ];

  static const List<String> allRoutes = [
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
    services,
    serviceDetails,
    providerProfile,
    serviceFilter,
    serviceGallery,
    booking,
    bookingDetails,
    myBookings,
    bookings,
    trackBooking,
    orderSuccess,
    cart,
    checkout,
    myOrders,
    orders,
    orderDetails,
    trackOrder,
    chat,
    chatList,
    reviews,
    ratingDialog,
    profile,
    editProfile,
    address,
    addresses,
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

  // ==========================================
  // HELPERS
  // ==========================================

  static bool isAuthRoute(String route) {
    return authRoutes.contains(route);
  }

  static bool isHomeRoute(String route) {
    return homeRoutes.contains(route);
  }

  static bool isServiceRoute(String route) {
    return serviceRoutes.contains(route);
  }

  static bool isBookingRoute(String route) {
    return bookingRoutes.contains(route);
  }

  static bool isCartRoute(String route) {
    return cartRoutes.contains(route);
  }

  static bool isOrderRoute(String route) {
    return orderRoutes.contains(route);
  }

  static bool isChatRoute(String route) {
    return chatRoutes.contains(route);
  }

  static bool isReviewRoute(String route) {
    return reviewRoutes.contains(route);
  }

  static bool isProfileRoute(String route) {
    return profileRoutes.contains(route);
  }

  static bool isSupportRoute(String route) {
    return supportRoutes.contains(route);
  }

  static bool isWalletRoute(String route) {
    return walletRoutes.contains(route);
  }

  static bool isKnownRoute(String route) {
    return allRoutes.contains(route);
  }

  static bool requiresAuthentication(String route) {
    return !isAuthRoute(route);
  }

  // ==========================================
  // SAFE FALLBACKS
  // ==========================================

  static String normalizeRoute(String route) {
    switch (route) {
      case services:
        return serviceList;

      case bookings:
        return myBookings;

      case orders:
        return myOrders;

      case addresses:
        return address;

      default:
        return route;
    }
  }
}