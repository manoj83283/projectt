import 'package:flutter/foundation.dart';

import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService =
      DashboardService();

  bool _isLoading = false;

  String? _errorMessage;

  DashboardModel? _dashboard;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  DashboardModel? get dashboard => _dashboard;

  DashboardSummary? get summary =>
      _dashboard?.summary;

  List<DashboardRevenuePoint>
      get revenueChart =>
          _dashboard?.revenueChart ?? [];

  List<DashboardRevenuePoint>
      get bookingChart =>
          _dashboard?.bookingChart ?? [];

  List<DashboardTopProvider>
      get topProviders =>
          _dashboard?.topProviders ?? [];

  List<DashboardTopService>
      get topServices =>
          _dashboard?.topServices ?? [];

  List<RecentBookingModel>
      get recentBookings =>
          _dashboard?.recentBookings ?? [];

  List<RecentOrderModel>
      get recentOrders =>
          _dashboard?.recentOrders ?? [];

  // =====================================================
  // DASHBOARD STATS
  // =====================================================

  int get totalCustomers =>
      summary?.totalCustomers ?? 0;

  int get totalProviders =>
      summary?.totalProviders ?? 0;

  int get totalServices =>
      summary?.totalServices ?? 0;

  int get totalBookings =>
      summary?.totalBookings ?? 0;

  int get totalOrders =>
      summary?.totalOrders ?? 0;

  int get pendingBookings =>
      summary?.pendingBookings ?? 0;

  int get pendingKyc =>
      summary?.pendingKyc ?? 0;

  double get totalRevenue =>
      summary?.totalRevenue ?? 0;

  double get totalCommission =>
      summary?.totalCommission ?? 0;

  double get monthlyRevenue =>
      summary?.monthlyRevenue ?? 0;

  double get todayRevenue =>
      summary?.todayRevenue ?? 0;

  int get activeProviders =>
      summary?.activeProviders ?? 0;

  int get activeCustomers =>
      summary?.activeCustomers ?? 0;

  bool get hasData =>
      _dashboard != null;

  // =====================================================
  // LOAD DASHBOARD
  // =====================================================

  Future<void> loadDashboard() async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _dashboardService
              .getDashboard();

      _dashboard =
          DashboardModel.fromJson(
        response,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH DASHBOARD
  // =====================================================

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  // =====================================================
  // LOAD REVENUE REPORT
  // =====================================================

  Future<void> loadRevenueChart({
    String range = 'monthly',
  }) async {
    try {
      _setLoading(true);

      final data =
          await _dashboardService
              .getRevenueChart(
        range: range,
      );

      if (_dashboard != null) {
        _dashboard = DashboardModel(
          summary: _dashboard!.summary,
          bookingChart:
              _dashboard!.bookingChart,
          topProviders:
              _dashboard!.topProviders,
          topServices:
              _dashboard!.topServices,
          recentBookings:
              _dashboard!.recentBookings,
          recentOrders:
              _dashboard!.recentOrders,
          generatedAt:
              _dashboard!.generatedAt,
          revenueChart:
              (data as List)
                  .map(
                    (e) =>
                        DashboardRevenuePoint
                            .fromJson(e),
                  )
                  .toList(),
        );
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // LOAD BOOKINGS CHART
  // =====================================================

  Future<void> loadBookingsChart({
    String range = 'monthly',
  }) async {
    try {
      _setLoading(true);

      final data =
          await _dashboardService
              .getBookingChart(
        range: range,
      );

      if (_dashboard != null) {
        _dashboard = DashboardModel(
          summary: _dashboard!.summary,
          revenueChart:
              _dashboard!.revenueChart,
          topProviders:
              _dashboard!.topProviders,
          topServices:
              _dashboard!.topServices,
          recentBookings:
              _dashboard!.recentBookings,
          recentOrders:
              _dashboard!.recentOrders,
          generatedAt:
              _dashboard!.generatedAt,
          bookingChart:
              (data as List)
                  .map(
                    (e) =>
                        DashboardRevenuePoint
                            .fromJson(e),
                  )
                  .toList(),
        );
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // RECENT BOOKINGS
  // =====================================================

  Future<void> loadRecentBookings() async {
    try {
      final response =
          await _dashboardService
              .getRecentBookings();

      if (_dashboard == null) return;

      _dashboard = DashboardModel(
        summary: _dashboard!.summary,
        revenueChart:
            _dashboard!.revenueChart,
        bookingChart:
            _dashboard!.bookingChart,
        topProviders:
            _dashboard!.topProviders,
        topServices:
            _dashboard!.topServices,
        recentOrders:
            _dashboard!.recentOrders,
        generatedAt:
            _dashboard!.generatedAt,
        recentBookings:
            (response)
                .map(
                  (e) =>
                      RecentBookingModel
                          .fromJson(e),
                )
                .toList(),
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // =====================================================
  // RECENT ORDERS
  // =====================================================

  Future<void> loadRecentOrders() async {
    try {
      final response =
          await _dashboardService
              .getRecentOrders();

      if (_dashboard == null) return;

      _dashboard = DashboardModel(
        summary: _dashboard!.summary,
        revenueChart:
            _dashboard!.revenueChart,
        bookingChart:
            _dashboard!.bookingChart,
        topProviders:
            _dashboard!.topProviders,
        topServices:
            _dashboard!.topServices,
        recentBookings:
            _dashboard!.recentBookings,
        generatedAt:
            _dashboard!.generatedAt,
        recentOrders:
            (response)
                .map(
                  (e) =>
                      RecentOrderModel
                          .fromJson(e),
                )
                .toList(),
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // =====================================================
  // CLEAR DATA
  // =====================================================

  void clearDashboard() {
    _dashboard = null;
    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =====================================================
  // LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}