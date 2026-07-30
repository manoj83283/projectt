import '../services/coupon_service.dart';

class CouponRepository {
  final CouponService _couponService;

  CouponRepository({
    CouponService? couponService,
  }) : _couponService =
            couponService ??
                CouponService();

  // =====================================================
  // GET COUPONS
  // =====================================================

  Future<Map<String, dynamic>> getCoupons({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    String? discountType,
  }) async {
    try {
      return await _couponService.getCoupons(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
        discountType: discountType,
      );
    } catch (e) {
      rethrow;
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
      return await _couponService
          .getCouponDetails(
        couponId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH COUPONS
  // =====================================================

  Future<List<dynamic>> searchCoupons(
    String keyword,
  ) async {
    try {
      return await _couponService
          .searchCoupons(
        keyword,
      );
    } catch (e) {
      rethrow;
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
    double? maximumDiscountAmount,
    double? minimumOrderAmount,
    required int usageLimit,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _couponService.createCoupon(
        code: code,
        title: title,
        description: description,
        discountType: discountType,
        discountValue: discountValue,
        maximumDiscountAmount:
            maximumDiscountAmount,
        minimumOrderAmount:
            minimumOrderAmount,
        usageLimit: usageLimit,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UPDATE COUPON
  // =====================================================

  Future<Map<String, dynamic>>
      updateCoupon({
    required String couponId,
    required String title,
    required String description,
    required double discountValue,
    double? maximumDiscountAmount,
    double? minimumOrderAmount,
    int? usageLimit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _couponService.updateCoupon(
        couponId: couponId,
        title: title,
        description: description,
        discountValue: discountValue,
        maximumDiscountAmount:
            maximumDiscountAmount,
        minimumOrderAmount:
            minimumOrderAmount,
        usageLimit: usageLimit,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ACTIVATE COUPON
  // =====================================================

  Future<Map<String, dynamic>>
      activateCoupon(
    String couponId,
  ) async {
    try {
      return await _couponService
          .activateCoupon(
        couponId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DEACTIVATE COUPON
  // =====================================================

  Future<Map<String, dynamic>>
      deactivateCoupon(
    String couponId,
  ) async {
    try {
      return await _couponService
          .deactivateCoupon(
        couponId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // VALIDATE COUPON
  // =====================================================

  Future<Map<String, dynamic>>
      validateCoupon({
    required String code,
    required double orderAmount,
  }) async {
    try {
      return await _couponService
          .validateCoupon(
        code: code,
        orderAmount: orderAmount,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // COUPON USAGE HISTORY
  // =====================================================

  Future<List<dynamic>>
      getCouponUsageHistory(
    String couponId,
  ) async {
    try {
      return await _couponService
          .getCouponUsageHistory(
        couponId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // COUPON ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCouponAnalytics(
    String couponId,
  ) async {
    try {
      return await _couponService
          .getCouponAnalytics(
        couponId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // EXPIRED COUPONS
  // =====================================================

  Future<List<dynamic>>
      getExpiredCoupons() async {
    try {
      return await _couponService
          .getExpiredCoupons();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ACTIVE COUPONS
  // =====================================================

  Future<List<dynamic>>
      getActiveCoupons() async {
    try {
      return await _couponService
          .getActiveCoupons();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE COUPON
  // =====================================================

  Future<void> deleteCoupon(
    String couponId,
  ) async {
    try {
      await _couponService.deleteCoupon(
        couponId,
      );
    } catch (e) {
      rethrow;
    }
  }
}