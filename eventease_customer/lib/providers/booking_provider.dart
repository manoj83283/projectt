import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider();

  final BookingRepository _repository =
      BookingRepository.instance;

  List<BookingModel> _myBookings =
      <BookingModel>[];

  List<BookingModel> _providerBookings =
      <BookingModel>[];

  BookingModel? _selectedBooking;

  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isDisposed = false;

  String? _error;

  DateTime? _lastCustomerRefresh;
  DateTime? _lastProviderRefresh;

  // =====================================================
  // GETTERS
  // =====================================================

  List<BookingModel> get myBookings {
    return List<BookingModel>.unmodifiable(
      _myBookings,
    );
  }

  List<BookingModel> get providerBookings {
    return List<BookingModel>.unmodifiable(
      _providerBookings,
    );
  }

  BookingModel? get selectedBooking {
    return _selectedBooking;
  }

  bool get isLoading {
    return _isLoading;
  }

  bool get isRefreshing {
    return _isRefreshing;
  }

  String? get error {
    return _error;
  }

  bool get hasError {
    return _error != null &&
        _error!.trim().isNotEmpty;
  }

  bool get hasMyBookings {
    return _myBookings.isNotEmpty;
  }

  bool get hasProviderBookings {
    return _providerBookings.isNotEmpty;
  }

  List<BookingModel> get activeBookings {
    return _myBookings
        .where(
          (booking) => booking.isActive,
        )
        .toList();
  }

  List<BookingModel> get completedBookings {
    return _myBookings
        .where(
          (booking) => booking.isCompleted,
        )
        .toList();
  }

  List<BookingModel> get pendingBookings {
    return _myBookings
        .where(
          (booking) => booking.isPending,
        )
        .toList();
  }

  List<BookingModel> get acceptedBookings {
    return _myBookings
        .where(
          (booking) => booking.isAccepted,
        )
        .toList();
  }

  List<BookingModel> get rejectedBookings {
    return _myBookings
        .where(
          (booking) => booking.isRejected,
        )
        .toList();
  }

  List<BookingModel> get cancelledBookings {
    return _myBookings
        .where(
          (booking) => booking.isCancelled,
        )
        .toList();
  }

  List<BookingModel> get recentBookings {
    final bookings =
        List<BookingModel>.from(
      _myBookings,
    );

    bookings.sort(
      _compareBookingsByActivity,
    );

    return bookings;
  }

  // =====================================================
  // NOTIFICATION HELPERS
  // =====================================================

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _setLoading(
    bool value, {
    bool notify = true,
  }) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    if (notify) {
      _safeNotifyListeners();
    }
  }

  void _setRefreshing(
    bool value, {
    bool notify = true,
  }) {
    if (_isRefreshing == value) {
      return;
    }

    _isRefreshing = value;

    if (notify) {
      _safeNotifyListeners();
    }
  }

  void _setError(
    String? value, {
    bool notify = true,
  }) {
    final normalizedError =
        value?.trim();

    _error =
        normalizedError == null ||
                normalizedError.isEmpty
            ? null
            : normalizedError;

    if (notify) {
      _safeNotifyListeners();
    }
  }

  String _errorMessage(
    Object error,
  ) {
    final message =
        error.toString().trim();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // =====================================================
  // MAP HELPERS
  // =====================================================

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, dynamic item) {
          return MapEntry(
            key.toString(),
            item,
          );
        },
      );
    }

    return <String, dynamic>{};
  }

  String _extractBookingId(
    dynamic event,
  ) {
    if (event == null) {
      return '';
    }

    if (event is String) {
      return event.trim();
    }

    if (event is BookingModel) {
      return event.id.trim();
    }

    if (event is! Map) {
      return '';
    }

    final eventMap =
        _asMap(event);

    final dynamic nestedPayload =
        eventMap['booking'] ??
        eventMap['data'] ??
        eventMap['payload'];

    if (nestedPayload is BookingModel) {
      return nestedPayload.id.trim();
    }

    if (nestedPayload is Map) {
      final nestedMap =
          _asMap(nestedPayload);

      return (
        nestedMap['_id'] ??
        nestedMap['id'] ??
        nestedMap['bookingId'] ??
        ''
      ).toString().trim();
    }

    return (
      eventMap['_id'] ??
      eventMap['id'] ??
      eventMap['bookingId'] ??
      ''
    ).toString().trim();
  }

  BookingModel? _bookingFromEvent(
    dynamic event,
  ) {
    if (event is BookingModel) {
      return event;
    }

    if (event is! Map) {
      return null;
    }

    final eventMap =
        _asMap(event);

    final dynamic payload =
        eventMap['booking'] ??
        eventMap['data'] ??
        eventMap['payload'] ??
        eventMap;

    if (payload is BookingModel) {
      return payload;
    }

    if (payload is! Map) {
      return null;
    }

    final payloadMap =
        _asMap(payload);

    final hasBookingData =
        payloadMap.containsKey('_id') ||
        payloadMap.containsKey('id') ||
        payloadMap.containsKey(
          'bookingId',
        );

    if (!hasBookingData) {
      return null;
    }

    return BookingModel.fromMap(
      payloadMap,
    );
  }

  // =====================================================
  // SORTING
  // =====================================================

  int _compareBookingsByActivity(
    BookingModel first,
    BookingModel second,
  ) {
    return second.lastActivityAt.compareTo(
      first.lastActivityAt,
    );
  }

  void _sortBookings() {
    _myBookings.sort(
      _compareBookingsByActivity,
    );

    _providerBookings.sort(
      _compareBookingsByActivity,
    );
  }

  List<BookingModel> _removeDuplicates(
    List<BookingModel> bookings,
  ) {
    final bookingMap =
        <String, BookingModel>{};

    for (final booking in bookings) {
      final bookingId =
          booking.id.trim();

      if (bookingId.isEmpty) {
        continue;
      }

      final existing =
          bookingMap[bookingId];

      if (existing == null) {
        bookingMap[bookingId] =
            booking;
        continue;
      }

      if (booking.lastActivityAt.isAfter(
        existing.lastActivityAt,
      )) {
        bookingMap[bookingId] =
            booking;
      }
    }

    final result =
        bookingMap.values.toList();

    result.sort(
      _compareBookingsByActivity,
    );

    return result;
  }

  // =====================================================
  // BOOKING LIST UPDATE
  // =====================================================

  void _updateBookingInList(
    List<BookingModel> bookings,
    BookingModel booking, {
    required bool insertWhenMissing,
  }) {
    final bookingId =
        booking.id.trim();

    if (bookingId.isEmpty) {
      return;
    }

    final index =
        bookings.indexWhere(
      (item) => item.id == bookingId,
    );

    if (index >= 0) {
      bookings[index] = booking;
      return;
    }

    if (insertWhenMissing) {
      bookings.insert(
        0,
        booking,
      );
    }
  }

  void upsertBooking(
    BookingModel booking, {
    bool updateCustomerList = true,
    bool updateProviderList = false,
    bool selectBooking = false,
    bool notify = true,
  }) {
    if (booking.id.trim().isEmpty) {
      return;
    }

    if (updateCustomerList) {
      _updateBookingInList(
        _myBookings,
        booking,
        insertWhenMissing: true,
      );
    }

    if (updateProviderList) {
      _updateBookingInList(
        _providerBookings,
        booking,
        insertWhenMissing: true,
      );
    }

    if (selectBooking ||
        _selectedBooking?.id ==
            booking.id) {
      _selectedBooking = booking;
    }

    _sortBookings();

    if (notify) {
      _safeNotifyListeners();
    }
  }

  void _updateBookingEverywhere(
    BookingModel booking, {
    bool selectBooking = false,
    bool notify = true,
  }) {
    final existsInProviderList =
        _providerBookings.any(
      (item) => item.id == booking.id,
    );

    upsertBooking(
      booking,
      updateCustomerList: true,
      updateProviderList:
          existsInProviderList,
      selectBooking: selectBooking,
      notify: notify,
    );
  }

  BookingModel? findBookingById(
    String bookingId,
  ) {
    final normalizedBookingId =
        bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      return null;
    }

    if (_selectedBooking?.id ==
        normalizedBookingId) {
      return _selectedBooking;
    }

    for (final booking in _myBookings) {
      if (booking.id ==
          normalizedBookingId) {
        return booking;
      }
    }

    for (
      final booking
      in _providerBookings
    ) {
      if (booking.id ==
          normalizedBookingId) {
        return booking;
      }
    }

    return null;
  }

  void removeBookingFromLists(
    String bookingId, {
    bool notify = true,
  }) {
    final normalizedBookingId =
        bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      return;
    }

    _myBookings.removeWhere(
      (booking) =>
          booking.id ==
          normalizedBookingId,
    );

    _providerBookings.removeWhere(
      (booking) =>
          booking.id ==
          normalizedBookingId,
    );

    if (_selectedBooking?.id ==
        normalizedBookingId) {
      _selectedBooking = null;
    }

    if (notify) {
      _safeNotifyListeners();
    }
  }

  // =====================================================
  // CREATE BOOKING
  // =====================================================

  Future<BookingModel> createBooking({
    required String serviceId,
    required DateTime bookingDate,
    required String bookingTime,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
    String? couponCode,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final booking =
          await _repository.createBooking(
        serviceId: serviceId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        couponCode: couponCode,
      );

      upsertBooking(
        booking,
        updateCustomerList: true,
        updateProviderList: false,
        selectBooking: true,
        notify: false,
      );

      _safeNotifyListeners();

      return booking;
    } catch (error) {
      _setError(
        _errorMessage(error),
      );

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CUSTOMER BOOKINGS
  // =====================================================

  Future<void> getMyBookings({
    int page = 1,
    int limit = 100,
    String? status,
    bool forceRefresh = false,
    bool showLoading = true,
  }) async {
    if (_isRefreshing &&
        !forceRefresh) {
      return;
    }

    if (!forceRefresh &&
        _lastCustomerRefresh != null &&
        _myBookings.isNotEmpty) {
      final elapsed =
          DateTime.now().difference(
        _lastCustomerRefresh!,
      );

      if (elapsed <
          const Duration(
            seconds: 2,
          )) {
        return;
      }
    }

    if (showLoading) {
      _setLoading(true);
    } else {
      _setRefreshing(true);
    }

    _setError(
      null,
      notify: false,
    );

    try {
      final bookings =
          await _repository.getMyBookings(
        page: page,
        limit: limit,
        status: status,
      );

      final normalizedBookings =
          _removeDuplicates(
        List<BookingModel>.from(
          bookings,
        ),
      );

      if (page <= 1) {
        _myBookings =
            normalizedBookings;
      } else {
        _myBookings =
            _removeDuplicates(
          <BookingModel>[
            ..._myBookings,
            ...normalizedBookings,
          ],
        );
      }

      if (_selectedBooking != null) {
        final selectedIndex =
            _myBookings.indexWhere(
          (booking) =>
              booking.id ==
              _selectedBooking!.id,
        );

        if (selectedIndex >= 0) {
          _selectedBooking =
              _myBookings[
                  selectedIndex];
        }
      }

      _sortBookings();

      _lastCustomerRefresh =
          DateTime.now();

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        _errorMessage(error),
      );
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        _setRefreshing(false);
      }
    }
  }

  Future<void> refreshMyBookings() {
    return getMyBookings(
      page: 1,
      limit: 100,
      forceRefresh: true,
      showLoading: false,
    );
  }

  // =====================================================
  // PROVIDER BOOKINGS
  // =====================================================

  Future<void> getProviderBookings({
    int page = 1,
    int limit = 100,
    String? status,
    bool forceRefresh = false,
    bool showLoading = true,
  }) async {
    if (!forceRefresh &&
        _lastProviderRefresh != null &&
        _providerBookings.isNotEmpty) {
      final elapsed =
          DateTime.now().difference(
        _lastProviderRefresh!,
      );

      if (elapsed <
          const Duration(
            seconds: 2,
          )) {
        return;
      }
    }

    if (showLoading) {
      _setLoading(true);
    } else {
      _setRefreshing(true);
    }

    _setError(
      null,
      notify: false,
    );

    try {
      final bookings =
          await _repository
              .getProviderBookings(
        page: page,
        limit: limit,
        status: status,
      );

      final normalizedBookings =
          _removeDuplicates(
        List<BookingModel>.from(
          bookings,
        ),
      );

      if (page <= 1) {
        _providerBookings =
            normalizedBookings;
      } else {
        _providerBookings =
            _removeDuplicates(
          <BookingModel>[
            ..._providerBookings,
            ...normalizedBookings,
          ],
        );
      }

      _sortBookings();

      _lastProviderRefresh =
          DateTime.now();

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        _errorMessage(error),
      );
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        _setRefreshing(false);
      }
    }
  }

  // =====================================================
  // BOOKING DETAILS
  // =====================================================

  Future<void> getBookingById(
    String bookingId, {
    bool showLoading = false,
  }) async {
    final normalizedBookingId =
        bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking ID is required.',
      );

      return;
    }

    if (showLoading) {
      _setLoading(true);
    } else {
      _setRefreshing(true);
    }

    _setError(
      null,
      notify: false,
    );

    try {
      final booking =
          await _repository.getBookingById(
        normalizedBookingId,
      );

      _updateBookingEverywhere(
        booking,
        selectBooking: true,
        notify: false,
      );

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        _errorMessage(error),
      );
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        _setRefreshing(false);
      }
    }
  }

  Future<BookingModel?> fetchBookingById(
    String bookingId, {
    bool showLoading = false,
  }) async {
    await getBookingById(
      bookingId,
      showLoading: showLoading,
    );

    if (_selectedBooking?.id ==
        bookingId.trim()) {
      return _selectedBooking;
    }

    return findBookingById(
      bookingId,
    );
  }

  Future<void> refreshBooking(
    String bookingId, {
    bool showLoading = false,
  }) async {
    await getBookingById(
      bookingId,
      showLoading: showLoading,
    );
  }

  // =====================================================
  // BOOKING HISTORY
  // =====================================================

  Future<void> getBookingHistory({
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _setLoading(true);
    } else {
      _setRefreshing(true);
    }

    _setError(
      null,
      notify: false,
    );

    try {
      final bookings =
          await _repository
              .getBookingHistory();

      _myBookings =
          _removeDuplicates(
        List<BookingModel>.from(
          bookings,
        ),
      );

      _lastCustomerRefresh =
          DateTime.now();

      if (_selectedBooking != null) {
        final index =
            _myBookings.indexWhere(
          (booking) =>
              booking.id ==
              _selectedBooking!.id,
        );

        if (index >= 0) {
          _selectedBooking =
              _myBookings[index];
        }
      }

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        _errorMessage(error),
      );
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        _setRefreshing(false);
      }
    }
  }

  // =====================================================
  // CUSTOMER OTP
  // =====================================================

  Future<String?> getServiceOtp(
    String bookingId, {
    bool showLoading = false,
  }) async {
    final normalizedBookingId =
        bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking ID is required.',
      );

      return null;
    }

    final booking =
        findBookingById(
      normalizedBookingId,
    );

    if (booking != null &&
        !booking.shouldFetchServiceOtp) {
      if (booking.otpVerified) {
        _setError(
          'The service OTP has already been verified.',
        );
      } else if (booking.isPending) {
        _setError(
          'The service OTP will be available after the Provider accepts the booking.',
        );
      } else {
        _setError(
          'The service OTP is unavailable for this booking.',
        );
      }

      return null;
    }

    if (showLoading) {
      _setLoading(true);
    } else {
      _setRefreshing(true);
    }

    _setError(
      null,
      notify: false,
    );

    try {
      final otp =
          await _repository.getServiceOtp(
        normalizedBookingId,
      );

      return otp?.trim();
    } catch (error) {
      _setError(
        _errorMessage(error),
      );

      return null;
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        _setRefreshing(false);
      }
    }
  }

  // =====================================================
  // PROVIDER OTP VERIFICATION
  // =====================================================

  Future<bool> verifyServiceOtp({
    required String bookingId,
    required String otp,
  }) async {
    final normalizedBookingId =
        bookingId.trim();

    final normalizedOtp =
        otp.trim();

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking ID is required.',
      );

      return false;
    }

    if (normalizedOtp.length != 4 ||
        int.tryParse(
              normalizedOtp,
            ) ==
            null) {
      _setError(
        'A valid 4-digit service OTP is required.',
      );

      return false;
    }

    _setLoading(true);
    _setError(
      null,
      notify: false,
    );

    try {
      final booking =
          await _repository
              .verifyServiceOtp(
        bookingId:
            normalizedBookingId,
        otp: normalizedOtp,
      );

      _updateBookingEverywhere(
        booking,
        selectBooking: true,
        notify: false,
      );

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        _errorMessage(error),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // ACCEPT AND CONFIRM
  // =====================================================

  Future<bool> acceptBooking(
    String bookingId,
  ) {
    return updateStatus(
      bookingId: bookingId,
      status: 'accepted',
    );
  }

  Future<bool> confirmBooking(
    String bookingId,
  ) {
    return updateStatus(
      bookingId: bookingId,
      status: 'accepted',
    );
  }

  // =====================================================
  // START
  // =====================================================

  Future<bool> startBooking(
    String bookingId,
  ) {
    return updateStatus(
      bookingId: bookingId,
      status: 'in_progress',
    );
  }

  // =====================================================
  // COMPLETE
  // =====================================================

  Future<bool> completeBooking(
    String bookingId,
  ) {
    return updateStatus(
      bookingId: bookingId,
      status: 'completed',
    );
  }

  // =====================================================
  // UPDATE STATUS
  // =====================================================

  Future<bool> updateStatus({
    required String bookingId,
    required String status,
  }) async {
    final normalizedBookingId =
        bookingId.trim();

    final normalizedStatus =
        status
            .trim()
            .toLowerCase()
            .replaceAll(
              '-',
              '_',
            )
            .replaceAll(
              ' ',
              '_',
            );

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking ID is required.',
      );

      return false;
    }

    if (normalizedStatus.isEmpty) {
      _setError(
        'Booking status is required.',
      );

      return false;
    }

    _setLoading(true);
    _setError(
      null,
      notify: false,
    );

    try {
      final booking =
          await _repository.updateStatus(
        bookingId:
            normalizedBookingId,
        status:
            normalizedStatus,
      );

      _updateBookingEverywhere(
        booking,
        selectBooking: true,
        notify: false,
      );

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        _errorMessage(error),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CANCEL
  // =====================================================

  Future<bool> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    final normalizedBookingId =
        bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking ID is required.',
      );

      return false;
    }

    _setLoading(true);
    _setError(
      null,
      notify: false,
    );

    try {
      final success =
          await _repository.cancelBooking(
        bookingId:
            normalizedBookingId,
        reason:
            reason?.trim(),
      );

      if (!success) {
        _setError(
          'Unable to cancel the booking.',
        );

        return false;
      }

      try {
        final booking =
            await _repository
                .getBookingById(
          normalizedBookingId,
        );

        _updateBookingEverywhere(
          booking,
          selectBooking: true,
          notify: false,
        );
      } catch (_) {
        await getMyBookings(
          forceRefresh: true,
          showLoading: false,
        );
      }

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        _errorMessage(error),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // INVOICE
  // =====================================================

  Future<Map<String, dynamic>?> getInvoice(
    String bookingId, {
    bool showLoading = false,
  }) async {
    final normalizedBookingId =
        bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking ID is required.',
      );

      return null;
    }

    if (showLoading) {
      _setLoading(true);
    } else {
      _setRefreshing(true);
    }

    _setError(
      null,
      notify: false,
    );

    try {
      final invoice =
          await _repository.getInvoice(
        normalizedBookingId,
      );

      return Map<String, dynamic>.from(
        invoice,
      );
    } catch (error) {
      _setError(
        _errorMessage(error),
      );

      return null;
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        _setRefreshing(false);
      }
    }
  }

  // =====================================================
  // TRACK
  // =====================================================

  Future<Map<String, dynamic>> trackBooking(
    String bookingId,
  ) async {
    final normalizedBookingId =
        bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking ID is required.',
      );

      return <String, dynamic>{};
    }

    _setError(
      null,
      notify: false,
    );

    try {
      final trackingData =
          await _repository.trackBooking(
        normalizedBookingId,
      );

      return Map<String, dynamic>.from(
        trackingData,
      );
    } catch (error) {
      _setError(
        _errorMessage(error),
      );

      return <String, dynamic>{};
    }
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<bool> deleteBooking(
    String bookingId,
  ) async {
    final normalizedBookingId =
        bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking ID is required.',
      );

      return false;
    }

    _setLoading(true);
    _setError(
      null,
      notify: false,
    );

    try {
      final success =
          await _repository.deleteBooking(
        normalizedBookingId,
      );

      if (success) {
        removeBookingFromLists(
          normalizedBookingId,
          notify: false,
        );

        _safeNotifyListeners();
      }

      return success;
    } catch (error) {
      _setError(
        _errorMessage(error),
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SOCKET EVENT HANDLING
  // =====================================================

  Future<void> handleBookingEvent(
    dynamic event,
  ) async {
    try {
      final booking =
          _bookingFromEvent(
        event,
      );

      if (booking != null &&
          booking.id.trim().isNotEmpty) {
        _updateBookingEverywhere(
          booking,
          selectBooking:
              _selectedBooking?.id ==
                  booking.id,
          notify: false,
        );

        _safeNotifyListeners();

        return;
      }

      final bookingId =
          _extractBookingId(
        event,
      );

      if (bookingId.isNotEmpty) {
        await refreshBooking(
          bookingId,
          showLoading: false,
        );

        return;
      }

      await getMyBookings(
        limit: 100,
        forceRefresh: true,
        showLoading: false,
      );
    } catch (
      error,
      stackTrace
    ) {
      debugPrint(
        'BOOKING SOCKET EVENT ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      await getMyBookings(
        limit: 100,
        forceRefresh: true,
        showLoading: false,
      );
    }
  }

  Future<void> onBookingUpdated(
    String bookingId,
  ) async {
    final normalizedBookingId =
        bookingId.trim();

    if (normalizedBookingId.isNotEmpty) {
      await refreshBooking(
        normalizedBookingId,
        showLoading: false,
      );
    }

    await getMyBookings(
      limit: 100,
      forceRefresh: true,
      showLoading: false,
    );
  }

  Future<void> onRefreshCustomerBookings(
    dynamic event,
  ) async {
    final bookingId =
        _extractBookingId(
      event,
    );

    if (bookingId.isNotEmpty) {
      await refreshBooking(
        bookingId,
        showLoading: false,
      );
    }

    await getMyBookings(
      limit: 100,
      forceRefresh: true,
      showLoading: false,
    );
  }

  // =====================================================
  // SELECT BOOKING
  // =====================================================

  void setSelectedBooking(
    BookingModel booking, {
    bool updateList = true,
  }) {
    _selectedBooking = booking;

    if (updateList) {
      _updateBookingInList(
        _myBookings,
        booking,
        insertWhenMissing: true,
      );

      _sortBookings();
    }

    _safeNotifyListeners();
  }

  void selectBookingById(
    String bookingId,
  ) {
    final booking =
        findBookingById(
      bookingId,
    );

    if (booking == null) {
      return;
    }

    _selectedBooking = booking;
    _safeNotifyListeners();
  }

  // =====================================================
  // CLEAR SELECTED BOOKING
  // =====================================================

  void clearSelectedBooking() {
    _selectedBooking = null;
    _safeNotifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }

  // =====================================================
  // RESET
  // =====================================================

  void reset() {
    _myBookings =
        <BookingModel>[];

    _providerBookings =
        <BookingModel>[];

    _selectedBooking = null;

    _isLoading = false;
    _isRefreshing = false;

    _error = null;

    _lastCustomerRefresh = null;
    _lastProviderRefresh = null;

    _safeNotifyListeners();
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}