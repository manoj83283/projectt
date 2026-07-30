import 'package:dio/dio.dart';

import '../core/network/api_service.dart';
import '../core/storage/storage_service.dart';
import '../core/constants/api_constants.dart';
import '../models/admin/admin_model.dart';

class AuthService {
  AuthService._();

  static final AuthService _instance =
      AuthService._();

  factory AuthService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // LOGIN
  // =====================================================

  Future<AdminModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data['data'];

      final accessToken =
          data['accessToken'];

      final refreshToken =
          data['refreshToken'];

      await StorageService.saveAccessToken(
        accessToken,
      );

      await StorageService.saveRefreshToken(
        refreshToken,
      );

      await StorageService.saveUserData(
        data['admin'],
      );

      await StorageService.setLoggedIn(
        true,
      );

      return AdminModel.fromJson(
        data['admin'],
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Login failed',
      );
    } catch (e) {
      throw Exception(
        e.toString(),
      );
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> logout() async {
    try {
      await _api.post(
        ApiConstants.logout,
      );
    } catch (_) {}

    await StorageService.logout();
  }

  // =====================================================
  // CURRENT ADMIN
  // =====================================================

  Future<AdminModel> getProfile() async {
    try {
      final response = await _api.get(
        ApiConstants.profile,
      );

      return AdminModel.fromJson(
        response.data['data'],
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to load profile',
      );
    }
  }

  // =====================================================
  // UPDATE PROFILE
  // =====================================================

  Future<AdminModel> updateProfile({
    required String name,
    required String phone,
    String? profileImage,
  }) async {
    try {
      final response = await _api.put(
        ApiConstants.updateProfile,
        data: {
          'name': name,
          'phone': phone,
          'profileImage':
              profileImage,
        },
      );

      final admin =
          AdminModel.fromJson(
        response.data['data'],
      );

      await StorageService.saveUserData(
        admin.toJson(),
      );

      return admin;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Profile update failed',
      );
    }
  }

  // =====================================================
  // CHANGE PASSWORD
  // =====================================================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _api.post(
        ApiConstants.changePassword,
        data: {
          'currentPassword':
              currentPassword,
          'newPassword':
              newPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Password change failed',
      );
    }
  }

  // =====================================================
  // FORGOT PASSWORD
  // =====================================================

  Future<void> forgotPassword(
    String email,
  ) async {
    try {
      await _api.post(
        ApiConstants.forgotPassword,
        data: {
          'email': email,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to send reset email',
      );
    }
  }

  // =====================================================
  // RESET PASSWORD
  // =====================================================

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    try {
      await _api.post(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'password': password,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Password reset failed',
      );
    }
  }

  // =====================================================
  // REFRESH TOKEN
  // =====================================================

  Future<bool> refreshToken() async {
    try {
      final refreshToken =
          await StorageService
              .getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      final response = await _api.post(
        ApiConstants.refreshToken,
        data: {
          'refreshToken':
              refreshToken,
        },
      );

      final newToken =
          response.data['data']
              ['accessToken'];

      await StorageService.saveAccessToken(
        newToken,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // CHECK LOGIN
  // =====================================================

  Future<bool>
      isAuthenticated() async {
    final token =
        await StorageService
            .getAccessToken();

    return token != null &&
        token.isNotEmpty;
  }

  // =====================================================
  // GET SAVED ADMIN
  // =====================================================

  Future<AdminModel?>
      getSavedAdmin() async {
    final data =
        await StorageService
            .getUserData();

    if (data == null) {
      return null;
    }

    return AdminModel.fromJson(data);
  }

  // =====================================================
  // VERIFY TOKEN
  // =====================================================

  Future<bool> verifyToken() async {
    try {
      await _api.get(
        ApiConstants.profile,
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}