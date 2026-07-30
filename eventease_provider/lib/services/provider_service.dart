import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/provider_model.dart';

class ProviderService {
  ProviderService._();

  static final ProviderService _instance =
      ProviderService._();

  static ProviderService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // GET PROVIDER PROFILE
  // =========================

  Future<ProviderModel> getProviderProfile() async {
    try {
      final response = await _apiService.get(
        '/provider/profile',
      );

      return ProviderModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Get Provider Profile Error: $e');
      rethrow;
    }
  }

  // =========================
  // UPDATE PROVIDER PROFILE
  // =========================

  Future<ProviderModel> updateProviderProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.put(
        '/provider/profile',
        body: data,
      );

      return ProviderModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Update Provider Profile Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET PROVIDER BY ID
  // =========================

  Future<ProviderModel> getProviderById(
    String providerId,
  ) async {
    try {
      final response = await _apiService.get(
        '/providers/$providerId',
      );

      return ProviderModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Get Provider By ID Error: $e');
      rethrow;
    }
  }

  // =========================
  // UPDATE ONLINE STATUS
  // =========================

  Future<bool> updateOnlineStatus({
    required bool isOnline,
  }) async {
    try {
      await _apiService.patch(
        '/provider/online-status',
        body: {
          'isOnline': isOnline,
        },
      );

      return true;
    } catch (e) {
      log('Update Online Status Error: $e');
      return false;
    }
  }

  // =========================
  // UPDATE LOCATION
  // =========================

  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _apiService.patch(
        '/provider/location',
        body: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return true;
    } catch (e) {
      log('Update Location Error: $e');
      return false;
    }
  }

  // =========================
  // UPDATE BUSINESS DETAILS
  // =========================

  Future<ProviderModel> updateBusinessDetails({
    required String businessName,
    required String businessType,
    required String categoryId,
  }) async {
    try {
      final response = await _apiService.put(
        '/provider/business',
        body: {
          'businessName': businessName,
          'businessType': businessType,
          'categoryId': categoryId,
        },
      );

      return ProviderModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Update Business Details Error: $e');
      rethrow;
    }
  }

  // =========================
  // SUBMIT KYC
  // =========================

  Future<Map<String, dynamic>> submitKyc({
    required String aadhaarNumber,
    required String panNumber,
    required String aadhaarFront,
    required String aadhaarBack,
    required String panCardImage,
  }) async {
    try {
      return await _apiService.post(
        '/provider/kyc',
        body: {
          'aadhaarNumber':
              aadhaarNumber,
          'panNumber': panNumber,
          'aadhaarFront':
              aadhaarFront,
          'aadhaarBack':
              aadhaarBack,
          'panCardImage':
              panCardImage,
        },
      );
    } catch (e) {
      log('Submit KYC Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET KYC STATUS
  // =========================

  Future<Map<String, dynamic>>
      getKycStatus() async {
    try {
      return await _apiService.get(
        '/provider/kyc-status',
      );
    } catch (e) {
      log('Get KYC Status Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET DASHBOARD SUMMARY
  // =========================

  Future<Map<String, dynamic>>
      getDashboardSummary() async {
    try {
      return await _apiService.get(
        '/provider/dashboard',
      );
    } catch (e) {
      log('Get Dashboard Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET EARNINGS SUMMARY
  // =========================

  Future<Map<String, dynamic>>
      getEarningsSummary() async {
    try {
      return await _apiService.get(
        '/provider/earnings',
      );
    } catch (e) {
      log('Get Earnings Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET PORTFOLIO IMAGES
  // =========================

  Future<List<String>>
      getPortfolioImages() async {
    try {
      final response =
          await _apiService.get(
        '/provider/portfolio',
      );

      if (response['data'] == null) {
        return [];
      }

      return List<String>.from(
        response['data'],
      );
    } catch (e) {
      log('Get Portfolio Error: $e');
      return [];
    }
  }

  // =========================
  // ADD PORTFOLIO IMAGE
  // =========================

  Future<bool> addPortfolioImage({
    required String imageUrl,
  }) async {
    try {
      await _apiService.post(
        '/provider/portfolio',
        body: {
          'imageUrl': imageUrl,
        },
      );

      return true;
    } catch (e) {
      log('Add Portfolio Image Error: $e');
      return false;
    }
  }

  // =========================
  // DELETE PORTFOLIO IMAGE
  // =========================

  Future<bool> deletePortfolioImage({
    required String imageUrl,
  }) async {
    try {
      await _apiService.delete(
        '/provider/portfolio',
        body: {
          'imageUrl': imageUrl,
        },
      );

      return true;
    } catch (e) {
      log(
        'Delete Portfolio Image Error: $e',
      );
      return false;
    }
  }

  // =========================
  // UPDATE AVAILABILITY
  // =========================

  Future<bool> updateAvailability({
    required bool available,
  }) async {
    try {
      await _apiService.patch(
        '/provider/availability',
        body: {
          'available': available,
        },
      );

      return true;
    } catch (e) {
      log(
        'Update Availability Error: $e',
      );
      return false;
    }
  }

  // =========================
  // DELETE ACCOUNT
  // =========================

  Future<bool> deleteAccount() async {
    try {
      await _apiService.delete(
        '/provider/profile',
      );

      return true;
    } catch (e) {
      log('Delete Account Error: $e');
      return false;
    }
  }
}