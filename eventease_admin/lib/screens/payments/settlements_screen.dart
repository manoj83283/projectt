import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/settlement_model.dart';
import '../../providers/payment_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/pagination_widget.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedProvider;

  final List<String> _settlementStatuses = const [
    'pending',
    'approved',
    'processing',
    'paid',
    'failed',
    'rejected',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSettlements();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSettlements() async {
    await context.read<PaymentProvider>().getSettlements(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          providerId: _selectedProvider,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchSettlements();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchSettlements();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchSettlements();
  }

  void _onProviderChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedProvider = value;
    });

    _fetchSettlements();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedStatus = null;
      _selectedProvider = null;
      _searchController.clear();
    });

    _fetchSettlements();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchSettlements();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchSettlements();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchSettlements();
  }

  Future<void> _viewSettlement(SettlementModel settlement) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 660,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.padding24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Settlement Details',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(
                    label: 'Settlement ID',
                    value: settlement.id,
                  ),
                  _DetailRow(
                    label: 'Provider',
                    value: settlement.providerName,
                  ),
                  _DetailRow(
                    label: 'Provider ID',
                    value: settlement.providerId,
                  ),
                  _DetailRow(
                    label: 'Amount',
                    value: AppFormatters.formatCurrency(settlement.amount),
                  ),
                  _DetailRow(
                    label: 'Commission',
                    value:
                        AppFormatters.formatCurrency(settlement.commission),
                  ),
                  _DetailRow(
                    label: 'Net Amount',
                    value: AppFormatters.formatCurrency(settlement.netAmount),
                  ),
                  _DetailRow(
                    label: 'Method',
                    value: AppFormatters.formatStatus(
                      settlement.paymentMethod,
                    ),
                  ),
                  _DetailRow(
                    label: 'Account',
                    value: _maskAccountNumber(settlement.accountNumber),
                  ),
                  _DetailRow(
                    label: 'Bank Name',
                    value: settlement.bankName.isEmpty
                        ? 'Not Available'
                        : settlement.bankName,
                  ),
                  _DetailRow(
                    label: 'IFSC Code',
                    value: settlement.ifscCode.isEmpty
                        ? 'Not Available'
                        : settlement.ifscCode,
                  ),
                  _DetailRow(
                    label: 'Request Date',
                    value: _formatDate(settlement.requestedAt),
                  ),
                  _DetailRow(
                    label: 'Paid Date',
                    value: _formatDate(settlement.paidAt),
                  ),
                  const SizedBox(height: 12),
                  _SettlementStatusBadge(
                    status: settlement.status,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _approveSettlement(SettlementModel settlement) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Approve Settlement',
      message: 'Are you sure you want to approve this settlement?',
      confirmText: 'Approve',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<PaymentProvider>()
        .approveSettlement(settlement.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Settlement approved successfully',
      errorMessage: 'Failed to approve settlement',
    );
  }

  Future<void> _rejectSettlement(SettlementModel settlement) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Reject Settlement'),
          content: TextField(
            controller: reasonController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Rejection Reason',
              hintText: 'Enter valid rejection reason',
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
                final value = reasonController.text.trim();

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

    final bool success = await context.read<PaymentProvider>().rejectSettlement(
          settlementId: settlement.id,
          reason: reason,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Settlement rejected successfully',
      errorMessage: 'Failed to reject settlement',
    );
  }

  Future<void> _processSettlement(SettlementModel settlement) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Process Settlement',
      message: 'Do you want to start processing this settlement?',
      confirmText: 'Process',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<PaymentProvider>()
        .processSettlement(settlement.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Settlement moved to processing',
      errorMessage: 'Failed to process settlement',
    );
  }

  Future<void> _markSettlementPaid(SettlementModel settlement) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Mark Settlement Paid',
      message: 'Are you sure you want to mark this settlement as paid?',
      confirmText: 'Mark Paid',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<PaymentProvider>()
        .markSettlementPaid(settlement.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Settlement marked as paid successfully',
      errorMessage: 'Failed to mark settlement as paid',
    );
  }

  Future<void> _exportSettlements() async {
    await context.read<PaymentProvider>().exportSettlements();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settlements export started successfully'),
        backgroundColor: AppColors.success,
      ),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : errorMessage),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );

    if (success) {
      _fetchSettlements();
    }
  }

  Widget _buildHeader(PaymentProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settlements',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage provider payouts, commission deductions, bank settlements, and payout approvals.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _exportSettlements,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 900;

            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isCompact ? 2 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isCompact ? 1.75 : 1.65,
              ),
              children: [
                _SettlementSummaryCard(
                  title: 'Total Settlement',
                  value: AppFormatters.formatCurrency(
                    provider.totalSettlementAmount,
                  ),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.success,
                ),
                _SettlementSummaryCard(
                  title: 'Pending',
                  value: provider.pendingSettlements.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.warning,
                ),
                _SettlementSummaryCard(
                  title: 'Paid',
                  value: provider.paidSettlements.toString(),
                  icon: Icons.task_alt_outlined,
                  color: AppColors.success,
                ),
                _SettlementSummaryCard(
                  title: 'Failed',
                  value: provider.failedSettlements.toString(),
                  icon: Icons.error_outline,
                  color: AppColors.error,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters(PaymentProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(AppDimensions.padding20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            hintText: 'Search settlement id, provider name, account number...',
            onChanged: _onSearch,
            onClear: _clearFilters,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 760;

              if (isCompact) {
                return Column(
                  children: [
                    _buildStatusDropdown(),
                    const SizedBox(height: 14),
                    _buildProviderDropdown(provider),
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
                  Expanded(child: _buildProviderDropdown(provider)),
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
      labelText: 'Settlement Status',
      value: _selectedStatus,
      items: _settlementStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
    );
  }

  Widget _buildProviderDropdown(PaymentProvider provider) {
    return CustomDropdown<String>(
      labelText: 'Provider',
      value: _selectedProvider,
      items: provider.providerIds,
      onChanged: _onProviderChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (
        context,
        paymentProvider,
        child,
      ) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
              AppDimensions.padding24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(paymentProvider),
                _buildFilters(paymentProvider),
                if (paymentProvider.errorMessage != null)
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
                      paymentProvider.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                SettlementsTable(
                  settlements: paymentProvider.settlements,
                  isLoading: paymentProvider.isLoading,
                  onView: _viewSettlement,
                  onApprove: _approveSettlement,
                  onReject: _rejectSettlement,
                  onProcess: _processSettlement,
                  onPaid: _markSettlementPaid,
                ),
                const SizedBox(height: 20),
                PaginationWidget(
                  currentPage: paymentProvider.currentPage,
                  totalPages: paymentProvider.totalPages,
                  totalRecords: paymentProvider.totalSettlements,
                  pageSize: _limit,
                  onPrevious: _previousPage,
                  onNext: () {
                    _nextPage(
                      paymentProvider.totalPages,
                    );
                  },
                  onPageSelected: _goToPage,
                ),
              ],
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

  static String _maskAccountNumber(String accountNumber) {
    if (accountNumber.trim().isEmpty) return 'Not Available';

    final String value = accountNumber.trim();

    if (value.length <= 4) return value;

    return 'XXXX XXXX ${value.substring(value.length - 4)}';
  }
}

class SettlementsTable extends StatelessWidget {
  final List<SettlementModel> settlements;
  final bool isLoading;
  final ValueChanged<SettlementModel> onView;
  final ValueChanged<SettlementModel> onApprove;
  final ValueChanged<SettlementModel> onReject;
  final ValueChanged<SettlementModel> onProcess;
  final ValueChanged<SettlementModel> onPaid;

  const SettlementsTable({
    super.key,
    required this.settlements,
    required this.isLoading,
    required this.onView,
    required this.onApprove,
    required this.onReject,
    required this.onProcess,
    required this.onPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          else if (settlements.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No settlements found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Settlements matching your filters will appear here.',
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
                dataRowMinHeight: 66,
                dataRowMaxHeight: 78,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Settlement ID')),
                  DataColumn(label: Text('Provider')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Commission')),
                  DataColumn(label: Text('Net Amount')),
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Account')),
                  DataColumn(label: Text('Request Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: settlements.map(
                  (settlement) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _SettlementInfoCell(
                            settlement: settlement,
                          ),
                        ),
                        DataCell(
                          _ProviderCell(
                            settlement: settlement,
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(settlement.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              settlement.commission,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              settlement.netAmount,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        DataCell(
                          _MethodChip(
                            method: settlement.paymentMethod,
                          ),
                        ),
                        DataCell(
                          _AccountCell(
                            settlement: settlement,
                          ),
                        ),
                        DataCell(
                          Text(
                            _SettlementsScreenState._formatDate(
                              settlement.requestedAt,
                            ),
                          ),
                        ),
                        DataCell(
                          _SettlementStatusBadge(
                            status: settlement.status,
                          ),
                        ),
                        DataCell(
                          _SettlementActions(
                            settlement: settlement,
                            onView: onView,
                            onApprove: onApprove,
                            onReject: onReject,
                            onProcess: onProcess,
                            onPaid: onPaid,
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

class _SettlementInfoCell extends StatelessWidget {
  final SettlementModel settlement;

  const _SettlementInfoCell({
    required this.settlement,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            settlement.id,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            settlement.providerId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCell extends StatelessWidget {
  final SettlementModel settlement;

  const _ProviderCell({
    required this.settlement,
  });

  @override
  Widget build(BuildContext context) {
    final String providerName = settlement.providerName.trim().isEmpty
        ? 'Unknown Provider'
        : settlement.providerName.trim();

    return SizedBox(
      width: 180,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              providerName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              providerName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCell extends StatelessWidget {
  final SettlementModel settlement;

  const _AccountCell({
    required this.settlement,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _SettlementsScreenState._maskAccountNumber(
              settlement.accountNumber,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            settlement.bankName.isEmpty ? 'Bank not available' : settlement.bankName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String method;

  const _MethodChip({
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: AppFormatters.formatStatus(method),
      color: AppColors.primary,
    );
  }
}

class _SettlementStatusBadge extends StatelessWidget {
  final String status;

  const _SettlementStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        break;
      case 'approved':
        color = AppColors.info;
        break;
      case 'processing':
        color = AppColors.primary;
        break;
      case 'paid':
        color = AppColors.success;
        break;
      case 'failed':
        color = AppColors.error;
        break;
      case 'rejected':
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

class _SettlementActions extends StatelessWidget {
  final SettlementModel settlement;
  final ValueChanged<SettlementModel> onView;
  final ValueChanged<SettlementModel> onApprove;
  final ValueChanged<SettlementModel> onReject;
  final ValueChanged<SettlementModel> onProcess;
  final ValueChanged<SettlementModel> onPaid;

  const _SettlementActions({
    required this.settlement,
    required this.onView,
    required this.onApprove,
    required this.onReject,
    required this.onProcess,
    required this.onPaid,
  });

  @override
  Widget build(BuildContext context) {
    final bool canApprove = settlement.status == 'pending';
    final bool canReject = settlement.status == 'pending' ||
        settlement.status == 'approved';
    final bool canProcess = settlement.status == 'approved';
    final bool canMarkPaid = settlement.status == 'processing';

    return PopupMenuButton<String>(
      tooltip: 'Settlement Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(settlement);
            break;
          case 'approve':
            onApprove(settlement);
            break;
          case 'reject':
            onReject(settlement);
            break;
          case 'process':
            onProcess(settlement);
            break;
          case 'paid':
            onPaid(settlement);
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
          value: 'approve',
          enabled: canApprove,
          child: _MenuItem(
            icon: Icons.check_circle_outline,
            label: 'Approve',
            color: canApprove ? AppColors.success : Colors.grey,
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
          value: 'process',
          enabled: canProcess,
          child: _MenuItem(
            icon: Icons.sync_outlined,
            label: 'Process',
            color: canProcess ? AppColors.primary : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'paid',
          enabled: canMarkPaid,
          child: _MenuItem(
            icon: Icons.payments_outlined,
            label: 'Mark Paid',
            color: canMarkPaid ? AppColors.success : Colors.grey,
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

class _SettlementSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SettlementSummaryCard({
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
        borderRadius: BorderRadius.circular(18),
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
            Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Settlement Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Provider payout operational view',
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