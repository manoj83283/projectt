import 'package:flutter/material.dart';

class AppConfig {
  AppConfig._();

  // ==========================================
  // APP INFO
  // ==========================================

  static const String appName = 'EventEase';

  static const String appTagLine =
      'Book Events, Services & Marketplace Products';

  static const String appVersion = '1.0.0';

  static const String companyName =
      'EventEase Technologies';

  // ==========================================
  // API CONFIGURATION
  // ==========================================

  static const String baseUrl =
      'https://api.eventease.com/api';

  static const String developmentUrl =
      'http://localhost:5000/api';

  static const String stagingUrl =
      'https://staging.eventease.com/api';

  static const String productionUrl =
      'https://api.eventease.com/api';

  static const int apiTimeoutSeconds =
      30;

  // ==========================================
  // PAGINATION
  // ==========================================

  static const int pageSize = 10;

  static const int servicePageSize =
      20;

  static const int bookingPageSize =
      20;

  static const int orderPageSize = 20;

  static const int reviewPageSize = 20;

  // ==========================================
  // MAP
  // ==========================================

  static const double defaultLatitude =
      17.385044;

  static const double defaultLongitude =
      78.486671;

  static const double defaultZoom = 14;

  // ==========================================
  // SUPPORT
  // ==========================================

  static const String supportEmail =
      'support@eventease.com';

  static const String supportPhone =
      '+91 9876543210';

  static const String supportWhatsApp =
      '+91 9876543210';

  // ==========================================
  // PAYMENT
  // ==========================================

  static const String razorpayKey =
      'YOUR_RAZORPAY_KEY';

  static const String currencyCode = 'INR';

  static const String currencySymbol =
      '₹';

  static const double minimumWalletAmount =
      100;

  static const double maximumWalletAmount =
      100000;

  // ==========================================
  // OTP CONFIGURATION
  // ==========================================

  static const int otpLength = 6;

  static const int otpExpiryMinutes =
      5;

  static const int resendOtpSeconds =
      30;

  // ==========================================
  // STORAGE KEYS
  // ==========================================

  static const String tokenKey =
      'auth_token';

  static const String refreshTokenKey =
      'refresh_token';

  static const String userKey =
      'user_data';

  static const String languageKey =
      'selected_language';

  static const String themeKey =
      'selected_theme';

  static const String onboardingKey =
      'onboarding_completed';

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

  static const String bookingRescheduled =
      'rescheduled';

  // ==========================================
  // PAYMENT STATUS
  // ==========================================

  static const String paymentPending =
      'pending';

  static const String paymentSuccess =
      'success';

  static const String paymentFailed =
      'failed';

  static const String paymentRefunded =
      'refunded';

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

  static const List<String>
      categoryTypes = [
    'venue',
    'professional',
    'service',
    'product',
  ];

  // ==========================================
  // SUPPORTED LANGUAGES
  // ==========================================

  static const List<Locale>
      supportedLocales = [
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

  static const List<String>
      eventCategories = [
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

  static const List<String>
      productCategories = [
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

  static const List<String>
      notificationTypes = [
    'booking',
    'order',
    'payment',
    'review',
    'chat',
    'promotion',
    'system',
  ];

  static const List<String>
      notificationChannels = [
    'push',
    'email',
    'sms',
    'whatsapp',
    'in_app',
  ];

  // ==========================================
  // IMAGE CONFIGURATION
  // ==========================================

  static const int maxImageCount = 10;

  static const int maxImageSizeMB =
      5;

  static const String defaultProfileImage =
      'assets/images/profile.png';

  static const String defaultBannerImage =
      'assets/images/banner.png';

  // ==========================================
  // REVIEW SETTINGS
  // ==========================================

  static const double minimumRating =
      1.0;

  static const double maximumRating =
      5.0;

  // ==========================================
  // BOOKING SETTINGS
  // ==========================================

  static const int minimumAdvanceBookingDays =
      0;

  static const int maximumAdvanceBookingDays =
      365;

  // ==========================================
  // DATE FORMATS
  // ==========================================

  static const String dateFormat =
      'dd-MM-yyyy';

  static const String dateTimeFormat =
      'dd-MM-yyyy HH:mm';

  static const String timeFormat =
      'HH:mm';

  // ==========================================
  // ANIMATION DURATION
  // ==========================================

  static const Duration splashDuration =
      Duration(seconds: 3);

  static const Duration animationDuration =
      Duration(milliseconds: 300);

  static const Duration pageTransitionDuration =
      Duration(milliseconds: 250);
}