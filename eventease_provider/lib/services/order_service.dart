import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/order_model.dart';

class OrderService {
  OrderService._();

  static final OrderService _instance =
      OrderService._();

  static OrderService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // GET ALL ORDERS
  // =========================

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _apiService.get(
        '/provider/orders',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) => OrderModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Get Orders Error: $e');
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
      final response = await _apiService.get(
        '/provider/orders/$orderId',
      );

      return OrderModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Get Order Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET TODAY ORDERS
  // =========================

  Future<List<OrderModel>>
      getTodayOrders() async {
    try {
      final response = await _apiService.get(
        '/provider/orders/today',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) => OrderModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Today Orders Error: $e');
      return [];
    }
  }

  // =========================
  // GET RECENT ORDERS
  // =========================

  Future<List<OrderModel>>
      getRecentOrders() async {
    try {
      final response = await _apiService.get(
        '/provider/orders/recent',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) => OrderModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Recent Orders Error: $e');
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
      final response = await _apiService.get(
        '/provider/orders/status/$status',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) => OrderModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log(
        'Get Orders By Status Error: $e',
      );
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
      await _apiService.patch(
        '/provider/orders/$orderId/confirm',
      );

      return true;
    } catch (e) {
      log('Confirm Order Error: $e');
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
      await _apiService.patch(
        '/provider/orders/$orderId/start',
      );

      return true;
    } catch (e) {
      log('Start Order Error: $e');
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
      await _apiService.patch(
        '/provider/orders/$orderId/complete',
      );

      return true;
    } catch (e) {
      log('Complete Order Error: $e');
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
      await _apiService.patch(
        '/provider/orders/$orderId/cancel',
        body: {
          'reason': reason,
        },
      );

      return true;
    } catch (e) {
      log('Cancel Order Error: $e');
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
      await _apiService.patch(
        '/provider/orders/$orderId/refund',
        body: {
          'reason': reason,
        },
      );

      return true;
    } catch (e) {
      log('Refund Order Error: $e');
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
      final response = await _apiService.get(
        '/provider/orders/search?keyword=$keyword',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) => OrderModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Search Orders Error: $e');
      return [];
    }
  }

  // =========================
  // ORDER ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    try {
      return await _apiService.get(
        '/provider/orders/analytics',
      );
    } catch (e) {
      log('Order Analytics Error: $e');
      rethrow;
    }
  }

  // =========================
  // ORDER COUNT
  // =========================

  Future<int> getOrderCount() async {
    try {
      final response = await _apiService.get(
        '/provider/orders/count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      log('Order Count Error: $e');
      return 0;
    }
  }

  // =========================
  // COMPLETED ORDER COUNT
  // =========================

  Future<int>
      getCompletedOrderCount() async {
    try {
      final response = await _apiService.get(
        '/provider/orders/completed-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // PENDING ORDER COUNT
  // =========================

  Future<int> getPendingOrderCount() async {
    try {
      final response = await _apiService.get(
        '/provider/orders/pending-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // TOTAL REVENUE
  // =========================

  Future<double> getTotalRevenue() async {
    try {
      final response = await _apiService.get(
        '/provider/orders/revenue',
      );

      return (response['revenue'] ?? 0)
          .toDouble();
    } catch (e) {
      log('Revenue Error: $e');
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
      final response = await _apiService.get(
        '/provider/orders/$orderId/invoice',
      );

      return response['url'];
    } catch (e) {
      log('Invoice Error: $e');
      return null;
    }
  }
}