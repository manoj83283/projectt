import 'package:flutter/foundation.dart';

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

  void _notify() {
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
      _notify();
    }
  }

  void _setError(
    Object? value, {
    bool notify = true,
  }) {
    _error = _cleanError(value);

    if (notify) {
      _notify();
    }
  }

  void _clearError({
    bool notify = false,
  }) {
    _error = null;

    if (notify) {
      _notify();
    }
  }

  String? _cleanError(
    Object? value,
  ) {
    if (value == null) {
      return null;
    }

    var message = value.toString().trim();

    const prefixes = <String>[
      'Exception: ',
      'FormatException: ',
      'Invalid argument(s): ',
    ];

    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message
            .substring(prefix.length)
            .trim();
      }
    }

    return message.isEmpty ? null : message;
  }

  void _setAuthenticatedUser(
    UserModel user, {
    bool notify = true,
  }) {
    _user = user;
    _isLoggedIn = true;
    _isInitialized = true;
    _error = null;

    if (notify) {
      _notify();
    }
  }

  void _setAuthenticatedWithoutUser({
    bool notify = true,
  }) {
    _isLoggedIn = true;
    _isInitialized = true;

    if (notify) {
      _notify();
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
    _isInitialized = true;

    if (notify) {
      _notify();
    }
  }

  Future<String?> _restoreToken() async {
    String? token =
        await AuthService.instance.getToken();

    if (token == null ||
        token.trim().isEmpty) {
      await AuthService.instance
          .restoreSession();

      token =
          await AuthService.instance.getToken();
    }

    if (token == null ||
        token.trim().isEmpty) {
      return null;
    }

    ApiService.instance.setAuthToken(
      token,
    );

    return token;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_isLoading) {
      return false;
    }

    final normalizedEmail =
        email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      _setError(
        'Email is required.',
      );

      return false;
    }

    if (password.trim().isEmpty) {
      _setError(
        'Password is required.',
      );

      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      debugPrint(
        'STARTING CUSTOMER LOGIN',
      );

      final user =
          await _repository.login(
        email: normalizedEmail,
        password: password,
      );

      final token =
          await AuthService.instance
              .getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Customer login succeeded, but the authentication token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      if (!ApiService.instance.hasAuthToken) {
        throw Exception(
          'Customer authentication could not be attached to API requests.',
        );
      }

      _setAuthenticatedUser(
        user,
        notify: false,
      );

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
        'CUSTOMER AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      _notify();

      return true;
    } catch (error) {
      debugPrint(
        'CUSTOMER LOGIN ERROR: $error',
      );

      final savedToken =
          await AuthService.instance
              .getToken();

      if (savedToken != null &&
          savedToken.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          savedToken,
        );

        _isLoggedIn = true;
      } else {
        _setUnauthenticated(
          notify: false,
        );
      }

      _setError(
        error,
        notify: false,
      );

      _isInitialized = true;
      _notify();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    if (_isLoading) {
      return false;
    }

    final normalizedName =
        fullName.trim();

    final normalizedEmail =
        email.trim().toLowerCase();

    final normalizedMobile =
        mobile.trim();

    if (normalizedName.isEmpty) {
      _setError(
        'Customer name is required.',
      );

      return false;
    }

    if (normalizedEmail.isEmpty) {
      _setError(
        'Email is required.',
      );

      return false;
    }

    if (normalizedMobile.isEmpty) {
      _setError(
        'Mobile number is required.',
      );

      return false;
    }

    if (password.trim().isEmpty) {
      _setError(
        'Password is required.',
      );

      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final user =
          await _repository.register(
        fullName: normalizedName,
        email: normalizedEmail,
        mobile: normalizedMobile,
        password: password,
      );

      final token =
          await AuthService.instance
              .getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Registration succeeded, but the Customer authentication token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      if (!ApiService.instance.hasAuthToken) {
        throw Exception(
          'The Customer authentication header could not be attached.',
        );
      }

      _setAuthenticatedUser(
        user,
        notify: false,
      );

      debugPrint(
        'CUSTOMER REGISTRATION SUCCESS',
      );

      debugPrint(
        'CUSTOMER AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      _notify();

      return true;
    } catch (error) {
      debugPrint(
        'CUSTOMER REGISTRATION ERROR: $error',
      );

      _setError(
        error,
        notify: false,
      );

      final savedToken =
          await AuthService.instance
              .getToken();

      if (savedToken != null &&
          savedToken.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          savedToken,
        );

        _isLoggedIn = true;
      } else {
        _setUnauthenticated(
          notify: false,
        );
      }

      _isInitialized = true;
      _notify();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> googleLogin({
    String? idToken,
    String? accessToken,
    String? email,
    String? name,
  }) async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final user =
          await _repository.googleLogin(
        idToken: idToken,
        accessToken: accessToken,
        email: email,
        name: name,
      );

      final token =
          await AuthService.instance
              .getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'Google login succeeded, but the Customer authentication token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      _setAuthenticatedUser(
        user,
        notify: false,
      );

      debugPrint(
        'GOOGLE LOGIN SUCCESS',
      );

      debugPrint(
        'GOOGLE AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      _notify();

      return true;
    } catch (error) {
      debugPrint(
        'GOOGLE LOGIN ERROR: $error',
      );

      _setError(
        error,
        notify: false,
      );

      final savedToken =
          await AuthService.instance
              .getToken();

      if (savedToken != null &&
          savedToken.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          savedToken,
        );

        _isLoggedIn = true;
      } else {
        _setUnauthenticated(
          notify: false,
        );
      }

      _isInitialized = true;
      _notify();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendOtp(
    String mobile,
  ) async {
    if (_isLoading) {
      return false;
    }

    final normalizedMobile =
        mobile.trim();

    if (normalizedMobile.isEmpty) {
      _setError(
        'Mobile number is required.',
      );

      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      return await _repository.sendOtp(
        normalizedMobile,
      );
    } catch (error) {
      debugPrint(
        'SEND OTP ERROR: $error',
      );

      _setError(
        error,
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

    final normalizedMobile =
        mobile.trim();

    final normalizedOtp =
        otp.trim();

    if (normalizedMobile.isEmpty) {
      _setError(
        'Mobile number is required.',
      );

      return false;
    }

    if (normalizedOtp.isEmpty) {
      _setError(
        'OTP is required.',
      );

      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final user =
          await _repository.verifyOtp(
        mobile: normalizedMobile,
        otp: normalizedOtp,
      );

      final token =
          await AuthService.instance
              .getToken();

      if (token == null ||
          token.trim().isEmpty) {
        throw Exception(
          'OTP verification succeeded, but the authentication token was not saved.',
        );
      }

      ApiService.instance.setAuthToken(
        token,
      );

      _setAuthenticatedUser(
        user,
        notify: false,
      );

      _notify();

      return true;
    } catch (error) {
      debugPrint(
        'VERIFY OTP ERROR: $error',
      );

      _setError(
        error,
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(
    String email,
  ) async {
    if (_isLoading) {
      return false;
    }

    final normalizedEmail =
        email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      _setError(
        'Email is required.',
      );

      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      return await _repository
          .forgotPassword(
        normalizedEmail,
      );
    } catch (error) {
      debugPrint(
        'FORGOT PASSWORD ERROR: $error',
      );

      _setError(
        error,
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

    if (token.trim().isEmpty) {
      _setError(
        'Reset token is required.',
      );

      return false;
    }

    if (password.trim().isEmpty) {
      _setError(
        'Password is required.',
      );

      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      return await _repository
          .resetPassword(
        token: token.trim(),
        password: password,
      );
    } catch (error) {
      debugPrint(
        'RESET PASSWORD ERROR: $error',
      );

      _setError(
        error,
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getProfile() async {
    try {
      final token =
          await _restoreToken();

      if (token == null) {
        _setUnauthenticated(
          notify: false,
        );

        _setError(
          'Please sign in to view your profile.',
          notify: false,
        );

        _notify();

        return;
      }

      final profile =
          await _repository.getProfile();

      _setAuthenticatedUser(
        profile,
      );

      debugPrint(
        'CUSTOMER PROFILE LOADED',
      );
    } catch (error) {
      debugPrint(
        'CUSTOMER PROFILE ERROR: $error',
      );

      final token =
          await AuthService.instance
              .getToken();

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
        error,
        notify: false,
      );

      _notify();
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

      final token =
          await AuthService.instance
              .ensureAuthenticated();

      ApiService.instance.setAuthToken(
        token,
      );

      final profile =
          await _repository.updateProfile(
        data: data,
      );

      _setAuthenticatedUser(
        profile,
        notify: false,
      );

      _notify();

      return true;
    } catch (error) {
      debugPrint(
        'UPDATE PROFILE ERROR: $error',
      );

      _setError(
        error,
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkAuth() async {
    if (_isCheckingAuth) {
      return;
    }

    _isCheckingAuth = true;

    try {
      _clearError();

      debugPrint(
        'STARTING CUSTOMER SESSION RESTORE',
      );

      final restored =
          await _repository.restoreSession();

      final token =
          await _repository.getToken();

      if ((!restored &&
              (token == null ||
                  token.trim().isEmpty)) ||
          token == null ||
          token.trim().isEmpty) {
        _setUnauthenticated(
          notify: false,
        );

        debugPrint(
          'NO CUSTOMER SESSION AVAILABLE',
        );

        return;
      }

      ApiService.instance.setAuthToken(
        token,
      );

      if (!ApiService.instance.hasAuthToken) {
        _setUnauthenticated(
          notify: false,
        );

        _setError(
          'Unable to attach Customer authentication.',
          notify: false,
        );

        return;
      }

      _user =
          AuthService.instance.currentUser;

      _setAuthenticatedWithoutUser(
        notify: false,
      );

      debugPrint(
        'CUSTOMER TOKEN SESSION RESTORED',
      );

      debugPrint(
        'CUSTOMER AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      try {
        final profile =
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

        _isLoggedIn = true;

        _user ??=
            AuthService.instance.currentUser;
      }
    } catch (error) {
      debugPrint(
        'CUSTOMER AUTH CHECK ERROR: $error',
      );

      final token =
          await AuthService.instance
              .getToken();

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
        error,
        notify: false,
      );
    } finally {
      _isCheckingAuth = false;
      _isInitialized = true;
      _notify();
    }
  }

  Future<bool>
      validateBookingSession() async {
    try {
      final token =
          await _restoreToken();

      if (token == null ||
          token.trim().isEmpty) {
        _setUnauthenticated(
          notify: false,
        );

        _notify();

        debugPrint(
          'BOOKING SESSION VALIDATION FAILED: '
          'TOKEN MISSING',
        );

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
      _isInitialized = true;

      _user ??=
          AuthService.instance.currentUser;

      debugPrint(
        'BOOKING SESSION VALIDATION SUCCESS',
      );

      debugPrint(
        'BOOKING AUTH HEADER AVAILABLE: '
        '${ApiService.instance.hasAuthToken}',
      );

      _notify();

      return true;
    } catch (error) {
      debugPrint(
        'BOOKING SESSION VALIDATION ERROR: '
        '$error',
      );

      return false;
    }
  }

  Future<bool> refreshCustomer() async {
    try {
      final token =
          await AuthService.instance
              .ensureAuthenticated();

      ApiService.instance.setAuthToken(
        token,
      );

      final profile =
          await _repository.getProfile();

      _setAuthenticatedUser(
        profile,
      );

      return true;
    } catch (error) {
      debugPrint(
        'REFRESH CUSTOMER ERROR: $error',
      );

      final token =
          await AuthService.instance
              .getToken();

      if (token != null &&
          token.trim().isNotEmpty) {
        ApiService.instance.setAuthToken(
          token,
        );

        _isLoggedIn = true;
        _isInitialized = true;
        _notify();
      }

      return false;
    }
  }

  Future<void> logout() async {
    if (_isLoading) {
      return;
    }

    try {
      _setLoading(true);

      await _repository.logout();
    } catch (error) {
      debugPrint(
        'CUSTOMER LOGOUT ERROR: $error',
      );

      await AuthService.instance
          .clearLocalAuth();
    } finally {
      _user = null;
      _isLoggedIn = false;
      _isInitialized = true;
      _error = null;

      _setLoading(
        false,
        notify: false,
      );

      _notify();
    }
  }

  Future<bool> deleteAccount() async {
    if (_isLoading) {
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final success =
          await _repository
              .deleteAccount();

      if (success) {
        _user = null;
        _isLoggedIn = false;
        _isInitialized = true;

        await AuthService.instance
            .clearLocalAuth();
      }

      _notify();

      return success;
    } catch (error) {
      debugPrint(
        'DELETE CUSTOMER ACCOUNT ERROR: '
        '$error',
      );

      _setError(
        error,
        notify: false,
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  void setUser(
    UserModel? user,
  ) {
    _user = user;
    _isLoggedIn = user != null ||
        AuthService.instance.hasToken;
    _isInitialized = true;

    _notify();
  }

  void clearError() {
    _clearError(
      notify: true,
    );
  }
}