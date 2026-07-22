import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider();

  final PaymentRepository _repository =
      PaymentRepository.instance;

  List<PaymentModel> _payments = [];

  PaymentModel? _selectedPayment;

  bool _isLoading = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  List<PaymentModel> get payments =>
      _payments;

  PaymentModel? get selectedPayment =>
      _selectedPayment;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // ==========================================
  // SET LOADING
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // SET ERROR
  // ==========================================

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ==========================================
  // CREATE PAYMENT ORDER
  // ==========================================

  Future<Map<String, dynamic>>
      createPaymentOrder({
    required String bookingId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .createPaymentOrder(
        bookingId: bookingId,
        amount: amount,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // VERIFY PAYMENT
  // ==========================================

  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      _setLoading(true);

      return await _repository.verifyPayment(
        razorpayOrderId:
            razorpayOrderId,
        razorpayPaymentId:
            razorpayPaymentId,
        razorpaySignature:
            razorpaySignature,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PAYMENT DETAILS
  // ==========================================

  Future<void> getPaymentById(
    String paymentId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _selectedPayment =
          await _repository.getPaymentById(
        paymentId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PAYMENT HISTORY
  // ==========================================

  Future<void> getPaymentHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _payments =
          await _repository.getPaymentHistory(
        page: page,
        limit: limit,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PAYMENT STATUS
  // ==========================================

  Future<String> getPaymentStatus(
    String paymentId,
  ) async {
    try {
      return await _repository
          .getPaymentStatus(paymentId);
    } catch (e) {
      _setError(e.toString());
      return '';
    }
  }

  // ==========================================
  // REFUND PAYMENT
  // ==========================================

  Future<bool> refundPayment({
    required String paymentId,
    required String reason,
  }) async {
    try {
      _setLoading(true);

      return await _repository.refundPayment(
        paymentId: paymentId,
        reason: reason,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // DOWNLOAD INVOICE
  // ==========================================

  Future<String> downloadInvoice(
    String paymentId,
  ) async {
    try {
      return await _repository
          .downloadInvoice(paymentId);
    } catch (e) {
      _setError(e.toString());
      return '';
    }
  }

  // ==========================================
  // WALLET PAYMENT
  // ==========================================

  Future<bool> payUsingWallet({
    required String bookingId,
    required double amount,
  }) async {
    try {
      _setLoading(true);

      return await _repository.payUsingWallet(
        bookingId: bookingId,
        amount: amount,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // UPI PAYMENT
  // ==========================================

  Future<Map<String, dynamic>>
      createUpiPayment({
    required String bookingId,
    required double amount,
  }) async {
    try {
      _setLoading(true);

      return await _repository
          .createUpiPayment(
        bookingId: bookingId,
        amount: amount,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CARD PAYMENT
  // ==========================================

  Future<Map<String, dynamic>>
      createCardPayment({
    required String bookingId,
    required double amount,
  }) async {
    try {
      _setLoading(true);

      return await _repository
          .createCardPayment(
        bookingId: bookingId,
        amount: amount,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PAYMENT SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getPaymentSummary() async {
    try {
      return await _repository
          .getPaymentSummary();
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // DELETE PAYMENT
  // ==========================================

  Future<bool> deletePayment(
    String paymentId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.deletePayment(
        paymentId,
      );

      if (success) {
        _payments.removeWhere(
          (e) => e.id == paymentId,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SELECT PAYMENT
  // ==========================================

  void setSelectedPayment(
    PaymentModel payment,
  ) {
    _selectedPayment = payment;
    notifyListeners();
  }

  // ==========================================
  // CLEAR PAYMENT
  // ==========================================

  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==========================================
  // RESET
  // ==========================================

  void reset() {
    _payments.clear();

    _selectedPayment = null;
    _error = null;

    notifyListeners();
  }
}