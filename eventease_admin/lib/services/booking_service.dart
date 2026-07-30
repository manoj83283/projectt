import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class BookingService {
  BookingService._();

  static final BookingService _instance =
      BookingService._();

  factory BookingService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL BOOKINGS
  // =====================================================

  Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? customerId,
    String? providerId,
    String? serviceId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/bookings',
        query: {
          'page': page,
          'limit': limit,
          if (search != null) 'search': search,
          if (status != null) 'status': status,
          if (customerId != null)
            'customerId': customerId,
          if (providerId != null)
            'providerId': providerId,
          if (serviceId != null)
            'serviceId': serviceId,
          if (startDate != null)
            'startDate': startDate,
          if (endDate != null)
            'endDate': endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/bookings/$bookingId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE BOOKING STATUS
  // =====================================================

  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
    String? notes,
  }) async {
    try {
      await _api.patch(
        '/admin/bookings/$bookingId/status',
        data: {
          'status': status,
          'notes': notes,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // APPROVE BOOKING
  // =====================================================

  Future<bool> approveBooking(
    String bookingId,
  ) async {
    try {
      await _api.patch(
        '/admin/bookings/$bookingId/approve',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REJECT BOOKING
  // =====================================================

  Future<bool> rejectBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/bookings/$bookingId/reject',
        data: {
          'reason': reason,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      await _api.patch(
        '/admin/bookings/$bookingId/cancel',
        data: {
          'reason': reason,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE BOOKING
  // =====================================================

  Future<bool> deleteBooking(
    String bookingId,
  ) async {
    try {
      await _api.delete(
        '/admin/bookings/$bookingId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ASSIGN PROVIDER
  // =====================================================

  Future<bool> assignProvider({
    required String bookingId,
    required String providerId,
  }) async {
    try {
      await _api.patch(
        '/admin/bookings/$bookingId/assign-provider',
        data: {
          'providerId': providerId,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/bookings/$bookingId/timeline',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/bookings/$bookingId/payments',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REFUND PAYMENT
  // =====================================================

  Future<bool> refundBooking({
    required String bookingId,
    required double amount,
    String? reason,
  }) async {
    try {
      await _api.post(
        '/admin/bookings/$bookingId/refund',
        data: {
          'amount': amount,
          'reason': reason,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BOOKING ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getBookingAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/bookings/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BOOKING STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getBookingStatistics() async {
    try {
      final response = await _api.get(
        '/admin/bookings/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // RECENT BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getRecentBookings() async {
    try {
      final response = await _api.get(
        '/admin/bookings/recent',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      searchBookings(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/bookings/search',
        query: {
          'keyword': keyword,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT BOOKINGS
  // =====================================================

  Future<Response<dynamic>>
      exportBookings({
    String format = 'excel',
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _api.get(
        '/admin/bookings/export',
        query: {
          'format': format,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND BOOKING NOTIFICATION
  // =====================================================

  Future<bool> sendNotification({
    required String bookingId,
    required String title,
    required String message,
  }) async {
    try {
      await _api.post(
        '/admin/bookings/$bookingId/notify',
        data: {
          'title': title,
          'message': message,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK DELETE BOOKINGS
  // =====================================================

  Future<bool> bulkDeleteBookings(
    List<String> bookingIds,
  ) async {
    try {
      await _api.post(
        '/admin/bookings/bulk-delete',
        data: {
          'bookingIds': bookingIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK STATUS UPDATE
  // =====================================================

  Future<bool> bulkStatusUpdate({
    required List<String> bookingIds,
    required String status,
  }) async {
    try {
      await _api.post(
        '/admin/bookings/bulk-status',
        data: {
          'bookingIds': bookingIds,
          'status': status,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ERROR HANDLER
  // =====================================================

  String _parseError(
    DioException e,
  ) {
    return e.response?.data?['message']
            ?.toString() ??
        e.message ??
        'Something went wrong';
  }
}