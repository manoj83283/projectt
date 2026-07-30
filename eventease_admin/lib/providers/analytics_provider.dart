import 'package:flutter/foundation.dart';

import '../models/analytics_model.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService =
      AnalyticsService();

  bool _isLoading = false;

  String? _errorMessage;

  AnalyticsModel? _analytics;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  AnalyticsModel? get analytics =>
      _analytics;

  bool get hasAnalytics =>
      _analytics != null;

  // =====================================================
  // SUMMARY
  // =====================================================

  int get totalCustomers =>
      _analytics?.totalCustomers ?? 0;

  int get totalProviders =>
      _analytics?.totalProviders ?? 0;

  int get totalServices =>
      _analytics?.totalServices ?? 0;

  int get totalBookings =>
      _analytics?.totalBookings ?? 0;

  int get totalOrders =>
      _analytics?.totalOrders ?? 0;

  double get totalRevenue =>
      _analytics?.totalRevenue ?? 0;

  double get totalCommission =>
      _analytics?.totalCommission ?? 0;

  double get totalSettlements =>
      _analytics?.totalSettlements ?? 0;

  double get averageOrderValue =>
      _analytics?.averageOrderValue ?? 0;

  double get averageBookingValue =>
      _analytics?.averageBookingValue ?? 0;

  // =====================================================
  // TODAY STATS
  // =====================================================

  int get todayBookings =>
      _analytics?.todayBookings ?? 0;

  int get todayOrders =>
      _analytics?.todayOrders ?? 0;

  double get todayRevenue =>
      _analytics?.todayRevenue ?? 0;

  // =====================================================
  // MONTHLY STATS
  // =====================================================

  int get monthlyBookings =>
      _analytics?.monthlyBookings ?? 0;

  int get monthlyOrders =>
      _analytics?.monthlyOrders ?? 0;

  double get monthlyRevenue =>
      _analytics?.monthlyRevenue ?? 0;

  // =====================================================
  // GROWTH
  // =====================================================

  double get customerGrowthRate =>
      _analytics?.customerGrowthRate ?? 0;

  double get providerGrowthRate =>
      _analytics?.providerGrowthRate ?? 0;

  double get revenueGrowthRate =>
      _analytics?.revenueGrowthRate ?? 0;

  // =====================================================
  // CHARTS
  // =====================================================

  List<AnalyticsChartPoint>
      get revenueChart =>
          _analytics?.revenueChart ?? [];

  List<AnalyticsChartPoint>
      get bookingChart =>
          _analytics?.bookingChart ?? [];

  List<AnalyticsChartPoint>
      get orderChart =>
          _analytics?.orderChart ?? [];

  // =====================================================
  // TOP PERFORMERS
  // =====================================================

  List<TopPerformerModel>
      get topProviders =>
          _analytics?.topProviders ?? [];

  List<TopPerformerModel>
      get topServices =>
          _analytics?.topServices ?? [];

  List<TopPerformerModel>
      get topCategories =>
          _analytics?.topCategories ?? [];

  // =====================================================
  // LOAD ANALYTICS
  // =====================================================

  Future<void> getAnalytics({
    String range = 'monthly',
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _analyticsService
              .getAnalytics(
        range: range,
      );

      _analytics =
          AnalyticsModel.fromJson(
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
  // REVENUE ANALYTICS
  // =====================================================

  Future<void> getRevenueAnalytics({
    String range = 'monthly',
  }) async {
    try {
      _setLoading(true);

      final response =
          await _analyticsService
              .getRevenueAnalytics(
        range: range,
      );

      if (_analytics != null) {
        _analytics =
            AnalyticsModel.fromJson(
          response,
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
  // BOOKING ANALYTICS
  // =====================================================

  Future<void> getBookingAnalytics({
    String range = 'monthly',
  }) async {
    try {
      _setLoading(true);

      final response =
          await _analyticsService
              .getBookingAnalytics(
        range: range,
      );

      if (_analytics != null) {
        _analytics =
            AnalyticsModel.fromJson(
          response,
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
  // ORDER ANALYTICS
  // =====================================================

  Future<void> getOrderAnalytics({
    String range = 'monthly',
  }) async {
    try {
      _setLoading(true);

      final response =
          await _analyticsService
              .getOrderAnalytics(
        range: range,
      );

      if (_analytics != null) {
        _analytics =
            AnalyticsModel.fromJson(
          response,
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
  // PROVIDER ANALYTICS
  // =====================================================

  Future<void> getProviderAnalytics() async {
    try {
      _setLoading(true);

      final response =
          await _analyticsService
              .getProviderAnalytics();

      if (_analytics != null) {
        _analytics =
            AnalyticsModel.fromJson(
          response,
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
  // CUSTOMER ANALYTICS
  // =====================================================

  Future<void> getCustomerAnalytics() async {
    try {
      _setLoading(true);

      final response =
          await _analyticsService
              .getCustomerAnalytics();

      if (_analytics != null) {
        _analytics =
            AnalyticsModel.fromJson(
          response,
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
  // REFRESH ANALYTICS
  // =====================================================

  Future<void> refreshAnalytics() async {
    await getAnalytics();
  }

  // =====================================================
  // CLEAR DATA
  // =====================================================

  void clearAnalytics() {
    _analytics = null;
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
  // SET LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}