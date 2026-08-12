import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/report_model.dart';
import '../../providers/report_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({
    super.key,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedReportType;
  String? _selectedStatus;
  String? _selectedFormat;

  final List<String> _reportTypes = const [
    'revenue',
    'bookings',
    'orders',
    'payments',
    'settlements',
    'customers',
    'providers',
    'services',
    'reviews',
    'support',
    'complaints',
    'disputes',
    'coupons',
    'notifications',
  ];

  final List<String> _statuses = const [
    'generated',
    'processing',
    'failed',
    'scheduled',
    'expired',
  ];

  final List<String> _formats = const [
    'pdf',
    'excel',
    'csv',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReports();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchReports() async {
    await context.read<ReportProvider>().getReports(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          reportType: _selectedReportType,
          status: _selectedStatus,
          format: _selectedFormat,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchReports();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchReports();
      },
    );
  }

  void _onReportTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedReportType = value;
    });

    _fetchReports();
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchReports();
  }

  void _onFormatChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedFormat = value;
    });

    _fetchReports();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedReportType = null;
      _selectedStatus = null;
      _selectedFormat = null;
      _searchController.clear();
    });

    _fetchReports();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchReports();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchReports();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchReports();
  }

  Future<void> _generateReport() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return _GenerateReportDialog(
          reportTypes: _reportTypes,
          formats: _formats,
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      _fetchReports();
    }
  }

  Future<void> _viewReport(ReportModel report) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.padding24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.assessment_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Report Details',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ReportTypeBadge(
                        reportType: report.reportType,
                      ),
                      _ReportStatusBadge(
                        status: report.status,
                      ),
                      _ReportFormatBadge(
                        format: report.format,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _DetailRow(
                    label: 'Report ID',
                    value: report.id,
                  ),
                  _DetailRow(
                    label: 'Report Name',
                    value: report.title,
                  ),
                  _DetailRow(
                    label: 'Description',
                    value: report.description.trim().isEmpty
                        ? 'Not Available'
                        : report.description,
                  ),
                  _DetailRow(
                    label: 'Generated By',
                    value: report.generatedBy.trim().isEmpty
                        ? 'Admin'
                        : report.generatedBy,
                  ),
                  _DetailRow(
                    label: 'Date Range',
                    value:
                        '${_formatDate(report.startDate)} - ${_formatDate(report.endDate)}',
                  ),
                  _DetailRow(
                    label: 'Records',
                    value: report.totalRecords.toString(),
                  ),
                  _DetailRow(
                    label: 'File Size',
                    value: report.fileSize.trim().isEmpty
                        ? 'Not Available'
                        : report.fileSize,
                  ),
                  _DetailRow(
                    label: 'Download URL',
                    value: report.downloadUrl.trim().isEmpty
                        ? 'Not Available'
                        : report.downloadUrl,
                  ),
                  _DetailRow(
                    label: 'Created Date',
                    value: _formatDateTime(report.createdAt),
                  ),
                  _DetailRow(
                    label: 'Expiry Date',
                    value: _formatDateTime(report.expiresAt),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadReport(ReportModel report) async {
    if (report.downloadUrl.trim().isEmpty) {
      NavigationService.showWarning(
        'Report download URL is not available',
      );
      return;
    }

    final bool success = await context.read<ReportProvider>().downloadReport(
          reportId: report.id,
          downloadUrl: report.downloadUrl,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Report download started successfully',
      errorMessage: 'Failed to download report',
      shouldRefresh: false,
    );
  }

  Future<void> _regenerateReport(ReportModel report) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Regenerate Report',
      message: 'Are you sure you want to regenerate "${report.title}"?',
      confirmText: 'Regenerate',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success = await context.read<ReportProvider>().regenerateReport(
          report.id,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Report regeneration started successfully',
      errorMessage: 'Failed to regenerate report',
    );
  }

  Future<void> _deleteReport(ReportModel report) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Report',
      message:
          'This action cannot be undone. Are you sure you want to delete "${report.title}"?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success = await context.read<ReportProvider>().deleteReport(
          report.id,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Report deleted successfully',
      errorMessage: 'Failed to delete report',
    );
  }

  Future<void> _exportReportsList() async {
    await context.read<ReportProvider>().exportReportsList();

    if (!mounted) return;

    NavigationService.showSuccess(
      'Reports list export started successfully',
    );
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _handleMutationResult({
    required bool success,
    required String successMessage,
    required String errorMessage,
    bool shouldRefresh = true,
  }) {
    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(successMessage);

      if (shouldRefresh) {
        _fetchReports();
      }

      return;
    }

    NavigationService.showError(
      context.read<ReportProvider>().errorMessage ?? errorMessage,
    );
  }

  Widget _buildHeader(ReportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Reports',
          subtitle:
              'Generate, download, regenerate and manage operational, financial, customer, provider and marketplace reports.',
          actions: [
            CustomButton(
              text: 'Export List',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: provider.isLoading ? null : _exportReportsList,
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: 'Refresh',
              type: ButtonType.outline,
              icon: Icons.refresh,
              onPressed: provider.isLoading ? null : _refresh,
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: 'Generate Report',
              icon: Icons.add_chart_outlined,
              onPressed: provider.isLoading ? null : _generateReport,
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isTablet = constraints.maxWidth < 1100;
            final bool isMobile = constraints.maxWidth < 650;

            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile
                    ? 1
                    : isTablet
                        ? 2
                        : 6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile
                    ? 3.6
                    : isTablet
                        ? 2.15
                        : 1.45,
              ),
              children: [
                _ReportSummaryCard(
                  title: 'Total Reports',
                  value: provider.totalReports.toString(),
                  icon: Icons.assessment_outlined,
                  color: AppColors.primary,
                ),
                _ReportSummaryCard(
                  title: 'Generated',
                  value: provider.generatedReports.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _ReportSummaryCard(
                  title: 'Processing',
                  value: provider.processingReports.toString(),
                  icon: Icons.sync_outlined,
                  color: AppColors.info,
                ),
                _ReportSummaryCard(
                  title: 'Scheduled',
                  value: provider.scheduledReports.toString(),
                  icon: Icons.schedule_outlined,
                  color: Colors.purple,
                ),
                _ReportSummaryCard(
                  title: 'Failed',
                  value: provider.failedReports.toString(),
                  icon: Icons.error_outline,
                  color: AppColors.error,
                ),
                _ReportSummaryCard(
                  title: 'Downloads',
                  value: provider.totalDownloads.toString(),
                  icon: Icons.file_download_outlined,
                  color: Colors.orange,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters(ReportProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(AppDimensions.padding20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Search report title, type, generated by...',
            onChanged: _onSearch,
            onClear: _clearFilters,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 1000;

              if (isCompact) {
                return Column(
                  children: [
                    _buildReportTypeDropdown(),
                    const SizedBox(height: 14),
                    _buildStatusDropdown(),
                    const SizedBox(height: 14),
                    _buildFormatDropdown(),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: provider.isLoading ? null : _clearFilters,
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Clear Filters'),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildReportTypeDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildFormatDropdown()),
                  const SizedBox(width: 14),
                  TextButton.icon(
                    onPressed: provider.isLoading ? null : _clearFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Clear'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Report Type',
      value: _selectedReportType,
      items: _reportTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onReportTypeChanged,
    );
  }

  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Status',
      value: _selectedStatus,
      items: _statuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
    );
  }

  Widget _buildFormatDropdown() {
    return CustomDropdown<String>(
      labelText: 'Format',
      value: _selectedFormat,
      items: _formats,
      itemLabelBuilder: (value) => value.toUpperCase(),
      onChanged: _onFormatChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (
        context,
        provider,
        child,
      ) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppDimensions.padding24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(provider),
                  _buildFilters(provider),
                  if (provider.errorMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ReportsTable(
                    reports: provider.reports,
                    isLoading: provider.isLoading,
                    onView: _viewReport,
                    onDownload: _downloadReport,
                    onRegenerate: _regenerateReport,
                    onDelete: _deleteReport,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalReports,
                    pageSize: _limit,
                    onPrevious: _previousPage,
                    onNext: () {
                      _nextPage(
                        provider.totalPages,
                      );
                    },
                    onPageSelected: _goToPage,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';

    return AppFormatters.formatDate(dateTime);
  }

  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';

    return AppFormatters.formatDateTime(dateTime);
  }
}

class ReportsTable extends StatelessWidget {
  final List<ReportModel> reports;
  final bool isLoading;
  final ValueChanged<ReportModel> onView;
  final ValueChanged<ReportModel> onDownload;
  final ValueChanged<ReportModel> onRegenerate;
  final ValueChanged<ReportModel> onDelete;

  const ReportsTable({
    super.key,
    required this.reports,
    required this.isLoading,
    required this.onView,
    required this.onDownload,
    required this.onRegenerate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const _TableHeader(),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(44),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (reports.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No reports found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Generated reports matching your filters will appear here.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 72,
                dataRowMaxHeight: 88,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Report')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Format')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Records')),
                  DataColumn(label: Text('File Size')),
                  DataColumn(label: Text('Generated By')),
                  DataColumn(label: Text('Created Date')),
                  DataColumn(label: Text('Expires')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: reports.map(
                  (report) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _ReportInfoCell(
                            report: report,
                          ),
                        ),
                        DataCell(
                          _ReportTypeBadge(
                            reportType: report.reportType,
                          ),
                        ),
                        DataCell(
                          _ReportFormatBadge(
                            format: report.format,
                          ),
                        ),
                        DataCell(
                          _ReportStatusBadge(
                            status: report.status,
                          ),
                        ),
                        DataCell(
                          Text(
                            report.totalRecords.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            report.fileSize.trim().isEmpty
                                ? 'N/A'
                                : report.fileSize,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              report.generatedBy.trim().isEmpty
                                  ? 'Admin'
                                  : report.generatedBy,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _ReportsScreenState._formatDateTime(
                              report.createdAt,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _ReportsScreenState._formatDateTime(
                              report.expiresAt,
                            ),
                          ),
                        ),
                        DataCell(
                          _ReportActions(
                            report: report,
                            onView: onView,
                            onDownload: onDownload,
                            onRegenerate: onRegenerate,
                            onDelete: onDelete,
                          ),
                        ),
                      ],
                    );
                  },
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _GenerateReportDialog extends StatefulWidget {
  final List<String> reportTypes;
  final List<String> formats;

  const _GenerateReportDialog({
    required this.reportTypes,
    required this.formats,
  });

  @override
  State<_GenerateReportDialog> createState() => _GenerateReportDialogState();
}

class _GenerateReportDialogState extends State<_GenerateReportDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _reportType;
  String? _format;

  DateTime? _startDate;
  DateTime? _endDate;

  bool _isSubmitting = false;
  bool _scheduleReport = false;

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();

    _reportType = 'revenue';
    _format = 'excel';
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
    _titleController.text = 'Monthly Revenue Report';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select Start Date',
    );

    if (selected == null) return;

    setState(() {
      _startDate = selected;

      if (_endDate != null && _endDate!.isBefore(selected)) {
        _endDate = selected;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: _startDate ?? DateTime(2020),
      lastDate: now,
      helpText: 'Select End Date',
    );

    if (selected == null) return;

    setState(() {
      _endDate = selected;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_reportType == null) {
      NavigationService.showWarning('Please select report type');
      return;
    }

    if (_format == null) {
      NavigationService.showWarning('Please select report format');
      return;
    }

    if (_startDate == null || _endDate == null) {
      NavigationService.showWarning('Please select report date range');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final bool success = await context.read<ReportProvider>().generateReport(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          reportType: _reportType!,
          format: _format!,
          startDate: _startDate!,
          endDate: _endDate!,
          scheduleReport: _scheduleReport,
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      NavigationService.showSuccess(
        _scheduleReport
            ? 'Report scheduled successfully'
            : 'Report generation started successfully',
      );

      Navigator.pop(context, true);
      return;
    }

    NavigationService.showError(
      context.read<ReportProvider>().errorMessage ??
          'Failed to generate report',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760,
          maxHeight: 820,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.padding24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.add_chart_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Generate Report',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Report Title',
                    hintText: 'Example: Monthly Revenue Report',
                    prefixIcon: Icon(Icons.title_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Report title is required';
                    }

                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional report description',
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 650;

                    if (isCompact) {
                      return Column(
                        children: [
                          _buildReportTypeDropdown(),
                          const SizedBox(height: 16),
                          _buildFormatDropdown(),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: _buildReportTypeDropdown()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFormatDropdown()),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isCompact = constraints.maxWidth < 650;

                    if (isCompact) {
                      return Column(
                        children: [
                          _DialogDateTile(
                            title: 'Start Date',
                            value: _startDate,
                            onTap: _pickStartDate,
                          ),
                          const SizedBox(height: 16),
                          _DialogDateTile(
                            title: 'End Date',
                            value: _endDate,
                            onTap: _pickEndDate,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _DialogDateTile(
                            title: 'Start Date',
                            value: _startDate,
                            onTap: _pickStartDate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _DialogDateTile(
                            title: 'End Date',
                            value: _endDate,
                            onTap: _pickEndDate,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _scheduleReport,
                  activeThumbColor: AppColors.primary,
                  title: const Text(
                    'Schedule Report',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    _scheduleReport
                        ? 'Report will be generated as a scheduled job'
                        : 'Report will be generated immediately',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  secondary: Icon(
                    _scheduleReport
                        ? Icons.schedule_outlined
                        : Icons.flash_on_outlined,
                    color:
                        _scheduleReport ? AppColors.primary : AppColors.success,
                  ),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _scheduleReport = value;
                          });
                        },
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        type: ButtonType.outline,
                        icon: Icons.close,
                        onPressed:
                            _isSubmitting ? null : () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text:
                            _scheduleReport ? 'Schedule Report' : 'Generate',
                        icon: _scheduleReport
                            ? Icons.schedule_outlined
                            : Icons.add_chart_outlined,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Report Type',
      value: _reportType,
      items: widget.reportTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: (value) {
        setState(() {
          _reportType = value;

          if (value != null) {
            _titleController.text =
                '${AppFormatters.formatStatus(value)} Report';
          }
        });
      },
    );
  }

  Widget _buildFormatDropdown() {
    return CustomDropdown<String>(
      labelText: 'Format',
      value: _format,
      items: widget.formats,
      itemLabelBuilder: (value) => value.toUpperCase(),
      onChanged: (value) {
        setState(() {
          _format = value;
        });
      },
    );
  }
}

class _ReportInfoCell extends StatelessWidget {
  final ReportModel report;

  const _ReportInfoCell({
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: _formatColor.withValues(alpha: 0.1),
            child: Icon(
              _formatIcon,
              color: _formatColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.description.trim().isEmpty
                      ? 'No description available'
                      : report.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _formatColor {
    switch (report.format) {
      case 'pdf':
        return AppColors.error;
      case 'excel':
        return AppColors.success;
      case 'csv':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData get _formatIcon {
    switch (report.format) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'excel':
        return Icons.table_chart_outlined;
      case 'csv':
        return Icons.description_outlined;
      default:
        return Icons.assessment_outlined;
    }
  }
}

class _ReportActions extends StatelessWidget {
  final ReportModel report;
  final ValueChanged<ReportModel> onView;
  final ValueChanged<ReportModel> onDownload;
  final ValueChanged<ReportModel> onRegenerate;
  final ValueChanged<ReportModel> onDelete;

  const _ReportActions({
    required this.report,
    required this.onView,
    required this.onDownload,
    required this.onRegenerate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canDownload = report.status == 'generated' &&
        report.downloadUrl.trim().isNotEmpty;

    final bool canRegenerate = report.status == 'failed' ||
        report.status == 'expired' ||
        report.status == 'generated';

    return PopupMenuButton<String>(
      tooltip: 'Report Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(report);
            break;
          case 'download':
            onDownload(report);
            break;
          case 'regenerate':
            onRegenerate(report);
            break;
          case 'delete':
            onDelete(report);
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: _MenuItem(
            icon: Icons.visibility_outlined,
            label: 'View Details',
          ),
        ),
        PopupMenuItem(
          value: 'download',
          enabled: canDownload,
          child: _MenuItem(
            icon: Icons.file_download_outlined,
            label: 'Download',
            color: canDownload ? AppColors.success : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'regenerate',
          enabled: canRegenerate,
          child: _MenuItem(
            icon: Icons.refresh_outlined,
            label: 'Regenerate',
            color: canRegenerate ? AppColors.primary : Colors.grey,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: _MenuItem(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: AppColors.error,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.more_vert,
          size: 20,
        ),
      ),
    );
  }
}

class _DialogDateTile extends StatelessWidget {
  final String title;
  final DateTime? value;
  final VoidCallback onTap;

  const _DialogDateTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radius12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
        ),
        child: Text(
          value == null ? 'Select date' : AppFormatters.formatDate(value!),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: value == null ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _ReportSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.padding18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTypeBadge extends StatelessWidget {
  final String reportType;

  const _ReportTypeBadge({
    required this.reportType,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (reportType) {
      case 'revenue':
      case 'payments':
      case 'settlements':
        color = AppColors.success;
        break;
      case 'bookings':
      case 'orders':
      case 'services':
        color = AppColors.primary;
        break;
      case 'customers':
      case 'providers':
        color = AppColors.info;
        break;
      case 'complaints':
      case 'disputes':
        color = AppColors.error;
        break;
      case 'support':
      case 'reviews':
        color = AppColors.warning;
        break;
      case 'coupons':
      case 'notifications':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(reportType),
      color: color,
    );
  }
}

class _ReportFormatBadge extends StatelessWidget {
  final String format;

  const _ReportFormatBadge({
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (format) {
      case 'pdf':
        color = AppColors.error;
        break;
      case 'excel':
        color = AppColors.success;
        break;
      case 'csv':
        color = AppColors.info;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: format.toUpperCase(),
      color: color,
    );
  }
}

class _ReportStatusBadge extends StatelessWidget {
  final String status;

  const _ReportStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'generated':
        color = AppColors.success;
        break;
      case 'processing':
        color = AppColors.info;
        break;
      case 'scheduled':
        color = Colors.purple;
        break;
      case 'failed':
        color = AppColors.error;
        break;
      case 'expired':
        color = Colors.blueGrey;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(status),
      color: color,
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padding20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.assessment_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Report Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Generated files and reporting history',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? Colors.black87;

    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: effectiveColor,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: effectiveColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}