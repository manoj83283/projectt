import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
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

class FeaturedServicesScreen extends StatefulWidget {
  const FeaturedServicesScreen({
    super.key,
  });

  @override
  State<FeaturedServicesScreen> createState() =>
      _FeaturedServicesScreenState();
}

class _FeaturedServicesScreenState
    extends State<FeaturedServicesScreen> {
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
        _loadFeaturedServices();
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =====================================================
  // LOAD FEATURED SERVICES
  // =====================================================

  Future<void> _loadFeaturedServices({
    int page = 1,
  }) async {
    _page = page;

    await context
        .read<ServiceProvider>()
        .getFeaturedServices(
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
    await _loadFeaturedServices(
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

    await _loadFeaturedServices(
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

    await _loadFeaturedServices(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadFeaturedServices(
      page: _page,
    );
  }

  // =====================================================
  // VIEW SERVICE
  // =====================================================

  void _viewService(
    ServiceModel service,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.serviceDetails,
      arguments: service,
    );
  }

  // =====================================================
  // EDIT SERVICE
  // =====================================================

  void _editService(
    ServiceModel service,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.editService,
      arguments: service,
    ).then(
      (_) => _refresh(),
    );
  }

  // =====================================================
  // TOGGLE FEATURED STATUS
  // =====================================================

  Future<void> _toggleFeatured(
    ServiceModel service,
  ) async {
    final bool shouldFeature =
        !service.isFeatured;

    final success =
        await context
            .read<ServiceProvider>()
            .toggleFeaturedService(
              serviceId: service.id,
              isFeatured: shouldFeature,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        shouldFeature
            ? 'Service marked as featured'
            : 'Service removed from featured',
      );

      await _refresh();
    } else {
      _showServiceError();
    }
  }

  // =====================================================
  // UPDATE PRIORITY
  // =====================================================

  Future<void> _updatePriority(
    ServiceModel service,
  ) async {
    final TextEditingController priorityController =
        TextEditingController(
      text: service.featuredPriority.toString(),
    );

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Update Featured Priority',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: priorityController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText: 'Priority',
                  hintText:
                      'Lower number appears first',
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Example: 1 shows before 2, 2 shows before 3.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
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
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Update',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      priorityController.dispose();
      return;
    }

    final priority =
        int.tryParse(
              priorityController.text.trim(),
            ) ??
            0;

    priorityController.dispose();

    if (priority < 0) {
      NavigationService.showWarning(
        'Priority cannot be negative',
      );
      return;
    }

    final success =
        await context
            .read<ServiceProvider>()
            .updateFeaturedPriority(
              serviceId: service.id,
              priority: priority,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Featured priority updated successfully',
      );

      await _refresh();
    } else {
      _showServiceError();
    }
  }

  // =====================================================
  // REMOVE FEATURED
  // =====================================================

  Future<void> _removeFeatured(
    ServiceModel service,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Remove From Featured',
          ),
          content: Text(
            'Are you sure you want to remove "${service.name}" from featured services?',
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
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<ServiceProvider>()
            .toggleFeaturedService(
              serviceId: service.id,
              isFeatured: false,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Service removed from featured',
      );

      await _refresh();
    } else {
      _showServiceError();
    }
  }

  // =====================================================
  // DELETE SERVICE
  // =====================================================

  Future<void> _deleteService(
    ServiceModel service,
  ) async {
    final confirmed =
        await DeleteServiceDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<ServiceProvider>()
            .deleteService(
              service.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Service deleted successfully',
      );

      await _refresh();
    } else {
      _showServiceError();
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showServiceError() {
    final error =
        context
            .read<ServiceProvider>()
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

    await _loadFeaturedServices(
      page: _page - 1,
    );
  }

  Future<void> _nextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadFeaturedServices(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadFeaturedServices(
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
          'Featured Services',
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
        child: Consumer<ServiceProvider>(
          builder: (
            context,
            serviceProvider,
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
                      serviceProvider,
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

                    if (serviceProvider
                            .errorMessage !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: serviceProvider
                              .errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    FeaturedServicesTable(
                      services: serviceProvider
                          .featuredServices,
                      isLoading:
                          serviceProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewService,
                      onEdit: _editService,
                      onToggleFeatured:
                          _toggleFeatured,
                      onUpdatePriority:
                          _updatePriority,
                      onRemoveFeatured:
                          _removeFeatured,
                      onDelete: _deleteService,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding16,
                    ),

                    PaginationWidget(
                      currentPage:
                          serviceProvider.currentPage,
                      totalPages:
                          serviceProvider.totalPages,
                      totalRecords:
                          serviceProvider
                              .totalFeaturedServices,
                      pageSize: _limit,
                      onPrevious:
                          _previousPage,
                      onNext: () {
                        _nextPage(
                          serviceProvider.totalPages,
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
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(
    ServiceProvider provider,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final bool isMobile =
            constraints.maxWidth < 950;

        final titleSection = Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Featured Services',
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
                'Control highlighted services shown on customer-facing home, category, and promotional sections.',
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
            _SummaryCard(
              title: 'Featured',
              value: provider.totalFeaturedServices
                  .toString(),
              icon: Icons.star_outline_rounded,
              color: AppColors.warning,
            ),
            _SummaryCard(
              title: 'Active',
              value: provider
                  .activeFeaturedServices
                  .toString(),
              icon:
                  Icons.check_circle_outline,
              color: AppColors.success,
            ),
            _SummaryCard(
              title: 'Inactive',
              value: provider
                  .inactiveFeaturedServices
                  .toString(),
              icon: Icons.block_outlined,
              color: AppColors.error,
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
                constraints.maxWidth < 750;

            final search = CustomSearchBar(
              controller: _searchController,
              hintText:
                  'Search featured services by name, provider or category...',
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
// FEATURED SERVICES TABLE
// =====================================================

class FeaturedServicesTable extends StatelessWidget {
  final List<ServiceModel> services;
  final bool isLoading;

  final VoidCallback? onRefresh;

  final Function(ServiceModel service)? onView;
  final Function(ServiceModel service)? onEdit;
  final Function(ServiceModel service)? onToggleFeatured;
  final Function(ServiceModel service)? onUpdatePriority;
  final Function(ServiceModel service)? onRemoveFeatured;
  final Function(ServiceModel service)? onDelete;

  const FeaturedServicesTable({
    super.key,
    required this.services,
    this.isLoading = false,
    this.onRefresh,
    this.onView,
    this.onEdit,
    this.onToggleFeatured,
    this.onUpdatePriority,
    this.onRemoveFeatured,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading featured services...',
      );
    }

    if (services.isEmpty) {
      return EmptyWidget(
        icon: Icons.star_outline_rounded,
        title: 'No Featured Services Found',
        description:
            'Mark services as featured to highlight them in customer-facing sections.',
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
                  title: 'Service',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Provider',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Category',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Price',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Priority',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Bookings',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Rating',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Status',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Featured',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Actions',
                ),
              ),
            ],
            rows: services.map(
              (service) {
                return DataRow(
                  cells: [
                    DataCell(
                      _ServiceInfoCell(
                        service: service,
                      ),
                    ),
                    DataCell(
                      _ProviderCell(
                        service: service,
                      ),
                    ),
                    DataCell(
                      Text(
                        service.categoryName
                                .isNotEmpty
                            ? service.categoryName
                            : '-',
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters
                            .formatCurrency(
                          service.price,
                        ),
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),
                    DataCell(
                      _PriorityBadge(
                        priority:
                            service.featuredPriority,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatNumber(
                          service.totalBookings,
                        ),
                      ),
                    ),
                    DataCell(
                      _RatingCell(
                        service: service,
                      ),
                    ),
                    DataCell(
                      _ServiceStatusBadge(
                        service: service,
                      ),
                    ),
                    DataCell(
                      _FeaturedBadge(
                        isFeatured:
                            service.isFeatured,
                      ),
                    ),
                    DataCell(
                      _FeaturedServiceActions(
                        service: service,
                        onView: onView,
                        onEdit: onEdit,
                        onToggleFeatured:
                            onToggleFeatured,
                        onUpdatePriority:
                            onUpdatePriority,
                        onRemoveFeatured:
                            onRemoveFeatured,
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
// SERVICE INFO CELL
// =====================================================

class _ServiceInfoCell extends StatelessWidget {
  final ServiceModel service;

  const _ServiceInfoCell({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        service.image != null &&
            service.image!.isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 250,
        maxWidth: 330,
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.warning
                  .withValues(alpha: 0.10),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radius12,
              ),
              image: hasImage
                  ? DecorationImage(
                      image: NetworkImage(
                        service.image!,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? null
                : const Icon(
                    Icons.star_outline_rounded,
                    color: AppColors.warning,
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
                  service.name.isNotEmpty
                      ? service.name
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
                  service.id,
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
// PROVIDER CELL
// =====================================================

class _ProviderCell extends StatelessWidget {
  final ServiceModel service;

  const _ProviderCell({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 170,
        maxWidth: 230,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            service.providerName.isNotEmpty
                ? service.providerName
                : '-',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight:
                  FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            service.providerId.isNotEmpty
                ? service.providerId
                : '-',
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// RATING CELL
// =====================================================

class _RatingCell extends StatelessWidget {
  final ServiceModel service;

  const _RatingCell({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.star_rounded,
          size: 18,
          color: AppColors.warning,
        ),
        const SizedBox(width: 4),
        Text(
          service.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${service.totalReviews})',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// PRIORITY BADGE
// =====================================================

class _PriorityBadge extends StatelessWidget {
  final int priority;

  const _PriorityBadge({
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius8,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Text(
        priority.toString(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// =====================================================
// SERVICE STATUS BADGE
// =====================================================

class _ServiceStatusBadge extends StatelessWidget {
  final ServiceModel service;

  const _ServiceStatusBadge({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    if (service.isRejected) {
      return const _StatusChip(
        label: 'Rejected',
        color: AppColors.error,
      );
    }

    if (!service.isApproved) {
      return const _StatusChip(
        label: 'Pending',
        color: AppColors.warning,
      );
    }

    if (!service.isActive) {
      return const _StatusChip(
        label: 'Inactive',
        color: AppColors.warning,
      );
    }

    return const _StatusChip(
      label: 'Active',
      color: AppColors.success,
    );
  }
}

// =====================================================
// FEATURED BADGE
// =====================================================

class _FeaturedBadge extends StatelessWidget {
  final bool isFeatured;

  const _FeaturedBadge({
    required this.isFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return _StatusChip(
      label: isFeatured
          ? 'Featured'
          : 'Not Featured',
      color: isFeatured
          ? AppColors.warning
          : AppColors.textSecondary,
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
// FEATURED SERVICE ACTIONS
// =====================================================

class _FeaturedServiceActions extends StatelessWidget {
  final ServiceModel service;

  final Function(ServiceModel service)? onView;
  final Function(ServiceModel service)? onEdit;
  final Function(ServiceModel service)? onToggleFeatured;
  final Function(ServiceModel service)? onUpdatePriority;
  final Function(ServiceModel service)? onRemoveFeatured;
  final Function(ServiceModel service)? onDelete;

  const _FeaturedServiceActions({
    required this.service,
    this.onView,
    this.onEdit,
    this.onToggleFeatured,
    this.onUpdatePriority,
    this.onRemoveFeatured,
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
            onView?.call(service);
            break;

          case 'edit':
            onEdit?.call(service);
            break;

          case 'toggle_featured':
            onToggleFeatured?.call(service);
            break;

          case 'priority':
            onUpdatePriority?.call(service);
            break;

          case 'remove_featured':
            onRemoveFeatured?.call(service);
            break;

          case 'delete':
            onDelete?.call(service);
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

        if (onUpdatePriority != null) {
          items.add(
            const PopupMenuItem(
              value: 'priority',
              child: _MenuItem(
                icon:
                    Icons.low_priority_rounded,
                label: 'Update Priority',
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (onToggleFeatured != null) {
          items.add(
            PopupMenuItem(
              value: 'toggle_featured',
              child: _MenuItem(
                icon: service.isFeatured
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                label: service.isFeatured
                    ? 'Unfeature'
                    : 'Feature',
                color: AppColors.warning,
              ),
            ),
          );
        }

        if (onRemoveFeatured != null) {
          items.add(
            const PopupMenuItem(
              value: 'remove_featured',
              child: _MenuItem(
                icon: Icons.remove_circle_outline,
                label: 'Remove Featured',
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

// =====================================================
// MENU ITEM
// =====================================================

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

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 165,
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