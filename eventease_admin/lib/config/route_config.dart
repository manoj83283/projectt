import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../routes/route_generator.dart';
import '../routes/navigation_service.dart';

class RouteConfig {
  RouteConfig._();

  // =====================================================
  // NAVIGATOR KEY
  // =====================================================

  static GlobalKey<NavigatorState> get navigatorKey =>
      NavigationService.navigatorKey;

  // =====================================================
  // INITIAL ROUTE
  // =====================================================

  static const String initialRoute =
      AppRoutes.login;

  // =====================================================
  // FALLBACK ROUTE
  // =====================================================

  static const String fallbackRoute =
      AppRoutes.notFound;
      
  static const String initialRoute =
      AppRoutes.splash;

  // =====================================================
  // AUTH ROUTES
  // =====================================================

  static const List<String> authRoutes = [
    AppRoutes.login,
    AppRoutes.forgotPassword,
    AppRoutes.otpVerification,
    AppRoutes.resetPassword,
  ];

  // =====================================================
  // PUBLIC ROUTES
  // =====================================================

  static const List<String> publicRoutes = [
    AppRoutes.login,
    AppRoutes.forgotPassword,
    AppRoutes.otpVerification,
    AppRoutes.resetPassword,
    AppRoutes.unauthorized,
    AppRoutes.notFound,
  ];

  // =====================================================
  // PROTECTED ROUTES
  // =====================================================

  static const List<String> protectedRoutes = [
    AppRoutes.dashboard,
    AppRoutes.customers,
    AppRoutes.customerDetails,
    AppRoutes.providers,
    AppRoutes.providerDetails,
    AppRoutes.providerKyc,
    AppRoutes.admins,
    AppRoutes.addAdmin,
    AppRoutes.editAdmin,
    AppRoutes.adminDetails,
    AppRoutes.categories,
    AppRoutes.addCategory,
    AppRoutes.editCategory,
    AppRoutes.categoryDetails,
    AppRoutes.services,
    AppRoutes.addService,
    AppRoutes.editService,
    AppRoutes.serviceDetails,
    AppRoutes.bookings,
    AppRoutes.bookingDetails,
    AppRoutes.orders,
    AppRoutes.orderDetails,
    AppRoutes.payments,
    AppRoutes.paymentDetails,
    AppRoutes.settlements,
    AppRoutes.settlementDetails,
    AppRoutes.coupons,
    AppRoutes.addCoupon,
    AppRoutes.editCoupon,
    AppRoutes.banners,
    AppRoutes.addBanner,
    AppRoutes.editBanner,
    AppRoutes.reviews,
    AppRoutes.reviewDetails,
    AppRoutes.notifications,
    AppRoutes.sendNotification,
    AppRoutes.supportTickets,
    AppRoutes.ticketDetails,
    AppRoutes.kycRequests,
    AppRoutes.kycDetails,
    AppRoutes.reports,
    AppRoutes.reportDetails,
    AppRoutes.analytics,
    AppRoutes.settings,
    AppRoutes.profile,
    AppRoutes.changePassword,
    AppRoutes.appSettings,
    AppRoutes.roles,
    AppRoutes.permissions,
    AppRoutes.activityLogs,
    AppRoutes.auditLogs,
  ];

