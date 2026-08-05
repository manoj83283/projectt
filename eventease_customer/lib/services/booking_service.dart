import '../models/booking_model.dart';
import '../models/order_model.dart';
import 'api_service.dart';

class BookingService {
  BookingService._();

  static final BookingService instance = BookingService._();

  // ==========================================
  // RESPONSE HELPERS
  // ==========================================

  dynamic _responseData(dynamic response) {
    try {
      return response.data;
    } catch (_) {
      return response;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  dynamic _extractSingle(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map<String, dynamic>) {
      return data['data'] ??
          data['order'] ??
          data['booking'] ??
          data['result'] ??
          data;
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      return map['data'] ??
          map['order'] ??
          map['booking'] ??
          map['result'] ??
          map;
    }

    return data;
  }

  List<dynamic> _extractList(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map<String, dynamic>) {
      final dynamic list = data['data'] ??
          data['orders'] ??
          data['bookings'] ??
          data['items'] ??
          data['results'];

      if (list is List) {
        return list;
      }
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      final dynamic list = map['data'] ??
          map['orders'] ??
          map['bookings'] ??
          map['items'] ??
          map['results'];

      if (list is List) {
        return list;
      }
    }

    if (data is List) {
      return data;
    }

    return [];
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map<String, dynamic>) {
      final dynamic payload = data['data'] ?? data;

      if (payload is Map<String, dynamic>) {
        return payload;
      }

      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final dynamic payload = map['data'] ?? map;

      if (payload is Map<String, dynamic>) {
        return payload;
      }

      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
    }

