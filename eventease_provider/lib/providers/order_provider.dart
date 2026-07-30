import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository =
      OrderRepository.instance;

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;

  String? _errorMessage;

  List<OrderModel> _orders = [];

  List<OrderModel> _todayOrders = [];

  List<OrderModel> _recentOrders = [];

  OrderModel? _selectedOrder;

  Map<String, dynamic> _analytics = {};

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<OrderModel> get orders => _orders;

  List<OrderModel> get todayOrders =>
      _todayOrders;

  List<OrderModel> get recentOrders =>
      _recentOrders;

  OrderModel? get selectedOrder =>
      _selectedOrder;

  Map<String, dynamic> get analytics =>
      _analytics;

  // =========================
  // HELPERS
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // GET ALL ORDERS
  // =========================

  Future<void> getOrders() async {
    try {
      _setLoading(true);

      _orders =
          await _repository.getOrders();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET ORDER BY ID
  // =========================

  Future<OrderModel?> getOrderById(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      _selectedOrder =
          await _repository.getOrderById(
        orderId,
      );

      notifyListeners();

      return _selectedOrder;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET TODAY ORDERS
  // =========================

  Future<void> getTodayOrders() async {
    try {
      _todayOrders =
          await _repository.getTodayOrders();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // GET RECENT ORDERS
  // =========================

  Future<void> getRecentOrders() async {
    try {
      _recentOrders =
          await _repository.getRecentOrders();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
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
      return await _repository
          .getOrdersByStatus(status);
    } catch (e) {
      _errorMessage = e.toString();
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
      final success =
          await _repository.confirmOrder(
        orderId,
      );

      if (success) {
        await getOrders();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
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
      final success =
          await _repository.startOrder(
        orderId,
      );

      if (success) {
        await getOrders();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
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
      final success =
          await _repository.completeOrder(
        orderId,
      );

      if (success) {
        await getOrders();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
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
      final success =
          await _repository.cancelOrder(
        orderId: orderId,
        reason: reason,
      );

      if (success) {
        await getOrders();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
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
      final success =
          await _repository.refundOrder(
        orderId: orderId,
        reason: reason,
      );

      if (success) {
        await getOrders();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
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
      return await _repository.searchOrders(
        keyword,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // =========================
  // ORDER ANALYTICS
  // =========================

  Future<void> getOrderAnalytics() async {
    try {
      _analytics =
          await _repository
              .getOrderAnalytics();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // TOTAL ORDER COUNT
  // =========================

  Future<int> getOrderCount() async {
    try {
      return await _repository
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
      return await _repository
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
      return await _repository
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
      return await _repository
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
      return await _repository
          .downloadInvoice(orderId);
    } catch (e) {
      return null;
    }
  }

  // =========================
  // REFRESH DATA
  // =========================

  Future<void> refreshData() async {
    await Future.wait([
      getOrders(),
      getTodayOrders(),
      getRecentOrders(),
      getOrderAnalytics(),
    ]);
  }

  // =========================
  // RESET STATE
  // =========================

  void reset() {
    _orders = [];
    _todayOrders = [];
    _recentOrders = [];
    _selectedOrder = null;
    _analytics = {};
    _errorMessage = null;

    notifyListeners();
  }
}