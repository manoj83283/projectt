import 'package:flutter/material.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  // =====================================================
  // BREAKPOINTS
  // =====================================================

  static const double mobileBreakpoint =
      600;

  static const double tabletBreakpoint =
      1024;

  static const double desktopBreakpoint =
      1440;

  // =====================================================
  // SCREEN TYPE
  // =====================================================

  static bool isMobile(
    BuildContext context,
  ) {
    return MediaQuery.of(context)
            .size
            .width <
        mobileBreakpoint;
  }

  static bool isTablet(
    BuildContext context,
  ) {
    final width =
        MediaQuery.of(context).size.width;

    return width >=
            mobileBreakpoint &&
        width < tabletBreakpoint;
  }

  static bool isDesktop(
    BuildContext context,
  ) {
    return MediaQuery.of(context)
            .size
            .width >=
        tabletBreakpoint;
  }

  static bool isLargeDesktop(
    BuildContext context,
  ) {
    return MediaQuery.of(context)
            .size
            .width >=
        desktopBreakpoint;
  }

  // =====================================================
  // SCREEN SIZE
  // =====================================================

  static double screenWidth(
    BuildContext context,
  ) {
    return MediaQuery.of(context)
        .size
        .width;
  }

  static double screenHeight(
    BuildContext context,
  ) {
    return MediaQuery.of(context)
        .size
        .height;
  }

  // =====================================================
  // PADDING
  // =====================================================

  static double horizontalPadding(
    BuildContext context,
  ) {
    if (isMobile(context)) return 16;
    if (isTablet(context)) return 24;
    return 32;
  }

  static double verticalPadding(
    BuildContext context,
  ) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 20;
    return 24;
  }

  // =====================================================
  // DASHBOARD GRID
  // =====================================================

  static int dashboardGridCount(
    BuildContext context,
  ) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    if (isLargeDesktop(context)) return 5;

    return 4;
  }

  // =====================================================
  // CUSTOMER GRID
  // =====================================================

  static int customerGridCount(
    BuildContext context,
  ) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;

    return 3;
  }

  // =====================================================
  // CARD WIDTH
  // =====================================================

  static double cardWidth(
    BuildContext context,
  ) {
    final width =
        screenWidth(context);

    if (isMobile(context)) {
      return width;
    }

    if (isTablet(context)) {
      return width / 2.3;
    }

    return width / 4.5;
  }

  // =====================================================
  // SIDEBAR
  // =====================================================

  static bool showSidebar(
    BuildContext context,
  ) {
    return !isMobile(context);
  }

  static bool showDrawer(
    BuildContext context,
  ) {
    return isMobile(context);
  }

  // =====================================================
  // FONT SIZE
  // =====================================================

  static double headingFontSize(
    BuildContext context,
  ) {
    if (isMobile(context)) return 22;
    if (isTablet(context)) return 26;

    return 30;
  }

  static double bodyFontSize(
    BuildContext context,
  ) {
    if (isMobile(context)) return 14;
    if (isTablet(context)) return 15;

    return 16;
  }

  // =====================================================
  // DEVICE TYPE
  // =====================================================

  static String deviceType(
    BuildContext context,
  ) {
    if (isMobile(context)) {
      return 'mobile';
    }

    if (isTablet(context)) {
      return 'tablet';
    }

    return 'desktop';
  }
}
