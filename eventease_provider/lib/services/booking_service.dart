import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/booking_model.dart';

class BookingService {
  BookingService._();

  static final BookingService _instance =
      BookingService._();

  static BookingService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // CREATE BOOKING
  // =========================

  Future<BookingModel> createBooking({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.post(
        '/bookings',
        body: data,
      );

      return BookingModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Create Booking Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET ALL BOOKINGS
  // =========================

  Future<List<BookingModel>>
      getBookings() async {
    try {
      final response = await _apiService.get(
        '/provider/bookings',
      );

      final List<dynamic> bookings =
          response['data'] ?? [];

      return bookings
          .map(
            (e) => BookingModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Get Bookings Error: $e');
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
      final response = await _apiService.get(
        '/provider/bookings/$bookingId',
      );

      return BookingModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Get Booking By Id Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET TODAY BOOKINGS
  // =========================

  Future<List<BookingModel>>
      getTodayBookings() async {
    try {
      final response = await _apiService.get(
        '/provider/bookings/today',
      );

      final List<dynamic> bookings =
          response['data'] ?? [];

      return bookings
          .map(
            (e) => BookingModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Today Bookings Error: $e');
      return [];
    }
  }

  // =========================
  // GET UPCOMING BOOKINGS
  // =========================

  Future<List<BookingModel>>
      getUpcomingBookings() async {
    try {
      final response = await _apiService.get(
        '/provider/bookings/upcoming',
      );

      final List<dynamic> bookings =
          response['data'] ?? [];

      return bookings
          .map(
            (e) => BookingModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Upcoming Bookings Error: $e');
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
      await _apiService.patch(
        '/provider/bookings/$bookingId/confirm',
      );

      return true;
    } catch (e) {
      log('Confirm Booking Error: $e');
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
      await _apiService.patch(
        '/provider/bookings/$bookingId/start',
      );

      return true;
    } catch (e) {
      log('Start Booking Error: $e');
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
      await _apiService.patch(
        '/provider/bookings/$bookingId/complete',
      );

      return true;
    } catch (e) {
      log('Complete Booking Error: $e');
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
      await _apiService.patch(
        '/provider/bookings/$bookingId/cancel',
        body: {
          'reason': reason,
        },
      );

      return true;
    } catch (e) {
      log('Cancel Booking Error: $e');
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
      await _apiService.patch(
        '/provider/bookings/$bookingId/reschedule',
        body: {
          'date': date.toIso8601String(),
          'time': time,
        },
      );

      return true;
    } catch (e) {
      log('Reschedule Booking Error: $e');
      return false;
    }
  }

  // =========================
  // GET BOOKINGS BY STATUS
  // =========================

  Future<List<BookingModel>>
      getBookingsByStatus(
    String status,
  ) async {
    try {
      final response = await _apiService.get(
        '/provider/bookings/status/$status',
      );

      final List<dynamic> bookings =
          response['data'] ?? [];

      return bookings
          .map(
            (e) => BookingModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log(
        'Get Bookings By Status Error: $e',
      );
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
      final response = await _apiService.get(
        '/provider/bookings/search?keyword=$keyword',
      );

      final List<dynamic> bookings =
          response['data'] ?? [];

      return bookings
          .map(
            (e) => BookingModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Search Booking Error: $e');
      return [];
    }
  }

  // =========================
  // BOOKING ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getBookingAnalytics() async {
    try {
      return await _apiService.get(
        '/provider/bookings/analytics',
      );
    } catch (e) {
      log('Analytics Error: $e');
      rethrow;
    }
  }

  // =========================
  // BOOKING COUNT
  // =========================

  Future<int> getBookingCount() async {
    try {
      final response = await _apiService.get(
        '/provider/bookings/count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      log('Booking Count Error: $e');
      return 0;
    }
  }

  // =========================
  // PENDING COUNT
  // =========================

  Future<int> getPendingCount() async {
    try {
      final response = await _apiService.get(
        '/provider/bookings/pending-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // COMPLETED COUNT
  // =========================

  Future<int> getCompletedCount() async {
    try {
      final response = await _apiService.get(
        '/provider/bookings/completed-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}