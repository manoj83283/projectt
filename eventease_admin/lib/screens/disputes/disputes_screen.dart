import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/dispute_model.dart';
import '../../providers/dispute_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({
    super.key,
  });

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedPriority;
  String? _selectedDisputeType;
  String? _selectedUserType;

  final List<String> _disputeStatuses = const [
    'open',
    'under_review',
    'awaiting_response',
    'in_mediation',
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

  final List<String> _disputeTypes = const [
    'booking',
    'payment',
    'refund',
    'service_quality',
    'provider_no_show',
    'customer_no_show',
    'cancellation',
    'settlement',
    'fraud',
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
      _fetchDisputes();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDisputes() async {
    await context.read<DisputeProvider>().getDisputes(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          priority: _selectedPriority,
          disputeType: _selectedDisputeType,
          userType: _selectedUserType,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchDisputes();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchDisputes();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchDisputes();
  }

  void _onPriorityChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedPriority = value;
    });

    _fetchDisputes();
  }

  void _onDisputeTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedDisputeType = value;
    });

    _fetchDisputes();
  }

  void _onUserTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedUserType = value;
    });

    _fetchDisputes();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedDisputeType = null;
      _selectedUserType = null;
      _searchController.clear();
    });

    _fetchDisputes();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchDisputes();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchDisputes();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchDisputes();
  }

  Future<void> _viewDispute(DisputeModel dispute) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.disputeDetails,
      arguments: dispute,
    );

    if (!mounted) return;

    _fetchDisputes();
  }

  Future<void> _assignDispute(DisputeModel dispute) async {
    final TextEditingController assigneeController = TextEditingController(
      text: dispute.assignedToId,
    );

    final String? assigneeId = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Assign Dispute'),
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

    final bool success = await context.read<DisputeProvider>().assignDispute(
          disputeId: dispute.id,
          assignedToId: assigneeId,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Dispute assigned successfully',
      errorMessage: 'Failed to assign dispute',
    );
  }

  Future<void> _markUnderReview(DisputeModel dispute) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Mark Under Review',
      message:
          'Do you want to mark dispute ${dispute.disputeNumber} as under review?',
      confirmText: 'Review',
      confirmColor: AppColors.info,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<DisputeProvider>()
        .markDisputeUnderReview(dispute.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Dispute marked as under review',
      errorMessage: 'Failed to update dispute',
    );
  }

  Future<void> _startMediation(DisputeModel dispute) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Start Mediation',
      message:
          'Do you want to start mediation for dispute ${dispute.disputeNumber}?',
      confirmText: 'Start',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<DisputeProvider>().startMediation(dispute.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Dispute moved to mediation',
      errorMessage: 'Failed to start mediation',
    );
  }

  Future<void> _requestResponse(DisputeModel dispute) async {
    final TextEditingController noteController = TextEditingController();

    final String? note = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Request Response'),
          content: TextField(
            controller: noteController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Response Request Note',
              hintText: 'Enter note for the party',
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
                final String value = noteController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              icon: const Icon(Icons.mark_email_unread_outlined),
              label: const Text('Request'),
            ),
          ],
        );
      },
    );

    noteController.dispose();

    if (note == null || note.isEmpty) return;

    final bool success =
        await context.read<DisputeProvider>().requestDisputeResponse(
              disputeId: dispute.id,
              note: note,
            );

    _handleMutationResult(
      success: success,
      successMessage: 'Response requested successfully',
      errorMessage: 'Failed to request response',
    );
  }

  Future<void> _resolveDispute(DisputeModel dispute) async {
    final TextEditingController resolutionController = TextEditingController();

    final String? resolution = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Resolve Dispute'),
          content: TextField(
            controller: resolutionController,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Resolution Note',
              hintText: 'Enter dispute resolution summary',
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

    final bool success = await context.read<DisputeProvider>().resolveDispute(
          disputeId: dispute.id,
          resolution: resolution,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Dispute resolved successfully',
      errorMessage: 'Failed to resolve dispute',
    );
  }

  Future<void> _rejectDispute(DisputeModel dispute) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Reject Dispute'),
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

    final bool success = await context.read<DisputeProvider>().rejectDispute(
          disputeId: dispute.id,
          reason: reason,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Dispute rejected successfully',
      errorMessage: 'Failed to reject dispute',
    );
  }

  Future<void> _closeDispute(DisputeModel dispute) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Close Dispute',
      message:
          'Are you sure you want to close dispute ${dispute.disputeNumber}?',
      confirmText: 'Close',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<DisputeProvider>().closeDispute(dispute.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Dispute closed successfully',
      errorMessage: 'Failed to close dispute',
    );
  }

  Future<void> _escalateDispute(DisputeModel dispute) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Escalate Dispute'),
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

    final bool success = await context.read<DisputeProvider>().escalateDispute(
          disputeId: dispute.id,
          reason: reason,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Dispute escalated successfully',
      errorMessage: 'Failed to escalate dispute',
    );
  }

  Future<void> _deleteDispute(DisputeModel dispute) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Dispute',
      message:
          'This action cannot be undone. Are you sure you want to delete dispute ${dispute.disputeNumber}?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<DisputeProvider>().deleteDispute(dispute.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Dispute deleted successfully',
      errorMessage: 'Failed to delete dispute',
    );
  }

  Future<void> _exportDisputes() async {
    await context.read<DisputeProvider>().exportDisputes();

    if (!mounted) return;

    NavigationService.showSuccess(
      'Disputes export started successfully',
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
      _fetchDisputes();
      return;
    }

    NavigationService.showError(
      context.read<DisputeProvider>().errorMessage ?? errorMessage,
    );
  }

  Widget _buildHeader(DisputeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Disputes',
          subtitle:
              'Manage booking, payment, refund, cancellation and service-quality disputes across customers and providers.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: _exportDisputes,
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
                _DisputeSummaryCard(
                  title: 'Total Disputes',
                  value: provider.totalDisputes.toString(),
                  icon: Icons.gavel_outlined,
                  color: AppColors.primary,
                ),
                _DisputeSummaryCard(
                  title: 'Open',
                  value: provider.openDisputes.toString(),
                  icon: Icons.mark_email_unread_outlined,
                  color: AppColors.warning,
                ),
                _DisputeSummaryCard(
                  title: 'Under Review',
                  value: provider.underReviewDisputes.toString(),
                  icon: Icons.manage_search_outlined,
                  color: AppColors.info,
                ),
                _DisputeSummaryCard(
                  title: 'Mediation',
                  value: provider.mediationDisputes.toString(),
                  icon: Icons.handshake_outlined,
                  color: AppColors.primary,
                ),
                _DisputeSummaryCard(
                  title: 'Resolved',
                  value: provider.resolvedDisputes.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _DisputeSummaryCard(
                  title: 'Escalated',
                  value: provider.escalatedDisputes.toString(),
                  icon: Icons.priority_high_outlined,
                  color: AppColors.error,
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
                'Search dispute id, subject, customer, provider, booking, order...',
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
                    _buildDisputeTypeDropdown(),
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
                  Expanded(child: _buildDisputeTypeDropdown()),
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
      labelText: 'Dispute Status',
      value: _selectedStatus,
      items: _disputeStatuses,
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

  Widget _buildDisputeTypeDropdown() {
    return CustomDropdown<String>(
      labelText: 'Dispute Type',
      value: _selectedDisputeType,
      items: _disputeTypes,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onDisputeTypeChanged,
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
    return Consumer<DisputeProvider>(
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
                  DisputesTable(
                    disputes: provider.disputes,
                    isLoading: provider.isLoading,
                    onView: _viewDispute,
                    onAssign: _assignDispute,
                    onReview: _markUnderReview,
                    onRequestResponse: _requestResponse,
                    onMediation: _startMediation,
                    onResolve: _resolveDispute,
                    onReject: _rejectDispute,
                    onClose: _closeDispute,
                    onEscalate: _escalateDispute,
                    onDelete: _deleteDispute,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalDisputes,
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

class DisputesTable extends StatelessWidget {
  final List<DisputeModel> disputes;
  final bool isLoading;
  final ValueChanged<DisputeModel> onView;
  final ValueChanged<DisputeModel> onAssign;
  final ValueChanged<DisputeModel> onReview;
  final ValueChanged<DisputeModel> onRequestResponse;
  final ValueChanged<DisputeModel> onMediation;
  final ValueChanged<DisputeModel> onResolve;
  final ValueChanged<DisputeModel> onReject;
  final ValueChanged<DisputeModel> onClose;
  final ValueChanged<DisputeModel> onEscalate;
  final ValueChanged<DisputeModel> onDelete;

  const DisputesTable({
    super.key,
    required this.disputes,
    required this.isLoading,
    required this.onView,
    required this.onAssign,
    required this.onReview,
    required this.onRequestResponse,
    required this.onMediation,
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
          else if (disputes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.gavel_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No disputes found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Disputes matching your filters will appear here.',
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
                  DataColumn(label: Text('Dispute')),
                  DataColumn(label: Text('Raised By')),
                  DataColumn(label: Text('Against')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Priority')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Assigned To')),
                  DataColumn(label: Text('Created Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: disputes.map(
                  (dispute) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _DisputeInfoCell(
                            dispute: dispute,
                          ),
                        ),
                        DataCell(
                          _UserCell(
                            dispute: dispute,
                          ),
                        ),
                        DataCell(
                          _AgainstCell(
                            dispute: dispute,
                          ),
                        ),
                        DataCell(
                          _DisputeTypeBadge(
                            type: dispute.disputeType,
                          ),
                        ),
                        DataCell(
                          _PriorityBadge(
                            priority: dispute.priority,
                          ),
                        ),
                        DataCell(
                          _DisputeStatusBadge(
                            status: dispute.status,
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              dispute.amount,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        DataCell(
                          _AssigneeCell(
                            dispute: dispute,
                          ),
                        ),
                        DataCell(
                          Text(
                            _DisputesScreenState._formatDate(
                              dispute.createdAt,
                            ),
                          ),
                        ),
                        DataCell(
                          _DisputeActions(
                            dispute: dispute,
                            onView: onView,
                            onAssign: onAssign,
                            onReview: onReview,
                            onRequestResponse: onRequestResponse,
                            onMediation: onMediation,
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

class _DisputeInfoCell extends StatelessWidget {
  final DisputeModel dispute;

  const _DisputeInfoCell({
    required this.dispute,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.gavel_outlined,
              color: AppColors.primary,
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
                  dispute.disputeNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dispute.subject,
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
  final DisputeModel dispute;

  const _UserCell({
    required this.dispute,
  });

  @override
  Widget build(BuildContext context) {
    final String userName =
        dispute.userName.trim().isEmpty ? 'Unknown User' : dispute.userName;

    return SizedBox(
      width: 185,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: _userTypeColor(dispute.userType).withOpacity(0.1),
            child: Text(
              userName[0].toUpperCase(),
              style: TextStyle(
                color: _userTypeColor(dispute.userType),
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
                  AppFormatters.formatStatus(dispute.userType),
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
  final DisputeModel dispute;

  const _AgainstCell({
    required this.dispute,
  });

  @override
  Widget build(BuildContext context) {
    final String againstName = dispute.againstName.trim().isEmpty
        ? 'Not Available'
        : dispute.againstName;

    return SizedBox(
      width: 185,
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
                  AppFormatters.formatStatus(dispute.againstType),
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
  final DisputeModel dispute;

  const _AssigneeCell({
    required this.dispute,
  });

  @override
  Widget build(BuildContext context) {
    final String assignee = dispute.assignedToName.trim().isEmpty
        ? 'Unassigned'
        : dispute.assignedToName;

    final bool assigned = dispute.assignedToName.trim().isNotEmpty;

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

class _DisputeTypeBadge extends StatelessWidget {
  final String type;

  const _DisputeTypeBadge({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (type) {
      case 'booking':
        color = AppColors.info;
        break;
      case 'payment':
        color = AppColors.success;
        break;
      case 'refund':
        color = Colors.purple;
        break;
      case 'service_quality':
        color = Colors.deepPurple;
        break;
      case 'provider_no_show':
        color = Colors.teal;
        break;
      case 'customer_no_show':
        color = Colors.orange;
        break;
      case 'cancellation':
        color = Colors.blueGrey;
        break;
      case 'settlement':
        color = Colors.indigo;
        break;
      case 'fraud':
        color = AppColors.error;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(type),
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

class _DisputeStatusBadge extends StatelessWidget {
  final String status;

  const _DisputeStatusBadge({
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
      case 'awaiting_response':
        color = Colors.orange;
        break;
      case 'in_mediation':
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

class _DisputeActions extends StatelessWidget {
  final DisputeModel dispute;
  final ValueChanged<DisputeModel> onView;
  final ValueChanged<DisputeModel> onAssign;
  final ValueChanged<DisputeModel> onReview;
  final ValueChanged<DisputeModel> onRequestResponse;
  final ValueChanged<DisputeModel> onMediation;
  final ValueChanged<DisputeModel> onResolve;
  final ValueChanged<DisputeModel> onReject;
  final ValueChanged<DisputeModel> onClose;
  final ValueChanged<DisputeModel> onEscalate;
  final ValueChanged<DisputeModel> onDelete;

  const _DisputeActions({
    required this.dispute,
    required this.onView,
    required this.onAssign,
    required this.onReview,
    required this.onRequestResponse,
    required this.onMediation,
    required this.onResolve,
    required this.onReject,
    required this.onClose,
    required this.onEscalate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canReview = dispute.status == 'open';
    final bool canRequestResponse = dispute.status == 'open' ||
        dispute.status == 'under_review';
    final bool canMediation = dispute.status == 'under_review' ||
        dispute.status == 'awaiting_response';
    final bool canResolve = dispute.status == 'open' ||
        dispute.status == 'under_review' ||
        dispute.status == 'awaiting_response' ||
        dispute.status == 'in_mediation' ||
        dispute.status == 'escalated';
    final bool canReject = dispute.status == 'open' ||
        dispute.status == 'under_review' ||
        dispute.status == 'awaiting_response';
    final bool canClose =
        dispute.status == 'resolved' || dispute.status == 'rejected';
    final bool canEscalate = dispute.status == 'open' ||
        dispute.status == 'under_review' ||
        dispute.status == 'awaiting_response' ||
        dispute.status == 'in_mediation';

    return PopupMenuButton<String>(
      tooltip: 'Dispute Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(dispute);
            break;
          case 'assign':
            onAssign(dispute);
            break;
          case 'review':
            onReview(dispute);
            break;
          case 'response':
            onRequestResponse(dispute);
            break;
          case 'mediation':
            onMediation(dispute);
            break;
          case 'resolve':
            onResolve(dispute);
            break;
          case 'reject':
            onReject(dispute);
            break;
          case 'close':
            onClose(dispute);
            break;
          case 'escalate':
            onEscalate(dispute);
            break;
          case 'delete':
            onDelete(dispute);
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
          value: 'response',
          enabled: canRequestResponse,
          child: _MenuItem(
            icon: Icons.mark_email_unread_outlined,
            label: 'Request Response',
            color: canRequestResponse ? Colors.orange : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'mediation',
          enabled: canMediation,
          child: _MenuItem(
            icon: Icons.handshake_outlined,
            label: 'Start Mediation',
            color: canMediation ? AppColors.primary : Colors.grey,
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

class _DisputeSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DisputeSummaryCard({
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
            Icons.gavel_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Dispute Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Marketplace dispute resolution overview',
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