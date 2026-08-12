import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';

class OrderChartData {
  final String label;
  final int orders;

  const OrderChartData({
    required this.label,
    required this.orders,
  });
}

class OrderChart extends StatelessWidget {
  final List<OrderChartData> data;
  final String title;
  final bool showGrid;
  final Color chartColor;

  const OrderChart({
    super.key,
    required this.data,
    this.title = 'Orders Overview',
    this.showGrid = true,
    this.chartColor = AppColors.success,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 350,
          child: Center(
            child: Text(
              'No order data available',
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
              child: BarChart(
                _barChartData(),
              ),
            ),

            const SizedBox(height: 20),

            _buildStatistics(context),
          ],
        ),
      ),
    );
  }

  BarChartData _barChartData() {
    final maxOrders = data
        .map((e) => e.orders)
        .reduce(
          (a, b) => a > b ? a : b,
        );

    return BarChartData(
      alignment:
          BarChartAlignment.spaceAround,

      maxY: maxOrders * 1.25,

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

              if (index <
                      0 ||
                  index >=
                      data.length) {
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
            reservedSize: 40,
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

      barGroups: data
          .asMap()
          .entries
          .map(
            (entry) =>
                BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.orders
                      .toDouble(),
                  width: 30,
                  color: chartColor,
                  borderRadius:
                      BorderRadius.circular(
                    6,
                  ),
                ),
              ],
            ),
          )
          .toList(),

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
              '${data[group.x].label}\n${rod.toY.toInt()} Orders',
              const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatistics(
    BuildContext context,
  ) {
    final totalOrders = data.fold<int>(
      0,
      (sum, item) =>
          sum + item.orders,
    );

    final highestOrders = data
        .map((e) => e.orders)
        .reduce(
          (a, b) => a > b ? a : b,
        );

    final averageOrders =
        totalOrders / data.length;

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _StatCard(
          title: 'Total Orders',
          value: AppFormatters
              .formatNumber(
            totalOrders,
          ),
          color: AppColors.primary,
        ),
        _StatCard(
          title: 'Peak Orders',
          value: AppFormatters
              .formatNumber(
            highestOrders,
          ),
          color: AppColors.success,
        ),
        _StatCard(
          title: 'Average Orders',
          value:
              averageOrders.toStringAsFixed(
            0,
          ),
          color: AppColors.warning,
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
        minWidth: 140,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radius12,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: 0.20,
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