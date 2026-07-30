import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService =
      OrderService();

  bool _isLoading = false;

  String? _errorMessage;

  List<OrderModel> _orders = [];

  OrderModel? _selectedOrder;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalOrders = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<OrderModel> get orders =>
      _orders;

  OrderModel? get selectedOrder =>
      _selectedOrder;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalOrders => _totalOrders;

  bool get hasOrders =>
      _orders.isNotEmpty;

  // =====================================================
  // GET ORDERS
  // =====================================================

  Future<void> getOrders({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? customerId,
    String? providerId,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _orderService.getOrders(
        page: page,
        limit: limit,
        search: search,
        status: status,
        customerId: customerId,
        providerId: providerId,
      );

      _orders =
          (response['orders'] as List? ??
                  [])
              .map(
                (e) =>
                    OrderModel.fromJson(e),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalOrders =
          response['totalOrders'] ??
              _orders.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET ORDER DETAILS
  // =====================================================

  Future<void> getOrderDetails(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _orderService
              .getOrderDetails(
        orderId,
      );

      _selectedOrder =
          OrderModel.fromJson(
        response,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEARCH ORDERS
  // =====================================================

  Future<void> searchOrders(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _orderService
              .searchOrders(
        keyword,
      );

      _orders =
          (response as List)
              .map(
                (e) =>
                    OrderModel.fromJson(e),
              )
              .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // PROCESS ORDER
  // =====================================================

  Future<bool> processOrder(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      await _orderService.processOrder(
        orderId,
      );

      final index =
          _orders.indexWhere(
        (e) => e.id == orderId,
      );

      if (index != -1) {
        _orders[index] =
            _orders[index].copyWith(
          orderStatus: 'processing',
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SHIP ORDER
  // =====================================================

  Future<bool> shipOrder(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      await _orderService.shipOrder(
        orderId,
      );

      final index =
          _orders.indexWhere(
        (e) => e.id == orderId,
      );

      if (index != -1) {
        _orders[index] =
            _orders[index].copyWith(
          orderStatus: 'shipped',
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DELIVER ORDER
  // =====================================================

  Future<bool> deliverOrder(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      await _orderService.deliverOrder(
        orderId,
      );

      final index =
          _orders.indexWhere(
        (e) => e.id == orderId,
      );

      if (index != -1) {
        _orders[index] =
            _orders[index].copyWith(
          orderStatus: 'delivered',
          deliveredAt: DateTime.now(),
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CANCEL ORDER
  // =====================================================

  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      _setLoading(true);

      await _orderService.cancelOrder(
        orderId: orderId,
        reason: reason,
      );

      final index =
          _orders.indexWhere(
        (e) => e.id == orderId,
      );

      if (index != -1) {
        _orders[index] =
            _orders[index].copyWith(
          orderStatus: 'cancelled',
          cancellationReason: reason,
          cancelledAt: DateTime.now(),
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // UPDATE PAYMENT STATUS
  // =====================================================

  Future<bool> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  }) async {
    try {
      _setLoading(true);

      await _orderService
          .updatePaymentStatus(
        orderId: orderId,
        paymentStatus: paymentStatus,
      );

      final index =
          _orders.indexWhere(
        (e) => e.id == orderId,
      );

      if (index != -1) {
        _orders[index] =
            _orders[index].copyWith(
          paymentStatus:
              paymentStatus,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DELETE ORDER
  // =====================================================

  Future<bool> deleteOrder(
    String orderId,
  ) async {
    try {
      _setLoading(true);

      await _orderService.deleteOrder(
        orderId,
      );

      _orders.removeWhere(
        (e) => e.id == orderId,
      );

      if (_selectedOrder?.id ==
          orderId) {
        _selectedOrder = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH ORDERS
  // =====================================================

  Future<void> refreshOrders() async {
    await getOrders(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED ORDER
  // =====================================================

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =====================================================
  // SET LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}