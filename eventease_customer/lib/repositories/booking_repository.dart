import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  BookingRepository._();

  static final BookingRepository instance = BookingRepository._();

  final BookingService _bookingService = BookingService.instance;

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
    try {
      return await _bookingService.createBooking(
        serviceId: serviceId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        amount: amount,
        providerId: providerId,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
        couponCode: couponCode,
        data: data,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // MY BOOKINGS
  // ==========================================

  Future<List<BookingModel>> getMyBookings({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _bookingService.getMyBookings(
        page: page,
        limit: limit,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // BOOKING DETAILS
  // ==========================================

  Future<BookingModel> getBookingById(
    String bookingId,
  ) async {
    try {
      return await _bookingService.getBookingById(
        bookingId,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // PROVIDER BOOKINGS
  // ==========================================

  Future<List<BookingModel>> getProviderBookings({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _bookingService.getProviderBookings(
        page: page,
        limit: limit,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // BOOKING HISTORY
  // ==========================================

  Future<List<BookingModel>> getBookingHistory() async {
    try {
      return await _bookingService.getBookingHistory();
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // UPDATE BOOKING STATUS
  // ==========================================

  Future<BookingModel> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      return await _bookingService.updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // UPDATE STATUS
  // Backward compatibility for BookingProvider
  // ==========================================

  Future<BookingModel> updateStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      return await updateBookingStatus(
        bookingId: bookingId,
        status: status,
      );
    } catch (_) {
      rethrow;
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
      return await _bookingService.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // ACCEPT BOOKING
  // ==========================================

  Future<bool> acceptBooking(
    String bookingId,
  ) async {
    try {
      return await _bookingService.acceptBooking(
        bookingId,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // CONFIRM BOOKING
  // ==========================================

  Future<bool> confirmBooking(
    String bookingId,
  ) async {
    try {
      return await _bookingService.confirmBooking(
        bookingId,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // START BOOKING
  // ==========================================

  Future<bool> startBooking(
    String bookingId,
  ) async {
    try {
      return await _bookingService.startBooking(
        bookingId,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // COMPLETE BOOKING
  // ==========================================

  Future<bool> completeBooking(
    String bookingId,
  ) async {
    try {
      return await _bookingService.completeBooking(
        bookingId,
      );
    } catch (_) {
      rethrow;
    }
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
    try {
      return await _bookingService.rescheduleBooking(
        bookingId: bookingId,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        reason: reason,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // TRACK BOOKING
  // ==========================================

  Future<Map<String, dynamic>> trackBooking(
    String bookingId,
  ) async {
    try {
      return await _bookingService.trackBooking(
        bookingId: bookingId,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================
  // DELETE BOOKING
  // ==========================================

  Future<bool> deleteBooking(
    String bookingId,
  ) async {
    try {
      return await _bookingService.deleteBooking(
        bookingId,
      );
    } catch (_) {
      rethrow;
    }
  }
}