    return <String, dynamic>{};
  }

  OrderModel _orderFromResponse(dynamic response) {
    return OrderModel.fromMap(
      _asMap(
        _extractSingle(response),
      ),
    );
  }

  BookingModel _bookingFromResponse(dynamic response) {
    return BookingModel.fromMap(
      _asMap(
        _extractSingle(response),
      ),
    );
  }

  List<OrderModel> _ordersFromResponse(dynamic response) {
    return _extractList(response)
        .map(
          (item) => OrderModel.fromMap(
            _asMap(item),
          ),
        )
        .toList();
  }

  List<BookingModel> _bookingsFromResponse(dynamic response) {
    return _extractList(response)
        .map(
          (item) => BookingModel.fromMap(
            _asMap(item),
          ),
        )
        .toList();
  }

  // ==========================================
  // CREATE ORDER
  // ==========================================

  Future<OrderModel> createOrder({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    final dynamic response = await ApiService.instance.post(
      '/orders',
      data: {
        'bookingId': bookingId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );

    return _orderFromResponse(response);
  }

  // ==========================================
  // MY ORDERS
  // ==========================================

  Future<List<OrderModel>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final dynamic response = await ApiService.instance.get(
      '/orders/my',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return _ordersFromResponse(response);
  }

  // ==========================================
  // GET ORDER BY ID
  // ==========================================

  Future<OrderModel> getOrderById(
    String orderId,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/orders/$orderId',
    );

    return _orderFromResponse(response);
  }

  // ==========================================
  // ORDER HISTORY
  // ==========================================

  Future<List<OrderModel>> getOrderHistory() async {
    final dynamic response = await ApiService.instance.get(
      '/orders/history',
    );

    return _ordersFromResponse(response);
  }

  // ==========================================
  // TRACK ORDER
  // ==========================================

  Future<Map<String, dynamic>> trackOrder(
    String orderId,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/orders/$orderId/track',
    );

    return _extractMap(response);
  }

  // ==========================================
  // UPDATE ORDER STATUS
  // ==========================================

  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
  }) async {
    final dynamic response = await ApiService.instance.patch(
      '/orders/$orderId/status',
      data: {
        'status': status,
      },
    );

    return _orderFromResponse(response);
  }

  // ==========================================
  // CANCEL ORDER
  // ==========================================

  Future<bool> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    await ApiService.instance.patch(
      '/orders/$orderId/cancel',
      data: {
        if (reason != null && reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
    );

    return true;
  }

  // ==========================================
  // CONFIRM ORDER
  // ==========================================

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    await ApiService.instance.patch(
      '/orders/$orderId/confirm',
    );

    return true;
  }

  // ==========================================
  // PROCESS ORDER
  // ==========================================

  Future<bool> processOrder(
    String orderId,
  ) async {
    await ApiService.instance.patch(
      '/orders/$orderId/process',
    );

    return true;
  }

  // ==========================================
  // SHIP ORDER
  // ==========================================

  Future<bool> shipOrder(
    String orderId,
  ) async {
    await ApiService.instance.patch(
      '/orders/$orderId/ship',
    );

    return true;
  }

  // ==========================================
  // DELIVER ORDER
  // ==========================================

  Future<bool> deliverOrder(
    String orderId,
  ) async {
    await ApiService.instance.patch(
      '/orders/$orderId/deliver',
    );

    return true;
  }

  // ==========================================
  // DELETE ORDER
  // ==========================================

  Future<bool> deleteOrder(
    String orderId,
  ) async {
    await ApiService.instance.delete(
      '/orders/$orderId',
    );

    return true;
  }

  // ==========================================
  // PROVIDER ORDERS
  // ==========================================

  Future<List<OrderModel>> getProviderOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final dynamic response = await ApiService.instance.get(
      '/orders/provider',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return _ordersFromResponse(response);
  }

  // ==========================================
  // CREATE BOOKING
  // ==========================================

  Future<BookingModel> createBooking({
    required String serviceId,
    DateTime? bookingDate,
    String? bookingTime,
    double? amount,
    String? providerId,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
    String? couponCode,
    Map<String, dynamic>? data,
  }) async {
    final Map<String, dynamic> payload = {
      ...?data,
      'serviceId': serviceId,
      if (bookingDate != null) 'bookingDate': bookingDate.toIso8601String(),
      if (bookingTime != null && bookingTime.trim().isNotEmpty)
        'bookingTime': bookingTime.trim(),
      if (amount != null) 'amount': amount,
      if (providerId != null && providerId.trim().isNotEmpty)
        'providerId': providerId.trim(),
      if (address != null && address.trim().isNotEmpty)
        'address': address.trim(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      if (couponCode != null && couponCode.trim().isNotEmpty)
        'couponCode': couponCode.trim(),
    };

    final dynamic response = await ApiService.instance.post(
      '/bookings',
      data: payload,
    );

    return _bookingFromResponse(response);
  }

  // ==========================================
  // MY BOOKINGS
  // ==========================================

  Future<List<BookingModel>> getMyBookings({
    int page = 1,
    int limit = 20,
  }) async {
    final dynamic response = await ApiService.instance.get(
      '/bookings/my',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return _bookingsFromResponse(response);
  }

  // ==========================================
  // GET BOOKING BY ID
  // ==========================================

  Future<BookingModel> getBookingById(
    String bookingId,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/bookings/$bookingId',
    );

    return _bookingFromResponse(response);
  }

  // ==========================================
  // PROVIDER BOOKINGS
  // ==========================================

  Future<List<BookingModel>> getProviderBookings({
    int page = 1,
    int limit = 20,
  }) async {
    final dynamic response = await ApiService.instance.get(
      '/bookings/provider',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return _bookingsFromResponse(response);
  }

  // ==========================================
  // BOOKING HISTORY
  // ==========================================

  Future<List<BookingModel>> getBookingHistory() async {
    final dynamic response = await ApiService.instance.get(
      '/bookings/history',
    );

    return _bookingsFromResponse(response);
  }

  // ==========================================
  // UPDATE BOOKING STATUS
  // ==========================================

  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final dynamic response = await ApiService.instance.patch(
      '/bookings/$bookingId/status',
      data: {
        'status': status,
      },
    );

    return _bookingFromResponse(response);
  }

  // ==========================================
  // ACCEPT BOOKING
  // ==========================================

  Future<bool> acceptBooking(
    String bookingId,
  ) async {
    await ApiService.instance.patch(
      '/bookings/$bookingId/accept',
    );

    return true;
  }

  // ==========================================
  // CONFIRM BOOKING
  // ==========================================

  Future<bool> confirmBooking(
    String bookingId,
  ) async {
    await ApiService.instance.patch(
      '/bookings/$bookingId/confirm',
    );

    return true;
  }

  // ==========================================
  // START BOOKING
  // ==========================================

  Future<bool> startBooking(
    String bookingId,
  ) async {
    await ApiService.instance.patch(
      '/bookings/$bookingId/start',
    );

    return true;
  }

  // ==========================================
  // COMPLETE BOOKING
  // ==========================================

  Future<bool> completeBooking(
    String bookingId,
  ) async {
    await ApiService.instance.patch(
      '/bookings/$bookingId/complete',
    );

    return true;
  }

  // ==========================================
  // CANCEL BOOKING
  // ==========================================

  Future<bool> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    await ApiService.instance.patch(
      '/bookings/$bookingId/cancel',
      data: {
        if (reason != null && reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
    );

    return true;
  }

  // ==========================================
  // RESCHEDULE BOOKING
  // ==========================================

  Future<bool> rescheduleBooking({
    required String bookingId,
    DateTime? bookingDate,
    String? bookingTime,
    String? reason,
  }) async {
    await ApiService.instance.patch(
      '/bookings/$bookingId/reschedule',
      data: {
        if (bookingDate != null) 'bookingDate': bookingDate.toIso8601String(),
        if (bookingTime != null && bookingTime.trim().isNotEmpty)
          'bookingTime': bookingTime.trim(),
        if (reason != null && reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
    );

    return true;
  }

  // ==========================================
  // TRACK BOOKING
  // Supports:
  // trackBooking(bookingId: bookingId)
  // ==========================================

  Future<Map<String, dynamic>> trackBooking({
    required String bookingId,
  }) async {
    final dynamic response = await ApiService.instance.get(
      '/bookings/$bookingId/track',
    );

    return _extractMap(response);
  }

  // ==========================================
  // DELETE BOOKING
  // ==========================================

  Future<bool> deleteBooking(
    String bookingId,
  ) async {
    await ApiService.instance.delete(
      '/bookings/$bookingId',
    );

    return true;
  }
}

// ==========================================
// BACKWARD COMPATIBILITY
// Existing code using OrderService.instance
// will continue working.
// ==========================================

class OrderService {
  OrderService._();

  static final OrderService instance = OrderService._();

  final BookingService _service = BookingService.instance;

  Future<OrderModel> createOrder({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) {
    return _service.createOrder(
      bookingId: bookingId,
      amount: amount,
      paymentMethod: paymentMethod,
      notes: notes,
    );
  }

  Future<List<OrderModel>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) {
    return _service.getMyOrders(
      page: page,
      limit: limit,
    );
  }

  Future<OrderModel> getOrderById(
    String orderId,
  ) {
    return _service.getOrderById(
      orderId,
    );
  }

  Future<List<OrderModel>> getOrderHistory() {
    return _service.getOrderHistory();
  }

  Future<Map<String, dynamic>> trackOrder(
    String orderId,
  ) {
    return _service.trackOrder(
      orderId,
    );
  }

  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
  }) {
    return _service.updateStatus(
      orderId: orderId,
      status: status,
    );
  }

  Future<bool> cancelOrder({
    required String orderId,
    String? reason,
  }) {
    return _service.cancelOrder(
      orderId: orderId,
      reason: reason,
    );
  }

  Future<bool> confirmOrder(
    String orderId,
  ) {
    return _service.confirmOrder(
      orderId,
    );
  }

  Future<bool> processOrder(
    String orderId,
  ) {
    return _service.processOrder(
      orderId,
    );
  }

  Future<bool> shipOrder(
    String orderId,
  ) {
    return _service.shipOrder(
      orderId,
    );
  }

  Future<bool> deliverOrder(
    String orderId,
  ) {
    return _service.deliverOrder(
      orderId,
    );
  }

  Future<bool> deleteOrder(
    String orderId,
  ) {
    return _service.deleteOrder(
      orderId,
    );
  }

  Future<List<OrderModel>> getProviderOrders({
    int page = 1,
    int limit = 20,
  }) {
    return _service.getProviderOrders(
      page: page,
      limit: limit,
    );
  }
}