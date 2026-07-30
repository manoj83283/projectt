import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static const FlutterSecureStorage _secureStorage =
      FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // =========================
  // KEYS
  // =========================

  static const String _accessTokenKey =
      'access_token';

  static const String _refreshTokenKey =
      'refresh_token';

  static const String _userKey =
      'user_data';

  static const String _languageKey =
      'language';

  static const String _themeKey =
      'theme_mode';

  static const String _isLoggedInKey =
      'is_logged_in';

  // =========================
  // ACCESS TOKEN
  // =========================

  static Future<void> saveAccessToken(
    String token,
  ) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  static Future<String?> getAccessToken()
  async {
    return await _secureStorage.read(
      key: _accessTokenKey,
    );
  }

  static Future<void> deleteAccessToken()
  async {
    await _secureStorage.delete(
      key: _accessTokenKey,
    );
  }

  // =========================
  // REFRESH TOKEN
  // =========================

  static Future<void> saveRefreshToken(
    String token,
  ) async {
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: token,
    );
  }

  static Future<String?> getRefreshToken()
  async {
    return await _secureStorage.read(
      key: _refreshTokenKey,
    );
  }

  static Future<void> deleteRefreshToken()
  async {
    await _secureStorage.delete(
      key: _refreshTokenKey,
    );
  }

  // =========================
  // USER DATA
  // =========================

  static Future<void> saveUserData(
    Map<String, dynamic> user,
  ) async {
    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(user),
    );
  }

  static Future<Map<String, dynamic>?>
      getUserData() async {
    final data =
        await _secureStorage.read(
      key: _userKey,
    );

    if (data == null) {
      return null;
    }

    return jsonDecode(data)
        as Map<String, dynamic>;
  }

  static Future<void> deleteUserData()
  async {
    await _secureStorage.delete(
      key: _userKey,
    );
  }

  // =========================
  // LOGIN STATE
  // =========================

  static Future<void> setLoggedIn(
    bool value,
  ) async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setBool(
      _isLoggedInKey,
      value,
    );
  }

  static Future<bool> isLoggedIn()
  async {
    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getBool(
          _isLoggedInKey,
        ) ??
        false;
  }

  // =========================
  // LANGUAGE
  // =========================

  static Future<void> saveLanguage(
    String languageCode,
  ) async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setString(
      _languageKey,
      languageCode,
    );
  }

  static Future<String> getLanguage()
  async {
    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getString(
          _languageKey,
        ) ??
        'en';
  }

  // =========================
  // THEME
  // =========================

  static Future<void> saveThemeMode(
    bool isDarkMode,
  ) async {
    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setBool(
      _themeKey,
      isDarkMode,
    );
  }

  static Future<bool> getThemeMode()
  async {
    final prefs =
        await SharedPreferences
            .getInstance();

    return prefs.getBool(
          _themeKey,
        ) ??
        false;
  }

  // =========================
  // CLEAR SESSION
  // =========================

  static Future<void> clearSession()
  async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteUserData();

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setBool(
      _isLoggedInKey,
      false,
    );
  }

  // =========================
  // LOGOUT
  // =========================

  static Future<void> logout() async {
    await clearSession();
  }

  // =========================
  // CLEAR ALL
  // =========================

  static Future<void> clearAll()
  async {
    await _secureStorage.deleteAll();

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.clear();
  }
}