import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  OrderService._();

  static final OrderService instance =
      OrderService._();

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
    final response =
        await ApiService.instance.post(
      '/orders',
      data: {
        'bookingId': bookingId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'couponCode': couponCode,
        'notes': notes,
      },
    );

    return OrderModel.fromMap(
      response.data['data'] ??
          response.data['order'],
    );
  }

  // ==========================================
  // MY ORDERS
  // ==========================================

  Future<List<OrderModel>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final response =
        await ApiService.instance.get(
      '/orders/my',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List orders =
        response.data['data'] ??
            response.data['orders'] ??
            [];

    return orders
        .map(
          (e) => OrderModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET ORDER BY ID
  // ==========================================

  Future<OrderModel> getOrderById(
    String orderId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/orders/$orderId',
    );

    return OrderModel.fromMap(
      response.data['data'] ??
          response.data['order'],
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
    final response =
        await ApiService.instance.get(
      '/orders/provider',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List orders =
        response.data['data'] ??
            response.data['orders'] ??
            [];

    return orders
        .map(
          (e) => OrderModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // ORDER HISTORY
  // ==========================================

  Future<List<OrderModel>>
      getOrderHistory() async {
    final response =
        await ApiService.instance.get(
      '/orders/history',
    );

    final List orders =
        response.data['data'] ??
            response.data['orders'] ??
            [];

    return orders
        .map(
          (e) => OrderModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // UPDATE ORDER STATUS
  // ==========================================

  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
  }) async {
    final response =
        await ApiService.instance.patch(
      '/orders/$orderId/status',
      data: {
        'status': status,
      },
    );

    return OrderModel.fromMap(
      response.data['data'] ??
          response.data['order'],
    );
  }

  // ==========================================
  // CONFIRM ORDER
  // ==========================================

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    await ApiService.instance.patch(
      '/orders/$orderId/confirm',
    );

    return true;
  }

  // ==========================================
  // PROCESS ORDER
  // ==========================================

  Future<bool> processOrder(
    String orderId,
  ) async {
    await ApiService.instance.patch(
      '/orders/$orderId/process',
    );

    return true;
  }

  // ==========================================
  // SHIP ORDER
  // ==========================================

  Future<bool> shipOrder(
    String orderId,
  ) async {
    await ApiService.instance.patch(
      '/orders/$orderId/ship',
    );

    return true;
  }

  // ==========================================
  // DELIVER ORDER
  // ==========================================

  Future<bool> deliverOrder(
    String orderId,
  ) async {
    await ApiService.instance.patch(
      '/orders/$orderId/deliver',
    );

    return true;
  }

  // ==========================================
  // CANCEL ORDER
  // ==========================================

  Future<bool> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    await ApiService.instance.patch(
      '/orders/$orderId/cancel',
      data: {
        'reason': reason,
      },
    );

    return true;
  }

  // ==========================================
  // TRACK ORDER
  // ==========================================

  Future<Map<String, dynamic>>
      trackOrder(
    String orderId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/orders/$orderId/track',
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // DELETE ORDER
  // ==========================================

  Future<bool> deleteOrder(
    String orderId,
  ) async {
    await ApiService.instance.delete(
      '/orders/$orderId',
    );

    return true;
  }

  // ==========================================
  // ORDER ANALYTICS
  // ==========================================

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    final response =
        await ApiService.instance.get(
      '/orders/analytics',
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // ORDER SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getOrderSummary() async {
    final response =
        await ApiService.instance.get(
      '/orders/summary',
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // INVOICE
  // ==========================================

  Future<String> getInvoiceUrl(
    String orderId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/orders/$orderId/invoice',
    );

    return response.data['invoiceUrl'] ??
        response.data['data']
            ?['invoiceUrl'] ??
        '';
  }
}