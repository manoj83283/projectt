import 'package:flutter/material.dart';

// Splash
import '../screens/splash/splash_screen.dart';

// Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

// Home
import '../screens/home/home_screen.dart';

// Profile
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/address_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/language_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/help_support_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/terms_conditions_screen.dart';

// Booking
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_details_screen.dart';
import '../screens/booking/track_order_screen.dart';

// Cart
import '../screens/cart/cart_screen.dart';
import '../screens/cart/checkout_screen.dart';

// Notifications
import '../screens/notifications/notifications_screen.dart';

// Support
import '../screens/support/about_screen.dart';

class AppRoutes {
  AppRoutes._();

  // =====================================================
  // ROUTE NAMES
  // =====================================================

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword =
      '/forgot-password';

  static const String home = '/home';

  static const String profile = '/profile';
  static const String editProfile =
      '/edit-profile';

  static const String address =
      '/address';

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

  static const String bookings =
      '/bookings';

  static const String bookingDetails =
      '/booking-details';

  static const String trackBooking =
      '/track-booking';

  static const String cart = '/cart';

  static const String checkout =
      '/checkout';

  static const String notifications =
      '/notifications';

  static const String about = '/about';

  // =====================================================
  // ROUTES MAP
  // =====================================================

  static Map<String, WidgetBuilder>
      get routes => {
            splash: (_) =>
                const SplashScreen(),

            login: (_) =>
                const LoginScreen(),

            register: (_) =>
                const RegisterScreen(),

            forgotPassword: (_) =>
                const ForgotPasswordScreen(),

            home: (_) =>
                const HomeScreen(),

            profile: (_) =>
                const ProfileScreen(),

            editProfile: (_) =>
                const EditProfileScreen(),

            address: (_) =>
                const AddressScreen(),

            settings: (_) =>
                const SettingsScreen(),

            language: (_) =>
                const LanguageScreen(),

            changePassword: (_) =>
                const ChangePasswordScreen(),

            helpSupport: (_) =>
                const HelpSupportScreen(),

            privacyPolicy: (_) =>
                const PrivacyPolicyScreen(),

            termsConditions: (_) =>
                const TermsConditionsScreen(),

            bookings: (_) =>
                const BookingScreen(),

            bookingDetails: (_) =>
                const BookingDetailsScreen(),

            trackBooking: (_) =>
                const TrackOrderScreen(),

            cart: (_) =>
                const CartScreen(),

            checkout: (_) =>
                const CheckoutScreen(),

            notifications: (_) =>
                const NotificationsScreen(),

            about: (_) =>
                const AboutScreen(),
          };

  // =====================================================
  // GENERATE ROUTE
  // =====================================================

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) =>
              const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) =>
              const LoginScreen(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) =>
              const RegisterScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const RouteNotFoundScreen(),
        );
    }
  }
}

// =====================================================
// ROUTE NOT FOUND
// =====================================================

class RouteNotFoundScreen
    extends StatelessWidget {
  const RouteNotFoundScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Page Not Found',
        ),
      ),
      body: const Center(
        child: Text(
          '404 - Route Not Found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}