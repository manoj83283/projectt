import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';

class BookingChartData {
  final String label;
  final int bookings;

  const BookingChartData({
    required this.label,
    required this.bookings,
  });
}

class BookingChart extends StatelessWidget {
  final List<BookingChartData> data;
  final String title;
  final Color barColor;
  final bool showGrid;

  const BookingChart({
    super.key,
    required this.data,
    this.title = 'Booking Overview',
    this.barColor = AppColors.primary,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No booking data available',
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 320,
              child: BarChart(
                _buildChartData(),
              ),
            ),

            const SizedBox(height: 16),

            _buildSummary(context),
          ],
        ),
      ),
    );
  }

  BarChartData _buildChartData() {
    return BarChartData(
      alignment:
          BarChartAlignment.spaceAround,

      maxY:
          (data
                  .map((e) => e.bookings)
                  .reduce(
                    (a, b) =>
                        a > b ? a : b,
                  ) *
              1.2)
              .toDouble(),

      gridData: FlGridData(
        show: showGrid,
      ),

      borderData: FlBorderData(
        show: false,
      ),

      titlesData: FlTitlesData(
        topTitles:
            const AxisTitles(),
        rightTitles:
            const AxisTitles(),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget:
                (value, meta) {
              final index =
                  value.toInt();

              if (index < 0 ||
                  index >= data.length) {
                return const SizedBox();
              }

              return Padding(
                padding:
                    const EdgeInsets.only(
                  top: 8,
                ),
                child: Text(
                  data[index].label,
                  style:
                      const TextStyle(
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            getTitlesWidget:
                (value, meta) {
              return Text(
                value.toInt().toString(),
                style:
                    const TextStyle(
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),

      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData:
            BarTouchTooltipData(
          getTooltipItem:
              (
                group,
                groupIndex,
                rod,
                rodIndex,
              ) {
            return BarTooltipItem(
              '${data[group.x].label}\n${rod.toY.toInt()} Bookings',
              const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            );
          },
        ),
      ),

      barGroups: data
          .asMap()
          .entries
          .map(
            (entry) => BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry
                      .value
                      .bookings
                      .toDouble(),
                  width: 28,
                  borderRadius:
                      BorderRadius.circular(
                    6,
                  ),
                  color: barColor,
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildSummary(
    BuildContext context,
  ) {
    final totalBookings =
        data.fold<int>(
      0,
      (sum, item) =>
          sum + item.bookings,
    );

    final peakBookings =
        data
            .map((e) => e.bookings)
            .reduce(
              (a, b) =>
                  a > b ? a : b,
            );

    final averageBookings =
        totalBookings / data.length;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _SummaryCard(
          title: 'Total Bookings',
          value: AppFormatters
              .formatNumber(
            totalBookings,
          ),
        ),
        _SummaryCard(
          title: 'Peak Bookings',
          value: AppFormatters
              .formatNumber(
            peakBookings,
          ),
        ),
        _SummaryCard(
          title: 'Average',
          value: averageBookings
              .toStringAsFixed(0),
        ),
      ],
    );
  }
}

class _SummaryCard
    extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.padding12,
      ),
      decoration: BoxDecoration(
        color:
            AppColors.primary.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}