  // =====================================================
  // ROUTE GENERATOR
  // =====================================================

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
  ) {
    return RouteGenerator.generateRoute(
      settings,
    );
  }

  // =====================================================
  // UNKNOWN ROUTE
  // =====================================================

  static Route<dynamic> onUnknownRoute(
    RouteSettings settings,
  ) {
    return RouteGenerator.generateRoute(
      const RouteSettings(
        name: AppRoutes.notFound,
      ),
    );
  }

  // =====================================================
  // ROUTE CHECKS
  // =====================================================

  static bool isAuthRoute(
    String? route,
  ) {
    if (route == null) return false;

    return authRoutes.contains(route);
  }

  static bool isPublicRoute(
    String? route,
  ) {
    if (route == null) return false;

    return publicRoutes.contains(route);
  }

  static bool isProtectedRoute(
    String? route,
  ) {
    if (route == null) return false;

    return protectedRoutes.contains(route);
  }

  static bool isUnknownRoute(
    String? route,
  ) {
    if (route == null) return true;

    return !allRoutes.contains(route);
  }

  // =====================================================
  // ALL ROUTES
  // =====================================================

  static const List<String> allRoutes = [
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.forgotPassword,
    AppRoutes.otpVerification,
    AppRoutes.resetPassword,
    AppRoutes.dashboard,
    AppRoutes.customers,
    AppRoutes.customerDetails,
    AppRoutes.providers,
    AppRoutes.providerDetails,
    AppRoutes.providerKyc,
    AppRoutes.admins,
    AppRoutes.addAdmin,
    AppRoutes.editAdmin,
    AppRoutes.adminDetails,
    AppRoutes.categories,
    AppRoutes.addCategory,
    AppRoutes.editCategory,
    AppRoutes.categoryDetails,
    AppRoutes.services,
    AppRoutes.addService,
    AppRoutes.editService,
    AppRoutes.serviceDetails,
    AppRoutes.bookings,
    AppRoutes.bookingDetails,
    AppRoutes.orders,
    AppRoutes.orderDetails,
    AppRoutes.payments,
    AppRoutes.paymentDetails,
    AppRoutes.settlements,
    AppRoutes.settlementDetails,
    AppRoutes.coupons,
    AppRoutes.addCoupon,
    AppRoutes.editCoupon,
    AppRoutes.banners,
    AppRoutes.addBanner,
    AppRoutes.editBanner,
    AppRoutes.reviews,
    AppRoutes.reviewDetails,
    AppRoutes.notifications,
    AppRoutes.sendNotification,
    AppRoutes.supportTickets,
    AppRoutes.ticketDetails,
    AppRoutes.kycRequests,
    AppRoutes.kycDetails,
    AppRoutes.reports,
    AppRoutes.reportDetails,
    AppRoutes.analytics,
    AppRoutes.settings,
    AppRoutes.profile,
    AppRoutes.changePassword,
    AppRoutes.appSettings,
    AppRoutes.roles,
    AppRoutes.permissions,
    AppRoutes.activityLogs,
    AppRoutes.auditLogs,
    AppRoutes.unauthorized,
    AppRoutes.notFound,
  ];

  // =====================================================
  // ROUTE GROUPS
  // =====================================================

  static const List<String> dashboardRoutes = [
    AppRoutes.dashboard,
    AppRoutes.analytics,
    AppRoutes.reports,
  ];

  static const List<String> customerRoutes = [
    AppRoutes.customers,
    AppRoutes.customerDetails,
  ];

  static const List<String> providerRoutes = [
    AppRoutes.providers,
    AppRoutes.providerDetails,
    AppRoutes.providerKyc,
  ];

  static const List<String> adminRoutes = [
    AppRoutes.admins,
    AppRoutes.addAdmin,
    AppRoutes.editAdmin,
    AppRoutes.adminDetails,
    AppRoutes.roles,
    AppRoutes.permissions,
  ];

  static const List<String> categoryRoutes = [
    AppRoutes.categories,
    AppRoutes.addCategory,
    AppRoutes.editCategory,
    AppRoutes.categoryDetails,
  ];

  static const List<String> serviceRoutes = [
    AppRoutes.services,
    AppRoutes.addService,
    AppRoutes.editService,
    AppRoutes.serviceDetails,
  ];

  static const List<String> bookingRoutes = [
    AppRoutes.bookings,
    AppRoutes.bookingDetails,
  ];

  static const List<String> orderRoutes = [
    AppRoutes.orders,
    AppRoutes.orderDetails,
  ];

  static const List<String> paymentRoutes = [
    AppRoutes.payments,
    AppRoutes.paymentDetails,
    AppRoutes.settlements,
    AppRoutes.settlementDetails,
  ];

  static const List<String> marketingRoutes = [
    AppRoutes.coupons,
    AppRoutes.addCoupon,
    AppRoutes.editCoupon,
    AppRoutes.banners,
    AppRoutes.addBanner,
    AppRoutes.editBanner,
    AppRoutes.notifications,
    AppRoutes.sendNotification,
  ];

  static const List<String> supportRoutes = [
    AppRoutes.supportTickets,
    AppRoutes.ticketDetails,
  ];

  static const List<String> kycRoutes = [
    AppRoutes.kycRequests,
    AppRoutes.kycDetails,
  ];

  static const List<String> settingsRoutes = [
    AppRoutes.settings,
    AppRoutes.profile,
    AppRoutes.changePassword,
    AppRoutes.appSettings,
  ];

  static const List<String> logRoutes = [
    AppRoutes.activityLogs,
    AppRoutes.auditLogs,
  ];

  // =====================================================
  // ROUTE GROUP HELPERS
  // =====================================================

  static bool isDashboardRoute(
    String? route,
  ) {
    if (route == null) return false;

    return dashboardRoutes.contains(route);
  }

  static bool isCustomerRoute(
    String? route,
  ) {
    if (route == null) return false;

    return customerRoutes.contains(route);
  }

  static bool isProviderRoute(
    String? route,
  ) {
    if (route == null) return false;

    return providerRoutes.contains(route);
  }

  static bool isAdminRoute(
    String? route,
  ) {
    if (route == null) return false;

    return adminRoutes.contains(route);
  }

  static bool isCategoryRoute(
    String? route,
  ) {
    if (route == null) return false;

    return categoryRoutes.contains(route);
  }

  static bool isServiceRoute(
    String? route,
  ) {
    if (route == null) return false;

    return serviceRoutes.contains(route);
  }

  static bool isBookingRoute(
    String? route,
  ) {
    if (route == null) return false;

    return bookingRoutes.contains(route);
  }

  static bool isOrderRoute(
    String? route,
  ) {
    if (route == null) return false;

    return orderRoutes.contains(route);
  }

  static bool isPaymentRoute(
    String? route,
  ) {
    if (route == null) return false;

    return paymentRoutes.contains(route);
  }

  static bool isMarketingRoute(
    String? route,
  ) {
    if (route == null) return false;

    return marketingRoutes.contains(route);
  }

  static bool isSupportRoute(
    String? route,
  ) {
    if (route == null) return false;

    return supportRoutes.contains(route);
  }

  static bool isKycRoute(
    String? route,
  ) {
    if (route == null) return false;

    return kycRoutes.contains(route);
  }

  static bool isSettingsRoute(
    String? route,
  ) {
    if (route == null) return false;

    return settingsRoutes.contains(route);
  }

  static bool isLogRoute(
    String? route,
  ) {
    if (route == null) return false;

    return logRoutes.contains(route);
  }

  // =====================================================
  // MATERIAL APP CONFIG HELPERS
  // =====================================================

  static Map<String, WidgetBuilder> get staticRoutes {
    return const {};
  }

  static RouteSettings routeSettings({
    required String name,
    Object? arguments,
  }) {
    return RouteSettings(
      name: name,
      arguments: arguments,
    );
  }

  // =====================================================
  // NAVIGATION HELPERS
  // =====================================================

  static Future<dynamic>? push(
    String routeName, {
    Object? arguments,
  }) {
    return NavigationService.push(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic>? pushReplacement(
    String routeName, {
    Object? arguments,
  }) {
    return NavigationService.pushReplacement(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic>? pushAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    return NavigationService.pushAndRemoveUntil(
      routeName,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>(
    [T? result],
  ) {
    NavigationService.pop<T>(
      result,
    );
  }

  static bool canPop() {
    return NavigationService.canPop();
  }

  // =====================================================
  // DEFAULT REDIRECTS
  // =====================================================

  static Future<dynamic>? goToLogin() {
    return pushAndRemoveUntil(
      AppRoutes.login,
    );
  }

  static Future<dynamic>? goToDashboard() {
    return pushAndRemoveUntil(
      AppRoutes.dashboard,
    );
  }

  static Future<dynamic>? goToUnauthorized() {
    return push(
      AppRoutes.unauthorized,
    );
  }

  static Future<dynamic>? goToNotFound() {
    return push(
      AppRoutes.notFound,
    );
  }

  // =====================================================
  // MODULE NAVIGATION HELPERS
  // =====================================================

  static Future<dynamic>? goToCustomerDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.customerDetails,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToProviderDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.providerDetails,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToProviderKyc({
    required Object arguments,
  }) {
    return push(
      AppRoutes.providerKyc,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToBookingDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.bookingDetails,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToOrderDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.orderDetails,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToPaymentDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.paymentDetails,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToSettlementDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.settlementDetails,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToReviewDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.reviewDetails,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToTicketDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.ticketDetails,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToKycDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.kycDetails,
      arguments: arguments,
    );
  }

  static Future<dynamic>? goToReportDetails({
    required Object arguments,
  }) {
    return push(
      AppRoutes.reportDetails,
      arguments: arguments,
    );
  }

  // =====================================================
  // ROUTE TITLE HELPER
  // =====================================================

  static String getRouteTitle(
    String? route,
  ) {
    switch (route) {
      case AppRoutes.login:
        return 'Login';

      case AppRoutes.dashboard:
        return 'Dashboard';

      case AppRoutes.customers:
        return 'Customers';

      case AppRoutes.customerDetails:
        return 'Customer Details';

      case AppRoutes.providers:
        return 'Providers';

      case AppRoutes.providerDetails:
        return 'Provider Details';

      case AppRoutes.providerKyc:
        return 'Provider KYC';

      case AppRoutes.admins:
        return 'Admins';

      case AppRoutes.categories:
        return 'Categories';

      case AppRoutes.services:
        return 'Services';

      case AppRoutes.bookings:
        return 'Bookings';

      case AppRoutes.bookingDetails:
        return 'Booking Details';

      case AppRoutes.orders:
        return 'Orders';

      case AppRoutes.orderDetails:
        return 'Order Details';

      case AppRoutes.payments:
        return 'Payments';

      case AppRoutes.settlements:
        return 'Settlements';

      case AppRoutes.coupons:
        return 'Coupons';

      case AppRoutes.banners:
        return 'Banners';

      case AppRoutes.reviews:
        return 'Reviews';

      case AppRoutes.notifications:
        return 'Notifications';

      case AppRoutes.supportTickets:
        return 'Support Tickets';

      case AppRoutes.kycRequests:
        return 'KYC Requests';

      case AppRoutes.reports:
        return 'Reports';

      case AppRoutes.analytics:
        return 'Analytics';

      case AppRoutes.settings:
        return 'Settings';

      case AppRoutes.profile:
        return 'Profile';

      case AppRoutes.roles:
        return 'Roles';

      case AppRoutes.permissions:
        return 'Permissions';

      case AppRoutes.activityLogs:
        return 'Activity Logs';

      case AppRoutes.auditLogs:
        return 'Audit Logs';

      case AppRoutes.unauthorized:
        return 'Unauthorized';

      case AppRoutes.notFound:
        return 'Page Not Found';

      default:
        return 'EventEase Admin';
    }
  }

  // =====================================================
  // CONFIG SUMMARY
  // =====================================================

  static Map<String, dynamic> summary() {
    return {
      'initialRoute': initialRoute,
      'fallbackRoute': fallbackRoute,
      'totalRoutes': allRoutes.length,
      'authRoutes': authRoutes.length,
      'publicRoutes': publicRoutes.length,
      'protectedRoutes': protectedRoutes.length,
    };
  }
}