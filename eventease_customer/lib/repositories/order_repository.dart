import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderRepository {
  OrderRepository._();

  static final OrderRepository instance =
      OrderRepository._();

  final OrderService _orderService =
      OrderService.instance;

  // ==========================================
  // CREATE ORDER
  // ==========================================

  Future<OrderModel> createOrder({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    String? couponCode,
    String? notes,
  }) async {
    return await _orderService.createOrder(
      bookingId: bookingId,
      amount: amount,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
      notes: notes,
    );
  }

  // ==========================================
  // MY ORDERS
  // ==========================================

  Future<List<OrderModel>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    return await _orderService.getMyOrders(
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // GET ORDER BY ID
  // ==========================================

  Future<OrderModel> getOrderById(
    String orderId,
  ) async {
    return await _orderService.getOrderById(
      orderId,
    );
  }

  // ==========================================
  // PROVIDER ORDERS
  // ==========================================

  Future<List<OrderModel>>
      getProviderOrders({
    int page = 1,
    int limit = 20,
  }) async {
    return await _orderService
        .getProviderOrders(
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // ORDER HISTORY
  // ==========================================

  Future<List<OrderModel>>
      getOrderHistory() async {
    return await _orderService
        .getOrderHistory();
  }

  // ==========================================
  // UPDATE STATUS
  // ==========================================

  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
  }) async {
    return await _orderService.updateStatus(
      orderId: orderId,
      status: status,
    );
  }

  // ==========================================
  // CONFIRM ORDER
  // ==========================================

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    return await _orderService
        .confirmOrder(orderId);
  }

  // ==========================================
  // PROCESS ORDER
  // ==========================================

  Future<bool> processOrder(
    String orderId,
  ) async {
    return await _orderService
        .processOrder(orderId);
  }

  // ==========================================
  // SHIP ORDER
  // ==========================================

  Future<bool> shipOrder(
    String orderId,
  ) async {
    return await _orderService
        .shipOrder(orderId);
  }

  // ==========================================
  // DELIVER ORDER
  // ==========================================

  Future<bool> deliverOrder(
    String orderId,
  ) async {
    return await _orderService
        .deliverOrder(orderId);
  }

  // ==========================================
  // CANCEL ORDER
  // ==========================================

  Future<bool> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    return await _orderService.cancelOrder(
      orderId: orderId,
      reason: reason,
    );
  }

  // ==========================================
  // TRACK ORDER
  // ==========================================

  Future<Map<String, dynamic>>
      trackOrder(
    String orderId,
  ) async {
    return await _orderService.trackOrder(
      orderId,
    );
  }

  // ==========================================
  // ORDER ANALYTICS
  // ==========================================

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    return await _orderService
        .getOrderAnalytics();
  }

  // ==========================================
  // ORDER SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getOrderSummary() async {
    return await _orderService
        .getOrderSummary();
  }

  // ==========================================
  // INVOICE URL
  // ==========================================

  Future<String> getInvoiceUrl(
    String orderId,
  ) async {
    return await _orderService
        .getInvoiceUrl(orderId);
  }

  // ==========================================
  // DELETE ORDER
  // ==========================================

  Future<bool> deleteOrder(
    String orderId,
  ) async {
    return await _orderService
        .deleteOrder(orderId);
  }
}