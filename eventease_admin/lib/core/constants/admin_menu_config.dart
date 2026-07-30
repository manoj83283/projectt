import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class AdminMenuConfig {
  AdminMenuConfig._();

  static List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'route': AppRoutes.dashboard,
    },
    {
      'title': 'Customers',
      'icon': Icons.people_outline,
      'route': AppRoutes.customers,
    },
    {
      'title': 'Providers',
      'icon': Icons.business_center_outlined,
      'route': AppRoutes.providers,
    },
    {
      'title': 'Categories',
      'icon': Icons.category_outlined,
      'route': AppRoutes.categories,
    },
    {
      'title': 'Services',
      'icon': Icons.miscellaneous_services_outlined,
      'route': AppRoutes.services,
    },
    {
      'title': 'Bookings',
      'icon': Icons.calendar_month_outlined,
      'route': AppRoutes.bookings,
    },
    {
      'title': 'Orders',
      'icon': Icons.shopping_bag_outlined,
      'route': AppRoutes.orders,
    },
    {
      'title': 'Payments',
      'icon': Icons.payments_outlined,
      'route': AppRoutes.payments,
    },
    {
      'title': 'Settlements',
      'icon': Icons.account_balance_wallet_outlined,
      'route': AppRoutes.settlements,
    },
    {
      'title': 'Coupons',
      'icon': Icons.discount_outlined,
      'route': AppRoutes.coupons,
    },
    {
      'title': 'Banners',
      'icon': Icons.image_outlined,
      'route': AppRoutes.banners,
    },
    {
      'title': 'Reviews',
      'icon': Icons.star_outline,
      'route': AppRoutes.reviews,
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications_outlined,
      'route': AppRoutes.notifications,
    },
    {
      'title': 'Support',
      'icon': Icons.support_agent_outlined,
      'route': AppRoutes.supportTickets,
    },
    {
      'title': 'KYC',
      'icon': Icons.verified_user_outlined,
      'route': AppRoutes.kycRequests,
    },
    {
      'title': 'Reports',
      'icon': Icons.assessment_outlined,
      'route': AppRoutes.reports,
    },
    {
      'title': 'Analytics',
      'icon': Icons.analytics_outlined,
      'route': AppRoutes.analytics,
    },
    {
      'title': 'Admins',
      'icon': Icons.admin_panel_settings_outlined,
      'route': AppRoutes.admins,
    },
    {
      'title': 'Settings',
      'icon': Icons.settings_outlined,
      'route': AppRoutes.settings,
    },
  ];
}