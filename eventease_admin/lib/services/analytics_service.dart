import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService _instance =
      AnalyticsService._();

  factory AnalyticsService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // DASHBOARD ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getDashboardAnalytics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/analytics/dashboard',
        query: {
          'startDate': ?startDate,
          'endDate': ?endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REVENUE ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getRevenueAnalytics({
    String? startDate,
    String? endDate,
    String groupBy = 'month',
  }) async {
    try {
      final response = await _api.get(
        '/admin/analytics/revenue',
        query: {
          'groupBy': groupBy,
          'startDate': ?startDate,
          'endDate': ?endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BOOKING ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getBookingAnalytics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/analytics/bookings',
        query: {
          'startDate': ?startDate,
          'endDate': ?endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ORDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderAnalytics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/analytics/orders',
        query: {
          'startDate': ?startDate,
          'endDate': ?endDate,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CUSTOMER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCustomerAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/analytics/customers',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // PROVIDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/analytics/providers',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CATEGORY ANALYTICS
  // =====================================================

  Future<List<dynamic>>
      getCategoryAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/analytics/categories',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SERVICE ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getServiceAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/analytics/services',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // PAYMENT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getPaymentAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/analytics/payments',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SETTLEMENT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getSettlementAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/analytics/settlements',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GEOGRAPHIC ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getLocationAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/analytics/locations',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // TOP PROVIDERS
  // =====================================================

  Future<List<dynamic>>
      getTopProviders({
    int limit = 10,
  }) async {
    try {
      final response = await _api.get(
        '/admin/analytics/top-providers',
        query: {
          'limit': limit,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // TOP SERVICES
  // =====================================================

  Future<List<dynamic>>
      getTopServices({
    int limit = 10,
  }) async {
    try {
      final response = await _api.get(
        '/admin/analytics/top-services',
        query: {
          'limit': limit,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // TOP CATEGORIES
  // =====================================================

  Future<List<dynamic>>
      getTopCategories({
    int limit = 10,
  }) async {
    try {
      final response = await _api.get(
        '/admin/analytics/top-categories',
        query: {
          'limit': limit,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GROWTH ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getGrowthAnalytics({
    String period = 'yearly',
  }) async {
    try {
      final response = await _api.get(
        '/admin/analytics/growth',
        query: {
          'period': period,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // USER RETENTION ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getRetentionAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/analytics/retention',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CONVERSION ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getConversionAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/analytics/conversion',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT ANALYTICS REPORT
  // =====================================================

  Future<Response<dynamic>>
      exportAnalyticsReport({
    required String reportType,
    String format = 'excel',
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _api.get(
        '/admin/analytics/export',
        query: {
          'reportType': reportType,
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
  // CUSTOM REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateCustomReport({
    required List<String> metrics,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.post(
        '/admin/analytics/custom-report',
        data: {
          'metrics': metrics,
          'startDate': startDate,
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