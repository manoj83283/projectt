import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // =====================================================
  // LIGHT THEME
  // =====================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      primaryColor: AppColors.primary,

      scaffoldBackgroundColor:
          AppColors.background,

      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor:
            AppColors.surface,
        foregroundColor:
            AppColors.textPrimary,
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),

      dividerColor:
          AppColors.divider,

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor:
            AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide:
              const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide:
              const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(12),
          borderSide:
              const BorderSide(
            color:
                AppColors.primary,
            width: 2,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          minimumSize:
              const Size(
            double.infinity,
            50,
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
            50,
          ),
          side: const BorderSide(
            color:
                AppColors.primary,
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

      textButtonTheme:
          TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              AppColors.primary,
        ),
      ),

      drawerTheme:
          const DrawerThemeData(
        backgroundColor:
            AppColors.surface,
      ),

      dataTableTheme:
          const DataTableThemeData(
        headingRowColor:
            WidgetStatePropertyAll(
          AppColors.background,
        ),
        dividerThickness: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor:
            AppColors.background,
        selectedColor:
            AppColors.primary,
        labelStyle:
            const TextStyle(
          color:
              AppColors.textPrimary,
        ),
        secondaryLabelStyle:
            const TextStyle(
          color: Colors.white,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            25,
          ),
        ),
      ),

      snackBarTheme:
          const SnackBarThemeData(
        behavior:
            SnackBarBehavior.floating,
      ),

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color:
            AppColors.primary,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight:
              FontWeight.bold,
          color:
              AppColors.textPrimary,
        ),
        headlineMedium:
            TextStyle(
          fontSize: 24,
          fontWeight:
              FontWeight.w600,
          color:
              AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.w600,
          color:
              AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color:
              AppColors.textPrimary,
        ),
        bodyMedium:
            TextStyle(
          fontSize: 14,
          color:
              AppColors.textSecondary,
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

      scaffoldBackgroundColor:
          AppColors.darkBackground,

      primaryColor:
          AppColors.primary,

      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary:
            AppColors.secondary,
        error: AppColors.error,
        surface:
            AppColors.darkSurface,
      ),

      appBarTheme:
          const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor:
            AppColors.darkSurface,
      ),

      cardTheme: CardThemeData(
        color:
            AppColors.darkCard,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),

      dividerColor:
          AppColors.darkDivider,

      drawerTheme:
          const DrawerThemeData(
        backgroundColor:
            AppColors.darkSurface,
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor:
            AppColors.darkSurface,
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          minimumSize:
              const Size(
            double.infinity,
            50,
          ),
        ),
      ),

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color:
            AppColors.primary,
      ),

      snackBarTheme:
          const SnackBarThemeData(
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}