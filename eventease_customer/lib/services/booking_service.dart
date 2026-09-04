import '../models/booking_model.dart';
import '../models/order_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class BookingService {
  BookingService._();

  static final BookingService instance =
      BookingService._();

  // =====================================================
  // RESPONSE HELPERS
  // =====================================================

  dynamic _responseData(
    dynamic response,
  ) {
    try {
      return response.data;
    } catch (_) {
      return response;
    }
  }

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (
          key,
          dynamic item,
        ) {
          return MapEntry(
            key.toString(),
            item,
          );
        },
      );
    }

    return <String, dynamic>{};
  }

  dynamic _extractSingle(
    dynamic response,
  ) {
    final dynamic responseData =
        _responseData(response);

    if (responseData is Map) {
      final map = _asMap(
        responseData,
      );

      /*
       * The backend commonly returns:
       *
       * {
       *   "success": true,
       *   "booking": {...},
       *   "data": {...}
       * }
       *
       * Prefer specifically named objects first.
       */
      return map['booking'] ??
          map['order'] ??
          map['result'] ??
          map['data'] ??
          map;
    }

    return responseData;
  }

  List<dynamic> _extractList(
    dynamic response,
  ) {
    final dynamic responseData =
        _responseData(response);

    if (responseData is List) {
      return responseData;
    }

    if (responseData is Map) {
      final map = _asMap(
        responseData,
      );

      /*
       * Prefer specifically named lists before `data`.
       */
      final dynamic list =
          map['bookings'] ??
          map['orders'] ??
          map['items'] ??
          map['results'] ??
          map['data'];

      if (list is List) {
        return list;
      }

      /*
       * Some APIs wrap lists one level deeper:
       *
       * {
       *   "data": {
       *     "bookings": [...]
       *   }
       * }
       */
      if (list is Map) {
        final nestedMap =
            _asMap(list);

        final dynamic nestedList =
            nestedMap['bookings'] ??
            nestedMap['orders'] ??
            nestedMap['items'] ??
            nestedMap['results'];

        if (nestedList is List) {
          return nestedList;
        }
      }
    }

    return <dynamic>[];
  }

  Map<String, dynamic> _extractMap(
    dynamic response,
  ) {
    final dynamic responseData =
        _responseData(response);

    if (responseData is Map) {
      final map = _asMap(
        responseData,
      );

      final dynamic payload =
          map['data'] ??
          map['result'] ??
          map;

      if (payload is Map) {
        return _asMap(payload);
      }
    }

    return <String, dynamic>{};
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

  int _normalizePage(
    int page,
  ) {
    return page < 1 ? 1 : page;
  }

  int _normalizeLimit(
    int limit,
  ) {
    if (limit < 1) {
      return 20;
    }

    if (limit > 100) {
      return 100;
    }

    return limit;
  }

  // =====================================================
  // AUTHENTICATION
  // =====================================================

  Future<void> _ensureAuthenticated() async {
    await AuthService.instance
        .ensureAuthenticated();

    if (!ApiService.instance.hasAuthToken) {
      throw Exception(
        'Authentication token is unavailable. '
        'Please sign in again.',
      );
    }
  }

  // =====================================================
  // MODEL CONVERSION
  // =====================================================

  OrderModel _orderFromResponse(
    dynamic response,
  ) {
    final map = _asMap(
      _extractSingle(response),
    );

    if (map.isEmpty) {
      throw const FormatException(
        'The backend did not return valid order data.',
      );
    }

    return OrderModel.fromMap(map);
  }

  BookingModel _bookingFromResponse(
    dynamic response,
  ) {
    final map = _asMap(
      _extractSingle(response),
    );

    if (map.isEmpty) {
      throw const FormatException(
        'The backend did not return valid booking data.',
      );
    }

    final booking =
        BookingModel.fromMap(map);

    if (booking.id.trim().isEmpty) {
      throw const FormatException(
        'The backend did not return a valid booking ID.',
      );
    }

    return booking;
  }

  List<OrderModel> _ordersFromResponse(
    dynamic response,
  ) {
    return _extractList(response)
        .whereType<Map>()
        .map(
          (item) {
            return OrderModel.fromMap(
              _asMap(item),
            );
          },
        )
        .toList();
  }

  List<BookingModel>
      _bookingsFromResponse(
    dynamic response,
  ) {
    return _extractList(response)
        .whereType<Map>()
        .map(
          (item) {
            return BookingModel.fromMap(
              _asMap(item),
            );
          },
        )
        .where(
          (booking) =>
              booking.id
                  .trim()
                  .isNotEmpty,
        )
        .toList();
  }

  // =====================================================
  // CREATE ORDER
  // POST /api/orders
  // =====================================================

  Future<OrderModel> createOrder({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    final response =
        await ApiService.instance.post(
      '/orders',
      data: {
        'bookingId':
            normalizedBookingId,
        'amount': amount,
        'paymentMethod':
            paymentMethod
                .trim()
                .toUpperCase(),
        if (notes != null &&
            notes.trim().isNotEmpty)
          'notes': notes.trim(),
      },
    );

    return _orderFromResponse(
      response,
    );
  }

  // =====================================================
  // MY ORDERS
  // GET /api/orders/my
  // =====================================================

  Future<List<OrderModel>> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    await _ensureAuthenticated();

    final response =
        await ApiService.instance.get(
      '/orders/my',
      queryParameters: {
        'page': _normalizePage(page),
        'limit':
            _normalizeLimit(limit),
      },
    );

    return _ordersFromResponse(
      response,
    );
  }

  // =====================================================
  // GET ORDER BY ID
  // GET /api/orders/:id
  // =====================================================

  Future<OrderModel> getOrderById(
    String orderId,
  ) async {
    await _ensureAuthenticated();

    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    final response =
        await ApiService.instance.get(
      '/orders/$normalizedOrderId',
    );

    return _orderFromResponse(
      response,
    );
  }

  // =====================================================
  // ORDER HISTORY
  // GET /api/orders/history
  // =====================================================

  Future<List<OrderModel>>
      getOrderHistory() async {
    await _ensureAuthenticated();

    final response =
        await ApiService.instance.get(
      '/orders/history',
    );

    return _ordersFromResponse(
      response,
    );
  }

  // =====================================================
  // TRACK ORDER
  // GET /api/orders/:id/track
  // =====================================================

  Future<Map<String, dynamic>>
      trackOrder(
    String orderId,
  ) async {
    await _ensureAuthenticated();

    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    final response =
        await ApiService.instance.get(
      '/orders/$normalizedOrderId/track',
    );

    return _extractMap(response);
  }

  // =====================================================
  // UPDATE ORDER STATUS
  // PATCH /api/orders/:id/status
  // =====================================================

  Future<OrderModel> updateStatus({
    required String orderId,
    required String status,
  }) async {
    await _ensureAuthenticated();

    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    final normalizedStatus =
        _normalizeStatus(status);

    if (normalizedStatus.isEmpty) {
      throw ArgumentError(
        'Order status is required.',
      );
    }

    final response =
        await ApiService.instance.patch(
      '/orders/$normalizedOrderId/status',
      data: {
        'status': normalizedStatus,
      },
    );

    return _orderFromResponse(
      response,
    );
  }

  // =====================================================
  // CANCEL ORDER
  // PATCH /api/orders/:id/cancel
  // =====================================================

  Future<bool> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    await _ensureAuthenticated();

    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    await ApiService.instance.patch(
      '/orders/$normalizedOrderId/cancel',
      data: {
        if (reason != null &&
            reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
    );

    return true;
  }

  // =====================================================
  // CONFIRM ORDER
  // PATCH /api/orders/:id/confirm
  // =====================================================

  Future<bool> confirmOrder(
    String orderId,
  ) async {
    await _ensureAuthenticated();

    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    await ApiService.instance.patch(
      '/orders/$normalizedOrderId/confirm',
    );

    return true;
  }

  // =====================================================
  // PROCESS ORDER
  // PATCH /api/orders/:id/process
  // =====================================================

  Future<bool> processOrder(
    String orderId,
  ) async {
    await _ensureAuthenticated();

    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    await ApiService.instance.patch(
      '/orders/$normalizedOrderId/process',
    );

    return true;
  }

  // =====================================================
  // SHIP ORDER
  // PATCH /api/orders/:id/ship
  // =====================================================

  Future<bool> shipOrder(
    String orderId,
  ) async {
    await _ensureAuthenticated();

    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    await ApiService.instance.patch(
      '/orders/$normalizedOrderId/ship',
    );

    return true;
  }

  // =====================================================
  // DELIVER ORDER
  // PATCH /api/orders/:id/deliver
  // =====================================================

  Future<bool> deliverOrder(
    String orderId,
  ) async {
    await _ensureAuthenticated();

    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    await ApiService.instance.patch(
      '/orders/$normalizedOrderId/deliver',
    );

    return true;
  }

  // =====================================================
  // DELETE ORDER
  // DELETE /api/orders/:id
  // =====================================================

  Future<bool> deleteOrder(
    String orderId,
  ) async {
    await _ensureAuthenticated();

    final normalizedOrderId =
        _normalizeId(
      orderId,
      'Order ID',
    );

    await ApiService.instance.delete(
      '/orders/$normalizedOrderId',
    );

    return true;
  }

  // =====================================================
  // PROVIDER ORDERS
  // GET /api/orders/provider
  // =====================================================

  Future<List<OrderModel>>
      getProviderOrders({
    int page = 1,
    int limit = 20,
  }) async {
    await _ensureAuthenticated();

    final response =
        await ApiService.instance.get(
      '/orders/provider',
      queryParameters: {
        'page': _normalizePage(page),
        'limit':
            _normalizeLimit(limit),
      },
    );

    return _ordersFromResponse(
      response,
    );
  }

  // =====================================================
  // CREATE BOOKING
  // POST /api/bookings
  // =====================================================

  Future<BookingModel> createBooking({
    required String serviceId,
    DateTime? bookingDate,
    String? bookingTime,

    /*
     * Retained for compatibility with older call sites.
     * The backend calculates the actual amount using
     * the Service document.
     */
    double? amount,

    /*
     * Retained for compatibility but intentionally not
     * submitted to the backend. The backend obtains the
     * Provider ID from Service.provider.
     */
    String? providerId,

    String? address,
    double? latitude,
    double? longitude,
    String? notes,
    String? couponCode,
    String paymentMethod = 'COD',
    int hoursBooked = 1,
    Map<String, dynamic>? data,
  }) async {
    await _ensureAuthenticated();

    final normalizedServiceId =
        _normalizeId(
      serviceId,
      'Service ID',
    );

    if (bookingDate == null) {
      throw ArgumentError(
        'Booking date is required.',
      );
    }

    final normalizedAddress =
        address?.trim() ??
        data?['address']
            ?.toString()
            .trim() ??
        data?['location']
            ?.toString()
            .trim() ??
        '';

    if (normalizedAddress.isEmpty) {
      throw ArgumentError(
        'Booking address is required.',
      );
    }

    final normalizedTime =
        bookingTime?.trim() ?? '';

    final normalizedPaymentMethod =
        paymentMethod
            .trim()
            .toUpperCase();

    final resolvedHours =
        hoursBooked < 1
            ? 1
            : hoursBooked;

    /*
     * The payload intentionally excludes:
     *
     * providerId
     * amount
     *
     * The backend derives the Provider ID and price from
     * the selected Service document. This prevents incorrect
     * Provider assignment and client-side price manipulation.
     */
    final payload =
        <String, dynamic>{
      ...?data,

      'serviceId':
          normalizedServiceId,

      'bookingDate':
          bookingDate
              .toIso8601String(),

      // Backward compatibility for existing backend code.
      'date':
          bookingDate
              .toIso8601String(),

      if (normalizedTime.isNotEmpty)
        'bookingTime':
            normalizedTime,

      'address':
          normalizedAddress,

      'location':
          data?['location']
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
              true
          ? data!['location']
              .toString()
              .trim()
          : normalizedAddress,

      'hoursBooked':
          data?['hoursBooked'] ??
          resolvedHours,

      'paymentMethod':
          data?['paymentMethod']
                  ?.toString()
                  .trim()
                  .toUpperCase() ??
              normalizedPaymentMethod,

      if (latitude != null)
        'latitude': latitude,

      if (longitude != null)
        'longitude': longitude,

      if (notes != null &&
          notes.trim().isNotEmpty)
        'notes': notes.trim(),

      if (couponCode != null &&
          couponCode.trim().isNotEmpty)
        'couponCode':
            couponCode
                .trim()
                .toUpperCase(),
    };

    final response =
        await ApiService.instance.post(
      '/bookings',
      data: payload,
    );

    final booking =
        _bookingFromResponse(
      response,
    );

    /*
     * A successful confirmation screen must use this real
     * backend booking ID. Never generate a local ID in the UI.
     */
    if (booking.id.trim().isEmpty) {
      throw const FormatException(
        'The backend did not return a valid MongoDB booking ID.',
      );
    }

    return booking;
  }

  // =====================================================
  // MY BOOKINGS
  // GET /api/bookings/my-bookings
  // =====================================================

  Future<List<BookingModel>>
      getMyBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    await _ensureAuthenticated();

    final response =
        await ApiService.instance.get(
      '/bookings/my-bookings',
      queryParameters: {
        'page': _normalizePage(page),
        'limit':
            _normalizeLimit(limit),
        if (status != null &&
            status.trim().isNotEmpty)
          'status':
              _normalizeStatus(status),
      },
    );

    return _bookingsFromResponse(
      response,
    );
  }

  // =====================================================
  // GET BOOKING BY ID
  // GET /api/bookings/:id
  // =====================================================

  Future<BookingModel> getBookingById(
    String bookingId,
  ) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    final response =
        await ApiService.instance.get(
      '/bookings/$normalizedBookingId',
    );

    return _bookingFromResponse(
      response,
    );
  }

  // =====================================================
  // PROVIDER BOOKINGS
  // GET /api/bookings/provider
  //
  // This method is maintained for shared compatibility.
  // The Provider application normally calls:
  // GET /api/provider/bookings
  // =====================================================

  Future<List<BookingModel>>
      getProviderBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    await _ensureAuthenticated();

    final response =
        await ApiService.instance.get(
      '/bookings/provider',
      queryParameters: {
        'page': _normalizePage(page),
        'limit':
            _normalizeLimit(limit),
        if (status != null &&
            status.trim().isNotEmpty)
          'status':
              _normalizeStatus(status),
      },
    );

    return _bookingsFromResponse(
      response,
    );
  }

  // =====================================================
  // BOOKING HISTORY
  // GET /api/bookings/history
  // =====================================================

  Future<List<BookingModel>>
      getBookingHistory() async {
    await _ensureAuthenticated();

    final response =
        await ApiService.instance.get(
      '/bookings/history',
      queryParameters: const {
        'page': 1,
        'limit': 100,
      },
    );

    return _bookingsFromResponse(
      response,
    );
  }

  // =====================================================
  // UPDATE BOOKING STATUS
  // PATCH /api/bookings/:id/status
  // =====================================================

  Future<BookingModel>
      updateBookingStatus({
    required String bookingId,
    required String status,
    String? reason,
    String? note,
  }) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    final normalizedStatus =
        _normalizeStatus(status);

    if (normalizedStatus.isEmpty) {
      throw ArgumentError(
        'Booking status is required.',
      );
    }

    final response =
        await ApiService.instance.patch(
      '/bookings/$normalizedBookingId/status',
      data: {
        'status':
            normalizedStatus,
        if (reason != null &&
            reason.trim().isNotEmpty)
          'reason': reason.trim(),
        if (note != null &&
            note.trim().isNotEmpty)
          'note': note.trim(),
      },
    );

    return _bookingFromResponse(
      response,
    );
  }

  // =====================================================
  // ACCEPT BOOKING
  // PATCH /api/bookings/:id/accept
  // =====================================================

  Future<bool> acceptBooking(
    String bookingId,
  ) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    await ApiService.instance.patch(
      '/bookings/$normalizedBookingId/accept',
    );

    return true;
  }

  // =====================================================
  // CONFIRM BOOKING
  // PATCH /api/bookings/:id/confirm
  // =====================================================

  Future<bool> confirmBooking(
    String bookingId,
  ) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    await ApiService.instance.patch(
      '/bookings/$normalizedBookingId/confirm',
    );

    return true;
  }

  // =====================================================
  // START BOOKING
  // PATCH /api/bookings/:id/start
  // =====================================================

  Future<bool> startBooking(
    String bookingId,
  ) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    await ApiService.instance.patch(
      '/bookings/$normalizedBookingId/start',
    );

    return true;
  }

  // =====================================================
  // COMPLETE BOOKING
  // PATCH /api/bookings/:id/complete
  // =====================================================

  Future<bool> completeBooking(
    String bookingId,
  ) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    await ApiService.instance.patch(
      '/bookings/$normalizedBookingId/complete',
    );

    return true;
  }

  // =====================================================
  // REJECT BOOKING
  // PATCH /api/bookings/:id/reject
  // =====================================================

  Future<bool> rejectBooking({
    required String bookingId,
    String? reason,
  }) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    await ApiService.instance.patch(
      '/bookings/$normalizedBookingId/reject',
      data: {
        if (reason != null &&
            reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
    );

    return true;
  }

  // =====================================================
  // CANCEL BOOKING
  // PATCH /api/bookings/:id/cancel
  // =====================================================

  Future<bool> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    await ApiService.instance.patch(
      '/bookings/$normalizedBookingId/cancel',
      data: {
        if (reason != null &&
            reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
    );

    return true;
  }

  // =====================================================
  // RESCHEDULE BOOKING
  //
  // This requires a corresponding backend route:
  // PATCH /api/bookings/:id/reschedule
  // =====================================================

  Future<bool> rescheduleBooking({
    required String bookingId,
    DateTime? bookingDate,
    String? bookingTime,
    String? reason,
  }) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    if (bookingDate == null &&
        (bookingTime == null ||
            bookingTime
                .trim()
                .isEmpty)) {
      throw ArgumentError(
        'A new booking date or time is required.',
      );
    }

    await ApiService.instance.patch(
      '/bookings/$normalizedBookingId/reschedule',
      data: {
        if (bookingDate != null)
          'bookingDate':
              bookingDate
                  .toIso8601String(),
        if (bookingDate != null)
          'date':
              bookingDate
                  .toIso8601String(),
        if (bookingTime != null &&
            bookingTime
                .trim()
                .isNotEmpty)
          'bookingTime':
              bookingTime.trim(),
        if (reason != null &&
            reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
    );

    return true;
  }

  // =====================================================
  // TRACK BOOKING
  //
  // This requires a corresponding backend route:
  // GET /api/bookings/:id/track
  // =====================================================

  Future<Map<String, dynamic>>
      trackBooking({
    required String bookingId,
  }) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    final response =
        await ApiService.instance.get(
      '/bookings/$normalizedBookingId/track',
    );

    return _extractMap(response);
  }

  // =====================================================
  // DELETE BOOKING
  //
  // This requires a corresponding backend route:
  // DELETE /api/bookings/:id
  // =====================================================

  Future<bool> deleteBooking(
    String bookingId,
  ) async {
    await _ensureAuthenticated();

    final normalizedBookingId =
        _normalizeId(
      bookingId,
      'Booking ID',
    );

    await ApiService.instance.delete(
      '/bookings/$normalizedBookingId',
    );

    return true;
  }
}

// =====================================================
// ORDER SERVICE BACKWARD COMPATIBILITY
// =====================================================
//
// Existing code using:
//
// OrderService.instance
//
// continues to work.
// =====================================================

class OrderService {
  OrderService._();

  static final OrderService instance =
      OrderService._();

  final BookingService _service =
      BookingService.instance;

  Future<OrderModel> createOrder({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) {
    return _service.createOrder(
      bookingId: bookingId,
      amount: amount,
      paymentMethod:
          paymentMethod,
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

  Future<List<OrderModel>>
      getOrderHistory() {
    return _service
        .getOrderHistory();
  }

  Future<Map<String, dynamic>>
      trackOrder(
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

  Future<List<OrderModel>>
      getProviderOrders({
    int page = 1,
    int limit = 20,
  }) {
    return _service
        .getProviderOrders(
      page: page,
      limit: limit,
    );
  }
}