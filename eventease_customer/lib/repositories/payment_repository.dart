import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  PaymentRepository._();

  static final PaymentRepository instance =
      PaymentRepository._();

  final PaymentService _paymentService =
      PaymentService.instance;

  // ==========================================
  // CREATE PAYMENT ORDER
  // ==========================================

  Future<Map<String, dynamic>>
      createPaymentOrder({
    required String bookingId,
    required double amount,
    required String paymentMethod,
  }) async {
    return await _paymentService
        .createPaymentOrder(
      bookingId: bookingId,
      amount: amount,
      paymentMethod: paymentMethod,
    );
  }

  // ==========================================
  // VERIFY PAYMENT
  // ==========================================

  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    return await _paymentService
        .verifyPayment(
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
  }

  // ==========================================
  // GET PAYMENT BY ID
  // ==========================================

  Future<PaymentModel> getPaymentById(
    String paymentId,
  ) async {
    return await _paymentService
        .getPaymentById(paymentId);
  }

  // ==========================================
  // PAYMENT HISTORY
  // ==========================================

  Future<List<PaymentModel>>
      getPaymentHistory({
    int page = 1,
    int limit = 20,
  }) async {
    return await _paymentService
        .getPaymentHistory(
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // PAYMENT STATUS
  // ==========================================

  Future<String> getPaymentStatus(
    String paymentId,
  ) async {
    return await _paymentService
        .getPaymentStatus(paymentId);
  }

  // ==========================================
  // REFUND PAYMENT
  // ==========================================

  Future<bool> refundPayment({
    required String paymentId,
    required String reason,
  }) async {
    return await _paymentService
        .refundPayment(
      paymentId: paymentId,
      reason: reason,
    );
  }

  // ==========================================
  // DOWNLOAD INVOICE
  // ==========================================

  Future<String> downloadInvoice(
    String paymentId,
  ) async {
    return await _paymentService
        .downloadInvoice(paymentId);
  }

  // ==========================================
  // WALLET PAYMENT
  // ==========================================

  Future<bool> payUsingWallet({
    required String bookingId,
    required double amount,
  }) async {
    return await _paymentService
        .payUsingWallet(
      bookingId: bookingId,
      amount: amount,
    );
  }

  // ==========================================
  // UPI PAYMENT
  // ==========================================

  Future<Map<String, dynamic>>
      createUpiPayment({
    required String bookingId,
    required double amount,
  }) async {
    return await _paymentService
        .createUpiPayment(
      bookingId: bookingId,
      amount: amount,
    );
  }

  // ==========================================
  // CARD PAYMENT
  // ==========================================

  Future<Map<String, dynamic>>
      createCardPayment({
    required String bookingId,
    required double amount,
  }) async {
    return await _paymentService
        .createCardPayment(
      bookingId: bookingId,
      amount: amount,
    );
  }

  // ==========================================
  // PAYMENT SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getPaymentSummary() async {
    return await _paymentService
        .getPaymentSummary();
  }

  // ==========================================
  // DELETE PAYMENT
  // ==========================================

  Future<bool> deletePayment(
    String paymentId,
  ) async {
    return await _paymentService
        .deletePayment(paymentId);
  }
}