import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // =====================================================
  // MEDIA QUERY
  // =====================================================

  MediaQueryData get mediaQuery =>
      MediaQuery.of(this);

  Size get screenSize =>
      MediaQuery.of(this).size;

  double get screenWidth =>
      MediaQuery.of(this).size.width;

  double get screenHeight =>
      MediaQuery.of(this).size.height;

  double get pixelRatio =>
      MediaQuery.of(this).devicePixelRatio;

  Orientation get orientation =>
      MediaQuery.of(this).orientation;

  // =====================================================
  // SAFE AREA
  // =====================================================

  EdgeInsets get padding =>
      MediaQuery.of(this).padding;

  double get topPadding =>
      MediaQuery.of(this).padding.top;

  double get bottomPadding =>
      MediaQuery.of(this).padding.bottom;

  // =====================================================
  // THEME
  // =====================================================

  ThemeData get theme =>
      Theme.of(this);

  ColorScheme get colorScheme =>
      Theme.of(this).colorScheme;

  TextTheme get textTheme =>
      Theme.of(this).textTheme;

  // =====================================================
  // RESPONSIVE
  // =====================================================

  bool get isMobile =>
      screenWidth < 600;

  bool get isTablet =>
      screenWidth >= 600 &&
      screenWidth < 1024;

  bool get isDesktop =>
      screenWidth >= 1024;

  bool get isPortrait =>
      orientation ==
      Orientation.portrait;

  bool get isLandscape =>
      orientation ==
      Orientation.landscape;

  // =====================================================
  // KEYBOARD
  // =====================================================

  bool get isKeyboardOpen =>
      MediaQuery.of(this)
              .viewInsets
              .bottom >
          0;

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  // =====================================================
  // NAVIGATION
  // =====================================================

  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  Future<T?> push<T>(
    Widget page,
  ) {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  Future<T?> pushReplacement<T>(
    Widget page,
  ) {
    return Navigator.pushReplacement<T, T>(
      this,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  Future<T?> pushNamed<T>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  // =====================================================
  // SNACKBAR
  // =====================================================

  void showSnackBar(
    String message,
  ) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  void showSuccessSnackBar(
    String message,
  ) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  void showErrorSnackBar(
    String message,
  ) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // =====================================================
  // DIALOGS
  // =====================================================

  Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible:
          barrierDismissible,
      builder: (_) => child,
    );
  }

  Future<T?> showAppBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled:
          isScrollControlled,
      useSafeArea: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => child,
    );
  }

  // =====================================================
  // SPACING HELPERS
  // =====================================================

  SizedBox get verticalSpaceSmall =>
      const SizedBox(height: 8);

  SizedBox get verticalSpaceMedium =>
      const SizedBox(height: 16);

  SizedBox get verticalSpaceLarge =>
      const SizedBox(height: 24);

  SizedBox get horizontalSpaceSmall =>
      const SizedBox(width: 8);

  SizedBox get horizontalSpaceMedium =>
      const SizedBox(width: 16);

  SizedBox get horizontalSpaceLarge =>
      const SizedBox(width: 24);
}