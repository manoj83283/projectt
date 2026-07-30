import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  BookingRepository._();

  static final BookingRepository _instance =
      BookingRepository._();

  static BookingRepository get instance =>
      _instance;

  final BookingService _bookingService =
      BookingService.instance;

  // =========================
  // CREATE BOOKING
  // =========================

  Future<BookingModel> createBooking({
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _bookingService
          .createBooking(
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET BOOKINGS
  // =========================

  Future<List<BookingModel>>
      getBookings() async {
    try {
      return await _bookingService
          .getBookings();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET BOOKING BY ID
  // =========================

  Future<BookingModel> getBookingById(
    String bookingId,
  ) async {
    try {
      return await _bookingService
          .getBookingById(
        bookingId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET TODAY BOOKINGS
  // =========================

  Future<List<BookingModel>>
      getTodayBookings() async {
    try {
      return await _bookingService
          .getTodayBookings();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET UPCOMING BOOKINGS
  // =========================

  Future<List<BookingModel>>
      getUpcomingBookings() async {
    try {
      return await _bookingService
          .getUpcomingBookings();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // CONFIRM BOOKING
  // =========================

  Future<bool> confirmBooking(
    String bookingId,
  ) async {
    try {
      return await _bookingService
          .confirmBooking(
        bookingId,
      );
    } catch (e) {
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
      return await _bookingService
          .startBooking(
        bookingId,
      );
    } catch (e) {
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
      return await _bookingService
          .completeBooking(
        bookingId,
      );
    } catch (e) {
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
      return await _bookingService
          .cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );
    } catch (e) {
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
      return await _bookingService
          .rescheduleBooking(
        bookingId: bookingId,
        date: date,
        time: time,
      );
    } catch (e) {
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
      return await _bookingService
          .getBookingsByStatus(
        status,
      );
    } catch (e) {
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
      return await _bookingService
          .searchBookings(
        keyword,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // BOOKING ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getBookingAnalytics() async {
    try {
      return await _bookingService
          .getBookingAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // TOTAL BOOKINGS COUNT
  // =========================

  Future<int> getBookingCount() async {
    try {
      return await _bookingService
          .getBookingCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // PENDING BOOKINGS COUNT
  // =========================

  Future<int> getPendingCount() async {
    try {
      return await _bookingService
          .getPendingCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // COMPLETED BOOKINGS COUNT
  // =========================

  Future<int> getCompletedCount() async {
    try {
      return await _bookingService
          .getCompletedCount();
    } catch (e) {
      return 0;
    }
  }
}