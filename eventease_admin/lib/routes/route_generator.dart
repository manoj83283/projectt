import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

// AUTH SCREENS
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/reset_password_screen.dart';

// DASHBOARD
import '../screens/dashboard/dashboard_screen.dart';

// CUSTOMERS
import '../screens/customers/customers_screen.dart';
import '../screens/customers/customer_details_screen.dart';

// PROVIDERS
import '../screens/providers/providers_screen.dart';
import '../screens/providers/provider_details_screen.dart';
import '../screens/providers/provider_kyc_screen.dart';

// ADMINS
import '../screens/admins/admins_screen.dart';
import '../screens/admins/add_admin_screen.dart';
import '../screens/admins/edit_admin_screen.dart';
import '../screens/admins/admin_details_screen.dart';

// CATEGORIES
import '../screens/categories/categories_screen.dart';
import '../screens/categories/add_category_screen.dart';
import '../screens/categories/edit_category_screen.dart';
import '../screens/categories/category_details_screen.dart';

// SERVICES
import '../screens/services/services_screen.dart';
import '../screens/services/add_service_screen.dart';
import '../screens/services/edit_service_screen.dart';
import '../screens/services/service_details_screen.dart';

// BOOKINGS
import '../screens/bookings/bookings_screen.dart';
import '../screens/bookings/booking_details_screen.dart';

// ORDERS
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_details_screen.dart';

// PAYMENTS
import '../screens/payments/payments_screen.dart';
import '../screens/payments/payment_details_screen.dart';

// SETTLEMENTS
import '../screens/settlements/settlements_screen.dart';
import '../screens/settlements/settlement_details_screen.dart';

// COUPONS
import '../screens/coupons/coupons_screen.dart';
import '../screens/coupons/add_coupon_screen.dart';
import '../screens/coupons/edit_coupon_screen.dart';

// BANNERS
import '../screens/banners/banners_screen.dart';
import '../screens/banners/add_banner_screen.dart';
import '../screens/banners/edit_banner_screen.dart';

// REVIEWS
import '../screens/reviews/reviews_screen.dart';
import '../screens/reviews/review_details_screen.dart';

// NOTIFICATIONS
import '../screens/notifications/notifications_screen.dart';
import '../screens/notifications/send_notification_screen.dart';

// SUPPORT
import '../screens/support/support_tickets_screen.dart';
import '../screens/support/ticket_details_screen.dart';

// KYC
import '../screens/kyc/kyc_requests_screen.dart';
import '../screens/kyc/kyc_details_screen.dart';

// REPORTS
import '../screens/reports/reports_screen.dart';
import '../screens/reports/report_details_screen.dart';

// ANALYTICS
import '../screens/analytics/analytics_screen.dart';

// SETTINGS
import '../screens/settings/settings_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/settings/change_password_screen.dart';
import '../screens/settings/app_settings_screen.dart';

// ROLES
import '../screens/roles/roles_screen.dart';
import '../screens/roles/permissions_screen.dart';

// LOGS
import '../screens/logs/activity_logs_screen.dart';
import '../screens/logs/audit_logs_screen.dart';
import '../screens/splash/splash_screen.dart';

