import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/dialogs/delete_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
  });

  @override
  State<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends State<CategoriesScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String? _selectedStatus;

  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadCategories();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // =====================================================
  // LOAD CATEGORIES
  // =====================================================

  Future<void> _loadCategories({
    int page = 1,
  }) async {
    _page = page;

    await context
        .read<CategoryProvider>()
        .getCategories(
          page: _page,
          limit: _limit,
          search:
              _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
          status: _selectedStatus,
        );
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<void> _onSearch(
    String value,
  ) async {
    await _loadCategories(
      page: 1,
    );
  }

  // =====================================================
  // STATUS FILTER
  // =====================================================

  Future<void> _onStatusChanged(
    String? value,
  ) async {
    setState(() {
      _selectedStatus = value;
    });

    await _loadCategories(
      page: 1,
    );
  }

  // =====================================================
  // CLEAR FILTERS
  // =====================================================

  Future<void> _clearFilters() async {
    _searchController.clear();

    setState(() {
      _selectedStatus = null;
      _page = 1;
    });

    await _loadCategories(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadCategories(
      page: _page,
    );
  }

  // =====================================================
  // ADD CATEGORY
  // =====================================================

  void _addCategory() {
    Navigator.pushNamed(
      context,
      AppRoutes.addCategory,
    ).then(
      (_) => _refresh(),
    );
  }

  // =====================================================
  // VIEW CATEGORY
  // =====================================================

  void _viewCategory(
    CategoryModel category,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.categoryDetails,
      arguments: category,
    );
  }

  // =====================================================
  // EDIT CATEGORY
  // =====================================================

  void _editCategory(
    CategoryModel category,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.editCategory,
      arguments: category,
    ).then(
      (_) => _refresh(),
    );
  }

  // =====================================================
  // ACTIVATE CATEGORY
  // =====================================================

  Future<void> _activateCategory(
    CategoryModel category,
  ) async {
    final success =
        await context
            .read<CategoryProvider>()
            .activateCategory(
              category.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Category activated successfully',
      );

      await _refresh();
    } else {
      _showCategoryError();
    }
  }

  // =====================================================
  // DEACTIVATE CATEGORY
  // =====================================================

  Future<void> _deactivateCategory(
    CategoryModel category,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Deactivate Category',
          ),
          content: Text(
            'Are you sure you want to deactivate ${category.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                AppStrings.cancel,
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.warning,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Deactivate',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<CategoryProvider>()
            .deactivateCategory(
              category.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Category deactivated successfully',
      );

      await _refresh();
    } else {
      _showCategoryError();
    }
  }

  // =====================================================
  // DELETE CATEGORY
  // =====================================================

  Future<void> _deleteCategory(
    CategoryModel category,
  ) async {
    final confirmed =
        await DeleteCategoryDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<CategoryProvider>()
            .deleteCategory(
              category.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Category deleted successfully',
      );

      await _refresh();
    } else {
      _showCategoryError();
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showCategoryError() {
    final error =
        context
            .read<CategoryProvider>()
            .errorMessage;

    NavigationService.showError(
      error ?? AppStrings.somethingWentWrong,
    );
  }

  // =====================================================
  // PAGINATION
  // =====================================================

  Future<void> _previousPage() async {
    if (_page <= 1) return;

    await _loadCategories(
      page: _page - 1,
    );
  }

  Future<void> _nextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadCategories(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadCategories(
      page: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.categories,
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Consumer<CategoryProvider>(
          builder: (
            context,
            categoryProvider,
            child,
          ) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(
                  AppDimensions.padding24,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _buildHeader(
                      categoryProvider,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildFilters(),

                    const SizedBox(
                      height:
                          AppDimensions.padding20,
                    ),

                    if (categoryProvider
                            .errorMessage !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: categoryProvider
                              .errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    CategoriesTable(
                      categories:
                          categoryProvider.categories,
                      isLoading:
                          categoryProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewCategory,
                      onEdit: _editCategory,
                      onActivate:
                          _activateCategory,
                      onDeactivate:
                          _deactivateCategory,
                      onDelete: _deleteCategory,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding16,
                    ),

                    PaginationWidget(
                      currentPage:
                          categoryProvider.currentPage,
                      totalPages:
                          categoryProvider.totalPages,
                      totalRecords:
                          categoryProvider
                              .totalCategories,
                      pageSize: _limit,
                      onPrevious:
                          _previousPage,
                      onNext: () {
                        _nextPage(
                          categoryProvider
                              .totalPages,
                        );
                      },
                      onPageSelected:
                          _goToPage,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addCategory,
        backgroundColor:
            AppColors.primary,
        foregroundColor:
            Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Category',
        ),
      ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(
    CategoryProvider provider,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final bool isMobile =
            constraints.maxWidth < 850;

        final titleSection = Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.categories,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                'Manage EventEase service categories, category visibility, ordering, and marketplace organization.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        );

        final summaryCards = Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _CategorySummaryCard(
              title: 'Total Categories',
              value: provider.totalCategories
                  .toString(),
              icon: Icons.category_outlined,
              color: AppColors.primary,
            ),
            _CategorySummaryCard(
              title: 'Active',
              value: provider.activeCategories
                  .toString(),
              icon:
                  Icons.check_circle_outline,
              color: AppColors.success,
            ),
            _CategorySummaryCard(
              title: 'Inactive',
              value: provider.inactiveCategories
                  .toString(),
              icon: Icons.block_outlined,
              color: AppColors.warning,
            ),
          ],
        );

        if (isMobile) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  titleSection,
                ],
              ),
              const SizedBox(height: 16),
              summaryCards,
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            titleSection,
            const SizedBox(width: 16),
            summaryCards,
          ],
        );
      },
    );
  }

  // =====================================================
  // FILTERS
  // =====================================================

  Widget _buildFilters() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.padding16,
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool isMobile =
                constraints.maxWidth < 700;

            final search = CustomSearchBar(
              controller: _searchController,
              hintText:
                  'Search categories by name or description...',
              onChanged: _onSearch,
              onClear: _clearFilters,
            );

            final statusDropdown =
                CustomDropdown<String>(
              labelText: 'Status',
              hintText: 'All Status',
              value: _selectedStatus,
              items: const [
                'active',
                'inactive',
              ],
              itemLabelBuilder:
                  AppFormatters.formatStatus,
              onChanged:
                  _onStatusChanged,
              prefixIcon: const Icon(
                Icons.filter_alt_outlined,
              ),
            );

            final clearButton =
                CustomButton(
              text: 'Clear',
              type: ButtonType.outline,
              icon: Icons.clear_rounded,
              onPressed: _clearFilters,
            );

            if (isMobile) {
              return Column(
                children: [
                  search,
                  const SizedBox(height: 12),
                  statusDropdown,
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: clearButton,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: search,
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: 220,
                  child: statusDropdown,
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: 130,
                  child: clearButton,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =====================================================
// CATEGORIES TABLE
// =====================================================

class CategoriesTable extends StatelessWidget {
  final List<CategoryModel> categories;
  final bool isLoading;

  final VoidCallback? onRefresh;

  final Function(CategoryModel category)? onView;
  final Function(CategoryModel category)? onEdit;
  final Function(CategoryModel category)? onActivate;
  final Function(CategoryModel category)? onDeactivate;
  final Function(CategoryModel category)? onDelete;

  const CategoriesTable({
    super.key,
    required this.categories,
    this.isLoading = false,
    this.onRefresh,
    this.onView,
    this.onEdit,
    this.onActivate,
    this.onDeactivate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading categories...',
      );
    }

    if (categories.isEmpty) {
      return EmptyWidget(
        icon: Icons.category_outlined,
        title: 'No Categories Found',
        description:
            'Create categories to organize EventEase services.',
        buttonText: AppStrings.refresh,
        onButtonPressed: onRefresh,
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight:
                AppDimensions.headingRowHeight,
            dataRowMinHeight:
                AppDimensions.dataRowHeight,
            dataRowMaxHeight:
                AppDimensions.dataRowHeight,
            headingRowColor:
                WidgetStateProperty.all(
              AppColors.background,
            ),
            columnSpacing: 28,
            horizontalMargin: 20,
            columns: const [
              DataColumn(
                label: _TableHeader(
                  title: 'Category',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Description',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Services',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Providers',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Sort Order',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Status',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Created',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Actions',
                ),
              ),
            ],
            rows: categories.map(
              (category) {
                return DataRow(
                  cells: [
                    DataCell(
                      _CategoryInfoCell(
                        category: category,
                      ),
                    ),
                    DataCell(
                      _DescriptionCell(
                        category: category,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatNumber(
                          category.totalServices,
                        ),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatNumber(
                          category.totalProviders,
                        ),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        category.sortOrder
                            .toString(),
                      ),
                    ),
                    DataCell(
                      _CategoryStatusBadge(
                        category: category,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatDate(
                          category.createdAt,
                        ),
                      ),
                    ),
                    DataCell(
                      _CategoryActions(
                        category: category,
                        onView: onView,
                        onEdit: onEdit,
                        onActivate: onActivate,
                        onDeactivate:
                            onDeactivate,
                        onDelete: onDelete,
                      ),
                    ),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// TABLE HEADER
// =====================================================

class _TableHeader extends StatelessWidget {
  final String title;

  const _TableHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// =====================================================
// CATEGORY INFO CELL
// =====================================================

class _CategoryInfoCell extends StatelessWidget {
  final CategoryModel category;

  const _CategoryInfoCell({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        category.image != null &&
            category.image!.isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 230,
        maxWidth: 300,
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radius12,
              ),
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(
                        category.image!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? null
                : const Icon(
                    Icons.category_outlined,
                    color: AppColors.primary,
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  category.name.isNotEmpty
                      ? category.name
                      : '-',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category.id,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color:
                        AppColors.textSecondary,
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

// =====================================================
// DESCRIPTION CELL
// =====================================================

class _DescriptionCell extends StatelessWidget {
  final CategoryModel category;

  const _DescriptionCell({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 240,
        maxWidth: 360,
      ),
      child: Text(
        category.description.isNotEmpty
            ? category.description
            : '-',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// =====================================================
// STATUS BADGE
// =====================================================

class _CategoryStatusBadge extends StatelessWidget {
  final CategoryModel category;

  const _CategoryStatusBadge({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    if (category.isActive) {
      return const _StatusChip(
        label: 'Active',
        color: AppColors.success,
      );
    }

    return const _StatusChip(
      label: 'Inactive',
      color: AppColors.warning,
    );
  }
}

// =====================================================
// STATUS CHIP
// =====================================================

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
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =====================================================
// CATEGORY ACTIONS
// =====================================================

class _CategoryActions extends StatelessWidget {
  final CategoryModel category;

  final Function(CategoryModel category)? onView;
  final Function(CategoryModel category)? onEdit;
  final Function(CategoryModel category)? onActivate;
  final Function(CategoryModel category)? onDeactivate;
  final Function(CategoryModel category)? onDelete;

  const _CategoryActions({
    required this.category,
    this.onView,
    this.onEdit,
    this.onActivate,
    this.onDeactivate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: const Icon(
        Icons.more_vert,
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView?.call(category);
            break;

          case 'edit':
            onEdit?.call(category);
            break;

          case 'activate':
            onActivate?.call(category);
            break;

          case 'deactivate':
            onDeactivate?.call(category);
            break;

          case 'delete':
            onDelete?.call(category);
            break;
        }
      },
      itemBuilder: (context) {
        final items =
            <PopupMenuEntry<String>>[];

        if (onView != null) {
          items.add(
            const PopupMenuItem(
              value: 'view',
              child: _MenuItem(
                icon:
                    Icons.visibility_outlined,
                label: 'View',
              ),
            ),
          );
        }

        if (onEdit != null) {
          items.add(
            const PopupMenuItem(
              value: 'edit',
              child: _MenuItem(
                icon: Icons.edit_outlined,
                label: 'Edit',
              ),
            ),
          );
        }

        if (!category.isActive &&
            onActivate != null) {
          items.add(
            const PopupMenuItem(
              value: 'activate',
              child: _MenuItem(
                icon:
                    Icons.check_circle_outline,
                label: 'Activate',
                color: AppColors.success,
              ),
            ),
          );
        }

        if (category.isActive &&
            onDeactivate != null) {
          items.add(
            const PopupMenuItem(
              value: 'deactivate',
              child: _MenuItem(
                icon:
                    Icons.block_outlined,
                label: 'Deactivate',
                color: AppColors.warning,
              ),
            ),
          );
        }

        if (onDelete != null) {
          items.add(
            const PopupMenuDivider(),
          );

          items.add(
            const PopupMenuItem(
              value: 'delete',
              child: _MenuItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: AppColors.error,
              ),
            ),
          );
        }

        return items;
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor =
        color ?? AppColors.textPrimary;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: itemColor,
        ),

        const SizedBox(width: 10),

        Text(
          label,
          style: TextStyle(
            color: itemColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// SUMMARY CARD
// =====================================================

class _CategorySummaryCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _CategorySummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 170,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radius12,
              ),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                      color:
                          AppColors.textPrimary,
                    ),
              ),

              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color:
                          AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}