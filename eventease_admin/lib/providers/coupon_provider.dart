import 'package:flutter/foundation.dart';

import '../models/coupon_model.dart';
import '../services/coupon_service.dart';

class CouponProvider extends ChangeNotifier {
  final CouponService _couponService =
      CouponService();

  final bool _isLoading = false;

  String? _errorMessage;

  List<CouponModel> _coupons = [];

  CouponModel? _selectedCoupon;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCoupons = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<CouponModel> get coupons =>
      _coupons;

  CouponModel? get selectedCoupon =>
      _selectedCoupon;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalCoupons => _totalCoupons;

  bool get hasCoupons =>
      _coupons.isNotEmpty;

  List<CouponModel> get activeCoupons =>
      _coupons
          .where(
            (coupon) => coupon.isActive,
          )
          .toList();

  // =====================================================
  // GET COUPONS
  // =====================================================

  Future<void> getCoupons({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _couponService.getCoupons(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
      );

      _coupons =
          (response['coupons'] as List? ??
                  [])
              .map(
                (e) =>
                    CouponModel.fromJson(
                  e,
                ),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalCoupons =
          response['totalCoupons'] ??
              _coupons.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET COUPON DETAILS
  // =====================================================

  Future<void> getCouponDetails(
    String couponId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _couponService
              .getCouponDetails(
        couponId,
      );

      _selectedCoupon =
          CouponModel.fromJson(
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
  // CREATE COUPON
  // =====================================================

  Future<bool> createCoupon({
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
      _setLoading(true);

      final response =
          await _couponService.createCoupon(
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

      final coupon =
          CouponModel.fromJson(
        response,
      );

      _coupons.insert(0, coupon);

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
  // UPDATE COUPON
  // =====================================================

  Future<bool> updateCoupon({
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
      _setLoading(true);

      final response =
          await _couponService.updateCoupon(
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

      final updatedCoupon =
          CouponModel.fromJson(
        response,
      );

      final index =
          _coupons.indexWhere(
        (e) => e.id == couponId,
      );

      if (index != -1) {
        _coupons[index] =
            updatedCoupon;
      }

      if (_selectedCoupon?.id ==
          couponId) {
        _selectedCoupon =
            updatedCoupon;
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
  // ACTIVATE COUPON
  // =====================================================

  Future<bool> activateCoupon(
    String couponId,
  ) async {
    try {
      _setLoading(true);

      await _couponService.activateCoupon(
        couponId,
      );

      final index =
          _coupons.indexWhere(
        (e) => e.id == couponId,
      );

      if (index != -1) {
        _coupons[index] =
            _coupons[index].copyWith(
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
  // DEACTIVATE COUPON
  // =====================================================

  Future<bool> deactivateCoupon(
    String couponId,
  ) async {
    try {
      _setLoading(true);

      await _couponService
          .deactivateCoupon(
        couponId,
      );

      final index =
          _coupons.indexWhere(
        (e) => e.id == couponId,
      );

      if (index != -1) {
        _coupons[index] =
            _coupons[index].copyWith(
          isActive: false,
        );
      }

      notifyListeners();

      return true
    }
  }
}