import '../models/coupon_model.dart';
import 'api_service.dart';

class CouponService {
  CouponService._();

  static final CouponService instance =
      CouponService._();

  // ==========================================
  // GET ALL COUPONS
  // ==========================================

  Future<List<CouponModel>> getCoupons({
    int page = 1,
    int limit = 20,
  }) async {
    final response =
        await ApiService.instance.get(
      '/coupons',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List coupons =
        response.data['data'] ??
            response.data['coupons'] ??
            [];

    return coupons
        .map(
          (e) => CouponModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET AVAILABLE COUPONS
  // ==========================================

  Future<List<CouponModel>>
      getAvailableCoupons() async {
    final response =
        await ApiService.instance.get(
      '/coupons/available',
    );

    final List coupons =
        response.data['data'] ??
            response.data['coupons'] ??
            [];

    return coupons
        .map(
          (e) => CouponModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET COUPON BY CODE
  // ==========================================

  Future<CouponModel> getCouponByCode(
    String code,
  ) async {
    final response =
        await ApiService.instance.get(
      '/coupons/code/$code',
    );

    return CouponModel.fromMap(
      response.data['data'] ??
          response.data['coupon'],
    );
  }

  // ==========================================
  // VALIDATE COUPON
  // ==========================================

  Future<Map<String, dynamic>>
      validateCoupon({
    required String couponCode,
    required double orderAmount,
  }) async {
    final response =
        await ApiService.instance.post(
      '/coupons/validate',
      data: {
        'couponCode': couponCode,
        'orderAmount': orderAmount,
      },
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // APPLY COUPON
  // ==========================================

  Future<Map<String, dynamic>>
      applyCoupon({
    required String couponCode,
    required double orderAmount,
  }) async {
    final response =
        await ApiService.instance.post(
      '/coupons/apply',
      data: {
        'couponCode': couponCode,
        'orderAmount': orderAmount,
      },
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // REMOVE COUPON
  // ==========================================

  Future<bool> removeCoupon(
    String couponCode,
  ) async {
    await ApiService.instance.delete(
      '/coupons/remove/$couponCode',
    );

    return true;
  }

  // ==========================================
  // COUPON HISTORY
  // ==========================================

  Future<List<CouponModel>>
      getCouponHistory() async {
    final response =
        await ApiService.instance.get(
      '/coupons/history',
    );

    final List coupons =
        response.data['data'] ??
            response.data['coupons'] ??
            [];

    return coupons
        .map(
          (e) => CouponModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // CREATE COUPON (ADMIN)
  // ==========================================

  Future<CouponModel> createCoupon({
    required String code,
    required String title,
    required String description,
    required double discount,
    required String discountType,
    required double minOrderAmount,
    required DateTime expiryDate,
  }) async {
    final response =
        await ApiService.instance.post(
      '/coupons',
      data: {
        'code': code,
        'title': title,
        'description': description,
        'discount': discount,
        'discountType': discountType,
        'minOrderAmount':
            minOrderAmount,
        'expiryDate':
            expiryDate.toIso8601String(),
      },
    );

    return CouponModel.fromMap(
      response.data['data'] ??
          response.data['coupon'],
    );
  }

  // ==========================================
  // UPDATE COUPON (ADMIN)
  // ==========================================

  Future<CouponModel> updateCoupon({
    required String couponId,
    required Map<String, dynamic> data,
  }) async {
    final response =
        await ApiService.instance.patch(
      '/coupons/$couponId',
      data: data,
    );

    return CouponModel.fromMap(
      response.data['data'] ??
          response.data['coupon'],
    );
  }

  // ==========================================
  // DELETE COUPON (ADMIN)
  // ==========================================

  Future<bool> deleteCoupon(
    String couponId,
  ) async {
    await ApiService.instance.delete(
      '/coupons/$couponId',
    );

    return true;
  }

  // ==========================================
  // COUPON DETAILS
  // ==========================================

  Future<CouponModel> getCouponDetails(
    String couponId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/coupons/$couponId',
    );

    return CouponModel.fromMap(
      response.data['data'] ??
          response.data['coupon'],
    );
  }
}