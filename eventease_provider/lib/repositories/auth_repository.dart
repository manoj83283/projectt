import '../models/provider_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository._();

  static final AuthRepository _instance =
      AuthRepository._();

  static AuthRepository get instance =>
      _instance;

  final AuthService _authService =
      AuthService.instance;

  // =========================
  // LOGIN
  // =========================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _authService.login(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // REGISTER
  // =========================

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String businessName,
  }) async {
    try {
      return await _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        businessName: businessName,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // SEND OTP
  // =========================

  Future<Map<String, dynamic>> sendOtp({
    required String phone,
  }) async {
    try {
      return await _authService.sendOtp(
        phone: phone,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // VERIFY OTP
  // =========================

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      return await _authService.verifyOtp(
        phone: phone,
        otp: otp,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // FORGOT PASSWORD
  // =========================

  Future<Map<String, dynamic>>
      forgotPassword({
    required String email,
  }) async {
    try {
      return await _authService
          .forgotPassword(
        email: email,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // RESET PASSWORD
  // =========================

  Future<Map<String, dynamic>>
      resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      return await _authService
          .resetPassword(
        email: email,
        otp: otp,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // CHANGE PASSWORD
  // =========================

  Future<Map<String, dynamic>>
      changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      return await _authService
          .changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET PROFILE
  // =========================

  Future<ProviderModel>
      getProfile() async {
    try {
      return await _authService
          .getProfile();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // UPDATE PROFILE
  // =========================

  Future<Map<String, dynamic>>
      updateProfile({
    required Map<String, dynamic>
        data,
  }) async {
    try {
      return await _authService
          .updateProfile(
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // REFRESH TOKEN
  // =========================

  Future<String?> refreshToken() async {
    try {
      return await _authService
          .refreshToken();
    } catch (e) {
      return null;
    }
  }

  // =========================
  // CHECK LOGIN
  // =========================

  Future<bool> isLoggedIn() async {
    try {
      return await _authService
          .isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  // =========================
  // GET TOKEN
  // =========================

  Future<String?> getToken() async {
    try {
      return await _authService
          .getToken();
    } catch (e) {
      return null;
    }
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // DELETE ACCOUNT
  // =========================

  Future<Map<String, dynamic>>
      deleteAccount() async {
    try {
      return await _authService
          .deleteAccount();
    } catch (e) {
      rethrow;
    }
  }
}