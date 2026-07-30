import 'package:flutter/foundation.dart';

import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService =
      PaymentService();

  bool _isLoading = false;

  String? _errorMessage;

  List<PaymentModel> _payments = [];

  PaymentModel? _selectedPayment;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalPayments = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<PaymentModel> get payments =>
      _payments;

  PaymentModel? get selectedPayment =>
      _selectedPayment;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalPayments => _totalPayments;

  bool get hasPayments =>
      _payments.isNotEmpty;

  double get totalAmount => _payments.fold(
        0,
        (sum, item) => sum + item.finalAmount,
      );

  // =====================================================
  // GET PAYMENTS
  // =====================================================

  Future<void> getPayments({
    int page = 1,
    int limit = 20,
    String? search,
    String? paymentStatus,
    String? paymentMethod,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _paymentService.getPayments(
        page: page,
        limit: limit,
        search: search,
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
      );

      _payments =
          (response['payments'] as List? ??
                  [])
              .map(
                (e) =>
                    PaymentModel.fromJson(
                  e,
                ),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalPayments =
          response['totalPayments'] ??
              _payments.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET PAYMENT DETAILS
  // =====================================================

  Future<void> getPaymentDetails(
    String paymentId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _paymentService
              .getPaymentDetails(
        paymentId,
      );

      _selectedPayment =
          PaymentModel.fromJson(
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
  // SEARCH PAYMENTS
  // =====================================================

  Future<void> searchPayments(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _paymentService
              .searchPayments(
        keyword,
      );

      _payments =
          (response as List)
              .map(
                (e) =>
                    PaymentModel.fromJson(
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
  // MARK PAYMENT SUCCESS
  // =====================================================

  Future<bool> markPaymentSuccess(
    String paymentId,
  ) async {
    try {
      _setLoading(true);

      await _paymentService
          .markPaymentSuccess(
        paymentId,
      );

      final index =
          _payments.indexWhere(
        (e) => e.id == paymentId,
      );

      if (index != -1) {
        _payments[index] =
            _payments[index].copyWith(
          paymentStatus: 'success',
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
  // MARK PAYMENT FAILED
  // =====================================================

  Future<bool> markPaymentFailed(
    String paymentId,
  ) async {
    try {
      _setLoading(true);

      await _paymentService
          .markPaymentFailed(
        paymentId,
      );

      final index =
          _payments.indexWhere(
        (e) => e.id == paymentId,
      );

      if (index != -1) {
        _payments[index] =
            _payments[index].copyWith(
          paymentStatus: 'failed',
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
  // PROCESS REFUND
  // =====================================================

  Future<bool> processRefund({
    required String paymentId,
    required double refundAmount,
    String? reason,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _paymentService
              .processRefund(
        paymentId: paymentId,
        refundAmount: refundAmount,
        reason: reason,
      );

      final index =
          _payments.indexWhere(
        (e) => e.id == paymentId,
      );

      if (index != -1) {
        _payments[index] =
            PaymentModel.fromJson(
          response,
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
  // DELETE PAYMENT
  // =====================================================

  Future<bool> deletePayment(
    String paymentId,
  ) async {
    try {
      _setLoading(true);

      await _paymentService
          .deletePayment(
        paymentId,
      );

      _payments.removeWhere(
        (e) => e.id == paymentId,
      );

      if (_selectedPayment?.id ==
          paymentId) {
        _selectedPayment = null;
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
  // REFRESH PAYMENTS
  // =====================================================

  Future<void> refreshPayments() async {
    await getPayments(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED PAYMENT
  // =====================================================

  void clearSelectedPayment() {
    _selectedPayment = null;
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