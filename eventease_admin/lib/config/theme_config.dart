import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

class ThemeConfig {
  ThemeConfig._();

  // =====================================================
  // LIGHT THEME
  // =====================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      scaffoldBackgroundColor:
          AppColors.background,

      primaryColor:
          AppColors.primary,

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
        surfaceTintColor:
            Colors.transparent,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radius16,
          ),
        ),
      ),

      dividerTheme:
          const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radius12,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radius12,
          ),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radius12,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radius12,
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
          elevation: 0,
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeight,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppDimensions
                  .buttonRadius,
            ),
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppDimensions
                  .buttonRadius,
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

      checkboxTheme:
          CheckboxThemeData(
        fillColor:
            WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }
            return Colors.transparent;
          },
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor:
            WidgetStateProperty.all(
          AppColors.primary,
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.all(
          AppColors.primary,
        ),
      ),

      dataTableTheme:
          DataTableThemeData(
        headingRowColor:
            WidgetStateProperty.all(
          AppColors.background,
        ),
        headingTextStyle:
            const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        dataTextStyle:
            const TextStyle(
          color: AppColors.textPrimary,
        ),
      ),

      snackBarTheme:
          const SnackBarThemeData(
        behavior:
            SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radius20,
          ),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
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

      primaryColor:
          AppColors.primary,

      scaffoldBackgroundColor:
          const Color(0xFF0F172A),

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),

      appBarTheme:
          const AppBarTheme(
        backgroundColor:
            Color(0xFF111827),
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: const Color(
          0xFF1E293B,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radius16,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primary,
          foregroundColor:
              Colors.white,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor:
            const Color(0xFF1E293B),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radius20,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // THEME MODE
  // =====================================================

  static ThemeMode get defaultThemeMode {
    return ThemeMode.system;
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static bool isDarkMode(
    BuildContext context,
  ) {
    return Theme.of(context)
            .brightness ==
        Brightness.dark;
  }

  static bool isLightMode(
    BuildContext context,
  ) {
    return Theme.of(context)
            .brightness ==
        Brightness.light;
  }
}