import 'package:flutter/foundation.dart';

import '../models/provider_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository =
      AuthRepository.instance;

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

  String? get errorMessage =>
      _errorMessage;

  ProviderModel? get provider =>
      _provider;

  // =========================
  // SET LOADING
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // =========================
  // CLEAR ERROR
  // =========================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // LOGIN
  // =========================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _repository.login(
        email: email,
        password: password,
      );

      _token =
          response['token']?.toString();

      _isLoggedIn = true;

      await getProfile();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // REGISTER
  // =========================

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String businessName,
  }) async {
    try {
      _setLoading(true);

      await _repository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        businessName: businessName,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // SEND OTP
  // =========================

  Future<bool> sendOtp({
    required String phone,
  }) async {
    try {
      _setLoading(true);

      await _repository.sendOtp(
        phone: phone,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
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

      await _repository.verifyOtp(
        phone: phone,
        otp: otp,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
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

      await _repository.forgotPassword(
        email: email,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
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

      await _repository.resetPassword(
        email: email,
        otp: otp,
        password: password,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
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

      await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET PROFILE
  // =========================

  Future<void> getProfile() async {
    try {
      _provider =
          await _repository.getProfile();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
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

      await _repository.updateProfile(
        data: data,
      );

      await getProfile();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
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
      _token =
          await _repository.refreshToken();

      notifyListeners();
    } catch (_) {}
  }

  // =========================
  // CHECK LOGIN
  // =========================

  Future<void> checkLoginStatus() async {
    try {
      _isLoggedIn =
          await _repository.isLoggedIn();

      if (_isLoggedIn) {
        await getProfile();
      }

      notifyListeners();
    } catch (_) {}
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

      await _repository.deleteAccount();

      _provider = null;
      _token = null;
      _isLoggedIn = false;

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}