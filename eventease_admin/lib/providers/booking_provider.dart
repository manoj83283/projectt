import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService =
      BookingService();

  bool _isLoading = false;

  String? _errorMessage;

  List<BookingModel> _bookings = [];

  BookingModel? _selectedBooking;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalBookings = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<BookingModel> get bookings =>
      _bookings;

  BookingModel? get selectedBooking =>
      _selectedBooking;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalBookings =>
      _totalBookings;

  bool get hasBookings =>
      _bookings.isNotEmpty;

  // =====================================================
  // GET BOOKINGS
  // =====================================================

  Future<void> getBookings({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? customerId,
    String? providerId,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _bookingService.getBookings(
        page: page,
        limit: limit,
        search: search,
        status: status,
        customerId: customerId,
        providerId: providerId,
      );

      _bookings =
          (response['bookings'] as List? ??
                  [])
              .map(
                (e) =>
                    BookingModel.fromJson(
                  e,
                ),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalBookings =
          response['totalBookings'] ??
              _bookings.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET BOOKING DETAILS
  // =====================================================

  Future<void> getBookingDetails(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _bookingService
              .getBookingDetails(
        bookingId,
      );

      _selectedBooking =
          BookingModel.fromJson(
        response,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEARCH BOOKINGS
  // =====================================================

  Future<void> searchBookings(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _bookingService
              .searchBookings(
        keyword,
      );

      _bookings =
          (response)
              .map(
                (e) =>
                    BookingModel.fromJson(
                  e,
                ),
              )
              .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CONFIRM BOOKING
  // =====================================================

  Future<bool> confirmBooking(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      await _bookingService
          .confirmBooking(
        bookingId,
      );

      final index =
          _bookings.indexWhere(
        (e) => e.id == bookingId,
      );

      if (index != -1) {
        _bookings[index] =
            _bookings[index].copyWith(
          status: 'confirmed',
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // COMPLETE BOOKING
  // =====================================================

  Future<bool> completeBooking(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      await _bookingService
          .completeBooking(
        bookingId,
      );

      final index =
          _bookings.indexWhere(
        (e) => e.id == bookingId,
      );

      if (index != -1) {
        _bookings[index] =
            _bookings[index].copyWith(
          status: 'completed',
          completedAt: DateTime.now(),
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CANCEL BOOKING
  // =====================================================

  Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      _setLoading(true);

      await _bookingService.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );

      final index =
          _bookings.indexWhere(
        (e) => e.id == bookingId,
      );

      if (index != -1) {
        _bookings[index] =
            _bookings[index].copyWith(
          status: 'cancelled',
          cancellationReason: reason,
          cancelledAt: DateTime.now(),
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // UPDATE PAYMENT STATUS
  // =====================================================

  Future<bool> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
  }) async {
    try {
      _setLoading(true);

      await _bookingService
          .updatePaymentStatus(
        bookingId: bookingId,
        paymentStatus: paymentStatus,
      );

      final index =
          _bookings.indexWhere(
        (e) => e.id == bookingId,
      );

      if (index != -1) {
        _bookings[index] =
            _bookings[index].copyWith(
          paymentStatus:
              paymentStatus,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DELETE BOOKING
  // =====================================================

  Future<bool> deleteBooking(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      await _bookingService
          .deleteBooking(
        bookingId,
      );

      _bookings.removeWhere(
        (e) => e.id == bookingId,
      );

      if (_selectedBooking?.id ==
          bookingId) {
        _selectedBooking = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH BOOKINGS
  // =====================================================

  Future<void> refreshBookings() async {
    await getBookings(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED BOOKING
  // =====================================================

  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =====================================================
  // LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}