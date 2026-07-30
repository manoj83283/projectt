import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';

class ProviderChartData {
  final String category;
  final int count;
  final Color? color;

  const ProviderChartData({
    required this.category,
    required this.count,
    this.color,
  });
}

class ProviderChart extends StatelessWidget {
  final List<ProviderChartData> data;
  final String title;
  final bool showLegend;

  const ProviderChart({
    super.key,
    required this.data,
    this.title = 'Providers by Category',
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Card(
        child: SizedBox(
          height: 350,
          child: Center(
            child: Text(
              'No provider data available',
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

            const SizedBox(height: 20),

            SizedBox(
              height: 320,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      _pieChartData(),
                    ),
                  ),

                  if (showLegend)
                    Expanded(
                      child: _buildLegend(
                        context,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildSummary(context),
          ],
        ),
      ),
    );
  }

  PieChartData _pieChartData() {
    return PieChartData(
      sectionsSpace: 3,
      centerSpaceRadius: 50,
      sections: data
          .asMap()
          .entries
          .map(
            (entry) => PieChartSectionData(
              color: _getColor(
                entry.key,
                entry.value.color,
              ),
              value:
                  entry.value.count.toDouble(),
              title:
                  '${entry.value.count}',
              radius: 85,
              titleStyle:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLegend(
    BuildContext context,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (_, index) {
        final item = data[index];

        return Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 6,
          ),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _getColor(
                    index,
                    item.color,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    4,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  item.category,
                  overflow:
                      TextOverflow.ellipsis,
                ),
              ),

              Text(
                AppFormatters
                    .formatNumber(
                  item.count,
                ),
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary(
    BuildContext context,
  ) {
    final totalProviders =
        data.fold<int>(
      0,
      (sum, item) =>
          sum + item.count,
    );

    final highestCategory =
        data.reduce(
      (a, b) =>
          a.count > b.count
              ? a
              : b,
    );

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: [
        _SummaryCard(
          title: 'Total Providers',
          value: AppFormatters
              .formatNumber(
            totalProviders,
          ),
          color: AppColors.primary,
        ),
        _SummaryCard(
          title: 'Top Category',
          value:
              highestCategory.category,
          color: AppColors.success,
        ),
        _SummaryCard(
          title: 'Highest Count',
          value:
              highestCategory.count
                  .toString(),
          color: AppColors.warning,
        ),
      ],
    );
  }

  Color _getColor(
    int index,
    Color? customColor,
  ) {
    if (customColor != null) {
      return customColor;
    }

    const colors = [
      Color(0xFF2563EB),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFFF97316),
      Color(0xFF84CC16),
    ];

    return colors[
        index % colors.length];
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
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