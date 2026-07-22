import '../models/payment_model.dart';
import 'api_service.dart';

class PaymentService {
  PaymentService._();

  static final PaymentService instance =
      PaymentService._();

  // ==========================================
  // CREATE PAYMENT ORDER
  // ==========================================

  Future<Map<String, dynamic>>
      createPaymentOrder({
    required String bookingId,
    required double amount,
    required String paymentMethod,
  }) async {
    final response =
        await ApiService.instance.post(
      '/payments/create-order',
      data: {
        'bookingId': bookingId,
        'amount': amount,
        'paymentMethod': paymentMethod,
      },
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // VERIFY PAYMENT
  // ==========================================

  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    await ApiService.instance.post(
      '/payments/verify',
      data: {
        'razorpayOrderId':
            razorpayOrderId,
        'razorpayPaymentId':
            razorpayPaymentId,
        'razorpaySignature':
            razorpaySignature,
      },
    );

    return true;
  }

  // ==========================================
  // GET PAYMENT BY ID
  // ==========================================

  Future<PaymentModel> getPaymentById(
    String paymentId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/payments/$paymentId',
    );

    return PaymentModel.fromMap(
      response.data['data'] ??
          response.data['payment'],
    );
  }

  // ==========================================
  // PAYMENT HISTORY
  // ==========================================

  Future<List<PaymentModel>>
      getPaymentHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response =
        await ApiService.instance.get(
      '/payments/history',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List payments =
        response.data['data'] ??
            response.data['payments'] ??
            [];

    return payments
        .map(
          (e) => PaymentModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // PAYMENT STATUS
  // ==========================================

  Future<String> getPaymentStatus(
    String paymentId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/payments/$paymentId/status',
    );

    return response.data['status'] ??
        response.data['data']
            ?['status'] ??
        'pending';
  }

  // ==========================================
  // REFUND PAYMENT
  // ==========================================

  Future<bool> refundPayment({
    required String paymentId,
    required String reason,
  }) async {
    await ApiService.instance.post(
      '/payments/refund',
      data: {
        'paymentId': paymentId,
        'reason': reason,
      },
    );

    return true;
  }

  // ==========================================
  // DOWNLOAD INVOICE
  // ==========================================

  Future<String> downloadInvoice(
    String paymentId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/payments/$paymentId/invoice',
    );

    return response.data['invoiceUrl'] ??
        response.data['data']
            ?['invoiceUrl'] ??
        '';
  }

  // ==========================================
  // WALLET PAYMENT
  // ==========================================

  Future<bool> payUsingWallet({
    required String bookingId,
    required double amount,
  }) async {
    await ApiService.instance.post(
      '/payments/wallet',
      data: {
        'bookingId': bookingId,
        'amount': amount,
      },
    );

    return true;
  }

  // ==========================================
  // UPI PAYMENT
  // ==========================================

  Future<Map<String, dynamic>>
      createUpiPayment({
    required String bookingId,
    required double amount,
  }) async {
    final response =
        await ApiService.instance.post(
      '/payments/upi',
      data: {
        'bookingId': bookingId,
        'amount': amount,
      },
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // CARD PAYMENT
  // ==========================================

  Future<Map<String, dynamic>>
      createCardPayment({
    required String bookingId,
    required double amount,
  }) async {
    final response =
        await ApiService.instance.post(
      '/payments/card',
      data: {
        'bookingId': bookingId,
        'amount': amount,
      },
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // PAYMENT SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getPaymentSummary() async {
    final response =
        await ApiService.instance.get(
      '/payments/summary',
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // DELETE PAYMENT
  // ==========================================

  Future<bool> deletePayment(
    String paymentId,
  ) async {
    await ApiService.instance.delete(
      '/payments/$paymentId',
    );

    return true;
  }
}