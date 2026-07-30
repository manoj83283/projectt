import 'package:flutter/foundation.dart';

import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository =
      PaymentRepository.instance;

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;

  String? _errorMessage;

  List<PaymentModel> _payments = [];

  List<PaymentModel> _todayPayments = [];

  List<PaymentModel> _paymentHistory = [];

  List<PaymentModel> _settlements = [];

  PaymentModel? _selectedPayment;

  Map<String, dynamic> _analytics = {};

  double _totalEarnings = 0;

  double _availableBalance = 0;

  double _pendingSettlement = 0;

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<PaymentModel> get payments =>
      _payments;

  List<PaymentModel> get todayPayments =>
      _todayPayments;

  List<PaymentModel> get paymentHistory =>
      _paymentHistory;

  List<PaymentModel> get settlements =>
      _settlements;

  PaymentModel? get selectedPayment =>
      _selectedPayment;

  Map<String, dynamic> get analytics =>
      _analytics;

  double get totalEarnings =>
      _totalEarnings;

  double get availableBalance =>
      _availableBalance;

  double get pendingSettlement =>
      _pendingSettlement;

  // =========================
  // HELPERS
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // GET PAYMENTS
  // =========================

  Future<void> getPayments() async {
    try {
      _setLoading(true);

      _payments =
          await _repository.getPayments();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET PAYMENT BY ID
  // =========================

  Future<PaymentModel?> getPaymentById(
    String paymentId,
  ) async {
    try {
      _setLoading(true);

      _selectedPayment =
          await _repository.getPaymentById(
        paymentId,
      );

      notifyListeners();

      return _selectedPayment;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET PAYMENT BY ORDER ID
  // =========================

  Future<PaymentModel?>
      getPaymentByOrderId(
    String orderId,
  ) async {
    try {
      return await _repository
          .getPaymentByOrderId(orderId);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  // =========================
  // GET PAYMENT HISTORY
  // =========================

  Future<void> getPaymentHistory() async {
    try {
      _paymentHistory =
          await _repository
              .getPaymentHistory();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // TODAY PAYMENTS
  // =========================

  Future<void> getTodayPayments() async {
    try {
      _todayPayments =
          await _repository
              .getTodayPayments();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // GET PAYMENTS BY STATUS
  // =========================

  Future<List<PaymentModel>>
      getPaymentsByStatus(
    String status,
  ) async {
    try {
      return await _repository
          .getPaymentsByStatus(status);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // =========================
  // GET SETTLEMENTS
  // =========================

  Future<void> getSettlements() async {
    try {
      _settlements =
          await _repository
              .getSettlements();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // REQUEST PAYOUT
  // =========================

  Future<bool> requestPayout({
    required double amount,
  }) async {
    try {
      _setLoading(true);

      await _repository.requestPayout(
        amount: amount,
      );

      await refreshFinancialData();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // REQUEST REFUND
  // =========================

  Future<bool> requestRefund({
    required String paymentId,
    required String reason,
  }) async {
    try {
      return await _repository
          .requestRefund(
        paymentId: paymentId,
        reason: reason,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // VERIFY PAYMENT
  // =========================

  Future<bool> verifyPayment({
    required String transactionId,
  }) async {
    try {
      return await _repository
          .verifyPayment(
        transactionId:
            transactionId,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // SEARCH PAYMENTS
  // =========================

  Future<List<PaymentModel>>
      searchPayments(
    String keyword,
  ) async {
    try {
      return await _repository
          .searchPayments(keyword);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // =========================
  // PAYMENT ANALYTICS
  // =========================

  Future<void>
      getPaymentAnalytics() async {
    try {
      _analytics =
          await _repository
              .getPaymentAnalytics();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // TOTAL EARNINGS
  // =========================

  Future<void>
      getTotalEarnings() async {
    try {
      _totalEarnings =
          await _repository
              .getTotalEarnings();

      notifyListeners();
    } catch (e) {
      _totalEarnings = 0;
    }
  }

  // =========================
  // AVAILABLE BALANCE
  // =========================

  Future<void>
      getAvailableBalance() async {
    try {
      _availableBalance =
          await _repository
              .getAvailableBalance();

      notifyListeners();
    } catch (e) {
      _availableBalance = 0;
    }
  }

  // =========================
  // PENDING SETTLEMENT
  // =========================

  Future<void>
      getPendingSettlementAmount() async {
    try {
      _pendingSettlement =
          await _repository
              .getPendingSettlementAmount();

      notifyListeners();
    } catch (e) {
      _pendingSettlement = 0;
    }
  }

  // =========================
  // DOWNLOAD INVOICE
  // =========================

  Future<String?> downloadInvoice(
    String paymentId,
  ) async {
    try {
      return await _repository
          .downloadInvoice(
        paymentId,
      );
    } catch (e) {
      return null;
    }
  }

  // =========================
  // REFRESH FINANCIAL DATA
  // =========================

  Future<void>
      refreshFinancialData() async {
    await Future.wait([
      getTotalEarnings(),
      getAvailableBalance(),
      getPendingSettlementAmount(),
    ]);
  }

  // =========================
  // REFRESH ALL
  // =========================

  Future<void> refreshData() async {
    await Future.wait([
      getPayments(),
      getTodayPayments(),
      getPaymentHistory(),
      getSettlements(),
      getPaymentAnalytics(),
      refreshFinancialData(),
    ]);
  }

  // =========================
  // RESET
  // =========================

  void reset() {
    _payments = [];
    _todayPayments = [];
    _paymentHistory = [];
    _settlements = [];
    _selectedPayment = null;
    _analytics = {};

    _totalEarnings = 0;
    _availableBalance = 0;
    _pendingSettlement = 0;

    _errorMessage = null;

    notifyListeners();
  }
}