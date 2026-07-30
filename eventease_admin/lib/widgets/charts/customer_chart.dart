import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';

class CustomerChartData {
  final String month;
  final int customers;

  const CustomerChartData({
    required this.month,
    required this.customers,
  });
}

class CustomerChart extends StatelessWidget {
  final List<CustomerChartData> data;
  final String title;
  final Color chartColor;
  final bool isCurved;
  final bool showGrid;

  const CustomerChart({
    super.key,
    required this.data,
    this.title = 'Customer Growth',
    this.chartColor = AppColors.primary,
    this.isCurved = true,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 350,
          child: Center(
            child: Text(
              'No customer data available',
            ),
          ),
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

            const SizedBox(height: 24),

            SizedBox(
              height: 300,
              child: LineChart(
                _lineChartData(),
              ),
            ),

            const SizedBox(height: 20),

            _buildStatistics(context),
          ],
        ),
      ),
    );
  }

  LineChartData _lineChartData() {
    final maxCustomers = data
        .map((e) => e.customers)
        .reduce(
          (a, b) => a > b ? a : b,
        );

    return LineChartData(
      minY: 0,
      maxY: maxCustomers * 1.2,

      gridData: FlGridData(
        show: showGrid,
      ),

      borderData: FlBorderData(
        show: true,
      ),

      titlesData: FlTitlesData(
        topTitles:
            const AxisTitles(),
        rightTitles:
            const AxisTitles(),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
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
                  data[index].month,
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
            reservedSize: 50,
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

      lineBarsData: [
        LineChartBarData(
          isCurved: isCurved,
          color: chartColor,
          barWidth: 4,

          isStrokeCapRound: true,

          dotData: const FlDotData(
            show: true,
          ),

          belowBarData: BarAreaData(
            show: true,
            color: chartColor.withOpacity(
              0.15,
            ),
          ),

          spots: data
              .asMap()
              .entries
              .map(
                (entry) => FlSpot(
                  entry.key.toDouble(),
                  entry.value.customers
                      .toDouble(),
                ),
              )
              .toList(),
        ),
      ],

      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData:
            LineTouchTooltipData(
          getTooltipItems:
              (touchedSpots) {
            return touchedSpots.map(
              (spot) {
                return LineTooltipItem(
                  '${data[spot.x.toInt()].month}\n${spot.y.toInt()} Customers',
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

  Widget _buildStatistics(
    BuildContext context,
  ) {
    final totalCustomers =
        data.fold<int>(
      0,
      (sum, item) =>
          sum + item.customers,
    );

    final highestCustomers =
        data
            .map((e) => e.customers)
            .reduce(
              (a, b) =>
                  a > b ? a : b,
            );

    final averageCustomers =
        totalCustomers / data.length;

    final latestCustomers =
        data.last.customers;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _StatCard(
          title: 'Total Customers',
          value: AppFormatters
              .formatNumber(
            totalCustomers,
          ),
          color: AppColors.primary,
        ),
        _StatCard(
          title: 'Peak Customers',
          value: AppFormatters
              .formatNumber(
            highestCustomers,
          ),
          color: AppColors.success,
        ),
        _StatCard(
          title: 'Average',
          value:
              averageCustomers.toStringAsFixed(
            0,
          ),
          color: AppColors.warning,
        ),
        _StatCard(
          title: 'Latest Month',
          value: AppFormatters
              .formatNumber(
            latestCustomers,
          ),
          color: AppColors.secondary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 150,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(
          0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radius12,
        ),
        border: Border.all(
          color: color.withOpacity(
            0.20,
          ),
        ),
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
          const SizedBox(height: 6),
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