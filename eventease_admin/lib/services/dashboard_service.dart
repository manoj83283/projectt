import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_service.dart';

class DashboardService {
  DashboardService._();

  static final DashboardService _instance =
      DashboardService._();

  factory DashboardService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // DASHBOARD OVERVIEW
  // =====================================================

  Future<Map<String, dynamic>>
      getDashboardOverview() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/overview',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // DASHBOARD STATS
  // =====================================================

  Future<Map<String, dynamic>>
      getDashboardStats() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/stats',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // REVENUE ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getRevenueAnalytics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/dashboard/revenue',
        query: {
          if (startDate != null)
            'startDate': startDate,
          if (endDate != null)
            'endDate': endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // BOOKING ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getBookingAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/bookings',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // ORDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/orders',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // USER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getUserAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/users',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // PROVIDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/providers',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // CATEGORY ANALYTICS
  // =====================================================

  Future<List<dynamic>>
      getCategoryAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/categories',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // TOP PROVIDERS
  // =====================================================

  Future<List<dynamic>>
      getTopProviders() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/top-providers',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // RECENT BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getRecentBookings() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/recent-bookings',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // RECENT ORDERS
  // =====================================================

  Future<List<dynamic>>
      getRecentOrders() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/recent-orders',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // RECENT ACTIVITIES
  // =====================================================

  Future<List<dynamic>>
      getRecentActivities() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/activities',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // MONTHLY GROWTH
  // =====================================================

  Future<Map<String, dynamic>>
      getGrowthAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/dashboard/growth',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // DATE RANGE REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getDateRangeReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/dashboard/report',
        query: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // EXPORT REPORT
  // =====================================================

  Future<Response<dynamic>>
      exportDashboardReport({
    required String format,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _api.get(
        '/admin/dashboard/export',
        query: {
          'format': format,
          'startDate': startDate,
          'endDate': endDate,
        },
      );
    } on DioException catch (e) {
      throw Exception(
        _parseError(e),
      );
    }
  }

  // =====================================================
  // ERROR PARSER
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