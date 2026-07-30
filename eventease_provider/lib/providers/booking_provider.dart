import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository =
      BookingRepository.instance;

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;

  String? _errorMessage;

  List<BookingModel> _bookings = [];

  List<BookingModel> _todayBookings = [];

  List<BookingModel> _upcomingBookings = [];

  BookingModel? _selectedBooking;

  Map<String, dynamic> _analytics = {};

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<BookingModel> get bookings =>
      _bookings;

  List<BookingModel> get todayBookings =>
      _todayBookings;

  List<BookingModel> get upcomingBookings =>
      _upcomingBookings;

  BookingModel? get selectedBooking =>
      _selectedBooking;

  Map<String, dynamic> get analytics =>
      _analytics;

  // =========================
  // HELPERS
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // CREATE BOOKING
  // =========================

  Future<bool> createBooking({
    required Map<String, dynamic> data,
  }) async {
    try {
      _setLoading(true);

      final booking =
          await _repository.createBooking(
        data: data,
      );

      _bookings.insert(0, booking);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET BOOKINGS
  // =========================

  Future<void> getBookings() async {
    try {
      _setLoading(true);

      _bookings =
          await _repository.getBookings();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET BOOKING BY ID
  // =========================

  Future<BookingModel?> getBookingById(
    String bookingId,
  ) async {
    try {
      _setLoading(true);

      _selectedBooking =
          await _repository.getBookingById(
        bookingId,
      );

      notifyListeners();

      return _selectedBooking;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // TODAY BOOKINGS
  // =========================

  Future<void> getTodayBookings() async {
    try {
      _todayBookings =
          await _repository
              .getTodayBookings();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // UPCOMING BOOKINGS
  // =========================

  Future<void>
      getUpcomingBookings() async {
    try {
      _upcomingBookings =
          await _repository
              .getUpcomingBookings();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // CONFIRM BOOKING
  // =========================

  Future<bool> confirmBooking(
    String bookingId,
  ) async {
    try {
      final success =
          await _repository.confirmBooking(
        bookingId,
      );

      if (success) {
        await getBookings();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // START BOOKING
  // =========================

  Future<bool> startBooking(
    String bookingId,
  ) async {
    try {
      final success =
          await _repository.startBooking(
        bookingId,
      );

      if (success) {
        await getBookings();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // COMPLETE BOOKING
  // =========================

  Future<bool> completeBooking(
    String bookingId,
  ) async {
    try {
      final success =
          await _repository.completeBooking(
        bookingId,
      );

      if (success) {
        await getBookings();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // CANCEL BOOKING
  // =========================

  Future<bool> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      final success =
          await _repository.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );

      if (success) {
        await getBookings();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // RESCHEDULE BOOKING
  // =========================

  Future<bool> rescheduleBooking({
    required String bookingId,
    required DateTime date,
    required String time,
  }) async {
    try {
      final success =
          await _repository
              .rescheduleBooking(
        bookingId: bookingId,
        date: date,
        time: time,
      );

      if (success) {
        await getBookings();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // BOOKINGS BY STATUS
  // =========================

  Future<List<BookingModel>>
      getBookingsByStatus(
    String status,
  ) async {
    try {
      return await _repository
          .getBookingsByStatus(status);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // =========================
  // SEARCH BOOKINGS
  // =========================

  Future<List<BookingModel>>
      searchBookings(
    String keyword,
  ) async {
    try {
      return await _repository
          .searchBookings(keyword);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // =========================
  // BOOKING ANALYTICS
  // =========================

  Future<void>
      getBookingAnalytics() async {
    try {
      _analytics =
          await _repository
              .getBookingAnalytics();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // COUNTS
  // =========================

  Future<int> getBookingCount() async {
    try {
      return await _repository
          .getBookingCount();
    } catch (e) {
      return 0;
    }
  }

  Future<int> getPendingCount() async {
    try {
      return await _repository
          .getPendingCount();
    } catch (e) {
      return 0;
    }
  }

  Future<int> getCompletedCount() async {
    try {
      return await _repository
          .getCompletedCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // REFRESH DATA
  // =========================

  Future<void> refreshData() async {
    await Future.wait([
      getBookings(),
      getTodayBookings(),
      getUpcomingBookings(),
      getBookingAnalytics(),
    ]);
  }

  // =========================
  // RESET STATE
  // =========================

  void reset() {
    _bookings = [];
    _todayBookings = [];
    _upcomingBookings = [];
    _selectedBooking = null;
    _analytics = {};
    _errorMessage = null;

    notifyListeners();
  }
}