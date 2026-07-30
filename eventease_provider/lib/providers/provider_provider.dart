import 'package:flutter/foundation.dart';

import '../models/provider_model.dart';
import '../repositories/provider_repository.dart';

class ProviderProvider extends ChangeNotifier {
  final ProviderRepository _repository =
      ProviderRepository.instance;

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;

  String? _errorMessage;

  ProviderModel? _provider;

  Map<String, dynamic> _dashboard = {};

  Map<String, dynamic> _earnings = {};

  Map<String, dynamic> _kycStatus = {};

  List<String> _portfolioImages = [];

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  ProviderModel? get provider =>
      _provider;

  Map<String, dynamic> get dashboard =>
      _dashboard;

  Map<String, dynamic> get earnings =>
      _earnings;

  Map<String, dynamic> get kycStatus =>
      _kycStatus;

  List<String> get portfolioImages =>
      _portfolioImages;

  // =========================
  // HELPERS
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // GET PROFILE
  // =========================

  Future<void> getProfile() async {
    try {
      _setLoading(true);

      _provider =
          await _repository
              .getProviderProfile();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET PROVIDER BY ID
  // =========================

  Future<ProviderModel?> getProviderById(
    String providerId,
  ) async {
    try {
      return await _repository
          .getProviderById(providerId);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  // =========================
  // UPDATE PROFILE
  // =========================

  Future<bool> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      _setLoading(true);

      _provider =
          await _repository
              .updateProviderProfile(
        data: data,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // UPDATE BUSINESS DETAILS
  // =========================

  Future<bool> updateBusinessDetails({
    required String businessName,
    required String businessType,
    required String categoryId,
  }) async {
    try {
      _setLoading(true);

      _provider =
          await _repository
              .updateBusinessDetails(
        businessName: businessName,
        businessType: businessType,
        categoryId: categoryId,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // UPDATE ONLINE STATUS
  // =========================

  Future<bool> updateOnlineStatus(
    bool isOnline,
  ) async {
    try {
      return await _repository
          .updateOnlineStatus(
        isOnline: isOnline,
      );
    } catch (e) {
      _errorMessage = e.toString();
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
      return await _repository
          .updateLocation(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // UPDATE AVAILABILITY
  // =========================

  Future<bool> updateAvailability(
    bool available,
  ) async {
    try {
      return await _repository
          .updateAvailability(
        available: available,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // SUBMIT KYC
  // =========================

  Future<bool> submitKyc({
    required String aadhaarNumber,
    required String panNumber,
    required String aadhaarFront,
    required String aadhaarBack,
    required String panCardImage,
  }) async {
    try {
      _setLoading(true);

      await _repository.submitKyc(
        aadhaarNumber: aadhaarNumber,
        panNumber: panNumber,
        aadhaarFront: aadhaarFront,
        aadhaarBack: aadhaarBack,
        panCardImage: panCardImage,
      );

      await getKycStatus();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // KYC STATUS
  // =========================

  Future<void> getKycStatus() async {
    try {
      _kycStatus =
          await _repository.getKycStatus();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // DASHBOARD
  // =========================

  Future<void>
      getDashboardSummary() async {
    try {
      _dashboard =
          await _repository
              .getDashboardSummary();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // EARNINGS
  // =========================

  Future<void>
      getEarningsSummary() async {
    try {
      _earnings =
          await _repository
              .getEarningsSummary();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // PORTFOLIO
  // =========================

  Future<void>
      getPortfolioImages() async {
    try {
      _portfolioImages =
          await _repository
              .getPortfolioImages();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // ADD PORTFOLIO IMAGE
  // =========================

  Future<bool> addPortfolioImage({
    required String imageUrl,
  }) async {
    try {
      final success =
          await _repository
              .addPortfolioImage(
        imageUrl: imageUrl,
      );

      if (success) {
        _portfolioImages.add(imageUrl);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();

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
      final success =
          await _repository
              .deletePortfolioImage(
        imageUrl: imageUrl,
      );

      if (success) {
        _portfolioImages.remove(
          imageUrl,
        );

        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    }
  }

  // =========================
  // REFRESH ALL
  // =========================

  Future<void> refreshData() async {
    await Future.wait([
      getProfile(),
      getDashboardSummary(),
      getEarningsSummary(),
      getKycStatus(),
      getPortfolioImages(),
    ]);
  }

  // =========================
  // DELETE ACCOUNT
  // =========================

  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);

      final success =
          await _repository.deleteAccount();

      if (success) {
        _provider = null;
        _dashboard = {};
        _earnings = {};
        _portfolioImages = [];
      }

      notifyListeners();

      return success;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }
}