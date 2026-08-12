import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/refund_model.dart';
import '../../providers/payment_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class RefundsScreen extends StatefulWidget {
  const RefundsScreen({
    super.key,
  });

  @override
  State<RefundsScreen> createState() => _RefundsScreenState();
}

class _RefundsScreenState extends State<RefundsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _selectedStatus;
  String? _selectedType;

  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadRefunds();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD REFUNDS
  // =====================================================

  Future<void> _loadRefunds({
    int page = 1,
  }) async {
    _page = page;

    await context.read<PaymentProvider>().getRefunds(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          type: _selectedType,
        );
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<void> _onSearch(
    String value,
  ) async {
    await _loadRefunds(
      page: 1,
    );
  }

  // =====================================================
  // STATUS FILTER
  // =====================================================

  Future<void> _onStatusChanged(
    String? value,
  ) async {
    setState(() {
      _selectedStatus = value;
    });

    await _loadRefunds(
      page: 1,
    );
  }

  // =====================================================
  // TYPE FILTER
  // =====================================================

  Future<void> _onTypeChanged(
    String? value,
  ) async {
    setState(() {
      _selectedType = value;
    });

    await _loadRefunds(
      page: 1,
    );
  }

  // =====================================================
  // CLEAR FILTERS
  // =====================================================

  Future<void> _clearFilters() async {
    _searchController.clear();

    setState(() {
      _selectedStatus = null;
      _selectedType = null;
      _page = 1;
    });

    await _loadRefunds(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadRefunds(
      page: _page,
    );
  }

  // =====================================================
  // VIEW REFUND
  // =====================================================

  void _viewRefund(
    RefundModel refund,
  ) {
    _showRefundDetailsDialog(
      refund,
    );
  }

  // =====================================================
  // APPROVE REFUND
  // =====================================================

  Future<void> _approveRefund(
    RefundModel refund,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Approve Refund',
          ),
          content: Text(
            'Are you sure you want to approve refund ${refund.refundNumber.isNotEmpty ? refund.refundNumber : refund.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                AppStrings.cancel,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Approve',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await context.read<PaymentProvider>().approveRefund(
          refund.id,
        );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Refund approved successfully',
      );

      await _refresh();
    } else {
      _showPaymentError();
    }
  }

  // =====================================================
  // REJECT REFUND
  // =====================================================

  Future<void> _rejectRefund(
    RefundModel refund,
  ) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Reject Refund',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter rejection reason for refund ${refund.refundNumber.isNotEmpty ? refund.refundNumber : refund.id}.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Rejection reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                AppStrings.cancel,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      reasonController.dispose();
      return;
    }

    final reason = reasonController.text.trim();

    reasonController.dispose();

    if (reason.isEmpty) {
      NavigationService.showWarning(
        'Rejection reason is required',
      );
      return;
    }

    final success = await context.read<PaymentProvider>().rejectRefund(
          refundId: refund.id,
          reason: reason,
        );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Refund rejected successfully',
      );

      await _refresh();
    } else {
      _showPaymentError();
    }
  }

  // =====================================================
  // PROCESS REFUND
  // =====================================================

  Future<void> _processRefund(
    RefundModel refund,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Process Refund',
          ),
          content: Text(
            'Are you sure you want to process refund ${refund.refundNumber.isNotEmpty ? refund.refundNumber : refund.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                AppStrings.cancel,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Process',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success = await context.read<PaymentProvider>().processRefund(
          refund.id,
        );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Refund processing started',
      );

      await _refresh();
    } else {
      _showPaymentError();
    }
  }

  // =====================================================
  // MARK REFUND COMPLETED
  // =====================================================

  Future<void> _markRefundCompleted(
    RefundModel refund,
  ) async {
    final transactionController = TextEditingController(
      text: refund.refundTransactionId,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Mark Refund Completed',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter refund transaction ID for ${refund.refundNumber.isNotEmpty ? refund.refundNumber : refund.id}.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: transactionController,
                decoration: const InputDecoration(
                  labelText: 'Refund Transaction ID',
                  hintText: 'Example: rfnd_xxxxx',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                AppStrings.cancel,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Complete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      transactionController.dispose();
      return;
    }

    final transactionId = transactionController.text.trim();

    transactionController.dispose();

    if (transactionId.isEmpty) {
      NavigationService.showWarning(
        'Refund transaction ID is required',
      );
      return;
    }

    final success = await context.read<PaymentProvider>().markRefundCompleted(
          refundId: refund.id,
          transactionId: transactionId,
        );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Refund marked as completed',
      );

      await _refresh();
    } else {
      _showPaymentError();
    }
  }

  // =====================================================
  // EXPORT REFUNDS
  // =====================================================

  Future<void> _exportRefunds() async {
    await context.read<PaymentProvider>().exportRefunds();

    if (!mounted) return;

    NavigationService.showSuccess(
      'Refund export started',
    );
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showPaymentError() {
    final error = context.read<PaymentProvider>().errorMessage;

    NavigationService.showError(
      error ?? AppStrings.somethingWentWrong,
    );
  }

  // =====================================================
  // PAGINATION
  // =====================================================

  Future<void> _previousPage() async {
    if (_page <= 1) return;

    await _loadRefunds(
      page: _page - 1,
    );
  }

  Future<void> _nextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadRefunds(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadRefunds(
      page: page,
    );
  }

  // =====================================================
  // REFUND DETAILS DIALOG
  // =====================================================

  void _showRefundDetailsDialog(
    RefundModel refund,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            refund.refundNumber.isNotEmpty ? refund.refundNumber : 'Refund Details',
          ),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DialogInfoRow(
                    label: 'Refund ID',
                    value: refund.id,
                  ),
                  _DialogInfoRow(
                    label: 'Payment ID',
                    value: refund.paymentId,
                  ),
                  _DialogInfoRow(
                    label: 'Reference',
                    value: refund.referenceNumber,
                  ),
                  _DialogInfoRow(
                    label: 'Customer',
                    value: refund.customerName,
                  ),
                  _DialogInfoRow(
                    label: 'Amount',
                    value: AppFormatters.formatCurrency(
                      refund.amount,
                    ),
                  ),
                  _DialogInfoRow(
                    label: 'Type',
                    value: AppFormatters.formatStatus(
                      refund.refundType,
                    ),
                  ),
                  _DialogInfoRow(
                    label: 'Status',
                    value: AppFormatters.formatStatus(
                      refund.status,
                    ),
                  ),
                  _DialogInfoRow(
                    label: 'Reason',
                    value: refund.reason,
                  ),
                  _DialogInfoRow(
                    label: 'Transaction ID',
                    value: refund.refundTransactionId.isNotEmpty
                        ? refund.refundTransactionId
                        : '-',
                  ),
                  _DialogInfoRow(
                    label: 'Requested',
                    value: AppFormatters.formatDateTime(
                      refund.requestedAt,
                    ),
                  ),
                  _DialogInfoRow(
                    label: 'Processed',
                    value: refund.processedAt != null
                        ? AppFormatters.formatDateTime(
                            refund.processedAt,
                          )
                        : '-',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Refunds',
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Export Refunds',
            onPressed: _exportRefunds,
            icon: const Icon(
              Icons.download_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Consumer<PaymentProvider>(
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
                    _buildHeader(
                      paymentProvider,
                    ),

                    const SizedBox(
                      height: AppDimensions.padding24,
                    ),

                    _buildFilters(),

                    const SizedBox(
                      height: AppDimensions.padding20,
                    ),

                    if (paymentProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: paymentProvider.errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    RefundsTable(
                      refunds: paymentProvider.refunds,
                      isLoading: paymentProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewRefund,
                      onApprove: _approveRefund,
                      onReject: _rejectRefund,
                      onProcess: _processRefund,
                      onComplete: _markRefundCompleted,
                    ),

                    const SizedBox(
                      height: AppDimensions.padding16,
                    ),

                    PaginationWidget(
                      currentPage: paymentProvider.currentPage,
                      totalPages: paymentProvider.totalPages,
                      totalRecords: paymentProvider.totalRefunds,
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
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(
    PaymentProvider provider,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final bool isMobile = constraints.maxWidth < 950;

        final titleSection = Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Refunds',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage customer refunds, payment reversals, failed payment refunds, order refunds, booking refunds, and finance approval workflow.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        );

        final summaryCards = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _RefundSummaryCard(
              title: 'Total Refunds',
              value: provider.totalRefunds.toString(),
              icon: Icons.currency_exchange_outlined,
              color: AppColors.primary,
            ),
            _RefundSummaryCard(
              title: 'Refund Amount',
              value: AppFormatters.formatCurrency(
                provider.totalRefundAmount,
              ),
              icon: Icons.currency_rupee_rounded,
              color: AppColors.success,
            ),
            _RefundSummaryCard(
              title: 'Pending',
              value: provider.pendingRefunds.toString(),
              icon: Icons.pending_actions_outlined,
              color: AppColors.warning,
            ),
            _RefundSummaryCard(
              title: 'Completed',
              value: provider.completedRefunds.toString(),
              icon: Icons.check_circle_outline,
              color: AppColors.success,
            ),
            _RefundSummaryCard(
              title: 'Rejected',
              value: provider.rejectedRefunds.toString(),
              icon: Icons.cancel_outlined,
              color: AppColors.error,
            ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  titleSection,
                ],
              ),
              const SizedBox(height: 16),
              summaryCards,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleSection,
            const SizedBox(width: 16),
            summaryCards,
          ],
        );
      },
    );
  }

  // =====================================================
  // FILTERS
  // =====================================================

  Widget _buildFilters() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding16,
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool isMobile = constraints.maxWidth < 900;

            final search = CustomSearchBar(
              controller: _searchController,
              hintText: 'Search refund id, payment id, customer, reference...',
              onChanged: _onSearch,
              onClear: _clearFilters,
            );

            final statusDropdown = CustomDropdown<String>(
              labelText: 'Refund Status',
              hintText: 'All Status',
              value: _selectedStatus,
              items: const [
                'pending',
                'approved',
                'processing',
                'completed',
                'failed',
                'rejected',
              ],
              itemLabelBuilder: AppFormatters.formatStatus,
              onChanged: _onStatusChanged,
              prefixIcon: const Icon(
                Icons.filter_alt_outlined,
              ),
            );

            final typeDropdown = CustomDropdown<String>(
              labelText: 'Refund Type',
              hintText: 'All Types',
              value: _selectedType,
              items: const [
                'booking',
                'order',
                'payment',
                'partial',
                'full',
              ],
              itemLabelBuilder: AppFormatters.formatStatus,
              onChanged: _onTypeChanged,
              prefixIcon: const Icon(
                Icons.category_outlined,
              ),
            );

            final clearButton = CustomButton(
              text: 'Clear',
              type: ButtonType.outline,
              icon: Icons.clear_rounded,
              onPressed: _clearFilters,
            );

            if (isMobile) {
              return Column(
                children: [
                  search,
                  const SizedBox(height: 12),
                  statusDropdown,
                  const SizedBox(height: 12),
                  typeDropdown,
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: clearButton,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: search,
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 220,
                  child: statusDropdown,
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 220,
                  child: typeDropdown,
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 130,
                  child: clearButton,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =====================================================
// REFUNDS TABLE
// =====================================================

class RefundsTable extends StatelessWidget {
  final List<RefundModel> refunds;
  final bool isLoading;

  final VoidCallback? onRefresh;

  final Function(RefundModel refund)? onView;
  final Function(RefundModel refund)? onApprove;
  final Function(RefundModel refund)? onReject;
  final Function(RefundModel refund)? onProcess;
  final Function(RefundModel refund)? onComplete;

  const RefundsTable({
    super.key,
    required this.refunds,
    this.isLoading = false,
    this.onRefresh,
    this.onView,
    this.onApprove,
    this.onReject,
    this.onProcess,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading refunds...',
      );
    }

    if (refunds.isEmpty) {
      return EmptyWidget(
        icon: Icons.currency_exchange_outlined,
        title: 'No Refunds Found',
        description: 'Refund requests and processed refunds will appear here.',
        buttonText: AppStrings.refresh,
        onButtonPressed: onRefresh,
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: AppDimensions.headingRowHeight,
            dataRowMinHeight: AppDimensions.dataRowHeight,
            dataRowMaxHeight: AppDimensions.dataRowHeight,
            headingRowColor: WidgetStateProperty.all(
              AppColors.background,
            ),
            columnSpacing: 28,
            horizontalMargin: 20,
            columns: const [
              DataColumn(
                label: _TableHeader(
                  title: 'Refund',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Reference',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Customer',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Amount',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Type',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Status',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Transaction',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Requested',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Actions',
                ),
              ),
            ],
            rows: refunds.map(
              (refund) {
                return DataRow(
                  cells: [
                    DataCell(
                      _RefundInfoCell(
                        refund: refund,
                      ),
                    ),
                    DataCell(
                      _ReferenceCell(
                        refund: refund,
                      ),
                    ),
                    DataCell(
                      _CustomerCell(
                        refund: refund,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatCurrency(
                          refund.amount,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    DataCell(
                      _RefundTypeBadge(
                        type: refund.refundType,
                      ),
                    ),
                    DataCell(
                      _RefundStatusBadge(
                        status: refund.status,
                      ),
                    ),
                    DataCell(
                      Text(
                        refund.refundTransactionId.isNotEmpty
                            ? refund.refundTransactionId
                            : '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatDate(
                          refund.requestedAt,
                        ),
                      ),
                    ),
                    DataCell(
                      _RefundActions(
                        refund: refund,
                        onView: onView,
                        onApprove: onApprove,
                        onReject: onReject,
                        onProcess: onProcess,
                        onComplete: onComplete,
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TABLE HEADER
// =====================================================

class _TableHeader extends StatelessWidget {
  final String title;

  const _TableHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// =====================================================
// REFUND INFO CELL
// =====================================================

class _RefundInfoCell extends StatelessWidget {
  final RefundModel refund;

  const _RefundInfoCell({
    required this.refund,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 220,
        maxWidth: 300,
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(
                AppDimensions.radius12,
              ),
            ),
            child: const Icon(
              Icons.currency_exchange_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  refund.refundNumber.isNotEmpty ? refund.refundNumber : refund.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  refund.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

// =====================================================
// REFERENCE CELL
// =====================================================

class _ReferenceCell extends StatelessWidget {
  final RefundModel refund;

  const _ReferenceCell({
    required this.refund,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 180,
        maxWidth: 260,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            refund.referenceNumber.isNotEmpty ? refund.referenceNumber : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            refund.paymentId.isNotEmpty ? refund.paymentId : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// CUSTOMER CELL
// =====================================================

class _CustomerCell extends StatelessWidget {
  final RefundModel refund;

  const _CustomerCell({
    required this.refund,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 170,
        maxWidth: 230,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            refund.customerName.isNotEmpty ? refund.customerName : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            refund.customerId.isNotEmpty ? refund.customerId : '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// REFUND TYPE BADGE
// =====================================================

class _RefundTypeBadge extends StatelessWidget {
  final String type;

  const _RefundTypeBadge({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: type.isNotEmpty ? AppFormatters.formatStatus(type) : '-',
      color: AppColors.info,
    );
  }
}

// =====================================================
// REFUND STATUS BADGE
// =====================================================

class _RefundStatusBadge extends StatelessWidget {
  final String status;

  const _RefundStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: status.isNotEmpty ? AppFormatters.formatStatus(status) : 'Pending',
      color: _statusColor(status),
    );
  }

  static Color _statusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.info;

      case 'processing':
        return AppColors.primary;

      case 'completed':
      case 'paid':
      case 'success':
        return AppColors.success;

      case 'failed':
      case 'rejected':
        return AppColors.error;

      case 'pending':
      default:
        return AppColors.warning;
    }
  }
}

// =====================================================
// REFUND ACTIONS
// =====================================================

class _RefundActions extends StatelessWidget {
  final RefundModel refund;

  final Function(RefundModel refund)? onView;
  final Function(RefundModel refund)? onApprove;
  final Function(RefundModel refund)? onReject;
  final Function(RefundModel refund)? onProcess;
  final Function(RefundModel refund)? onComplete;

  const _RefundActions({
    required this.refund,
    this.onView,
    this.onApprove,
    this.onReject,
    this.onProcess,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final status = refund.status.toLowerCase();

    final isPending = status == 'pending';
    final isApproved = status == 'approved';
    final isProcessing = status == 'processing';

    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: const Icon(
        Icons.more_vert,
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView?.call(refund);
            break;

          case 'approve':
            onApprove?.call(refund);
            break;

          case 'reject':
            onReject?.call(refund);
            break;

          case 'process':
            onProcess?.call(refund);
            break;

          case 'complete':
            onComplete?.call(refund);
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[];

        if (onView != null) {
          items.add(
            const PopupMenuItem(
              value: 'view',
              child: _MenuItem(
                icon: Icons.visibility_outlined,
                label: 'View Details',
              ),
            ),
          );
        }

        if (isPending && onApprove != null) {
          items.add(
            const PopupMenuItem(
              value: 'approve',
              child: _MenuItem(
                icon: Icons.check_circle_outline,
                label: 'Approve',
                color: AppColors.success,
              ),
            ),
          );
        }

        if (isPending && onReject != null) {
          items.add(
            const PopupMenuItem(
              value: 'reject',
              child: _MenuItem(
                icon: Icons.cancel_outlined,
                label: 'Reject',
                color: AppColors.error,
              ),
            ),
          );
        }

        if (isApproved && onProcess != null) {
          items.add(
            const PopupMenuItem(
              value: 'process',
              child: _MenuItem(
                icon: Icons.sync_outlined,
                label: 'Process Refund',
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (isProcessing && onComplete != null) {
          items.add(
            const PopupMenuItem(
              value: 'complete',
              child: _MenuItem(
                icon: Icons.done_all_outlined,
                label: 'Mark Completed',
                color: AppColors.success,
              ),
            ),
          );
        }

        return items;
      },
    );
  }
}

// =====================================================
// MENU ITEM
// =====================================================

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
    final itemColor = color ?? AppColors.textPrimary;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: itemColor,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: itemColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// SUMMARY CARD
// =====================================================

class _RefundSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _RefundSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 165,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(
                AppDimensions.radius12,
              ),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================
// STATUS CHIP
// =====================================================

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
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =====================================================
// DIALOG INFO ROW
// =====================================================

class _DialogInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _DialogInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}