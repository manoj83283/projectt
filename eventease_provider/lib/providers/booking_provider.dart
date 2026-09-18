import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider({BookingRepository? repository})
    : _repository = repository ?? BookingRepository.instance;

  final BookingRepository _repository;

  // =====================================================
  // STATE
  // =====================================================

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _disposed = false;

  String? _errorMessage;

  List<BookingModel> _bookings = <BookingModel>[];

  List<BookingModel> _todayBookings = <BookingModel>[];

  List<BookingModel> _upcomingBookings = <BookingModel>[];

  BookingModel? _selectedBooking;

  Map<String, dynamic> _analytics = <String, dynamic>{};

  DateTime? _lastRefreshedAt;

  // =====================================================
  // BASIC GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  bool get isRefreshing => _isRefreshing;

  bool get hasError =>
      _errorMessage != null && _errorMessage!.trim().isNotEmpty;

  String? get errorMessage => _errorMessage;

  List<BookingModel> get bookings => List<BookingModel>.unmodifiable(_bookings);

  List<BookingModel> get todayBookings =>
      List<BookingModel>.unmodifiable(_todayBookings);

  List<BookingModel> get upcomingBookings =>
      List<BookingModel>.unmodifiable(_upcomingBookings);

  BookingModel? get selectedBooking => _selectedBooking;

  Map<String, dynamic> get analytics =>
      Map<String, dynamic>.unmodifiable(_analytics);

  DateTime? get lastRefreshedAt => _lastRefreshedAt;

  bool get hasBookings => _bookings.isNotEmpty;

  // =====================================================
  // STATUS COUNTS
  // =====================================================

  int get totalBookingCount => _bookings.length;

  int get pendingCount => _countByStatus('pending');

  int get acceptedCount => _countByStatus('accepted');

  int get inProgressCount => _countByStatus('in_progress');

  int get completedCount => _countByStatus('completed');

  int get cancelledCount => _countByStatus('cancelled');

  int get rejectedCount => _countByStatus('rejected');

  // =====================================================
  // STATUS LISTS
  // =====================================================

  List<BookingModel> get pendingBookings => _filterByStatus('pending');

  List<BookingModel> get acceptedBookings => _filterByStatus('accepted');

  List<BookingModel> get inProgressBookings => _filterByStatus('in_progress');

  List<BookingModel> get completedBookings => _filterByStatus('completed');

  List<BookingModel> get cancelledBookings => _filterByStatus('cancelled');

  List<BookingModel> get rejectedBookings => _filterByStatus('rejected');

  // =====================================================
  // ANALYTICS GETTERS
  // =====================================================

  int get analyticsTotalBookings =>
      _analyticsInt(primaryKey: 'totalBookings', fallbackKey: 'totalOrders');

  int get analyticsTodayBookings =>
      _analyticsInt(primaryKey: 'todayBookings', fallbackKey: 'todayOrders');

  int get analyticsPendingBookings => _analyticsInt(
    primaryKey: 'pendingBookings',
    fallbackKey: 'pendingOrders',
  );

  int get analyticsAcceptedBookings => _analyticsInt(
    primaryKey: 'acceptedBookings',
    fallbackKey: 'acceptedOrders',
  );

  int get analyticsInProgressBookings => _analyticsInt(
    primaryKey: 'inProgressBookings',
    fallbackKey: 'inProgressOrders',
  );

  int get analyticsCompletedBookings => _analyticsInt(
    primaryKey: 'completedBookings',
    fallbackKey: 'completedOrders',
  );

  int get analyticsCancelledBookings => _analyticsInt(
    primaryKey: 'cancelledBookings',
    fallbackKey: 'cancelledOrders',
  );

  int get analyticsRejectedBookings => _analyticsInt(
    primaryKey: 'rejectedBookings',
    fallbackKey: 'rejectedOrders',
  );

  double get analyticsTotalRevenue => _analyticsDouble(
    primaryKey: 'totalRevenue',
    fallbackKey: 'totalEarnings',
  );

  // =====================================================
  // STATE HELPERS
  // =====================================================

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _notify();
  }

  void _setRefreshing(bool value) {
    _isRefreshing = value;
    _notify();
  }

  void _clearErrorSilently() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    _notify();
  }

  void _setError(Object error, {required String fallback}) {
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

    _errorMessage = message.isEmpty ? fallback : message;

    debugPrint(
      'BOOKING PROVIDER ERROR: '
      '$_errorMessage',
    );

    _notify();
  }

  // =====================================================
  // NORMALIZATION HELPERS
  // =====================================================

  String _normalizeStatus(String? value) {
    final normalized = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (normalized) {
      case 'confirm':
      case 'confirmed':
        return 'accepted';

      case 'inprogress':
      case 'processing':
        return 'in_progress';

      case 'canceled':
        return 'cancelled';

      default:
        return normalized;
    }
  }

  String _normalizeId(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError('$fieldName is required.');
    }

    return normalized;
  }

  int _countByStatus(String status) {
    final normalizedStatus = _normalizeStatus(status);

    return _bookings.where((booking) {
      return _normalizeStatus(booking.status) == normalizedStatus;
    }).length;
  }

  List<BookingModel> _filterByStatus(String status) {
    final normalizedStatus = _normalizeStatus(status);

    return List<BookingModel>.unmodifiable(
      _bookings.where((booking) {
        return _normalizeStatus(booking.status) == normalizedStatus;
      }),
    );
  }

  int _analyticsInt({required String primaryKey, required String fallbackKey}) {
    final value = _analytics[primaryKey] ?? _analytics[fallbackKey];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _analyticsDouble({
    required String primaryKey,
    required String fallbackKey,
  }) {
    final value = _analytics[primaryKey] ?? _analytics[fallbackKey];

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // =====================================================
  // CREATE BOOKING
  // =====================================================

  Future<bool> createBooking({required Map<String, dynamic> data}) async {
    _setLoading(true);
    _clearErrorSilently();

    try {
      final booking = await _repository.createBooking(data: data);

      _bookings.insert(0, booking);

      _selectedBooking = booking;

      _notify();

      await refreshData(showLoading: false);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to create booking.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET ALL BOOKINGS
  // =====================================================

  Future<void> getBookings({bool showLoading = true}) async {
    if (showLoading) {
      _setLoading(true);
    }

    _clearErrorSilently();

    try {
      final result = await _repository.getBookings();

      _bookings = List<BookingModel>.from(result);

      _lastRefreshedAt = DateTime.now();

      debugPrint(
        'PROVIDER BOOKINGS LOADED: '
        '${_bookings.length}',
      );

      _notify();
    } catch (error) {
      _setError(error, fallback: 'Unable to load Provider bookings.');
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }

  // =====================================================
  // GET BOOKING BY ID
  // =====================================================

  Future<BookingModel?> getBookingById(
    String bookingId, {
    bool showLoading = true,
  }) async {
    String normalizedBookingId;

    try {
      normalizedBookingId = _normalizeId(bookingId, 'Booking ID');
    } catch (error) {
      _setError(error, fallback: 'Booking ID is required.');

      return null;
    }

    if (showLoading) {
      _setLoading(true);
    }

    _clearErrorSilently();

    try {
      final booking = await _repository.getBookingById(normalizedBookingId);

      _selectedBooking = booking;

      _notify();

      return booking;
    } catch (error) {
      _setError(error, fallback: 'Unable to load booking details.');

      return null;
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }

  void selectBooking(BookingModel? booking) {
    _selectedBooking = booking;
    _notify();
  }

  // =====================================================
  // TODAY BOOKINGS
  // =====================================================

  Future<void> getTodayBookings({bool showLoading = false}) async {
    if (showLoading) {
      _setLoading(true);
    }

    try {
      final result = await _repository.getTodayBookings();

      _todayBookings = List<BookingModel>.from(result);

      _notify();
    } catch (error) {
      _setError(error, fallback: 'Unable to load today\'s bookings.');
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }

  // =====================================================
  // UPCOMING BOOKINGS
  // =====================================================

  Future<void> getUpcomingBookings({bool showLoading = false}) async {
    if (showLoading) {
      _setLoading(true);
    }

    try {
      final result = await _repository.getUpcomingBookings();

      _upcomingBookings = List<BookingModel>.from(result);

      _notify();
    } catch (error) {
      _setError(error, fallback: 'Unable to load upcoming bookings.');
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }

  // =====================================================
  // REFRESH AFTER BOOKING ACTION
  // =====================================================

  Future<void> _refreshAfterAction(String bookingId) async {
    await refreshData(showLoading: false);

    await getBookingById(bookingId, showLoading: false);
  }

  // =====================================================
  // CONFIRM / ACCEPT BOOKING
  //
  // pending -> accepted
  // =====================================================

  Future<bool> confirmBooking(String bookingId) async {
    String normalizedBookingId;

    try {
      normalizedBookingId = _normalizeId(bookingId, 'Booking ID');
    } catch (error) {
      _setError(error, fallback: 'Booking ID is required.');

      return false;
    }

    _setLoading(true);
    _clearErrorSilently();

    try {
      final success = await _repository.confirmBooking(normalizedBookingId);

      if (!success) {
        throw Exception('The booking could not be accepted.');
      }

      await _refreshAfterAction(normalizedBookingId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to accept booking.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> acceptBooking(String bookingId) {
    return confirmBooking(bookingId);
  }

  // =====================================================
  // START BOOKING
  //
  // accepted -> in_progress
  // =====================================================

  Future<bool> startBooking(String bookingId) async {
    String normalizedBookingId;

    try {
      normalizedBookingId = _normalizeId(bookingId, 'Booking ID');
    } catch (error) {
      _setError(error, fallback: 'Booking ID is required.');

      return false;
    }

    _setLoading(true);
    _clearErrorSilently();

    try {
      final success = await _repository.startBooking(normalizedBookingId);

      if (!success) {
        throw Exception('The booking could not be started.');
      }

      await _refreshAfterAction(normalizedBookingId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to start booking.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // COMPLETE BOOKING
  //
  // in_progress -> completed
  // =====================================================

  Future<bool> completeBooking(String bookingId) async {
    String normalizedBookingId;

    try {
      normalizedBookingId = _normalizeId(bookingId, 'Booking ID');
    } catch (error) {
      _setError(error, fallback: 'Booking ID is required.');

      return false;
    }

    _setLoading(true);
    _clearErrorSilently();

    try {
      final success = await _repository.completeBooking(normalizedBookingId);

      if (!success) {
        throw Exception('The booking could not be completed.');
      }

      await _refreshAfterAction(normalizedBookingId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to complete booking.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CANCEL BOOKING
  //
  // accepted -> cancelled
  // in_progress -> cancelled
  // =====================================================

  Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    String normalizedBookingId;

    try {
      normalizedBookingId = _normalizeId(bookingId, 'Booking ID');
    } catch (error) {
      _setError(error, fallback: 'Booking ID is required.');

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

    _setLoading(true);
    _clearErrorSilently();

    try {
      final success = await _repository.cancelBooking(
        bookingId: normalizedBookingId,
        reason: normalizedReason,
      );

      if (!success) {
        throw Exception('The booking could not be cancelled.');
      }

      await _refreshAfterAction(normalizedBookingId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to cancel booking.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // RESCHEDULE BOOKING
  // =====================================================

  Future<bool> rescheduleBooking({
    required String bookingId,
    required DateTime date,
    required String time,
  }) async {
    String normalizedBookingId;

    try {
      normalizedBookingId = _normalizeId(bookingId, 'Booking ID');
    } catch (error) {
      _setError(error, fallback: 'Booking ID is required.');

      return false;
    }

    final normalizedTime = time.trim();

    if (normalizedTime.isEmpty) {
      _setError(
        ArgumentError('Booking time is required.'),
        fallback: 'Booking time is required.',
      );

      return false;
    }

    _setLoading(true);
    _clearErrorSilently();

    try {
      final success = await _repository.rescheduleBooking(
        bookingId: normalizedBookingId,
        date: date,
        time: normalizedTime,
      );

      if (!success) {
        throw Exception('The booking could not be rescheduled.');
      }

      await _refreshAfterAction(normalizedBookingId);

      return true;
    } catch (error) {
      _setError(error, fallback: 'Unable to reschedule booking.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // BOOKINGS BY STATUS
  // =====================================================

  Future<List<BookingModel>> getBookingsByStatus(String status) async {
    final normalizedStatus = _normalizeStatus(status);

    if (normalizedStatus.isEmpty || normalizedStatus == 'all') {
      return bookings;
    }

    try {
      final result = await _repository.getBookingsByStatus(normalizedStatus);

      return List<BookingModel>.unmodifiable(result);
    } catch (error) {
      debugPrint(
        'REMOTE BOOKING FILTER FAILED: '
        '$error',
      );

      return _filterByStatus(normalizedStatus);
    }
  }

  // =====================================================
  // SEARCH BOOKINGS
  // =====================================================

  Future<List<BookingModel>> searchBookings(String keyword) async {
    final normalizedKeyword = keyword.trim();

    if (normalizedKeyword.isEmpty) {
      return bookings;
    }

    try {
      final result = await _repository.searchBookings(normalizedKeyword);

      return List<BookingModel>.unmodifiable(result);
    } catch (error) {
      debugPrint(
        'REMOTE BOOKING SEARCH FAILED: '
        '$error',
      );

      final lowerKeyword = normalizedKeyword.toLowerCase();

      return _bookings.where((booking) {
        return booking.toString().toLowerCase().contains(lowerKeyword);
      }).toList();
    }
  }

  // =====================================================
  // BOOKING ANALYTICS
  // =====================================================

  Future<void> getBookingAnalytics({bool showLoading = false}) async {
    if (showLoading) {
      _setLoading(true);
    }

    try {
      final result = await _repository.getBookingAnalytics();

      _analytics = Map<String, dynamic>.from(result);

      _notify();
    } catch (error) {
      _setError(error, fallback: 'Unable to load booking analytics.');
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }

  // =====================================================
  // COUNT METHODS
  // =====================================================

  Future<int> getBookingCount() async {
    try {
      return await _repository.getBookingCount();
    } catch (error) {
      debugPrint('BOOKING COUNT ERROR: $error');

      return totalBookingCount;
    }
  }

  Future<int> getPendingCount() async {
    try {
      return await _repository.getPendingCount();
    } catch (error) {
      debugPrint('PENDING COUNT ERROR: $error');

      return pendingCount;
    }
  }

  Future<int> getCompletedCount() async {
    try {
      return await _repository.getCompletedCount();
    } catch (error) {
      debugPrint('COMPLETED COUNT ERROR: $error');

      return completedCount;
    }
  }

  Future<int> getAcceptedCount() async {
    if (_analytics.isEmpty) {
      await getBookingAnalytics();
    }

    if (_analytics.containsKey('acceptedBookings') ||
        _analytics.containsKey('acceptedOrders')) {
      return analyticsAcceptedBookings;
    }

    return acceptedCount;
  }

  Future<int> getInProgressCount() async {
    if (_analytics.isEmpty) {
      await getBookingAnalytics();
    }

    if (_analytics.containsKey('inProgressBookings') ||
        _analytics.containsKey('inProgressOrders')) {
      return analyticsInProgressBookings;
    }

    return inProgressCount;
  }

  Future<int> getCancelledCount() async {
    if (_analytics.isEmpty) {
      await getBookingAnalytics();
    }

    if (_analytics.containsKey('cancelledBookings') ||
        _analytics.containsKey('cancelledOrders')) {
      return analyticsCancelledBookings;
    }

    return cancelledCount;
  }

  Future<int> getRejectedCount() async {
    if (_analytics.isEmpty) {
      await getBookingAnalytics();
    }

    if (_analytics.containsKey('rejectedBookings') ||
        _analytics.containsKey('rejectedOrders')) {
      return analyticsRejectedBookings;
    }

    return rejectedCount;
  }

  // =====================================================
  // REFRESH ALL DATA
  // =====================================================

  Future<void> refreshData({bool showLoading = true}) async {
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;

    if (showLoading) {
      _setLoading(true);
    } else {
      _setRefreshing(true);
    }

    _clearErrorSilently();

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _repository.getBookings(),
        _repository.getTodayBookings(),
        _repository.getUpcomingBookings(),
        _repository.getBookingAnalytics(),
      ]);

      _bookings = List<BookingModel>.from(results[0] as List);

      _todayBookings = List<BookingModel>.from(results[1] as List);

      _upcomingBookings = List<BookingModel>.from(results[2] as List);

      _analytics = Map<String, dynamic>.from(results[3] as Map);

      _lastRefreshedAt = DateTime.now();

      debugPrint('PROVIDER BOOKING DATA REFRESHED');

      debugPrint('TOTAL: $totalBookingCount');

      debugPrint('PENDING: $pendingCount');

      debugPrint('ACCEPTED: $acceptedCount');

      debugPrint('IN PROGRESS: $inProgressCount');

      debugPrint('COMPLETED: $completedCount');

      debugPrint('CANCELLED: $cancelledCount');

      debugPrint('REJECTED: $rejectedCount');

      _notify();
    } catch (error) {
      _setError(error, fallback: 'Unable to refresh Provider booking data.');

      try {
        final fallbackBookings = await _repository.getBookings();

        _bookings = List<BookingModel>.from(fallbackBookings);

        _lastRefreshedAt = DateTime.now();

        _notify();
      } catch (fallbackError) {
        debugPrint(
          'BOOKING REFRESH FALLBACK ERROR: '
          '$fallbackError',
        );
      }
    } finally {
      _isRefreshing = false;

      if (showLoading) {
        _setLoading(false);
      } else {
        _setRefreshing(false);
      }
    }
  }

  // =====================================================
  // REAL-TIME EVENT
  // =====================================================

  Future<void> handleBookingEvent(dynamic event) async {
    debugPrint('BOOKING EVENT RECEIVED: $event');

    await refreshData(showLoading: false);
  }

  // =====================================================
  // RESET
  // =====================================================

  void reset() {
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;

    _bookings = <BookingModel>[];

    _todayBookings = <BookingModel>[];

    _upcomingBookings = <BookingModel>[];

    _selectedBooking = null;

    _analytics = <String, dynamic>{};

    _lastRefreshedAt = null;

    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
