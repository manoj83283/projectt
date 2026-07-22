import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance =
      AuthRepository._();

  final AuthService _authService =
      AuthService.instance;

  // ==========================================
  // LOGIN
  // ==========================================

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    return await _authService.login(
      email: email,
      password: password,
    );
  }

  // ==========================================
  // REGISTER
  // ==========================================

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    return await _authService.register(
      fullName: fullName,
      email: email,
      mobile: mobile,
      password: password,
    );
  }

  // ==========================================
  // GOOGLE LOGIN
  // ==========================================

  Future<UserModel> googleLogin() async {
    return await _authService.googleLogin();
  }

  // ==========================================
  // SEND OTP
  // ==========================================

  Future<bool> sendOtp(
    String mobile,
  ) async {
    return await _authService.sendOtp(
      mobile,
    );
  }

  // ==========================================
  // VERIFY OTP
  // ==========================================

  Future<UserModel> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    return await _authService.verifyOtp(
      mobile: mobile,
      otp: otp,
    );
  }

  // ==========================================
  // FORGOT PASSWORD
  // ==========================================

  Future<bool> forgotPassword(
    String email,
  ) async {
    return await _authService
        .forgotPassword(email);
  }

  // ==========================================
  // RESET PASSWORD
  // ==========================================

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    return await _authService.resetPassword(
      token: token,
      password: password,
    );
  }

  // ==========================================
  // GET PROFILE
  // ==========================================

  Future<UserModel> getProfile() async {
    return await _authService.getProfile();
  }

  // ==========================================
  // UPDATE PROFILE
  // ==========================================

  Future<UserModel> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    return await _authService.updateProfile(
      data: data,
    );
  }

  // ==========================================
  // REFRESH TOKEN
  // ==========================================

  Future<bool> refreshToken() async {
    return await _authService.refreshToken();
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<bool> logout() async {
    return await _authService.logout();
  }

  // ==========================================
  // DELETE ACCOUNT
  // ==========================================

  Future<bool> deleteAccount() async {
    return await _authService.deleteAccount();
  }

  // ==========================================
  // CHECK LOGIN
  // ==========================================

  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  // ==========================================
  // GET TOKEN
  // ==========================================

  Future<String?> getToken() async {
    return await _authService.getToken();
  }
}