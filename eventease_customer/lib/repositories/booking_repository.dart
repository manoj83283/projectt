import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  BookingRepository._();

  static final BookingRepository instance =
      BookingRepository._();

  final BookingService _bookingService =
      BookingService.instance;

  // =====================================================
  // CREATE BOOKING
  // =====================================================
  //
  // The backend derives:
  // - Provider ID from Service.provider
  // - Pricing from the Service document
  // - Booking ID from MongoDB
  //
  // providerId and amount remain in the method signature
  // only for compatibility with older calling code.
  // =====================================================

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
    String paymentMethod = 'COD',
    int hoursBooked = 1,
    Map<String, dynamic>? data,
  }) {
    return _bookingService.createBooking(
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
      paymentMethod: paymentMethod,
      hoursBooked: hoursBooked,
      data: data,
    );
  }

  // =====================================================
  // MY BOOKINGS
  // =====================================================

  Future<List<BookingModel>> getMyBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    return _bookingService.getMyBookings(
      page: page,
      limit: limit,
      status: status,
    );
  }

  // =====================================================
  // BOOKING DETAILS
  // =====================================================

  Future<BookingModel> getBookingById(
    String bookingId,
  ) {
    return _bookingService.getBookingById(
      bookingId,
    );
  }

  // =====================================================
  // PROVIDER BOOKINGS
  // =====================================================
  //
  // Retained for shared compatibility.
  // The dedicated Provider application normally calls:
  //
  // GET /api/provider/bookings
  // =====================================================

  Future<List<BookingModel>>
      getProviderBookings({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    return _bookingService
        .getProviderBookings(
      page: page,
      limit: limit,
      status: status,
    );
  }

  // =====================================================
  // BOOKING HISTORY
  // =====================================================

  Future<List<BookingModel>>
      getBookingHistory() {
    return _bookingService
        .getBookingHistory();
  }

  // =====================================================
  // UPDATE BOOKING STATUS
  // =====================================================

  Future<BookingModel>
      updateBookingStatus({
    required String bookingId,
    required String status,
    String? reason,
    String? note,
  }) {
    return _bookingService
        .updateBookingStatus(
      bookingId: bookingId,
      status: status,
      reason: reason,
      note: note,
    );
  }

  // =====================================================
  // UPDATE STATUS
  // Backward compatibility for BookingProvider
  // =====================================================

  Future<BookingModel> updateStatus({
    required String bookingId,
    required String status,
    String? reason,
    String? note,
  }) {
    return updateBookingStatus(
      bookingId: bookingId,
      status: status,
      reason: reason,
      note: note,
    );
  }

  // =====================================================
  // ACCEPT BOOKING
  // =====================================================

  Future<bool> acceptBooking(
    String bookingId,
  ) {
    return _bookingService.acceptBooking(
      bookingId,
    );
  }

  // =====================================================
  // CONFIRM BOOKING
  // =====================================================

  Future<bool> confirmBooking(
    String bookingId,
  ) {
    return _bookingService.confirmBooking(
      bookingId,
    );
  }

  // =====================================================
  // START BOOKING
  // =====================================================

  Future<bool> startBooking(
    String bookingId,
  ) {
    return _bookingService.startBooking(
      bookingId,
    );
  }

  // =====================================================
  // COMPLETE BOOKING
  // =====================================================

  Future<bool> completeBooking(
    String bookingId,
  ) {
    return _bookingService.completeBooking(
      bookingId,
    );
  }

  // =====================================================
  // REJECT BOOKING
  // =====================================================

  Future<bool> rejectBooking({
    required String bookingId,
    String? reason,
  }) {
    return _bookingService.rejectBooking(
      bookingId: bookingId,
      reason: reason,
    );
  }

  // =====================================================
  // CANCEL BOOKING
  // =====================================================

  Future<bool> cancelBooking({
    required String bookingId,
    String? reason,
  }) {
    return _bookingService.cancelBooking(
      bookingId: bookingId,
      reason: reason,
    );
  }

  // =====================================================
  // RESCHEDULE BOOKING
  // =====================================================
  //
  // Requires:
  // PATCH /api/bookings/:id/reschedule
  // =====================================================

  Future<bool> rescheduleBooking({
    required String bookingId,
    DateTime? bookingDate,
    String? bookingTime,
    String? reason,
  }) {
    return _bookingService
        .rescheduleBooking(
      bookingId: bookingId,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      reason: reason,
    );
  }

  // =====================================================
  // TRACK BOOKING
  // =====================================================
  //
  // Requires:
  // GET /api/bookings/:id/track
  // =====================================================

  Future<Map<String, dynamic>>
      trackBooking(
    String bookingId,
  ) {
    return _bookingService.trackBooking(
      bookingId: bookingId,
    );
  }

  // =====================================================
  // DELETE BOOKING
  // =====================================================
  //
  // Requires:
  // DELETE /api/bookings/:id
  // =====================================================

  Future<bool> deleteBooking(
    String bookingId,
  ) {
    return _bookingService.deleteBooking(
      bookingId,
    );
  }
}