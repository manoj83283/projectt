import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderRepository {
  OrderRepository._();

  static final OrderRepository _instance =
      OrderRepository._();

  static OrderRepository get instance =>
      _instance;

  final OrderService _orderService =
      OrderService.instance;

  // =========================
  // GET ALL ORDERS
  // =========================

  Future<List<OrderModel>> getOrders() async {
    try {
      return await _orderService.getOrders();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET ORDER BY ID
  // =========================

  Future<OrderModel> getOrderById(
    String orderId,
  ) async {
    try {
      return await _orderService.getOrderById(
        orderId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET TODAY ORDERS
  // =========================

  Future<List<OrderModel>>
      getTodayOrders() async {
    try {
      return await _orderService
          .getTodayOrders();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET RECENT ORDERS
  // =========================

  Future<List<OrderModel>>
      getRecentOrders() async {
    try {
      return await _orderService
          .getRecentOrders();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET ORDERS BY STATUS
  // =========================

  Future<List<OrderModel>>
      getOrdersByStatus(
    String status,
  ) async {
    try {
      return await _orderService
          .getOrdersByStatus(
        status,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // CONFIRM ORDER
  // =========================

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    try {
      return await _orderService
          .confirmOrder(
        orderId,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // START ORDER
  // =========================

  Future<bool> startOrder(
    String orderId,
  ) async {
    try {
      return await _orderService
          .startOrder(
        orderId,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // COMPLETE ORDER
  // =========================

  Future<bool> completeOrder(
    String orderId,
  ) async {
    try {
      return await _orderService
          .completeOrder(
        orderId,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // CANCEL ORDER
  // =========================

  Future<bool> cancelOrder({
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
      return false;
    }
  }

  // =========================
  // REFUND ORDER
  // =========================

  Future<bool> refundOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      return await _orderService
          .refundOrder(
        orderId: orderId,
        reason: reason,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // SEARCH ORDERS
  // =========================

  Future<List<OrderModel>>
      searchOrders(
    String keyword,
  ) async {
    try {
      return await _orderService
          .searchOrders(
        keyword,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // ORDER ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    try {
      return await _orderService
          .getOrderAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // TOTAL ORDER COUNT
  // =========================

  Future<int> getOrderCount() async {
    try {
      return await _orderService
          .getOrderCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // COMPLETED ORDER COUNT
  // =========================

  Future<int>
      getCompletedOrderCount() async {
    try {
      return await _orderService
          .getCompletedOrderCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // PENDING ORDER COUNT
  // =========================

  Future<int>
      getPendingOrderCount() async {
    try {
      return await _orderService
          .getPendingOrderCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // TOTAL REVENUE
  // =========================

  Future<double> getTotalRevenue() async {
    try {
      return await _orderService
          .getTotalRevenue();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // DOWNLOAD INVOICE
  // =========================

  Future<String?> downloadInvoice(
    String orderId,
  ) async {
    try {
      return await _orderService
          .downloadInvoice(
        orderId,
      );
    } catch (e) {
      return null;
    }
  }
}