import '../services/analytics_service.dart';

class AnalyticsRepository {
  final AnalyticsService _analyticsService;

  AnalyticsRepository({
    AnalyticsService? analyticsService,
  }) : _analyticsService =
            analyticsService ??
                AnalyticsService();

  // =====================================================
  // DASHBOARD ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getDashboardAnalytics({
    String range = 'monthly',
  }) async {
    try {
      return await _analyticsService
          .getDashboardAnalytics(
        range: range,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // OVERALL ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getAnalytics({
    String range = 'monthly',
  }) async {
    try {
      return await _analyticsService
          .getAnalytics(
        range: range,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REVENUE ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getRevenueAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String range = 'monthly',
  }) async {
    try {
      return await _analyticsService
          .getRevenueAnalytics(
        startDate: startDate,
        endDate: endDate,
        range: range,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BOOKING ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getBookingAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String range = 'monthly',
  }) async {
    try {
      return await _analyticsService
          .getBookingAnalytics(
        startDate: startDate,
        endDate: endDate,
        range: range,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ORDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getOrderAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String range = 'monthly',
  }) async {
    try {
      return await _analyticsService
          .getOrderAnalytics(
        startDate: startDate,
        endDate: endDate,
        range: range,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PAYMENT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getPaymentAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _analyticsService
          .getPaymentAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCustomerAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _analyticsService
          .getCustomerAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getProviderAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _analyticsService
          .getProviderAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SERVICE ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getServiceAnalytics({
    String? serviceId,
    String? categoryId,
  }) async {
    try {
      return await _analyticsService
          .getServiceAnalytics(
        serviceId: serviceId,
        categoryId: categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CATEGORY ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCategoryAnalytics() async {
    try {
      return await _analyticsService
          .getCategoryAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SETTLEMENT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getSettlementAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _analyticsService
          .getSettlementAnalytics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // COUPON ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCouponAnalytics() async {
    try {
      return await _analyticsService
          .getCouponAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REVIEW ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getReviewAnalytics() async {
    try {
      return await _analyticsService
          .getReviewAnalytics();
    } catch (e) {
      rethrow;
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
      return await _analyticsService
          .getTopProviders(
        limit: limit,
      );
    } catch (e) {
      rethrow;
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
      return await _analyticsService
          .getTopServices(
        limit: limit,
      );
    } catch (e) {
      rethrow;
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
      return await _analyticsService
          .getTopCategories(
        limit: limit,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GROWTH ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getGrowthAnalytics({
    String range = 'monthly',
  }) async {
    try {
      return await _analyticsService
          .getGrowthAnalytics(
        range: range,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REAL-TIME ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getRealtimeAnalytics() async {
    try {
      return await _analyticsService
          .getRealtimeAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // EXPORT ANALYTICS
  // =====================================================

  Future<String> exportAnalytics({
    required String reportType,
    required String format,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _analyticsService
          .exportAnalytics(
        reportType: reportType,
        format: format,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }
}