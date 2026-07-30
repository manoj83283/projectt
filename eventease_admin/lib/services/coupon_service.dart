import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class CouponService {
  CouponService._();

  static final CouponService _instance =
      CouponService._();

  factory CouponService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL COUPONS
  // =====================================================

  Future<Map<String, dynamic>> getCoupons({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? couponType,
  }) async {
    try {
      final response = await _api.get(
        '/admin/coupons',
        query: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (isActive != null)
            'isActive': isActive,
          if (couponType != null)
            'couponType': couponType,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET COUPON DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getCouponDetails(
    String couponId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/coupons/$couponId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CREATE COUPON
  // =====================================================

  Future<Map<String, dynamic>>
      createCoupon({
    required String code,
    required String title,
    required String description,
    required String discountType,
    required double discountValue,
    required DateTime startDate,
    required DateTime endDate,
    double? minimumOrderAmount,
    double? maximumDiscountAmount,
    int? usageLimit,
    bool isActive = true,
  }) async {
    try {
      final response = await _api.post(
        '/admin/coupons',
        data: {
          'code': code,
          'title': title,
          'description': description,
          'discountType': discountType,
          'discountValue': discountValue,
          'startDate':
              startDate.toIso8601String(),
          'endDate':
              endDate.toIso8601String(),
          'minimumOrderAmount':
              minimumOrderAmount,
          'maximumDiscountAmount':
              maximumDiscountAmount,
          'usageLimit': usageLimit,
          'isActive': isActive,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE COUPON
  // =====================================================

  Future<Map<String, dynamic>>
      updateCoupon({
    required String couponId,
    String? title,
    String? description,
    double? discountValue,
    DateTime? startDate,
    DateTime? endDate,
    double? minimumOrderAmount,
    double? maximumDiscountAmount,
    int? usageLimit,
    bool? isActive,
  }) async {
    try {
      final response = await _api.put(
        '/admin/coupons/$couponId',
        data: {
          if (title != null)
            'title': title,
          if (description != null)
            'description': description,
          if (discountValue != null)
            'discountValue': discountValue,
          if (startDate != null)
            'startDate':
                startDate.toIso8601String(),
          if (endDate != null)
            'endDate':
                endDate.toIso8601String(),
          if (minimumOrderAmount != null)
            'minimumOrderAmount':
                minimumOrderAmount,
          if (maximumDiscountAmount != null)
            'maximumDiscountAmount':
                maximumDiscountAmount,
          if (usageLimit != null)
            'usageLimit': usageLimit,
          if (isActive != null)
            'isActive': isActive,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE COUPON
  // =====================================================

  Future<bool> deleteCoupon(
    String couponId,
  ) async {
    try {
      await _api.delete(
        '/admin/coupons/$couponId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ACTIVATE COUPON
  // =====================================================

  Future<bool> activateCoupon(
    String couponId,
  ) async {
    try {
      await _api.patch(
        '/admin/coupons/$couponId/activate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DEACTIVATE COUPON
  // =====================================================

  Future<bool> deactivateCoupon(
    String couponId,
  ) async {
    try {
      await _api.patch(
        '/admin/coupons/$couponId/deactivate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // COUPON USAGE REPORT
  // =====================================================

  Future<List<dynamic>>
      getCouponUsage(
    String couponId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/coupons/$couponId/usage',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // COUPON ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCouponAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/coupons/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // COUPON STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCouponStatistics() async {
    try {
      final response = await _api.get(
        '/admin/coupons/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // VALIDATE COUPON
  // =====================================================

  Future<Map<String, dynamic>>
      validateCoupon(
    String code,
  ) async {
    try {
      final response = await _api.post(
        '/admin/coupons/validate',
        data: {
          'code': code,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GENERATE COUPON CODE
  // =====================================================

  Future<String> generateCouponCode() async {
    try {
      final response = await _api.get(
        '/admin/coupons/generate-code',
      );

      return response.data['data']['code']
          .toString();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH COUPONS
  // =====================================================

  Future<List<dynamic>>
      searchCoupons(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/coupons/search',
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
  // EXPORT COUPONS
  // =====================================================

  Future<Response<dynamic>>
      exportCoupons({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/coupons/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK DELETE COUPONS
  // =====================================================

  Future<bool> bulkDeleteCoupons(
    List<String> couponIds,
  ) async {
    try {
      await _api.post(
        '/admin/coupons/bulk-delete',
        data: {
          'couponIds': couponIds,
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
    required List<String> couponIds,
    required bool isActive,
  }) async {
    try {
      await _api.post(
        '/admin/coupons/bulk-status',
        data: {
          'couponIds': couponIds,
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