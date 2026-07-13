import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat =
      NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _currencyDecimalFormat =
      NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  // =====================================================
  // BASIC CURRENCY
  // =====================================================

  static String format(
    num amount,
  ) {
    return _currencyFormat.format(amount);
  }

  static String formatWithDecimals(
    num amount,
  ) {
    return _currencyDecimalFormat.format(amount);
  }

  // =====================================================
  // COMPACT FORMAT
  // =====================================================

  static String compact(
    num amount,
  ) {
    if (amount >= 10000000) {
      return "₹${(amount / 10000000).toStringAsFixed(2)} Cr";
    }

    if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(2)} L";
    }

    if (amount >= 1000) {
      return "₹${(amount / 1000).toStringAsFixed(1)} K";
    }

    return "₹${amount.toStringAsFixed(0)}";
  }

  // =====================================================
  // WORD FORMAT
  // =====================================================

  static String indianUnits(
    num amount,
  ) {
    if (amount >= 10000000) {
      return "₹${(amount / 10000000).toStringAsFixed(2)} Crore";
    }

    if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(2)} Lakh";
    }

    if (amount >= 1000) {
      return "₹${(amount / 1000).toStringAsFixed(2)} Thousand";
    }

    return "₹${amount.toStringAsFixed(0)}";
  }

  // =====================================================
  // WITHOUT SYMBOL
  // =====================================================

  static String withoutSymbol(
    num amount,
  ) {
    final formatter =
        NumberFormat('#,##,##0');

    return formatter.format(amount);
  }

  // =====================================================
  // PARSE AMOUNT
  // =====================================================

  static double parse(
    String value,
  ) {
    return double.tryParse(
          value
              .replaceAll('₹', '')
              .replaceAll(',', '')
              .trim(),
        ) ??
        0;
  }

  // =====================================================
  // PERCENTAGE
  // =====================================================

  static String percentage(
    num value,
  ) {
    return "${value.toStringAsFixed(0)}%";
  }

  // =====================================================
  // DISCOUNT PERCENTAGE
  // =====================================================

  static int discountPercentage({
    required double originalPrice,
    required double salePrice,
  }) {
    if (originalPrice <= 0) {
      return 0;
    }

    return (((originalPrice - salePrice) /
                originalPrice) *
            100)
        .round();
  }

  // =====================================================
  // PRICE SAVED
  // =====================================================

  static String amountSaved({
    required double originalPrice,
    required double salePrice,
  }) {
    final saved =
        originalPrice - salePrice;

    return format(saved);
  }

  // =====================================================
  // GST CALCULATION
  // =====================================================

  static double calculateGST({
    required double amount,
    required double gstPercentage,
  }) {
    return (amount * gstPercentage) / 100;
  }

  // =====================================================
  // FINAL PRICE
  // =====================================================

  static double finalAmount({
    required double amount,
    required double gst,
    double discount = 0,
    double serviceFee = 0,
    double platformFee = 0,
  }) {
    return amount -
        discount +
        gst +
        serviceFee +
        platformFee;
  }

  // =====================================================
  // FREE TEXT
  // =====================================================

  static String freeOrPrice(
    num amount,
  ) {
    return amount <= 0
        ? "FREE"
        : format(amount);
  }
}