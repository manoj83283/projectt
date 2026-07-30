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
import '../screens/services/edit_service_screen.dart';
import '../screens/services/service_details_screen.dart';

// Bookings
import '../screens/bookings/bookings_screen.dart';
import '../screens/bookings/booking_details_screen.dart';

// Orders
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_details_screen.dart';

// Customers
import '../screens/customers/customers_screen.dart';
import '../screens/customers/customer_details_screen.dart';

// Earnings
import '../screens/earnings/earnings_screen.dart';
import '../screens/earnings/transactions_screen.dart';

// Reviews
import '../screens/reviews/reviews_screen.dart';

// Chat
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';

// Notifications
import '../screens/notifications/notifications_screen.dart';

// Availability
import '../screens/availability/availability_screen.dart';

// Profile
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/help_support_screen.dart';

class AppRoutes {
  // =========================
  // AUTH
  // =========================

  static const String splash =
      '/splash';

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

  // =========================
  // DASHBOARD
  // =========================

  static const String dashboard =
      '/dashboard';

  // =========================
  // SERVICES
  // =========================

  static const String myServices =
      '/my-services';

  static const String addService =
      '/add-service';

  static const String editService =
      '/edit-service';

  static const String serviceDetails =
      '/service-details';

  // =========================
  // BOOKINGS
  // =========================

  static const String bookings =
      '/bookings';

  static const String bookingDetails =
      '/booking-details';

  // =========================
  // ORDERS
  // =========================

  static const String orders =
      '/orders';

  static const String orderDetails =
      '/order-details';

  // =========================
  // CUSTOMERS
  // =========================

  static const String customers =
      '/customers';

  static const String customerDetails =
      '/customer-details';

  // =========================
  // EARNINGS
  // =========================

  static const String earnings =
      '/earnings';

  static const String transactions =
      '/transactions';

  // =========================
  // REVIEWS
  // =========================

  static const String reviews =
      '/reviews';

  // =========================
  // CHAT
  // =========================

  static const String chats =
      '/chats';

  static const String chatScreen =
      '/chat-screen';

  // =========================
  // NOTIFICATIONS
  // =========================

  static const String notifications =
      '/notifications';

  // =========================
  // AVAILABILITY
  // =========================

  static const String availability =
      '/availability';

  // =========================
  // PROFILE
  // =========================

  static const String profile =
      '/profile';

  static const String editProfile =
      '/edit-profile';

  static const String settings =
      '/settings';

  static const String helpSupport =
      '/help-support';

  // =========================
  // ROUTES
  // =========================

  static Map<String, WidgetBuilder>
      routes = {
    // Splash
    splash: (context) =>
        const SplashScreen(),

    // Auth
    login: (context) =>
        const LoginScreen(),

    register: (context) =>
        const RegisterScreen(),

    otp: (context) =>
        const OtpScreen(),

    forgotPassword: (context) =>
        const ForgotPasswordScreen(),

    resetPassword: (context) =>
        const ResetPasswordScreen(),

    // Dashboard
    dashboard: (context) =>
        const DashboardScreen(),

    // Services
    myServices: (context) =>
        const MyServicesScreen(),

    addService: (context) =>
        const AddServiceScreen(),

    // Bookings
    bookings: (context) =>
        const BookingsScreen(),

    // Orders
    orders: (context) =>
        const OrdersScreen(),

    // Customers
    customers: (context) =>
        const CustomersScreen(),

    // Earnings
    earnings: (context) =>
        const EarningsScreen(),

    transactions: (context) =>
        const TransactionsScreen(),

    // Reviews
    reviews: (context) =>
        const ReviewsScreen(),

    // Chat
    chats: (context) =>
        const ChatListScreen(),

    // Notifications
    notifications: (context) =>
        const NotificationsScreen(),

    // Availability
    availability: (context) =>
        const AvailabilityScreen(),

    // Profile
    profile: (context) =>
        const ProfileScreen(),

    editProfile: (context) =>
        const EditProfileScreen(),

    settings: (context) =>
        const SettingsScreen(),

    helpSupport: (context) =>
        const HelpSupportScreen(),
  };

  // =========================
  // ON GENERATE ROUTE
  // =========================

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(
            body: Center(
              child: Text(
                'Route Not Found',
              ),
            ),
          ),
        );
    }
  }
}