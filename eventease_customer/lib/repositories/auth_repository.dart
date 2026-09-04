import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  final AuthRepository _repository =
      AuthRepository.instance;

  UserModel? _user;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  bool _isCheckingAuth = false;

  String? _error;

  // =====================================================
  // GETTERS
  // =====================================================

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  bool get isLoggedIn => _isLoggedIn;

  bool get isInitialized => _isInitialized;

  bool get isCheckingAuth => _isCheckingAuth;

  String? get error => _error;

  bool get hasUser => _user != null;

  bool get hasAuthenticatedSession {
    return _isLoggedIn &&
        AuthService.instance.hasToken &&
        ApiService.instance.hasAuthToken;
  }

  // =====================================================
  // INTERNAL HELPERS
  // =====================================================

  void _notifySafely() {
    notifyListeners();
  }

  void _setLoading(
    bool value, {
    bool notify = true,
  }) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    if (notify) {
      _notifySafely();
    }
  }

  void _setError(
    String? value, {
    bool notify = true,
  }) {
    _error = _cleanError(value);

    if (notify) {
      _notifySafely();
    }
  }

  void _clearError({
    bool notify = false,
  }) {
    _error = null;

    if (notify) {
      _notifySafely();
    }
  }

  String? _cleanError(
    String? value,
  ) {
    if (value == null) {
      return null;
    }

    String message = value.trim();

    if (message.startsWith('Exception: ')) {
      message = message.substring(
        'Exception: '.length,
      );
    }

    return message.trim().isEmpty
        ? null
        : message.trim();
  }

  void _setAuthenticatedUser(
    UserModel user, {
    bool notify = true,
  }) {
    _user = user;
    _isLoggedIn = true;
    _error = null;

    if (notify) {
      _notifySafely();
    }
  }

  void _setAuthenticatedWithoutUser({
    bool notify = true,
  }) {
    /*
     * A valid JWT is enough to keep the customer signed in.
     *
     * The profile may be temporarily unavailable due to:
     *
     * 1. Backend startup delay
     * 2. Temporary network problem
     * 3. Incorrect profile route
     * 4. Server error
     *
     * None of those conditions should destroy the customer
     * session or redirect the customer to Sign In.
     */
    _isLoggedIn = true;

    if (notify) {
      _notifySafely();
    }
  }

  void _setUnauthenticated({
    bool clearUser = true,
    bool notify = true,
  }) {
    if (clearUser) {
      _user = null;
    }

    _isLoggedIn = false;

    if (notify) {
      _notifySafely();
    }
  }

  // =====================================================
  // LOGIN
  // =====================================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final String normalizedEmail =
          email.trim().toLowerCase();

      if (normalizedEmail.isEmpty) {
        throw ArgumentError(
          'Email is required.',
        );
      }

      if (password.trim().isEmpty) {
        throw ArgumentError(
          'Password is required.',
        );
      }

      final UserModel user =
          await _repository.login(
        email: normalizedEmail,
        password: password,
      );

      /*
       * Confirm that login actually persisted a token.
       */
      final String? token =
          await AuthService.instance.getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Customer sign-in completed, but the authentication '
          'token was not saved. Please try again.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      if (!ApiService.instance.hasAuthToken) {
        throw Exception(
          'Customer sign-in completed, but authentication '
          'could not be attached to API requests.',
        );
      }

      _setAuthenticatedUser(
        user,
        notify: false,
      );

      _isInitialized = true;

      debugPrint(
        'CUSTOMER LOGIN SUCCESS',
      );

      debugPrint(
        'CUSTOMER USER ID: ${user.id}',
      );

      debugPrint(
        'CUSTOMER TOKEN AVAILABLE: true',
      );

      debugPrint(
        'CUSTOMER API AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      _notifySafely();

      return true;
    } catch (error) {
      debugPrint(
        'CUSTOMER LOGIN ERROR: $error',
      );

      /*
       * Do not delete an existing valid session when a new
       * login attempt fails because of a network error.
       */
      final String? existingToken =
          await AuthService.instance.getToken();

      if (existingToken != null &&
          existingToken.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          existingToken,
        );

        _isLoggedIn = true;
      } else {
        _setUnauthenticated(
          notify: false,
        );
      }

      _setError(
        error.toString(),
        notify: false,
      );

      _isInitialized = true;
      _notifySafely();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REGISTER
  // =====================================================

  Future<bool> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final String normalizedName =
          fullName.trim();

      final String normalizedEmail =
          email.trim().toLowerCase();

      final String normalizedMobile =
          mobile.trim();

      if (normalizedName.isEmpty) {
        throw ArgumentError(
          'Customer name is required.',
        );
      }

      if (normalizedEmail.isEmpty) {
        throw ArgumentError(
          'Email is required.',
        );
      }

      if (normalizedMobile.isEmpty) {
        throw ArgumentError(
          'Mobile number is required.',
        );
      }

      if (password.trim().isEmpty) {
        throw ArgumentError(
          'Password is required.',
        );
      }

      final UserModel user =
          await _repository.register(
        fullName: normalizedName,
        email: normalizedEmail,
        mobile: normalizedMobile,
        password: password,
      );

      final String? token =
          await AuthService.instance.getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Customer registration completed, but the '
          'authentication token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      _setAuthenticatedUser(
        user,
        notify: false,
      );

      _isInitialized = true;

      debugPrint(
        'CUSTOMER REGISTRATION SUCCESS',
      );

      debugPrint(
        'CUSTOMER API AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      _notifySafely();

      return true;
    } catch (error) {
      debugPrint(
        'CUSTOMER REGISTER ERROR: $error',
      );

      _setError(
        error.toString(),
        notify: false,
      );

      final String? existingToken =
          await AuthService.instance.getToken();

      if (existingToken != null &&
          existingToken.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          existingToken,
        );

        _isLoggedIn = true;
      } else {
        _setUnauthenticated(
          notify: false,
        );
      }

      _isInitialized = true;
      _notifySafely();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GOOGLE LOGIN
  // =====================================================

  Future<bool> googleLogin() async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final UserModel user =
          await _repository.googleLogin();

      final String? token =
          await AuthService.instance.getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Google login completed, but the authentication '
          'token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      _setAuthenticatedUser(
        user,
        notify: false,
      );

      _isInitialized = true;

      debugPrint(
        'GOOGLE LOGIN SUCCESS',
      );

      debugPrint(
        'GOOGLE LOGIN AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      _notifySafely();

      return true;
    } catch (error) {
      debugPrint(
        'GOOGLE LOGIN ERROR: $error',
      );

      _setError(
        error.toString(),
        notify: false,
      );

      final String? existingToken =
          await AuthService.instance.getToken();

      if (existingToken != null &&
          existingToken.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          existingToken,
        );

        _isLoggedIn = true;
      } else {
        _setUnauthenticated(
          notify: false,
        );
      }

      _isInitialized = true;
      _notifySafely();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // OTP
  // =====================================================

  Future<bool> sendOtp(
    String mobile,
  ) async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final String normalizedMobile =
          mobile.trim();

      if (normalizedMobile.isEmpty) {
        throw ArgumentError(
          'Mobile number is required.',
        );
      }

      return await _repository.sendOtp(
        normalizedMobile,
      );
    } catch (error) {
      debugPrint(
        'SEND OTP ERROR: $error',
      );

      _setError(
        error.toString(),
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final UserModel user =
          await _repository.verifyOtp(
        mobile: mobile.trim(),
        otp: otp.trim(),
      );

      final String? token =
          await AuthService.instance.getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'OTP verification completed, but the customer '
          'authentication token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      _setAuthenticatedUser(
        user,
        notify: false,
      );

      _isInitialized = true;
      _notifySafely();

      return true;
    } catch (error) {
      debugPrint(
        'VERIFY OTP ERROR: $error',
      );

      _setError(
        error.toString(),
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // PASSWORD
  // =====================================================

  Future<bool> forgotPassword(
    String email,
  ) async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      return await _repository.forgotPassword(
        email.trim().toLowerCase(),
      );
    } catch (error) {
      debugPrint(
        'FORGOT PASSWORD ERROR: $error',
      );

      _setError(
        error.toString(),
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      return await _repository.resetPassword(
        token: token.trim(),
        password: password,
      );
    } catch (error) {
      debugPrint(
        'RESET PASSWORD ERROR: $error',
      );

      _setError(
        error.toString(),
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // PROFILE
  // =====================================================

  Future<void> getProfile() async {
    if (_isLoading) {
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      final String? token =
          await AuthService.instance.getToken();

      if (token == null ||
          token.trim().isEmpty) {
        _setUnauthenticated(
          notify: false,
        );

        _setError(
          'Please sign in to view your profile.',
          notify: false,
        );

        _notifySafely();
        return;
      }

      ApiService.instance.setAuthToken(
        token,
      );

      final UserModel profile =
          await _repository.getProfile();

      _setAuthenticatedUser(
        profile,
        notify: false,
      );

      debugPrint(
        'CUSTOMER PROFILE LOADED',
      );

      _notifySafely();
    } catch (error) {
      debugPrint(
        'CUSTOMER PROFILE ERROR: $error',
      );

      /*
       * Do not mark the customer as logged out just because
       * the profile endpoint failed.
       */
      final String? token =
          await AuthService.instance.getToken();

      if (token != null &&
          token.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          token,
        );

        _setAuthenticatedWithoutUser(
          notify: false,
        );
      } else {
        _setUnauthenticated(
          notify: false,
        );
      }

      _setError(
        error.toString(),
        notify: false,
      );

      _notifySafely();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final String token =
          await AuthService.instance
              .ensureAuthenticated();

      ApiService.instance.setAuthToken(
        token,
      );

      final UserModel profile =
          await _repository.updateProfile(
        data: data,
      );

      _setAuthenticatedUser(
        profile,
        notify: false,
      );

      _notifySafely();

      return true;
    } catch (error) {
      debugPrint(
        'UPDATE PROFILE ERROR: $error',
      );

      _setError(
        error.toString(),
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // RESTORE AUTH
  // =====================================================

  Future<void> checkAuth() async {
    if (_isCheckingAuth) {
      return;
    }

    _isCheckingAuth = true;

    try {
      _setLoading(true);
      _clearError();

      debugPrint(
        'STARTING CUSTOMER SESSION RESTORE',
      );

      /*
       * Restore the token directly through AuthService.
       *
       * Do not depend only on AuthRepository.isLoggedIn()
       * because the API header must also be restored.
       */
      bool restored =
          await AuthService.instance.restoreSession();

      String? token =
          await AuthService.instance.getToken();

      /*
       * restoreSession can return false during an initialization
       * timing problem, but the token may still be available.
       */
      if (!restored &&
          token != null &&
          token.trim().isNotEmpty) {
        restored = true;
      }

      if (!restored ||
          token == null ||
          token.trim().isEmpty) {
        debugPrint(
          'NO CUSTOMER SESSION AVAILABLE',
        );

        _setUnauthenticated(
          notify: false,
        );

        _isInitialized = true;
        _notifySafely();
        return;
      }

      ApiService.instance.setAuthToken(
        token,
      );

      if (!ApiService.instance.hasAuthToken) {
        debugPrint(
          'CUSTOMER TOKEN EXISTS BUT API HEADER IS MISSING',
        );

        _setUnauthenticated(
          notify: false,
        );

        _setError(
          'Unable to restore customer authentication.',
          notify: false,
        );

        _isInitialized = true;
        _notifySafely();
        return;
      }

      /*
       * A valid saved token is enough to restore the session.
       * Do not wait for profile loading to mark the customer
       * as authenticated.
       */
      _setAuthenticatedWithoutUser(
        notify: false,
      );

      _user = AuthService.instance.currentUser;

      debugPrint(
        'CUSTOMER TOKEN SESSION RESTORED',
      );

      debugPrint(
        'CUSTOMER AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      /*
       * Profile loading is optional for session restoration.
       * A failure here must not send the user to Sign In.
       */
      try {
        final UserModel profile =
            await _repository.getProfile();

        _setAuthenticatedUser(
          profile,
          notify: false,
        );

        debugPrint(
          'CUSTOMER PROFILE SESSION RESTORED',
        );

        debugPrint(
          'CUSTOMER EMAIL: ${profile.email}',
        );
      } catch (profileError) {
        debugPrint(
          'CUSTOMER PROFILE RESTORE FAILED: '
          '$profileError',
        );

        /*
         * Keep logged in because the JWT exists.
         */
        _isLoggedIn = true;

        _user ??=
            AuthService.instance.currentUser;

        _setError(
          profileError.toString(),
          notify: false,
        );
      }

      _isInitialized = true;
      _notifySafely();
    } catch (error) {
      debugPrint(
        'CUSTOMER AUTH CHECK ERROR: $error',
      );

      /*
       * Final fallback: check local token before marking the
       * customer as signed out.
       */
      final String? token =
          await AuthService.instance.getToken();

      if (token != null &&
          token.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          token,
        );

        _isLoggedIn = true;
        _user ??=
            AuthService.instance.currentUser;

        debugPrint(
          'CUSTOMER SESSION KEPT USING SAVED TOKEN',
        );
      } else {
        _setUnauthenticated(
          notify: false,
        );
      }

      _setError(
        error.toString(),
        notify: false,
      );

      _isInitialized = true;
      _notifySafely();
    } finally {
      _isCheckingAuth = false;
      _setLoading(false);
    }
  }

  // =====================================================
  // VALIDATE SESSION FOR BOOKING
  // =====================================================

  Future<bool> validateBookingSession() async {
    try {
      String? token =
          await AuthService.instance.getToken();

      if (token == null ||
          token.trim().isEmpty) {
        await AuthService.instance.restoreSession();

        token =
            await AuthService.instance.getToken();
      }

      if (token == null ||
          token.trim().isEmpty) {
        debugPrint(
          'BOOKING SESSION VALIDATION FAILED: '
          'TOKEN MISSING',
        );

        _setUnauthenticated(
          notify: false,
        );

        _notifySafely();

        return false;
      }

      ApiService.instance.setAuthToken(
        token,
      );

      if (!ApiService.instance.hasAuthToken) {
        debugPrint(
          'BOOKING SESSION VALIDATION FAILED: '
          'AUTH HEADER MISSING',
        );

        return false;
      }

      _isLoggedIn = true;

      _user ??=
          AuthService.instance.currentUser;

      debugPrint(
        'BOOKING SESSION VALIDATION SUCCESS',
      );

      debugPrint(
        'BOOKING AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      _notifySafely();

      return true;
    } catch (error) {
      debugPrint(
        'BOOKING SESSION VALIDATION ERROR: $error',
      );

      return false;
    }
  }

  // =====================================================
  // REFRESH CUSTOMER
  // =====================================================

  Future<bool> refreshCustomer() async {
    try {
      final String token =
          await AuthService.instance
              .ensureAuthenticated();

      ApiService.instance.setAuthToken(
        token,
      );

      final UserModel profile =
          await _repository.getProfile();

      _setAuthenticatedUser(profile);

      return true;
    } catch (error) {
      debugPrint(
        'REFRESH CUSTOMER ERROR: $error',
      );

      /*
       * Keep session active if a token still exists.
       */
      final String? token =
          await AuthService.instance.getToken();

      if (token != null &&
          token.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          token,
        );

        _isLoggedIn = true;
        _notifySafely();
      }

      return false;
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    if (_isLoading) {
      return;
    }

    try {
      _setLoading(true);

      await _repository.logout();
    } catch (error) {
      debugPrint(
        'CUSTOMER BACKEND LOGOUT ERROR: $error',
      );

      /*
       * Local authentication must still be cleared when the
       * customer explicitly presses Logout.
       */
      await AuthService.instance.clearLocalAuth();
    } finally {
      _user = null;
      _isLoggedIn = false;
      _isInitialized = true;
      _error = null;

      _notifySafely();
      _setLoading(false);
    }
  }

  // =====================================================
  // DELETE ACCOUNT
  // =====================================================

  Future<bool> deleteAccount() async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final bool success =
          await _repository.deleteAccount();

      if (success) {
        _user = null;
        _isLoggedIn = false;

        await AuthService.instance
            .clearLocalAuth();
      }

      _notifySafely();

      return success;
    } catch (error) {
      debugPrint(
        'DELETE CUSTOMER ACCOUNT ERROR: $error',
      );

      _setError(
        error.toString(),
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // MANUAL USER SYNC
  // =====================================================

  void setUser(
    UserModel? user,
  ) {
    _user = user;

    if (user != null) {
      _isLoggedIn = true;
    }

    _notifySafely();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _clearError(
      notify: true,
    );
  }
}