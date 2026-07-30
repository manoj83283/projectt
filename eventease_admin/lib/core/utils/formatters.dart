import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  // =====================================================
  // DATE FORMATTERS
  // =====================================================

  static String formatDate(
    DateTime? date,
  ) {
    if (date == null) return '-';

    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }

  static String formatDateTime(
    DateTime? date,
  ) {
    if (date == null) return '-';

    return DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(date);
  }

  static String formatTime(
    DateTime? date,
  ) {
    if (date == null) return '-';

    return DateFormat(
      'hh:mm a',
    ).format(date);
  }

  static String formatServerDate(
    DateTime? date,
  ) {
    if (date == null) return '';

    return DateFormat(
      'yyyy-MM-dd',
    ).format(date);
  }

  // =====================================================
  // CURRENCY FORMATTERS
  // =====================================================

  static String formatCurrency(
    num? amount,
  ) {
    if (amount == null) return '₹0';

    final formatter =
        NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return formatter.format(amount);
  }

  static String formatCompactCurrency(
    num? amount,
  ) {
    if (amount == null) return '₹0';

    final formatter =
        NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '₹',
    );

    return formatter.format(amount);
  }

  // =====================================================
  // NUMBER FORMATTERS
  // =====================================================

  static String formatNumber(
    num? value,
  ) {
    if (value == null) return '0';

    return NumberFormat(
      '#,##,###',
    ).format(value);
  }

  static String formatCompactNumber(
    num? value,
  ) {
    if (value == null) return '0';

    return NumberFormat.compact()
        .format(value);
  }

  // =====================================================
  // PERCENTAGE
  // =====================================================

  static String formatPercentage(
    num? value,
  ) {
    if (value == null) return '0%';

    return '${value.toStringAsFixed(2)}%';
  }

  // =====================================================
  // PHONE NUMBER
  // =====================================================

  static String formatPhone(
    String? phone,
  ) {
    if (phone == null ||
        phone.isEmpty) {
      return '-';
    }

    if (phone.length != 10) {
      return phone;
    }

    return '${phone.substring(0, 5)} ${phone.substring(5)}';
  }

  // =====================================================
  // MASK PHONE
  // =====================================================

  static String maskPhone(
    String? phone,
  ) {
    if (phone == null ||
        phone.length < 10) {
      return '-';
    }

    return '${phone.substring(0, 2)}******${phone.substring(8)}';
  }

  // =====================================================
  // EMAIL MASKING
  // =====================================================

  static String maskEmail(
    String? email,
  ) {
    if (email == null ||
        !email.contains('@')) {
      return '-';
    }

    final parts =
        email.split('@');

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return email;
    }

    return '${username.substring(0, 2)}******@$domain';
  }

  // =====================================================
  // STATUS FORMAT
  // =====================================================

  static String formatStatus(
    String? status,
  ) {
    if (status == null ||
        status.isEmpty) {
      return '-';
    }

    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() +
                  word.substring(1),
        )
        .join(' ');
  }

  // =====================================================
  // NAME INITIALS
  // =====================================================

  static String getInitials(
    String? name,
  ) {
    if (name == null ||
        name.trim().isEmpty) {
      return 'NA';
    }

    final parts =
        name.trim().split(' ');

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'
        .toUpperCase();
  }

  // =====================================================
  // FILE SIZE
  // =====================================================

  static String formatFileSize(
    int bytes,
  ) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }

    if (bytes <
        1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  // =====================================================
  // INPUT FORMATTERS
  // =====================================================

  static List<TextInputFormatter>
      phoneInputFormatter() {
    return [
      FilteringTextInputFormatter
          .digitsOnly,
      LengthLimitingTextInputFormatter(
        10,
      ),
    ];
  }

  static List<TextInputFormatter>
      otpInputFormatter() {
    return [
      FilteringTextInputFormatter
          .digitsOnly,
      LengthLimitingTextInputFormatter(
        6,
      ),
    ];
  }

  static List<TextInputFormatter>
      amountInputFormatter() {
    return [
      FilteringTextInputFormatter.allow(
        RegExp(r'^\d*\.?\d{0,2}'),
      ),
    ];
  }

  // =====================================================
  // RELATIVE TIME
  // =====================================================

  static String timeAgo(
    DateTime? date,
  ) {
    if (date == null) return '-';

    final difference =
        DateTime.now()
            .difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 30) {
      return '${difference.inDays} day ago';
    }

    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} month ago';
    }

    return '${(difference.inDays / 365).floor()} year ago';
  }
}