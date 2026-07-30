import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeMode _themeMode = ThemeMode.light;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _themeMode;

  bool get isLightTheme =>
      _themeMode == ThemeMode.light;

  bool get isDarkTheme =>
      _themeMode == ThemeMode.dark;

  bool get isSystemTheme =>
      _themeMode == ThemeMode.system;

  // =====================================================
  // LIGHT THEME
  // =====================================================

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      colorSchemeSeed:
          const Color(0xFF2563EB),

      scaffoldBackgroundColor:
          const Color(0xFFF8FAFC),

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize:
              const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // DARK THEME
  // =====================================================

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      colorSchemeSeed:
          const Color(0xFF2563EB),

      scaffoldBackgroundColor:
          const Color(0xFF0F172A),

      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize:
              const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // TOGGLE THEME
  // =====================================================

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setLightTheme();
    } else {
      setDarkTheme();
    }
  }

  // =====================================================
  // LIGHT THEME
  // =====================================================

  void setLightTheme() {
    _themeMode = ThemeMode.light;
    _isDarkMode = false;
    notifyListeners();
  }

  // =====================================================
  // DARK THEME
  // =====================================================

  void setDarkTheme() {
    _themeMode = ThemeMode.dark;
    _isDarkMode = true;
    notifyListeners();
  }

  // =====================================================
  // SYSTEM THEME
  // =====================================================

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}