import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  BookingProvider();

  final BookingRepository _repository =
      BookingRepository.instance;

  List<BookingModel> _myBookings = [];
  List<BookingModel> _providerBookings = [];

  BookingModel? _selectedBooking;

  bool _isLoading = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  List<BookingModel> get myBookings =>
      _myBookings;

  List<BookingModel> get providerBookings =>
      _providerBookings;

  BookingModel? get selectedBooking =>
      _selectedBooking;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // ==========================================
  // INTERNAL HELPERS
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ==========================================
  // CREATE BOOKING
  // ==========================================

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
    try {
      _setLoading(true);
      _setError(null);

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

      _selectedBooking = booking;

      _myBookings.removeWhere(
        (item) => item.id == booking.id,
      );

      _myBookings.insert(
        0,
        booking,
      );

      notifyListeners();

      return booking;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // MY BOOKINGS
  // ==========================================

  Future<void> getMyBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _myBookings =
          await _repository.getMyBookings(
        page: page,
        limit: limit,
        status: status,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PROVIDER BOOKINGS
  // ==========================================

  Future<void> getProviderBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _providerBookings =
          await _repository.getProviderBookings(
        page: page,
        limit: limit,
        status: status,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // BOOKING DETAILS
  // ==========================================

  Future<void> getBookingById(
    String bookingId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _selectedBooking =
          await _repository.getBookingById(
        bookingId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // BOOKING HISTORY
  // ==========================================

  Future<void> getBookingHistory() async {
    try {
      _setLoading(true);
      _setError(null);

      _myBookings =
          await _repository
              .getBookingHistory();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // ACCEPT BOOKING
  // ==========================================

  Future<bool> acceptBooking(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.acceptBooking(
        bookingId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CONFIRM BOOKING
  // ==========================================

  Future<bool> confirmBooking(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.confirmBooking(
        bookingId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // START BOOKING
  // ==========================================

  Future<bool> startBooking(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.startBooking(
        bookingId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // COMPLETE BOOKING
  // ==========================================

  Future<bool> completeBooking(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.completeBooking(
        bookingId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // UPDATE STATUS
  // ==========================================

  Future<bool> updateStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      _setLoading(true);

      final booking =
          await _repository.updateStatus(
        bookingId: bookingId,
        status: status,
      );

      _selectedBooking = booking;

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CANCEL BOOKING
  // ==========================================

  Future<bool> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      _setLoading(true);

      return await _repository.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // TRACK BOOKING
  // ==========================================

  Future<Map<String, dynamic>>
      trackBooking(
    String bookingId,
  ) async {
    try {
      return await _repository.trackBooking(
        bookingId,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // DELETE BOOKING
  // ==========================================

  Future<bool> deleteBooking(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.deleteBooking(
        bookingId,
      );

      if (success) {
        _myBookings.removeWhere(
          (item) => item.id == bookingId,
        );

        _providerBookings.removeWhere(
          (item) => item.id == bookingId,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SELECT BOOKING
  // ==========================================

  void setSelectedBooking(
    BookingModel booking,
  ) {
    _selectedBooking = booking;
    notifyListeners();
  }

  // ==========================================
  // CLEAR BOOKING
  // ==========================================

  void clearSelectedBooking() {
    _selectedBooking = null;
    notifyListeners();
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==========================================
  // RESET
  // ==========================================

  void reset() {
    _myBookings = [];
    _providerBookings = [];
    _selectedBooking = null;
    _error = null;

    notifyListeners();
  }
}