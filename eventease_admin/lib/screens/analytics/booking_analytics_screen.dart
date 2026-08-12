import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/booking_analytics_model.dart';
import '../../providers/analytics_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';

class BookingAnalyticsScreen extends StatefulWidget {
  const BookingAnalyticsScreen({
    super.key,
  });

  @override
  State<BookingAnalyticsScreen> createState() => _BookingAnalyticsScreenState();
}

class _BookingAnalyticsScreenState extends State<BookingAnalyticsScreen> {
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
      _fetchBookingAnalytics();
    });
  }

  Future<void> _fetchBookingAnalytics() async {
    await context.read<AnalyticsProvider>().getBookingAnalytics(
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  Future<void> _refresh() async {
    await _fetchBookingAnalytics();
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

    _fetchBookingAnalytics();
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

    _fetchBookingAnalytics();
  }

  void _onPeriodChanged(String? value) {
    if (value == null) return;

    setState(() {
      _selectedPeriod = value;
    });

    _fetchBookingAnalytics();
  }

  void _clearFilters() {
    final DateTime now = DateTime.now();

    setState(() {
      _selectedPeriod = 'monthly';
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);
    });

    _fetchBookingAnalytics();
  }

  Future<void> _exportBookingAnalytics() async {
    await context.read<AnalyticsProvider>().exportBookingAnalytics(
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
        );

    if (!mounted) return;

    NavigationService.showSuccess(
      'Booking analytics export started successfully',
    );
  }

  Widget _buildHeader(AnalyticsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Booking Analytics',
          subtitle:
              'Track booking volume, completion rate, cancellations, pending bookings, provider acceptance and service demand trends.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: provider.isLoading ? null : _exportBookingAnalytics,
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
                _BookingSummaryCard(
                  title: 'Total Bookings',
                  value: provider.totalBookings.toString(),
                  icon: Icons.event_available_outlined,
                  color: AppColors.primary,
                ),
                _BookingSummaryCard(
                  title: 'Completed',
                  value: provider.completedBookings.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _BookingSummaryCard(
                  title: 'Pending',
                  value: provider.pendingBookings.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.warning,
                ),
                _BookingSummaryCard(
                  title: 'Cancelled',
                  value: provider.cancelledBookings.toString(),
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                ),
                _BookingSummaryCard(
                  title: 'Revenue',
                  value: AppFormatters.formatCurrency(
                    provider.bookingRevenue,
                  ),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.success,
                ),
                _BookingSummaryCard(
                  title: 'Completion Rate',
                  value:
                      '${provider.bookingCompletionRate.toStringAsFixed(1)}%',
                  icon: Icons.analytics_outlined,
                  color: Colors.purple,
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
              _BookingTrendCard(
                title: 'Booking Trend',
                points: provider.bookingTrend,
              ),
              const SizedBox(height: 20),
              _BookingBreakdownCard(
                title: 'Booking Status Breakdown',
                breakdowns: provider.bookingStatusBreakdown,
              ),
              const SizedBox(height: 20),
              _BookingBreakdownCard(
                title: 'Category Booking Demand',
                breakdowns: provider.categoryBookings,
              ),
              const SizedBox(height: 20),
              _BookingBreakdownCard(
                title: 'Provider Acceptance',
                breakdowns: provider.providerAcceptanceBreakdown,
              ),
            ],
          );
        }

        return Column(
          children: [
            _BookingTrendCard(
              title: 'Booking Trend',
              points: provider.bookingTrend,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _BookingBreakdownCard(
                    title: 'Booking Status Breakdown',
                    breakdowns: provider.bookingStatusBreakdown,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _BookingBreakdownCard(
                    title: 'Category Booking Demand',
                    breakdowns: provider.categoryBookings,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _BookingBreakdownCard(
              title: 'Provider Acceptance',
              breakdowns: provider.providerAcceptanceBreakdown,
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
                    RecentBookingsTable(
                      bookings: provider.recentBookingAnalytics,
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

class RecentBookingsTable extends StatelessWidget {
  final List<BookingAnalyticsRowModel> bookings;

  const RecentBookingsTable({
    super.key,
    required this.bookings,
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
          if (bookings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No booking records found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Recent booking analytics records will appear here.',
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
                  DataColumn(label: Text('Booking ID')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Provider')),
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Payment')),
                  DataColumn(label: Text('Booking Date')),
                  DataColumn(label: Text('Event Date')),
                ],
                rows: bookings.map(
                  (booking) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _BookingIdCell(
                            booking: booking,
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 160,
                            child: Text(
                              booking.customerName.trim().isEmpty
                                  ? 'Unknown Customer'
                                  : booking.customerName,
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
                              booking.providerName.trim().isEmpty
                                  ? 'Not Assigned'
                                  : booking.providerName,
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
                            width: 170,
                            child: Text(
                              booking.serviceName.trim().isEmpty
                                  ? 'Not Available'
                                  : booking.serviceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          _StatusChip(
                            label: AppFormatters.formatStatus(
                              booking.categoryName,
                            ),
                            color: AppColors.primary,
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              booking.amount,
                            ),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          _BookingStatusBadge(
                            status: booking.status,
                          ),
                        ),
                        DataCell(
                          _PaymentStatusBadge(
                            status: booking.paymentStatus,
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDate(booking.createdAt),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDate(booking.eventDate),
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

class _BookingTrendCard extends StatelessWidget {
  final String title;
  final List<BookingPointModel> points;

  const _BookingTrendCard({
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
              title: 'No booking trend data',
              subtitle: 'Booking trend will appear after bookings.',
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

class _BookingBreakdownCard extends StatelessWidget {
  final String title;
  final List<BookingBreakdownModel> breakdowns;

  const _BookingBreakdownCard({
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
              subtitle: 'Booking breakdown will appear here.',
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
  final BookingBreakdownModel item;
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
      case 'completed':
      case 'accepted':
      case 'paid':
        return AppColors.success;
      case 'pending':
      case 'requested':
      case 'processing':
        return AppColors.warning;
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return AppColors.error;
      case 'confirmed':
      case 'in_progress':
        return AppColors.primary;
      case 'rescheduled':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}

class _BookingIdCell extends StatelessWidget {
  final BookingAnalyticsRowModel booking;

  const _BookingIdCell({
    required this.booking,
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
            booking.bookingId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.id,
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

class _BookingStatusBadge extends StatelessWidget {
  final String status;

  const _BookingStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'confirmed':
        color = AppColors.primary;
        break;
      case 'in_progress':
        color = AppColors.info;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      case 'rescheduled':
        color = Colors.orange;
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

class _BookingSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _BookingSummaryCard({
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
            Icons.event_available_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Recent Booking Analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Booking operations overview',
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