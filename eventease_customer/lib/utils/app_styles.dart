import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  AppStyles._();

  // =========================================================
  // TEXT STYLES
  // =========================================================

  static const TextStyle heading1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textHint,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle priceText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    color: AppColors.error,
  );

  // =========================================================
  // BORDER RADIUS
  // =========================================================

  static BorderRadius radiusSmall =
      BorderRadius.circular(8);

  static BorderRadius radiusMedium =
      BorderRadius.circular(12);

  static BorderRadius radiusLarge =
      BorderRadius.circular(16);

  static BorderRadius radiusXL =
      BorderRadius.circular(24);

  // =========================================================
  // SHADOWS
  // =========================================================

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  // =========================================================
  // CARD DECORATION
  // =========================================================

  static BoxDecoration cardDecoration =
      BoxDecoration(
    color: Colors.white,
    borderRadius: radiusLarge,
    boxShadow: cardShadow,
  );

  static BoxDecoration containerDecoration =
      BoxDecoration(
    color: Colors.white,
    borderRadius: radiusMedium,
    border: Border.all(
      color: AppColors.border,
    ),
  );

  // =========================================================
  // INPUT DECORATION
  // =========================================================

  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,

      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      border: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius: radiusMedium,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
    );
  }

  // =========================================================
  // BUTTON STYLES
  // =========================================================

  static ButtonStyle primaryButton =
      ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    minimumSize: const Size(
      double.infinity,
      54,
    ),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: radiusMedium,
    ),
  );

  static ButtonStyle secondaryButton =
      OutlinedButton.styleFrom(
    minimumSize:
        const Size(double.infinity, 54),
    side: const BorderSide(
      color: AppColors.primary,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: radiusMedium,
    ),
  );

  // =========================================================
  // STATUS COLORS
  // =========================================================

  static Color statusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;

      case 'confirmed':
        return AppColors.confirmed;

      case 'assigned':
        return AppColors.assigned;

      case 'in progress':
        return AppColors.inProgress;

      case 'completed':
        return AppColors.completed;

      case 'cancelled':
        return AppColors.cancelled;

      default:
        return AppColors.textSecondary;
    }
  }

  // =========================================================
  // APP BAR
  // =========================================================

  static AppBarTheme appBarTheme =
      const AppBarTheme(
    centerTitle: true,
    backgroundColor: Colors.white,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );

  // =========================================================
  // THEME DATA
  // =========================================================

  static ThemeData lightTheme =
      ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor:
        AppColors.background,
    appBarTheme: appBarTheme,
    colorScheme:
        ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ),
  );
}