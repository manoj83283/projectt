import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Helpers {
  Helpers._();

  // =====================================================
  // SNACKBARS
  // =====================================================

  static void showSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showErrorSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showWarningSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =====================================================
  // LOADING DIALOG
  // =====================================================

  static void showLoading(
    BuildContext context, {
    String message = "Loading...",
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void hideLoading(
    BuildContext context,
  ) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop();
  }

  // =====================================================
  // ALERT DIALOG
  // =====================================================

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = "Yes",
    String cancelText = "No",
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // BOTTOM SHEET
  // =====================================================

  static Future<T?> showAppBottomSheet<T>(
    BuildContext context,
    Widget child,
  ) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) => child,
    );
  }

  // =====================================================
  // KEYBOARD
  // =====================================================

  static void dismissKeyboard(
    BuildContext context,
  ) {
    FocusScope.of(context).unfocus();
  }

  // =====================================================
  // NAVIGATION
  // =====================================================

  static Future<dynamic> push(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  static Future<dynamic> pushReplacement(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  static void pop(BuildContext context,
      [dynamic result]) {
    Navigator.pop(context, result);
  }

  // =====================================================
  // FORMATTERS
  // =====================================================

  static String formatCurrency(
    double amount,
  ) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return formatter.format(amount);
  }

  static String formatNumber(
    num value,
  ) {
    final formatter =
        NumberFormat('#,##,###');

    return formatter.format(value);
  }

  // =====================================================
  // DATE HELPERS
  // =====================================================

  static String formatDate(
    DateTime date,
  ) {
    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }

  static String formatDateTime(
    DateTime date,
  ) {
    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(date);
  }

  // =====================================================
  // STRING HELPERS
  // =====================================================

  static String capitalize(
    String value,
  ) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() +
        value.substring(1);
  }

  static String capitalizeWords(
    String value,
  ) {
    return value
        .split(' ')
        .map(capitalize)
        .join(' ');
  }

  // =====================================================
  // CLIPBOARD
  // =====================================================

  static Future<void> copyToClipboard(
    BuildContext context,
    String text,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: text),
    );

    if (context.mounted) {
      showSuccessSnackBar(
        context,
        "Copied to clipboard",
      );
    }
  }

  // =====================================================
  // IMAGE HELPERS
  // =====================================================

  static String imageOrPlaceholder(
    String? imageUrl,
    String placeholder,
  ) {
    if (imageUrl == null ||
        imageUrl.trim().isEmpty) {
      return placeholder;
    }

    return imageUrl;
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  static Color statusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;

      case 'confirmed':
        return Colors.blue;

      case 'assigned':
        return Colors.indigo;

      case 'in progress':
        return Colors.purple;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // STAR RATING
  // =====================================================

  static List<Widget> ratingStars(
    double rating,
  ) {
    return List.generate(
      5,
      (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      },
    );
  }
}