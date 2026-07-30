import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/revenue_analytics_model.dart';
import '../../providers/analytics_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';

class RevenueAnalyticsScreen extends StatefulWidget {
  const RevenueAnalyticsScreen({
    super.key,
  });

  @override
  State<RevenueAnalyticsScreen> createState() => _RevenueAnalyticsScreenState();
}

class _RevenueAnalyticsScreenState extends State<RevenueAnalyticsScreen> {
  String _selectedPeriod = 'monthly';

  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _periods = const [
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'yearly',
  ];

  @override
  void initState() {
    super.initState();

    final DateTime now = DateTime.now();

    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRevenueAnalytics();
    });
  }

  Future<void> _fetchRevenueAnalytics() async {
    await context.read<AnalyticsProvider>().getRevenueAnalytics(
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  Future<void> _refresh() async {
    await _fetchRevenueAnalytics();
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
      _startDate = selectedDate;

      if (_endDate != null && _endDate!.isBefore(selectedDate)) {
        _endDate = selectedDate;
      }
    });

    _fetchRevenueAnalytics();
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
      _endDate = selectedDate;
    });

    _fetchRevenueAnalytics();
  }

  void _onPeriodChanged(String? value) {
    if (value == null) return;

    setState(() {
      _selectedPeriod = value;
    });

    _fetchRevenueAnalytics();
  }

  void _clearFilters() {
    final DateTime now = DateTime.now();

    setState(() {
      _selectedPeriod = 'monthly';
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);
    });

    _fetchRevenueAnalytics();
  }

  Future<void> _exportRevenueAnalytics() async {
    await context.read<AnalyticsProvider>().exportRevenueAnalytics(
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
        );

    if (!mounted) return;

    NavigationService.showSuccess(
      'Revenue analytics export started successfully',
    );
  }

  Widget _buildHeader(AnalyticsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Revenue Analytics',
          subtitle:
              'Track revenue, commissions, refunds, net earnings, payment performance and marketplace financial trends.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: provider.isLoading ? null : _exportRevenueAnalytics,
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
                _RevenueSummaryCard(
                  title: 'Total Revenue',
                  value: AppFormatters.formatCurrency(provider.totalRevenue),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.success,
                ),
                _RevenueSummaryCard(
                  title: 'Net Revenue',
                  value: AppFormatters.formatCurrency(provider.netRevenue),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),
                _RevenueSummaryCard(
                  title: 'Commission',
                  value: AppFormatters.formatCurrency(provider.totalCommission),
                  icon: Icons.percent_outlined,
                  color: Colors.purple,
                ),
                _RevenueSummaryCard(
                  title: 'Refunds',
                  value: AppFormatters.formatCurrency(provider.totalRefunds),
                  icon: Icons.currency_exchange,
                  color: AppColors.error,
                ),
                _RevenueSummaryCard(
                  title: 'Transactions',
                  value: provider.totalTransactions.toString(),
                  icon: Icons.receipt_long_outlined,
                  color: AppColors.info,
                ),
                _RevenueSummaryCard(
                  title: 'Avg Order Value',
                  value: AppFormatters.formatCurrency(provider.averageOrderValue),
                  icon: Icons.analytics_outlined,
                  color: Colors.orange,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters(AnalyticsProvider provider) {
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 900;

          if (isCompact) {
            return Column(
              children: [
                _buildPeriodDropdown(),
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

          return Row(
            children: [
              Expanded(
                child: _buildPeriodDropdown(),
              ),
              const SizedBox(width: 14),
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
          );
        },
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return CustomDropdown<String>(
      labelText: 'Analytics Period',
      value: _selectedPeriod,
      items: _periods,
      itemLabelBuilder: AppFormatters.formatStatus,
      onChanged: _onPeriodChanged,
    );
  }

  Widget _buildCharts(AnalyticsProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompact = constraints.maxWidth < 1000;

        if (isCompact) {
          return Column(
            children: [
              _RevenueTrendCard(
                title: 'Revenue Trend',
                points: provider.revenueTrend,
              ),
              const SizedBox(height: 20),
              _RevenueBreakdownCard(
                title: 'Category Revenue',
                breakdowns: provider.categoryRevenue,
              ),
              const SizedBox(height: 20),
              _RevenueBreakdownCard(
                title: 'Payment Method Revenue',
                breakdowns: provider.paymentMethodRevenue,
              ),
            ],
          );
        }

        return Column(
          children: [
            _RevenueTrendCard(
              title: 'Revenue Trend',
              points: provider.revenueTrend,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _RevenueBreakdownCard(
                    title: 'Category Revenue',
                    breakdowns: provider.categoryRevenue,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _RevenueBreakdownCard(
                    title: 'Payment Method Revenue',
                    breakdowns: provider.paymentMethodRevenue,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
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
                  if (provider.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(44),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    _buildCharts(provider),
                    const SizedBox(height: 20),
                    RevenueTransactionsTable(
                      transactions: provider.recentRevenueTransactions,
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class RevenueTransactionsTable extends StatelessWidget {
  final List<RevenueTransactionModel> transactions;

  const RevenueTransactionsTable({
    super.key,
    required this.transactions,
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
          if (transactions.isEmpty)
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
                    'No revenue transactions found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Revenue transactions matching selected date range will appear here.',
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
                dataRowMinHeight: 68,
                dataRowMaxHeight: 82,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Transaction ID')),
                  DataColumn(label: Text('Reference')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Provider')),
                  DataColumn(label: Text('Gross Amount')),
                  DataColumn(label: Text('Commission')),
                  DataColumn(label: Text('Net Amount')),
                  DataColumn(label: Text('Payment Method')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Date')),
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
                          SizedBox(
                            width: 160,
                            child: Text(
                              transaction.customerName.trim().isEmpty
                                  ? 'Unknown Customer'
                                  : transaction.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 160,
                            child: Text(
                              transaction.providerName.trim().isEmpty
                                  ? 'Not Assigned'
                                  : transaction.providerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              transaction.grossAmount,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              transaction.commissionAmount,
                            ),
                            style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              transaction.netAmount,
                            ),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          _StatusChip(
                            label: AppFormatters.formatStatus(
                              transaction.paymentMethod,
                            ),
                            color: AppColors.primary,
                          ),
                        ),
                        DataCell(
                          _RevenueStatusBadge(
                            status: transaction.status,
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDate(transaction.createdAt),
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

  static String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Not Available';

    return AppFormatters.formatDateTime(dateTime);
  }
}

class _RevenueTrendCard extends StatelessWidget {
  final String title;
  final List<RevenuePointModel> points;

  const _RevenueTrendCard({
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue = points.isEmpty
        ? 0
        : points
            .map((point) => point.amount)
            .reduce((value, element) => value > element ? value : element);

    return _AnalyticsCard(
      title: title,
      icon: Icons.show_chart_outlined,
      child: points.isEmpty
          ? const _EmptyAnalyticsState(
              icon: Icons.show_chart_outlined,
              title: 'No revenue trend data',
              subtitle: 'Revenue trend will appear after transactions.',
            )
          : SizedBox(
              height: 280,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: points.map(
                  (point) {
                    final double percentage =
                        maxValue <= 0 ? 0 : (point.amount / maxValue);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              AppFormatters.formatCompactCurrency(point.amount),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  width: double.infinity,
                                  height: (220 * percentage).clamp(8, 220),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.84),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              point.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
    );
  }
}

class _RevenueBreakdownCard extends StatelessWidget {
  final String title;
  final List<RevenueBreakdownModel> breakdowns;

  const _RevenueBreakdownCard({
    required this.title,
    required this.breakdowns,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue = breakdowns.isEmpty
        ? 0
        : breakdowns
            .map((item) => item.amount)
            .reduce((value, element) => value > element ? value : element);

    return _AnalyticsCard(
      title: title,
      icon: Icons.pie_chart_outline,
      child: breakdowns.isEmpty
          ? const _EmptyAnalyticsState(
              icon: Icons.pie_chart_outline,
              title: 'No breakdown data',
              subtitle: 'Revenue breakdown will appear here.',
            )
          : Column(
              children: breakdowns.map(
                (item) {
                  final double progress =
                      maxValue <= 0 ? 0 : (item.amount / maxValue);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _BreakdownRow(
                      item: item,
                      progress: progress,
                    ),
                  );
                },
              ).toList(),
            ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final RevenueBreakdownModel item;
  final double progress;

  const _BreakdownRow({
    required this.item,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _colorForLabel(item.label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(
                Icons.analytics_outlined,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppFormatters.formatStatus(item.label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              AppFormatters.formatCurrency(item.amount),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${item.percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Color _colorForLabel(String label) {
    switch (label) {
      case 'booking':
      case 'paid':
      case 'razorpay':
        return AppColors.success;
      case 'order':
      case 'upi':
        return AppColors.primary;
      case 'refund':
      case 'failed':
        return AppColors.error;
      case 'settlement':
      case 'wallet':
        return Colors.purple;
      case 'cash':
        return Colors.orange;
      case 'card':
        return AppColors.info;
      default:
        return Colors.blueGrey;
    }
  }
}

class _TransactionInfoCell extends StatelessWidget {
  final RevenueTransactionModel transaction;

  const _TransactionInfoCell({
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
            transaction.transactionId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            transaction.paymentId,
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

class _ReferenceCell extends StatelessWidget {
  final RevenueTransactionModel transaction;

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
            transaction.orderId.trim().isEmpty
                ? 'Order: Not Available'
                : 'Order: ${transaction.orderId}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            transaction.bookingId.trim().isEmpty
                ? 'Booking: Not Available'
                : 'Booking: ${transaction.bookingId}',
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

class _RevenueStatusBadge extends StatelessWidget {
  final String status;

  const _RevenueStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'paid':
      case 'success':
      case 'completed':
        color = AppColors.success;
        break;
      case 'pending':
      case 'processing':
        color = AppColors.warning;
        break;
      case 'failed':
      case 'cancelled':
        color = AppColors.error;
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

class _RevenueSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _RevenueSummaryCard({
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

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _AnalyticsCard({
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
            color: Colors.black.withOpacity(0.035),
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
                backgroundColor: AppColors.primary.withOpacity(0.1),
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

class _EmptyAnalyticsState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyAnalyticsState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 52,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
              'Recent Revenue Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Financial transaction overview',
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