// ERROR PAGES
import '../screens/error/not_found_screen.dart';
import '../screens/error/unauthorized_screen.dart';

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {

      // ==========================================
      // AUTH
      // ==========================================

      case AppRoutes.login:
        return _materialRoute(
          const LoginScreen(),
        );

      case AppRoutes.forgotPassword:
        return _materialRoute(
          const ForgotPasswordScreen(),
        );

      case AppRoutes.otpVerification:
        return _materialRoute(
          const OtpVerificationScreen(),
        );

      case AppRoutes.resetPassword:
        return _materialRoute(
          const ResetPasswordScreen(),
        );

      // ==========================================
      // DASHBOARD
      // ==========================================

      case AppRoutes.dashboard:
        return _materialRoute(
          const DashboardScreen(),
        );

      // ==========================================
      // CUSTOMERS
      // ==========================================

      case AppRoutes.customers:
        return _materialRoute(
          const CustomersScreen(),
        );

      case AppRoutes.customerDetails:
        return _materialRoute(
          const CustomerDetailsScreen(),
        );

      // ==========================================
      // PROVIDERS
      // ==========================================

      case AppRoutes.providers:
        return _materialRoute(
          const ProvidersScreen(),
        );

      case AppRoutes.providerDetails:
        return _materialRoute(
          const ProviderDetailsScreen(),
        );

      case AppRoutes.providerKyc:
        return _materialRoute(
          const ProviderKycScreen(),
        );

      // ==========================================
      // ADMINS
      // ==========================================

      case AppRoutes.admins:
        return _materialRoute(
          const AdminsScreen(),
        );

      case AppRoutes.addAdmin:
        return _materialRoute(
          const AddAdminScreen(),
        );

      case AppRoutes.editAdmin:
        return _materialRoute(
          const EditAdminScreen(),
        );

      case AppRoutes.adminDetails:
        return _materialRoute(
          const AdminDetailsScreen(),
        );

      // ==========================================
      // CATEGORIES
      // ==========================================

      case AppRoutes.categories:
        return _materialRoute(
          const CategoriesScreen(),
        );

      case AppRoutes.addCategory:
        return _materialRoute(
          const AddCategoryScreen(),
        );

      case AppRoutes.editCategory:
        return _materialRoute(
          const EditCategoryScreen(),
        );

      case AppRoutes.categoryDetails:
        return _materialRoute(
          const CategoryDetailsScreen(),
        );

      // ==========================================
      // SERVICES
      // ==========================================

      case AppRoutes.services:
        return _materialRoute(
          const ServicesScreen(),
        );

      case AppRoutes.addService:
        return _materialRoute(
          const AddServiceScreen(),
        );

      case AppRoutes.editService:
        return _materialRoute(
          const EditServiceScreen(),
        );

      case AppRoutes.serviceDetails:
        return _materialRoute(
          const ServiceDetailsScreen(),
        );

      // ==========================================
      // BOOKINGS
      // ==========================================

      case AppRoutes.bookings:
        return _materialRoute(
          const BookingsScreen(),
        );

      case AppRoutes.bookingDetails:
        return _materialRoute(
          const BookingDetailsScreen(),
        );

      // ==========================================
      // ORDERS
      // ==========================================

      case AppRoutes.orders:
        return _materialRoute(
          const OrdersScreen(),
        );

      case AppRoutes.orderDetails:
        return _materialRoute(
          const OrderDetailsScreen(),
        );

      // ==========================================
      // PAYMENTS
      // ==========================================

      case AppRoutes.payments:
        return _materialRoute(
          const PaymentsScreen(),
        );

      case AppRoutes.paymentDetails:
        return _materialRoute(
          const PaymentDetailsScreen(),
        );

      // ==========================================
      // SETTLEMENTS
      // ==========================================

      case AppRoutes.settlements:
        return _materialRoute(
          const SettlementsScreen(),
        );

      case AppRoutes.settlementDetails:
        return _materialRoute(
          const SettlementDetailsScreen(),
        );

      // ==========================================
      // COUPONS
      // ==========================================

      case AppRoutes.coupons:
        return _materialRoute(
          const CouponsScreen(),
        );

      case AppRoutes.addCoupon:
        return _materialRoute(
          const AddCouponScreen(),
        );

      case AppRoutes.editCoupon:
        return _materialRoute(
          const EditCouponScreen(),
        );

      // ==========================================
      // BANNERS
      // ==========================================

      case AppRoutes.banners:
        return _materialRoute(
          const BannersScreen(),
        );

      case AppRoutes.addBanner:
        return _materialRoute(
          const AddBannerScreen(),
        );

      case AppRoutes.editBanner:
        return _materialRoute(
          const EditBannerScreen(),
        );

      // ==========================================
      // REVIEWS
      // ==========================================

      case AppRoutes.reviews:
        return _materialRoute(
          const ReviewsScreen(),
        );

      case AppRoutes.reviewDetails:
        return _materialRoute(
          const ReviewDetailsScreen(),
        );

      // ==========================================
      // NOTIFICATIONS
      // ==========================================

      case AppRoutes.notifications:
        return _materialRoute(
          const NotificationsScreen(),
        );

      case AppRoutes.sendNotification:
        return _materialRoute(
          const SendNotificationScreen(),
        );

      // ==========================================
      // SUPPORT
      // ==========================================

      case AppRoutes.supportTickets:
        return _materialRoute(
          const SupportTicketsScreen(),
        );

      case AppRoutes.ticketDetails:
        return _materialRoute(
          const TicketDetailsScreen(),
        );

      // ==========================================
      // KYC
      // ==========================================

      case AppRoutes.kycRequests:
        return _materialRoute(
          const KycRequestsScreen(),
        );

      case AppRoutes.kycDetails:
        return _materialRoute(
          const KycDetailsScreen(),
        );

      // ==========================================
      // REPORTS
      // ==========================================

      case AppRoutes.reports:
        return _materialRoute(
          const ReportsScreen(),
        );

      case AppRoutes.reportDetails:
        return _materialRoute(
          const ReportDetailsScreen(),
        );
        
      case AppRoutes.splash:
        return _materialRoute(
          const SplashScreen(),
        );

      // ==========================================
      // ANALYTICS
      // ==========================================

      case AppRoutes.analytics:
        return _materialRoute(
          const AnalyticsScreen(),
        );

      // ==========================================
      // SETTINGS
      // ==========================================

      case AppRoutes.settings:
        return _materialRoute(
          const SettingsScreen(),
        );

      case AppRoutes.profile:
        return _materialRoute(
          const ProfileScreen(),
        );

      case AppRoutes.changePassword:
        return _materialRoute(
          const ChangePasswordScreen(),
        );

      case AppRoutes.appSettings:
        return _materialRoute(
          const AppSettingsScreen(),
        );

      // ==========================================
      // ROLES & PERMISSIONS
      // ==========================================

      case AppRoutes.roles:
        return _materialRoute(
          const RolesScreen(),
        );

      case AppRoutes.permissions:
        return _materialRoute(
          const PermissionsScreen(),
        );

      // ==========================================
      // LOGS
      // ==========================================

      case AppRoutes.activityLogs:
        return _materialRoute(
          const ActivityLogsScreen(),
        );

      case AppRoutes.auditLogs:
        return _materialRoute(
          const AuditLogsScreen(),
        );

      // ==========================================
      // ERROR
      // ==========================================

      case AppRoutes.unauthorized:
        return _materialRoute(
          const UnauthorizedScreen(),
        );

      case AppRoutes.notFound:
        return _materialRoute(
          const NotFoundScreen(),
        );

      default:
        return _materialRoute(
          const NotFoundScreen(),
        );
    }
  }

  static MaterialPageRoute _materialRoute(
    Widget child,
  ) {
    return MaterialPageRoute(
      builder: (_) => child,
    );
  }
}