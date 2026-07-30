import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class BannerService {
  BannerService._();

  static final BannerService _instance =
      BannerService._();

  factory BannerService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL BANNERS
  // =====================================================

  Future<Map<String, dynamic>> getBanners({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? bannerType,
  }) async {
    try {
      final response = await _api.get(
        '/admin/banners',
        query: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (isActive != null)
            'isActive': isActive,
          if (bannerType != null)
            'bannerType': bannerType,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/banners/$bannerId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CREATE BANNER
  // =====================================================

  Future<Map<String, dynamic>>
      createBanner({
    required String title,
    required String image,
    String? description,
    String? redirectUrl,
    String? categoryId,
    String? serviceId,
    String bannerType = 'homepage',
    int priority = 0,
    bool isActive = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _api.post(
        '/admin/banners',
        data: {
          'title': title,
          'image': image,
          'description': description,
          'redirectUrl': redirectUrl,
          'categoryId': categoryId,
          'serviceId': serviceId,
          'bannerType': bannerType,
          'priority': priority,
          'isActive': isActive,
          'startDate':
              startDate?.toIso8601String(),
          'endDate':
              endDate?.toIso8601String(),
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE BANNER
  // =====================================================

  Future<Map<String, dynamic>>
      updateBanner({
    required String bannerId,
    String? title,
    String? image,
    String? description,
    String? redirectUrl,
    String? categoryId,
    String? serviceId,
    String? bannerType,
    int? priority,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _api.put(
        '/admin/banners/$bannerId',
        data: {
          if (title != null)
            'title': title,
          if (image != null)
            'image': image,
          if (description != null)
            'description': description,
          if (redirectUrl != null)
            'redirectUrl': redirectUrl,
          if (categoryId != null)
            'categoryId': categoryId,
          if (serviceId != null)
            'serviceId': serviceId,
          if (bannerType != null)
            'bannerType': bannerType,
          if (priority != null)
            'priority': priority,
          if (isActive != null)
            'isActive': isActive,
          if (startDate != null)
            'startDate':
                startDate.toIso8601String(),
          if (endDate != null)
            'endDate':
                endDate.toIso8601String(),
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE BANNER
  // =====================================================

  Future<bool> deleteBanner(
    String bannerId,
  ) async {
    try {
      await _api.delete(
        '/admin/banners/$bannerId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ACTIVATE BANNER
  // =====================================================

  Future<bool> activateBanner(
    String bannerId,
  ) async {
    try {
      await _api.patch(
        '/admin/banners/$bannerId/activate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DEACTIVATE BANNER
  // =====================================================

  Future<bool> deactivateBanner(
    String bannerId,
  ) async {
    try {
      await _api.patch(
        '/admin/banners/$bannerId/deactivate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REORDER BANNERS
  // =====================================================

  Future<bool> reorderBanners(
    List<Map<String, dynamic>> banners,
  ) async {
    try {
      await _api.post(
        '/admin/banners/reorder',
        data: {
          'banners': banners,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BANNER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getBannerAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/banners/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BANNER STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getBannerStatistics() async {
    try {
      final response = await _api.get(
        '/admin/banners/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // TRACK BANNER CLICK
  // =====================================================

  Future<bool> trackBannerClick(
    String bannerId,
  ) async {
    try {
      await _api.post(
        '/admin/banners/$bannerId/click',
      );

      return true;
    } on DioException {
      return false;
    }
  }

  // =====================================================
  // SEARCH BANNERS
  // =====================================================

  Future<List<dynamic>>
      searchBanners(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/banners/search',
        query: {
          'keyword': keyword,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT BANNERS
  // =====================================================

  Future<Response<dynamic>>
      exportBanners({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/banners/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK DELETE BANNERS
  // =====================================================

  Future<bool> bulkDeleteBanners(
    List<String> bannerIds,
  ) async {
    try {
      await _api.post(
        '/admin/banners/bulk-delete',
        data: {
          'bannerIds': bannerIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK STATUS UPDATE
  // =====================================================

  Future<bool> bulkStatusUpdate({
    required List<String> bannerIds,
    required bool isActive,
  }) async {
    try {
      await _api.post(
        '/admin/banners/bulk-status',
        data: {
          'bannerIds': bannerIds,
          'isActive': isActive,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ERROR HANDLER
  // =====================================================

  String _parseError(
    DioException e,
  ) {
    return e.response?.data?['message']
            ?.toString() ??
        e.message ??
        'Something went wrong';
  }
}