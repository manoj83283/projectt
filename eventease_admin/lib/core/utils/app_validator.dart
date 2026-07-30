class AppValidator {
  AppValidator._();

  // =====================================================
  // REQUIRED
  // =====================================================

  static String? required(
    String? value, {
    String fieldName = 'Field',
  }) {
    if (value == null ||
        value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // =====================================================
  // EMAIL
  // =====================================================

  static String? email(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Email is required';
    }

    const pattern =
        r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$';

    if (!RegExp(pattern)
        .hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // =====================================================
  // PASSWORD
  // =====================================================

  static String? password(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  // =====================================================
  // CONFIRM PASSWORD
  // =====================================================

  static String? confirmPassword({
    required String? password,
    required String? confirmPassword,
  }) {
    if (confirmPassword == null ||
        confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // =====================================================
  // PHONE
  // =====================================================

  static String? phone(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Phone number is required';
    }

    if (!RegExp(
      r'^[0-9]{10}$',
    ).hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // =====================================================
  // OTP
  // =====================================================

  static String? otp(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }

    return null;
  }

  // =====================================================
  // NAME
  // =====================================================

  static String? name(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null;
  }

  // =====================================================
  // AMOUNT
  // =====================================================

  static String? amount(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Amount is required';
    }

    final amount =
        double.tryParse(value);

    if (amount == null) {
      return 'Enter a valid amount';
    }

    if (amount < 0) {
      return 'Amount cannot be negative';
    }

    return null;
  }

  // =====================================================
  // URL
  // =====================================================

  static String? url(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'URL is required';
    }

    final uri =
        Uri.tryParse(value);

    if (uri == null ||
        !uri.hasAbsolutePath) {
      return 'Enter a valid URL';
    }

    return null;
  }

  // =====================================================
  // PINCODE
  // =====================================================

  static String? pincode(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Pincode is required';
    }

    if (!RegExp(
      r'^[0-9]{6}$',
    ).hasMatch(value)) {
      return 'Enter a valid pincode';
    }

    return null;
  }

  // =====================================================
  // DROPDOWN
  // =====================================================

  static String? dropdown(
    dynamic value, {
    String fieldName = 'Selection',
  }) {
    if (value == null) {
      return '$fieldName is required';
    }

    return null;
  }

  // =====================================================
  // MIN LENGTH
  // =====================================================

  static String? minLength(
    String? value, {
    required int length,
    required String fieldName,
  }) {
    if (value == null ||
        value.length < length) {
      return '$fieldName must be at least $length characters';
    }

    return null;
  }

  // =====================================================
  // MAX LENGTH
  // =====================================================

  static String? maxLength(
    String? value, {
    required int length,
    required String fieldName,
  }) {
    if (value != null &&
        value.length > length) {
      return '$fieldName cannot exceed $length characters';
    }

    return null;
  }
}