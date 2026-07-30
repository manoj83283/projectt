import 'package:flutter/material.dart';

class ThemeConfig {
  ThemeConfig._();

  // =====================================================
  // COLORS
  // =====================================================

  static const Color primaryColor =
      Color(0xFF2563EB);

  static const Color secondaryColor =
      Color(0xFF10B981);

  static const Color errorColor =
      Color(0xFFEF4444);

  static const Color warningColor =
      Color(0xFFF59E0B);

  static const Color successColor =
      Color(0xFF22C55E);

  static const Color scaffoldLight =
      Color(0xFFF8FAFC);

  static const Color scaffoldDark =
      Color(0xFF0F172A);

  // =====================================================
  // LIGHT THEME
  // =====================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      primaryColor: primaryColor,

      scaffoldBackgroundColor:
          scaffoldLight,

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),

      // =====================
      // APPBAR
      // =====================

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor:
            Colors.transparent,
      ),

      // =====================
      // CARD
      // =====================

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),
      ),

      // =====================
      // BUTTONS
      // =====================

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              primaryColor,
          foregroundColor:
              Colors.white,
          elevation: 0,
          minimumSize:
              const Size(
            double.infinity,
            52,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          minimumSize:
              const Size(
            double.infinity,
            52,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      // =====================
      // INPUT
      // =====================

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderSide:
              const BorderSide(
            color:
                Color(0xFFE2E8F0),
          ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderSide:
              const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),

      // =====================
      // SWITCH
      // =====================

      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.all(
          primaryColor,
        ),
      ),

      // =====================
      // CHECKBOX
      // =====================

      checkboxTheme:
          CheckboxThemeData(
        fillColor:
            WidgetStateProperty.all(
          primaryColor,
        ),
      ),

      // =====================
      // SNACKBAR
      // =====================

      snackBarTheme:
          const SnackBarThemeData(
        behavior:
            SnackBarBehavior.floating,
      ),

      // =====================
      // BOTTOM NAVIGATION
      // =====================

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        selectedItemColor:
            primaryColor,
        unselectedItemColor:
            Colors.grey,
        type:
            BottomNavigationBarType.fixed,
      ),

      // =====================
      // TEXT
      // =====================

      textTheme:
          const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight:
              FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  // =====================================================
  // DARK THEME
  // =====================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      primaryColor: primaryColor,

      scaffoldBackgroundColor:
          scaffoldDark,

      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),

      // =====================
      // APPBAR
      // =====================

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            Color(0xFF1E293B),
        foregroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.transparent,
      ),

      // =====================
      // CARD
      // =====================

      cardTheme: CardThemeData(
        color:
            const Color(0xFF1E293B),
        elevation: 1,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),
      ),

      // =====================
      // INPUT
      // =====================

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor:
            const Color(0xFF1E293B),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderSide:
              const BorderSide(
            color:
                Color(0xFF334155),
          ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderSide:
              const BorderSide(
            color: primaryColor,
          ),
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),

      // =====================
      // BUTTONS
      // =====================

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              primaryColor,
          foregroundColor:
              Colors.white,
          minimumSize:
              const Size(
            double.infinity,
            52,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      // =====================
      // BOTTOM NAVIGATION
      // =====================

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor:
            Color(0xFF1E293B),
        selectedItemColor:
            primaryColor,
        unselectedItemColor:
            Colors.grey,
        type:
            BottomNavigationBarType.fixed,
      ),

      // =====================
      // TEXT
      // =====================

      textTheme:
          const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight:
              FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}