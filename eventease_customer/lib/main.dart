import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'core/storage/storage_helper.dart';
import '../config/app_config.dart';
import '../config/route_config.dart';
import '../config/theme_config.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/category_provider.dart';
import '../providers/order_provider.dart';
import '../providers/service_provider.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/booking/booking_details_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/my_bookings_screen.dart';
import '../screens/booking/my_orders_screen.dart';
import '../screens/booking/order_success_screen.dart';
import '../screens/booking/track_booking_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/cart/checkout_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/home/category_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/home/search_screen.dart';
import '../screens/orders/my_orders_screen.dart';
import '../screens/orders/order_details_screen.dart';
import '../screens/orders/track_order_screen.dart';
import '../screens/profile/add_address_screen.dart';
import '../screens/profile/address_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/help_support_screen.dart';
import '../screens/profile/language_screen.dart';
import '../screens/profile/privacy_policy_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/terms_conditions_screen.dart';
import '../screens/reviews/rating_dialog.dart';
import '../screens/reviews/reviews_screen.dart';
import '../screens/services/provider_profile_screen.dart';
import '../screens/services/service_detail_screen.dart';
import '../screens/services/service_filter_screen.dart';
import '../screens/services/service_gallery_screen.dart';
import '../screens/services/service_list_screen.dart';
import '../screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StorageHelper.init();

  runApp(
    const EventEaseApp(),
  );
}

class EventEaseApp extends StatelessWidget {
  const EventEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(),
        ),
        ChangeNotifierProvider(
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
            debugShowCheckedModeBanner:
                false,

            title: AppConfig.appName,

            theme:
                ThemeConfig.lightTheme,

            darkTheme:
                ThemeConfig.darkTheme,

            themeMode:
                ThemeMode.system,

            supportedLocales:
                AppConfig.supportedLocales,

            initialRoute:
                RouteConfig.splash,

            routes: {
              // Splash
              RouteConfig.splash:
                  (context) =>
                      const SplashScreen(),

              // Auth
              RouteConfig.login:
                  (context) =>
                      const LoginScreen(),

              RouteConfig.signup:
                  (context) =>
                      const SignupScreen(),

              RouteConfig
                      .forgotPassword:
                  (context) =>
                      const ForgotPasswordScreen(),
              
              RouteConfig.otp:
                  (context) =>
                      const OtpScreen(),
                      
              RouteConfig.resetPassword:
                  (context) =>
                      const ResetPasswordScreen(),

              // Home
              RouteConfig.home:
                  (context) =>
                      const HomeScreen(),

              RouteConfig.search:
                  (context) =>
                      const SearchScreen(),
                      
              RouteConfig.notifications:
                  (context) =>
                      const NotificationsScreen(),

              RouteConfig.category:
                  (context) =>
                      const CategoryScreen(),

              // Services
              RouteConfig.serviceList:
                  (context) =>
                      const ServiceListScreen(),

              RouteConfig
                      .serviceDetails:
                  (context) =>
                      const ServiceDetailScreen(),

              RouteConfig
                      .providerProfile:
                  (context) =>
                      const ProviderProfileScreen(),
                      
              RouteConfig
                      .ServiceFilter:
                  (context) =>
                      const ServiceFilterScreen(),
                      
              RouteConfig.serviceGallery:
                  (context) =>
                      const ServiceGalleryScreen(),

              // Booking
              RouteConfig.booking:
                  (context) =>
                      const BookingScreen(),

              RouteConfig.myOrders:
                  (context) =>
                      const MyOrdersScreen(),
                      
              RouteConfig.myBookings:
                  (context) =>
                      const MyBookingsScreen(),
                      
              RouteConfig.bookingDetails:
                  (context) =>
                      const BookingDetailsScreen(),
                      
              RouteConfig.trackBooking:
                  (context) =>
                      const TrackBookingScreen(),

              RouteConfig
                      .orderSuccess:
                  (context) =>
                      const OrderSuccessScreen(),

              // Cart
              RouteConfig.cart:
                  (context) =>
                      const CartScreen(),
                      
              RouteConfig.checkout:
                  (context) =>
                      const CheckoutScreen(),
              //order        
              RouteConfig.myOrders:
                  (context) =>
                      const MyOrdersScreen(),
                      
              RouteConfig.orderDetails:
                  (context) =>
                      const OrderDetailsScreen(),
                      
              RouteConfig.trackOrder:
                  (context) =>
                      const TrackOrderScreen(),
                      
              ///reviews
              RouteConfig.reviews:
                  (context) =>
                      const ReviewsScreen(),
                      
              RouteConfig.ratingDialog:
                  (context) =>
                      const rating_dialog(),

              // Chat
              RouteConfig.chat:
                  (context) =>
                      const ChatScreen(),
                      
              RouteConfig.chatList:
                  (context) =>
                      const ChatListScreen(),

              // Profile
              RouteConfig.profile:
                  (context) =>
                      const ProfileScreen(),
                      
              RouteConfig.editProfile:
                  (context) =>
                      const EditProfileScreen(),

              RouteConfig.address:
                  (context) =>
                      const AddressScreen(),
                      
              RouteConfig.addAddress:
                  (context) =>
                      const AddAddressScreen(),

              RouteConfig.settings:
                  (context) =>
                      const SettingsScreen(),
                      
              RouteConfig.language:
                  (context) =>
                      const LanguageScreen(),
                      
              RouteConfig.changePassword:
                  (context) =>
                      const ChangePasswordScreen(),
                      
              RouteConfig.helpSupport:
                  (context) =>
                      const HelpSupportScreen(),
                      
              RouteConfig.privacyPolicy:
                  (context) =>
                      const PrivacyPolicyScreen(),
                      
              RouteConfig.termsConditions:
                  (context) =>
                      const TermsConditionsScreen(),
            },
          );
        },
      ),
    );
  }
}