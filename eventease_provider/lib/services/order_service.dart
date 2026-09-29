import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/order_model.dart';

class OrderService {
  OrderService._();

  static final OrderService _instance =
      OrderService._();

  static OrderService get instance {
    return _instance;
  }

  final ApiService _apiService =
      ApiService.instance;

  // =====================================================
  // RESPONSE HELPERS
  // =====================================================

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, item) {
          return MapEntry(
            key.toString(),
            item,
          );
        },
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
        final nested = _asMap(payload);

        final nestedList =
            nested['orders'] ??
            nested['bookings'] ??
            nested['items'] ??
            nested['results'];

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
        map['invoice'] ??
        map['data'] ??
        map;

    return _asMap(payload);
  }

  String _normalizeId(
    String value,
    String fieldName,
  ) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError(
        '$fieldName is required.',
      );
    }

    return normalized;
  }

  String _normalizeStatus(
    String value,
  ) {
    final status = value
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

  int _normalizePage(
    int page,
  ) {
    return page < 1 ? 1 : page;
  }

  int _normalizeLimit(
    int limit,
  ) {
    if (limit < 1) {
      return 100;
    }

    return limit > 100 ? 100 : limit;
  }

  OrderModel _orderFromResponse(
    dynamic response,
  ) {
    final data = _extractSingle(
      response,
    );

    if (data.isEmpty) {
      throw const FormatException(
        'The backend did not return valid booking data.',
      );
    }

    return OrderModel.fromMap(
      data,
    );
  }

  List<OrderModel> _ordersFromResponse(
    dynamic response,
  ) {
    final orders = <OrderModel>[];

    for (final item in _extractList(response)) {
      if (item is! Map) {
        continue;
      }

      try {
        orders.add(
          OrderModel.fromMap(
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
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  // =====================================================
  // BOOKING ID RESOLUTION
  // =====================================================

  Future<String> _resolveBookingId(
    String orderOrBookingId,
  ) async {
    final normalizedId = _normalizeId(
      orderOrBookingId,
      'Order or Booking ID',
    );

    try {
      final order = await getOrderById(
        normalizedId,
      );

      if (order.bookingId.trim().isNotEmpty) {
        return order.bookingId.trim();
      }

      if (order.id.trim().isNotEmpty) {
        return order.id.trim();
      }
    } catch (error) {
      log(
        'Using supplied identifier as Booking ID: $error',
      );
    }

    return normalizedId;
  }

  // =====================================================
  // GET ORDERS
  // =====================================================

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

      final response = await _apiService.get(
        '/provider/orders',
        queryParameters: {
          'page': _normalizePage(page),
          'limit': _normalizeLimit(limit),
          if (normalizedStatus.isNotEmpty)
            'status': normalizedStatus,
        },
      );

      return _ordersFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Get Orders Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET ORDER BY ID
  // =====================================================

  Future<OrderModel> getOrderById(
    String orderId,
  ) async {
    try {
      final normalizedOrderId = _normalizeId(
        orderId,
        'Order ID',
      );

      final response = await _apiService.get(
        '/bookings/$normalizedOrderId',
      );

      return _orderFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Get Order Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // TODAY ORDERS
  // =====================================================

  Future<List<OrderModel>> getTodayOrders() async {
    try {
      final response = await _apiService.get(
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

  // =====================================================
  // RECENT ORDERS
  // =====================================================

  Future<List<OrderModel>> getRecentOrders() async {
    try {
      final response = await _apiService.get(
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

  // =====================================================
  // ORDERS BY STATUS
  // =====================================================

  Future<List<OrderModel>> getOrdersByStatus(
    String status,
  ) async {
    final normalizedStatus = _normalizeStatus(
      status,
    );

    if (
      normalizedStatus.isEmpty ||
      normalizedStatus == 'all'
    ) {
      return getOrders();
    }

    return getOrders(
      status: normalizedStatus,
    );
  }

  // =====================================================
  // UPDATE STATUS
  // =====================================================

  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
    String? reason,
    String? note,
  }) async {
    try {
      final bookingId = await _resolveBookingId(
        orderId,
      );

      final normalizedStatus = _normalizeStatus(
        status,
      );

      const allowedStatuses = <String>{
        'accepted',
        'rejected',
        'in_progress',
        'completed',
        'cancelled',
      };

      if (!allowedStatuses.contains(normalizedStatus)) {
        throw ArgumentError(
          'Invalid order status: $normalizedStatus',
        );
      }

      final response = await _apiService.patch(
        '/bookings/$bookingId/status',
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

      return _orderFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Update Order Status Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // ACCEPT ORDER
  // =====================================================

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    await updateOrderStatus(
      orderId: orderId,
      status: 'accepted',
    );

    return true;
  }

  Future<bool> acceptOrder(
    String orderId,
  ) {
    return confirmOrder(
      orderId,
    );
  }

  // =====================================================
  // MARK PROVIDER ARRIVED
  // =====================================================

  Future<OrderModel> markProviderArrived({
    required String orderId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final bookingId = await _resolveBookingId(
        orderId,
      );

      final response = await _apiService.patch(
        '/bookings/$bookingId/arrived',
        body: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      return _orderFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Mark Provider Arrived Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // VERIFY SERVICE OTP
  // =====================================================

  Future<OrderModel> verifyServiceOtp({
    required String orderId,
    required String otp,
  }) async {
    try {
      final bookingId = await _resolveBookingId(
        orderId,
      );

      final normalizedOtp = otp.trim();

      if (
        normalizedOtp.length != 4 ||
        int.tryParse(normalizedOtp) == null
      ) {
        throw ArgumentError(
          'A valid 4-digit service OTP is required.',
        );
      }

      final response = await _apiService.post(
        '/bookings/$bookingId/verify-service-otp',
        body: {
          'otp': normalizedOtp,
        },
      );

      return _orderFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Verify Service OTP Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // START ORDER
  // =====================================================

  Future<bool> startOrder(
    String orderId,
  ) async {
    await updateOrderStatus(
      orderId: orderId,
      status: 'in_progress',
    );

    return true;
  }

  // =====================================================
  // COMPLETE ORDER
  // =====================================================

  Future<bool> completeOrder(
    String orderId,
  ) async {
    await updateOrderStatus(
      orderId: orderId,
      status: 'completed',
    );

    return true;
  }

  // =====================================================
  // REJECT ORDER
  // =====================================================

  Future<bool> rejectOrder({
    required String orderId,
    required String reason,
  }) async {
    final normalizedReason = reason.trim();

    if (normalizedReason.isEmpty) {
      throw ArgumentError(
        'Rejection reason is required.',
      );
    }

    await updateOrderStatus(
      orderId: orderId,
      status: 'rejected',
      reason: normalizedReason,
      note: normalizedReason,
    );

    return true;
  }

  // =====================================================
  // CANCEL ORDER
  // =====================================================

  Future<bool> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    final normalizedReason = reason.trim();

    if (normalizedReason.isEmpty) {
      throw ArgumentError(
        'Cancellation reason is required.',
      );
    }

    await updateOrderStatus(
      orderId: orderId,
      status: 'cancelled',
      reason: normalizedReason,
      note: normalizedReason,
    );

    return true;
  }

  // =====================================================
  // REFUND
  // =====================================================

  Future<bool> refundOrder({
    required String orderId,
    required String reason,
  }) async {
    log(
      'Refund is not supported by the current backend. '
      'Order ID: $orderId. Reason: $reason',
    );

    return false;
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<List<OrderModel>> searchOrders(
    String keyword,
  ) async {
    final normalizedKeyword =
        keyword.trim().toLowerCase();

    final orders = await getOrders();

    if (normalizedKeyword.isEmpty) {
      return orders;
    }

    return orders.where(
      (order) {
        final searchableText = [
          order.orderNumber,
          order.bookingNumber,
          order.bookingId,
          order.customerName,
          order.customerEmail,
          order.customerPhone,
          order.serviceName,
          order.status,
          order.eventAddress,
          order.location,
          order.transactionId,
        ].join(' ').toLowerCase();

        return searchableText.contains(
          normalizedKeyword,
        );
      },
    ).toList();
  }

  // =====================================================
  // ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    try {
      final response = await _apiService.get(
        '/provider/orders/analytics',
      );

      return _extractMap(
        response,
      );
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
    final analytics = await getOrderAnalytics();

    return _toInt(
      analytics['totalOrders'] ??
          analytics['totalBookings'],
    );
  }

  Future<int> getCompletedOrderCount() async {
    final analytics = await getOrderAnalytics();

    return _toInt(
      analytics['completedOrders'] ??
          analytics['completedBookings'],
    );
  }

  Future<int> getPendingOrderCount() async {
    final analytics = await getOrderAnalytics();

    return _toInt(
      analytics['pendingOrders'] ??
          analytics['pendingBookings'],
    );
  }

  // =====================================================
  // REVENUE
  // =====================================================

  Future<double> getTotalRevenue() async {
    try {
      final response = await _apiService.get(
        '/provider/earnings',
      );

      final data = _extractMap(
        response,
      );

      return _toDouble(
        data['totalEarnings'] ??
            data['totalRevenue'] ??
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

  // =====================================================
  // INVOICE
  // =====================================================

  Future<Map<String, dynamic>> getInvoice(
    String orderId,
  ) async {
    try {
      final bookingId = await _resolveBookingId(
        orderId,
      );

      final response = await _apiService.get(
        '/bookings/$bookingId/invoice',
      );

      final invoice = _extractMap(
        response,
      );

      if (invoice.isEmpty) {
        throw const FormatException(
          'The backend did not return valid invoice data.',
        );
      }

      return invoice;
    } catch (error, stackTrace) {
      log(
        'Get Invoice Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<String?> downloadInvoice(
    String orderId,
  ) async {
    final invoice = await getInvoice(
      orderId,
    );

    final invoiceUrl =
        invoice['invoiceUrl']
            ?.toString()
            .trim();

    if (
      invoiceUrl == null ||
      invoiceUrl.isEmpty
    ) {
      return null;
    }

    return invoiceUrl;
  }
}