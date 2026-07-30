import '../services/dashboard_service.dart';

class DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository({
    DashboardService? dashboardService,
  }) : _dashboardService =
            dashboardService ??
                DashboardService();

  // =====================================================
  // DASHBOARD DATA
  // =====================================================

  Future<Map<String, dynamic>>
      getDashboard() async {
    try {
      return await _dashboardService
          .getDashboard();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DASHBOARD SUMMARY
  // =====================================================

  Future<Map<String, dynamic>>
      getDashboardSummary() async {
    try {
      return await _dashboardService
          .getDashboardSummary();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REVENUE CHART
  // =====================================================

  Future<List<dynamic>> getRevenueChart({
    String range = 'monthly',
  }) async {
    try {
      return await _dashboardService
          .getRevenueChart(
        range: range,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BOOKING CHART
  // =====================================================

  Future<List<dynamic>> getBookingChart({
    String range = 'monthly',
  }) async {
    try {
      return await _dashboardService
          .getBookingChart(
        range: range,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ORDER CHART
  // =====================================================

  Future<List<dynamic>> getOrderChart({
    String range = 'monthly',
  }) async {
    try {
      return await _dashboardService
          .getOrderChart(
        range: range,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // RECENT BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getRecentBookings() async {
    try {
      return await _dashboardService
          .getRecentBookings();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // RECENT ORDERS
  // =====================================================

  Future<List<dynamic>>
      getRecentOrders() async {
    try {
      return await _dashboardService
          .getRecentOrders();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // TOP PROVIDERS
  // =====================================================

  Future<List<dynamic>>
      getTopProviders() async {
    try {
      return await _dashboardService
          .getTopProviders();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // TOP SERVICES
  // =====================================================

  Future<List<dynamic>>
      getTopServices() async {
    try {
      return await _dashboardService
          .getTopServices();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // TOP CATEGORIES
  // =====================================================

  Future<List<dynamic>>
      getTopCategories() async {
    try {
      return await _dashboardService
          .getTopCategories();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // TODAY STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getTodayStatistics() async {
    try {
      return await _dashboardService
          .getTodayStatistics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // MONTHLY STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getMonthlyStatistics() async {
    try {
      return await _dashboardService
          .getMonthlyStatistics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SYSTEM HEALTH
  // =====================================================

  Future<Map<String, dynamic>>
      getSystemHealth() async {
    try {
      return await _dashboardService
          .getSystemHealth();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PLATFORM ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getPlatformAnalytics() async {
    try {
      return await _dashboardService
          .getPlatformAnalytics();
    } catch (e) {
      rethrow;
    }
  }
}