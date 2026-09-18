import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderRepository? repository})
    : _repository = repository ?? OrderRepository.instance;

  final OrderRepository _repository;

  // =====================================================
  // STATE
  // =====================================================

  int _activeRequests = 0;

  bool _disposed = false;

  String? _errorMessage;

  List<OrderModel> _orders = <OrderModel>[];

  List<OrderModel> _todayOrders = <OrderModel>[];

  List<OrderModel> _recentOrders = <OrderModel>[];

  OrderModel? _selectedOrder;

  Map<String, dynamic> _analytics = <String, dynamic>{};

  double _totalRevenue = 0;

  DateTime? _lastRefreshedAt;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _activeRequests > 0;

  bool get hasError =>
      _errorMessage != null && _errorMessage!.trim().isNotEmpty;

  String? get errorMessage => _errorMessage;

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);

  List<OrderModel> get todayOrders =>
      List<OrderModel>.unmodifiable(_todayOrders);

  List<OrderModel> get recentOrders =>
      List<OrderModel>.unmodifiable(_recentOrders);

  OrderModel? get selectedOrder => _selectedOrder;

  Map<String, dynamic> get analytics =>
      Map<String, dynamic>.unmodifiable(_analytics);

  double get totalRevenue => _totalRevenue;

  DateTime? get lastRefreshedAt => _lastRefreshedAt;

  bool get hasOrders => _orders.isNotEmpty;

  int get totalOrderCount => _orders.length;

  // =====================================================
  // LOCAL STATUS COUNTS
  // =====================================================

  int get pendingOrderCount => _countByStatus('pending');

  int get acceptedOrderCount => _countByStatus('accepted');

  int get inProgressOrderCount => _countByStatus('in_progress');

  int get completedOrderCount => _countByStatus('completed');

  int get cancelledOrderCount => _countByStatus('cancelled');

  int get rejectedOrderCount => _countByStatus('rejected');

  // =====================================================
  // LOCAL STATUS LISTS
  // =====================================================

  List<OrderModel> get pendingOrders => _filterByStatus('pending');

  List<OrderModel> get acceptedOrders => _filterByStatus('accepted');

  List<OrderModel> get inProgressOrders => _filterByStatus('in_progress');

  List<OrderModel> get completedOrders => _filterByStatus('completed');

  List<OrderModel> get cancelledOrders => _filterByStatus('cancelled');

  List<OrderModel> get rejectedOrders => _filterByStatus('rejected');

  // =====================================================
  // ANALYTICS GETTERS
  // =====================================================

  int get analyticsTotalOrders => _analyticsInt('totalOrders', 'totalBookings');

  int get analyticsPendingOrders =>
      _analyticsInt('pendingOrders', 'pendingBookings');

  int get analyticsAcceptedOrders =>
      _analyticsInt('acceptedOrders', 'acceptedBookings');

  int get analyticsInProgressOrders =>
      _analyticsInt('inProgressOrders', 'inProgressBookings');

  int get analyticsCompletedOrders =>
      _analyticsInt('completedOrders', 'completedBookings');

  int get analyticsCancelledOrders =>
      _analyticsInt('cancelledOrders', 'cancelledBookings');

  int get analyticsRejectedOrders =>
      _analyticsInt('rejectedOrders', 'rejectedBookings');

  // =====================================================
  // NOTIFICATION HELPERS
  // =====================================================

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _beginRequest() {
    _activeRequests += 1;
    _safeNotifyListeners();
  }

  void _endRequest() {
    if (_activeRequests > 0) {
      _activeRequests -= 1;
    }

    _safeNotifyListeners();
  }

  void _clearErrorWithoutNotification() {
    _errorMessage = null;
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    _safeNotifyListeners();
  }

  void _setError(Object error, {required String fallback}) {
    final message = _cleanErrorMessage(error, fallback: fallback);

    _errorMessage = message;

    debugPrint('ORDER PROVIDER ERROR: $message');

    _safeNotifyListeners();
  }

  String _cleanErrorMessage(Object error, {required String fallback}) {
    var message = error.toString().trim();

    const prefixes = <String>[
      'Exception: ',
      'FormatException: ',
      'Invalid argument(s): ',
      'DioException: ',
    ];

    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message.substring(prefix.length).trim();
      }
    }

    return message.isEmpty ? fallback : message;
  }

  // =====================================================
  // NORMALIZATION HELPERS
  // =====================================================

  String _normalizeId(String value, String fieldName) {
    final normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError('$fieldName is required.');
    }

    return normalizedValue;
  }

  String _normalizeStatus(String? value) {
    final status = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (status) {
      case 'confirm':
      case 'confirmed':
        return 'accepted';

      case 'inprogress':
      case 'processing':
        return 'in_progress';

      case 'canceled':
        return 'cancelled';

      default:
        return status;
    }
  }

  int _countByStatus(String status) {
    final normalizedStatus = _normalizeStatus(status);

    return _orders.where((order) {
      return _normalizeStatus(order.status) == normalizedStatus;
    }).length;
  }

  List<OrderModel> _filterByStatus(String status) {
    final normalizedStatus = _normalizeStatus(status);

    return List<OrderModel>.unmodifiable(
      _orders.where((order) {
        return _normalizeStatus(order.status) == normalizedStatus;
      }),
    );
  }

  int _analyticsInt(String primaryKey, String fallbackKey) {
    final value = _analytics[primaryKey] ?? _analytics[fallbackKey];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // =====================================================
  // GET ALL ORDERS
  // =====================================================

  Future<void> getOrders({bool showLoading = true}) async {
    if (showLoading) {
      _beginRequest();
    }

    _clearErrorWithoutNotification();

    try {
      final result = await _repository.getOrders();

      _orders = List<OrderModel>.from(result);

      _lastRefreshedAt = DateTime.now();

      debugPrint(
        'PROVIDER ORDERS LOADED: '
        '${_orders.length}',
      );

      _safeNotifyListeners();
    } catch (error) {
      _setError(error, fallback: 'Unable to load Provider orders.');
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  // =====================================================
  // GET ORDER BY ID
  // =====================================================

  Future<OrderModel?> getOrderById(
    String orderId, {
    bool showLoading = true,
  }) async {
    String normalizedOrderId;

    try {
      normalizedOrderId = _normalizeId(orderId, 'Order ID');
    } catch (error) {
      _setError(error, fallback: 'Order ID is required.');

      return null;
    }

    if (showLoading) {
      _beginRequest();
    }

    _clearErrorWithoutNotification();

    try {
      _selectedOrder = await _repository.getOrderById(normalizedOrderId);

      _safeNotifyListeners();

      return _selectedOrder;
    } catch (error) {
      _setError(error, fallback: 'Unable to load order details.');

      return null;
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  void selectOrder(OrderModel? order) {
    _selectedOrder = order;
    _safeNotifyListeners();
  }

  // =====================================================
  // GET TODAY ORDERS
  // =====================================================

  Future<void> getTodayOrders({bool showLoading = false}) async {
    if (showLoading) {
      _beginRequest();
    }

    try {
      final result = await _repository.getTodayOrders();

      _todayOrders = List<OrderModel>.from(result);

      _safeNotifyListeners();
    } catch (error) {
      _setError(error, fallback: 'Unable to load today\'s orders.');
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  // =====================================================
  // GET RECENT ORDERS
  // =====================================================

  Future<void> getRecentOrders({bool showLoading = false}) async {
    if (showLoading) {
      _beginRequest();
    }

    try {
      final result = await _repository.getRecentOrders();

      _recentOrders = List<OrderModel>.from(result);

      _safeNotifyListeners();
    } catch (error) {
      _setError(error, fallback: 'Unable to load recent orders.');
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  // =====================================================
  // GET ORDERS BY STATUS
  // =====================================================

  Future<List<OrderModel>> getOrdersByStatus(String status) async {
    final normalizedStatus = _normalizeStatus(status);

    if (normalizedStatus.isEmpty || normalizedStatus == 'all') {
      return orders;
    }

    try {
      final result = await _repository.getOrdersByStatus(normalizedStatus);

      return List<OrderModel>.unmodifiable(result);
    } catch (error) {
      debugPrint(
        'REMOTE STATUS FILTER FAILED: '
        '$error',
      );

      return _filterByStatus(normalizedStatus);
    }
  }

  // =====================================================
  // REFRESH AFTER STATUS CHANGE
  // =====================================================

  Future<void> _refreshAfterMutation(String orderId) async {
    await refreshData(showLoading: false);

    await getOrderById(orderId, showLoading: false);
  }

  // =====================================================
  // CONFIRM / ACCEPT ORDER
  //
  // pending -> accepted
  // =====================================================

  Future<bool> confirmOrder(String orderId) async {
    String normalizedOrderId;

    try {
      normalizedOrderId = _normalizeId(orderId, 'Order ID');
    } catch (error) {
      _setError(error, fallback: 'Order ID is required.');

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success = await _repository.confirmOrder(normalizedOrderId);

      if (!success) {
        throw Exception('The Provider could not accept this order.');
      }

      await _refreshAfterMutation(normalizedOrderId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to accept order.');

      return false;
    } finally {
      _endRequest();
    }
  }

  Future<bool> acceptOrder(String orderId) {
    return confirmOrder(orderId);
  }

  // =====================================================
  // START ORDER
  //
  // accepted -> in_progress
  // =====================================================

  Future<bool> startOrder(String orderId) async {
    String normalizedOrderId;

    try {
      normalizedOrderId = _normalizeId(orderId, 'Order ID');
    } catch (error) {
      _setError(error, fallback: 'Order ID is required.');

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success = await _repository.startOrder(normalizedOrderId);

      if (!success) {
        throw Exception('The order could not be started.');
      }

      await _refreshAfterMutation(normalizedOrderId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to start order.');

      return false;
    } finally {
      _endRequest();
    }
  }

  // =====================================================
  // COMPLETE ORDER
  //
  // in_progress -> completed
  // =====================================================

  Future<bool> completeOrder(String orderId) async {
    String normalizedOrderId;

    try {
      normalizedOrderId = _normalizeId(orderId, 'Order ID');
    } catch (error) {
      _setError(error, fallback: 'Order ID is required.');

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success = await _repository.completeOrder(normalizedOrderId);

      if (!success) {
        throw Exception('The order could not be completed.');
      }

      await _refreshAfterMutation(normalizedOrderId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to complete order.');

      return false;
    } finally {
      _endRequest();
    }
  }

  // =====================================================
  // CANCEL ORDER
  //
  // accepted -> cancelled
  // in_progress -> cancelled
  // =====================================================

  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    String normalizedOrderId;

    try {
      normalizedOrderId = _normalizeId(orderId, 'Order ID');
    } catch (error) {
      _setError(error, fallback: 'Order ID is required.');

      return false;
    }

    final normalizedReason = reason.trim();

    if (normalizedReason.isEmpty) {
      _setError(
        ArgumentError('Cancellation reason is required.'),
        fallback: 'Cancellation reason is required.',
      );

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success = await _repository.cancelOrder(
        orderId: normalizedOrderId,
        reason: normalizedReason,
      );

      if (!success) {
        throw Exception('The order could not be cancelled.');
      }

      await _refreshAfterMutation(normalizedOrderId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to cancel order.');

      return false;
    } finally {
      _endRequest();
    }
  }

  // =====================================================
  // REFUND ORDER
  // =====================================================

  Future<bool> refundOrder({
    required String orderId,
    required String reason,
  }) async {
    String normalizedOrderId;

    try {
      normalizedOrderId = _normalizeId(orderId, 'Order ID');
    } catch (error) {
      _setError(error, fallback: 'Order ID is required.');

      return false;
    }

    final normalizedReason = reason.trim();

    if (normalizedReason.isEmpty) {
      _setError(
        ArgumentError('Refund reason is required.'),
        fallback: 'Refund reason is required.',
      );

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success = await _repository.refundOrder(
        orderId: normalizedOrderId,
        reason: normalizedReason,
      );

      if (!success) {
        throw Exception('Refund is unavailable or could not be processed.');
      }

      await _refreshAfterMutation(normalizedOrderId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to refund order.');

      return false;
    } finally {
      _endRequest();
    }
  }

  // =====================================================
  // SEARCH ORDERS
  // =====================================================

  Future<List<OrderModel>> searchOrders(String keyword) async {
    final normalizedKeyword = keyword.trim();

    if (normalizedKeyword.isEmpty) {
      return orders;
    }

    try {
      final result = await _repository.searchOrders(normalizedKeyword);

      return List<OrderModel>.unmodifiable(result);
    } catch (error) {
      debugPrint(
        'REMOTE ORDER SEARCH FAILED: '
        '$error',
      );

      final lowerKeyword = normalizedKeyword.toLowerCase();

      return _orders.where((order) {
        return order.toString().toLowerCase().contains(lowerKeyword);
      }).toList();
    }
  }

  // =====================================================
  // ORDER ANALYTICS
  // =====================================================

  Future<void> getOrderAnalytics({bool showLoading = false}) async {
    if (showLoading) {
      _beginRequest();
    }

    try {
      final result = await _repository.getOrderAnalytics();

      _analytics = Map<String, dynamic>.from(result);

      _safeNotifyListeners();
    } catch (error) {
      _setError(error, fallback: 'Unable to load order analytics.');
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  // =====================================================
  // COUNT METHODS
  // =====================================================

  Future<int> getOrderCount() async {
    try {
      return await _repository.getOrderCount();
    } catch (error) {
      debugPrint('GET ORDER COUNT ERROR: $error');

      return totalOrderCount;
    }
  }

  Future<int> getCompletedOrderCount() async {
    try {
      return await _repository.getCompletedOrderCount();
    } catch (error) {
      debugPrint(
        'GET COMPLETED ORDER COUNT ERROR: '
        '$error',
      );

      return completedOrderCount;
    }
  }

  Future<int> getPendingOrderCount() async {
    try {
      return await _repository.getPendingOrderCount();
    } catch (error) {
      debugPrint(
        'GET PENDING ORDER COUNT ERROR: '
        '$error',
      );

      return pendingOrderCount;
    }
  }

  Future<int> getAcceptedOrderCount() async {
    if (_analytics.isEmpty) {
      await getOrderAnalytics();
    }

    if (_analytics.containsKey('acceptedOrders') ||
        _analytics.containsKey('acceptedBookings')) {
      return analyticsAcceptedOrders;
    }

    return acceptedOrderCount;
  }

  Future<int> getInProgressOrderCount() async {
    if (_analytics.isEmpty) {
      await getOrderAnalytics();
    }

    if (_analytics.containsKey('inProgressOrders') ||
        _analytics.containsKey('inProgressBookings')) {
      return analyticsInProgressOrders;
    }

    return inProgressOrderCount;
  }

  Future<int> getCancelledOrderCount() async {
    if (_analytics.isEmpty) {
      await getOrderAnalytics();
    }

    if (_analytics.containsKey('cancelledOrders') ||
        _analytics.containsKey('cancelledBookings')) {
      return analyticsCancelledOrders;
    }

    return cancelledOrderCount;
  }

  Future<int> getRejectedOrderCount() async {
    if (_analytics.isEmpty) {
      await getOrderAnalytics();
    }

    if (_analytics.containsKey('rejectedOrders') ||
        _analytics.containsKey('rejectedBookings')) {
      return analyticsRejectedOrders;
    }

    return rejectedOrderCount;
  }

  // =====================================================
  // TOTAL REVENUE
  // =====================================================

  Future<double> getTotalRevenue({bool forceRefresh = true}) async {
    if (!forceRefresh && _lastRefreshedAt != null) {
      return _totalRevenue;
    }

    try {
      final result = await _repository.getTotalRevenue();

      _totalRevenue = _toDouble(result);

      _safeNotifyListeners();

      return _totalRevenue;
    } catch (error) {
      _setError(error, fallback: 'Unable to load total revenue.');

      return _totalRevenue;
    }
  }

  // =====================================================
  // DOWNLOAD INVOICE
  // =====================================================

  Future<String?> downloadInvoice(String orderId) async {
    try {
      final normalizedOrderId = _normalizeId(orderId, 'Order ID');

      return await _repository.downloadInvoice(normalizedOrderId);
    } catch (error) {
      _setError(error, fallback: 'Invoice is unavailable.');

      return null;
    }
  }

  // =====================================================
  // REAL-TIME EVENT HANDLER
  //
  // Call when receiving:
  // newBooking
  // bookingUpdated
  // bookingCancelled
  // refreshBookings
  // refreshProviderDashboard
  // =====================================================

  Future<void> handleOrderEvent(dynamic event) async {
    debugPrint(
      'PROVIDER ORDER EVENT RECEIVED: '
      '$event',
    );

    await refreshData(showLoading: false);
  }

  // =====================================================
  // REFRESH ALL ORDER DATA
  // =====================================================

  Future<void> refreshData({bool showLoading = true}) async {
    if (showLoading) {
      _beginRequest();
    }

    _clearErrorWithoutNotification();

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _repository.getOrders(),
        _repository.getTodayOrders(),
        _repository.getRecentOrders(),
        _repository.getOrderAnalytics(),
        _repository.getTotalRevenue(),
      ]);

      _orders = List<OrderModel>.from(results[0] as List);

      _todayOrders = List<OrderModel>.from(results[1] as List);

      _recentOrders = List<OrderModel>.from(results[2] as List);

      _analytics = Map<String, dynamic>.from(results[3] as Map);

      _totalRevenue = _toDouble(results[4]);

      _lastRefreshedAt = DateTime.now();

      debugPrint('PROVIDER ORDER DATA REFRESHED');

      debugPrint(
        'TOTAL ORDERS: '
        '$totalOrderCount',
      );

      debugPrint(
        'PENDING ORDERS: '
        '$pendingOrderCount',
      );

      debugPrint(
        'ACCEPTED ORDERS: '
        '$acceptedOrderCount',
      );

      debugPrint(
        'IN-PROGRESS ORDERS: '
        '$inProgressOrderCount',
      );

      debugPrint(
        'COMPLETED ORDERS: '
        '$completedOrderCount',
      );

      debugPrint(
        'CANCELLED ORDERS: '
        '$cancelledOrderCount',
      );

      debugPrint(
        'REJECTED ORDERS: '
        '$rejectedOrderCount',
      );

      debugPrint(
        'TOTAL REVENUE: '
        '$_totalRevenue',
      );

      _safeNotifyListeners();
    } catch (error) {
      _setError(error, fallback: 'Unable to refresh Provider order data.');

      /*
       * If one secondary endpoint fails, still refresh
       * the main order list.
       */
      try {
        final fallbackOrders = await _repository.getOrders();

        _orders = List<OrderModel>.from(fallbackOrders);

        _lastRefreshedAt = DateTime.now();

        _safeNotifyListeners();
      } catch (fallbackError) {
        debugPrint(
          'ORDER REFRESH FALLBACK ERROR: '
          '$fallbackError',
        );
      }
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  // =====================================================
  // RESET
  // =====================================================

  void reset() {
    _activeRequests = 0;

    _errorMessage = null;

    _orders = <OrderModel>[];

    _todayOrders = <OrderModel>[];

    _recentOrders = <OrderModel>[];

    _selectedOrder = null;

    _analytics = <String, dynamic>{};

    _totalRevenue = 0;

    _lastRefreshedAt = null;

    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
