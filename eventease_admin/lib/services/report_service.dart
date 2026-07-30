import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class ReportService {
  ReportService._();

  static final ReportService _instance =
      ReportService._();

  factory ReportService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // DASHBOARD REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getDashboardReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/dashboard',
        query: {
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
  // REVENUE REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getRevenueReport({
    required String startDate,
    required String endDate,
    String groupBy = 'month',
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/revenue',
        query: {
          'startDate': startDate,
          'endDate': endDate,
          'groupBy': groupBy,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BOOKING REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getBookingReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/bookings',
        query: {
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
  // ORDER REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/orders',
        query: {
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
  // CUSTOMER REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getCustomerReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/customers',
        query: {
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
  // PROVIDER REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/providers',
        query: {
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
  // SERVICE REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getServiceReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/services',
        query: {
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
  // PAYMENT REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getPaymentReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/payments',
        query: {
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
  // SETTLEMENT REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getSettlementReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/settlements',
        query: {
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
  // COMMISSION REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getCommissionReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/commissions',
        query: {
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
  // COUPON REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getCouponReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/coupons',
        query: {
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
  // REVIEW REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getReviewReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.get(
        '/admin/reports/reviews',
        query: {
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
  // EXPORT REPORT
  // =====================================================

  Future<Response<dynamic>>
      exportReport({
    required String reportType,
    required String format,
    required String startDate,
    required String endDate,
  }) async {
    try {
      return await _api.get(
        '/admin/reports/export',
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
  // SCHEDULE REPORT
  // =====================================================

  Future<bool> scheduleReport({
    required String reportType,
    required String frequency,
    required String email,
  }) async {
    try {
      await _api.post(
        '/admin/reports/schedule',
        data: {
          'reportType': reportType,
          'frequency': frequency,
          'email': email,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CUSTOM REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateCustomReport({
    required List<String> modules,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _api.post(
        '/admin/reports/custom',
        data: {
          'modules': modules,
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
  // REPORT HISTORY
  // =====================================================

  Future<List<dynamic>>
      getReportHistory() async {
    try {
      final response = await _api.get(
        '/admin/reports/history',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE REPORT
  // =====================================================

  Future<bool> deleteReport(
    String reportId,
  ) async {
    try {
      await _api.delete(
        '/admin/reports/$reportId',
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