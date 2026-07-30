import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final int pageSize;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int>? onPageSelected;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    this.pageSize = 20,
    this.onPrevious,
    this.onNext,
    this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 12,
        crossAxisAlignment:
            WrapCrossAlignment.center,
        children: [
          Text(
            _recordText(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _navigationButton(
                icon:
                    Icons.keyboard_double_arrow_left,
                enabled: currentPage > 1,
                onTap: onPrevious,
              ),

              const SizedBox(width: 8),

              ..._buildPageButtons(),

              const SizedBox(width: 8),

              _navigationButton(
                icon:
                    Icons.keyboard_double_arrow_right,
                enabled:
                    currentPage < totalPages,
                onTap: onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageButtons() {
    final widgets = <Widget>[];

    int startPage = currentPage - 2;
    int endPage = currentPage + 2;

    if (startPage < 1) {
      startPage = 1;
      endPage =
          totalPages > 5 ? 5 : totalPages;
    }

    if (endPage > totalPages) {
      endPage = totalPages;
      startPage =
          totalPages > 5 ? totalPages - 4 : 1;
    }

    for (int page = startPage;
        page <= endPage;
        page++) {
      widgets.add(
        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 2,
          ),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radius8,
            ),
            onTap: () {
              onPageSelected?.call(page);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: currentPage == page
                    ? AppColors.primary
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radius8,
                ),
                border: Border.all(
                  color: currentPage == page
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  '$page',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    color:
                        currentPage == page
                            ? Colors.white
                            : AppColors
                                .textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _navigationButton({
    required IconData icon,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
      color: enabled
          ? AppColors.primary
          : Colors.grey,
    );
  }

  String _recordText() {
    final start =
        ((currentPage - 1) * pageSize) + 1;

    int end = currentPage * pageSize;

    if (end > totalRecords) {
      end = totalRecords;
    }

    return 'Showing $start - $end of $totalRecords records';
  }
}

// =====================================================
// SIMPLE PAGINATION
// =====================================================

class SimplePaginationWidget
    extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const SimplePaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed:
              currentPage > 1
                  ? onPrevious
                  : null,
          icon: const Icon(
            Icons.chevron_left,
          ),
          label: const Text('Previous'),
        ),

        const SizedBox(width: 12),

        Text(
          'Page $currentPage of $totalPages',
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),

        const SizedBox(width: 12),

        OutlinedButton.icon(
          onPressed:
              currentPage < totalPages
                  ? onNext
                  : null,
          icon: const Icon(
            Icons.chevron_right,
          ),
          label: const Text('Next'),
        ),
      ],
    );
  }
}

// =====================================================
// DATA TABLE PAGINATION
// =====================================================

class TablePaginationInfo
    extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalRecords;

  const TablePaginationInfo({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.table_rows_outlined,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          'Page $currentPage / $totalPages • Total Records: $totalRecords',
        ),
      ],
    );
  }
}