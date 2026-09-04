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
import 'screens/booking/my_bookings_screen.dart'
    as booking_screens;
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

import 'screens/orders/my_orders_screen.dart'
    as order_screens;
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

import 'services/api_service.dart';
import 'services/auth_service.dart';

// =====================================================
// APPLICATION ENTRY POINT
// =====================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize the existing application storage.
    await StorageHelper.init();

    debugPrint(
      'APPLICATION STORAGE INITIALIZED',
    );
  } catch (error, stackTrace) {
    debugPrint(
      'APPLICATION STORAGE INITIALIZATION ERROR: $error',
    );

    debugPrint(
      'STORAGE STACK TRACE: $stackTrace',
    );
  }

  bool sessionRestored = false;

  try {
    /*
     * Restore the saved customer JWT before runApp().
     *
     * This ensures the Authorization header is available
     * before protected requests are made.
     */
    sessionRestored =
        await AuthService.instance.restoreSession();

    debugPrint(
      'APPLICATION SESSION RESTORED: $sessionRestored',
    );

    debugPrint(
      'APPLICATION CUSTOMER TOKEN AVAILABLE: '
      '${AuthService.instance.hasToken}',
    );

    debugPrint(
      'APPLICATION API AUTH HEADER AVAILABLE: '
      '${ApiService.instance.hasAuthToken}',
    );
  } catch (error, stackTrace) {
    /*
     * A restoration failure should not prevent the
     * application from starting.
     */
    debugPrint(
      'APPLICATION SESSION RESTORE ERROR: $error',
    );

    debugPrint(
      'SESSION RESTORE STACK TRACE: $stackTrace',
    );
  }

  runApp(
    const EventEaseApp(),
  );
}

// =====================================================
// ROOT APPLICATION
// =====================================================

class EventEaseApp extends StatelessWidget {
  const EventEaseApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        // =================================================
        // AUTHENTICATION
        // =================================================

        ChangeNotifierProvider<AuthProvider>(
          create: (
            BuildContext context,
          ) {
            final AuthProvider authProvider =
                AuthProvider();

            /*
             * AuthService restores the actual token before
             * runApp().
             *
             * AuthProvider must separately synchronize its
             * isLoggedIn and user state.
             *
             * Without this call, AuthProvider starts with
             * isLoggedIn=false even when a saved JWT exists.
             */
            authProvider.checkAuth();

            return authProvider;
          },
        ),

        // =================================================
        // SERVICES
        // =================================================

        ChangeNotifierProvider<ServiceProvider>(
          create: (
            BuildContext context,
          ) {
            return ServiceProvider();
          },
        ),

        // =================================================
        // CATEGORIES
        // =================================================

        ChangeNotifierProvider<CategoryProvider>(
          create: (
            BuildContext context,
          ) {
            return CategoryProvider();
          },
        ),

        // =================================================
        // CART
        // =================================================

        ChangeNotifierProvider<CartProvider>(
          create: (
            BuildContext context,
          ) {
            return CartProvider();
          },
        ),

        // =================================================
        // BOOKINGS
        // =================================================

        ChangeNotifierProvider<BookingProvider>(
          create: (
            BuildContext context,
          ) {
            return BookingProvider();
          },
        ),

        // =================================================
        // ORDERS
        // =================================================

        ChangeNotifierProvider<OrderProvider>(
          create: (
            BuildContext context,
          ) {
            return OrderProvider();
          },
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
          BuildContext context,
          Widget? child,
        ) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConfig.appName,
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: ThemeMode.system,

            /*
             * These locales must also exist in
             * AppConfig.supportedLocales.
             */
            supportedLocales:
                AppConfig.supportedLocales,

