import 'dart:developer';

import '../core/network/api_service.dart';
import '../core/storage/storage_helper.dart';
import '../models/provider_model.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance =
      AuthService._internal();

  static AuthService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // LOGIN
  // =========================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response =
          await _apiService.post(
        '/provider/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      final token =
          response['token']?.toString();

      if (token != null &&
          token.isNotEmpty) {
        await StorageHelper.saveToken(
          token,
        );
      }

      return response;
    } catch (e) {
      log('Login Error: $e');
      rethrow;
    }
  }

  // =========================
  // REGISTER
  // =========================

  Future<Map<String, dynamic>>
      register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String businessName,
  }) async {
    try {
      return await _apiService.post(
        '/provider/auth/register',
        body: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'businessName': businessName,
        },
      );
    } catch (e) {
      log('Register Error: $e');
      rethrow;
    }
  }

  // =========================
  // SEND OTP
  // =========================

  Future<Map<String, dynamic>>
      sendOtp({
    required String phone,
  }) async {
    try {
      return await _apiService.post(
        '/provider/auth/send-otp',
        body: {
          'phone': phone,
        },
      );
    } catch (e) {
      log('Send OTP Error: $e');
      rethrow;
    }
  }

  // =========================
  // VERIFY OTP
  // =========================

  Future<Map<String, dynamic>>
      verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      return await _apiService.post(
        '/provider/auth/verify-otp',
        body: {
          'phone': phone,
          'otp': otp,
        },
      );
    } catch (e) {
      log('Verify OTP Error: $e');
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
      return await _apiService.post(
        '/provider/auth/forgot-password',
        body: {
          'email': email,
        },
      );
    } catch (e) {
      log('Forgot Password Error: $e');
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
      return await _apiService.post(
        '/provider/auth/reset-password',
        body: {
          'email': email,
          'otp': otp,
          'password': password,
        },
      );
    } catch (e) {
      log('Reset Password Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET PROFILE
  // =========================

  Future<ProviderModel> getProfile() async {
    try {
      final response =
          await _apiService.get(
        '/provider/profile',
      );

      return ProviderModel.fromJson(
        response['data'] ??
            response,
      );
    } catch (e) {
      log('Profile Error: $e');
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
      return await _apiService.put(
        '/provider/profile',
        body: data,
      );
    } catch (e) {
      log('Update Profile Error: $e');
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
      return await _apiService.post(
        '/provider/auth/change-password',
        body: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      log('Change Password Error: $e');
      rethrow;
    }
  }

  // =========================
  // REFRESH TOKEN
  // =========================

  Future<String?> refreshToken() async {
    try {
      final response =
          await _apiService.post(
        '/provider/auth/refresh-token',
      );

      final token =
          response['token']?.toString();

      if (token != null &&
          token.isNotEmpty) {
        await StorageHelper.saveToken(
          token,
        );
      }

      return token;
    } catch (e) {
      log('Refresh Token Error: $e');
      return null;
    }
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    try {
      await _apiService.post(
        '/provider/auth/logout',
      );
    } catch (_) {}

    await StorageHelper.clearAll();
  }

  // =========================
  // DELETE ACCOUNT
  // =========================

  Future<Map<String, dynamic>>
      deleteAccount() async {
    try {
      final response =
          await _apiService.delete(
        '/provider/profile',
      );

      await StorageHelper.clearAll();

      return response;
    } catch (e) {
      log('Delete Account Error: $e');
      rethrow;
    }
  }

  // =========================
  // CHECK LOGIN
  // =========================

  Future<bool> isLoggedIn() async {
    final token =
        await StorageHelper.getToken();

    return token != null &&
        token.isNotEmpty;
  }

  // =========================
  // GET TOKEN
  // =========================

  Future<String?> getToken() async {
    return StorageHelper.getToken();
  }
}