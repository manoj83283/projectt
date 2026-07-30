import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService _instance =
      PaymentService._();

  factory PaymentService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL PAYMENTS
  // =====================================================

  Future<Map<String, dynamic>> getPayments({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? paymentMethod,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/payments',
        query: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (status != null) 'status': status,
          if (paymentMethod != null)
            'paymentMethod': paymentMethod,
          if (startDate != null)
            'startDate': startDate,
          if (endDate != null)
            'endDate': endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PAYMENT DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getPaymentDetails(
    String paymentId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/payments/$paymentId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PAYMENT TRANSACTIONS
  // =====================================================

  Future<List<dynamic>>
      getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        '/admin/payments/transactions',
        query: {
          'page': page,
          'limit': limit,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET TRANSACTION DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getTransactionDetails(
    String transactionId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/payments/transactions/$transactionId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REFUND PAYMENT
  // =====================================================

  Future<bool> refundPayment({
    required String paymentId,
    required double amount,
    required String reason,
  }) async {
    try {
      await _api.post(
        '/admin/payments/$paymentId/refund',
        data: {
          'amount': amount,
          'reason': reason,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // APPROVE PAYOUT
  // =====================================================

  Future<bool> approvePayout(
    String payoutId,
  ) async {
    try {
      await _api.patch(
        '/admin/payments/payouts/$payoutId/approve',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REJECT PAYOUT
  // =====================================================

  Future<bool> rejectPayout({
    required String payoutId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/payments/payouts/$payoutId/reject',
        data: {
          'reason': reason,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PAYOUTS
  // =====================================================

  Future<Map<String, dynamic>> getPayouts({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final response = await _api.get(
        '/admin/payments/payouts',
        query: {
          'page': page,
          'limit': limit,
          if (status != null) 'status': status,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET PAYOUT DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getPayoutDetails(
    String payoutId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/payments/payouts/$payoutId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // PAYMENT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getPaymentAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/payments/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REVENUE REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getRevenueReport({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/payments/revenue-report',
        query: {
          if (startDate != null)
            'startDate': startDate,
          if (endDate != null)
            'endDate': endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // WALLET TRANSACTIONS
  // =====================================================

  Future<List<dynamic>>
      getWalletTransactions(
    String userId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/payments/wallet/$userId',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT PAYMENTS
  // =====================================================

  Future<Response<dynamic>>
      exportPayments({
    String format = 'excel',
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _api.get(
        '/admin/payments/export',
        query: {
          'format': format,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH PAYMENTS
  // =====================================================

  Future<List<dynamic>>
      searchPayments(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/payments/search',
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
  // PAYMENT STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getPaymentStatistics() async {
    try {
      final response = await _api.get(
        '/admin/payments/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // FAILED PAYMENTS
  // =====================================================

  Future<List<dynamic>>
      getFailedPayments() async {
    try {
      final response = await _api.get(
        '/admin/payments/failed',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // RETRY PAYMENT
  // =====================================================

  Future<bool> retryPayment(
    String paymentId,
  ) async {
    try {
      await _api.post(
        '/admin/payments/$paymentId/retry',
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