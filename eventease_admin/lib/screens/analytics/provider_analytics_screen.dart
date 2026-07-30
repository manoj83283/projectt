import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/provider_analytics_model.dart';
import '../../providers/analytics_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/page_header.dart';

class ProviderAnalyticsScreen extends StatefulWidget {
  const ProviderAnalyticsScreen({
    super.key,
  });

  @override
  State<ProviderAnalyticsScreen> createState() =>
      _ProviderAnalyticsScreenState();
}

class _ProviderAnalyticsScreenState extends State<ProviderAnalyticsScreen> {
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
      _fetchProviderAnalytics();
    });
  }

  Future<void> _fetchProviderAnalytics() async {
    await context.read<AnalyticsProvider>().getProviderAnalytics(
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
        );
  }

  Future<void> _refresh() async {
    await _fetchProviderAnalytics();
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

    _fetchProviderAnalytics();
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

    _fetchProviderAnalytics();
  }

  void _onPeriodChanged(String? value) {
    if (value == null) return;

    setState(() {
      _selectedPeriod = value;
    });

    _fetchProviderAnalytics();
  }

  void _clearFilters() {
    final DateTime now = DateTime.now();

    setState(() {
      _selectedPeriod = 'monthly';
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);
    });

    _fetchProviderAnalytics();
  }

  Future<void> _exportProviderAnalytics() async {
    await context.read<AnalyticsProvider>().exportProviderAnalytics(
          period: _selectedPeriod,
          startDate: _startDate,
          endDate: _endDate,
        );

    if (!mounted) return;

    NavigationService.showSuccess(
      'Provider analytics export started successfully',
    );
  }

  Widget _buildHeader(AnalyticsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Provider Analytics',
          subtitle:
              'Track provider onboarding, active providers, approvals, ratings, earnings, bookings and performance trends.',
          actions: [
            CustomButton(
              text: 'Export',
              type: ButtonType.outline,
              icon: Icons.download_outlined,
              onPressed: provider.isLoading ? null : _exportProviderAnalytics,
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
                _ProviderSummaryCard(
                  title: 'Total Providers',
                  value: provider.totalProviders.toString(),
                  icon: Icons.groups_outlined,
                  color: AppColors.primary,
                ),
                _ProviderSummaryCard(
                  title: 'Active',
                  value: provider.activeProviders.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _ProviderSummaryCard(
                  title: 'Pending KYC',
                  value: provider.pendingKycProviders.toString(),
                  icon: Icons.verified_user_outlined,
                  color: AppColors.warning,
                ),
                _ProviderSummaryCard(
                  title: 'Rejected',
                  value: provider.rejectedProviders.toString(),
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                ),
                _ProviderSummaryCard(
                  title: 'Total Earnings',
                  value: AppFormatters.formatCurrency(
                    provider.providerTotalEarnings,
                  ),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.success,
                ),
                _ProviderSummaryCard(
                  title: 'Avg Rating',
                  value: provider.providerAverageRating.toStringAsFixed(1),
                  icon: Icons.star_outline,
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
              _ProviderTrendCard(
                title: 'Provider Onboarding Trend',
                points: provider.providerOnboardingTrend,
              ),
              const SizedBox(height: 20),
              _ProviderBreakdownCard(
                title: 'Provider Status Breakdown',
                breakdowns: provider.providerStatusBreakdown,
              ),
              const SizedBox(height: 20),
              _ProviderBreakdownCard(
                title: 'Category-wise Providers',
                breakdowns: provider.providerCategoryBreakdown,
              ),
              const SizedBox(height: 20),
              _ProviderBreakdownCard(
                title: 'Provider Rating Distribution',
                breakdowns: provider.providerRatingBreakdown,
              ),
            ],
          );
        }

        return Column(
          children: [
            _ProviderTrendCard(
              title: 'Provider Onboarding Trend',
              points: provider.providerOnboardingTrend,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ProviderBreakdownCard(
                    title: 'Provider Status Breakdown',
                    breakdowns: provider.providerStatusBreakdown,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _ProviderBreakdownCard(
                    title: 'Category-wise Providers',
                    breakdowns: provider.providerCategoryBreakdown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ProviderBreakdownCard(
              title: 'Provider Rating Distribution',
              breakdowns: provider.providerRatingBreakdown,
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
                    TopProvidersTable(
                      providers: provider.topProviderAnalytics,
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

class TopProvidersTable extends StatelessWidget {
  final List<ProviderAnalyticsRowModel> providers;

  const TopProvidersTable({
    super.key,
    required this.providers,
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
          if (providers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No provider analytics found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Provider performance analytics will appear here.',
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
                  DataColumn(label: Text('Provider')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('KYC')),
                  DataColumn(label: Text('Bookings')),
                  DataColumn(label: Text('Completed')),
                  DataColumn(label: Text('Earnings')),
                  DataColumn(label: Text('Rating')),
                  DataColumn(label: Text('Joined Date')),
                ],
                rows: providers.map(
                  (provider) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _ProviderInfoCell(
                            provider: provider,
                          ),
                        ),
                        DataCell(
                          _StatusChip(
                            label: AppFormatters.formatStatus(
                              provider.categoryName,
                            ),
                            color: AppColors.primary,
                          ),
                        ),
                        DataCell(
                          _ProviderStatusBadge(
                            status: provider.status,
                          ),
                        ),
                        DataCell(
                          _KycStatusBadge(
                            status: provider.kycStatus,
                          ),
                        ),
                        DataCell(
                          Text(
                            provider.totalBookings.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            provider.completedBookings.toString(),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            AppFormatters.formatCurrency(
                              provider.totalEarnings,
                            ),
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        DataCell(
                          _RatingBadge(
                            rating: provider.averageRating,
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDate(provider.joinedAt),
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

class _ProviderTrendCard extends StatelessWidget {
  final String title;
  final List<ProviderPointModel> points;

  const _ProviderTrendCard({
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
              title: 'No provider onboarding data',
              subtitle: 'Provider onboarding trend will appear here.',
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

class _ProviderBreakdownCard extends StatelessWidget {
  final String title;
  final List<ProviderBreakdownModel> breakdowns;

  const _ProviderBreakdownCard({
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
              subtitle: 'Provider breakdown will appear here.',
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
  final ProviderBreakdownModel item;
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
      case 'approved':
      case 'verified':
      case '5_star':
        return AppColors.success;
      case 'pending':
      case 'pending_kyc':
      case '3_star':
        return AppColors.warning;
      case 'rejected':
      case 'suspended':
      case '1_star':
      case '2_star':
        return AppColors.error;
      case 'inactive':
        return Colors.blueGrey;
      case '4_star':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}

class _ProviderInfoCell extends StatelessWidget {
  final ProviderAnalyticsRowModel provider;

  const _ProviderInfoCell({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final String providerName = provider.providerName.trim().isEmpty
        ? 'Unknown Provider'
        : provider.providerName.trim();

    return SizedBox(
      width: 250,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              providerName[0].toUpperCase(),
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
                  providerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.providerId,
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

class _ProviderStatusBadge extends StatelessWidget {
  final String status;

  const _ProviderStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'active':
      case 'approved':
        color = AppColors.success;
        break;
      case 'pending':
      case 'pending_approval':
        color = AppColors.warning;
        break;
      case 'inactive':
        color = Colors.blueGrey;
        break;
      case 'rejected':
      case 'suspended':
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

class _KycStatusBadge extends StatelessWidget {
  final String status;

  const _KycStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'verified':
      case 'approved':
        color = AppColors.success;
        break;
      case 'pending':
      case 'under_review':
        color = AppColors.warning;
        break;
      case 'rejected':
        color = AppColors.error;
        break;
      case 'not_submitted':
        color = Colors.blueGrey;
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

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = rating >= 4
        ? AppColors.success
        : rating >= 3
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProviderSummaryCard({
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
            Icons.groups_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Top Provider Analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            'Provider performance overview',
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