import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  StorageHelper._();

  static late SharedPreferences _prefs;

  // ==========================================
  // INIT
  // ==========================================

  static Future<void> init() async {
    _prefs =
        await SharedPreferences.getInstance();
  }

  // ==========================================
  // STRING
  // ==========================================

  static Future<bool> setString(
    String key,
    String value,
  ) async {
    return await _prefs.setString(
      key,
      value,
    );
  }

  static String? getString(
    String key,
  ) {
    return _prefs.getString(key);
  }

  // ==========================================
  // INT
  // ==========================================

  static Future<bool> setInt(
    String key,
    int value,
  ) async {
    return await _prefs.setInt(
      key,
      value,
    );
  }

  static int? getInt(
    String key,
  ) {
    return _prefs.getInt(key);
  }

  // ==========================================
  // DOUBLE
  // ==========================================

  static Future<bool> setDouble(
    String key,
    double value,
  ) async {
    return await _prefs.setDouble(
      key,
      value,
    );
  }

  static double? getDouble(
    String key,
  ) {
    return _prefs.getDouble(key);
  }

  // ==========================================
  // BOOL
  // ==========================================

  static Future<bool> setBool(
    String key,
    bool value,
  ) async {
    return await _prefs.setBool(
      key,
      value,
    );
  }

  static bool getBool(
    String key, {
    bool defaultValue = false,
  }) {
    return _prefs.getBool(key) ??
        defaultValue;
  }

  // ==========================================
  // STRING LIST
  // ==========================================

  static Future<bool> setStringList(
    String key,
    List<String> value,
  ) async {
    return await _prefs.setStringList(
      key,
      value,
    );
  }

  static List<String> getStringList(
    String key,
  ) {
    return _prefs.getStringList(key) ?? [];
  }

  // ==========================================
  // OBJECT
  // ==========================================

  static Future<bool> setObject(
    String key,
    Map<String, dynamic> value,
  ) async {
    return await _prefs.setString(
      key,
      jsonEncode(value),
    );
  }

  static Map<String, dynamic>?
      getObject(
    String key,
  ) {
    final data =
        _prefs.getString(key);

    if (data == null) {
      return null;
    }

    return jsonDecode(data);
  }

  // ==========================================
  // TOKEN
  // ==========================================

  static const String _tokenKey =
      'access_token';

  static Future<bool> saveToken(
    String token,
  ) async {
    return await _prefs.setString(
      _tokenKey,
      token,
    );
  }

  static String? getToken() {
    return _prefs.getString(
      _tokenKey,
    );
  }

  static Future<bool> removeToken()
      async {
    return await _prefs.remove(
      _tokenKey,
    );
  }

  // ==========================================
  // USER
  // ==========================================

  static const String _userKey =
      'user_data';

  static Future<bool> saveUser(
    Map<String, dynamic> user,
  ) async {
    return await setObject(
      _userKey,
      user,
    );
  }

  static Map<String, dynamic>?
      getUser() {
    return getObject(_userKey);
  }

  static Future<bool> removeUser()
      async {
    return await _prefs.remove(
      _userKey,
    );
  }

  // ==========================================
  // LOGIN STATUS
  // ==========================================

  static const String _loginKey =
      'is_logged_in';

  static Future<bool> setLoggedIn(
    bool value,
  ) async {
    return await _prefs.setBool(
      _loginKey,
      value,
    );
  }

  static bool isLoggedIn() {
    return _prefs.getBool(
          _loginKey,
        ) ??
        false;
  }

  // ==========================================
  // LANGUAGE
  // ==========================================

  static const String _languageKey =
      'language';

  static Future<bool> saveLanguage(
    String language,
  ) async {
    return await _prefs.setString(
      _languageKey,
      language,
    );
  }

  static String getLanguage() {
    return _prefs.getString(
          _languageKey,
        ) ??
        'en';
  }

  // ==========================================
  // THEME
  // ==========================================

  static const String _themeKey =
      'theme_mode';

  static Future<bool> saveTheme(
    String theme,
  ) async {
    return await _prefs.setString(
      _themeKey,
      theme,
    );
  }

  static String getTheme() {
    return _prefs.getString(
          _themeKey,
        ) ??
        'light';
  }

  // ==========================================
  // REMOVE KEY
  // ==========================================

  static Future<bool> remove(
    String key,
  ) async {
    return await _prefs.remove(key);
  }

  // ==========================================
  // CLEAR ALL
  // ==========================================

  static Future<bool> clear() async {
    return await _prefs.clear();
  }
}