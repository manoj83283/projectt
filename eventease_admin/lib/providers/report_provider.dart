import 'package:flutter/foundation.dart';

import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService =
      ReportService();

  bool _isLoading = false;

  String? _errorMessage;

  List<ReportModel> _reports = [];

  ReportModel? _selectedReport;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalReports = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<ReportModel> get reports =>
      _reports;

  ReportModel? get selectedReport =>
      _selectedReport;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalReports => _totalReports;

  bool get hasReports =>
      _reports.isNotEmpty;

  List<ReportModel> get generatedReports =>
      _reports
          .where(
            (report) =>
                report.isGenerated,
          )
          .toList();

  List<ReportModel> get processingReports =>
      _reports
          .where(
            (report) =>
                report.isProcessing,
          )
          .toList();

  // =====================================================
  // GET REPORTS
  // =====================================================

  Future<void> getReports({
    int page = 1,
    int limit = 20,
    String? search,
    String? reportType,
    String? status,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _reportService.getReports(
        page: page,
        limit: limit,
        search: search,
        reportType: reportType,
        status: status,
      );

      _reports =
          (response['reports'] as List? ??
                  [])
              .map(
                (e) =>
                    ReportModel.fromJson(
                  e,
                ),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalReports =
          response['totalReports'] ??
              _reports.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET REPORT DETAILS
  // =====================================================

  Future<void> getReportDetails(
    String reportId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _reportService
              .getReportDetails(
        reportId,
      );

      _selectedReport =
          ReportModel.fromJson(
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
  // GENERATE REPORT
  // =====================================================

  Future<bool> generateReport({
    required String reportName,
    required String reportType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _reportService
              .generateReport(
        reportName: reportName,
        reportType: reportType,
        format: format,
        startDate: startDate,
        endDate: endDate,
        filters: filters,
      );

      final report =
          ReportModel.fromJson(
        response,
      );

      _reports.insert(0, report);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DOWNLOAD REPORT
  // =====================================================

  Future<String?> downloadReport(
    String reportId,
  ) async {
    try {
      _setLoading(true);

      final fileUrl =
          await _reportService
              .downloadReport(
        reportId,
      );

      return fileUrl;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // EXPORT REPORT
  // =====================================================

  Future<bool> exportReport({
    required String reportId,
    required String format,
  }) async {
    try {
      _setLoading(true);

      await _reportService.exportReport(
        reportId: reportId,
        format: format,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DELETE REPORT
  // =====================================================

  Future<bool> deleteReport(
    String reportId,
  ) async {
    try {
      _setLoading(true);

      await _reportService.deleteReport(
        reportId,
      );

      _reports.removeWhere(
        (e) => e.id == reportId,
      );

      if (_selectedReport?.id ==
          reportId) {
        _selectedReport = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEARCH REPORTS
  // =====================================================

  Future<void> searchReports(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _reportService
              .searchReports(
        keyword,
      );

      _reports =
          (response as List)
              .map(
                (e) =>
                    ReportModel.fromJson(
                  e,
                ),
              )
              .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH REPORTS
  // =====================================================

  Future<void> refreshReports() async {
    await getReports(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED REPORT
  // =====================================================

  void clearSelectedReport() {
    _selectedReport = null;
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