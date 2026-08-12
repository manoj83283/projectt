import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/dispute_model.dart';
import '../../providers/dispute_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/page_header.dart';

class DisputeDetailsScreen extends StatefulWidget {
  final DisputeModel dispute;

  const DisputeDetailsScreen({
    super.key,
    required this.dispute,
  });

  @override
  State<DisputeDetailsScreen> createState() => _DisputeDetailsScreenState();
}

class _DisputeDetailsScreenState extends State<DisputeDetailsScreen> {
  late DisputeModel _dispute;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dispute = widget.dispute;
  }

  Future<void> _assignDispute() async {
    final TextEditingController assigneeController = TextEditingController(
      text: _dispute.assignedToId,
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

    await _performAction(
      action: () => context.read<DisputeProvider>().assignDispute(
            disputeId: _dispute.id,
            assignedToId: assigneeId,
          ),
      successMessage: 'Dispute assigned successfully',
      errorMessage: 'Failed to assign dispute',
      shouldPop: true,
    );
  }

  Future<void> _markUnderReview() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Mark Under Review',
      message:
          'Do you want to mark dispute ${_dispute.disputeNumber} as under review?',
      confirmText: 'Review',
      confirmColor: AppColors.info,
    );

    if (!confirmed) return;

    await _performAction(
      action: () => context
          .read<DisputeProvider>()
          .markDisputeUnderReview(_dispute.id),
      successMessage: 'Dispute marked as under review',
      errorMessage: 'Failed to update dispute',
      shouldPop: true,
    );
  }

  Future<void> _requestResponse() async {
    final TextEditingController noteController = TextEditingController(
      text: _dispute.responseNote,
    );

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
              hintText: 'Enter note for customer/provider',
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

    await _performAction(
      action: () => context.read<DisputeProvider>().requestDisputeResponse(
            disputeId: _dispute.id,
            note: note,
          ),
      successMessage: 'Response requested successfully',
      errorMessage: 'Failed to request response',
      shouldPop: true,
    );
  }

  Future<void> _startMediation() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Start Mediation',
      message:
          'Do you want to start mediation for dispute ${_dispute.disputeNumber}?',
      confirmText: 'Start',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    await _performAction(
      action: () => context.read<DisputeProvider>().startMediation(
            _dispute.id,
          ),
      successMessage: 'Dispute moved to mediation',
      errorMessage: 'Failed to start mediation',
      shouldPop: true,
    );
  }

  Future<void> _resolveDispute() async {
    final TextEditingController resolutionController = TextEditingController(
      text: _dispute.resolution,
    );

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

    await _performAction(
      action: () => context.read<DisputeProvider>().resolveDispute(
            disputeId: _dispute.id,
            resolution: resolution,
          ),
      successMessage: 'Dispute resolved successfully',
      errorMessage: 'Failed to resolve dispute',
      shouldPop: true,
    );
  }

  Future<void> _rejectDispute() async {
    final TextEditingController reasonController = TextEditingController(
      text: _dispute.rejectionReason,
    );

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

    await _performAction(
      action: () => context.read<DisputeProvider>().rejectDispute(
            disputeId: _dispute.id,
            reason: reason,
          ),
      successMessage: 'Dispute rejected successfully',
      errorMessage: 'Failed to reject dispute',
      shouldPop: true,
    );
  }

  Future<void> _closeDispute() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Close Dispute',
      message:
          'Are you sure you want to close dispute ${_dispute.disputeNumber}?',
      confirmText: 'Close',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    await _performAction(
      action: () => context.read<DisputeProvider>().closeDispute(_dispute.id),
      successMessage: 'Dispute closed successfully',
      errorMessage: 'Failed to close dispute',
      shouldPop: true,
    );
  }

  Future<void> _escalateDispute() async {
    final TextEditingController reasonController = TextEditingController(
      text: _dispute.escalationReason,
    );

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

    await _performAction(
      action: () => context.read<DisputeProvider>().escalateDispute(
            disputeId: _dispute.id,
            reason: reason,
          ),
      successMessage: 'Dispute escalated successfully',
      errorMessage: 'Failed to escalate dispute',
      shouldPop: true,
    );
  }

  Future<void> _deleteDispute() async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Dispute',
      message:
          'This action cannot be undone. Are you sure you want to delete dispute ${_dispute.disputeNumber}?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    await _performAction(
      action: () => context.read<DisputeProvider>().deleteDispute(_dispute.id),
      successMessage: 'Dispute deleted successfully',
      errorMessage: 'Failed to delete dispute',
      shouldPop: true,
    );
  }

  Future<void> _performAction({
    required Future<bool> Function() action,
    required String successMessage,
    required String errorMessage,
    bool shouldPop = false,
  }) async {
    setState(() {
      _isLoading = true;
    });

    final bool success = await action();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      NavigationService.showSuccess(successMessage);

      if (shouldPop) {
        Navigator.pop(context, true);
      }

      return;
    }

    NavigationService.showError(
      context.read<DisputeProvider>().errorMessage ?? errorMessage,
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

  bool get _canReview {
    return _dispute.status == 'open';
  }

  bool get _canRequestResponse {
    return _dispute.status == 'open' || _dispute.status == 'under_review';
  }

  bool get _canMediation {
    return _dispute.status == 'under_review' ||
        _dispute.status == 'awaiting_response';
  }

  bool get _canResolve {
    return _dispute.status == 'open' ||
        _dispute.status == 'under_review' ||
        _dispute.status == 'awaiting_response' ||
        _dispute.status == 'in_mediation' ||
        _dispute.status == 'escalated';
  }

  bool get _canReject {
    return _dispute.status == 'open' ||
        _dispute.status == 'under_review' ||
        _dispute.status == 'awaiting_response';
  }

  bool get _canClose {
    return _dispute.status == 'resolved' || _dispute.status == 'rejected';
  }

  bool get _canEscalate {
    return _dispute.status == 'open' ||
        _dispute.status == 'under_review' ||
        _dispute.status == 'awaiting_response' ||
        _dispute.status == 'in_mediation';
  }

  Widget _buildHeader() {
    return PageHeader(
      title: 'Dispute Details',
      subtitle:
          'View dispute information, involved parties, payment references, mediation, escalation and resolution lifecycle.',
      actions: [
        CustomButton(
          text: 'Back',
          type: ButtonType.outline,
          icon: Icons.arrow_back,
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding24),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDisputeIconBlock(),
                const SizedBox(height: 20),
                _buildDisputeSummaryBlock(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 230,
                child: _buildDisputeIconBlock(),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: _buildDisputeSummaryBlock(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDisputeIconBlock() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding20),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.gavel_outlined,
            color: _statusColor,
            size: 56,
          ),
          const SizedBox(height: 10),
          Text(
            _dispute.disputeNumber,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _statusColor,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            AppFormatters.formatCurrency(_dispute.amount),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 10),
          _DisputeStatusBadge(
            status: _dispute.status,
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeSummaryBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _DisputeStatusBadge(
              status: _dispute.status,
            ),
            _PriorityBadge(
              priority: _dispute.priority,
            ),
            _DisputeTypeBadge(
              type: _dispute.disputeType,
            ),
            _UserTypeBadge(
              userType: _dispute.userType,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          _dispute.subject.trim().isEmpty ? 'Dispute' : _dispute.subject,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          _dispute.description.trim().isEmpty
              ? 'No description provided.'
              : _dispute.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
        ),
        if (_dispute.responseNote.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          _AlertBox(
            icon: Icons.mark_email_unread_outlined,
            title: 'Response Request Note',
            message: _dispute.responseNote,
            color: Colors.orange,
          ),
        ],
        if (_dispute.escalationReason.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          _AlertBox(
            icon: Icons.priority_high_outlined,
            title: 'Escalation Reason',
            message: _dispute.escalationReason,
            color: AppColors.error,
          ),
        ],
        if (_dispute.rejectionReason.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          _AlertBox(
            icon: Icons.cancel_outlined,
            title: 'Rejection Reason',
            message: _dispute.rejectionReason,
            color: AppColors.error,
          ),
        ],
        if (_dispute.resolution.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          _AlertBox(
            icon: Icons.check_circle_outline,
            title: 'Resolution',
            message: _dispute.resolution,
            color: AppColors.success,
          ),
        ],
      ],
    );
  }

  Widget _buildDisputeInformation() {
    return _SectionCard(
      title: 'Dispute Information',
      icon: Icons.gavel_outlined,
      child: _DetailGrid(
        children: [
          _InfoTile(
            label: 'Dispute ID',
            value: _emptyFallback(_dispute.id),
            icon: Icons.tag_outlined,
          ),
          _InfoTile(
            label: 'Dispute Number',
            value: _emptyFallback(_dispute.disputeNumber),
            icon: Icons.confirmation_number_outlined,
          ),
          _InfoTile(
            label: 'Dispute Type',
            value: AppFormatters.formatStatus(_dispute.disputeType),
            icon: Icons.category_outlined,
          ),
          _InfoTile(
            label: 'Priority',
            value: AppFormatters.formatStatus(_dispute.priority),
            icon: Icons.flag_outlined,
          ),
          _InfoTile(
            label: 'Status',
            value: AppFormatters.formatStatus(_dispute.status),
            icon: Icons.verified_outlined,
          ),
          _InfoTile(
            label: 'Amount',
            value: AppFormatters.formatCurrency(_dispute.amount),
            icon: Icons.currency_rupee_rounded,
          ),
          _InfoTile(
            label: 'Created Date',
            value: _formatDate(_dispute.createdAt),
            icon: Icons.calendar_today_outlined,
          ),
          _InfoTile(
            label: 'Updated Date',
            value: _formatDate(_dispute.updatedAt),
            icon: Icons.update_outlined,
          ),
          _InfoTile(
            label: 'Resolved Date',
            value: _formatDate(_dispute.resolvedAt),
            icon: Icons.task_alt_outlined,
          ),
          _InfoTile(
            label: 'Closed Date',
            value: _formatDate(_dispute.closedAt),
            icon: Icons.lock_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildRaisedByInformation() {
    return _SectionCard(
      title: 'Raised By',
      icon: Icons.person_outline,
      child: _DetailGrid(
        children: [
          _InfoTile(
            label: 'User ID',
            value: _emptyFallback(_dispute.userId),
            icon: Icons.badge_outlined,
          ),
          _InfoTile(
            label: 'User Name',
            value: _emptyFallback(_dispute.userName),
            icon: Icons.account_circle_outlined,
          ),
          _InfoTile(
            label: 'User Type',
            value: AppFormatters.formatStatus(_dispute.userType),
            icon: Icons.groups_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildAgainstInformation() {
    return _SectionCard(
      title: 'Against Information',
      icon: Icons.person_search_outlined,
      child: _DetailGrid(
        children: [
          _InfoTile(
            label: 'Against ID',
            value: _emptyFallback(_dispute.againstId),
            icon: Icons.badge_outlined,
          ),
          _InfoTile(
            label: 'Against Name',
            value: _emptyFallback(_dispute.againstName),
            icon: Icons.person_pin_outlined,
          ),
          _InfoTile(
            label: 'Against Type',
            value: AppFormatters.formatStatus(_dispute.againstType),
            icon: Icons.group_work_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceInformation() {
    return _SectionCard(
      title: 'Reference Information',
      icon: Icons.assignment_outlined,
      child: _DetailGrid(
        children: [
          _InfoTile(
            label: 'Booking ID',
            value: _emptyFallback(_dispute.bookingId),
            icon: Icons.event_available_outlined,
          ),
          _InfoTile(
            label: 'Order ID',
            value: _emptyFallback(_dispute.orderId),
            icon: Icons.shopping_bag_outlined,
          ),
          _InfoTile(
            label: 'Payment ID',
            value: _emptyFallback(_dispute.paymentId),
            icon: Icons.payments_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentInformation() {
    return _SectionCard(
      title: 'Assignment Information',
      icon: Icons.assignment_ind_outlined,
      child: _DetailGrid(
        children: [
          _InfoTile(
            label: 'Assigned To ID',
            value: _emptyFallback(_dispute.assignedToId),
            icon: Icons.badge_outlined,
          ),
          _InfoTile(
            label: 'Assigned To',
            value: _emptyFallback(_dispute.assignedToName),
            icon: Icons.admin_panel_settings_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildLifecycleActions() {
    return _SectionCard(
      title: 'Dispute Lifecycle Actions',
      icon: Icons.admin_panel_settings_outlined,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 760;

          final List<Widget> actions = [
            CustomButton(
              text: 'Assign',
              type: ButtonType.outline,
              icon: Icons.person_add_alt_1_outlined,
              onPressed: _isLoading ? null : _assignDispute,
            ),
            CustomButton(
              text: 'Under Review',
              type: ButtonType.outline,
              icon: Icons.manage_search_outlined,
              onPressed: !_canReview || _isLoading ? null : _markUnderReview,
            ),
            CustomButton(
              text: 'Request Response',
              type: ButtonType.outline,
              icon: Icons.mark_email_unread_outlined,
              onPressed:
                  !_canRequestResponse || _isLoading ? null : _requestResponse,
            ),
            CustomButton(
              text: 'Start Mediation',
              type: ButtonType.outline,
              icon: Icons.handshake_outlined,
              onPressed: !_canMediation || _isLoading ? null : _startMediation,
            ),
            CustomButton(
              text: 'Resolve',
              icon: Icons.check_circle_outline,
              onPressed: !_canResolve || _isLoading ? null : _resolveDispute,
            ),
            CustomButton(
              text: 'Reject',
              type: ButtonType.outline,
              icon: Icons.cancel_outlined,
              onPressed: !_canReject || _isLoading ? null : _rejectDispute,
            ),
            CustomButton(
              text: 'Close',
              type: ButtonType.outline,
              icon: Icons.lock_outline,
              onPressed: !_canClose || _isLoading ? null : _closeDispute,
            ),
            CustomButton(
              text: 'Escalate',
              type: ButtonType.outline,
              icon: Icons.priority_high_outlined,
              onPressed: !_canEscalate || _isLoading ? null : _escalateDispute,
            ),
            CustomButton(
              text: 'Delete',
              type: ButtonType.danger,
              icon: Icons.delete_outline,
              onPressed: _isLoading ? null : _deleteDispute,
            ),
          ];

          if (isCompact) {
            return Column(
              children: actions
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: action,
                      ),
                    ),
                  )
                  .toList(),
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: actions,
          );
        },
      ),
    );
  }

  Color get _statusColor {
    switch (_dispute.status) {
      case 'open':
        return AppColors.warning;
      case 'under_review':
        return AppColors.info;
      case 'awaiting_response':
        return Colors.orange;
      case 'in_mediation':
        return AppColors.primary;
      case 'resolved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'closed':
        return Colors.purple;
      case 'escalated':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  String _emptyFallback(String value) {
    return value.trim().isEmpty ? 'Not Available' : value.trim();
  }

  static String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';

    return AppFormatters.formatDateTime(dateTime);
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
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(
                    AppDimensions.padding24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
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
                      _buildOverviewCard(),
                      const SizedBox(height: 20),
                      _buildDisputeInformation(),
                      const SizedBox(height: 20),
                      _buildRaisedByInformation(),
                      const SizedBox(height: 20),
                      _buildAgainstInformation(),
                      const SizedBox(height: 20),
                      _buildReferenceInformation(),
                      const SizedBox(height: 20),
                      _buildAssignmentInformation(),
                      const SizedBox(height: 20),
                      _buildLifecycleActions(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.08),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<Widget> children;

  const _DetailGrid({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 760;

        if (isCompact) {
          return Column(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 4.4,
          children: children,
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.padding16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
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

class _AlertBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _AlertBox({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.padding16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: color,
                    height: 1.4,
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

class _UserTypeBadge extends StatelessWidget {
  final String userType;

  const _UserTypeBadge({
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (userType) {
      case 'customer':
        color = AppColors.success;
        break;
      case 'provider':
        color = AppColors.info;
        break;
      case 'admin':
        color = Colors.purple;
        break;
      default:
        color = AppColors.primary;
    }

    return _StatusChip(
      label: AppFormatters.formatStatus(userType),
      color: color,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}