import 'package:flutter/foundation.dart';

import '../models/provider_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository.instance;

  // =========================
  // STATES
  // =========================

  bool _isLoading = false;
  bool _isLoggedIn = false;

  String? _token;
  String? _errorMessage;

  ProviderModel? _provider;

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  bool get isLoggedIn => _isLoggedIn;

  String? get token => _token;

  String? get errorMessage => _errorMessage;

  ProviderModel? get provider => _provider;

  bool get hasError {
    return _errorMessage != null && _errorMessage!.isNotEmpty;
  }

  bool get hasProvider => _provider != null;

  // =========================
  // SET LOADING
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // =========================
  // SET ERROR
  // =========================

  void _setError(Object error) {
    _errorMessage = error.toString();
    notifyListeners();
  }

  // =========================
  // CLEAR ERROR
  // =========================

  void clearError({
    bool notify = true,
  }) {
    _errorMessage = null;

    if (notify) {
      notifyListeners();
    }
  }

  // =========================
  // LOGIN
  // Backend: /auth/signin
  // =========================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      clearError(notify: false);

      final response = await _repository.login(
        email: email,
        password: password,
      );

      _token = response['token']?.toString();

      _isLoggedIn = _token != null && _token!.isNotEmpty;

      if (_isLoggedIn) {
        await getProfile(notifyError: false);
      }

      notifyListeners();

      return _isLoggedIn;
    } catch (e) {
      _isLoggedIn = false;
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // SIGNUP
  // Standard method going forward
  // Backend: /auth/signup
  // =========================

  Future<bool> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String businessName,
  }) async {
    try {
      _setLoading(true);
      clearError(notify: false);

      final response = await _repository.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        businessName: businessName,
      );

      _token = response['token']?.toString();

      if (_token != null && _token!.isNotEmpty) {
        _isLoggedIn = true;

        try {
          await getProfile(notifyError: false);
        } catch (_) {
          // Sign up succeeded even if profile fetch fails temporarily.
        }
      }

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // REGISTER WRAPPER
  // Backward compatibility for older screen/provider calls
  // =========================

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String businessName,
  }) async {
    return signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
      businessName: businessName,
    );
  }

  // =========================
  // SEND OTP
  // =========================

  Future<bool> sendOtp({
    required String phone,
  }) async {
    try {
      _setLoading(true);
      clearError(notify: false);

      await _repository.sendOtp(
        phone: phone,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // VERIFY OTP
  // =========================

  Future<bool> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      _setLoading(true);
      clearError(notify: false);

      await _repository.verifyOtp(
        phone: phone,
        otp: otp,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================

  Future<bool> forgotPassword({
    required String email,
  }) async {
    try {
      _setLoading(true);
      clearError(notify: false);

      await _repository.forgotPassword(
        email: email,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // RESET PASSWORD
  // =========================

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      _setLoading(true);
      clearError(notify: false);

      await _repository.resetPassword(
        email: email,
        otp: otp,
        password: password,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // CHANGE PASSWORD
  // =========================

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      clearError(notify: false);

      await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GOOGLE LOGIN
  // =========================

  Future<bool> googleLogin({
    required String email,
    required String name,
  }) async {
    try {
      _setLoading(true);
      clearError(notify: false);

      final response = await _repository.googleLogin(
        email: email,
        name: name,
      );

      _token = response['token']?.toString();

      _isLoggedIn = _token != null && _token!.isNotEmpty;

      if (_isLoggedIn) {
        await getProfile(notifyError: false);
      }

      notifyListeners();

      return _isLoggedIn;
    } catch (e) {
      _isLoggedIn = false;
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET PROFILE
  // =========================

  Future<void> getProfile({
    bool notifyError = true,
  }) async {
    try {
      clearError(notify: false);

      _provider = await _repository.getProfile();

      notifyListeners();
    } catch (e) {
      if (notifyError) {
        _setError(e);
      } else {
        _errorMessage = e.toString();
      }
    }
  }

  // =========================
  // UPDATE PROFILE
  // =========================

  Future<bool> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      _setLoading(true);
      clearError(notify: false);

      await _repository.updateProfile(
        data: data,
      );

      await getProfile(notifyError: false);

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // REFRESH TOKEN
  // =========================

  Future<void> refreshToken() async {
    try {
      clearError(notify: false);

      _token = await _repository.refreshToken();

      _isLoggedIn = _token != null && _token!.isNotEmpty;

      notifyListeners();
    } catch (_) {
      // Ignore refresh failure silently.
    }
  }

  // =========================
  // CHECK LOGIN
  // Important:
  // Do not call clearError() with notifyListeners during splash/build.
  // =========================

  Future<void> checkLoginStatus() async {
    try {
      _errorMessage = null;

      _isLoggedIn = await _repository.isLoggedIn();

      if (_isLoggedIn) {
        _token = await _repository.getToken();

        try {
          await getProfile(notifyError: false);
        } catch (_) {
          // Ignore profile loading issue during startup.
        }
      }

      notifyListeners();
    } catch (_) {
      _isLoggedIn = false;
      _token = null;
      _provider = null;

      notifyListeners();
    }
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    try {
      _setLoading(true);

      await _repository.logout();

      _provider = null;
      _token = null;
      _isLoggedIn = false;
      _errorMessage = null;

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // DELETE ACCOUNT
  // =========================

  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      clearError(notify: false);

      await _repository.deleteAccount();

      _provider = null;
      _token = null;
      _isLoggedIn = false;
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // RESET LOCAL STATE
  // =========================

  void reset() {
    _isLoading = false;
    _isLoggedIn = false;
    _token = null;
    _errorMessage = null;
    _provider = null;

    notifyListeners();
  }
}