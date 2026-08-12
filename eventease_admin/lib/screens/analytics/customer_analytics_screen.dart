import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer_analytics_model.dart';
import '../../providers/analytics_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';

class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({
    super.key,
  });

  @override
  State<CustomerAnalyticsScreen> createState() =>
      _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
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
      _fetchCustomerAnalytics();
    });
  }

  Future<void> _fetchCustomerAnalytics() async {
    await context.read<AnalyticsProvider>().getCustomerAnalytics(
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  Future<void> _refresh() async {
    await _fetchCustomerAnalytics();
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

    _fetchCustomerAnalytics();
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

    _fetchCustomerAnalytics();
  }

  void _onPeriodChanged(String? value) {
    if (value == null) return;

    setState(() {
      _selectedPeriod = value;
    });

    _fetchCustomerAnalytics();
  }

  void _clearFilters() {
    final DateTime now = DateTime.now();

    setState(() {
      _selectedPeriod = 'monthly';
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);
    });

    _fetchCustomerAnalytics();
  }

  Future<void> _exportCustomerAnalytics() async {
    await context.read<AnalyticsProvider>().exportCustomerAnalytics(
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
        );

    if (!mounted) return;

    NavigationService.showSuccess(
      'Customer analytics export started successfully',
    );
  }

  Widget _buildHeader(AnalyticsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Customer Analytics',
          subtitle:
              'Track customer growth, active users, bookings, orders, spending, retention and customer engagement trends.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: provider.isLoading ? null : _exportCustomerAnalytics,
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
                _CustomerSummaryCard(
                  title: 'Total Customers',
                  value: provider.totalCustomers.toString(),
                  icon: Icons.people_alt_outlined,
                  color: AppColors.primary,
                ),
                _CustomerSummaryCard(
                  title: 'Active Customers',
                  value: provider.activeCustomers.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _CustomerSummaryCard(
                  title: 'New Customers',
                  value: provider.newCustomers.toString(),
                  icon: Icons.person_add_alt_1_outlined,
                  color: AppColors.info,
                ),
                _CustomerSummaryCard(
                  title: 'Repeat Customers',
                  value: provider.repeatCustomers.toString(),
                  icon: Icons.repeat_outlined,
                  color: Colors.purple,
                ),
                _CustomerSummaryCard(
                  title: 'Total Spend',
                  value: AppFormatters.formatCurrency(
                    provider.customerTotalSpend,
                  ),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.success,
                ),
                _CustomerSummaryCard(
                  title: 'Avg Spend',
                  value: AppFormatters.formatCurrency(
                    provider.customerAverageSpend,
                  ),
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
            color: Colors.black.withValues(alpha: 0.035),
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
              _CustomerTrendCard(
                title: 'Customer Growth Trend',
                points: provider.customerGrowthTrend,
              ),
              const SizedBox(height: 20),
              _CustomerBreakdownCard(
                title: 'Customer Status Breakdown',
                breakdowns: provider.customerStatusBreakdown,
              ),
              const SizedBox(height: 20),
              _CustomerBreakdownCard(
                title: 'Customer Source Breakdown',
                breakdowns: provider.customerSourceBreakdown,
              ),
              const SizedBox(height: 20),
              _CustomerBreakdownCard(
                title: 'Spending Segment Breakdown',
                breakdowns: provider.customerSpendingBreakdown,
              ),
            ],
          );
        }

        return Column(
          children: [
            _CustomerTrendCard(
              title: 'Customer Growth Trend',
              points: provider.customerGrowthTrend,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _CustomerBreakdownCard(
                    title: 'Customer Status Breakdown',
                    breakdowns: provider.customerStatusBreakdown,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _CustomerBreakdownCard(
                    title: 'Customer Source Breakdown',
                    breakdowns: provider.customerSourceBreakdown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _CustomerBreakdownCard(
              title: 'Spending Segment Breakdown',
              breakdowns: provider.customerSpendingBreakdown,
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
                    TopCustomersTable(
                      customers: provider.topCustomerAnalytics,
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

class TopCustomersTable extends StatelessWidget {
  final List<CustomerAnalyticsRowModel> customers;

  const TopCustomersTable({
    super.key,
    required this.customers,
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
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const _TableHeader(),
          if (customers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No customer analytics found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customer performance analytics will appear here.',
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
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Source')),
                  DataColumn(label: Text('Bookings')),
                  DataColumn(label: Text('Orders')),
                  DataColumn(label: Text('Total Spend')),
                  DataColumn(label: Text('Avg Spend')),
                  DataColumn(label: Text('Last Active')),
                  DataColumn(label: Text('Joined Date')),
                ],
                rows: customers.map(
                  (customer) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _CustomerInfoCell(
                            customer: customer,
                          ),
                        ),
                        DataCell(
                          _CustomerStatusBadge(
                            status: customer.status,
                          ),
                        ),
                        DataCell(
                          _StatusChip(
                            label: AppFormatters.formatStatus(
                              customer.source,
                            ),
                            color: AppColors.primary,
                          ),
                        ),
                        DataCell(
                          Text(
                            customer.totalBookings.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            customer.totalOrders.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              customer.totalSpend,
                            ),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              customer.averageSpend,
                            ),
                            style: const TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDate(customer.lastActiveAt),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDate(customer.joinedAt),
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

class _CustomerTrendCard extends StatelessWidget {
  final String title;
  final List<CustomerPointModel> points;

  const _CustomerTrendCard({
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final int maxValue = points.isEmpty
        ? 0
        : points
            .map((point) => point.count)
            .reduce((value, element) => value > element ? value : element);

    return _AnalyticsCard(
      title: title,
      icon: Icons.show_chart_outlined,
      child: points.isEmpty
          ? const _EmptyAnalyticsState(
              icon: Icons.show_chart_outlined,
              title: 'No customer growth data',
              subtitle: 'Customer growth trend will appear here.',
            )
          : SizedBox(
              height: 280,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: points.map(
                  (point) {
                    final double percentage =
                        maxValue <= 0 ? 0 : point.count / maxValue;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              point.count.toString(),
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
                                    color: AppColors.primary.withValues(alpha: 0.84),
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

class _CustomerBreakdownCard extends StatelessWidget {
  final String title;
  final List<CustomerBreakdownModel> breakdowns;

  const _CustomerBreakdownCard({
    required this.title,
    required this.breakdowns,
  });

  @override
  Widget build(BuildContext context) {
    final int maxValue = breakdowns.isEmpty
        ? 0
        : breakdowns
            .map((item) => item.count)
            .reduce((value, element) => value > element ? value : element);

    return _AnalyticsCard(
      title: title,
      icon: Icons.pie_chart_outline,
      child: breakdowns.isEmpty
          ? const _EmptyAnalyticsState(
              icon: Icons.pie_chart_outline,
              title: 'No breakdown data',
              subtitle: 'Customer breakdown will appear here.',
            )
          : Column(
              children: breakdowns.map(
                (item) {
                  final double progress =
                      maxValue <= 0 ? 0 : item.count / maxValue;

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
  final CustomerBreakdownModel item;
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
              backgroundColor: color.withValues(alpha: 0.1),
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
              item.count.toString(),
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
      case 'active':
      case 'repeat':
      case 'high_value':
      case 'organic':
        return AppColors.success;
      case 'new':
      case 'medium_value':
      case 'referral':
        return AppColors.info;
      case 'inactive':
      case 'low_value':
        return AppColors.warning;
      case 'blocked':
      case 'churned':
        return AppColors.error;
      case 'campaign':
      case 'social':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
}

class _CustomerInfoCell extends StatelessWidget {
  final CustomerAnalyticsRowModel customer;

  const _CustomerInfoCell({
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final String customerName = customer.customerName.trim().isEmpty
        ? 'Unknown Customer'
        : customer.customerName.trim();

    return SizedBox(
      width: 260,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              customerName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
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
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.customerId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (customer.phone.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    customer.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerStatusBadge extends StatelessWidget {
  final String status;

  const _CustomerStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'active':
        color = AppColors.success;
        break;
      case 'inactive':
        color = AppColors.warning;
        break;
      case 'blocked':
      case 'suspended':
        color = AppColors.error;
        break;
      case 'new':
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

class _CustomerSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _CustomerSummaryCard({
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
            Icons.people_alt_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Top Customer Analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Customer engagement overview',
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