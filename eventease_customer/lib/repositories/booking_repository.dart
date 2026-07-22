import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  BookingRepository._();

  static final BookingRepository instance =
      BookingRepository._();

  final BookingService _bookingService =
      BookingService.instance;

  // ==========================================
  // CREATE BOOKING
  // ==========================================

  Future<BookingModel> createBooking({
    required String serviceId,
    required DateTime bookingDate,
    required String bookingTime,
    required String address,
    required double latitude,
    required double longitude,
    String? notes,
    String? couponCode,
  }) async {
    return await _bookingService.createBooking(
      serviceId: serviceId,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      address: address,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      couponCode: couponCode,
    );
  }

  // ==========================================
  // MY BOOKINGS
  // ==========================================

  Future<List<BookingModel>> getMyBookings({
    int page = 1,
    int limit = 20,
  }) async {
    return await _bookingService.getMyBookings(
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // GET BOOKING BY ID
  // ==========================================

  Future<BookingModel> getBookingById(
    String bookingId,
  ) async {
    return await _bookingService.getBookingById(
      bookingId,
    );
  }

  // ==========================================
  // PROVIDER BOOKINGS
  // ==========================================

  Future<List<BookingModel>>
      getProviderBookings({
    int page = 1,
    int limit = 20,
  }) async {
    return await _bookingService
        .getProviderBookings(
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // UPDATE STATUS
  // ==========================================

  Future<BookingModel> updateStatus({
    required String bookingId,
    required String status,
  }) async {
    return await _bookingService.updateStatus(
      bookingId: bookingId,
      status: status,
    );
  }

  // ==========================================
  // ACCEPT BOOKING
  // ==========================================

  Future<bool> acceptBooking(
    String bookingId,
  ) async {
    return await _bookingService
        .acceptBooking(bookingId);
  }

  // ==========================================
  // CONFIRM BOOKING
  // ==========================================

  Future<bool> confirmBooking(
    String bookingId,
  ) async {
    return await _bookingService
        .confirmBooking(bookingId);
  }

  // ==========================================
  // START BOOKING
  // ==========================================

  Future<bool> startBooking(
    String bookingId,
  ) async {
    return await _bookingService
        .startBooking(bookingId);
  }

  // ==========================================
  // COMPLETE BOOKING
  // ==========================================

  Future<bool> completeBooking(
    String bookingId,
  ) async {
    return await _bookingService
        .completeBooking(bookingId);
  }

  // ==========================================
  // CANCEL BOOKING
  // ==========================================

  Future<bool> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    return await _bookingService.cancelBooking(
      bookingId: bookingId,
      reason: reason,
    );
  }

  // ==========================================
  // TRACK BOOKING
  // ==========================================

  Future<Map<String, dynamic>> trackBooking(
    String bookingId,
  ) async {
    return await _bookingService.trackBooking(
      bookingId,
    );
  }

  // ==========================================
  // BOOKING HISTORY
  // ==========================================

  Future<List<BookingModel>>
      getBookingHistory() async {
    return await _bookingService
        .getBookingHistory();
  }

  // ==========================================
  // DELETE BOOKING
  // ==========================================

  Future<bool> deleteBooking(
    String bookingId,
  ) async {
    return await _bookingService
        .deleteBooking(bookingId);
  }
}