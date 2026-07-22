import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance =
      AuthService._();

  // ==========================================
  // LOGIN
  // ==========================================

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response =
        await ApiService.instance.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;

    final token = data['token'];

    if (token != null) {
      ApiService.instance.setAuthToken(
        token,
      );
    }

    return UserModel.fromMap(
      data['user'],
    );
  }

  // ==========================================
  // REGISTER
  // ==========================================

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response =
        await ApiService.instance.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    final data = response.data;

    final token = data['token'];

    if (token != null) {
      ApiService.instance.setAuthToken(
        token,
      );
    }

    return UserModel.fromMap(
      data['user'],
    );
  }

  // ==========================================
  // GET PROFILE
  // ==========================================

  Future<UserModel> getProfile() async {
    final response =
        await ApiService.instance.get(
      '/auth/profile',
    );

    return UserModel.fromMap(
      response.data['user'],
    );
  }

  // ==========================================
  // REFRESH TOKEN
  // ==========================================

  Future<String?> refreshToken() async {
    final response =
        await ApiService.instance.post(
      '/auth/refresh-token',
    );

    final token =
        response.data['token'];

    if (token != null) {
      ApiService.instance.setAuthToken(
        token,
      );
    }

    return token;
  }

  // ==========================================
  // FORGOT PASSWORD
  // ==========================================

  Future<bool> forgotPassword(
    String email,
  ) async {
    await ApiService.instance.post(
      '/auth/forgot-password',
      data: {
        'email': email,
      },
    );

    return true;
  }

  // ==========================================
  // RESET PASSWORD
  // ==========================================

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    await ApiService.instance.post(
      '/auth/reset-password',
      data: {
        'token': token,
        'password': password,
      },
    );

    return true;
  }

  // ==========================================
  // CHANGE PASSWORD
  // ==========================================

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await ApiService.instance.post(
      '/auth/change-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );

    return true;
  }

  // ==========================================
  // LOGOUT
  // ==========================================

  Future<void> logout() async {
    try {
      await ApiService.instance.post(
        '/auth/logout',
      );
    } catch (_) {}

    ApiService.instance.clearAuthToken();
  }

  // ==========================================
  // DELETE ACCOUNT
  // ==========================================

  Future<bool> deleteAccount() async {
    await ApiService.instance.delete(
      '/auth/delete-account',
    );

    ApiService.instance.clearAuthToken();

    return true;
  }

  // ==========================================
  // VERIFY OTP
  // ==========================================

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await ApiService.instance.post(
      '/auth/verify-otp',
      data: {
        'email': email,
        'otp': otp,
      },
    );

    return true;
  }

  // ==========================================
  // RESEND OTP
  // ==========================================

  Future<bool> resendOtp(
    String email,
  ) async {
    await ApiService.instance.post(
      '/auth/resend-otp',
      data: {
        'email': email,
      },
    );

    return true;
  }
}