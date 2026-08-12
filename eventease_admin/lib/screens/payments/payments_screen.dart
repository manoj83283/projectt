import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/pagination_widget.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _selectedStatus;
  String? _selectedMethod;

  final List<String> _paymentStatuses = const [
    'pending',
    'paid',
    'failed',
    'refunded',
    'partially_paid',
  ];

  final List<String> _paymentMethods = const [
    'upi',
    'card',
    'net_banking',
    'wallet',
    'cash',
    'razorpay',
    'stripe',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPayments();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPayments() async {
    await context.read<PaymentProvider>().getPayments(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          paymentStatus: _selectedStatus,
          paymentMethod: _selectedMethod,
        );
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
    });

    await _fetchPayments();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        setState(() {
          _page = 1;
        });

        _fetchPayments();
      },
    );
  }

  void _onStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedStatus = value;
    });

    _fetchPayments();
  }

  void _onMethodChanged(String? value) {
    setState(() {
      _page = 1;
      _selectedMethod = value;
    });

    _fetchPayments();
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _selectedStatus = null;
      _selectedMethod = null;
      _searchController.clear();
    });

    _fetchPayments();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchPayments();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchPayments();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchPayments();
  }

  Future<void> _viewPayment(PaymentModel payment) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 620,
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
                          'Payment Details',
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
                    label: 'Payment ID',
                    value: payment.paymentId,
                  ),
                  _DetailRow(
                    label: 'Transaction ID',
                    value: payment.transactionId.isEmpty
                        ? 'Not Available'
                        : payment.transactionId,
                  ),
                  _DetailRow(
                    label: 'Order ID',
                    value: payment.orderId,
                  ),
                  _DetailRow(
                    label: 'Booking ID',
                    value: payment.bookingId,
                  ),
                  _DetailRow(
                    label: 'Customer',
                    value: payment.customerName,
                  ),
                  _DetailRow(
                    label: 'Amount',
                    value: AppFormatters.formatCurrency(payment.amount),
                  ),
                  _DetailRow(
                    label: 'Method',
                    value: AppFormatters.formatStatus(payment.paymentMethod),
                  ),
                  _DetailRow(
                    label: 'Date',
                    value: _formatDate(payment.createdAt),
                  ),
                  const SizedBox(height: 12),
                  _PaymentStatusBadge(
                    status: payment.paymentStatus,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _refundPayment(PaymentModel payment) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Refund Payment'),
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
                final reason = reasonController.text.trim();

                if (reason.isEmpty) return;

                Navigator.pop(context, reason);
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

    final bool success = await context.read<PaymentProvider>().refundPayment(
          paymentId: payment.id,
          reason: reason,
        );

    _handleMutationResult(
      success: success,
      successMessage: 'Payment refunded successfully',
      errorMessage: 'Failed to refund payment',
    );
  }

  Future<void> _retryPayment(PaymentModel payment) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Retry Payment',
      message: 'Are you sure you want to retry payment ${payment.paymentId}?',
      confirmText: 'Retry',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<PaymentProvider>().retryPayment(payment.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Payment retry initiated successfully',
      errorMessage: 'Failed to retry payment',
    );
  }

  Future<void> _exportPayment(PaymentModel payment) async {
    await context.read<PaymentProvider>().exportPayments();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payments export started successfully'),
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
      _fetchPayments();
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
                    'Payments',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Monitor revenue, payment status, refunds, retries, and transactions.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
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
                _PaymentSummaryCard(
                  title: 'Total Revenue',
                  value: AppFormatters.formatCurrency(
                    provider.totalRevenue,
                  ),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.success,
                ),
                _PaymentSummaryCard(
                  title: 'Successful',
                  value: provider.successfulPayments.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _PaymentSummaryCard(
                  title: 'Pending',
                  value: provider.pendingPayments.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.warning,
                ),
                _PaymentSummaryCard(
                  title: 'Failed / Refunded',
                  value:
                      '${provider.failedPayments} / ${provider.refundedPayments}',
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
                'Search payment id, transaction id, customer, order, booking...',
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
      labelText: 'Payment Status',
      value: _selectedStatus,
      items: _paymentStatuses,
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
                _buildFilters(),
                if (paymentProvider.errorMessage != null)
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
                      paymentProvider.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                PaymentsTable(
                  payments: paymentProvider.payments,
                  isLoading: paymentProvider.isLoading,
                  onView: _viewPayment,
                  onRefund: _refundPayment,
                  onRetry: _retryPayment,
                  onExport: _exportPayment,
                ),
                const SizedBox(height: 20),
                PaginationWidget(
                  currentPage: paymentProvider.currentPage,
                  totalPages: paymentProvider.totalPages,
                  totalRecords: paymentProvider.totalPayments,
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
}

class PaymentsTable extends StatelessWidget {
  final List<PaymentModel> payments;
  final bool isLoading;
  final ValueChanged<PaymentModel> onView;
  final ValueChanged<PaymentModel> onRefund;
  final ValueChanged<PaymentModel> onRetry;
  final ValueChanged<PaymentModel> onExport;

  const PaymentsTable({
    super.key,
    required this.payments,
    required this.isLoading,
    required this.onView,
    required this.onRefund,
    required this.onRetry,
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
          else if (payments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No payments found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Payments matching your filters will appear here.',
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
                  DataColumn(label: Text('Payment ID')),
                  DataColumn(label: Text('Reference')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Transaction ID')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: payments.map(
                  (payment) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _PaymentInfoCell(
                            payment: payment,
                          ),
                        ),
                        DataCell(
                          _ReferenceCell(
                            payment: payment,
                          ),
                        ),
                        DataCell(
                          _CustomerCell(
                            payment: payment,
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(payment.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        DataCell(
                          _MethodChip(
                            method: payment.paymentMethod,
                          ),
                        ),
                        DataCell(
                          _PaymentStatusBadge(
                            status: payment.paymentStatus,
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 170,
                            child: Text(
                              payment.transactionId.isEmpty
                                  ? 'Not Available'
                                  : payment.transactionId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _PaymentsScreenState._formatDate(
                              payment.createdAt,
                            ),
                          ),
                        ),
                        DataCell(
                          _PaymentActions(
                            payment: payment,
                            onView: onView,
                            onRefund: onRefund,
                            onRetry: onRetry,
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

class _PaymentInfoCell extends StatelessWidget {
  final PaymentModel payment;

  const _PaymentInfoCell({
    required this.payment,
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
            payment.paymentId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            payment.id,
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

class _ReferenceCell extends StatelessWidget {
  final PaymentModel payment;

  const _ReferenceCell({
    required this.payment,
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
            'Order: ${payment.orderId}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Booking: ${payment.bookingId}',
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
  final PaymentModel payment;

  const _CustomerCell({
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              payment.customerName.isEmpty
                  ? 'C'
                  : payment.customerName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              payment.customerName,
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

class _PaymentStatusBadge extends StatelessWidget {
  final String status;

  const _PaymentStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'paid':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'failed':
        color = AppColors.error;
        break;
      case 'refunded':
        color = Colors.purple;
        break;
      case 'partially_paid':
        color = AppColors.info;
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

class _PaymentActions extends StatelessWidget {
  final PaymentModel payment;
  final ValueChanged<PaymentModel> onView;
  final ValueChanged<PaymentModel> onRefund;
  final ValueChanged<PaymentModel> onRetry;
  final ValueChanged<PaymentModel> onExport;

  const _PaymentActions({
    required this.payment,
    required this.onView,
    required this.onRefund,
    required this.onRetry,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final bool canRefund = payment.paymentStatus == 'paid' ||
        payment.paymentStatus == 'partially_paid';

    final bool canRetry = payment.paymentStatus == 'failed' ||
        payment.paymentStatus == 'pending';

    return PopupMenuButton<String>(
      tooltip: 'Payment Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(payment);
            break;
          case 'refund':
            onRefund(payment);
            break;
          case 'retry':
            onRetry(payment);
            break;
          case 'export':
            onExport(payment);
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
          value: 'refund',
          enabled: canRefund,
          child: _MenuItem(
            icon: Icons.currency_exchange,
            label: 'Refund Payment',
            color: canRefund ? AppColors.warning : Colors.grey,
          ),
        ),
        PopupMenuItem(
          value: 'retry',
          enabled: canRetry,
          child: _MenuItem(
            icon: Icons.refresh,
            label: 'Retry Payment',
            color: canRetry ? AppColors.primary : Colors.grey,
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

class _PaymentSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _PaymentSummaryCard({
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
            Icons.payments_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Payment Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Secure transaction overview',
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