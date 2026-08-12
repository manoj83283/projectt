import 'package:flutter/foundation.dart';

import '../models/banner_model.dart';
import '../services/banner_service.dart';

class BannerProvider extends ChangeNotifier {
  final BannerService _bannerService =
      BannerService();

  bool _isLoading = false;

  String? _errorMessage;

  List<BannerModel> _banners = [];

  BannerModel? _selectedBanner;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalBanners = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<BannerModel> get banners =>
      _banners;

  BannerModel? get selectedBanner =>
      _selectedBanner;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalBanners => _totalBanners;

  bool get hasBanners =>
      _banners.isNotEmpty;

  List<BannerModel> get activeBanners =>
      _banners
          .where(
            (banner) => banner.isActive,
          )
          .toList();

  List<BannerModel> get featuredBanners =>
      _banners
          .where(
            (banner) => banner.isFeatured,
          )
          .toList();

  // =====================================================
  // GET BANNERS
  // =====================================================

  Future<void> getBanners({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? bannerType,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _bannerService.getBanners(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
        bannerType: bannerType,
      );

      _banners =
          (response['banners'] as List? ??
                  [])
              .map(
                (e) =>
                    BannerModel.fromJson(
                  e,
                ),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalBanners =
          response['totalBanners'] ??
              _banners.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET BANNER DETAILS
  // =====================================================

  Future<void> getBannerDetails(
    String bannerId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _bannerService
              .getBannerDetails(
        bannerId,
      );

      _selectedBanner =
          BannerModel.fromJson(
        response,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CREATE BANNER
  // =====================================================

  Future<bool> createBanner({
    required String title,
    String? description,
    required String imageUrl,
    String? mobileImageUrl,
    required String bannerType,
    String? redirectType,
    String? redirectId,
    String? redirectUrl,
    int priority = 0,
    bool isFeatured = false,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _bannerService.createBanner(
        title: title,
        description: description,
        imageUrl: imageUrl,
        mobileImageUrl: mobileImageUrl,
        bannerType: bannerType,
        redirectType: redirectType,
        redirectId: redirectId,
        redirectUrl: redirectUrl,
        priority: priority,
        isFeatured: isFeatured,
      );

      final banner =
          BannerModel.fromJson(
        response,
      );

      _banners.insert(0, banner);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // UPDATE BANNER
  // =====================================================

  Future<bool> updateBanner({
    required String bannerId,
    required String title,
    String? description,
    String? imageUrl,
    String? mobileImageUrl,
    String? redirectType,
    String? redirectId,
    String? redirectUrl,
    int? priority,
    bool? isFeatured,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _bannerService.updateBanner(
        bannerId: bannerId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        mobileImageUrl: mobileImageUrl,
        redirectType: redirectType,
        redirectId: redirectId,
        redirectUrl: redirectUrl,
        priority: priority,
        isFeatured: isFeatured,
      );

      final updatedBanner =
          BannerModel.fromJson(
        response,
      );

      final index =
          _banners.indexWhere(
        (e) => e.id == bannerId,
      );

      if (index != -1) {
        _banners[index] =
            updatedBanner;
      }

      if (_selectedBanner?.id ==
          bannerId) {
        _selectedBanner =
            updatedBanner;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // ACTIVATE BANNER
  // =====================================================

  Future<bool> activateBanner(
    String bannerId,
  ) async {
    try {
      _setLoading(true);

      await _bannerService.activateBanner(
        bannerId,
      );

      final index =
          _banners.indexWhere(
        (e) => e.id == bannerId,
      );

      if (index != -1) {
        _banners[index] =
            _banners[index].copyWith(
          isActive: true,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DEACTIVATE BANNER
  // =====================================================

  Future<bool> deactivateBanner(
    String bannerId,
  ) async {
    try {
      _setLoading(true);

      await _bannerService
          .deactivateBanner(
        bannerId,
      );

      final index =
          _banners.indexWhere(
        (e) => e.id == bannerId,
      );

      if (index != -1) {
        _banners[index] =
            _banners[index].copyWith(
          isActive: false,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // FEATURE BANNER
  // =====================================================

  Future<bool> featureBanner(
    String bannerId,
  ) async {
    try {
      _setLoading(true);

      await _bannerService.featureBanner(
        bannerId,
      );

      final index =
          _banners.indexWhere(
        (e) => e.id == bannerId,
      );

      if (index != -1) {
        _banners[index] =
            _banners[index].copyWith(
          isFeatured: true,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // UNFEATURE BANNER
  // =====================================================

  Future<bool> unFeatureBanner(
    String bannerId,
  ) async {
    try {
      _setLoading(true);

      await _bannerService
          .unFeatureBanner(
        bannerId,
      );

      final index =
          _banners.indexWhere(
        (e) => e.id == bannerId,
      );

      if (index != -1) {
        _banners[index] =
            _banners[index].copyWith(
          isFeatured: false,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DELETE BANNER
  // =====================================================

  Future<bool> deleteBanner(
    String bannerId,
  ) async {
    try {
      _setLoading(true);

      await _bannerService.deleteBanner(
        bannerId,
      );

      _banners.removeWhere(
        (e) => e.id == bannerId,
      );

      if (_selectedBanner?.id ==
          bannerId) {
        _selectedBanner = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEARCH BANNERS
  // =====================================================

  Future<void> searchBanners(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _bannerService.searchBanners(
        keyword,
      );

      _banners =
          (response)
              .map(
                (e) =>
                    BannerModel.fromJson(
                  e,
                ),
              )
              .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH BANNERS
  // =====================================================

  Future<void> refreshBanners() async {
    await getBanners(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED BANNER
  // =====================================================

  void clearSelectedBanner() {
    _selectedBanner = null;
    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =====================================================
  // SET LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}