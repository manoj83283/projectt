import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/activity_log_model.dart';
import '../../providers/audit_log_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({
    super.key,
  });

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedAction;
  String? _selectedModule;
  String? _selectedSeverity;
  String? _selectedActorRole;

  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _actions = const [
    'create',
    'update',
    'delete',
    'login',
    'logout',
    'view',
    'export',
    'import',
    'approve',
    'reject',
    'assign',
    'resolve',
    'close',
    'sync',
    'backup',
  ];

  final List<String> _modules = const [
    'auth',
    'dashboard',
    'customers',
    'providers',
    'services',
    'bookings',
    'orders',
    'payments',
    'settlements',
    'coupons',
    'notifications',
    'reviews',
    'support',
    'complaints',
    'disputes',
    'cms',
    'reports',
    'analytics',
    'settings',
  ];

  final List<String> _severities = const [
    'low',
    'medium',
    'high',
    'critical',
  ];

  final List<String> _actorRoles = const [
    'super_admin',
    'admin',
    'manager',
    'support',
    'finance',
    'operations',
    'system',
  ];

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActivityLogs();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivityLogs() async {
    await context.read<AuditLogProvider>().getActivityLogs(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          action: _selectedAction,
          module: _selectedModule,
          severity: _selectedSeverity,
          actorRole: _selectedActorRole,
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchActivityLogs();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchActivityLogs();
      },
    );
  }

  void _onActionChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedAction = value;
    });

    _fetchActivityLogs();
  }

  void _onModuleChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedModule = value;
    });

    _fetchActivityLogs();
  }

  void _onSeverityChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedSeverity = value;
    });

    _fetchActivityLogs();
  }

  void _onActorRoleChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedActorRole = value;
    });

    _fetchActivityLogs();
  }

  Future<void> _pickStartDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select Start Date',
    );

    if (selectedDate == null) return;

    setState(() {
      _page = 1;
      _startDate = selectedDate;

      if (_endDate != null && _endDate!.isBefore(selectedDate)) {
        _endDate = selectedDate;
      }
    });

    _fetchActivityLogs();
  }

  Future<void> _pickEndDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: _startDate ?? DateTime(2020),
      lastDate: now,
      helpText: 'Select End Date',
    );

    if (selectedDate == null) return;

    setState(() {
      _page = 1;
      _endDate = selectedDate;
    });

    _fetchActivityLogs();
  }

  void _clearFilters() {
    final DateTime now = DateTime.now();

    setState(() {
      _page = 1;
      _selectedAction = null;
      _selectedModule = null;
      _selectedSeverity = null;
      _selectedActorRole = null;
      _searchController.clear();
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = now;
    });

    _fetchActivityLogs();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchActivityLogs();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchActivityLogs();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchActivityLogs();
  }

  Future<void> _viewLog(ActivityLogModel log) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 780,
              maxHeight: 780,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.padding20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _severityColor(log.severity)
                            .withValues(alpha: 0.1),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: _severityColor(log.severity),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Activity Log Details',
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
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.padding24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _ActionBadge(action: log.action),
                            _ModuleBadge(module: log.module),
                            _SeverityBadge(severity: log.severity),
                            _StatusChip(
                              label: AppFormatters.formatStatus(log.actorRole),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          log.title.trim().isEmpty
                              ? 'Activity Log'
                              : log.title,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          log.description.trim().isEmpty
                              ? 'No description available.'
                              : log.description,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey.shade800,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 22),
                        _DetailRow(label: 'Log ID', value: _empty(log.id)),
                        _DetailRow(
                          label: 'Actor ID',
                          value: _empty(log.actorId),
                        ),
                        _DetailRow(
                          label: 'Actor Name',
                          value: _empty(log.actorName),
                        ),
                        _DetailRow(
                          label: 'Actor Email',
                          value: _empty(log.actorEmail),
                        ),
                        _DetailRow(
                          label: 'Actor Role',
                          value: AppFormatters.formatStatus(log.actorRole),
                        ),
                        _DetailRow(
                          label: 'Module',
                          value: AppFormatters.formatStatus(log.module),
                        ),
                        _DetailRow(
                          label: 'Action',
                          value: AppFormatters.formatStatus(log.action),
                        ),
                        _DetailRow(
                          label: 'Entity Type',
                          value: AppFormatters.formatStatus(log.entityType),
                        ),
                        _DetailRow(
                          label: 'Entity ID',
                          value: _empty(log.entityId),
                        ),
                        _DetailRow(
                          label: 'IP Address',
                          value: _empty(log.ipAddress),
                        ),
                        _DetailRow(
                          label: 'Device',
                          value: _empty(log.device),
                        ),
                        _DetailRow(
                          label: 'Platform',
                          value: _empty(log.platform),
                        ),
                        _DetailRow(
                          label: 'Location',
                          value: _empty(log.location),
                        ),
                        _DetailRow(
                          label: 'Created Date',
                          value: _formatDateTime(log.createdAt),
                        ),
                        if (log.metadata.trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _MetadataBox(metadata: log.metadata),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportLogs() async {
    await context.read<AuditLogProvider>().exportActivityLogs(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          action: _selectedAction,
          module: _selectedModule,
          severity: _selectedSeverity,
          actorRole: _selectedActorRole,
          startDate: _startDate,
          endDate: _endDate,
        );

    if (!mounted) return;

    NavigationService.showSuccess(
      'Activity logs export started successfully',
    );
  }

  Widget _buildHeader(AuditLogProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Activity Logs',
          subtitle:
              'Track admin actions, system events, security activity, exports, approvals, deletes and configuration changes.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: provider.isLoading ? null : _exportLogs,
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: 'Refresh',
              type: ButtonType.outline,
              icon: Icons.refresh,
              onPressed: provider.isLoading ? null : _refresh,
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
                        : 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile
                    ? 3.6
                    : isTablet
                        ? 2.15
                        : 1.55,
              ),
              children: [
                _AuditSummaryCard(
                  title: 'Total Logs',
                  value: provider.totalActivityLogs.toString(),
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.primary,
                ),
                _AuditSummaryCard(
                  title: 'Today',
                  value: provider.todayActivityLogs.toString(),
                  icon: Icons.today_outlined,
                  color: AppColors.info,
                ),
                _AuditSummaryCard(
                  title: 'High Severity',
                  value: provider.highSeverityLogs.toString(),
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.warning,
                ),
                _AuditSummaryCard(
                  title: 'Critical',
                  value: provider.criticalLogs.toString(),
                  icon: Icons.error_outline,
                  color: AppColors.error,
                ),
                _AuditSummaryCard(
                  title: 'Exports',
                  value: provider.exportLogs.toString(),
                  icon: Icons.file_download_outlined,
                  color: Colors.purple,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters(AuditLogProvider provider) {
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
            hintText:
                'Search actor, email, action, module, entity, IP address...',
            onChanged: _onSearch,
            onClear: _clearFilters,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 1050;

              if (isCompact) {
                return Column(
                  children: [
                    _buildActionDropdown(),
                    const SizedBox(height: 14),
                    _buildModuleDropdown(),
                    const SizedBox(height: 14),
                    _buildSeverityDropdown(),
                    const SizedBox(height: 14),
                    _buildActorRoleDropdown(),
                    const SizedBox(height: 14),
                    _DateFilterTile(
                      title: 'Start Date',
                      value: _startDate,
                      onTap: _pickStartDate,
                    ),
                    const SizedBox(height: 14),
                    _DateFilterTile(
                      title: 'End Date',
                      value: _endDate,
                      onTap: _pickEndDate,
                    ),
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

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildActionDropdown()),
                      const SizedBox(width: 14),
                      Expanded(child: _buildModuleDropdown()),
                      const SizedBox(width: 14),
                      Expanded(child: _buildSeverityDropdown()),
                      const SizedBox(width: 14),
                      Expanded(child: _buildActorRoleDropdown()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _DateFilterTile(
                          title: 'Start Date',
                          value: _startDate,
                          onTap: _pickStartDate,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _DateFilterTile(
                          title: 'End Date',
                          value: _endDate,
                          onTap: _pickEndDate,
                        ),
                      ),
                      const SizedBox(width: 14),
                      TextButton.icon(
                        onPressed: provider.isLoading ? null : _clearFilters,
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionDropdown() {
    return CustomDropdown<String>(
      labelText: 'Action',
      value: _selectedAction,
      items: _actions,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onActionChanged,
    );
  }

  Widget _buildModuleDropdown() {
    return CustomDropdown<String>(
      labelText: 'Module',
      value: _selectedModule,
      items: _modules,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onModuleChanged,
    );
  }

  Widget _buildSeverityDropdown() {
    return CustomDropdown<String>(
      labelText: 'Severity',
      value: _selectedSeverity,
      items: _severities,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onSeverityChanged,
    );
  }

  Widget _buildActorRoleDropdown() {
    return CustomDropdown<String>(
      labelText: 'Actor Role',
      value: _selectedActorRole,
      items: _actorRoles,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onActorRoleChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuditLogProvider>(
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
                  ActivityLogsTable(
                    logs: provider.activityLogs,
                    isLoading: provider.isLoading,
                    onView: _viewLog,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalActivityLogs,
                    pageSize: _limit,
                    onPrevious: _previousPage,
                    onNext: () => _nextPage(provider.totalPages),
                    onPageSelected: _goToPage,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _empty(String value) {
    return value.trim().isEmpty ? 'Not Available' : value.trim();
  }

  static String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';

    return AppFormatters.formatDateTime(dateTime);
  }

  static Color _severityColor(String severity) {
    switch (severity) {
      case 'low':
        return AppColors.success;
      case 'medium':
        return AppColors.info;
      case 'high':
        return AppColors.warning;
      case 'critical':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
}

class ActivityLogsTable extends StatelessWidget {
  final List<ActivityLogModel> logs;
  final bool isLoading;
  final ValueChanged<ActivityLogModel> onView;

  const ActivityLogsTable({
    super.key,
    required this.logs,
    required this.isLoading,
    required this.onView,
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
          else if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No activity logs found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Audit activity matching your filters will appear here.',
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
                dataRowMinHeight: 76,
                dataRowMaxHeight: 96,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Activity')),
                  DataColumn(label: Text('Actor')),
                  DataColumn(label: Text('Action')),
                  DataColumn(label: Text('Module')),
                  DataColumn(label: Text('Severity')),
                  DataColumn(label: Text('Entity')),
                  DataColumn(label: Text('IP Address')),
                  DataColumn(label: Text('Platform')),
                  DataColumn(label: Text('Created Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: logs.map(
                  (log) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _ActivityInfoCell(log: log),
                        ),
                        DataCell(
                          _ActorCell(log: log),
                        ),
                        DataCell(
                          _ActionBadge(action: log.action),
                        ),
                        DataCell(
                          _ModuleBadge(module: log.module),
                        ),
                        DataCell(
                          _SeverityBadge(severity: log.severity),
                        ),
                        DataCell(
                          _EntityCell(log: log),
                        ),
                        DataCell(
                          SizedBox(
                            width: 130,
                            child: Text(
                              log.ipAddress.trim().isEmpty
                                  ? 'N/A'
                                  : log.ipAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          _StatusChip(
                            label: AppFormatters.formatStatus(log.platform),
                            color: Colors.blueGrey,
                          ),
                        ),
                        DataCell(
                          Text(
                            _ActivityLogsScreenState._formatDateTime(
                              log.createdAt,
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            tooltip: 'View Activity Log',
                            onPressed: () => onView(log),
                            icon: const Icon(
                              Icons.visibility_outlined,
                              color: AppColors.primary,
                            ),
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

class _ActivityInfoCell extends StatelessWidget {
  final ActivityLogModel log;

  const _ActivityInfoCell({
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _ActivityLogsScreenState._severityColor(log.severity);

    return SizedBox(
      width: 320,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(
              _actionIcon(log.action),
              color: color,
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
                  log.title.trim().isEmpty ? 'Activity Log' : log.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.description.trim().isEmpty
                      ? log.id
                      : log.description,
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

  IconData _actionIcon(String action) {
    switch (action) {
      case 'create':
        return Icons.add_circle_outline;
      case 'update':
        return Icons.edit_outlined;
      case 'delete':
        return Icons.delete_outline;
      case 'login':
        return Icons.login_outlined;
      case 'logout':
        return Icons.logout_outlined;
      case 'export':
        return Icons.file_download_outlined;
      case 'approve':
        return Icons.check_circle_outline;
      case 'reject':
        return Icons.cancel_outlined;
      case 'sync':
        return Icons.sync_outlined;
      case 'backup':
        return Icons.backup_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}

class _ActorCell extends StatelessWidget {
  final ActivityLogModel log;

  const _ActorCell({
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final String actorName =
        log.actorName.trim().isEmpty ? 'System' : log.actorName.trim();

    return SizedBox(
      width: 220,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              actorName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  actorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.actorEmail.trim().isEmpty
                      ? AppFormatters.formatStatus(log.actorRole)
                      : log.actorEmail,
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
}

class _EntityCell extends StatelessWidget {
  final ActivityLogModel log;

  const _EntityCell({
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.entityType.trim().isEmpty
                ? 'Not Available'
                : AppFormatters.formatStatus(log.entityType),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            log.entityId.trim().isEmpty ? 'N/A' : log.entityId,
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
    );
  }
}

class _ActionBadge extends StatelessWidget {
  final String action;

  const _ActionBadge({
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (action) {
      case 'create':
        color = AppColors.success;
        break;
      case 'update':
        color = AppColors.info;
        break;
      case 'delete':
        color = AppColors.error;
        break;
      case 'login':
      case 'logout':
        color = AppColors.primary;
        break;
      case 'export':
      case 'import':
        color = Colors.purple;
        break;
      case 'approve':
      case 'resolve':
      case 'close':
        color = AppColors.success;
        break;
      case 'reject':
        color = AppColors.error;
        break;
      case 'sync':
      case 'backup':
        color = Colors.blueGrey;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(action),
      color: color,
    );
  }
}

class _ModuleBadge extends StatelessWidget {
  final String module;

  const _ModuleBadge({
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (module) {
      case 'auth':
      case 'settings':
        color = AppColors.error;
        break;
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
      case 'support':
      case 'complaints':
      case 'disputes':
        color = AppColors.warning;
        break;
      case 'reports':
      case 'analytics':
        color = Colors.purple;
        break;
      default:
        color = Colors.blueGrey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(module),
      color: color,
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;

  const _SeverityBadge({
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: AppFormatters.formatStatus(severity),
      color: _ActivityLogsScreenState._severityColor(severity),
    );
  }
}

class _DateFilterTile extends StatelessWidget {
  final String title;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateFilterTile({
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

class _AuditSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AuditSummaryCard({
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

class _MetadataBox extends StatelessWidget {
  final String metadata;

  const _MetadataBox({
    required this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: SelectableText(
        metadata,
        style: TextStyle(
          color: Colors.grey.shade800,
          height: 1.45,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
      ),
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
            Icons.receipt_long_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Activity Log Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Audit trail and admin activity history',
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
            child: SelectableText(
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
        label.trim().isEmpty ? 'N/A' : label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}