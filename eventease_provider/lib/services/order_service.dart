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

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key.toString(),
          item,
        ),
      );
    }

    return <String, dynamic>{};
  }

  List<dynamic> _extractList(
    dynamic response,
  ) {
    if (response is List) {
      return response;
    }

    if (response is Map) {
      final map = _asMap(response);

      final payload =
          map['orders'] ??
          map['bookings'] ??
          map['items'] ??
          map['results'] ??
          map['data'];

      if (payload is List) {
        return payload;
      }

      if (payload is Map) {
        final nestedMap =
            _asMap(payload);

        final nestedList =
            nestedMap['orders'] ??
            nestedMap['bookings'] ??
            nestedMap['items'] ??
            nestedMap['results'];

        if (nestedList is List) {
          return nestedList;
        }
      }
    }

    return <dynamic>[];
  }

  Map<String, dynamic> _extractSingle(
    dynamic response,
  ) {
    if (response is! Map) {
      return <String, dynamic>{};
    }

    final map = _asMap(response);

    final payload =
        map['order'] ??
        map['booking'] ??
        map['result'] ??
        map['data'] ??
        map;

    return _asMap(payload);
  }

  Map<String, dynamic> _extractMap(
    dynamic response,
  ) {
    if (response is! Map) {
      return <String, dynamic>{};
    }

    final map = _asMap(response);

    final payload =
        map['analytics'] ??
        map['dashboard'] ??
        map['data'] ??
        map;

    return _asMap(payload);
  }

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
    String value,
  ) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  bool _matchesSearch(
    OrderModel order,
    String keyword,
  ) {
    final normalizedKeyword =
        keyword.trim().toLowerCase();

    if (normalizedKeyword.isEmpty) {
      return true;
    }

    final searchableText =
        order.toString().toLowerCase();

    return searchableText.contains(
      normalizedKeyword,
    );
  }

  List<OrderModel> _ordersFromResponse(
    dynamic response,
  ) {
    final orders =
        <OrderModel>[];

    for (final item
        in _extractList(response)) {
      if (item is! Map) {
        continue;
      }

      try {
        orders.add(
          OrderModel.fromJson(
            _asMap(item),
          ),
        );
      } catch (error, stackTrace) {
        log(
          'Order parsing failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return orders;
  }

  Future<List<OrderModel>> getOrders({
    int page = 1,
    int limit = 100,
    String? status,
  }) async {
    try {
      final normalizedStatus =
          status == null
              ? ''
              : _normalizeStatus(status);

      final response =
          await _apiService.get(
        '/provider/orders',
        queryParameters: {
          'page': page < 1 ? 1 : page,
          'limit': limit < 1
              ? 100
              : limit > 100
                  ? 100
                  : limit,
          if (normalizedStatus.isNotEmpty)
            'status': normalizedStatus,
        },
      );

      final orders =
          _ordersFromResponse(response);

      log(
        'Provider orders loaded: '
        '${orders.length}',
      );

      return orders;
    } catch (error, stackTrace) {
      log(
        'Get Orders Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<OrderModel> getOrderById(
    String orderId,
  ) async {
    try {
      final normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );

      final response =
          await _apiService.get(
        '/bookings/$normalizedOrderId',
      );

      final data =
          _extractSingle(response);

      if (data.isEmpty) {
        throw const FormatException(
          'The backend did not return valid booking data.',
        );
      }

      return OrderModel.fromJson(data);
    } catch (error, stackTrace) {
      log(
        'Get Order Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<List<OrderModel>>
      getTodayOrders() async {
    try {
      final response =
          await _apiService.get(
        '/provider/orders/today',
      );

      return _ordersFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Today Orders Error',
        error: error,
        stackTrace: stackTrace,
      );

      return <OrderModel>[];
    }
  }

  Future<List<OrderModel>>
      getRecentOrders() async {
    try {
      final response =
          await _apiService.get(
        '/provider/orders/recent',
      );

      return _ordersFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Recent Orders Error',
        error: error,
        stackTrace: stackTrace,
      );

      return <OrderModel>[];
    }
  }

  Future<List<OrderModel>>
      getOrdersByStatus(
    String status,
  ) async {
    try {
      final normalizedStatus =
          _normalizeStatus(status);

      if (normalizedStatus.isEmpty) {
        return getOrders();
      }

      final orders =
          await getOrders();

      return orders.where(
        (order) {
          final orderMap =
              _asMap(
            order.toJson(),
          );

          final orderStatus =
              _normalizeStatus(
            orderMap['status']
                    ?.toString() ??
                orderMap['bookingStatus']
                    ?.toString() ??
                '',
          );

          return orderStatus ==
              normalizedStatus;
        },
      ).toList();
    } catch (error, stackTrace) {
      log(
        'Get Orders By Status Error',
        error: error,
        stackTrace: stackTrace,
      );

      return <OrderModel>[];
    }
  }

  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
    String? reason,
    String? note,
  }) async {
    try {
      final normalizedOrderId =
          _normalizeId(
        orderId,
        'Order ID',
      );

      final normalizedStatus =
          _normalizeStatus(status);

      const allowedStatuses =
          <String>{
        'accepted',
        'rejected',
        'in_progress',
        'completed',
        'cancelled',
      };

      if (!allowedStatuses.contains(
        normalizedStatus,
      )) {
        throw ArgumentError(
          'Invalid order status: '
          '$normalizedStatus',
        );
      }

      log(
        'Updating booking '
        '$normalizedOrderId '
        'to $normalizedStatus',
      );

      final response =
          await _apiService.patch(
        '/bookings/'
        '$normalizedOrderId/status',
        body: {
          'status': normalizedStatus,
          if (reason != null &&
              reason.trim().isNotEmpty)
            'reason': reason.trim(),
          if (note != null &&
              note.trim().isNotEmpty)
            'note': note.trim(),
        },
      );

      final data =
          _extractSingle(response);

      if (data.isEmpty) {
        throw const FormatException(
          'The backend did not return the updated booking.',
        );
      }

      return OrderModel.fromJson(data);
    } catch (error, stackTrace) {
      log(
        'Update Order Status Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    try {
      await updateOrderStatus(
        orderId: orderId,
        status: 'accepted',
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Confirm Order Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> acceptOrder(
    String orderId,
  ) {
    return confirmOrder(orderId);
  }

  Future<bool> startOrder(
    String orderId,
  ) async {
    try {
      await updateOrderStatus(
        orderId: orderId,
        status: 'in_progress',
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Start Order Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> completeOrder(
    String orderId,
  ) async {
    try {
      await updateOrderStatus(
        orderId: orderId,
        status: 'completed',
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Complete Order Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> rejectOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      await updateOrderStatus(
        orderId: orderId,
        status: 'rejected',
        reason: reason,
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Reject Order Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      await updateOrderStatus(
        orderId: orderId,
        status: 'cancelled',
        reason: reason,
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Cancel Order Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> refundOrder({
    required String orderId,
    required String reason,
  }) async {
    log(
      'Refund is not supported by the '
      'current booking backend. '
      'Order ID: $orderId. '
      'Reason: $reason',
    );

    return false;
  }

  Future<List<OrderModel>> searchOrders(
    String keyword,
  ) async {
    try {
      final orders =
          await getOrders();

      return orders
          .where(
            (order) => _matchesSearch(
              order,
              keyword,
            ),
          )
          .toList();
    } catch (error, stackTrace) {
      log(
        'Search Orders Error',
        error: error,
        stackTrace: stackTrace,
      );

      return <OrderModel>[];
    }
  }

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    try {
      final response =
          await _apiService.get(
        '/provider/orders/analytics',
      );

      return _extractMap(response);
    } catch (error, stackTrace) {
      log(
        'Order Analytics Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<int> getOrderCount() async {
    try {
      final analytics =
          await getOrderAnalytics();

      return _toInt(
        analytics['totalOrders'] ??
            analytics['totalBookings'],
      );
    } catch (error, stackTrace) {
      log(
        'Order Count Error',
        error: error,
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  Future<int>
      getCompletedOrderCount() async {
    try {
      final analytics =
          await getOrderAnalytics();

      return _toInt(
        analytics['completedOrders'] ??
            analytics[
                'completedBookings'],
      );
    } catch (error, stackTrace) {
      log(
        'Completed Order Count Error',
        error: error,
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  Future<int> getPendingOrderCount() async {
    try {
      final analytics =
          await getOrderAnalytics();

      return _toInt(
        analytics['pendingOrders'] ??
            analytics['pendingBookings'],
      );
    } catch (error, stackTrace) {
      log(
        'Pending Order Count Error',
        error: error,
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  Future<double> getTotalRevenue() async {
    try {
      final response =
          await _apiService.get(
        '/provider/earnings',
      );

      final data =
          _extractMap(response);

      return _toDouble(
        data['totalEarnings'] ??
            data['availableBalance'],
      );
    } catch (error, stackTrace) {
      log(
        'Revenue Error',
        error: error,
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  Future<String?> downloadInvoice(
    String orderId,
  ) async {
    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    log(
      'Invoice endpoint is not implemented '
      'for booking $normalizedOrderId.',
    );

    return null;
  }

  int _toInt(
    dynamic value,
  ) {
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
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}