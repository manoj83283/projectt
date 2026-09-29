import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderRepository {
  OrderRepository._();

  static final OrderRepository _instance =
      OrderRepository._();

  static OrderRepository get instance {
    return _instance;
  }

  final OrderService _orderService =
      OrderService.instance;

  // =====================================================
  // GET ALL ORDERS
  // =====================================================

  Future<List<OrderModel>> getOrders({
    int page = 1,
    int limit = 100,
    String? status,
  }) {
    return _orderService.getOrders(
      page: page,
      limit: limit,
      status: status,
    );
  }

  // =====================================================
  // GET ORDER BY ID
  // =====================================================

  Future<OrderModel> getOrderById(
    String orderId,
  ) {
    return _orderService.getOrderById(
      orderId,
    );
  }

  // =====================================================
  // GET TODAY ORDERS
  // =====================================================

  Future<List<OrderModel>> getTodayOrders() async {
    try {
      return await _orderService.getTodayOrders();
    } catch (_) {
      return <OrderModel>[];
    }
  }

  // =====================================================
  // GET RECENT ORDERS
  // =====================================================

  Future<List<OrderModel>> getRecentOrders() async {
    try {
      return await _orderService.getRecentOrders();
    } catch (_) {
      return <OrderModel>[];
    }
  }

  // =====================================================
  // GET ORDERS BY STATUS
  // =====================================================

  Future<List<OrderModel>> getOrdersByStatus(
    String status,
  ) async {
    try {
      return await _orderService.getOrdersByStatus(
        status,
      );
    } catch (_) {
      return <OrderModel>[];
    }
  }

  // =====================================================
  // UPDATE ORDER STATUS
  // =====================================================

  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
    String? reason,
    String? note,
  }) {
    return _orderService.updateOrderStatus(
      orderId: orderId,
      status: status,
      reason: reason,
      note: note,
    );
  }

  // =====================================================
  // CONFIRM ORDER
  //
  // pending -> accepted
  // =====================================================

  Future<bool> confirmOrder(
    String orderId,
  ) {
    return _orderService.confirmOrder(
      orderId,
    );
  }

  // =====================================================
  // ACCEPT ORDER
  //
  // Compatibility alias for confirmOrder.
  // =====================================================

  Future<bool> acceptOrder(
    String orderId,
  ) {
    return _orderService.acceptOrder(
      orderId,
    );
  }

  // =====================================================
  // VERIFY SERVICE OTP
  //
  // accepted -> otp_verified
  // =====================================================

  Future<OrderModel> verifyServiceOtp({
    required String orderId,
    required String otp,
  }) {
    return _orderService.verifyServiceOtp(
      orderId: orderId,
      otp: otp,
    );
  }

  // =====================================================
  // START ORDER
  //
  // otp_verified -> in_progress
  // =====================================================

  Future<bool> startOrder(
    String orderId,
  ) {
    return _orderService.startOrder(
      orderId,
    );
  }

  // =====================================================
  // COMPLETE ORDER
  //
  // in_progress -> completed
  // =====================================================

  Future<bool> completeOrder(
    String orderId,
  ) {
    return _orderService.completeOrder(
      orderId,
    );
  }

  // =====================================================
  // REJECT ORDER
  //
  // pending -> rejected
  // =====================================================

  Future<bool> rejectOrder({
    required String orderId,
    required String reason,
  }) {
    return _orderService.rejectOrder(
      orderId: orderId,
      reason: reason,
    );
  }

  // =====================================================
  // CANCEL ORDER
  //
  // accepted -> cancelled
  // otp_verified -> cancelled
  // in_progress -> cancelled
  // =====================================================

  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) {
    return _orderService.cancelOrder(
      orderId: orderId,
      reason: reason,
    );
  }

  // =====================================================
  // REFUND ORDER
  //
  // Retained for compatibility. The current booking
  // backend does not implement Provider refund processing.
  // =====================================================

  Future<bool> refundOrder({
    required String orderId,
    required String reason,
  }) {
    return _orderService.refundOrder(
      orderId: orderId,
      reason: reason,
    );
  }

  // =====================================================
  // SEARCH ORDERS
  // =====================================================

  Future<List<OrderModel>> searchOrders(
    String keyword,
  ) async {
    try {
      return await _orderService.searchOrders(
        keyword,
      );
    } catch (_) {
      return <OrderModel>[];
    }
  }

  // =====================================================
  // ORDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderAnalytics() {
    return _orderService.getOrderAnalytics();
  }

  // =====================================================
  // TOTAL ORDER COUNT
  // =====================================================

  Future<int> getOrderCount() async {
    try {
      return await _orderService.getOrderCount();
    } catch (_) {
      final analytics =
          await _safeAnalytics();

      return _analyticsInt(
        analytics,
        'totalOrders',
        'totalBookings',
      );
    }
  }

  // =====================================================
  // PENDING ORDER COUNT
  // =====================================================

  Future<int> getPendingOrderCount() async {
    try {
      return await _orderService
          .getPendingOrderCount();
    } catch (_) {
      final analytics =
          await _safeAnalytics();

      return _analyticsInt(
        analytics,
        'pendingOrders',
        'pendingBookings',
      );
    }
  }

  // =====================================================
  // ACCEPTED ORDER COUNT
  // =====================================================

  Future<int> getAcceptedOrderCount() async {
    final analytics =
        await _safeAnalytics();

    return _analyticsInt(
      analytics,
      'acceptedOrders',
      'acceptedBookings',
    );
  }

  // =====================================================
  // OTP VERIFIED ORDER COUNT
  // =====================================================

  Future<int> getOtpVerifiedOrderCount() async {
    final analytics =
        await _safeAnalytics();

    return _analyticsInt(
      analytics,
      'otpVerifiedOrders',
      'otpVerifiedBookings',
    );
  }

  // =====================================================
  // IN-PROGRESS ORDER COUNT
  // =====================================================

  Future<int> getInProgressOrderCount() async {
    final analytics =
        await _safeAnalytics();

    return _analyticsInt(
      analytics,
      'inProgressOrders',
      'inProgressBookings',
    );
  }

  // =====================================================
  // COMPLETED ORDER COUNT
  // =====================================================

  Future<int> getCompletedOrderCount() async {
    try {
      return await _orderService
          .getCompletedOrderCount();
    } catch (_) {
      final analytics =
          await _safeAnalytics();

      return _analyticsInt(
        analytics,
        'completedOrders',
        'completedBookings',
      );
    }
  }

  // =====================================================
  // CANCELLED ORDER COUNT
  // =====================================================

  Future<int> getCancelledOrderCount() async {
    final analytics =
        await _safeAnalytics();

    return _analyticsInt(
      analytics,
      'cancelledOrders',
      'cancelledBookings',
    );
  }

  // =====================================================
  // REJECTED ORDER COUNT
  // =====================================================

  Future<int> getRejectedOrderCount() async {
    final analytics =
        await _safeAnalytics();

    return _analyticsInt(
      analytics,
      'rejectedOrders',
      'rejectedBookings',
    );
  }

  // =====================================================
  // TOTAL REVENUE
  // =====================================================

  Future<double> getTotalRevenue() async {
    try {
      return await _orderService.getTotalRevenue();
    } catch (_) {
      final analytics =
          await _safeAnalytics();

      return _analyticsDouble(
        analytics,
        'totalRevenue',
        'totalEarnings',
      );
    }
  }

  // =====================================================
  // GET INVOICE DATA
  // =====================================================

  Future<Map<String, dynamic>> getInvoice(
    String orderId,
  ) {
    return _orderService.getInvoice(
      orderId,
    );
  }

  // =====================================================
  // DOWNLOAD INVOICE
  //
  // Returns invoiceUrl when one exists in the backend
  // invoice response.
  // =====================================================

  Future<String?> downloadInvoice(
    String orderId,
  ) {
    return _orderService.downloadInvoice(
      orderId,
    );
  }

  // =====================================================
  // COMPATIBILITY: GET BOOKING
  // =====================================================

  Future<OrderModel> getBookingById(
    String bookingId,
  ) {
    return getOrderById(
      bookingId,
    );
  }

  // =====================================================
  // COMPATIBILITY: UPDATE BOOKING STATUS
  // =====================================================

  Future<OrderModel> updateBookingStatus({
    required String bookingId,
    required String status,
    String? reason,
    String? note,
  }) {
    return updateOrderStatus(
      orderId: bookingId,
      status: status,
      reason: reason,
      note: note,
    );
  }

  // =====================================================
  // COMPATIBILITY: ACCEPT BOOKING
  // =====================================================

  Future<bool> acceptBooking(
    String bookingId,
  ) {
    return acceptOrder(
      bookingId,
    );
  }

  // =====================================================
  // COMPATIBILITY: VERIFY BOOKING OTP
  // =====================================================

  Future<OrderModel> verifyBookingOtp({
    required String bookingId,
    required String otp,
  }) {
    return verifyServiceOtp(
      orderId: bookingId,
      otp: otp,
    );
  }

  // =====================================================
  // COMPATIBILITY: START BOOKING
  // =====================================================

  Future<bool> startBooking(
    String bookingId,
  ) {
    return startOrder(
      bookingId,
    );
  }

  // =====================================================
  // COMPATIBILITY: COMPLETE BOOKING
  // =====================================================

  Future<bool> completeBooking(
    String bookingId,
  ) {
    return completeOrder(
      bookingId,
    );
  }

  // =====================================================
  // COMPATIBILITY: REJECT BOOKING
  // =====================================================

  Future<bool> rejectBooking({
    required String bookingId,
    required String reason,
  }) {
    return rejectOrder(
      orderId: bookingId,
      reason: reason,
    );
  }

  // =====================================================
  // COMPATIBILITY: CANCEL BOOKING
  // =====================================================

  Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
  }) {
    return cancelOrder(
      orderId: bookingId,
      reason: reason,
    );
  }

  // =====================================================
  // SAFE ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      _safeAnalytics() async {
    try {
      return await _orderService
          .getOrderAnalytics();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  // =====================================================
  // ANALYTICS INTEGER
  // =====================================================

  int _analyticsInt(
    Map<String, dynamic> analytics,
    String primaryKey,
    String fallbackKey,
  ) {
    final value =
        analytics[primaryKey] ??
        analytics[fallbackKey];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // =====================================================
  // ANALYTICS DOUBLE
  // =====================================================

  double _analyticsDouble(
    Map<String, dynamic> analytics,
    String primaryKey,
    String fallbackKey,
  ) {
    final value =
        analytics[primaryKey] ??
        analytics[fallbackKey];

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}