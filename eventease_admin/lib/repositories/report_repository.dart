import '../services/report_service.dart';

class ReportRepository {
  final ReportService _reportService;

  ReportRepository({
    ReportService? reportService,
  }) : _reportService =
            reportService ??
                ReportService();

  // =====================================================
  // GET REPORTS
  // =====================================================

  Future<Map<String, dynamic>> getReports({
    int page = 1,
    int limit = 20,
    String? search,
    String? reportType,
    String? status,
  }) async {
    try {
      return await _reportService.getReports(
        page: page,
        limit: limit,
        search: search,
        reportType: reportType,
        status: status,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GET REPORT DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getReportDetails(
    String reportId,
  ) async {
    try {
      return await _reportService
          .getReportDetails(
        reportId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH REPORTS
  // =====================================================

  Future<List<dynamic>> searchReports(
    String keyword,
  ) async {
    try {
      return await _reportService
          .searchReports(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GENERATE REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateReport({
    required String reportName,
    required String reportType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      return await _reportService
          .generateReport(
        reportName: reportName,
        reportType: reportType,
        format: format,
        startDate: startDate,
        endDate: endDate,
        filters: filters,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REVENUE REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
    String format = 'pdf',
  }) async {
    try {
      return await _reportService
          .generateRevenueReport(
        startDate: startDate,
        endDate: endDate,
        format: format,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // BOOKING REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateBookingReport({
    required DateTime startDate,
    required DateTime endDate,
    String format = 'pdf',
  }) async {
    try {
      return await _reportService
          .generateBookingReport(
        startDate: startDate,
        endDate: endDate,
        format: format,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ORDER REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateOrderReport({
    required DateTime startDate,
    required DateTime endDate,
    String format = 'pdf',
  }) async {
    try {
      return await _reportService
          .generateOrderReport(
        startDate: startDate,
        endDate: endDate,
        format: format,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // PROVIDER REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateProviderReport({
    required DateTime startDate,
    required DateTime endDate,
    String format = 'pdf',
  }) async {
    try {
      return await _reportService
          .generateProviderReport(
        startDate: startDate,
        endDate: endDate,
        format: format,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CUSTOMER REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateCustomerReport({
    required DateTime startDate,
    required DateTime endDate,
    String format = 'pdf',
  }) async {
    try {
      return await _reportService
          .generateCustomerReport(
        startDate: startDate,
        endDate: endDate,
        format: format,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SETTLEMENT REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateSettlementReport({
    required DateTime startDate,
    required DateTime endDate,
    String format = 'pdf',
  }) async {
    try {
      return await _reportService
          .generateSettlementReport(
        startDate: startDate,
        endDate: endDate,
        format: format,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ANALYTICS REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      generateAnalyticsReport({
    required DateTime startDate,
    required DateTime endDate,
    String format = 'pdf',
  }) async {
    try {
      return await _reportService
          .generateAnalyticsReport(
        startDate: startDate,
        endDate: endDate,
        format: format,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DOWNLOAD REPORT
  // =====================================================

  Future<String> downloadReport(
    String reportId,
  ) async {
    try {
      return await _reportService
          .downloadReport(
        reportId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // EXPORT REPORT
  // =====================================================

  Future<String> exportReport({
    required String reportId,
    required String format,
  }) async {
    try {
      return await _reportService
          .exportReport(
        reportId: reportId,
        format: format,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REPORT HISTORY
  // =====================================================

  Future<List<dynamic>>
      getReportHistory() async {
    try {
      return await _reportService
          .getReportHistory();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REPORT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getReportAnalytics() async {
    try {
      return await _reportService
          .getReportAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE REPORT
  // =====================================================

  Future<void> deleteReport(
    String reportId,
  ) async {
    try {
      await _reportService.deleteReport(
        reportId,
      );
    } catch (e) {
      rethrow;
    }
  }
}