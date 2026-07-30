import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/login_log_model.dart';
import '../../providers/audit_log_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class LoginLogsScreen extends StatefulWidget {
  const LoginLogsScreen({
    super.key,
  });

  @override
  State<LoginLogsScreen> createState() => _LoginLogsScreenState();
}

class _LoginLogsScreenState extends State<LoginLogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedRole;
  String? _selectedPlatform;
  String? _selectedLoginType;

  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _statuses = const [
    'success',
    'failed',
    'blocked',
    'locked',
    'logout',
    'expired',
  ];

  final List<String> _roles = const [
    'super_admin',
    'admin',
    'manager',
    'support',
    'finance',
    'operations',
    'provider',
    'customer',
    'system',
  ];

  final List<String> _platforms = const [
    'web',
    'android',
    'ios',
    'desktop',
    'api',
  ];

  final List<String> _loginTypes = const [
    'password',
    'otp',
    'sso',
    'google',
    'apple',
    'refresh_token',
  ];

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLoginLogs();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLoginLogs() async {
    await context.read<AuditLogProvider>().getLoginLogs(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          role: _selectedRole,
          platform: _selectedPlatform,
          loginType: _selectedLoginType,
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchLoginLogs();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchLoginLogs();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchLoginLogs();
  }

  void _onRoleChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedRole = value;
    });

    _fetchLoginLogs();
  }

  void _onPlatformChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedPlatform = value;
    });

    _fetchLoginLogs();
  }

  void _onLoginTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedLoginType = value;
    });

    _fetchLoginLogs();
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

    _fetchLoginLogs();
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

    _fetchLoginLogs();
  }

  void _clearFilters() {
    final DateTime now = DateTime.now();

    setState(() {
      _page = 1;
      _selectedStatus = null;
      _selectedRole = null;
      _selectedPlatform = null;
      _selectedLoginType = null;
      _searchController.clear();
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = now;
    });

    _fetchLoginLogs();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchLoginLogs();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchLoginLogs();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchLoginLogs();
  }

  Future<void> _viewLog(LoginLogModel log) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 760,
              maxHeight: 760,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.padding20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            _statusColor(log.status).withOpacity(0.1),
                        child: Icon(
                          Icons.login_outlined,
                          color: _statusColor(log.status),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Login Log Details',
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
                            _LoginStatusBadge(status: log.status),
                            _RoleBadge(role: log.role),
                            _PlatformBadge(platform: log.platform),
                            _LoginTypeBadge(loginType: log.loginType),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          log.userName.trim().isEmpty
                              ? 'Unknown User'
                              : log.userName,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          log.email.trim().isEmpty
                              ? 'No email available'
                              : log.email,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 22),
                        _DetailRow(label: 'Log ID', value: _empty(log.id)),
                        _DetailRow(label: 'User ID', value: _empty(log.userId)),
                        _DetailRow(
                          label: 'User Name',
                          value: _empty(log.userName),
                        ),
                        _DetailRow(label: 'Email', value: _empty(log.email)),
                        _DetailRow(
                          label: 'Role',
                          value: AppFormatters.formatStatus(log.role),
                        ),
                        _DetailRow(
                          label: 'Status',
                          value: AppFormatters.formatStatus(log.status),
                        ),
                        _DetailRow(
                          label: 'Login Type',
                          value: AppFormatters.formatStatus(log.loginType),
                        ),
                        _DetailRow(
                          label: 'IP Address',
                          value: _empty(log.ipAddress),
                        ),
                        _DetailRow(label: 'Device', value: _empty(log.device)),
                        _DetailRow(
                          label: 'Platform',
                          value: AppFormatters.formatStatus(log.platform),
                        ),
                        _DetailRow(label: 'Browser', value: _empty(log.browser)),
                        _DetailRow(label: 'OS', value: _empty(log.os)),
                        _DetailRow(
                          label: 'Location',
                          value: _empty(log.location),
                        ),
                        _DetailRow(
                          label: 'Failure Reason',
                          value: _empty(log.failureReason),
                        ),
                        _DetailRow(
                          label: 'Session ID',
                          value: _empty(log.sessionId),
                        ),
                        _DetailRow(
                          label: 'Login Time',
                          value: _formatDateTime(log.loginAt),
                        ),
                        _DetailRow(
                          label: 'Logout Time',
                          value: _formatDateTime(log.logoutAt),
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
    await context.read<AuditLogProvider>().exportLoginLogs(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          role: _selectedRole,
          platform: _selectedPlatform,
          loginType: _selectedLoginType,
          startDate: _startDate,
          endDate: _endDate,
        );

    if (!mounted) return;

    NavigationService.showSuccess(
      'Login logs export started successfully',
    );
  }

  Widget _buildHeader(AuditLogProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Login Logs',
          subtitle:
              'Track admin, customer, provider and system login attempts, failed logins, blocked sessions, devices and IP access.',
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
                _LoginSummaryCard(
                  title: 'Total Logins',
                  value: provider.totalLoginLogs.toString(),
                  icon: Icons.login_outlined,
                  color: AppColors.primary,
                ),
                _LoginSummaryCard(
                  title: 'Successful',
                  value: provider.successLoginLogs.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _LoginSummaryCard(
                  title: 'Failed',
                  value: provider.failedLoginLogs.toString(),
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                ),
                _LoginSummaryCard(
                  title: 'Blocked',
                  value: provider.blockedLoginLogs.toString(),
                  icon: Icons.block_outlined,
                  color: AppColors.warning,
                ),
                _LoginSummaryCard(
                  title: 'Today',
                  value: provider.todayLoginLogs.toString(),
                  icon: Icons.today_outlined,
                  color: AppColors.info,
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
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Search user, email, IP address, device, session...',
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
                    _buildStatusDropdown(),
                    const SizedBox(height: 14),
                    _buildRoleDropdown(),
                    const SizedBox(height: 14),
                    _buildPlatformDropdown(),
                    const SizedBox(height: 14),
                    _buildLoginTypeDropdown(),
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
                      Expanded(child: _buildStatusDropdown()),
                      const SizedBox(width: 14),
                      Expanded(child: _buildRoleDropdown()),
                      const SizedBox(width: 14),
                      Expanded(child: _buildPlatformDropdown()),
                      const SizedBox(width: 14),
                      Expanded(child: _buildLoginTypeDropdown()),
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

  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Status',
      value: _selectedStatus,
      items: _statuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
    );
  }

  Widget _buildRoleDropdown() {
    return CustomDropdown<String>(
      labelText: 'Role',
      value: _selectedRole,
      items: _roles,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onRoleChanged,
    );
  }

  Widget _buildPlatformDropdown() {
    return CustomDropdown<String>(
      labelText: 'Platform',
      value: _selectedPlatform,
      items: _platforms,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onPlatformChanged,
    );
  }

  Widget _buildLoginTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Login Type',
      value: _selectedLoginType,
      items: _loginTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onLoginTypeChanged,
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
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.25),
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
                  LoginLogsTable(
                    logs: provider.loginLogs,
                    isLoading: provider.isLoading,
                    onView: _viewLog,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalLoginLogs,
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

  static Color _statusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      case 'blocked':
      case 'locked':
        return AppColors.warning;
      case 'logout':
        return AppColors.info;
      case 'expired':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}

