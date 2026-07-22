import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider();

  final OrderRepository _repository =
      OrderRepository.instance;

  List<OrderModel> _myOrders = [];
  List<OrderModel> _providerOrders = [];

  OrderModel? _selectedOrder;

  bool _isLoading = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  List<OrderModel> get myOrders =>
      _myOrders;

  List<OrderModel> get providerOrders =>
      _providerOrders;

  OrderModel? get selectedOrder =>
      _selectedOrder;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // ==========================================
  // SET LOADING
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // SET ERROR
  // ==========================================

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ==========================================
  // CREATE ORDER
  // ==========================================

  Future<bool> createOrder({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    String? couponCode,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final order =
          await _repository.createOrder(
        bookingId: bookingId,
        amount: amount,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        notes: notes,
      );

      _myOrders.insert(0, order);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // MY ORDERS
  // ==========================================

  Future<void> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _myOrders =
          await _repository.getMyOrders(
        page: page,
        limit: limit,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PROVIDER ORDERS
  // ==========================================

  Future<void> getProviderOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _providerOrders =
          await _repository.getProviderOrders(
        page: page,
        limit: limit,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GET ORDER DETAILS
  // ==========================================

  Future<void> getOrderById(
    String orderId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _selectedOrder =
          await _repository.getOrderById(
        orderId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // ORDER HISTORY
  // ==========================================

  Future<void> getOrderHistory() async {
    try {
      _setLoading(true);
      _setError(null);

      _myOrders =
          await _repository.getOrderHistory();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // UPDATE STATUS
  // ==========================================

  Future<bool> updateStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      _setLoading(true);

      final order =
          await _repository.updateStatus(
        orderId: orderId,
        status: status,
      );

      _selectedOrder = order;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CONFIRM ORDER
  // ==========================================

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.confirmOrder(
        orderId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PROCESS ORDER
  // ==========================================

  Future<bool> processOrder(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.processOrder(
        orderId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SHIP ORDER
  // ==========================================

  Future<bool> shipOrder(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.shipOrder(
        orderId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // DELIVER ORDER
  // ==========================================

  Future<bool> deliverOrder(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.deliverOrder(
        orderId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CANCEL ORDER
  // ==========================================

  Future<bool> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      _setLoading(true);

      return await _repository.cancelOrder(
        orderId: orderId,
        reason: reason,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // TRACK ORDER
  // ==========================================

  Future<Map<String, dynamic>>
      trackOrder(
    String orderId,
  ) async {
    try {
      return await _repository.trackOrder(
        orderId,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // ORDER SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getOrderSummary() async {
    try {
      return await _repository
          .getOrderSummary();
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // ORDER ANALYTICS
  // ==========================================

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    try {
      return await _repository
          .getOrderAnalytics();
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // GET INVOICE URL
  // ==========================================

  Future<String> getInvoiceUrl(
    String orderId,
  ) async {
    try {
      return await _repository.getInvoiceUrl(
        orderId,
      );
    } catch (e) {
      _setError(e.toString());
      return '';
    }
  }

  // ==========================================
  // DELETE ORDER
  // ==========================================

  Future<bool> deleteOrder(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.deleteOrder(
        orderId,
      );

      if (success) {
        _myOrders.removeWhere(
          (e) => e.id == orderId,
        );

        _providerOrders.removeWhere(
          (e) => e.id == orderId,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SELECT ORDER
  // ==========================================

  void setSelectedOrder(
    OrderModel order,
  ) {
    _selectedOrder = order;
    notifyListeners();
  }

  // ==========================================
  // CLEAR ORDER
  // ==========================================

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==========================================
  // RESET
  // ==========================================

  void reset() {
    _myOrders.clear();
    _providerOrders.clear();

    _selectedOrder = null;
    _error = null;

    notifyListeners();
  }
}