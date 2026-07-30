import '../services/order_service.dart';

class OrderRepository {
  final OrderService _orderService;

  OrderRepository({
    OrderService? orderService,
  }) : _orderService =
            orderService ??
                OrderService();

  // =====================================================
  // GET ORDERS
  // =====================================================

  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? customerId,
    String? providerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _orderService.getOrders(
        page: page,
        limit: limit,
        search: search,
        status: status,
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
  // GET ORDER DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderDetails(
    String orderId,
  ) async {
    try {
      return await _orderService
          .getOrderDetails(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH ORDERS
  // =====================================================

  Future<List<dynamic>> searchOrders(
    String keyword,
  ) async {
    try {
      return await _orderService
          .searchOrders(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROCESS ORDER
  // =====================================================

  Future<Map<String, dynamic>>
      processOrder(
    String orderId,
  ) async {
    try {
      return await _orderService
          .processOrder(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SHIP ORDER
  // =====================================================

  Future<Map<String, dynamic>>
      shipOrder(
    String orderId,
  ) async {
    try {
      return await _orderService
          .shipOrder(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELIVER ORDER
  // =====================================================

  Future<Map<String, dynamic>>
      deliverOrder(
    String orderId,
  ) async {
    try {
      return await _orderService
          .deliverOrder(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CANCEL ORDER
  // =====================================================

  Future<Map<String, dynamic>>
      cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      return await _orderService
          .cancelOrder(
        orderId: orderId,
        reason: reason,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UPDATE PAYMENT STATUS
  // =====================================================

  Future<Map<String, dynamic>>
      updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    try {
      return await _orderService
          .updatePaymentStatus(
        orderId: orderId,
        paymentStatus: paymentStatus,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ORDER TIMELINE
  // =====================================================

  Future<List<dynamic>>
      getOrderTimeline(
    String orderId,
  ) async {
    try {
      return await _orderService
          .getOrderTimeline(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ORDER ITEMS
  // =====================================================

  Future<List<dynamic>>
      getOrderItems(
    String orderId,
  ) async {
    try {
      return await _orderService
          .getOrderItems(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ORDER PAYMENTS
  // =====================================================

  Future<List<dynamic>>
      getOrderPayments(
    String orderId,
  ) async {
    try {
      return await _orderService
          .getOrderPayments(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER ORDERS
  // =====================================================

  Future<List<dynamic>>
      getCustomerOrders(
    String customerId,
  ) async {
    try {
      return await _orderService
          .getCustomerOrders(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER ORDERS
  // =====================================================

  Future<List<dynamic>>
      getProviderOrders(
    String providerId,
  ) async {
    try {
      return await _orderService
          .getProviderOrders(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ORDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    try {
      return await _orderService
          .getOrderAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ORDER REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateOrderReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _orderService
          .generateOrderReport(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE ORDER
  // =====================================================

  Future<void> deleteOrder(
    String orderId,
  ) async {
    try {
      await _orderService.deleteOrder(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }
}