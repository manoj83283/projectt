import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    loadTheme();
  }

  static const String _themeKey =
      'theme_mode';

  ThemeMode _themeMode =
      ThemeMode.system;

  bool _isLoading = false;

  // ==========================================
  // GETTERS
  // ==========================================

  ThemeMode get themeMode =>
      _themeMode;

  bool get isLoading => _isLoading;

  bool get isDarkMode =>
      _themeMode == ThemeMode.dark;

  bool get isLightMode =>
      _themeMode == ThemeMode.light;

  bool get isSystemMode =>
      _themeMode == ThemeMode.system;

  // ==========================================
  // SET LOADING
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // LOAD THEME
  // ==========================================

  Future<void> loadTheme() async {
    try {
      _setLoading(true);

      final prefs =
          await SharedPreferences
              .getInstance();

      final theme =
          prefs.getString(_themeKey);

      switch (theme) {
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;

        case 'light':
          _themeMode = ThemeMode.light;
          break;

        default:
          _themeMode = ThemeMode.system;
      }

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SET THEME MODE
  // ==========================================

  Future<void> setThemeMode(
    ThemeMode mode,
  ) async {
    _themeMode = mode;

    final prefs =
        await SharedPreferences
            .getInstance();

    switch (mode) {
      case ThemeMode.dark:
        await prefs.setString(
          _themeKey,
          'dark',
        );
        break;

      case ThemeMode.light:
        await prefs.setString(
          _themeKey,
          'light',
        );
        break;

      case ThemeMode.system:
        await prefs.setString(
          _themeKey,
          'system',
        );
        break;
    }

    notifyListeners();
  }

  // ==========================================
  // TOGGLE THEME
  // ==========================================

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(
        ThemeMode.light,
      );
    } else {
      await setThemeMode(
        ThemeMode.dark,
      );
    }
  }

  // ==========================================
  // SET DARK MODE
  // ==========================================

  Future<void> setDarkMode() async {
    await setThemeMode(
      ThemeMode.dark,
    );
  }

  // ==========================================
  // SET LIGHT MODE
  // ==========================================

  Future<void> setLightMode() async {
    await setThemeMode(
      ThemeMode.light,
    );
  }

  // ==========================================
  // SET SYSTEM MODE
  // ==========================================

  Future<void> setSystemMode() async {
    await setThemeMode(
      ThemeMode.system,
    );
  }

  // ==========================================
  // RESET
  // ==========================================

  Future<void> reset() async {
    await setThemeMode(
      ThemeMode.system,
    );
  }
}