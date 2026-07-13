import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_constants.dart';

class StorageHelper {
  StorageHelper._();

  static SharedPreferences? _prefs;

  // =====================================================
  // INITIALIZE
  // =====================================================

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'StorageHelper not initialized. Call StorageHelper.init() in main().',
      );
    }
    return _prefs!;
  }

  // =====================================================
  // TOKEN
  // =====================================================

  static Future<bool> saveAccessToken(
    String token,
  ) async {
    return prefs.setString(
      AppConstants.accessTokenKey,
      token,
    );
  }

  static String? getAccessToken() {
    return prefs.getString(
      AppConstants.accessTokenKey,
    );
  }

  static Future<bool> removeAccessToken() async {
    return prefs.remove(
      AppConstants.accessTokenKey,
    );
  }

  // =====================================================
  // REFRESH TOKEN
  // =====================================================

  static Future<bool> saveRefreshToken(
    String token,
  ) async {
    return prefs.setString(
      AppConstants.refreshTokenKey,
      token,
    );
  }

  static String? getRefreshToken() {
    return prefs.getString(
      AppConstants.refreshTokenKey,
    );
  }

  static Future<bool> removeRefreshToken() async {
    return prefs.remove(
      AppConstants.refreshTokenKey,
    );
  }

  // =====================================================
  // USER DATA
  // =====================================================

  static Future<bool> saveUser(
    Map<String, dynamic> user,
  ) async {
    return prefs.setString(
      AppConstants.userKey,
      jsonEncode(user),
    );
  }

  static Map<String, dynamic>? getUser() {
    final data = prefs.getString(
      AppConstants.userKey,
    );

    if (data == null) return null;

    return jsonDecode(data);
  }

  static Future<bool> removeUser() async {
    return prefs.remove(
      AppConstants.userKey,
    );
  }

  // =====================================================
  // LANGUAGE
  // =====================================================

  static Future<bool> saveLanguage(
    String languageCode,
  ) async {
    return prefs.setString(
      AppConstants.languageKey,
      languageCode,
    );
  }

  static String getLanguage() {
    return prefs.getString(
          AppConstants.languageKey,
        ) ??
        'en';
  }

  // =====================================================
  // THEME
  // =====================================================

  static Future<bool> saveDarkMode(
    bool isDark,
  ) async {
    return prefs.setBool(
      AppConstants.themeKey,
      isDark,
    );
  }

  static bool isDarkMode() {
    return prefs.getBool(
          AppConstants.themeKey,
        ) ??
        false;
  }

  // =====================================================
  // ONBOARDING
  // =====================================================

  static Future<bool> setOnboardingCompleted() async {
    return prefs.setBool(
      AppConstants.onboardingKey,
      true,
    );
  }

  static bool isOnboardingCompleted() {
    return prefs.getBool(
          AppConstants.onboardingKey,
        ) ??
        false;
  }

  // =====================================================
  // LOCATION
  // =====================================================

  static Future<bool> saveLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final data = {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };

    return prefs.setString(
      AppConstants.locationKey,
      jsonEncode(data),
    );
  }

  static Map<String, dynamic>? getLocation() {
    final data = prefs.getString(
      AppConstants.locationKey,
    );

    if (data == null) return null;

    return jsonDecode(data);
  }

  // =====================================================
  // CART
  // =====================================================

  static Future<bool> saveCart(
    List<Map<String, dynamic>> items,
  ) async {
    return prefs.setString(
      AppConstants.cartKey,
      jsonEncode(items),
    );
  }

  static List<dynamic> getCart() {
    final data = prefs.getString(
      AppConstants.cartKey,
    );

    if (data == null) {
      return [];
    }

    return jsonDecode(data);
  }

  static Future<bool> clearCart() async {
    return prefs.remove(
      AppConstants.cartKey,
    );
  }

  // =====================================================
  // GENERIC STRING
  // =====================================================

  static Future<bool> setString(
    String key,
    String value,
  ) async {
    return prefs.setString(key, value);
  }

  static String? getString(
    String key,
  ) {
    return prefs.getString(key);
  }

  // =====================================================
  // GENERIC BOOL
  // =====================================================

  static Future<bool> setBool(
    String key,
    bool value,
  ) async {
    return prefs.setBool(key, value);
  }

  static bool getBool(
    String key, {
    bool defaultValue = false,
  }) {
    return prefs.getBool(key) ?? defaultValue;
  }

  // =====================================================
  // GENERIC INT
  // =====================================================

  static Future<bool> setInt(
    String key,
    int value,
  ) async {
    return prefs.setInt(key, value);
  }

  static int getInt(
    String key, {
    int defaultValue = 0,
  }) {
    return prefs.getInt(key) ?? defaultValue;
  }

  // =====================================================
  // REMOVE KEY
  // =====================================================

  static Future<bool> remove(
    String key,
  ) async {
    return prefs.remove(key);
  }

  // =====================================================
  // CLEAR ALL
  // =====================================================

  static Future<bool> clearAll() async {
    return prefs.clear();
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  static Future<void> logout() async {
    await removeAccessToken();
    await removeRefreshToken();
    await removeUser();
    await clearCart();
  }

  // =====================================================
  // IS LOGGED IN
  // =====================================================

  static bool isLoggedIn() {
    final token = getAccessToken();

    return token != null &&
        token.isNotEmpty;
  }
}