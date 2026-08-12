extension StringExtensions on String {
  // =====================================================
  // CAPITALIZE FIRST LETTER
  // =====================================================

  String capitalize() {
    if (trim().isEmpty) return this;

    return this[0].toUpperCase() +
        substring(1).toLowerCase();
  }

  // =====================================================
  // TITLE CASE
  // =====================================================

  String toTitleCase() {
    if (trim().isEmpty) return this;

    return split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              word[0].toUpperCase() +
              word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  // =====================================================
  // INITIALS
  // =====================================================

  String initials() {
    if (trim().isEmpty) return '';

    final words = trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .toList();

    if (words.length == 1) {
      return words.first[0].toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'
        .toUpperCase();
  }

  // =====================================================
  // EMAIL VALIDATION
  // =====================================================

  bool get isValidEmail {
    const pattern =
        r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$';

    return RegExp(pattern).hasMatch(trim());
  }

  // =====================================================
  // MOBILE VALIDATION (INDIA)
  // =====================================================

  bool get isValidMobile {
    return RegExp(
      r'^[6-9]\d{9}$',
    ).hasMatch(trim());
  }

  // =====================================================
  // URL VALIDATION
  // =====================================================

  bool get isValidUrl {
    final uri = Uri.tryParse(this);

    return uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty;
  }

  // =====================================================
  // NUMERIC CHECK
  // =====================================================

  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  // =====================================================
  // PARSE INT
  // =====================================================

  int toInt({
    int defaultValue = 0,
  }) {
    return int.tryParse(trim()) ??
        defaultValue;
  }

  // =====================================================
  // PARSE DOUBLE
  // =====================================================

  double toDouble({
    double defaultValue = 0.0,
  }) {
    return double.tryParse(trim()) ??
        defaultValue;
  }

  // =====================================================
  // REMOVE EXTRA SPACES
  // =====================================================

  String removeExtraSpaces() {
    return trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }

  // =====================================================
  // REVERSE STRING
  // =====================================================

  String reverse() {
    return split('')
        .reversed
        .join();
  }

  // =====================================================
  // CURRENCY PARSE
  // =====================================================

  double currencyToDouble() {
    return double.tryParse(
          replaceAll('₹', '')
              .replaceAll(',', '')
              .trim(),
        ) ??
        0;
  }

  // =====================================================
  // MASK MOBILE
  // =====================================================

  String maskMobile() {
    if (length < 10) return this;

    return '${substring(0, 2)}******${substring(length - 2)}';
  }

  // =====================================================
  // MASK EMAIL
  // =====================================================

  String maskEmail() {
    if (!contains('@')) return this;

    final parts = split('@');

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return this;
    }

    return '${name.substring(0, 2)}******@$domain';
  }

  // =====================================================
  // TRUNCATE
  // =====================================================

  String truncate(int length) {
    if (this.length <= length) {
      return this;
    }

    return '${substring(0, length)}...';
  }

  // =====================================================
  // CAMEL CASE
  // =====================================================

  String toCamelCase() {
    final words = removeExtraSpaces()
        .split(' ');

    if (words.isEmpty) return this;

    return words.first.toLowerCase() +
        words
            .skip(1)
            .map(
              (e) =>
                  e.capitalize(),
            )
            .join();
  }
}