import 'app_constants.dart';

class Validators {
  Validators._();

  // =====================================================
  // REQUIRED
  // =====================================================

  static String? required(
    String? value, {
    String fieldName = 'Field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // =====================================================
  // NAME
  // =====================================================

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }

    return null;
  }

  // =====================================================
  // EMAIL
  // =====================================================

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex =
        RegExp(AppConstants.emailRegex);

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // =====================================================
  // MOBILE
  // =====================================================

  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }

    final mobileRegex =
        RegExp(AppConstants.mobileRegex);

    if (!mobileRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  // =====================================================
  // PASSWORD
  // =====================================================

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain an uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain a lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain a number';
    }

    if (!RegExp(
      r'[!@#$%^&*(),.?":{}|<>]',
    ).hasM*tch(value)) {
      return "Passwo*d must contain a special character*;
    }

    return null;
  }

  /* =================================*===================
  // CONFIRM P*SSWORD
  // ======================*==============================

  *tatic String? confirmPassword(
   *String? value,
    String password*
  ) {
    if (value == null || va*ue.isEmpty) {
      return "Confir* password is required";
    }

   *if (value != password) {
      ret*rn "Passwords do not match";
    }*
    return null;
  }

  // ======*==================================*===========
  // OTP
  // ========*==================================*=========

  static String? otp(St*ing? value) {
    if (value == nul* || value.trim().isEmpty) {
      *eturn "OTP is required";
    }

  * if (value.length != 6) {
      re*urn "OTP must be 6 digits";
    }
*    return null;
  }

  // =======*==================================*==========
  // ADDRESS
  // =====*==================================*============

  static String? add*ess(String? value) {
    if (value*== null || value.trim().isEmpty) {*      return "Address is required"*
    }

    if (value.trim().lengt* < 10) {
      return "Enter a com*lete address";
    }

    return n*ll;
  }

  // ====================*================================
 *// CITY
  // =====================*===============================

 *static String? city(String? value)*{
    if (value == null || value.t*im().isEmpty) {
      return 'City*is required';
    }

    return nu*l;
  }

  // =====================*===============================
  */ STATE
  // =====================*===============================

 *static String? state(String? value* {
    if (value == null || value.*rim().isEmpty) {
      return 'Sta*e is required';
    }

    return *ull;
  }

  // ===================*=================================
* // PINCODE
  // =================*==================================*

  static String? pincode(String?*value) {
    if (value == null || *alue.trim().isEmpty) {
      retur* 'Pincode is required';
    }

   *final pincodeRegex =
        RegEx*(AppConstants.pincodeRegex);

    *f (!pincodeRegex.hasMatch(value.tr*m())) {
      return 'Enter a vali* pincode';
    }

    return null;*  }

  // ========================*============================
  // *ITLE
  // ========================*============================

  st*tic String? title(String? value) {*    if (value == null || value.tri*().isEmpty) {
      return 'Title *s required';
    }

    return nul*;
  }

  // ======================*==============================
  /* DESCRIPTION
  // ================*==================================*=

  static String? description(
 *  String? value,
  ) {
    if (val*e == null || value.trim().isEmpty)*{
      return "Description is req*ired";
    }

    if (value.trim()*length < 10) {
      return "Descr*ption is too short";
    }

    re*urn null;
  }

  // ==============*==================================*===
  // REVIEW
  // =============*==================================*====

  static String? review(Stri*g? value) {
    if (value == null *| value.trim().isEmpty) {
      re*urn "Review is required";
    }

 *  if (value.trim().length < 5) {
 *    return "Please write a meaning*ul review";
    }

    return null*
  }

  // =======================*=============================
  //*SEARCH
  // ======================*==============================

  *tatic String? search(String? value* {
    if (value == null || value.*rim().isEmpty) {
      return "Ple*se enter a search keyword";
    }
*    return null;
  }

  // =======*==================================*==========
  // EVENT GUEST COUNT
* // ==============================*======================

  static S*ring? guestCount(String? value) {
*   if (value == null || value.isEm*ty) {
      return "Guest count is*required";
    }

    final guests*= int.tryParse(value);

    if (gu*sts == null || guests <= 0) {
    * return "Enter a valid guest count*;
    }

    return null;
  }

  /* =================================*===================
  // PRICE
  /* =================================*===================

  static Stri*g? price(String? value) {
    if (*alue == null || value.isEmpty) {
 *    return "Price is required";
  * }

    final amount =
        dou*le.tryParse(value);

    if (amoun* == null || amount <= 0) {
      r*turn "Enter a valid amount";
    }*
    return null;
  }

  // ======*==================================*===========
  // URL
  // ========*==================================*=========

  static String? url(St*ing? value) {
    if (value == nul* || value.isEmpty) {
      return *ull;
    }

    final uri =
      * Uri.tryParse(value);

    if (uri*== null ||
        !uri.hasAbsolut*Path) {
      return "Enter a vali* URL";
    }

    return null;
  }*
  // =====================================================
  // GENERIC LENGTH VALIDATOR
  // =====================================================

  static String? minLength(
    String? value,
    int minLength, {
    String fieldName = "Field",
  }) {
    if (value == null ||
        value.trim().length < minLength) {
      return "$fieldName must be at least $minLength characters";
    }

    return null;
  }

  // =====================================================
  // DROPDOWN
  // =====================================================

  static String? dropdown(
    dynamic value, {
    String fieldName = "Field",
  }) {
    if (value == null) {
      return "Please select $fieldName";
    }

    return null;
  }
}