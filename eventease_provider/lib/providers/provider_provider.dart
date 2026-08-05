import 'package:flutter/foundation.dart';

import '../models/provider_model.dart';
import '../repositories/provider_repository.dart';

class ProviderProvider extends ChangeNotifier {
  final ProviderRepository _repository = ProviderRepository.instance;

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

  String? get errorMessage => _errorMessage;

  ProviderModel? get provider => _provider;

  Map<String, dynamic> get dashboard => _dashboard;

  Map<String, dynamic> get earnings => _earnings;

  Map<String, dynamic> get kycStatus => _kycStatus;

  List<String> get portfolioImages => _portfolioImages;

  bool get hasProvider => _provider != null;

  bool get isAvailable => _provider?.isAvailable ?? true;

  bool get isOnline => _provider?.isOnline ?? false;

  bool get isVerified => _provider?.isVerified ?? false;

  // =========================
  // HELPERS
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(Object e) {
    _errorMessage = e.toString();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // INIT
  // =========================

  Future<void> init() async {
    await refreshData();
  }

  // =========================
  // GET PROFILE
  // =========================

  Future<void> getProfile() async {
    try {
      _setLoading(true);
      clearError();

      _provider = await _repository.getProviderProfile();

      notifyListeners();
    } catch (e) {
      _setError(e);
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
      clearError();

      return await _repository.getProviderById(providerId);
    } catch (e) {
      _setError(e);
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
      clearError();

      _provider = await _repository.updateProviderProfile(
        data: data,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
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
      clearError();

      _provider = await _repository.updateBusinessDetails(
        businessName: businessName,
        businessType: businessType,
        categoryId: categoryId,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e);
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
      clearError();

      final success = await _repository.updateOnlineStatus(
        isOnline: isOnline,
      );

      if (success && _provider != null) {
        _provider = _provider!.copyWith(
          isOnline: isOnline,
        );

        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e);
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
      clearError();

      final success = await _repository.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );

      if (success && _provider != null) {
        _provider = _provider!.copyWith(
          latitude: latitude,
          longitude: longitude,
        );

        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e);
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
      _setLoading(true);
      clearError();

      final success = await _repository.updateAvailability(
        available: available,
      );

      if (success && _provider != null) {
        _provider = _provider!.copyWith(
          isAvailable: available,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // UPDATE AVAILABILITY WITH SCHEDULE
  // =========================
  // Optional helper for future use. Existing screen can still call:
  // updateAvailability(true/false)

  Future<bool> updateAvailabilityWithSchedule({
    required bool available,
    List<String> workingDays = const [],
    String? startTime,
    String? endTime,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final success = await _repository.updateAvailability(
        available: available,
      );

      if (success && _provider != null) {
        _provider = _provider!.copyWith(
          isAvailable: available,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
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
      clearError();

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
      _setError(e);
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
      clearError();

      _kycStatus = await _repository.getKycStatus();

      notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // =========================
  // DASHBOARD
  // =========================

  Future<void> getDashboardSummary() async {
    try {
      clearError();

      _dashboard = await _repository.getDashboardSummary();

      notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // =========================
  // EARNINGS
  // =========================

  Future<void> getEarningsSummary() async {
    try {
      clearError();

      _earnings = await _repository.getEarningsSummary();

      notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // =========================
  // PORTFOLIO
  // =========================

  Future<void> getPortfolioImages() async {
    try {
      clearError();

      _portfolioImages = await _repository.getPortfolioImages();

      notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // =========================
  // ADD PORTFOLIO IMAGE
  // =========================

  Future<bool> addPortfolioImage({
    required String imageUrl,
  }) async {
    try {
      clearError();

      final success = await _repository.addPortfolioImage(
        imageUrl: imageUrl,
      );

      if (success) {
        _portfolioImages.add(imageUrl);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e);
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
      clearError();

      final success = await _repository.deletePortfolioImage(
        imageUrl: imageUrl,
      );

      if (success) {
        _portfolioImages.remove(imageUrl);
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e);
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
      clearError();

      final success = await _repository.deleteAccount();

      if (success) {
        _provider = null;
        _dashboard = {};
        _earnings = {};
        _kycStatus = {};
        _portfolioImages = [];
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // RESET
  // =========================

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _provider = null;
    _dashboard = {};
    _earnings = {};
    _kycStatus = {};
    _portfolioImages = [];

    notifyListeners();
  }
}