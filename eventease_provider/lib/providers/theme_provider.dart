import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  bool _isLoading = false;

  ThemeMode _themeMode = ThemeMode.system;

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode =>
      _themeMode == ThemeMode.dark;

  bool get isLightMode =>
      _themeMode == ThemeMode.light;

  bool get isSystemMode =>
      _themeMode == ThemeMode.system;

  // =========================
  // INIT
  // =========================

  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs =
          await SharedPreferences.getInstance();

      final savedTheme =
          prefs.getString(_themeKey);

      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;

        case 'dark':
          _themeMode = ThemeMode.dark;
          break;

        default:
          _themeMode = ThemeMode.system;
      }
    } catch (e) {
      debugPrint(
        'Theme Initialize Error: $e',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // SET LIGHT MODE
  // =========================

  Future<void> setLightMode() async {
    await _saveThemeMode(
      ThemeMode.light,
      'light',
    );
  }

  // =========================
  // SET DARK MODE
  // =========================

  Future<void> setDarkMode() async {
    await _saveThemeMode(
      ThemeMode.dark,
      'dark',
    );
  }

  // =========================
  // SET SYSTEM MODE
  // =========================

  Future<void> setSystemMode() async {
    await _saveThemeMode(
      ThemeMode.system,
      'system',
    );
  }

  // =========================
  // TOGGLE THEME
  // =========================

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  // =========================
  // SAVE THEME MODE
  // =========================

  Future<void> _saveThemeMode(
    ThemeMode mode,
    String value,
  ) async {
    try {
      _themeMode = mode;

      notifyListeners();

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        _themeKey,
        value,
      );
    } catch (e) {
      debugPrint(
        'Save Theme Error: $e',
      );
    }
  }

  // =========================
  // RESET
  // =========================

  Future<void> resetTheme() async {
    await setSystemMode();
  }
}