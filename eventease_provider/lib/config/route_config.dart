import 'package:flutter/material.dart';

// Splash
import '../screens/splash/splash_screen.dart';

// Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';

// Dashboard
import '../screens/dashboard/dashboard_screen.dart';

// Services
import '../screens/services/my_services_screen.dart';
import '../screens/services/add_service_screen.dart';

// Bookings
import '../screens/bookings/bookings_screen.dart';

// Orders
import '../screens/orders/orders_screen.dart';

// Customers
import '../screens/customers/customers_screen.dart';

// Earnings
import '../screens/earnings/earnings_screen.dart';
import '../screens/earnings/transactions_screen.dart';

// Reviews
import '../screens/reviews/reviews_screen.dart';

// Chat
import '../screens/chat/chat_list_screen.dart';

// Notifications
import '../screens/notifications/notifications_screen.dart';

// Availability
import '../screens/availability/availability_screen.dart';

// Profile
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/help_support_screen.dart';

class RouteConfig {
  RouteConfig._();

  // =====================================================
  // INITIAL ROUTE
  // =====================================================

  static const String initialRoute = splash;

  // =====================================================
  // SPLASH
  // =====================================================

  static const String splash = '/splash';

  // =====================================================
  // AUTH
  // =====================================================

  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // =====================================================
  // DASHBOARD
  // =====================================================

  static const String dashboard = '/dashboard';

  // =====================================================
  // SERVICES
  // =====================================================

  static const String myServices = '/my-services';
  static const String addService = '/add-service';
  static const String editService = '/edit-service';
  static const String serviceDetails = '/service-details';

  // =====================================================
  // BOOKINGS
  // =====================================================

  static const String bookings = '/bookings';
  static const String bookingDetails = '/booking-details';

  // =====================================================
  // ORDERS
  // =====================================================

  static const String orders = '/orders';
  static const String orderDetails = '/order-details';

  // =====================================================
  // CUSTOMERS
  // =====================================================

  static const String customers = '/customers';
  static const String customerDetails = '/customer-details';

  // =====================================================
  // EARNINGS
  // =====================================================

  static const String earnings = '/earnings';
  static const String transactions = '/transactions';

  // =====================================================
  // REVIEWS
  // =====================================================

  static const String reviews = '/reviews';

  // =====================================================
  // CHAT
  // =====================================================

  static const String chatList = '/chat-list';
  static const String chatScreen = '/chat-screen';

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  static const String notifications = '/notifications';

  // =====================================================
  // AVAILABILITY
  // =====================================================

  static const String availability = '/availability';

  // =====================================================
  // PROFILE
  // =====================================================

  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String helpSupport = '/help-support';

  // =====================================================
  // ADDITIONAL SETTINGS
  // =====================================================

  static const String changePassword = '/change-password';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsConditions = '/terms-conditions';
  static const String about = '/about';

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

  static const String serviceId = 'serviceId';
  static const String bookingId = 'bookingId';
  static const String orderId = 'orderId';
  static const String customerId = 'customerId';
  static const String reviewId = 'reviewId';
  static const String chatRoomId = 'chatRoomId';
  static const String notificationId = 'notificationId';

  // =====================================================
  // HELPERS
  // =====================================================

  static bool isAuthRoute(String route) {
    return authRoutes.contains(route);
  }

  static bool isProtectedRoute(String route) {
    return protectedRoutes.contains(route);
  }

  static bool requiresAuthentication(String route) {
    return protectedRoutes.contains(route);
  }

  static bool isDashboardRoute(String route) {
    return route == dashboard;
  }

  static bool isProfileRoute(String route) {
    return route == profile ||
        route == editProfile ||
        route == settings ||
        route == helpSupport;
  }

  static bool isChatRoute(String route) {
    return route == chatList || route == chatScreen;
  }

  static bool isBookingRoute(String route) {
    return route == bookings || route == bookingDetails;
  }

  static bool isOrderRoute(String route) {
    return route == orders || route == orderDetails;
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

  // =====================================================
  // ON GENERATE ROUTE
  // =====================================================

  static Route<dynamic> onGenerateRoute(
    RouteSettings routeSettings,
  ) {
    switch (routeSettings.name) {
      case splash:
        return _route(
          routeSettings,
          const SplashScreen(),
        );

      case login:
        return _route(
          routeSettings,
          const LoginScreen(),
        );

      case register:
        return _route(
          routeSettings,
          const RegisterScreen(),
        );

      case forgotPassword:
        return _route(
          routeSettings,
          const ForgotPasswordScreen(),
        );

      case otp:
        final args = routeSettings.arguments;

        String phone = '';

        if (args is Map) {
          phone = args['phone']?.toString() ?? '';
        }

        return _route(
          routeSettings,
          OtpScreen(
            phone: phone,
          ),
        );

      case resetPassword:
        final args = routeSettings.arguments;

        String email = '';
        String otpCode = '';

        if (args is Map) {
          email = args['email']?.toString() ?? '';
          otpCode = args['otp']?.toString() ?? '';
        }

        return _route(
          routeSettings,
          ResetPasswordScreen(
            email: email,
            otp: otpCode,
          ),
        );

      case dashboard:
        return _route(
          routeSettings,
          const DashboardScreen(),
        );

      case myServices:
        return _route(
          routeSettings,
          const MyServicesScreen(),
        );

      case addService:
        return _route(
          routeSettings,
          const AddServiceScreen(),
        );

      case bookings:
        return _route(
          routeSettings,
          const BookingsScreen(),
        );

      case orders:
        return _route(
          routeSettings,
          const OrdersScreen(),
        );

      case customers:
        return _route(
          routeSettings,
          const CustomersScreen(),
        );

      case earnings:
        return _route(
          routeSettings,
          const EarningsScreen(),
        );

      case transactions:
        return _route(
          routeSettings,
          const TransactionsScreen(),
        );

      case reviews:
        return _route(
          routeSettings,
          const ReviewsScreen(),
        );

      case chatList:
        return _route(
          routeSettings,
          const ChatListScreen(),
        );

      case notifications:
        return _route(
          routeSettings,
          const NotificationsScreen(),
        );

      case availability:
        return _route(
          routeSettings,
          const AvailabilityScreen(),
        );

      case profile:
        return _route(
          routeSettings,
          const ProfileScreen(),
        );

      case editProfile:
        return _route(
          routeSettings,
          const EditProfileScreen(),
        );

      case RouteConfig.settings:
        return _route(
          routeSettings,
          const SettingsScreen(),
        );

      case helpSupport:
        return _route(
          routeSettings,
          const HelpSupportScreen(),
        );

      case editService:
      case serviceDetails:
      case bookingDetails:
      case orderDetails:
      case customerDetails:
      case chatScreen:
      case changePassword:
      case privacyPolicy:
      case termsConditions:
      case about:
        return _routeNotImplemented(
          routeSettings,
          'Route "${routeSettings.name}" requires argument handling or screen connection.',
        );

      default:
        return _unknownRoute(routeSettings);
    }
  }

  // =====================================================
  // ROUTE BUILDER
  // =====================================================

  static Route<dynamic> _route(
    RouteSettings settings,
    Widget screen,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => screen,
    );
  }

  // =====================================================
  // UNKNOWN ROUTE
  // =====================================================

  static Route<dynamic> _unknownRoute(
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Route Not Found'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No route defined for: ${settings.name}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // NOT IMPLEMENTED ROUTE
  // =====================================================

  static Route<dynamic> _routeNotImplemented(
    RouteSettings settings,
    String message,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Route Configuration Required'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}