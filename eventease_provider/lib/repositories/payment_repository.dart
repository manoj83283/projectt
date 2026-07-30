import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  PaymentRepository._();

  static final PaymentRepository _instance =
      PaymentRepository._();

  static PaymentRepository get instance =>
      _instance;

  final PaymentService _paymentService =
      PaymentService.instance;

  // =========================
  // GET ALL PAYMENTS
  // =========================

  Future<List<PaymentModel>>
      getPayments() async {
    try {
      return await _paymentService
          .getPayments();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET PAYMENT BY ID
  // =========================

  Future<PaymentModel> getPaymentById(
    String paymentId,
  ) async {
    try {
      return await _paymentService
          .getPaymentById(
        paymentId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET PAYMENT BY ORDER ID
  // =========================

  Future<PaymentModel>
      getPaymentByOrderId(
    String orderId,
  ) async {
    try {
      return await _paymentService
          .getPaymentByOrderId(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // PAYMENT HISTORY
  // =========================

  Future<List<PaymentModel>>
      getPaymentHistory() async {
    try {
      return await _paymentService
          .getPaymentHistory();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // TODAY PAYMENTS
  // =========================

  Future<List<PaymentModel>>
      getTodayPayments() async {
    try {
      return await _paymentService
          .getTodayPayments();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // PAYMENTS BY STATUS
  // =========================

  Future<List<PaymentModel>>
      getPaymentsByStatus(
    String status,
  ) async {
    try {
      return await _paymentService
          .getPaymentsByStatus(
        status,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET SETTLEMENTS
  // =========================

  Future<List<PaymentModel>>
      getSettlements() async {
    try {
      return await _paymentService
          .getSettlements();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // REQUEST PAYOUT
  // =========================

  Future<Map<String, dynamic>>
      requestPayout({
    required double amount,
  }) async {
    try {
      return await _paymentService
          .requestPayout(
        amount: amount,
      );
    } catch (e) {
      rethrow;
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
      return await _paymentService
          .requestRefund(
        paymentId: paymentId,
        reason: reason,
      );
    } catch (e) {
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
      return await _paymentService
          .verifyPayment(
        transactionId:
            transactionId,
      );
    } catch (e) {
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
      return await _paymentService
          .searchPayments(
        keyword,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // PAYMENT ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getPaymentAnalytics() async {
    try {
      return await _paymentService
          .getPaymentAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // TOTAL EARNINGS
  // =========================

  Future<double>
      getTotalEarnings() async {
    try {
      return await _paymentService
          .getTotalEarnings();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // AVAILABLE BALANCE
  // =========================

  Future<double>
      getAvailableBalance() async {
    try {
      return await _paymentService
          .getAvailableBalance();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // PENDING SETTLEMENT
  // =========================

  Future<double>
      getPendingSettlementAmount() async {
    try {
      return await _paymentService
          .getPendingSettlementAmount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // DOWNLOAD INVOICE
  // =========================

  Future<String?> downloadInvoice(
    String paymentId,
  ) async {
    try {
      return await _paymentService
          .downloadInvoice(
        paymentId,
      );
    } catch (e) {
      return null;
    }
  }
}