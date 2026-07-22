import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  final AuthRepository _repository =
      AuthRepository.instance;

  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  UserModel? get user => _user;

  bool get isLoading => _isLoading;

  bool get isLoggedIn => _isLoggedIn;

  String? get error => _error;

  // ==========================================
  // SET LOADING
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // SET ERROR
  // ==========================================

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ==========================================
  // LOGIN
  // ==========================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _user = await _repository.login(
        email: email,
        password: password,
      );

      _isLoggedIn = true;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // REGISTER
  // ==========================================

  Future<bool> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _user = await _repository.register(
        fullName: fullName,
        email: email,
        mobile: mobile,
        password: password,
      );

      _isLoggedIn = true;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GOOGLE LOGIN
  // ==========================================

  Future<bool> googleLogin() async {
    try {
      _setLoading(true);
      _setError(null);

      _user =
          await _repository.googleLogin();

      _isLoggedIn = true;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SEND OTP
  // ==========================================

  Future<bool> sendOtp(
    String mobile,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository.sendOtp(
        mobile,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // VERIFY OTP
  // ==========================================

  Future<bool> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _user =
          await _repository.verifyOtp(
        mobile: mobile,
        otp: otp,
      );

      _isLoggedIn = true;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // FORGOT PASSWORD
  // ==========================================

  Future<bool> forgotPassword(
    String email,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .forgotPassword(email);
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // RESET PASSWORD
  // ==========================================

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .resetPassword(
        token: token,
        password: password,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GET PROFILE
  // ==========================================

  Future<void> getProfile() async {
    try {
      _setLoading(true);

      _user =
          await _repository.getProfile();

      _isLoggedIn = true;

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // UPDATE PROFILE
  // ==========================================

  Future<bool> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      _setLoading(true);

      _user =
          await _repository.updateProfile(
        data: data,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CHECK LOGIN
  // ==========================================

  Future<void> checkAuth() async {
    try {
      _isLoggedIn =
          await _repository.isLoggedIn();

      if (_isLoggedIn) {
        await getProfile();
      }

      notifyListeners();
    } catch (_) {}
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> logout() async {
    try {
      _setLoading(true);

      await _repository.logout();

      _user = null;
      _isLoggedIn = false;
      _error = null;

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // DELETE ACCOUNT
  // ==========================================

  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);

      final success =
          await _repository.deleteAccount();

      if (success) {
        _user = null;
        _isLoggedIn = false;
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================

  void clearError() {
    _error = null;
    notifyListeners();
  }
}