import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/provider_model.dart';
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
import '../../widgets/dialogs/approve_dialog.dart';
import '../../widgets/dialogs/delete_dialog.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({
    super.key,
  });

  @override
  State<ProviderServicesScreen> createState() =>
      _ProviderServicesScreenState();
}

class _ProviderServicesScreenState
    extends State<ProviderServicesScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  ProviderModel? _provider;

  String? _selectedStatus;

  int _page = 1;
  final int _limit = 20;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is ProviderModel) {
      _provider = args;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadServices();
        },
      );
    } else if (args is Map<String, dynamic>) {
      final providerArg = args['provider'];

      if (providerArg is ProviderModel) {
        _provider = providerArg;
      }

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadServices();
        },
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // =====================================================
  // LOAD SERVICES
  // =====================================================

  Future<void> _loadServices({
    int page = 1,
  }) async {
    if (_provider == null) return;

    _page = page;

    await context
        .read<ServiceProvider>()
        .getServices(
          page: _page,
          limit: _limit,
          providerId: _provider!.id,
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
    await _loadServices(
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

    await _loadServices(
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

    await _loadServices(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadServices(
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
  // APPROVE SERVICE
  // =====================================================

  Future<void> _approveService(
    ServiceModel service,
  ) async {
    final confirmed =
        await ApproveServiceDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<ServiceProvider>()
            .approveService(
              service.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Service approved successfully',
      );

      await _refresh();
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // REJECT SERVICE
  // =====================================================

  Future<void> _rejectService(
    ServiceModel service,
  ) async {
    final reasonController =
        TextEditingController();

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Reject Service',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter rejection reason for ${service.name}.',
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    reasonController,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Rejection reason',
                  border:
                      OutlineInputBorder(),
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
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.error,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      reasonController.dispose();
      return;
    }

    final reason =
        reasonController.text.trim();

    reasonController.dispose();

    if (reason.isEmpty) {
      NavigationService.showWarning(
        'Rejection reason is required',
      );
      return;
    }

    final success =
        await context
            .read<ServiceProvider>()
            .rejectService(
              serviceId: service.id,
              reason: reason,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Service rejected successfully',
      );

      await _refresh();
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // ACTIVATE SERVICE
  // =====================================================

  Future<void> _activateService(
    ServiceModel service,
  ) async {
    final success =
        await context
            .read<ServiceProvider>()
            .activateService(
              service.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Service activated successfully',
      );

      await _refresh();
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // DEACTIVATE SERVICE
  // =====================================================

  Future<void> _deactivateService(
    ServiceModel service,
  ) async {
    final success =
        await context
            .read<ServiceProvider>()
            .deactivateService(
              service.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Service deactivated successfully',
      );

      await _refresh();
    } else {
      _showProviderError();
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
      _showProviderError();
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showProviderError() {
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

    await _loadServices(
      page: _page - 1,
    );
  }

  Future<void> _nextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadServices(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadServices(
      page: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_provider == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Provider Services',
          ),
        ),
        body: const Center(
          child: Text(
            'Provider data not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Provider Services',
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.refresh,
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
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

                    _buildProviderSummary(),

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

                    _ProviderServicesTable(
                      services:
                          serviceProvider.services,
                      isLoading:
                          serviceProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewService,
                      onApprove:
                          _approveService,
                      onReject: _rejectService,
                      onActivate:
                          _activateService,
                      onDeactivate:
                          _deactivateService,
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
                          serviceProvider.totalServices,
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
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Provider Services',
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
                'View and manage all services listed by ${_provider!.displayName}.',
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
        ),

        const SizedBox(width: 16),

        _SummaryCard(
          title: 'Services',
          value:
              provider.totalServices.toString(),
          icon: Icons
              .miscellaneous_services_outlined,
          color: AppColors.primary,
        ),
      ],
    );
  }

  // =====================================================
  // PROVIDER SUMMARY
  // =====================================================

  Widget _buildProviderSummary() {
    final provider = _provider!;

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
          AppDimensions.padding20,
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final isMobile =
                constraints.maxWidth < 700;

            final providerInfo = Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      AppColors.primary
                          .withOpacity(0.10),
                  backgroundImage:
                      provider.profileImage != null &&
                              provider
                                  .profileImage!
                                  .isNotEmpty
                          ? NetworkImage(
                              provider.profileImage!,
                            )
                          : null,
                  child: provider.profileImage ==
                              null ||
                          provider
                              .profileImage!
                              .isEmpty
                      ? Text(
                          AppFormatters
                              .getInitials(
                            provider.displayName,
                          ),
                          style:
                              const TextStyle(
                            color:
                                AppColors.primary,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.displayName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w800,
                            ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        provider.businessName
                                .isNotEmpty
                            ? provider.businessName
                            : '-',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        provider.categoryName
                                .isNotEmpty
                            ? provider.categoryName
                            : '-',
                        style: const TextStyle(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            final metrics = Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MiniMetric(
                  label: 'Bookings',
                  value: AppFormatters
                      .formatNumber(
                    provider.totalBookings,
                  ),
                  color: AppColors.primary,
                ),
                _MiniMetric(
                  label: 'Earnings',
                  value: AppFormatters
                      .formatCurrency(
                    provider.totalEarnings,
                  ),
                  color: AppColors.success,
                ),
                _MiniMetric(
                  label: 'Rating',
                  value: provider.rating
                      .toStringAsFixed(1),
                  color: AppColors.warning,
                ),
              ],
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  providerInfo,
                  const SizedBox(height: 18),
                  metrics,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: providerInfo,
                ),
                metrics,
              ],
            );
          },
        ),
      ),
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
                  'Search services by name or category...',
              onChanged: _onSearch,
              onClear: _clearFilters,
            );

            final statusDropdown =
                CustomDropdown<String>(
              labelText: 'Service Status',
              hintText: 'All Status',
              value: _selectedStatus,
              items: const [
                'pending',
                'approved',
                'rejected',
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
                  width: 240,
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
// PROVIDER SERVICES TABLE
// =====================================================

class _ProviderServicesTable extends StatelessWidget {
  final List<ServiceModel> services;
  final bool isLoading;

  final VoidCallback? onRefresh;

  final Function(ServiceModel service)? onView;
  final Function(ServiceModel service)? onApprove;
  final Function(ServiceModel service)? onReject;
  final Function(ServiceModel service)? onActivate;
  final Function(ServiceModel service)? onDeactivate;
  final Function(ServiceModel service)? onDelete;

  const _ProviderServicesTable({
    required this.services,
    this.isLoading = false,
    this.onRefresh,
    this.onView,
    this.onApprove,
    this.onReject,
    this.onActivate,
    this.onDeactivate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading provider services...',
      );
    }

    if (services.isEmpty) {
      return EmptyWidget(
        icon: Icons.miscellaneous_services_outlined,
        title: 'No Services Found',
        description:
            'This provider has not added any services yet.',
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
                  title: 'Created',
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
                      Text(
                        AppFormatters
                            .formatNumber(
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
                      Text(
                        AppFormatters.formatDate(
                          service.createdAt,
                        ),
                      ),
                    ),
                    DataCell(
                      _ServiceActions(
                        service: service,
                        onView: onView,
                        onApprove: onApprove,
                        onReject: onReject,
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
        minWidth: 230,
        maxWidth: 300,
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withOpacity(0.10),
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
                    Icons
                        .miscellaneous_services_outlined,
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
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.25),
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
// SERVICE ACTIONS
// =====================================================

class _ServiceActions extends StatelessWidget {
  final ServiceModel service;

  final Function(ServiceModel service)? onView;
  final Function(ServiceModel service)? onApprove;
  final Function(ServiceModel service)? onReject;
  final Function(ServiceModel service)? onActivate;
  final Function(ServiceModel service)? onDeactivate;
  final Function(ServiceModel service)? onDelete;

  const _ServiceActions({
    required this.service,
    this.onView,
    this.onApprove,
    this.onReject,
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
            onView?.call(service);
            break;

          case 'approve':
            onApprove?.call(service);
            break;

          case 'reject':
            onReject?.call(service);
            break;

          case 'activate':
            onActivate?.call(service);
            break;

          case 'deactivate':
            onDeactivate?.call(service);
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
                icon: Icons.visibility_outlined,
                label: 'View',
              ),
            ),
          );
        }

        if (!service.isApproved &&
            !service.isRejected &&
            onApprove != null) {
          items.add(
            const PopupMenuItem(
              value: 'approve',
              child: _MenuItem(
                icon:
                    Icons.check_circle_outline,
                label: 'Approve',
                color: AppColors.success,
              ),
            ),
          );
        }

        if (!service.isApproved &&
            !service.isRejected &&
            onReject != null) {
          items.add(
            const PopupMenuItem(
              value: 'reject',
              child: _MenuItem(
                icon: Icons.cancel_outlined,
                label: 'Reject',
                color: AppColors.error,
              ),
            ),
          );
        }

        if (service.isApproved &&
            !service.isActive &&
            onActivate != null) {
          items.add(
            const PopupMenuItem(
              value: 'activate',
              child: _MenuItem(
                icon:
                    Icons.toggle_on_outlined,
                label: 'Activate',
                color: AppColors.success,
              ),
            ),
          );
        }

        if (service.isActive &&
            onDeactivate != null) {
          items.add(
            const PopupMenuItem(
              value: 'deactivate',
              child: _MenuItem(
                icon:
                    Icons.toggle_off_outlined,
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
        minWidth: 170,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding16,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius16,
        ),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
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

// =====================================================
// MINI METRIC
// =====================================================

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding12,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radius12,
        ),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
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
    );
  }
}