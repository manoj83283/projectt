import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({
    OrderRepository? repository,
  }) : _repository =
            repository ??
            OrderRepository.instance;

  final OrderRepository _repository;

  int _activeRequests = 0;

  bool _disposed = false;

  String? _errorMessage;

  List<OrderModel> _orders =
      <OrderModel>[];

  List<OrderModel> _todayOrders =
      <OrderModel>[];

  List<OrderModel> _recentOrders =
      <OrderModel>[];

  OrderModel? _selectedOrder;

  Map<String, dynamic> _analytics =
      <String, dynamic>{};

  double _totalRevenue = 0;

  DateTime? _lastRefreshedAt;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading {
    return _activeRequests > 0;
  }

  bool get hasError {
    return _errorMessage != null &&
        _errorMessage!.trim().isNotEmpty;
  }

  String? get errorMessage {
    return _errorMessage;
  }

  List<OrderModel> get orders {
    return List<OrderModel>.unmodifiable(
      _orders,
    );
  }

  List<OrderModel> get todayOrders {
    return List<OrderModel>.unmodifiable(
      _todayOrders,
    );
  }

  List<OrderModel> get recentOrders {
    return List<OrderModel>.unmodifiable(
      _recentOrders,
    );
  }

  OrderModel? get selectedOrder {
    return _selectedOrder;
  }

  Map<String, dynamic> get analytics {
    return Map<String, dynamic>.unmodifiable(
      _analytics,
    );
  }

  double get totalRevenue {
    return _totalRevenue;
  }

  DateTime? get lastRefreshedAt {
    return _lastRefreshedAt;
  }

  bool get hasOrders {
    return _orders.isNotEmpty;
  }

  int get totalOrderCount {
    return _orders.length;
  }

  // =====================================================
  // LOCAL STATUS COUNTS
  // =====================================================

  int get pendingOrderCount {
    return _countByStatus(
      'pending',
    );
  }

  int get acceptedOrderCount {
    return _countByStatus(
      'accepted',
    );
  }

  int get otpVerifiedOrderCount {
    return _countByStatus(
      'otp_verified',
    );
  }

  int get inProgressOrderCount {
    return _countByStatus(
      'in_progress',
    );
  }

  int get completedOrderCount {
    return _countByStatus(
      'completed',
    );
  }

  int get cancelledOrderCount {
    return _countByStatus(
      'cancelled',
    );
  }

  int get rejectedOrderCount {
    return _countByStatus(
      'rejected',
    );
  }

  // =====================================================
  // LOCAL STATUS LISTS
  // =====================================================

  List<OrderModel> get pendingOrders {
    return _filterByStatus(
      'pending',
    );
  }

  List<OrderModel> get acceptedOrders {
    return _filterByStatus(
      'accepted',
    );
  }

  List<OrderModel> get otpVerifiedOrders {
    return _filterByStatus(
      'otp_verified',
    );
  }

  List<OrderModel> get inProgressOrders {
    return _filterByStatus(
      'in_progress',
    );
  }

  List<OrderModel> get completedOrders {
    return _filterByStatus(
      'completed',
    );
  }

  List<OrderModel> get cancelledOrders {
    return _filterByStatus(
      'cancelled',
    );
  }

  List<OrderModel> get rejectedOrders {
    return _filterByStatus(
      'rejected',
    );
  }

  // =====================================================
  // ANALYTICS GETTERS
  // =====================================================

  int get analyticsTotalOrders {
    return _analyticsInt(
      'totalOrders',
      'totalBookings',
    );
  }

  int get analyticsPendingOrders {
    return _analyticsInt(
      'pendingOrders',
      'pendingBookings',
    );
  }

  int get analyticsAcceptedOrders {
    return _analyticsInt(
      'acceptedOrders',
      'acceptedBookings',
    );
  }

  int get analyticsOtpVerifiedOrders {
    return _analyticsInt(
      'otpVerifiedOrders',
      'otpVerifiedBookings',
    );
  }

  int get analyticsInProgressOrders {
    return _analyticsInt(
      'inProgressOrders',
      'inProgressBookings',
    );
  }

  int get analyticsCompletedOrders {
    return _analyticsInt(
      'completedOrders',
      'completedBookings',
    );
  }

  int get analyticsCancelledOrders {
    return _analyticsInt(
      'cancelledOrders',
      'cancelledBookings',
    );
  }

  int get analyticsRejectedOrders {
    return _analyticsInt(
      'rejectedOrders',
      'rejectedBookings',
    );
  }

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

  void _setError(
    Object error, {
    required String fallback,
  }) {
    final message = _cleanErrorMessage(
      error,
      fallback: fallback,
    );

    _errorMessage = message;

    debugPrint(
      'ORDER PROVIDER ERROR: $message',
    );

    _safeNotifyListeners();
  }

  String _cleanErrorMessage(
    Object error, {
    required String fallback,
  }) {
    var message =
        error.toString().trim();

    const prefixes = <String>[
      'Exception: ',
      'FormatException: ',
      'Invalid argument(s): ',
      'DioException: ',
    ];

    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message
            .substring(prefix.length)
            .trim();
      }
    }

    return message.isEmpty
        ? fallback
        : message;
  }

  // =====================================================
  // NORMALIZATION
  // =====================================================

  String _normalizeId(
    String value,
    String fieldName,
  ) {
    final normalizedValue =
        value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError(
        '$fieldName is required.',
      );
    }

    return normalizedValue;
  }

  String _normalizeStatus(
    String? value,
  ) {
    final status = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (status) {
      case 'confirm':
      case 'confirmed':
        return 'accepted';

      case 'otpverified':
        return 'otp_verified';

      case 'inprogress':
      case 'processing':
        return 'in_progress';

      case 'canceled':
        return 'cancelled';

      default:
        return status;
    }
  }

  int _countByStatus(
    String status,
  ) {
    final normalizedStatus =
        _normalizeStatus(status);

    return _orders.where(
      (order) {
        return _normalizeStatus(
              order.status,
            ) ==
            normalizedStatus;
      },
    ).length;
  }

  List<OrderModel> _filterByStatus(
    String status,
  ) {
    final normalizedStatus =
        _normalizeStatus(status);

    return List<OrderModel>.unmodifiable(
      _orders.where(
        (order) {
          return _normalizeStatus(
                order.status,
              ) ==
              normalizedStatus;
        },
      ),
    );
  }

  int _analyticsInt(
    String primaryKey,
    String fallbackKey,
  ) {
    final value =
        _analytics[primaryKey] ??
        _analytics[fallbackKey];

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

  double _toDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // =====================================================
  // LOCAL ORDER SYNCHRONIZATION
  // =====================================================

  void _replaceOrderInList(
    List<OrderModel> target,
    OrderModel order, {
    bool insertWhenMissing = false,
  }) {
    final index = target.indexWhere(
      (item) => item.id == order.id,
    );

    if (index >= 0) {
      target[index] = order;
      return;
    }

    if (insertWhenMissing) {
      target.insert(
        0,
        order,
      );
    }
  }

  void _applyOrderLocally(
    OrderModel order, {
    bool insertWhenMissing = true,
    bool notify = true,
  }) {
    _replaceOrderInList(
      _orders,
      order,
      insertWhenMissing:
          insertWhenMissing,
    );

    _replaceOrderInList(
      _todayOrders,
      order,
    );

    _replaceOrderInList(
      _recentOrders,
      order,
      insertWhenMissing:
          insertWhenMissing,
    );

    if (
      _selectedOrder?.id ==
      order.id
    ) {
      _selectedOrder = order;
    }

    if (notify) {
      _safeNotifyListeners();
    }
  }

  OrderModel? findOrderById(
    String orderId,
  ) {
    final normalizedId =
        orderId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    if (
      _selectedOrder?.id ==
      normalizedId
    ) {
      return _selectedOrder;
    }

    for (final order in _orders) {
      if (order.id == normalizedId) {
        return order;
      }

      if (
        order.bookingId ==
        normalizedId
      ) {
        return order;
      }
    }

    return null;
  }

  // =====================================================
  // GET ALL ORDERS
  // =====================================================

  Future<void> getOrders({
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _beginRequest();
    }

    _clearErrorWithoutNotification();

    try {
      final result =
          await _repository.getOrders();

      _orders =
          List<OrderModel>.from(
        result,
      );

      _lastRefreshedAt =
          DateTime.now();

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to load Provider orders.',
      );
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
      normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );
    } catch (error) {
      _setError(
        error,
        fallback:
            'Order ID is required.',
      );

      return null;
    }

    if (showLoading) {
      _beginRequest();
    }

    _clearErrorWithoutNotification();

    try {
      final order =
          await _repository.getOrderById(
        normalizedOrderId,
      );

      _selectedOrder = order;

      _applyOrderLocally(
        order,
        notify: false,
      );

      _safeNotifyListeners();

      return order;
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to load order details.',
      );

      return null;
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  void selectOrder(
    OrderModel? order,
  ) {
    _selectedOrder = order;

    _safeNotifyListeners();
  }

  // =====================================================
  // GET TODAY ORDERS
  // =====================================================

  Future<void> getTodayOrders({
    bool showLoading = false,
  }) async {
    if (showLoading) {
      _beginRequest();
    }

    try {
      final result =
          await _repository
              .getTodayOrders();

      _todayOrders =
          List<OrderModel>.from(
        result,
      );

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to load today\'s orders.',
      );
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  // =====================================================
  // GET RECENT ORDERS
  // =====================================================

  Future<void> getRecentOrders({
    bool showLoading = false,
  }) async {
    if (showLoading) {
      _beginRequest();
    }

    try {
      final result =
          await _repository
              .getRecentOrders();

      _recentOrders =
          List<OrderModel>.from(
        result,
      );

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to load recent orders.',
      );
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  // =====================================================
  // GET ORDERS BY STATUS
  // =====================================================

  Future<List<OrderModel>>
      getOrdersByStatus(
    String status,
  ) async {
    final normalizedStatus =
        _normalizeStatus(status);

    if (
      normalizedStatus.isEmpty ||
      normalizedStatus == 'all'
    ) {
      return orders;
    }

    try {
      final result =
          await _repository
              .getOrdersByStatus(
        normalizedStatus,
      );

      return List<OrderModel>.unmodifiable(
        result,
      );
    } catch (error) {
      debugPrint(
        'REMOTE STATUS FILTER FAILED: $error',
      );

      return _filterByStatus(
        normalizedStatus,
      );
    }
  }

  // =====================================================
  // REFRESH AFTER MUTATION
  // =====================================================

  Future<void> _refreshAfterMutation(
    String orderId,
  ) async {
    await refreshData(
      showLoading: false,
    );

    await getOrderById(
      orderId,
      showLoading: false,
    );
  }

  // =====================================================
  // ACCEPT ORDER
  //
  // pending -> accepted
  // =====================================================

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    String normalizedOrderId;

    try {
      normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );
    } catch (error) {
      _setError(
        error,
        fallback:
            'Order ID is required.',
      );

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success =
          await _repository.confirmOrder(
        normalizedOrderId,
      );

      if (!success) {
        throw Exception(
          'The Provider could not accept this order.',
        );
      }

      await _refreshAfterMutation(
        normalizedOrderId,
      );

      return true;
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to accept order.',
      );

      return false;
    } finally {
      _endRequest();
    }
  }

  Future<bool> acceptOrder(
    String orderId,
  ) {
    return confirmOrder(
      orderId,
    );
  }

  // =====================================================
  // VERIFY SERVICE OTP
  //
  // accepted -> otp_verified
  // =====================================================

  Future<bool> verifyServiceOtp({
    required String orderId,
    required String otp,
  }) async {
    String normalizedOrderId;

    try {
      normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );
    } catch (error) {
      _setError(
        error,
        fallback:
            'Order ID is required.',
      );

      return false;
    }

    final normalizedOtp =
        otp.trim();

    if (
      normalizedOtp.length != 4 ||
      int.tryParse(normalizedOtp) ==
          null
    ) {
      _setError(
        ArgumentError(
          'A valid 4-digit OTP is required.',
        ),
        fallback:
            'A valid 4-digit OTP is required.',
      );

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final updatedOrder =
          await _repository
              .verifyServiceOtp(
        orderId: normalizedOrderId,
        otp: normalizedOtp,
      );

      _selectedOrder =
          updatedOrder;

      _applyOrderLocally(
        updatedOrder,
      );

      await refreshData(
        showLoading: false,
      );

      return true;
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to verify the service OTP.',
      );

      return false;
    } finally {
      _endRequest();
    }
  }

  // =====================================================
  // START ORDER
  //
  // otp_verified -> in_progress
  // =====================================================

  Future<bool> startOrder(
    String orderId,
  ) async {
    String normalizedOrderId;

    try {
      normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );
    } catch (error) {
      _setError(
        error,
        fallback:
            'Order ID is required.',
      );

      return false;
    }

    final currentOrder =
        findOrderById(
      normalizedOrderId,
    );

    if (
      currentOrder != null &&
      !currentOrder.canStart
    ) {
      _setError(
        Exception(
          'Verify the customer service OTP before starting the service.',
        ),
        fallback:
            'Verify the customer service OTP before starting the service.',
      );

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success =
          await _repository.startOrder(
        normalizedOrderId,
      );

      if (!success) {
        throw Exception(
          'The order could not be started.',
        );
      }

      await _refreshAfterMutation(
        normalizedOrderId,
      );

      return true;
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to start order.',
      );

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

  Future<bool> completeOrder(
    String orderId,
  ) async {
    String normalizedOrderId;

    try {
      normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );
    } catch (error) {
      _setError(
        error,
        fallback:
            'Order ID is required.',
      );

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success =
          await _repository.completeOrder(
        normalizedOrderId,
      );

      if (!success) {
        throw Exception(
          'The order could not be completed.',
        );
      }

      await _refreshAfterMutation(
        normalizedOrderId,
      );

      return true;
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to complete order.',
      );

      return false;
    } finally {
      _endRequest();
    }
  }

  // =====================================================
  // REJECT ORDER
  //
  // pending -> rejected
  // =====================================================

  Future<bool> rejectOrder({
    required String orderId,
    required String reason,
  }) async {
    String normalizedOrderId;

    try {
      normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );
    } catch (error) {
      _setError(
        error,
        fallback:
            'Order ID is required.',
      );

      return false;
    }

    final normalizedReason =
        reason.trim();

    if (normalizedReason.isEmpty) {
      _setError(
        ArgumentError(
          'Rejection reason is required.',
        ),
        fallback:
            'Rejection reason is required.',
      );

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success =
          await _repository.rejectOrder(
        orderId: normalizedOrderId,
        reason: normalizedReason,
      );

      if (!success) {
        throw Exception(
          'The order could not be rejected.',
        );
      }

      await _refreshAfterMutation(
        normalizedOrderId,
      );

      return true;
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to reject order.',
      );

      return false;
    } finally {
      _endRequest();
    }
  }

  // =====================================================
  // CANCEL ORDER
  // =====================================================

  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    String normalizedOrderId;

    try {
      normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );
    } catch (error) {
      _setError(
        error,
        fallback:
            'Order ID is required.',
      );

      return false;
    }

    final normalizedReason =
        reason.trim();

    if (normalizedReason.isEmpty) {
      _setError(
        ArgumentError(
          'Cancellation reason is required.',
        ),
        fallback:
            'Cancellation reason is required.',
      );

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success =
          await _repository.cancelOrder(
        orderId: normalizedOrderId,
        reason: normalizedReason,
      );

      if (!success) {
        throw Exception(
          'The order could not be cancelled.',
        );
      }

      await _refreshAfterMutation(
        normalizedOrderId,
      );

      return true;
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to cancel order.',
      );

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
      normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );
    } catch (error) {
      _setError(
        error,
        fallback:
            'Order ID is required.',
      );

      return false;
    }

    final normalizedReason =
        reason.trim();

    if (normalizedReason.isEmpty) {
      _setError(
        ArgumentError(
          'Refund reason is required.',
        ),
        fallback:
            'Refund reason is required.',
      );

      return false;
    }

    _beginRequest();
    _clearErrorWithoutNotification();

    try {
      final success =
          await _repository.refundOrder(
        orderId: normalizedOrderId,
        reason: normalizedReason,
      );

      if (!success) {
        throw Exception(
          'Refund is unavailable or could not be processed.',
        );
      }

      await _refreshAfterMutation(
        normalizedOrderId,
      );

      return true;
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to refund order.',
      );

      return false;
    } finally {
      _endRequest();
    }
  }

  // =====================================================
  // SEARCH ORDERS
  // =====================================================

  Future<List<OrderModel>> searchOrders(
    String keyword,
  ) async {
    final normalizedKeyword =
        keyword.trim();

    if (normalizedKeyword.isEmpty) {
      return orders;
    }

    try {
      final result =
          await _repository.searchOrders(
        normalizedKeyword,
      );

      return List<OrderModel>.unmodifiable(
        result,
      );
    } catch (error) {
      final lowerKeyword =
          normalizedKeyword.toLowerCase();

      return _orders.where(
        (order) {
          return order
              .toString()
              .toLowerCase()
              .contains(
                lowerKeyword,
              );
        },
      ).toList();
    }
  }

  // =====================================================
  // ANALYTICS
  // =====================================================

  Future<void> getOrderAnalytics({
    bool showLoading = false,
  }) async {
    if (showLoading) {
      _beginRequest();
    }

    try {
      final result =
          await _repository
              .getOrderAnalytics();

      _analytics =
          Map<String, dynamic>.from(
        result,
      );

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to load order analytics.',
      );
    } finally {
      if (showLoading) {
        _endRequest();
      }
    }
  }

  Future<int> getOrderCount() async {
    try {
      return await _repository
          .getOrderCount();
    } catch (_) {
      return totalOrderCount;
    }
  }

  Future<int>
      getCompletedOrderCount() async {
    try {
      return await _repository
          .getCompletedOrderCount();
    } catch (_) {
      return completedOrderCount;
    }
  }

  Future<int>
      getPendingOrderCount() async {
    try {
      return await _repository
          .getPendingOrderCount();
    } catch (_) {
      return pendingOrderCount;
    }
  }

  Future<int>
      getAcceptedOrderCount() async {
    if (_analytics.isEmpty) {
      await getOrderAnalytics();
    }

    return analyticsAcceptedOrders > 0
        ? analyticsAcceptedOrders
        : acceptedOrderCount;
  }

  Future<int>
      getOtpVerifiedOrderCount() async {
    if (_analytics.isEmpty) {
      await getOrderAnalytics();
    }

    return analyticsOtpVerifiedOrders > 0
        ? analyticsOtpVerifiedOrders
        : otpVerifiedOrderCount;
  }

  Future<int>
      getInProgressOrderCount() async {
    if (_analytics.isEmpty) {
      await getOrderAnalytics();
    }

    return analyticsInProgressOrders > 0
        ? analyticsInProgressOrders
        : inProgressOrderCount;
  }

  Future<int>
      getCancelledOrderCount() async {
    if (_analytics.isEmpty) {
      await getOrderAnalytics();
    }

    return analyticsCancelledOrders > 0
        ? analyticsCancelledOrders
        : cancelledOrderCount;
  }

  Future<int>
      getRejectedOrderCount() async {
    if (_analytics.isEmpty) {
      await getOrderAnalytics();
    }

    return analyticsRejectedOrders > 0
        ? analyticsRejectedOrders
        : rejectedOrderCount;
  }

  // =====================================================
  // REVENUE
  // =====================================================

  Future<double> getTotalRevenue({
    bool forceRefresh = true,
  }) async {
    if (
      !forceRefresh &&
      _lastRefreshedAt != null
    ) {
      return _totalRevenue;
    }

    try {
      final result =
          await _repository
              .getTotalRevenue();

      _totalRevenue =
          _toDouble(result);

      _safeNotifyListeners();

      return _totalRevenue;
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to load total revenue.',
      );

      return _totalRevenue;
    }
  }

  // =====================================================
  // INVOICE
  // =====================================================

  Future<String?> downloadInvoice(
    String orderId,
  ) async {
    try {
      final normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );

      return await _repository
          .downloadInvoice(
        normalizedOrderId,
      );
    } catch (error) {
      _setError(
        error,
        fallback:
            'Invoice is unavailable.',
      );

      return null;
    }
  }

  // =====================================================
  // REAL-TIME ORDER EVENT
  // =====================================================

  Future<void> handleOrderEvent(
    dynamic event,
  ) async {
    try {
      if (event is Map) {
        final eventMap =
            event.map(
          (key, value) {
            return MapEntry(
              key.toString(),
              value,
            );
          },
        );

        final candidate =
            eventMap['booking'] ??
            eventMap['order'] ??
            eventMap['data'] ??
            eventMap;

        if (candidate is Map) {
          final orderMap =
              candidate.map(
            (key, value) {
              return MapEntry(
                key.toString(),
                value,
              );
            },
          );

          final order =
              OrderModel.fromMap(
            orderMap,
          );

          if (order.id.isNotEmpty) {
            _applyOrderLocally(
              order,
            );
          }
        }
      }

      await refreshData(
        showLoading: false,
      );
    } catch (error) {
      debugPrint(
        'PROVIDER ORDER EVENT ERROR: $error',
      );

      await getOrders(
        showLoading: false,
      );
    }
  }

  // =====================================================
  // REFRESH ALL ORDER DATA
  // =====================================================

  Future<void> refreshData({
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _beginRequest();
    }

    _clearErrorWithoutNotification();

    try {
      final results =
          await Future.wait<dynamic>(
        <Future<dynamic>>[
          _repository.getOrders(),
          _repository.getTodayOrders(),
          _repository.getRecentOrders(),
          _repository.getOrderAnalytics(),
          _repository.getTotalRevenue(),
        ],
      );

      _orders =
          List<OrderModel>.from(
        results[0] as List,
      );

      _todayOrders =
          List<OrderModel>.from(
        results[1] as List,
      );

      _recentOrders =
          List<OrderModel>.from(
        results[2] as List,
      );

      _analytics =
          Map<String, dynamic>.from(
        results[3] as Map,
      );

      _totalRevenue =
          _toDouble(
        results[4],
      );

      _lastRefreshedAt =
          DateTime.now();

      if (_selectedOrder != null) {
        final matchingOrder =
            findOrderById(
          _selectedOrder!.id,
        );

        if (matchingOrder != null) {
          _selectedOrder =
              matchingOrder;
        }
      }

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        error,
        fallback:
            'Unable to refresh Provider order data.',
      );

      try {
        final fallbackOrders =
            await _repository
                .getOrders();

        _orders =
            List<OrderModel>.from(
          fallbackOrders,
        );

        _lastRefreshedAt =
            DateTime.now();

        _safeNotifyListeners();
      } catch (fallbackError) {
        debugPrint(
          'ORDER REFRESH FALLBACK ERROR: $fallbackError',
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

    _orders =
        <OrderModel>[];

    _todayOrders =
        <OrderModel>[];

    _recentOrders =
        <OrderModel>[];

    _selectedOrder = null;

    _analytics =
        <String, dynamic>{};

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