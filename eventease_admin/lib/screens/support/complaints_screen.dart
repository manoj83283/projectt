import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/complaint_model.dart';
import '../../providers/support_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({
    super.key,
  });

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedPriority;
  String? _selectedCategory;
  String? _selectedUserType;

  final List<String> _complaintStatuses = const [
    'open',
    'under_review',
    'in_progress',
    'resolved',
    'rejected',
    'closed',
    'escalated',
  ];

  final List<String> _priorities = const [
    'low',
    'medium',
    'high',
    'urgent',
  ];

  final List<String> _categories = const [
    'booking',
    'payment',
    'refund',
    'provider',
    'customer',
    'service_quality',
    'fraud',
    'safety',
    'technical',
    'other',
  ];

  final List<String> _userTypes = const [
    'customer',
    'provider',
    'admin',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchComplaints();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchComplaints() async {
    await context.read<SupportProvider>().getComplaints(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          category: _selectedCategory,
          userType: _selectedUserType,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchComplaints();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchComplaints();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchComplaints();
  }

  void _onPriorityChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedPriority = value;
    });

    _fetchComplaints();
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedCategory = value;
    });

    _fetchComplaints();
  }

  void _onUserTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedUserType = value;
    });

    _fetchComplaints();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedCategory = null;
      _selectedUserType = null;
      _searchController.clear();
    });

    _fetchComplaints();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchComplaints();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchComplaints();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchComplaints();
  }

  Future<void> _viewComplaint(ComplaintModel complaint) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.complaintDetails,
      arguments: complaint,
    );

    if (!mounted) return;

    _fetchComplaints();
  }

  Future<void> _assignComplaint(ComplaintModel complaint) async {
    final TextEditingController assigneeController = TextEditingController(
      text: complaint.assignedToId,
    );

    final String? assigneeId = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Assign Complaint'),
          content: TextField(
            controller: assigneeController,
            decoration: const InputDecoration(
              labelText: 'Assignee Admin ID',
              hintText: 'Enter admin ID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final String value = assigneeController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Assign'),
            ),
          ],
        );
      },
    );

    assigneeController.dispose();

    if (assigneeId == null || assigneeId.isEmpty) return;

    final bool success = await context.read<SupportProvider>().assignComplaint(
          complaintId: complaint.id,
          assignedToId: assigneeId,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Complaint assigned successfully',
      errorMessage: 'Failed to assign complaint',
    );
  }

  Future<void> _markUnderReview(ComplaintModel complaint) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Mark Under Review',
      message:
          'Do you want to mark complaint ${complaint.complaintNumber} as under review?',
      confirmText: 'Review',
      confirmColor: AppColors.info,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<SupportProvider>()
        .markComplaintUnderReview(complaint.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Complaint marked as under review',
      errorMessage: 'Failed to update complaint',
    );
  }

  Future<void> _markInProgress(ComplaintModel complaint) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Mark In Progress',
      message:
          'Do you want to mark complaint ${complaint.complaintNumber} as in progress?',
      confirmText: 'Start',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<SupportProvider>()
        .markComplaintInProgress(complaint.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Complaint marked as in progress',
      errorMessage: 'Failed to update complaint',
    );
  }

  Future<void> _resolveComplaint(ComplaintModel complaint) async {
    final TextEditingController resolutionController = TextEditingController();

    final String? resolution = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Resolve Complaint'),
          content: TextField(
            controller: resolutionController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Resolution Note',
              hintText: 'Enter resolution summary',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final String value = resolutionController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Resolve'),
            ),
          ],
        );
      },
    );

    resolutionController.dispose();

    if (resolution == null || resolution.isEmpty) return;

    final bool success = await context.read<SupportProvider>().resolveComplaint(
          complaintId: complaint.id,
          resolution: resolution,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Complaint resolved successfully',
      errorMessage: 'Failed to resolve complaint',
    );
  }

  Future<void> _rejectComplaint(ComplaintModel complaint) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Reject Complaint'),
          content: TextField(
            controller: reasonController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Rejection Reason',
              hintText: 'Enter rejection reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final String value = reasonController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Reject'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null || reason.isEmpty) return;

    final bool success = await context.read<SupportProvider>().rejectComplaint(
          complaintId: complaint.id,
          reason: reason,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Complaint rejected successfully',
      errorMessage: 'Failed to reject complaint',
    );
  }

  Future<void> _closeComplaint(ComplaintModel complaint) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Close Complaint',
      message:
          'Are you sure you want to close complaint ${complaint.complaintNumber}?',
      confirmText: 'Close',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<SupportProvider>().closeComplaint(complaint.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Complaint closed successfully',
      errorMessage: 'Failed to close complaint',
    );
  }

  Future<void> _escalateComplaint(ComplaintModel complaint) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Escalate Complaint'),
          content: TextField(
            controller: reasonController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Escalation Reason',
              hintText: 'Enter escalation reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final String value = reasonController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              icon: const Icon(Icons.priority_high_outlined),
              label: const Text('Escalate'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null || reason.isEmpty) return;

    final bool success = await context.read<SupportProvider>().escalateComplaint(
          complaintId: complaint.id,
          reason: reason,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Complaint escalated successfully',
      errorMessage: 'Failed to escalate complaint',
    );
  }

  Future<void> _deleteComplaint(ComplaintModel complaint) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Complaint',
      message:
          'This action cannot be undone. Are you sure you want to delete complaint ${complaint.complaintNumber}?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<SupportProvider>().deleteComplaint(complaint.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Complaint deleted successfully',
      errorMessage: 'Failed to delete complaint',
    );
  }

  Future<void> _exportComplaints() async {
    await context.read<SupportProvider>().exportComplaints();

    if (!mounted) return;

    NavigationService.showSuccess(
      'Complaints export started successfully',
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
  }) {
    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(successMessage);
      _fetchComplaints();
      return;
    }

    NavigationService.showError(
      context.read<SupportProvider>().errorMessage ?? errorMessage,
    );
  }

  Widget _buildHeader(SupportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Complaints',
          subtitle:
              'Manage marketplace complaints, safety issues, disputes, escalations and resolutions.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: _exportComplaints,
            ),
            const SizedBox(width: 12),
            CustomButton(
              text: 'Refresh',
              type: ButtonType.outline,
              icon: Icons.refresh,
              onPressed: _refresh,
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
                _ComplaintSummaryCard(
                  title: 'Total Complaints',
                  value: provider.totalComplaints.toString(),
                  icon: Icons.report_problem_outlined,
                  color: AppColors.primary,
                ),
                _ComplaintSummaryCard(
                  title: 'Open',
                  value: provider.openComplaints.toString(),
                  icon: Icons.mark_email_unread_outlined,
                  color: AppColors.warning,
                ),
                _ComplaintSummaryCard(
                  title: 'Under Review',
                  value: provider.underReviewComplaints.toString(),
                  icon: Icons.manage_search_outlined,
                  color: AppColors.info,
                ),
                _ComplaintSummaryCard(
                  title: 'Resolved',
                  value: provider.resolvedComplaints.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _ComplaintSummaryCard(
                  title: 'Escalated',
                  value: provider.escalatedComplaints.toString(),
                  icon: Icons.priority_high_outlined,
                  color: AppColors.error,
                ),
                _ComplaintSummaryCard(
                  title: 'Closed',
                  value: provider.closedComplaints.toString(),
                  icon: Icons.lock_outline,
                  color: Colors.purple,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters() {
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
            hintText:
                'Search complaint id, subject, user, provider, booking, order...',
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
                    _buildStatusDropdown(),
                    const SizedBox(height: 14),
                    _buildPriorityDropdown(),
                    const SizedBox(height: 14),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 14),
                    _buildUserTypeDropdown(),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Clear Filters'),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildPriorityDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildCategoryDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildUserTypeDropdown()),
                  const SizedBox(width: 14),
                  TextButton.icon(
                    onPressed: _clearFilters,
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

  Widget _buildStatusDropdown() {
    return CustomDropdown<String>(
      labelText: 'Complaint Status',
      value: _selectedStatus,
      items: _complaintStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
    );
  }

  Widget _buildPriorityDropdown() {
    return CustomDropdown<String>(
      labelText: 'Priority',
      value: _selectedPriority,
      items: _priorities,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onPriorityChanged,
    );
  }

  Widget _buildCategoryDropdown() {
    return CustomDropdown<String>(
      labelText: 'Category',
      value: _selectedCategory,
      items: _categories,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onCategoryChanged,
    );
  }

  Widget _buildUserTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'User Type',
      value: _selectedUserType,
      items: _userTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onUserTypeChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportProvider>(
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
                  _buildFilters(),
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
                  ComplaintsTable(
                    complaints: provider.complaints,
                    isLoading: provider.isLoading,
                    onView: _viewComplaint,
                    onAssign: _assignComplaint,
                    onReview: _markUnderReview,
                    onInProgress: _markInProgress,
                    onResolve: _resolveComplaint,
                    onReject: _rejectComplaint,
                    onClose: _closeComplaint,
                    onEscalate: _escalateComplaint,
                    onDelete: _deleteComplaint,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalComplaints,
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

    return AppFormatters.formatDateTime(dateTime);
  }
}

class ComplaintsTable extends StatelessWidget {
  final List<ComplaintModel> complaints;
  final bool isLoading;
  final ValueChanged<ComplaintModel> onView;
  final ValueChanged<ComplaintModel> onAssign;
  final ValueChanged<ComplaintModel> onReview;
  final ValueChanged<ComplaintModel> onInProgress;
  final ValueChanged<ComplaintModel> onResolve;
  final ValueChanged<ComplaintModel> onReject;
  final ValueChanged<ComplaintModel> onClose;
  final ValueChanged<ComplaintModel> onEscalate;
  final ValueChanged<ComplaintModel> onDelete;

  const ComplaintsTable({
    super.key,
    required this.complaints,
    required this.isLoading,
    required this.onView,
    required this.onAssign,
    required this.onReview,
    required this.onInProgress,
    required this.onResolve,
    required this.onReject,
    required this.onClose,
    required this.onEscalate,
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
          else if (complaints.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.report_problem_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No complaints found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Complaints matching your filters will appear here.',
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
                  DataColumn(label: Text('Complaint')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Against')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Priority')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Assigned To')),
                  DataColumn(label: Text('Created Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: complaints.map(
                  (complaint) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _ComplaintInfoCell(
                            complaint: complaint,
                          ),
                        ),
                        DataCell(
                          _UserCell(
                            complaint: complaint,
                          ),
                        ),
                        DataCell(
                          _AgainstCell(
                            complaint: complaint,
                          ),
                        ),
                        DataCell(
                          _CategoryBadge(
                            category: complaint.category,
                          ),
                        ),
                        DataCell(
                          _PriorityBadge(
                            priority: complaint.priority,
                          ),
                        ),
                        DataCell(
                          _ComplaintStatusBadge(
                            status: complaint.status,
                          ),
                        ),
                        DataCell(
                          _AssigneeCell(
                            complaint: complaint,
                          ),
                        ),
                        DataCell(
                          Text(
                            _ComplaintsScreenState._formatDate(
                              complaint.createdAt,
                            ),
                          ),
                        ),
                        DataCell(
                          _ComplaintActions(
                            complaint: complaint,
                            onView: onView,
                            onAssign: onAssign,
                            onReview: onReview,
                            onInProgress: onInProgress,
                            onResolve: onResolve,
                            onReject: onReject,
                            onClose: onClose,
                            onEscalate: onEscalate,
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

class _ComplaintInfoCell extends StatelessWidget {
  final ComplaintModel complaint;

  const _ComplaintInfoCell({
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.error.withOpacity(0.1),
            child: const Icon(
              Icons.report_problem_outlined,
              color: AppColors.error,
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
                  complaint.complaintNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  complaint.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

class _UserCell extends StatelessWidget {
  final ComplaintModel complaint;

  const _UserCell({
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    final String userName = complaint.userName.trim().isEmpty
        ? 'Unknown User'
        : complaint.userName;

    return SizedBox(
      width: 185,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: _userTypeColor(complaint.userType).withOpacity(0.1),
            child: Text(
              userName[0].toUpperCase(),
              style: TextStyle(
                color: _userTypeColor(complaint.userType),
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatStatus(complaint.userType),
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

  Color _userTypeColor(String userType) {
    switch (userType) {
      case 'customer':
        return AppColors.success;
      case 'provider':
        return AppColors.info;
      case 'admin':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
}

class _AgainstCell extends StatelessWidget {
  final ComplaintModel complaint;

  const _AgainstCell({
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    final String againstName = complaint.againstName.trim().isEmpty
        ? 'Not Available'
        : complaint.againstName;

    final String againstType = complaint.againstType.trim().isEmpty
        ? 'unknown'
        : complaint.againstType;

    return SizedBox(
      width: 180,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.warning.withOpacity(0.1),
            child: const Icon(
              Icons.person_search_outlined,
              color: AppColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  againstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatStatus(againstType),
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

class _AssigneeCell extends StatelessWidget {
  final ComplaintModel complaint;

  const _AssigneeCell({
    required this.complaint,
  });

  @override
  Widget build(BuildContext context) {
    final String assignee = complaint.assignedToName.trim().isEmpty
        ? 'Unassigned'
        : complaint.assignedToName;

    final bool assigned = complaint.assignedToName.trim().isNotEmpty;

    return SizedBox(
      width: 160,
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: assigned
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            child: Icon(
              assigned ? Icons.person_outline : Icons.person_off_outlined,
              color: assigned ? AppColors.success : AppColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              assignee,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: assigned ? Colors.black87 : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (category) {
      case 'booking':
        color = AppColors.info;
        break;
      case 'payment':
        color = AppColors.success;
        break;
      case 'refund':
        color = Colors.purple;
        break;
      case 'provider':
        color = Colors.teal;
        break;
      case 'customer':
        color = AppColors.primary;
        break;
      case 'service_quality':
        color = Colors.deepPurple;
        break;
      case 'fraud':
        color = AppColors.error;
        break;
      case 'safety':
        color = Colors.deepOrange;
        break;
      case 'technical':
        color = Colors.blueGrey;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(category),
      color: color,
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (priority) {
      case 'low':
        color = AppColors.success;
        break;
      case 'medium':
        color = AppColors.info;
        break;
      case 'high':
        color = AppColors.warning;
        break;
      case 'urgent':
        color = AppColors.error;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(priority),
      color: color,
    );
  }
}

class _ComplaintStatusBadge extends StatelessWidget {
  final String status;

  const _ComplaintStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'open':
        color = AppColors.warning;
        break;
      case 'under_review':
        color = AppColors.info;
        break;
      case 'in_progress':
        color = AppColors.primary;
        break;
      case 'resolved':
        color = AppColors.success;
        break;
      case 'rejected':
        color = AppColors.error;
        break;
      case 'closed':
        color = Colors.purple;
        break;
      case 'escalated':
        color = Colors.deepOrange;
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

class _ComplaintActions extends StatelessWidget {
  final ComplaintModel complaint;
  final ValueChanged<ComplaintModel> onView;
  final ValueChanged<ComplaintModel> onAssign;
  final ValueChanged<ComplaintModel> onReview;
  final ValueChanged<ComplaintModel> onInProgress;
  final ValueChanged<ComplaintModel> onResolve;
  final ValueChanged<ComplaintModel> onReject;
  final ValueChanged<ComplaintModel> onClose;
  final ValueChanged<ComplaintModel> onEscalate;
  final ValueChanged<ComplaintModel> onDelete;

  const _ComplaintActions({
    required this.complaint,
    required this.onView,
    required this.onAssign,
    required this.onReview,
    required this.onInProgress,
    required this.onResolve,
    required this.onReject,
    required this.onClose,
    required this.onEscalate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canReview = complaint.status == 'open';
    final bool canStart = complaint.status == 'open' ||
        complaint.status == 'under_review';
    final bool canResolve = complaint.status == 'open' ||
        complaint.status == 'under_review' ||
        complaint.status == 'in_progress' ||
        complaint.status == 'escalated';
    final bool canReject = complaint.status == 'open' ||
        complaint.status == 'under_review' ||
        complaint.status == 'in_progress';
    final bool canClose =
        complaint.status == 'resolved' || complaint.status == 'rejected';
    final bool canEscalate = complaint.status == 'open' ||
        complaint.status == 'under_review' ||
        complaint.status == 'in_progress';

    return PopupMenuButton<String>(
      tooltip: 'Complaint Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(complaint);
            break;
          case 'assign':
            onAssign(complaint);
            break;
          case 'review':
            onReview(complaint);
            break;
          case 'progress':
            onInProgress(complaint);
            break;
          case 'resolve':
            onResolve(complaint);
            break;
          case 'reject':
            onReject(complaint);
            break;
          case 'close':
            onClose(complaint);
            break;
          case 'escalate':
            onEscalate(complaint);
            break;
          case 'delete':
            onDelete(complaint);
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
        const PopupMenuItem(
          value: 'assign',
          child: _MenuItem(
            icon: Icons.person_add_alt_1_outlined,
            label: 'Assign',
            color: AppColors.primary,
          ),
        ),
        PopupMenuItem(
          value: 'review',
          enabled: canReview,
          child: _MenuItem(
            icon: Icons.manage_search_outlined,
            label: 'Under Review',
            color: canReview ? AppColors.info : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'progress',
          enabled: canStart,
          child: _MenuItem(
            icon: Icons.sync_outlined,
            label: 'In Progress',
            color: canStart ? AppColors.primary : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'resolve',
          enabled: canResolve,
          child: _MenuItem(
            icon: Icons.check_circle_outline,
            label: 'Resolve',
            color: canResolve ? AppColors.success : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'reject',
          enabled: canReject,
          child: _MenuItem(
            icon: Icons.cancel_outlined,
            label: 'Reject',
            color: canReject ? AppColors.error : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'close',
          enabled: canClose,
          child: _MenuItem(
            icon: Icons.lock_outline,
            label: 'Close',
            color: canClose ? Colors.purple : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'escalate',
          enabled: canEscalate,
          child: _MenuItem(
            icon: Icons.priority_high_outlined,
            label: 'Escalate',
            color: canEscalate ? Colors.deepOrange : Colors.grey,
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

class _ComplaintSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ComplaintSummaryCard({
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
            Icons.report_problem_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Complaint Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Marketplace dispute and complaint overview',
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
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.24),
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