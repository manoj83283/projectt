import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction_model.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedMethod;

  final List<String> _transactionStatuses = const [
    'pending',
    'success',
    'failed',
    'cancelled',
    'refunded',
  ];

  final List<String> _paymentMethods = const [
    'upi',
    'card',
    'wallet',
    'net_banking',
    'cash',
    'razorpay',
    'stripe',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions() async {
    await context.read<PaymentProvider>().getTransactions(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          status: _selectedStatus,
          method: _selectedMethod,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchTransactions();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchTransactions();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchTransactions();
  }

  void _onMethodChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedMethod = value;
    });

    _fetchTransactions();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedStatus = null;
      _selectedMethod = null;
      _searchController.clear();
    });

    _fetchTransactions();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchTransactions();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchTransactions();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchTransactions();
  }

  Future<void> _viewTransaction(TransactionModel transaction) async {
    final TransactionModel? details = await context
        .read<PaymentProvider>()
        .getTransactionDetails(transaction.transactionId);

    if (!mounted) return;

    final TransactionModel selectedTransaction = details ?? transaction;

    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 680,
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
                        Icons.receipt_long_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Transaction Details',
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
                    label: 'Transaction ID',
                    value: selectedTransaction.transactionId,
                  ),
                  _DetailRow(
                    label: 'Payment ID',
                    value: selectedTransaction.paymentId,
                  ),
                  _DetailRow(
                    label: 'Reference ID',
                    value: selectedTransaction.referenceId,
                  ),
                  _DetailRow(
                    label: 'Order ID',
                    value: selectedTransaction.orderId,
                  ),
                  _DetailRow(
                    label: 'Booking ID',
                    value: selectedTransaction.bookingId,
                  ),
                  _DetailRow(
                    label: 'Customer',
                    value: selectedTransaction.customerName,
                  ),
                  _DetailRow(
                    label: 'Provider',
                    value: selectedTransaction.providerName.isEmpty
                        ? 'Not Available'
                        : selectedTransaction.providerName,
                  ),
                  _DetailRow(
                    label: 'Amount',
                    value: AppFormatters.formatCurrency(
                      selectedTransaction.amount,
                    ),
                  ),
                  _DetailRow(
                    label: 'Currency',
                    value: selectedTransaction.currency.isEmpty
                        ? 'INR'
                        : selectedTransaction.currency,
                  ),
                  _DetailRow(
                    label: 'Method',
                    value: AppFormatters.formatStatus(
                      selectedTransaction.paymentMethod,
                    ),
                  ),
                  _DetailRow(
                    label: 'Gateway',
                    value: selectedTransaction.gateway.isEmpty
                        ? 'Not Available'
                        : AppFormatters.formatStatus(
                            selectedTransaction.gateway,
                          ),
                  ),
                  _DetailRow(
                    label: 'Created Date',
                    value: _formatDate(selectedTransaction.createdAt),
                  ),
                  const SizedBox(height: 12),
                  _TransactionStatusBadge(
                    status: selectedTransaction.status,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _retryTransaction(TransactionModel transaction) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Retry Transaction',
      message:
          'Are you sure you want to retry transaction ${transaction.transactionId}?',
      confirmText: 'Retry',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<PaymentProvider>()
        .retryTransaction(transaction.transactionId);

    _handleMutationResult(
      success: success,
      successMessage: 'Transaction retry initiated successfully',
      errorMessage: 'Failed to retry transaction',
    );
  }

  Future<void> _refundTransaction(TransactionModel transaction) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Refund Transaction'),
          content: TextField(
            controller: reasonController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Refund Reason',
              hintText: 'Enter valid refund reason',
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
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final String value = reasonController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              icon: const Icon(Icons.currency_exchange),
              label: const Text('Refund'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null || reason.isEmpty) return;

    final bool success =
        await context.read<PaymentProvider>().refundTransaction(
              transactionId: transaction.transactionId,
              reason: reason,
            );

    _handleMutationResult(
      success: success,
      successMessage: 'Transaction refunded successfully',
      errorMessage: 'Failed to refund transaction',
    );
  }

  Future<void> _exportTransactions(TransactionModel transaction) async {
    await context.read<PaymentProvider>().exportTransactions();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transactions export started successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _exportAllTransactions() async {
    await context.read<PaymentProvider>().exportTransactions();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transactions export started successfully'),
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
      _fetchTransactions();
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
                    'Transactions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Track payment gateway transactions, retries, refunds, and payment references.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: _exportAllTransactions,
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
                        ? 2.2
                        : 1.45,
              ),
              children: [
                _TransactionSummaryCard(
                  title: 'Total Transactions',
                  value: provider.totalTransactions.toString(),
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.primary,
                ),
                _TransactionSummaryCard(
                  title: 'Revenue',
                  value: AppFormatters.formatCurrency(
                    provider.totalRevenue,
                  ),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.success,
                ),
                _TransactionSummaryCard(
                  title: 'Successful',
                  value: provider.successTransactions.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _TransactionSummaryCard(
                  title: 'Pending',
                  value: provider.pendingTransactions.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.warning,
                ),
                _TransactionSummaryCard(
                  title: 'Failed',
                  value: provider.failedTransactions.toString(),
                  icon: Icons.error_outline,
                  color: AppColors.error,
                ),
                _TransactionSummaryCard(
                  title: 'Refunded',
                  value: provider.refundedTransactions.toString(),
                  icon: Icons.currency_exchange,
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
        borderRadius: BorderRadius.circular(18),
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
                'Search transaction id, payment id, order id, booking id...',
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
                    _buildMethodDropdown(),
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
                  Expanded(child: _buildMethodDropdown()),
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
      labelText: 'Transaction Status',
      value: _selectedStatus,
      items: _transactionStatuses,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onStatusChanged,
    );
  }

  Widget _buildMethodDropdown() {
    return CustomDropdown<String>(
      labelText: 'Payment Method',
      value: _selectedMethod,
      items: _paymentMethods,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onMethodChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (
        context,
        transactionProvider,
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
                _buildHeader(transactionProvider),
                _buildFilters(),
                if (transactionProvider.errorMessage != null)
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
                      transactionProvider.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                TransactionsTable(
                  transactions: transactionProvider.transactions,
                  isLoading: transactionProvider.isLoading,
                  onView: _viewTransaction,
                  onRetry: _retryTransaction,
                  onRefund: _refundTransaction,
                  onExport: _exportTransactions,
                ),
                const SizedBox(height: 20),
                PaginationWidget(
                  currentPage: transactionProvider.currentPage,
                  totalPages: transactionProvider.totalPages,
                  totalRecords: transactionProvider.totalTransactions,
                  pageSize: _limit,
                  onPrevious: _previousPage,
                  onNext: () {
                    _nextPage(
                      transactionProvider.totalPages,
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
}

class TransactionsTable extends StatelessWidget {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final ValueChanged<TransactionModel> onView;
  final ValueChanged<TransactionModel> onRetry;
  final ValueChanged<TransactionModel> onRefund;
  final ValueChanged<TransactionModel> onExport;

  const TransactionsTable({
    super.key,
    required this.transactions,
    required this.isLoading,
    required this.onView,
    required this.onRetry,
    required this.onRefund,
    required this.onExport,
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
          else if (transactions.isEmpty)
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
                    'No transactions found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Transactions matching your filters will appear here.',
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
                  DataColumn(label: Text('Transaction ID')),
                  DataColumn(label: Text('Reference ID')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Provider')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Gateway')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Created Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: transactions.map(
                  (transaction) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _TransactionInfoCell(
                            transaction: transaction,
                          ),
                        ),
                        DataCell(
                          _ReferenceCell(
                            transaction: transaction,
                          ),
                        ),
                        DataCell(
                          _CustomerCell(
                            transaction: transaction,
                          ),
                        ),
                        DataCell(
                          _ProviderCell(
                            transaction: transaction,
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(transaction.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        DataCell(
                          _MethodChip(
                            method: transaction.paymentMethod,
                          ),
                        ),
                        DataCell(
                          _GatewayChip(
                            gateway: transaction.gateway,
                          ),
                        ),
                        DataCell(
                          _TransactionStatusBadge(
                            status: transaction.status,
                          ),
                        ),
                        DataCell(
                          Text(
                            _TransactionsScreenState._formatDate(
                              transaction.createdAt,
                            ),
                          ),
                        ),
                        DataCell(
                          _TransactionActions(
                            transaction: transaction,
                            onView: onView,
                            onRetry: onRetry,
                            onRefund: onRefund,
                            onExport: onExport,
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

class _TransactionInfoCell extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionInfoCell({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.transactionId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            transaction.paymentId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceCell extends StatelessWidget {
  final TransactionModel transaction;

  const _ReferenceCell({
    required this.transaction,
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
            transaction.referenceId.isEmpty
                ? 'Ref: Not Available'
                : 'Ref: ${transaction.referenceId}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            transaction.orderId.isNotEmpty
                ? 'Order: ${transaction.orderId}'
                : 'Booking: ${transaction.bookingId}',
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

class _CustomerCell extends StatelessWidget {
  final TransactionModel transaction;

  const _CustomerCell({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final String customerName = transaction.customerName.trim().isEmpty
        ? 'Unknown Customer'
        : transaction.customerName.trim();

    return SizedBox(
      width: 175,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              customerName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              customerName,
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

class _ProviderCell extends StatelessWidget {
  final TransactionModel transaction;

  const _ProviderCell({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final String providerName = transaction.providerName.trim().isEmpty
        ? 'Not Assigned'
        : transaction.providerName.trim();

    final bool hasProvider = transaction.providerName.trim().isNotEmpty;

    return SizedBox(
      width: 175,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: hasProvider
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.warning.withValues(alpha: 0.1),
            child: Icon(
              hasProvider ? Icons.person_outline : Icons.person_off_outlined,
              size: 18,
              color: hasProvider ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              providerName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: hasProvider ? Colors.black87 : AppColors.warning,
              ),
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

class _GatewayChip extends StatelessWidget {
  final String gateway;

  const _GatewayChip({
    required this.gateway,
  });

  @override
  Widget build(BuildContext context) {
    final String label = gateway.trim().isEmpty
        ? 'Not Available'
        : AppFormatters.formatStatus(gateway);

    return _StatusChip(
      label: label,
      color: Colors.blueGrey,
    );
  }
}

class _TransactionStatusBadge extends StatelessWidget {
  final String status;

  const _TransactionStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'success':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'failed':
        color = AppColors.error;
        break;
      case 'cancelled':
        color = Colors.grey;
        break;
      case 'refunded':
        color = Colors.purple;
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

class _TransactionActions extends StatelessWidget {
  final TransactionModel transaction;
  final ValueChanged<TransactionModel> onView;
  final ValueChanged<TransactionModel> onRetry;
  final ValueChanged<TransactionModel> onRefund;
  final ValueChanged<TransactionModel> onExport;

  const _TransactionActions({
    required this.transaction,
    required this.onView,
    required this.onRetry,
    required this.onRefund,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final bool canRetry =
        transaction.status == 'failed' || transaction.status == 'pending';

    final bool canRefund = transaction.status == 'success';

    return PopupMenuButton<String>(
      tooltip: 'Transaction Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(transaction);
            break;
          case 'retry':
            onRetry(transaction);
            break;
          case 'refund':
            onRefund(transaction);
            break;
          case 'export':
            onExport(transaction);
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
          value: 'retry',
          enabled: canRetry,
          child: _MenuItem(
            icon: Icons.refresh,
            label: 'Retry Transaction',
            color: canRetry ? AppColors.primary : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'refund',
          enabled: canRefund,
          child: _MenuItem(
            icon: Icons.currency_exchange,
            label: 'Refund Transaction',
            color: canRefund ? AppColors.warning : Colors.grey,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'export',
          child: _MenuItem(
            icon: Icons.download_outlined,
            label: 'Export',
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

class _TransactionSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _TransactionSummaryCard({
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
              'Transaction Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Gateway transaction operational view',
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