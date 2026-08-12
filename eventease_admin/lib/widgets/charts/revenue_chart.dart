import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';

class RevenueData {
  final String label;
  final double amount;

  const RevenueData({
    required this.label,
    required this.amount,
  });
}

class RevenueChart extends StatelessWidget {
  final List<RevenueData> revenueData;
  final String title;
  final Color lineColor;
  final bool showGrid;
  final bool showDots;

  const RevenueChart({
    super.key,
    required this.revenueData,
    this.title = 'Revenue Overview',
    this.lineColor = AppColors.primary,
    this.showGrid = true,
    this.showDots = true,
  });

  @override
  Widget build(BuildContext context) {
    if (revenueData.isEmpty) {
      return const Center(
        child: Text(
          'No revenue data available',
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
              child: LineChart(
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

  LineChartData _buildChartData() {
    return LineChartData(
      minY: 0,

      gridData: FlGridData(
        show: showGrid,
      ),

      borderData: FlBorderData(
        show: true,
      ),

      titlesData: FlTitlesData(
        rightTitles:
            const AxisTitles(),
        topTitles:
            const AxisTitles(),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget:
                (value, meta) {
              final index =
                  value.toInt();

              if (index < 0 ||
                  index >=
                      revenueData.length) {
                return const SizedBox();
              }

              return Padding(
                padding:
                    const EdgeInsets.only(
                  top: 8,
                ),
                child: Text(
                  revenueData[index]
                      .label,
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
            reservedSize: 60,
            getTitlesWidget:
                (value, meta) {
              return Text(
                AppFormatters
                    .formatCompactCurrency(
                  value,
                ),
                style:
                    const TextStyle(
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),

      lineBarsData: [
        LineChartBarData(
          isCurved: true,

          color: lineColor,

          barWidth: 4,

          isStrokeCapRound: true,

          dotData: FlDotData(
            show: showDots,
          ),

          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withValues(
              alpha: 0.15,
            ),
          ),

          spots: revenueData
              .asMap()
              .entries
              .map(
                (entry) => FlSpot(
                  entry.key.toDouble(),
                  entry.value.amount,
                ),
              )
              .toList(),
        ),
      ],

      lineTouchData: LineTouchData(
        touchTooltipData:
            LineTouchTooltipData(
          getTooltipItems:
              (touchedSpots) {
            return touchedSpots.map(
              (spot) {
                return LineTooltipItem(
                  '${revenueData[spot.x.toInt()].label}\n${AppFormatters.formatCurrency(spot.y)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                );
              },
            ).toList();
          },
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
  ) {
    final totalRevenue =
        revenueData.fold<double>(
      0,
      (sum, item) =>
          sum + item.amount,
    );

    final highestRevenue =
        revenueData
            .map((e) => e.amount)
            .reduce(
              (a, b) =>
                  a > b ? a : b,
            );

    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: [
        _InfoTile(
          title: 'Total Revenue',
          value: AppFormatters
              .formatCurrency(
            totalRevenue,
          ),
        ),
        _InfoTile(
          title: 'Peak Revenue',
          value: AppFormatters
              .formatCurrency(
            highestRevenue,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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