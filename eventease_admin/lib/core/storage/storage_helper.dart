import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  StorageHelper._();

  static SharedPreferences? _prefs;

  // =====================================================
  // INIT
  // =====================================================

  static Future<void> init() async {
    _prefs ??=
        await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'StorageHelper not initialized. Call StorageHelper.init() before use.',
      );
    }

    return _prefs!;
  }

  // =====================================================
  // STRING
  // =====================================================

  static Future<bool> setString(
    String key,
    String value,
  ) async {
    return await prefs.setString(
      key,
      value,
    );
  }

  static String? getString(
    String key,
  ) {
    return prefs.getString(key);
  }

  // =====================================================
  // INT
  // =====================================================

  static Future<bool> setInt(
    String key,
    int value,
  ) async {
    return await prefs.setInt(
      key,
      value,
    );
  }

  static int? getInt(
    String key,
  ) {
    return prefs.getInt(key);
  }

  // =====================================================
  // DOUBLE
  // =====================================================

  static Future<bool> setDouble(
    String key,
    double value,
  ) async {
    return await prefs.setDouble(
      key,
      value,
    );
  }

  static double? getDouble(
    String key,
  ) {
    return prefs.getDouble(key);
  }

  // =====================================================
  // BOOL
  // =====================================================

  static Future<bool> setBool(
    String key,
    bool value,
  ) async {
    return await prefs.setBool(
      key,
      value,
    );
  }

  static bool getBool(
    String key, {
    bool defaultValue = false,
  }) {
    return prefs.getBool(key) ??
        defaultValue;
  }

  // =====================================================
  // STRING LIST
  // =====================================================

  static Future<bool> setStringList(
    String key,
    List<String> value,
  ) async {
    return await prefs.setStringList(
      key,
      value,
    );
  }

  static List<String> getStringList(
    String key,
  ) {
    return prefs.getStringList(key) ??
        [];
  }

  // =====================================================
  // JSON OBJECT
  // =====================================================

  static Future<bool> setJson(
    String key,
    Map<String, dynamic> value,
  ) async {
    return await prefs.setString(
      key,
      jsonEncode(value),
    );
  }

  static Map<String, dynamic>?
      getJson(
    String key,
  ) {
    final data =
        prefs.getString(key);

    if (data == null ||
        data.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(
      jsonDecode(data),
    );
  }

  // =====================================================
  // JSON LIST
  // =====================================================

  static Future<bool> setJsonList(
    String key,
    List<dynamic> value,
  ) async {
    return await prefs.setString(
      key,
      jsonEncode(value),
    );
  }

  static List<dynamic> getJsonList(
    String key,
  ) {
    final data =
        prefs.getString(key);

    if (data == null ||
        data.isEmpty) {
      return [];
    }

    return List<dynamic>.from(
      jsonDecode(data),
    );
  }

  // =====================================================
  // CONTAINS KEY
  // =====================================================

  static bool containsKey(
    String key,
  ) {
    return prefs.containsKey(key);
  }

  // =====================================================
  // REMOVE KEY
  // =====================================================

  static Future<bool> remove(
    String key,
  ) async {
    return await prefs.remove(key);
  }

  // =====================================================
  // CLEAR ALL
  // =====================================================

  static Future<bool> clear() async {
    return await prefs.clear();
  }

  // =====================================================
  // CLEAR SELECTED KEYS
  // =====================================================

  static Future<void> clearKeys(
    List<String> keys,
  ) async {
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // =====================================================
  // RELOAD
  // =====================================================

  static Future<void> reload() async {
    await prefs.reload();
  }

  // =====================================================
  // TOKEN HELPERS
  // =====================================================

  static Future<void> saveAccessToken(
    String token,
    String key,
  ) async {
    await setString(
      key,
      token,
    );
  }

  static String? getAccessToken(
    String key,
  ) {
    return getString(key);
  }

  // =====================================================
  // USER HELPERS
  // =====================================================

  static Future<void> saveUser(
    String key,
    Map<String, dynamic> user,
  ) async {
    await setJson(
      key,
      user,
    );
  }

  static Map<String, dynamic>?
      getUser(
    String key,
  ) {
    return getJson(key);
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  static Future<void> logout({
    required List<String>
        preserveKeys,
  }) async {
    final Map<String, dynamic>
        preserved = {};

    for (final key
        in preserveKeys) {
      preserved[key] =
          prefs.get(key);
    }

    await clear();

    for (final entry
        in preserved.entries) {
      final value = entry.value;

      if (value is String) {
        await setString(
          entry.key,
          value,
        );
      } else if (value is bool) {
        await setBool(
          entry.key,
          value,
        );
      } else if (value is int) {
        await setInt(
          entry.key,
          value,
        );
      } else if (value is double) {
        await setDouble(
          entry.key,
          value,
        );
      } else if (value
          is List<String>) {
        await setStringList(
          entry.key,
          value,
        );
      }
    }
  }
}