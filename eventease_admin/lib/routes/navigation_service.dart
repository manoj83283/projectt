import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState>
      navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator =>
      navigatorKey.currentState;

  static BuildContext? get context =>
      navigatorKey.currentContext;

  // =====================================================
  // PUSH
  // =====================================================

  static Future<dynamic>? push(
    String routeName, {
    Object? arguments,
  }) {
    return navigator?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  // =====================================================
  // PUSH REPLACEMENT
  // =====================================================

  static Future<dynamic>? pushReplacement(
    String routeName, {
    Object? arguments,
  }) {
    return navigator?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  // =====================================================
  // PUSH REMOVE UNTIL
  // =====================================================

  static Future<dynamic>? pushAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    return navigator?.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // =====================================================
  // POP
  // =====================================================

  static void pop<T extends Object?>(
      [T? result]) {
    if (navigator?.canPop() ?? false) {
      navigator?.pop(result);
    }
  }

  // =====================================================
  // POP UNTIL
  // =====================================================

  static void popUntil(
    String routeName,
  ) {
    navigator?.popUntil(
      ModalRoute.withName(routeName),
    );
  }

  // =====================================================
  // CAN POP
  // =====================================================

  static bool canPop() {
    return navigator?.canPop() ?? false;
  }

  // =====================================================
  // MAYBE POP
  // =====================================================

  static Future<bool> maybePop() async {
    return await navigator?.maybePop() ??
        false;
  }

  // =====================================================
  // CURRENT ROUTE
  // =====================================================

  static String? currentRouteName(
    BuildContext context,
  ) {
    return ModalRoute.of(context)
        ?.settings
        .name;
  }

  // =====================================================
  // SHOW SNACKBAR
  // =====================================================

  static void showSnackBar({
    required String message,
    Color backgroundColor =
        Colors.green,
    Duration duration =
        const Duration(seconds: 3),
  }) {
    final ctx = navigatorKey.currentContext;

    if (ctx == null) return;

    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              backgroundColor,
          duration: duration,
        ),
      );
  }

  // =====================================================
  // SUCCESS MESSAGE
  // =====================================================

  static void showSuccess(
    String message,
  ) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.green,
    );
  }

  // =====================================================
  // ERROR MESSAGE
  // =====================================================

  static void showError(
    String message,
  ) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red,
    );
  }

  // =====================================================
  // WARNING MESSAGE
  // =====================================================

  static void showWarning(
    String message,
  ) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.orange,
    );
  }

  // =====================================================
  // INFO MESSAGE
  // =====================================================

  static void showInfo(
    String message,
  ) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.blue,
    );
  }

  // =====================================================
  // SHOW DIALOG
  // =====================================================

  static Future<T?> showAppDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: navigatorKey.currentContext!,
      barrierDismissible:
          barrierDismissible,
      builder: (_) => child,
    );
  }

  // =====================================================
  // SHOW CONFIRM DIALOG
  // =====================================================

  static Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // LOGOUT & CLEAR STACK
  // =====================================================

  static Future<dynamic>? logout(
    String loginRoute,
  ) {
    return pushAndRemoveUntil(
      loginRoute,
    );
  }
}