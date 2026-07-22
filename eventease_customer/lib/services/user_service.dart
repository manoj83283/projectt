import 'dart:io';

import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  // ==========================================
  // GET CURRENT USER PROFILE
  // ==========================================

  Future<UserModel> getProfile() async {
    final response = await ApiService.instance.get(
      '/users/profile',
    );

    return UserModel.fromMap(
      response.data['data'] ?? response.data['user'],
    );
  }

  // ==========================================
  // GET USER BY ID
  // ==========================================

  Future<UserModel> getUserById(
    String userId,
  ) async {
    final response = await ApiService.instance.get(
      '/users/$userId',
    );

    return UserModel.fromMap(
      response.data['data'] ?? response.data,
    );
  }

  // ==========================================
  // UPDATE PROFILE
  // ==========================================

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? gender,
    String? address,
    DateTime? dateOfBirth,
  }) async {
    final response = await ApiService.instance.put(
      '/users/profile',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'address': address,
        'dateOfBirth':
            dateOfBirth?.toIso8601String(),
      },
    );

    return UserModel.fromMap(
      response.data['data'] ?? response.data['user'],
    );
  }

  // ==========================================
  // UPLOAD PROFILE IMAGE
  // ==========================================

  Future<String> uploadProfileImage(
    File imageFile,
  ) async {
    final response =
        await ApiService.instance.uploadFile(
      '/users/profile-image',
      file: imageFile,
      fieldName: 'image',
    );

    return response.data['imageUrl'] ??
        response.data['url'] ??
        '';
  }

  // ==========================================
  // REMOVE PROFILE IMAGE
  // ==========================================

  Future<bool> removeProfileImage() async {
    await ApiService.instance.delete(
      '/users/profile-image',
    );

    return true;
  }

  // ==========================================
  // UPDATE LOCATION
  // ==========================================

  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    await ApiService.instance.put(
      '/users/location',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      },
    );

    return true;
  }

  // ==========================================
  // UPDATE FCM TOKEN
  // ==========================================

  Future<bool> updateFcmToken(
    String token,
  ) async {
    await ApiService.instance.put(
      '/users/fcm-token',
      data: {
        'fcmToken': token,
      },
    );

    return true;
  }

  // ==========================================
  // CHANGE PASSWORD
  // ==========================================

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiService.instance.post(
      '/users/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    return true;
  }

  // ==========================================
  // DEACTIVATE ACCOUNT
  // ==========================================

  Future<bool> deactivateAccount() async {
    await ApiService.instance.post(
      '/users/deactivate',
    );

    return true;
  }

  // ==========================================
  // DELETE ACCOUNT
  // ==========================================

  Future<bool> deleteAccount() async {
    await ApiService.instance.delete(
      '/users/delete-account',
    );

    return true;
  }

  // ==========================================
  // UPDATE DEVICE INFO
  // ==========================================

  Future<bool> updateDeviceInfo({
    required String deviceId,
    required String platform,
  }) async {
    await ApiService.instance.put(
      '/users/device-info',
      data: {
        'deviceId': deviceId,
        'platform': platform,
      },
    );

    return true;
  }
}