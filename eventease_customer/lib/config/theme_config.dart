import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  ThemeConfig._();

  // =====================================================
  // COLORS
  // =====================================================

  static const Color primaryColor =
      Color(0xFF1976D2);

  static const Color secondaryColor =
      Color(0xFF26A69A);

  static const Color accentColor =
      Color(0xFFFF9800);

  static const Color successColor =
      Color(0xFF4CAF50);

  static const Color errorColor =
      Color(0xFFE53935);

  static const Color warningColor =
      Color(0xFFFFB300);

  static const Color backgroundColor =
      Color(0xFFF8F9FC);

  static const Color cardColor =
      Colors.white;

  static const Color textPrimary =
      Color(0xFF212121);

  static const Color textSecondary =
      Color(0xFF757575);

  // =====================================================
  // LIGHT THEME
  // =====================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    primaryColor: primaryColor,

    scaffoldBackgroundColor:
        backgroundColor,

    cardColor: cardColor,

    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: Colors.white,
    ),

    textTheme: GoogleFonts.poppinsTextTheme(),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle:
          GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize:
            const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    ),

    outlinedButtonTheme:
        OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
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
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide:
            const BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
    ),

    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // =====================================================
  // DARK THEME
  // =====================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    primaryColor: primaryColor,

    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),

    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    ),

    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor:
          const Color(0xFF121212),
      titleTextStyle:
          GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize:
            const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
    ),
  );
}