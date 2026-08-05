import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/route_config.dart';
import 'config/theme_config.dart';
import 'core/storage/storage_helper.dart';

import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/category_provider.dart';
import 'providers/order_provider.dart';
import 'providers/service_provider.dart';

import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/signup_screen.dart';

import 'screens/booking/booking_details_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/booking/my_bookings_screen.dart' as booking_screens;
import 'screens/booking/order_success_screen.dart';
import 'screens/booking/track_booking_screen.dart';

import 'screens/cart/cart_screen.dart';
import 'screens/cart/checkout_screen.dart';

import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/chat_screen.dart';

import 'screens/home/category_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/notifications_screen.dart';
import 'screens/home/search_screen.dart';

import 'screens/orders/my_orders_screen.dart' as order_screens;
import 'screens/orders/order_details_screen.dart';
import 'screens/orders/track_order_screen.dart';

import 'screens/profile/add_address_screen.dart';
import 'screens/profile/address_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/profile/language_screen.dart';
import 'screens/profile/privacy_policy_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/terms_conditions_screen.dart';

import 'screens/reviews/rating_dialog.dart';
import 'screens/reviews/reviews_screen.dart';

import 'screens/services/provider_profile_screen.dart';
import 'screens/services/service_detail_screen.dart';
import 'screens/services/service_filter_screen.dart';
import 'screens/services/service_gallery_screen.dart';
import 'screens/services/service_list_screen.dart';

import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageHelper.init();

  runApp(
    const EventEaseApp(),
  );
}

class EventEaseApp extends StatelessWidget {
  const EventEaseApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ServiceProvider>(
          create: (_) => ServiceProvider(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(
          375,
          812,
        ),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (
          context,
          child,
        ) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConfig.appName,
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: ThemeMode.system,
            supportedLocales: AppConfig.supportedLocales,
            initialRoute: RouteConfig.splash,
            routes: _routes,
            onUnknownRoute: _onUnknownRoute,
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> get _routes {
    return {
      // Splash
      RouteConfig.splash: (context) => const SplashScreen(),

      // Auth
      RouteConfig.login: (context) => const LoginScreen(),
      RouteConfig.signup: (context) => const SignupScreen(),
      RouteConfig.forgotPassword: (context) => const ForgotPasswordScreen(),
      RouteConfig.otp: (context) => OtpScreen(),
      RouteConfig.resetPassword: (context) => ResetPasswordScreen(),

      // Home
      RouteConfig.home: (context) => const HomeScreen(),
      RouteConfig.search: (context) => const SearchScreen(),
      RouteConfig.notifications: (context) => const NotificationsScreen(),
      RouteConfig.category: (context) => const CategoryScreen(),

      // Services
      RouteConfig.serviceList: (context) => const ServiceListScreen(),
      RouteConfig.serviceDetails: (context) => const ServiceDetailScreen(),
      RouteConfig.providerProfile: (context) => const ProviderProfileScreen(),
      RouteConfig.serviceFilter: (context) => const ServiceFilterScreen(),
      RouteConfig.serviceGallery: (context) => const ServiceGalleryScreen(),

      // Booking
      RouteConfig.booking: (context) => const BookingScreen(),
      RouteConfig.myBookings: (context) => booking_screens.MyBookingsScreen(),
      RouteConfig.bookingDetails: (context) => const BookingDetailsScreen(),
      RouteConfig.trackBooking: (context) => const TrackBookingScreen(),
      RouteConfig.orderSuccess: (context) => const OrderSuccessScreen(),

      // Cart
      RouteConfig.cart: (context) => const CartScreen(),
      RouteConfig.checkout: (context) => const CheckoutScreen(),

      // Orders
      RouteConfig.myOrders: (context) => order_screens.MyOrdersScreen(),
      RouteConfig.orderDetails: (context) => const OrderDetailsScreen(),
      RouteConfig.trackOrder: (context) => const TrackOrderScreen(),

      // Reviews
      RouteConfig.reviews: (context) => const ReviewsScreen(),
      RouteConfig.ratingDialog: (context) => _buildRatingDialog(),

      // Chat
      RouteConfig.chat: (context) => const ChatScreen(),
      RouteConfig.chatList: (context) => const ChatListScreen(),

      // Profile
      RouteConfig.profile: (context) => const ProfileScreen(),
      RouteConfig.editProfile: (context) => const EditProfileScreen(),
      RouteConfig.address: (context) => const AddressScreen(),
      RouteConfig.addAddress: (context) => const AddAddressScreen(),
      RouteConfig.settings: (context) => const SettingsScreen(),
      RouteConfig.language: (context) => const LanguageScreen(),
      RouteConfig.changePassword: (context) => const ChangePasswordScreen(),
      RouteConfig.helpSupport: (context) => const HelpSupportScreen(),
      RouteConfig.privacyPolicy: (context) => const PrivacyPolicyScreen(),
      RouteConfig.termsConditions: (context) => const TermsConditionsScreen(),
    };
  }

  Route<dynamic> _onUnknownRoute(
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) {
        return const Scaffold(
          body: Center(
            child: Text(
              'Page not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingDialog() {
    return const RatingDialog();
  }
}