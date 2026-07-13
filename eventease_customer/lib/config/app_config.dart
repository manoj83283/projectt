import 'package:flutter/material.dart';

class AppConfig {
  AppConfig._();

  // ==========================================
  // APP INFO
  // ==========================================

  static const String appName = 'EventEase';

  static const String appVersion = '1.0.0';

  static const String companyName =
      'EventEase Technologies';

  // ==========================================
  // PAGINATION
  // ==========================================

  static const int pageSize = 10;

  static const int servicePageSize = 20;

  static const int bookingPageSize = 20;

  // ==========================================
  // MAP
  // ==========================================

  static const double defaultLatitude =
      17.385044;

  static const double defaultLongitude =
      78.486671;

  static const double defaultZoom = 14;

  // Hyderabad Default Location

  // ==========================================
  // SUPPORT
  // ==========================================

  static const String supportEmail =
      'support@eventease.com';

  static const String supportPhone =
      '+91 9876543210';

  // ==========================================
  // PAYMENT
  // ==========================================

  static const String razorpayKey =
      'YOUR_RAZORPAY_KEY';

  // ==========================================
  // STORAGE KEYS
  // ==========================================

  static const String tokenKey =
      'auth_token';

  static const String userKey =
      'user_data';

  static const String languageKey =
      'selected_language';

  static const String themeKey =
      'selected_theme';

  // ==========================================
  // ORDER STATUS
  // ==========================================

  static const String pending =
      'pending';

  static const String accepted =
      'accepted';

  static const String rejected =
      'rejected';

  static const String processing =
      'processing';

  static const String completed =
      'completed';

  static const String cancelled =
      'cancelled';

  // ==========================================
  // BOOKING STATUS
  // ==========================================

  static const String bookingPending =
      'pending';

  static const String bookingConfirmed =
      'confirmed';

  static const String bookingCompleted =
      'completed';

  static const String bookingCancelled =
      'cancelled';

  // ==========================================
  // USER ROLES
  // ==========================================

  static const String customerRole =
      'user';

  static const String providerRole =
      'provider';

  static const String adminRole =
      'admin';

  // ==========================================
  // CATEGORY TYPES
  // ==========================================

  static const List<String> categoryTypes = [
    'venue',
    'professional',
    'service',
    'product',
  ];

  // ==========================================
  // SUPPORTED LANGUAGES
  // ==========================================

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('te'),
    Locale('ta'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('bn'),
  ];

  // ==========================================
  // EVENT CATEGORIES
  // ==========================================

  static const List<String> eventCategories = [
    'Convention Hall',
    'Resort',
    'Hotel',
    'Photographer',
    'Videographer',
    'Makeup Artist',
    'Catering',
    'Decoration',
    'DJ',
    'Event Planner',
  ];

  // ==========================================
  // MARKETPLACE CATEGORIES
  // ==========================================

  static const List<String> productCategories = [
    'Vegetables',
    'Rice',
    'Chicken',
    'Goat',
    'Sheep',
    'Dairy Products',
  ];

  // ==========================================
  // NOTIFICATION TYPES
  // ==========================================

  static const List<String> notificationTypes = [
    'booking',
    'order',
    'payment',
    'review',
    'chat',
    'promotion',
    'system',
  ];

  // ==========================================
  // DATE FORMATS
  // ==========================================

  static const String dateFormat =
      'dd-MM-yyyy';

  static const String dateTimeFormat =
      'dd-MM-yyyy HH:mm';

  // ==========================================
  // ANIMATION DURATION
  // ==========================================

  static const Duration splashDuration =
      Duration(seconds: 3);

  static const Duration animationDuration =
      Duration(milliseconds: 300);
}