import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _bookingService;

  BookingRepository({
    BookingService? bookingService,
  }) : _bookingService =
            bookingService ??
                BookingService();

  // =====================================================
  // GET BOOKINGS
  // =====================================================

  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? customerId,
    String? providerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _bookingService.getBookings(
        page: page,
        limit: limit,
        search: search,
        status: status,
        customerId: customerId,
        providerId: providerId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GET BOOKING DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getBookingDetails(
    String bookingId,
  ) async {
    try {
      return await _bookingService
          .getBookingDetails(
        bookingId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH BOOKINGS
  // =====================================================

  Future<List<dynamic>> searchBookings(
    String keyword,
  ) async {
    try {
      return await _bookingService
          .searchBookings(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CONFIRM BOOKING
  // =====================================================

  Future<Map<String, dynamic>>
      confirmBooking(
    String bookingId,
  ) async {
    try {
      return await _bookingService
          .confirmBooking(
        bookingId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // COMPLETE BOOKING
  // =====================================================

  Future<Map<String, dynamic>>
      completeBooking(
    String bookingId,
  ) async {
    try {
      return await _bookingService
          .completeBooking(
        bookingId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CANCEL BOOKING
  // =====================================================

  Future<Map<String, dynamic>>
      cancelBooking({
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
      rethrow;
    }
  }

  // =====================================================
  // UPDATE PAYMENT STATUS
  // =====================================================

  Future<Map<String, dynamic>>
      updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
  }) async {
    try {
      return await _bookingService
          .updatePaymentStatus(
        bookingId: bookingId,
        paymentStatus: paymentStatus,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BOOKING TIMELINE
  // =====================================================

  Future<List<dynamic>>
      getBookingTimeline(
    String bookingId,
  ) async {
    try {
      return await _bookingService
          .getBookingTimeline(
        bookingId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BOOKING PAYMENTS
  // =====================================================

  Future<List<dynamic>>
      getBookingPayments(
    String bookingId,
  ) async {
    try {
      return await _bookingService
          .getBookingPayments(
        bookingId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getCustomerBookings(
    String customerId,
  ) async {
    try {
      return await _bookingService
          .getCustomerBookings(
        customerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getProviderBookings(
    String providerId,
  ) async {
    try {
      return await _bookingService
          .getProviderBookings(
        providerId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BOOKING ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getBookingAnalytics() async {
    try {
      return await _bookingService
          .getBookingAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BOOKING REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateBookingReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _bookingService
          .generateBookingReport(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE BOOKING
  // =====================================================

  Future<void> deleteBooking(
    String bookingId,
  ) async {
    try {
      await _bookingService
          .deleteBooking(
        bookingId,
      );
    } catch (e) {
      rethrow;
    }
  }
}