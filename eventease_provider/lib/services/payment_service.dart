import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/payment_model.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService _instance =
      PaymentService._();

  static PaymentService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // GET ALL PAYMENTS
  // =========================

  Future<List<PaymentModel>> getPayments() async {
    try {
      final response = await _apiService.get(
        '/provider/payments',
      );

      final List<dynamic> payments =
          response['data'] ?? [];

      return payments
          .map(
            (e) => PaymentModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Get Payments Error: $e');
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
      final response = await _apiService.get(
        '/provider/payments/$paymentId',
      );

      return PaymentModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Get Payment Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET PAYMENT BY ORDER ID
  // =========================

  Future<PaymentModel> getPaymentByOrderId(
    String orderId,
  ) async {
    try {
      final response = await _apiService.get(
        '/provider/payments/order/$orderId',
      );

      return PaymentModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Get Payment By Order Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET PAYMENT HISTORY
  // =========================

  Future<List<PaymentModel>>
      getPaymentHistory() async {
    try {
      final response = await _apiService.get(
        '/provider/payments/history',
      );

      final List<dynamic> payments =
          response['data'] ?? [];

      return payments
          .map(
            (e) => PaymentModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Payment History Error: $e');
      return [];
    }
  }

  // =========================
  // GET TODAY PAYMENTS
  // =========================

  Future<List<PaymentModel>>
      getTodayPayments() async {
    try {
      final response = await _apiService.get(
        '/provider/payments/today',
      );

      final List<dynamic> payments =
          response['data'] ?? [];

      return payments
          .map(
            (e) => PaymentModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Today Payments Error: $e');
      return [];
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
      final response = await _apiService.get(
        '/provider/payments/status/$status',
      );

      final List<dynamic> payments =
          response['data'] ?? [];

      return payments
          .map(
            (e) => PaymentModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log(
        'Get Payments By Status Error: $e',
      );
      return [];
    }
  }

  // =========================
  // GET SETTLEMENTS
  // =========================

  Future<List<PaymentModel>>
      getSettlements() async {
    try {
      final response = await _apiService.get(
        '/provider/settlements',
      );

      final List<dynamic> payments =
          response['data'] ?? [];

      return payments
          .map(
            (e) => PaymentModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Get Settlements Error: $e');
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
      return await _apiService.post(
        '/provider/payout/request',
        body: {
          'amount': amount,
        },
      );
    } catch (e) {
      log('Request Payout Error: $e');
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
      await _apiService.post(
        '/provider/payments/$paymentId/refund',
        body: {
          'reason': reason,
        },
      );

      return true;
    } catch (e) {
      log('Refund Request Error: $e');
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
      await _apiService.post(
        '/provider/payments/verify',
        body: {
          'transactionId':
              transactionId,
        },
      );

      return true;
    } catch (e) {
      log('Verify Payment Error: $e');
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
      final response = await _apiService.get(
        '/provider/payments/search?keyword=$keyword',
      );

      final List<dynamic> payments =
          response['data'] ?? [];

      return payments
          .map(
            (e) => PaymentModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Search Payments Error: $e');
      return [];
    }
  }

  // =========================
  // PAYMENT ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getPaymentAnalytics() async {
    try {
      return await _apiService.get(
        '/provider/payments/analytics',
      );
    } catch (e) {
      log('Payment Analytics Error: $e');
      rethrow;
    }
  }

  // =========================
  // TOTAL EARNINGS
  // =========================

  Future<double> getTotalEarnings() async {
    try {
      final response = await _apiService.get(
        '/provider/payments/total-earnings',
      );

      return (response['amount'] ?? 0)
          .toDouble();
    } catch (e) {
      log('Total Earnings Error: $e');
      return 0;
    }
  }

  // =========================
  // AVAILABLE BALANCE
  // =========================

  Future<double>
      getAvailableBalance() async {
    try {
      final response = await _apiService.get(
        '/provider/payments/available-balance',
      );

      return (response['amount'] ?? 0)
          .toDouble();
    } catch (e) {
      log('Available Balance Error: $e');
      return 0;
    }
  }

  // =========================
  // PENDING SETTLEMENT
  // =========================

  Future<double>
      getPendingSettlementAmount() async {
    try {
      final response = await _apiService.get(
        '/provider/payments/pending-settlement',
      );

      return (response['amount'] ?? 0)
          .toDouble();
    } catch (e) {
      log('Pending Settlement Error: $e');
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
      final response = await _apiService.get(
        '/provider/payments/$paymentId/invoice',
      );

      return response['url']
          ?.toString();
    } catch (e) {
      log('Download Invoice Error: $e');
      return null;
    }
  }
}