import '../services/payment_service.dart';

class PaymentRepository {
  final PaymentService _paymentService;

  PaymentRepository({
    PaymentService? paymentService,
  }) : _paymentService =
            paymentService ??
                PaymentService();

  // =====================================================
  // GET PAYMENTS
  // =====================================================

  Future<Map<String, dynamic>> getPayments({
    int page = 1,
    int limit = 20,
    String? search,
    String? paymentStatus,
    String? paymentMethod,
    String? customerId,
    String? providerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _paymentService.getPayments(
        page: page,
        limit: limit,
        search: search,
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
        customerId: customerId,
        providerId: providerId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
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
      return await _paymentService
          .getPaymentDetails(
        paymentId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH PAYMENTS
  // =====================================================

  Future<List<dynamic>> searchPayments(
    String keyword,
  ) async {
    try {
      return await _paymentService
          .searchPayments(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // MARK PAYMENT SUCCESS
  // =====================================================

  Future<Map<String, dynamic>>
      markPaymentSuccess(
    String paymentId,
  ) async {
    try {
      return await _paymentService
          .markPaymentSuccess(
        paymentId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // MARK PAYMENT FAILED
  // =====================================================

  Future<Map<String, dynamic>>
      markPaymentFailed(
    String paymentId,
  ) async {
    try {
      return await _paymentService
          .markPaymentFailed(
        paymentId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROCESS REFUND
  // =====================================================

  Future<Map<String, dynamic>>
      processRefund({
    required String paymentId,
    required double refundAmount,
    String? reason,
  }) async {
    try {
      return await _paymentService
          .processRefund(
        paymentId: paymentId,
        refundAmount: refundAmount,
        reason: reason,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PAYMENT TRANSACTIONS
  // =====================================================

  Future<List<dynamic>>
      getPaymentTransactions(
    String paymentId,
  ) async {
    try {
      return await _paymentService
          .getPaymentTransactions(
        paymentId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER PAYMENTS
  // =====================================================

  Future<List<dynamic>>
      getCustomerPayments(
    String customerId,
  ) async {
    try {
      return await _paymentService
          .getCustomerPayments(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER PAYMENTS
  // =====================================================

  Future<List<dynamic>>
      getProviderPayments(
    String providerId,
  ) async {
    try {
      return await _paymentService
          .getProviderPayments(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PAYMENT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getPaymentAnalytics() async {
    try {
      return await _paymentService
          .getPaymentAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REVENUE ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _paymentService
          .getRevenueAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PAYMENT REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generatePaymentReport({
    DateTime? startDate,
    DateTime? endDate,
    String? paymentMethod,
  }) async {
    try {
      return await _paymentService
          .generatePaymentReport(
        startDate: startDate,
        endDate: endDate,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE PAYMENT
  // =====================================================

  Future<void> deletePayment(
    String paymentId,
  ) async {
    try {
      await _paymentService
          .deletePayment(
        paymentId,
      );
    } catch (e) {
      rethrow;
    }
  }
}