import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/support_ticket_model.dart';
import '../../providers/support_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({
    super.key,
  });

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedPriority;
  String? _selectedCategory;
  String? _selectedUserType;

  final List<String> _ticketStatuses = const [
    'open',
    'in_progress',
    'resolved',
    'closed',
    'reopened',
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
    'account',
    'provider',
    'service',
    'technical',
    'kyc',
    'settlement',
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
      _fetchTickets();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    await context.read<SupportProvider>().getTickets(
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

    await _fetchTickets();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchTickets();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchTickets();
  }

  void _onPriorityChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedPriority = value;
    });

    _fetchTickets();
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedCategory = value;
    });

    _fetchTickets();
  }

  void _onUserTypeChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedUserType = value;
    });

    _fetchTickets();
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

    _fetchTickets();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchTickets();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchTickets();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchTickets();
  }

  Future<void> _viewTicket(SupportTicketModel ticket) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.ticketDetails,
      arguments: ticket,
    );

    if (!mounted) return;

    _fetchTickets();
  }

  Future<void> _assignTicket(SupportTicketModel ticket) async {
    final TextEditingController assigneeController = TextEditingController(
      text: ticket.assignedToId,
    );

    final String? assigneeId = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Assign Ticket'),
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

    final bool success = await context.read<SupportProvider>().assignTicket(
          ticketId: ticket.id,
          assignedToId: assigneeId,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Ticket assigned successfully',
      errorMessage: 'Failed to assign ticket',
    );
  }

  Future<void> _markInProgress(SupportTicketModel ticket) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Mark In Progress',
      message: 'Do you want to mark ticket ${ticket.ticketNumber} as in progress?',
      confirmText: 'Start',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<SupportProvider>().markTicketInProgress(ticket.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Ticket marked as in progress',
      errorMessage: 'Failed to update ticket',
    );
  }

  Future<void> _resolveTicket(SupportTicketModel ticket) async {
    final TextEditingController resolutionController = TextEditingController();

    final String? resolution = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Resolve Ticket'),
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

    final bool success = await context.read<SupportProvider>().resolveTicket(
          ticketId: ticket.id,
          resolution: resolution,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Ticket resolved successfully',
      errorMessage: 'Failed to resolve ticket',
    );
  }

  Future<void> _closeTicket(SupportTicketModel ticket) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Close Ticket',
      message: 'Are you sure you want to close ticket ${ticket.ticketNumber}?',
      confirmText: 'Close',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<SupportProvider>().closeTicket(ticket.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Ticket closed successfully',
      errorMessage: 'Failed to close ticket',
    );
  }

  Future<void> _reopenTicket(SupportTicketModel ticket) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Reopen Ticket',
      message: 'Do you want to reopen ticket ${ticket.ticketNumber}?',
      confirmText: 'Reopen',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<SupportProvider>().reopenTicket(ticket.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Ticket reopened successfully',
      errorMessage: 'Failed to reopen ticket',
    );
  }

  Future<void> _escalateTicket(SupportTicketModel ticket) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Escalate Ticket'),
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

    final bool success = await context.read<SupportProvider>().escalateTicket(
          ticketId: ticket.id,
          reason: reason,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Ticket escalated successfully',
      errorMessage: 'Failed to escalate ticket',
    );
  }

  Future<void> _deleteTicket(SupportTicketModel ticket) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Delete Ticket',
      message:
          'This action cannot be undone. Are you sure you want to delete ticket ${ticket.ticketNumber}?',
      confirmText: 'Delete',
      confirmColor: AppColors.error,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<SupportProvider>().deleteTicket(ticket.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Ticket deleted successfully',
      errorMessage: 'Failed to delete ticket',
    );
  }

  Future<void> _exportTickets() async {
    await context.read<SupportProvider>().exportTickets();

    if (!mounted) return;

    NavigationService.showSuccess(
      'Tickets export started successfully',
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
      _fetchTickets();
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
          title: 'Support Tickets',
          subtitle:
              'Manage customer, provider and admin support issues, escalations, resolutions and SLA tracking.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: _exportTickets,
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
                _TicketSummaryCard(
                  title: 'Total Tickets',
                  value: provider.totalTickets.toString(),
                  icon: Icons.support_agent_outlined,
                  color: AppColors.primary,
                ),
                _TicketSummaryCard(
                  title: 'Open',
                  value: provider.openTickets.toString(),
                  icon: Icons.mark_email_unread_outlined,
                  color: AppColors.warning,
                ),
                _TicketSummaryCard(
                  title: 'In Progress',
                  value: provider.inProgressTickets.toString(),
                  icon: Icons.sync_outlined,
                  color: AppColors.info,
                ),
                _TicketSummaryCard(
                  title: 'Resolved',
                  value: provider.resolvedTickets.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _TicketSummaryCard(
                  title: 'Escalated',
                  value: provider.escalatedTickets.toString(),
                  icon: Icons.priority_high_outlined,
                  color: AppColors.error,
                ),
                _TicketSummaryCard(
                  title: 'Closed',
                  value: provider.closedTickets.toString(),
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
            hintText: 'Search ticket id, subject, customer, provider, email...',
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
      labelText: 'Ticket Status',
      value: _selectedStatus,
      items: _ticketStatuses,
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
                  TicketsTable(
                    tickets: provider.tickets,
                    isLoading: provider.isLoading,
                    onView: _viewTicket,
                    onAssign: _assignTicket,
                    onInProgress: _markInProgress,
                    onResolve: _resolveTicket,
                    onClose: _closeTicket,
                    onReopen: _reopenTicket,
                    onEscalate: _escalateTicket,
                    onDelete: _deleteTicket,
                  ),
                  const SizedBox(height: 20),
                  PaginationWidget(
                    currentPage: provider.currentPage,
                    totalPages: provider.totalPages,
                    totalRecords: provider.totalTickets,
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

class TicketsTable extends StatelessWidget {
  final List<SupportTicketModel> tickets;
  final bool isLoading;
  final ValueChanged<SupportTicketModel> onView;
  final ValueChanged<SupportTicketModel> onAssign;
  final ValueChanged<SupportTicketModel> onInProgress;
  final ValueChanged<SupportTicketModel> onResolve;
  final ValueChanged<SupportTicketModel> onClose;
  final ValueChanged<SupportTicketModel> onReopen;
  final ValueChanged<SupportTicketModel> onEscalate;
  final ValueChanged<SupportTicketModel> onDelete;

  const TicketsTable({
    super.key,
    required this.tickets,
    required this.isLoading,
    required this.onView,
    required this.onAssign,
    required this.onInProgress,
    required this.onResolve,
    required this.onClose,
    required this.onReopen,
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
          else if (tickets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.support_agent_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No tickets found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Support tickets matching your filters will appear here.',
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
                  DataColumn(label: Text('Ticket')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Priority')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Assigned To')),
                  DataColumn(label: Text('Created Date')),
                  DataColumn(label: Text('Last Updated')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: tickets.map(
                  (ticket) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _TicketInfoCell(
                            ticket: ticket,
                          ),
                        ),
                        DataCell(
                          _UserCell(
                            ticket: ticket,
                          ),
                        ),
                        DataCell(
                          _CategoryBadge(
                            category: ticket.category,
                          ),
                        ),
                        DataCell(
                          _PriorityBadge(
                            priority: ticket.priority,
                          ),
                        ),
                        DataCell(
                          _TicketStatusBadge(
                            status: ticket.status,
                          ),
                        ),
                        DataCell(
                          _AssigneeCell(
                            ticket: ticket,
                          ),
                        ),
                        DataCell(
                          Text(
                            _TicketsScreenState._formatDate(ticket.createdAt),
                          ),
                        ),
                        DataCell(
                          Text(
                            _TicketsScreenState._formatDate(ticket.updatedAt),
                          ),
                        ),
                        DataCell(
                          _TicketActions(
                            ticket: ticket,
                            onView: onView,
                            onAssign: onAssign,
                            onInProgress: onInProgress,
                            onResolve: onResolve,
                            onClose: onClose,
                            onReopen: onReopen,
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

class _TicketInfoCell extends StatelessWidget {
  final SupportTicketModel ticket;

  const _TicketInfoCell({
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.confirmation_number_outlined,
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
                  ticket.ticketNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.subject,
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
  final SupportTicketModel ticket;

  const _UserCell({
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final String userName =
        ticket.userName.trim().isEmpty ? 'Unknown User' : ticket.userName;

    return SizedBox(
      width: 190,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: _userTypeColor(ticket.userType).withOpacity(0.1),
            child: Text(
              userName[0].toUpperCase(),
              style: TextStyle(
                color: _userTypeColor(ticket.userType),
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
                  AppFormatters.formatStatus(ticket.userType),
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

class _AssigneeCell extends StatelessWidget {
  final SupportTicketModel ticket;

  const _AssigneeCell({
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    final String assignee = ticket.assignedToName.trim().isEmpty
        ? 'Unassigned'
        : ticket.assignedToName;

    final bool assigned = ticket.assignedToName.trim().isNotEmpty;

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
      case 'account':
        color = AppColors.primary;
        break;
      case 'provider':
        color = Colors.teal;
        break;
      case 'service':
        color = Colors.deepPurple;
        break;
      case 'technical':
        color = Colors.blueGrey;
        break;
      case 'kyc':
        color = Colors.orange;
        break;
      case 'settlement':
        color = Colors.indigo;
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

class _TicketStatusBadge extends StatelessWidget {
  final String status;

  const _TicketStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'open':
        color = AppColors.warning;
        break;
      case 'in_progress':
        color = AppColors.info;
        break;
      case 'resolved':
        color = AppColors.success;
        break;
      case 'closed':
        color = Colors.purple;
        break;
      case 'reopened':
        color = AppColors.primary;
        break;
      case 'escalated':
        color = AppColors.error;
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

class _TicketActions extends StatelessWidget {
  final SupportTicketModel ticket;
  final ValueChanged<SupportTicketModel> onView;
  final ValueChanged<SupportTicketModel> onAssign;
  final ValueChanged<SupportTicketModel> onInProgress;
  final ValueChanged<SupportTicketModel> onResolve;
  final ValueChanged<SupportTicketModel> onClose;
  final ValueChanged<SupportTicketModel> onReopen;
  final ValueChanged<SupportTicketModel> onEscalate;
  final ValueChanged<SupportTicketModel> onDelete;

  const _TicketActions({
    required this.ticket,
    required this.onView,
    required this.onAssign,
    required this.onInProgress,
    required this.onResolve,
    required this.onClose,
    required this.onReopen,
    required this.onEscalate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool canStart =
        ticket.status == 'open' || ticket.status == 'reopened';

    final bool canResolve =
        ticket.status == 'open' ||
        ticket.status == 'in_progress' ||
        ticket.status == 'escalated' ||
        ticket.status == 'reopened';

    final bool canClose = ticket.status == 'resolved';

    final bool canReopen =
        ticket.status == 'resolved' || ticket.status == 'closed';

    final bool canEscalate =
        ticket.status == 'open' || ticket.status == 'in_progress';

    return PopupMenuButton<String>(
      tooltip: 'Ticket Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(ticket);
            break;
          case 'assign':
            onAssign(ticket);
            break;
          case 'progress':
            onInProgress(ticket);
            break;
          case 'resolve':
            onResolve(ticket);
            break;
          case 'close':
            onClose(ticket);
            break;
          case 'reopen':
            onReopen(ticket);
            break;
          case 'escalate':
            onEscalate(ticket);
            break;
          case 'delete':
            onDelete(ticket);
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
          value: 'progress',
          enabled: canStart,
          child: _MenuItem(
            icon: Icons.sync_outlined,
            label: 'Mark In Progress',
            color: canStart ? AppColors.info : Colors.grey,
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
          value: 'close',
          enabled: canClose,
          child: _MenuItem(
            icon: Icons.lock_outline,
            label: 'Close',
            color: canClose ? Colors.purple : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'reopen',
          enabled: canReopen,
          child: _MenuItem(
            icon: Icons.refresh_outlined,
            label: 'Reopen',
            color: canReopen ? AppColors.primary : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'escalate',
          enabled: canEscalate,
          child: _MenuItem(
            icon: Icons.priority_high_outlined,
            label: 'Escalate',
            color: canEscalate ? AppColors.error : Colors.grey,
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

class _TicketSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _TicketSummaryCard({
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
            Icons.support_agent_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Support Ticket Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Support operations and SLA overview',
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