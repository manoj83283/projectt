import 'package:flutter/foundation.dart';

import '../providers/booking_provider.dart';
import 'socket_service.dart';

class CustomerRealtimeService {
  CustomerRealtimeService._();

  static final CustomerRealtimeService instance = CustomerRealtimeService._();

  final SocketService _socketService = SocketService.instance;

  BookingProvider? _bookingProvider;

  String _accessToken = '';
  String _customerId = '';

  bool _initialized = false;
  bool _initializing = false;

  bool get isInitialized {
    return _initialized;
  }

  bool get isInitializing {
    return _initializing;
  }

  bool get isConnected {
    return _socketService.isConnected;
  }

  String get customerId {
    return _customerId;
  }

  Future<void> initialize({
    required String token,
    required String customerId,
    required BookingProvider bookingProvider,
  }) async {
    final normalizedToken = token.trim();

    final normalizedCustomerId = customerId.trim();

    if (normalizedToken.isEmpty) {
      throw ArgumentError('Customer access token is required.');
    }

    if (normalizedCustomerId.isEmpty) {
      throw ArgumentError('Customer ID is required.');
    }

    if (_initializing) {
      return;
    }

    _initializing = true;

    try {
      _accessToken = normalizedToken;
      _customerId = normalizedCustomerId;
      _bookingProvider = bookingProvider;

      _socketService.registerCustomerBookingListeners(_handleBookingEvent);

      await _socketService.connect(
        token: normalizedToken,
        customerId: normalizedCustomerId,
      );

      _socketService.joinCustomerRoom(normalizedCustomerId);

      await bookingProvider.getMyBookings(
        page: 1,
        limit: 100,
        forceRefresh: true,
        showLoading: false,
      );

      _initialized = true;

      _debug('Customer booking synchronization initialized.');
    } finally {
      _initializing = false;
    }
  }

  Future<void> restore() async {
    final bookingProvider = _bookingProvider;

    if (_accessToken.isEmpty ||
        _customerId.isEmpty ||
        bookingProvider == null ||
        _initializing) {
      return;
    }

    await initialize(
      token: _accessToken,
      customerId: _customerId,
      bookingProvider: bookingProvider,
    );
  }

  Future<void> refreshBookings() async {
    final bookingProvider = _bookingProvider;

    if (bookingProvider == null) {
      return;
    }

    await bookingProvider.getMyBookings(
      page: 1,
      limit: 100,
      forceRefresh: true,
      showLoading: false,
    );
  }

  Future<void> _handleBookingEvent(dynamic event) async {
    final bookingProvider = _bookingProvider;

    if (bookingProvider == null) {
      return;
    }

    _debug('Booking lifecycle event received.');

    await bookingProvider.handleBookingEvent(event);
  }

  void joinBookingRoom(String bookingId) {
    final normalizedBookingId = bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      return;
    }

    _socketService.joinBookingRoom(normalizedBookingId);
  }

  void leaveBookingRoom(String bookingId) {
    final normalizedBookingId = bookingId.trim();

    if (normalizedBookingId.isEmpty) {
      return;
    }

    _socketService.leaveBookingRoom(normalizedBookingId);
  }

  void disconnect() {
    _socketService.removeCustomerBookingListeners();

    _socketService.disconnect();

    _bookingProvider = null;

    _accessToken = '';
    _customerId = '';

    _initialized = false;
    _initializing = false;

    _debug('Customer booking synchronization disconnected.');
  }

  void _debug(String message) {
    if (kDebugMode) {
      debugPrint('CUSTOMER REALTIME: $message');
    }
  }
}
