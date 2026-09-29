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
  // CUSTOMER BOOKINGS
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
  // PROVIDER BOOKINGS
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
  // SERVICE OTP
  // =====================================================

  Future<String?> getServiceOtp(
    String bookingId,
  ) {
    return _bookingService.getServiceOtp(
      bookingId,
    );
  }

  // =====================================================
  // VERIFY OTP
  // =====================================================

  Future<BookingModel> verifyServiceOtp({
    required String bookingId,
    required String otp,
  }) {
    return _bookingService.verifyServiceOtp(
      bookingId: bookingId,
      otp: otp,
    );
  }

  // =====================================================
  // STATUS UPDATE
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
  // ACCEPT
  // =====================================================

  Future<bool> acceptBooking(
    String bookingId,
  ) {
    return _bookingService.acceptBooking(
      bookingId,
    );
  }

  // =====================================================
  // CONFIRM
  // =====================================================

  Future<bool> confirmBooking(
    String bookingId,
  ) {
    return _bookingService.confirmBooking(
      bookingId,
    );
  }

  // =====================================================
  // START
  // =====================================================

  Future<bool> startBooking(
    String bookingId,
  ) {
    return _bookingService.startBooking(
      bookingId,
    );
  }

  // =====================================================
  // COMPLETE
  // =====================================================

  Future<bool> completeBooking(
    String bookingId,
  ) {
    return _bookingService.completeBooking(
      bookingId,
    );
  }

  // =====================================================
  // REJECT
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
  // CANCEL
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
  // RESCHEDULE
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
  // INVOICE
  // =====================================================

  Future<Map<String, dynamic>>
      getInvoice(
    String bookingId,
  ) {
    return _bookingService.getInvoice(
      bookingId,
    );
  }

  // =====================================================
  // TRACK
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
  // DELETE
  // =====================================================

  Future<bool> deleteBooking(
    String bookingId,
  ) {
    return _bookingService.deleteBooking(
      bookingId,
    );
  }
}