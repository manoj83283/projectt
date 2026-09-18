import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/booking_model.dart';

class BookingService {
  BookingService._();

  static final BookingService _instance =
      BookingService._();

  static BookingService get instance =>
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
          map['bookings'] ??
          map['orders'] ??
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

  Map<String, dynamic> _extractSingle(
    dynamic response,
  ) {
    if (response is! Map) {
      return <String, dynamic>{};
    }

    final map = _asMap(response);

    final payload =
        map['booking'] ??
        map['order'] ??
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

  List<BookingModel> _bookingsFromResponse(
    dynamic response,
  ) {
    final bookings =
        <BookingModel>[];

    for (final item in _extractList(response)) {
      if (item is! Map) {
        continue;
      }

      try {
        bookings.add(
          BookingModel.fromJson(
            _asMap(item),
          ),
        );
      } catch (error, stackTrace) {
        log(
          'Booking parse error',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return bookings;
  }

  BookingModel _bookingFromResponse(
    dynamic response,
  ) {
    final bookingData =
        _extractSingle(response);

    if (bookingData.isEmpty) {
      throw const FormatException(
        'The backend did not return valid booking data.',
      );
    }

    return BookingModel.fromJson(
      bookingData,
    );
  }

  Future<BookingModel> createBooking({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response =
          await _apiService.post(
        '/bookings',
        body: data,
      );

      return _bookingFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Create Booking Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<List<BookingModel>> getBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final normalizedStatus =
          status == null
              ? ''
              : _normalizeStatus(status);

      final response =
          await _apiService.get(
        '/provider/bookings',
        queryParameters: {
          'page': _normalizePage(page),
          'limit': _normalizeLimit(limit),
          if (normalizedStatus.isNotEmpty)
            'status': normalizedStatus,
        },
      );

      final bookings =
          _bookingsFromResponse(
        response,
      );

      log(
        'Provider bookings loaded: '
        '${bookings.length}',
      );

      return bookings;
    } catch (error, stackTrace) {
      log(
        'Get Bookings Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<List<BookingModel>>
      getProviderBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    return getBookings(
      page: page,
      limit: limit,
      status: status,
    );
  }

  Future<BookingModel> getBookingById(
    String bookingId,
  ) async {
    try {
      final normalizedBookingId =
          _normalizeId(
        bookingId,
        'Booking ID',
      );

      final response =
          await _apiService.get(
        '/bookings/$normalizedBookingId',
      );

      return _bookingFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Get Booking By ID Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<List<BookingModel>>
      getTodayBookings() async {
    try {
      final response =
          await _apiService.get(
        '/provider/bookings/today',
      );

      return _bookingsFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Today Bookings Error',
        error: error,
        stackTrace: stackTrace,
      );

      return <BookingModel>[];
    }
  }

  Future<List<BookingModel>>
      getProviderTodayBookings() {
    return getTodayBookings();
  }

  Future<List<BookingModel>>
      getUpcomingBookings() async {
    try {
      final response =
          await _apiService.get(
        '/provider/bookings/upcoming',
      );

      return _bookingsFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Upcoming Bookings Error',
        error: error,
        stackTrace: stackTrace,
      );

      return <BookingModel>[];
    }
  }

  Future<List<BookingModel>>
      getProviderUpcomingBookings() {
    return getUpcomingBookings();
  }

  Future<BookingModel>
      updateBookingStatus({
    required String bookingId,
    required String status,
    String? reason,
    String? note,
  }) async {
    try {
      final normalizedBookingId =
          _normalizeId(
        bookingId,
        'Booking ID',
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
          'Invalid booking status: '
          '$normalizedStatus',
        );
      }

      log(
        'Updating booking '
        '$normalizedBookingId '
        'to $normalizedStatus',
      );

      final response =
          await _apiService.patch(
        '/bookings/'
        '$normalizedBookingId/status',
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

      return _bookingFromResponse(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Update Booking Status Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<bool> confirmBooking(
    String bookingId,
  ) async {
    try {
      await updateBookingStatus(
        bookingId: bookingId,
        status: 'accepted',
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Confirm Booking Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> acceptBooking(
    String bookingId,
  ) {
    return confirmBooking(
      bookingId,
    );
  }

  Future<bool> startBooking(
    String bookingId,
  ) async {
    try {
      await updateBookingStatus(
        bookingId: bookingId,
        status: 'in_progress',
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Start Booking Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> completeBooking(
    String bookingId,
  ) async {
    try {
      await updateBookingStatus(
        bookingId: bookingId,
        status: 'completed',
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Complete Booking Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> rejectBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      await updateBookingStatus(
        bookingId: bookingId,
        status: 'rejected',
        reason: reason,
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Reject Booking Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      await updateBookingStatus(
        bookingId: bookingId,
        status: 'cancelled',
        reason: reason,
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Cancel Booking Error',
        error: error,
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  Future<bool> rescheduleBooking({
    required String bookingId,
    required DateTime date,
    required String time,
  }) async {
    log(
      'Provider booking reschedule is not '
      'supported by the current backend. '
      'Booking ID: $bookingId',
    );

    return false;
  }

  Future<List<BookingModel>>
      getBookingsByStatus(
    String status,
  ) async {
    try {
      final normalizedStatus =
          _normalizeStatus(status);

      if (normalizedStatus.isEmpty) {
        return getBookings();
      }

      return getBookings(
        status: normalizedStatus,
      );
    } catch (error, stackTrace) {
      log(
        'Get Bookings By Status Error',
        error: error,
        stackTrace: stackTrace,
      );

      return <BookingModel>[];
    }
  }

  Future<List<BookingModel>>
      searchBookings(
    String keyword,
  ) async {
    try {
      final normalizedKeyword =
          keyword.trim().toLowerCase();

      final bookings =
          await getBookings(
        limit: 100,
      );

      if (normalizedKeyword.isEmpty) {
        return bookings;
      }

      return bookings.where(
        (booking) {
          return booking
              .toString()
              .toLowerCase()
              .contains(
                normalizedKeyword,
              );
        },
      ).toList();
    } catch (error, stackTrace) {
      log(
        'Search Booking Error',
        error: error,
        stackTrace: stackTrace,
      );

      return <BookingModel>[];
    }
  }

  Future<Map<String, dynamic>>
      getBookingAnalytics() async {
    try {
      final response =
          await _apiService.get(
        '/provider/bookings/analytics',
      );

      return _extractMap(
        response,
      );
    } catch (error, stackTrace) {
      log(
        'Booking Analytics Error',
        error: error,
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  Future<Map<String, dynamic>>
      getProviderBookingAnalytics() {
    return getBookingAnalytics();
  }

  Future<int> getBookingCount() async {
    try {
      final analytics =
          await getBookingAnalytics();

      return _toInt(
        analytics['totalBookings'] ??
            analytics['totalOrders'],
      );
    } catch (error, stackTrace) {
      log(
        'Booking Count Error',
        error: error,
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  Future<int> getPendingCount() async {
    try {
      final analytics =
          await getBookingAnalytics();

      return _toInt(
        analytics['pendingBookings'] ??
            analytics['pendingOrders'],
      );
    } catch (error, stackTrace) {
      log(
        'Pending Booking Count Error',
        error: error,
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  Future<int> getCompletedCount() async {
    try {
      final analytics =
          await getBookingAnalytics();

      return _toInt(
        analytics['completedBookings'] ??
            analytics['completedOrders'],
      );
    } catch (error, stackTrace) {
      log(
        'Completed Booking Count Error',
        error: error,
        stackTrace: stackTrace,
      );

      return 0;
    }
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
}