            initialRoute: RouteConfig.splash,
            routes: _routes,
            onUnknownRoute: _onUnknownRoute,
          );
        },
      ),
    );
  }

  // =====================================================
  // APPLICATION ROUTES
  // =====================================================

  Map<String, WidgetBuilder> get _routes {
    return <String, WidgetBuilder>{
      // =================================================
      // SPLASH
      // =================================================

      RouteConfig.splash: (
        BuildContext context,
      ) {
        return const SplashScreen();
      },

      // =================================================
      // AUTHENTICATION
      // =================================================

      RouteConfig.login: (
        BuildContext context,
      ) {
        return const LoginScreen();
      },

      RouteConfig.signup: (
        BuildContext context,
      ) {
        return const SignupScreen();
      },

      RouteConfig.forgotPassword: (
        BuildContext context,
      ) {
        return const ForgotPasswordScreen();
      },

      RouteConfig.otp: (
        BuildContext context,
      ) {
        return const OtpScreen();
      },

      RouteConfig.resetPassword: (
        BuildContext context,
      ) {
        return const ResetPasswordScreen();
      },

      // =================================================
      // HOME
      // =================================================

      RouteConfig.home: (
        BuildContext context,
      ) {
        return const HomeScreen();
      },

      RouteConfig.search: (
        BuildContext context,
      ) {
        return const SearchScreen();
      },

      RouteConfig.notifications: (
        BuildContext context,
      ) {
        return const NotificationsScreen();
      },

      RouteConfig.category: (
        BuildContext context,
      ) {
        return const CategoryScreen();
      },

      // =================================================
      // SERVICES
      // =================================================

      RouteConfig.serviceList: (
        BuildContext context,
      ) {
        return const ServiceListScreen();
      },

      RouteConfig.serviceDetails: (
        BuildContext context,
      ) {
        return const ServiceDetailScreen();
      },

      RouteConfig.providerProfile: (
        BuildContext context,
      ) {
        return const ProviderProfileScreen();
      },

      RouteConfig.serviceFilter: (
        BuildContext context,
      ) {
        return const ServiceFilterScreen();
      },

      RouteConfig.serviceGallery: (
        BuildContext context,
      ) {
        return const ServiceGalleryScreen();
      },

      // =================================================
      // BOOKINGS
      // =================================================

      RouteConfig.booking: (
        BuildContext context,
      ) {
        return const BookingScreen();
      },

      RouteConfig.myBookings: (
        BuildContext context,
      ) {
        return const booking_screens
            .MyBookingsScreen();
      },

      RouteConfig.bookingDetails: (
        BuildContext context,
      ) {
        return const BookingDetailsScreen();
      },

      RouteConfig.trackBooking: (
        BuildContext context,
      ) {
        return const TrackBookingScreen();
      },

      RouteConfig.orderSuccess: (
        BuildContext context,
      ) {
        return const OrderSuccessScreen();
      },

      // =================================================
      // CART AND CHECKOUT
      // =================================================

      RouteConfig.cart: (
        BuildContext context,
      ) {
        return const CartScreen();
      },

      RouteConfig.checkout: (
        BuildContext context,
      ) {
        return const CheckoutScreen();
      },

      // =================================================
      // ORDERS
      // =================================================

      RouteConfig.myOrders: (
        BuildContext context,
      ) {
        return const order_screens
            .MyOrdersScreen();
      },

      RouteConfig.orderDetails: (
        BuildContext context,
      ) {
        return const OrderDetailsScreen();
      },

      RouteConfig.trackOrder: (
        BuildContext context,
      ) {
        return const TrackOrderScreen();
      },

      // =================================================
      // REVIEWS
      // =================================================

      RouteConfig.reviews: (
        BuildContext context,
      ) {
        return const ReviewsScreen();
      },

      RouteConfig.ratingDialog: (
        BuildContext context,
      ) {
        return _buildRatingDialog();
      },

      // =================================================
      // CHAT
      // =================================================

      RouteConfig.chat: (
        BuildContext context,
      ) {
        return const ChatScreen();
      },

      RouteConfig.chatList: (
        BuildContext context,
      ) {
        return const ChatListScreen();
      },

      // =================================================
      // PROFILE
      // =================================================

      RouteConfig.profile: (
        BuildContext context,
      ) {
        return const ProfileScreen();
      },

      RouteConfig.editProfile: (
        BuildContext context,
      ) {
        return const EditProfileScreen();
      },

      RouteConfig.address: (
        BuildContext context,
      ) {
        return const AddressScreen();
      },

      RouteConfig.addAddress: (
        BuildContext context,
      ) {
        return const AddAddressScreen();
      },

      RouteConfig.settings: (
        BuildContext context,
      ) {
        return const SettingsScreen();
      },

      RouteConfig.language: (
        BuildContext context,
      ) {
        return const LanguageScreen();
      },

      RouteConfig.changePassword: (
        BuildContext context,
      ) {
        return const ChangePasswordScreen();
      },

      RouteConfig.helpSupport: (
        BuildContext context,
      ) {
        return const HelpSupportScreen();
      },

      RouteConfig.privacyPolicy: (
        BuildContext context,
      ) {
        return const PrivacyPolicyScreen();
      },

      RouteConfig.termsConditions: (
        BuildContext context,
      ) {
        return const TermsConditionsScreen();
      },
    };
  }

  // =====================================================
  // UNKNOWN ROUTE
  // =====================================================

  Route<dynamic> _onUnknownRoute(
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (
        BuildContext context,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Page Not Found',
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(
                24,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Page not found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    settings.name == null
                        ? 'The requested page is unavailable.'
                        : 'The route "${settings.name}" '
                            'is unavailable.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                        RouteConfig.home,
                        (
                          Route<dynamic> route,
                        ) {
                          return false;
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.home,
                    ),
                    label: const Text(
                      'Go to Home',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // RATING DIALOG ROUTE
  // =====================================================

  Widget _buildRatingDialog() {
    return const RatingDialog();
  }
}