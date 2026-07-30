import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  Helpers._();

  // =====================================================
  // SNACKBAR
  // =====================================================

  static void showSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // =====================================================
  // SUCCESS SNACKBAR
  // =====================================================

  static void showSuccess(
    BuildContext context,
    String message,
  ) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  // =====================================================
  // ERROR SNACKBAR
  // =====================================================

  static void showError(
    BuildContext context,
    String message,
  ) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red,
    );
  }

  // =====================================================
  // FORMAT DATE
  // =====================================================

  static String formatDate(
    DateTime date,
  ) {
    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }

  // =====================================================
  // FORMAT DATE TIME
  // =====================================================

  static String formatDateTime(
    DateTime dateTime,
  ) {
    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(dateTime);
  }

  // =====================================================
  // FORMAT TIME
  // =====================================================

  static String formatTime(
    DateTime dateTime,
  ) {
    return DateFormat(
      'hh:mm a',
    ).format(dateTime);
  }

  // =====================================================
  // FORMAT CURRENCY
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

  // =====================================================
  // FORMAT NUMBER
  // =====================================================

  static String formatNumber(
    num value,
  ) {
    return NumberFormat.decimalPattern(
      'en_IN',
    ).format(value);
  }

  // =====================================================
  // CAPITALIZE
  // =====================================================

  static String capitalize(
    String text,
  ) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() +
        text.substring(1);
  }

  // =====================================================
  // TITLE CASE
  // =====================================================

  static String toTitleCase(
    String text,
  ) {
    if (text.trim().isEmpty) {
      return '';
    }

    return text
        .split(' ')
        .map(
          (word) => capitalize(word),
        )
        .join(' ');
  }

  // =====================================================
  // INITIALS
  // =====================================================

  static String getInitials(
    String name,
  ) {
    final names = name
        .trim()
        .split(' ')
        .where(
          (e) => e.isNotEmpty,
        )
        .toList();

    if (names.isEmpty) {
      return '';
    }

    if (names.length == 1) {
      return names.first[0]
          .toUpperCase();
    }

    return '${names[0][0]}${names[1][0]}'
        .toUpperCase();
  }

  // =====================================================
  // MASK PHONE
  // =====================================================

  static String maskPhone(
    String phone,
  ) {
    if (phone.length < 10) {
      return phone;
    }

    return '${phone.substring(0, 2)}******${phone.substring(phone.length - 2)}';
  }

  // =====================================================
  // MASK EMAIL
  // =====================================================

  static String maskEmail(
    String email,
  ) {
    if (!email.contains('@')) {
      return email;
    }

    final parts = email.split('@');

    if (parts.first.length < 3) {
      return email;
    }

    return '${parts.first.substring(0, 2)}****@${parts.last}';
  }

  // =====================================================
  // REMOVE NULLS
  // =====================================================

  static Map<String, dynamic>
      removeNullValues(
    Map<String, dynamic> map,
  ) {
    map.removeWhere(
      (key, value) => value == null,
    );

    return map;
  }

  // =====================================================
  // STATUS COLOR
  // =====================================================

  static Color getStatusColor(
    String? status,
  ) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'confirmed':
        return Colors.green;

      case 'pending':
      case 'processing':
        return Colors.orange;

      case 'cancelled':
      case 'failed':
        return Colors.red;

      case 'refunded':
        return Colors.purple;

      default:
        return Colors.grey;
    }
  }

  // =====================================================
  // STATUS TEXT
  // =====================================================

  static String formatStatus(
    String? status,
  ) {
    if (status == null ||
        status.isEmpty) {
      return '';
    }

    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (e) => capitalize(e),
        )
        .join(' ');
  }

  // =====================================================
  // RANDOM ID
  // =====================================================

  static String generateId({
    int length = 10,
  }) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final random = Random();

    return List.generate(
      length,
      (_) =>
          chars[random.nextInt(chars.length)],
    ).join();
  }

  // =====================================================
  // DAYS DIFFERENCE
  // =====================================================

  static int daysBetween(
    DateTime start,
    DateTime end,
  ) {
    return end
        .difference(start)
        .inDays;
  }

  // =====================================================
  // VALID URL
  // =====================================================

  static bool isValidUrl(
    String url,
  ) {
    return Uri.tryParse(url)
            ?.hasAbsolutePath ==
        true;
  }

  // =====================================================
  // VALID IMAGE URL
  // =====================================================

  static bool isImageUrl(
    String url,
  ) {
    return url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.webp');
  }

  // =====================================================
  // HIDE KEYBOARD
  // =====================================================

  static void hideKeyboard(
    BuildContext context,
  ) {
    FocusScope.of(context).unfocus();
  }

  // =====================================================
  // SHOW LOADING
  // =====================================================

  static void showLoading(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(
            child:
                CircularProgressIndicator(),
          ),
    );
  }

  // =====================================================
  // HIDE LOADING
  // =====================================================

  static void hideLoading(
    BuildContext context,
  ) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop();
  }

  // =====================================================
  // CONFIRMATION DIALOG
  // =====================================================

  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),
            child: const Text(
              'Cancel',
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),
            child: const Text(
              'Confirm',
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}