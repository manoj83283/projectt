import '../services/banner_service.dart';

class BannerRepository {
  final BannerService _bannerService;

  BannerRepository({
    BannerService? bannerService,
  }) : _bannerService =
            bannerService ??
                BannerService();

  // =====================================================
  // GET BANNERS
  // =====================================================

  Future<Map<String, dynamic>> getBanners({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    bool? isFeatured,
    String? bannerType,
  }) async {
    try {
      return await _bannerService.getBanners(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
        isFeatured: isFeatured,
        bannerType: bannerType,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GET BANNER DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getBannerDetails(
    String bannerId,
  ) async {
    try {
      return await _bannerService
          .getBannerDetails(
        bannerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH BANNERS
  // =====================================================

  Future<List<dynamic>> searchBanners(
    String keyword,
  ) async {
    try {
      return await _bannerService
          .searchBanners(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CREATE BANNER
  // =====================================================

  Future<Map<String, dynamic>>
      createBanner({
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
      return await _bannerService.createBanner(
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
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UPDATE BANNER
  // =====================================================

  Future<Map<String, dynamic>>
      updateBanner({
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
      return await _bannerService.updateBanner(
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
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ACTIVATE BANNER
  // =====================================================

  Future<Map<String, dynamic>>
      activateBanner(
    String bannerId,
  ) async {
    try {
      return await _bannerService
          .activateBanner(
        bannerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DEACTIVATE BANNER
  // =====================================================

  Future<Map<String, dynamic>>
      deactivateBanner(
    String bannerId,
  ) async {
    try {
      return await _bannerService
          .deactivateBanner(
        bannerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // FEATURE BANNER
  // =====================================================

  Future<Map<String, dynamic>>
      featureBanner(
    String bannerId,
  ) async {
    try {
      return await _bannerService
          .featureBanner(
        bannerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UNFEATURE BANNER
  // =====================================================

  Future<Map<String, dynamic>>
      unFeatureBanner(
    String bannerId,
  ) async {
    try {
      return await _bannerService
          .unFeatureBanner(
        bannerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UPDATE PRIORITY
  // =====================================================

  Future<Map<String, dynamic>>
      updateBannerPriority({
    required String bannerId,
    required int priority,
  }) async {
    try {
      return await _bannerService
          .updateBannerPriority(
        bannerId: bannerId,
        priority: priority,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REORDER BANNERS
  // =====================================================

  Future<Map<String, dynamic>>
      reorderBanners(
    List<Map<String, dynamic>>
        banners,
  ) async {
    try {
      return await _bannerService
          .reorderBanners(
        banners,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BANNER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getBannerAnalytics(
    String bannerId,
  ) async {
    try {
      return await _bannerService
          .getBannerAnalytics(
        bannerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BANNER CLICK ANALYTICS
  // =====================================================

  Future<List<dynamic>>
      getBannerClicks(
    String bannerId,
  ) async {
    try {
      return await _bannerService
          .getBannerClicks(
        bannerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ACTIVE BANNERS
  // =====================================================

  Future<List<dynamic>>
      getActiveBanners() async {
    try {
      return await _bannerService
          .getActiveBanners();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // FEATURED BANNERS
  // =====================================================

  Future<List<dynamic>>
      getFeaturedBanners() async {
    try {
      return await _bannerService
          .getFeaturedBanners();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE BANNER
  // =====================================================

  Future<void> deleteBanner(
    String bannerId,
  ) async {
    try {
      await _bannerService
          .deleteBanner(
        bannerId,
      );
    } catch (e) {
      rethrow;
    }
  }
}