class Validators {
  Validators._();

  // =====================================================
  // REQUIRED FIELD
  // =====================================================

  static String? requiredField(
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
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$';

    if (!RegExp(pattern)
        .hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // =====================================================
  // PHONE NUMBER
  // =====================================================

  static String? phone(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Phone number is required';
    }

    if (!RegExp(r'^[0-9]{10}$')
        .hasMatch(value.trim())) {
      return 'Enter a valid 10 digit mobile number';
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
  // STRONG PASSWORD
  // =====================================================

  static String? strongPassword(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return 'Password is required';
    }

    final pattern = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
    );

    if (!pattern.hasMatch(value)) {
      return '''
Password must contain:
• 1 uppercase letter
• 1 lowercase letter
• 1 number
• 1 special character
• Minimum 8 characters
''';
    }

    return null;
  }

  // =====================================================
  // CONFIRM PASSWORD
  // =====================================================

  static String? confirmPassword(
    String? password,
    String? confirmPassword,
  ) {
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
      return 'Enter valid 6 digit OTP';
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
  // BUSINESS NAME
  // =====================================================

  static String? businessName(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Business name is required';
    }

    if (value.trim().length < 3) {
      return 'Business name is too short';
    }

    return null;
  }

  // =====================================================
  // ADDRESS
  // =====================================================

  static String? address(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.trim().length < 10) {
      return 'Enter complete address';
    }

    return null;
  }

  // =====================================================
  // DESCRIPTION
  // =====================================================

  static String? description(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Description is required';
    }

    if (value.trim().length < 20) {
      return 'Description should contain at least 20 characters';
    }

    return null;
  }

  // =====================================================
  // PRICE
  // =====================================================

  static String? price(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Price is required';
    }

    final amount =
        double.tryParse(value);

    if (amount == null ||
        amount <= 0) {
      return 'Enter valid amount';
    }

    return null;
  }

  // =====================================================
  // SERVICE PRICE
  // =====================================================

  static String? servicePrice(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Service price is required';
    }

    final amount =
        double.tryParse(value);

    if (amount == null ||
        amount < 100) {
      return 'Minimum price should be ₹100';
    }

    return null;
  }

  // =====================================================
  // EXPERIENCE
  // =====================================================

  static String? experience(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Experience is required';
    }

    final years =
        int.tryParse(value);

    if (years == null ||
        years < 0) {
      return 'Enter valid experience';
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
        value.trim().isEmpty) {
      return null;
    }

    final uri =
        Uri.tryParse(value.trim());

    if (uri == null ||
        !uri.hasAbsolutePath) {
      return 'Enter valid URL';
    }

    return null;
  }

  // =====================================================
  // PAN CARD
  // =====================================================

  static String? panNumber(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'PAN number is required';
    }

    if (!RegExp(
      r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$',
    ).hasMatch(
      value.trim().toUpperCase(),
    )) {
      return 'Enter valid PAN number';
    }

    return null;
  }

  // =====================================================
  // GST NUMBER
  // =====================================================

  static String? gstNumber(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'GST number is required';
    }

    if (!RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[A-Z0-9]{3}$',
    ).hasMatch(
      value.trim().toUpperCase(),
    )) {
      return 'Enter valid GST number';
    }

    return null;
  }

  // =====================================================
  // PINCODE
  // =====================================================

  static String? pinCode(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Pincode is required';
    }

    if (!RegExp(r'^[0-9]{6}$')
        .hasMatch(value.trim())) {
      return 'Enter valid 6 digit pincode';
    }

    return null;
  }

  // =====================================================
  // BANK ACCOUNT
  // =====================================================

  static String? bankAccount(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Bank account number is required';
    }

    if (value.length < 9) {
      return 'Enter valid account number';
    }

    return null;
  }

  // =====================================================
  // IFSC CODE
  // =====================================================

  static String? ifscCode(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'IFSC Code is required';
    }

    if (!RegExp(
      r'^[A-Z]{4}0[A-Z0-9]{6}$',
    ).hasMatch(
      value.trim().toUpperCase(),
    )) {
      return 'Enter valid IFSC Code';
    }

    return null;
  }
}