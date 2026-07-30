import '../models/provider_model.dart';
import '../services/provider_service.dart';

class ProviderRepository {
  ProviderRepository._();

  static final ProviderRepository _instance =
      ProviderRepository._();

  static ProviderRepository get instance =>
      _instance;

  final ProviderService _providerService =
      ProviderService.instance;

  // =========================
  // GET PROVIDER PROFILE
  // =========================

  Future<ProviderModel>
      getProviderProfile() async {
    try {
      return await _providerService
          .getProviderProfile();
    } catch (e) {
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
      return await _providerService
          .getProviderById(providerId);
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // UPDATE PROFILE
  // =========================

  Future<ProviderModel>
      updateProviderProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _providerService
          .updateProviderProfile(
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // UPDATE BUSINESS DETAILS
  // =========================

  Future<ProviderModel>
      updateBusinessDetails({
    required String businessName,
    required String businessType,
    required String categoryId,
  }) async {
    try {
      return await _providerService
          .updateBusinessDetails(
        businessName: businessName,
        businessType: businessType,
        categoryId: categoryId,
      );
    } catch (e) {
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
      return await _providerService
          .updateOnlineStatus(
        isOnline: isOnline,
      );
    } catch (e) {
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
      return await _providerService
          .updateLocation(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
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
      return await _providerService
          .updateAvailability(
        available: available,
      );
    } catch (e) {
      return false;
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
      return await _providerService
          .submitKyc(
        aadhaarNumber: aadhaarNumber,
        panNumber: panNumber,
        aadhaarFront: aadhaarFront,
        aadhaarBack: aadhaarBack,
        panCardImage: panCardImage,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET KYC STATUS
  // =========================

  Future<Map<String, dynamic>>
      getKycStatus() async {
    try {
      return await _providerService
          .getKycStatus();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // DASHBOARD SUMMARY
  // =========================

  Future<Map<String, dynamic>>
      getDashboardSummary() async {
    try {
      return await _providerService
          .getDashboardSummary();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // EARNINGS SUMMARY
  // =========================

  Future<Map<String, dynamic>>
      getEarningsSummary() async {
    try {
      return await _providerService
          .getEarningsSummary();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET PORTFOLIO IMAGES
  // =========================

  Future<List<String>>
      getPortfolioImages() async {
    try {
      return await _providerService
          .getPortfolioImages();
    } catch (e) {
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
      return await _providerService
          .addPortfolioImage(
        imageUrl: imageUrl,
      );
    } catch (e) {
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
      return await _providerService
          .deletePortfolioImage(
        imageUrl: imageUrl,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // DELETE ACCOUNT
  // =========================

  Future<bool> deleteAccount() async {
    try {
      return await _providerService
          .deleteAccount();
    } catch (e) {
      return false;
    }
  }
}