import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==================================================
  // BRAND COLORS
  // ==================================================

  static const Color primary =
      Color(0xFF2563EB);

  static const Color primaryLight =
      Color(0xFF60A5FA);

  static const Color primaryDark =
      Color(0xFF1D4ED8);

  static const Color secondary =
      Color(0xFF7C3AED);

  static const Color accent =
      Color(0xFFFF6B35);

  // ==================================================
  // BACKGROUND COLORS
  // ==================================================

  static const Color background =
      Color(0xFFF8FAFC);

  static const Color surface =
      Colors.white;

  static const Color card =
      Colors.white;

  static const Color darkBackground =
      Color(0xFF121212);

  static const Color darkSurface =
      Color(0xFF1E1E1E);

  // ==================================================
  // TEXT COLORS
  // ==================================================

  static const Color textPrimary =
      Color(0xFF111827);

  static const Color textSecondary =
      Color(0xFF6B7280);

  static const Color textHint =
      Color(0xFF9CA3AF);

  static const Color textWhite =
      Colors.white;

  // ==================================================
  // STATUS COLORS
  // ==================================================

  static const Color success =
      Color(0xFF22C55E);

  static const Color warning =
      Color(0xFFF59E0B);

  static const Color error =
      Color(0xFFEF4444);

  static const Color info =
      Color(0xFF3B82F6);

  // ==================================================
  // BOOKING STATUS
  // ==================================================

  static const Color pending =
      Color(0xFFF59E0B);

  static const Color confirmed =
      Color(0xFF3B82F6);

  static const Color assigned =
      Color(0xFF8B5CF6);

  static const Color inProgress =
      Color(0xFFEC4899);

  static const Color completed =
      Color(0xFF22C55E);

  static const Color cancelled =
      Color(0xFFEF4444);

  // ==================================================
  // CATEGORY COLORS
  // ==================================================

  static const Color photography =
      Color(0xFF8B5CF6);

  static const Color catering =
      Color(0xFFF97316);

  static const Color decoration =
      Color(0xFFEC4899);

  static const Color hall =
      Color(0xFF3B82F6);

  static const Color dj =
      Color(0xFF7C3AED);

  static const Color makeup =
      Color(0xFFEF4444);

  static const Color resort =
      Color(0xFF14B8A6);

  static const Color grocery =
      Color(0xFF22C55E);

  // ==================================================
  // BORDER COLORS
  // ==================================================

  static const Color border =
      Color(0xFFE5E7EB);

  static const Color divider =
      Color(0xFFF3F4F6);

  // ==================================================
  // ICON COLORS
  // ==================================================

  static const Color iconPrimary =
      Color(0xFF374151);

  static const Color iconSecondary =
      Color(0xFF6B7280);

  // ==================================================
  // SHADOW COLORS
  // ==================================================

  static Color shadow =
      Colors.black.withValues(alpha: 0.08);

  // ==================================================
  // GRADIENTS
  // ==================================================

  static const LinearGradient primaryGradient =
      LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary,
      secondary,
    ],
  );

  static const LinearGradient blueGradient =
      LinearGradient(
    colors: [
      Color(0xFF2563EB),
      Color(0xFF60A5FA),
    ],
  );

  static const LinearGradient orangeGradient =
      LinearGradient(
    colors: [
      Color(0xFFFF6B35),
      Color(0xFFFFA726),
    ],
  );

  static const LinearGradient greenGradient =
      LinearGradient(
    colors: [
      Color(0xFF16A34A),
      Color(0xFF4ADE80),
    ],
  );

  // ==================================================
  // HELPERS
  // ==================================================

  static Color bookingStatusColor(
      String status) {
    switch (
        status.toLowerCase()) {
      case 'pending':
        return pending;

      case 'confirmed':
        return confirmed;

      case 'assigned':
        return assigned;

      case 'in progress':
        return inProgress;

      case 'completed':
        return completed;

      case 'cancelled':
        return cancelled;

      default:
        return textSecondary;
    }
  }

  static Color distanceColor(
      double km) {
    if (km <= 5) {
      return success;
    } else if (km <= 15) {
      return warning;
    }
    return error;
  }
}