import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const FlutterSecureStorage _secureStorage =
      FlutterSecureStorage();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'StorageHelper not initialized. Call StorageHelper.init() in main.dart',
      );
    }
    return _prefs!;
  }

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    final secureToken = await _secureStorage.read(key: 'token');
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }

    return prefs.getString('token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: 'refreshToken', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: 'refreshToken');
  }

  static Future<void> saveUserId(String userId) async {
    await prefs.setString('userId', userId);
  }

  static String? getUserId() {
    return prefs.getString('userId');
  }

  static Future<void> saveRole(String role) async {
    await prefs.setString('role', role);
  }

  static String? getRole() {
    return prefs.getString('role');
  }

  static Future<void> saveUserName(String name) async {
    await prefs.setString('userName', name);
  }

  static String? getUserName() {
    return prefs.getString('userName');
  }

  static Future<void> saveUserEmail(String email) async {
    await prefs.setString('userEmail', email);
  }

  static String? getUserEmail() {
    return prefs.getString('userEmail');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await prefs.clear();
  }
}