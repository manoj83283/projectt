import 'dart:developer';

import '../core/network/api_service.dart';
import '../core/storage/storage_helper.dart';
import '../models/provider_model.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  static AuthService get instance => _instance;

  final ApiService _apiService = ApiService.instance;

  // =========================
  // LOGIN
  // Backend: POST /api/auth/signin
  // =========================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/signin',
        body: {
          'email': email.trim(),
          'password': password,
        },
      );

      final Map<String, dynamic> data = _normalizeMap(response);

      await _saveAuthData(data);

      return data;
    } catch (e) {
      log('Login Error: $e');
      rethrow;
    }
  }

  // =========================
  // SIGNUP
  // Backend: POST /api/auth/signup
  // =========================

  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String businessName,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/signup',
        body: {
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
          'role': 'provider',
          'shopName': businessName.trim(),
          'businessName': businessName.trim(),
        },
      );

      final Map<String, dynamic> data = _normalizeMap(response);

      await _saveAuthData(
        data,
        fallbackRole: 'provider',
      );

      return data;
    } catch (e) {
      log('Signup Error: $e');
      rethrow;
    }
  }

  // =========================
  // REGISTER WRAPPER
  // Backward compatibility for older code
  // =========================

  Future<Map<String, dynamic>> register({
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
  // GOOGLE LOGIN
  // Backend: POST /api/auth/google
  // =========================

  Future<Map<String, dynamic>> googleLogin({
    required String email,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/google',
        body: {
          'email': email.trim(),
          'name': name.trim(),
          'role': 'provider',
        },
      );

      final Map<String, dynamic> data = _normalizeMap(response);

      await _saveAuthData(
        data,
        fallbackRole: 'provider',
      );

      return data;
    } catch (e) {
      log('Google Login Error: $e');
      rethrow;
    }
  }

  // =========================
  // SEND OTP
  // NOTE: Backend route must exist to use this.
  // =========================

  Future<Map<String, dynamic>> sendOtp({
    required String phone,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/send-otp',
        body: {
          'phone': phone.trim(),
        },
      );

      return _normalizeMap(response);
    } catch (e) {
      log('Send OTP Error: $e');
      rethrow;
    }
  }

  // =========================
  // VERIFY OTP
  // NOTE: Backend route must exist to use this.
  // =========================

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-otp',
        body: {
          'phone': phone.trim(),
          'otp': otp.trim(),
        },
      );

      return _normalizeMap(response);
    } catch (e) {
      log('Verify OTP Error: $e');
      rethrow;
    }
  }

  // =========================
  // FORGOT PASSWORD
  // NOTE: Backend route must exist to use this.
  // =========================

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        body: {
          'email': email.trim(),
        },
      );

      return _normalizeMap(response);
    } catch (e) {
      log('Forgot Password Error: $e');
      rethrow;
    }
  }

  // =========================
  // RESET PASSWORD
  // NOTE: Backend route must exist to use this.
  // =========================

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/reset-password',
        body: {
          'email': email.trim(),
          'otp': otp.trim(),
          'password': password,
        },
      );

      return _normalizeMap(response);
    } catch (e) {
      log('Reset Password Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET PROFILE
  // Backend: GET /api/auth/profile
  // =========================

  Future<ProviderModel> getProfile() async {
    try {
      final response = await _apiService.get(
        '/auth/profile',
      );

      final Map<String, dynamic> data = _normalizeMap(response);

      final profileData = data['data'] ?? data['user'] ?? data;

      if (profileData is Map<String, dynamic>) {
        return ProviderModel.fromJson(profileData);
      }

      if (profileData is Map) {
        return ProviderModel.fromJson(
          profileData.map(
            (key, value) => MapEntry(
              key.toString(),
              value,
            ),
          ),
        );
      }

      return ProviderModel.empty();
    } catch (e) {
      log('Profile Error: $e');
      rethrow;
    }
  }

  // =========================
  // UPDATE PROFILE
  // NOTE: Backend route must exist to use this.
  // =========================

  Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.put(
        '/auth/profile',
        body: data,
      );

      return _normalizeMap(response);
    } catch (e) {
      log('Update Profile Error: $e');
      rethrow;
    }
  }

  // =========================
  // CHANGE PASSWORD
  // NOTE: Backend route must exist to use this.
  // =========================

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/change-password',
        body: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );

      return _normalizeMap(response);
    } catch (e) {
      log('Change Password Error: $e');
      rethrow;
    }
  }

  // =========================
  // REFRESH TOKEN
  // NOTE: Backend route must exist to use this.
  // =========================

  Future<String?> refreshToken() async {
    try {
      final response = await _apiService.post(
        '/auth/refresh-token',
      );

      final Map<String, dynamic> data = _normalizeMap(response);

      final token = data['token']?.toString();

      if (token != null && token.isNotEmpty) {
        await StorageHelper.saveToken(token);
      }

      return token;
    } catch (e) {
      log('Refresh Token Error: $e');
      return null;
    }
  }

  // =========================
  // LOGOUT
  // Local logout
  // =========================

  Future<void> logout() async {
    try {
      await _apiService.post(
        '/auth/logout',
      );
    } catch (_) {
      // Backend logout route may not exist.
      // Local cleanup still required.
    }

    await StorageHelper.clearAll();
  }

  // =========================
  // DELETE ACCOUNT
  // NOTE: Backend route must exist to use this.
  // =========================

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _apiService.delete(
        '/auth/profile',
      );

      await StorageHelper.clearAll();

      return _normalizeMap(response);
    } catch (e) {
      log('Delete Account Error: $e');
      rethrow;
    }
  }

  // =========================
  // CHECK LOGIN
  // =========================

  Future<bool> isLoggedIn() async {
    final token = await StorageHelper.getToken();

    return token != null && token.isNotEmpty;
  }

  // =========================
  // GET TOKEN
  // =========================

  Future<String?> getToken() async {
    return StorageHelper.getToken();
  }

  // =========================
  // SAVE AUTH DATA
  // =========================

  Future<void> _saveAuthData(
    Map<String, dynamic> data, {
    String? fallbackRole,
  }) async {
    final token = data['token']?.toString();

    if (token != null && token.isNotEmpty) {
      await StorageHelper.saveToken(token);
    }

    final userId = data['user']?['_id']?.toString() ??
        data['user']?['id']?.toString() ??
        data['_id']?.toString() ??
        data['id']?.toString();

    if (userId != null && userId.isNotEmpty) {
      await StorageHelper.saveUserId(userId);
    }

    final role = data['user']?['role']?.toString() ??
        data['role']?.toString() ??
        fallbackRole;

    if (role != null && role.isNotEmpty) {
      await StorageHelper.saveRole(role);
    }
  }

  // =========================
  // HELPERS
  // =========================

  Map<String, dynamic> _normalizeMap(dynamic response) {
    if (response == null) {
      return {};
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return response.map(
        (key, value) => MapEntry(
          key.toString(),
          value,
        ),
      );
    }

    return {
      'data': response,
    };
  }
}