class LoginLogsTable extends StatelessWidget {
  final List<LoginLogModel> logs;
  final bool isLoading;
  final ValueChanged<LoginLogModel> onView;

  const LoginLogsTable({
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
            color: Colors.black.withOpacity(0.035),
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
                    Icons.login_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No login logs found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Login activity matching your filters will appear here.',
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
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Login Type')),
                  DataColumn(label: Text('IP Address')),
                  DataColumn(label: Text('Device')),
                  DataColumn(label: Text('Platform')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Login Time')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: logs.map(
                  (log) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _UserCell(log: log),
                        ),
                        DataCell(
                          _RoleBadge(role: log.role),
                        ),
                        DataCell(
                          _LoginStatusBadge(status: log.status),
                        ),
                        DataCell(
                          _LoginTypeBadge(loginType: log.loginType),
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
                          _DeviceCell(log: log),
                        ),
                        DataCell(
                          _PlatformBadge(platform: log.platform),
                        ),
                        DataCell(
                          SizedBox(
                            width: 160,
                            child: Text(
                              log.location.trim().isEmpty
                                  ? 'Not Available'
                                  : log.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _LoginLogsScreenState._formatDateTime(
                              log.loginAt,
                            ),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            tooltip: 'View Login Log',
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

class _UserCell extends StatelessWidget {
  final LoginLogModel log;

  const _UserCell({
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final String userName =
        log.userName.trim().isEmpty ? 'Unknown User' : log.userName.trim();

    final Color color = _LoginLogsScreenState._statusColor(log.status);

    return SizedBox(
      width: 260,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: color.withOpacity(0.1),
            child: Text(
              userName[0].toUpperCase(),
              style: TextStyle(
                color: color,
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
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.email.trim().isEmpty ? log.userId : log.email,
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

class _DeviceCell extends StatelessWidget {
  final LoginLogModel log;

  const _DeviceCell({
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.device.trim().isEmpty ? 'Unknown Device' : log.device,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            log.browser.trim().isEmpty && log.os.trim().isEmpty
                ? 'N/A'
                : '${log.browser} ${log.os}',
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

class _LoginStatusBadge extends StatelessWidget {
  final String status;

  const _LoginStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: AppFormatters.formatStatus(status),
      color: _LoginLogsScreenState._statusColor(status),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (role) {
      case 'super_admin':
        color = AppColors.error;
        break;
      case 'admin':
      case 'manager':
        color = AppColors.primary;
        break;
      case 'support':
      case 'operations':
        color = AppColors.info;
        break;
      case 'finance':
        color = AppColors.success;
        break;
      case 'provider':
        color = Colors.teal;
        break;
      case 'customer':
        color = Colors.indigo;
        break;
      case 'system':
        color = Colors.blueGrey;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(role),
      color: color,
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final String platform;

  const _PlatformBadge({
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (platform) {
      case 'web':
        color = AppColors.primary;
        break;
      case 'android':
        color = AppColors.success;
        break;
      case 'ios':
        color = Colors.blueGrey;
        break;
      case 'desktop':
        color = Colors.purple;
        break;
      case 'api':
        color = AppColors.warning;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(platform),
      color: color,
    );
  }
}

class _LoginTypeBadge extends StatelessWidget {
  final String loginType;

  const _LoginTypeBadge({
    required this.loginType,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (loginType) {
      case 'password':
        color = AppColors.primary;
        break;
      case 'otp':
        color = AppColors.success;
        break;
      case 'sso':
        color = Colors.purple;
        break;
      case 'google':
        color = AppColors.error;
        break;
      case 'apple':
        color = Colors.black87;
        break;
      case 'refresh_token':
        color = AppColors.info;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(loginType),
      color: color,
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

class _LoginSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _LoginSummaryCard({
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
            color: Colors.black.withOpacity(0.035),
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
              color: color.withOpacity(0.11),
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
            Icons.login_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Login Log Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Authentication and session activity history',
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
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.24),
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