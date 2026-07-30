import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dialogs/approve_dialog.dart';
import '../../widgets/dialogs/delete_dialog.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({
    super.key,
  });

  @override
  State<ServiceDetailsScreen> createState() =>
      _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState
    extends State<ServiceDetailsScreen> {
  ServiceModel? _service;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is ServiceModel) {
      _service = args;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadServiceDetails();
        },
      );
    } else if (args is Map<String, dynamic>) {
      final serviceArg = args['service'];

      if (serviceArg is ServiceModel) {
        _service = serviceArg;
      }

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadServiceDetails();
        },
      );
    }

    _initialized = true;
  }

  // =====================================================
  // LOAD SERVICE DETAILS
  // =====================================================

  Future<void> _loadServiceDetails() async {
    if (_service == null) return;

    await context
        .read<ServiceProvider>()
        .getServiceDetails(
          _service!.id,
        );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadServiceDetails();
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
      _showServiceError();
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
      _showServiceError();
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
      _showServiceError();
    }
  }

  // =====================================================
  // DEACTIVATE SERVICE
  // =====================================================

  Future<void> _deactivateService(
    ServiceModel service,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Deactivate Service',
          ),
          content: Text(
            'Are you sure you want to deactivate ${service.name}?',
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

      Navigator.pop(
        context,
        true,
      );
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

  @override
  Widget build(BuildContext context) {
    if (_service == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Service Details',
          ),
        ),
        body: const Center(
          child: Text(
            'Service data not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Service Details',
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
            if (serviceProvider.isLoading) {
              return const FullScreenLoadingWidget(
                message:
                    'Loading service details...',
              );
            }

            final service =
                serviceProvider.selectedService ??
                    _service!;

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

                    _buildHeroCard(
                      service,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildOverviewGrid(
                      service,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final bool isMobile =
                            constraints.maxWidth <
                                900;

                        if (isMobile) {
                          return Column(
                            children: [
                              _buildServiceInfoCard(
                                service,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildProviderInfoCard(
                                service,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildPricingInfoCard(
                                service,
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Expanded(
                              child:
                                  _buildServiceInfoCard(
                                service,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child:
                                  _buildProviderInfoCard(
                                service,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child:
                                  _buildPricingInfoCard(
                                service,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildDescriptionCard(
                      service,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildActionsCard(
                      service,
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
  // HERO CARD
  // =====================================================

  Widget _buildHeroCard(
    ServiceModel service,
  ) {
    final bool hasImage =
        service.image != null &&
            service.image!.isNotEmpty;

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
          AppDimensions.padding24,
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool isMobile =
                constraints.maxWidth < 760;

            final image = Container(
              height: isMobile ? 220 : 180,
              width: isMobile ? double.infinity : 240,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radius16,
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
                      Icons.miscellaneous_services_outlined,
                      color: AppColors.primary,
                      size: 54,
                    ),
            );

            final content = Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name.isNotEmpty
                        ? service.name
                        : 'Service',
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                          color: AppColors
                              .textPrimary,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    service.categoryName.isNotEmpty
                        ? service.categoryName
                        : '-',
                    style: const TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildServiceStatusChip(
                        service,
                      ),
                      _RatingChip(
                        rating: service.rating,
                        totalReviews:
                            service.totalReviews,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _MiniInfoBox(
                        title: 'Price',
                        value: AppFormatters
                            .formatCurrency(
                          service.price,
                        ),
                        icon:
                            Icons.currency_rupee_rounded,
                        color: AppColors.success,
                      ),
                      _MiniInfoBox(
                        title: 'Bookings',
                        value: AppFormatters
                            .formatNumber(
                          service.totalBookings,
                        ),
                        icon:
                            Icons.calendar_month_outlined,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  image,
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      content,
                    ],
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                image,
                const SizedBox(width: 24),
                content,
              ],
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // OVERVIEW GRID
  // =====================================================

  Widget _buildOverviewGrid(
    ServiceModel service,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        int crossAxisCount = 4;

        if (constraints.maxWidth < 700) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1100) {
          crossAxisCount = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio:
              crossAxisCount == 1 ? 3.8 : 1.8,
          children: [
            _StatCard(
              title: 'Price',
              value: AppFormatters
                  .formatCurrency(
                service.price,
              ),
              icon:
                  Icons.currency_rupee_rounded,
              color: AppColors.success,
            ),
            _StatCard(
              title: 'Bookings',
              value: AppFormatters
                  .formatNumber(
                service.totalBookings,
              ),
              icon:
                  Icons.calendar_month_outlined,
              color: AppColors.primary,
            ),
            _StatCard(
              title: 'Rating',
              value:
                  service.rating.toStringAsFixed(
                1,
              ),
              icon: Icons.star_outline,
              color: AppColors.warning,
            ),
            _StatCard(
              title: 'Reviews',
              value: AppFormatters
                  .formatNumber(
                service.totalReviews,
              ),
              icon:
                  Icons.rate_review_outlined,
              color: AppColors.info,
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // SERVICE INFO CARD
  // =====================================================

  Widget _buildServiceInfoCard(
    ServiceModel service,
  ) {
    return _DetailsCard(
      title: 'Service Information',
      icon: Icons.miscellaneous_services_outlined,
      children: [
        _InfoRow(
          label: 'Service ID',
          value: service.id,
        ),
        _InfoRow(
          label: 'Service Name',
          value: service.name.isNotEmpty
              ? service.name
              : '-',
        ),
        _InfoRow(
          label: 'Category',
          value: service.categoryName.isNotEmpty
              ? service.categoryName
              : '-',
        ),
        _InfoRow(
          label: 'Status',
          value: _serviceStatusText(
            service,
          ),
        ),
        _InfoRow(
          label: 'Created',
          value: AppFormatters.formatDate(
            service.createdAt,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PROVIDER INFO CARD
  // =====================================================

  Widget _buildProviderInfoCard(
    ServiceModel service,
  ) {
    return _DetailsCard(
      title: 'Provider Information',
      icon: Icons.business_center_outlined,
      children: [
        _InfoRow(
          label: 'Provider ID',
          value: service.providerId.isNotEmpty
              ? service.providerId
              : '-',
        ),
        _InfoRow(
          label: 'Provider',
          value: service.providerName.isNotEmpty
              ? service.providerName
              : '-',
        ),
        _InfoRow(
          label: 'Can Serve',
          value: service.isApproved &&
                  service.isActive &&
                  !service.isRejected
              ? 'Yes'
              : 'No',
        ),
      ],
    );
  }

  // =====================================================
  // PRICING INFO CARD
  // =====================================================

  Widget _buildPricingInfoCard(
    ServiceModel service,
  ) {
    return _DetailsCard(
      title: 'Pricing & Performance',
      icon: Icons.analytics_outlined,
      children: [
        _InfoRow(
          label: 'Base Price',
          value:
              AppFormatters.formatCurrency(
            service.price,
          ),
        ),
        _InfoRow(
          label: 'Bookings',
          value: AppFormatters.formatNumber(
            service.totalBookings,
          ),
        ),
        _InfoRow(
          label: 'Rating',
          value:
              '${service.rating.toStringAsFixed(1)} / 5',
        ),
        _InfoRow(
          label: 'Reviews',
          value: AppFormatters.formatNumber(
            service.totalReviews,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // DESCRIPTION CARD
  // =====================================================

  Widget _buildDescriptionCard(
    ServiceModel service,
  ) {
    return _DetailsCard(
      title: 'Description',
      icon: Icons.description_outlined,
      children: [
        Text(
          service.description.isNotEmpty
              ? service.description
              : 'No description available.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // ACTIONS CARD
  // =====================================================

  Widget _buildActionsCard(
    ServiceModel service,
  ) {
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
            final bool isMobile =
                constraints.maxWidth < 850;

            final actions =
                <Widget>[
              if (!service.isApproved &&
                  !service.isRejected)
                CustomButton(
                  text: 'Approve',
                  type: ButtonType.success,
                  icon:
                      Icons.check_circle_outline,
                  onPressed: () {
                    _approveService(service);
                  },
                ),
              if (!service.isApproved &&
                  !service.isRejected)
                CustomButton(
                  text: 'Reject',
                  type: ButtonType.danger,
                  icon: Icons.cancel_outlined,
                  onPressed: () {
                    _rejectService(service);
                  },
                ),
              if (service.isApproved &&
                  !service.isActive)
                CustomButton(
                  text: 'Activate',
                  type: ButtonType.success,
                  icon:
                      Icons.toggle_on_outlined,
                  onPressed: () {
                    _activateService(service);
                  },
                ),
              if (service.isActive)
                CustomButton(
                  text: 'Deactivate',
                  type: ButtonType.warning,
                  icon:
                      Icons.toggle_off_outlined,
                  onPressed: () {
                    _deactivateService(service);
                  },
                ),
              CustomButton(
                text: 'Delete',
                type: ButtonType.danger,
                icon: Icons.delete_outline,
                onPressed: () {
                  _deleteService(service);
                },
              ),
            ];

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildActionHeader(),
                  const SizedBox(height: 16),
                  ...actions.map(
                    (action) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: action,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildActionHeader(),
                const SizedBox(height: 16),
                Row(
                  children: actions
                      .map(
                        (action) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(
                              right: 12,
                            ),
                            child: action,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionHeader() {
    return Row(
      children: [
        const Icon(
          Icons.admin_panel_settings_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Text(
          'Admin Actions',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  // =====================================================
  // STATUS HELPERS
  // =====================================================

  Widget _buildServiceStatusChip(
    ServiceModel service,
  ) {
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

  String _serviceStatusText(
    ServiceModel service,
  ) {
    if (service.isRejected) {
      return 'Rejected';
    }

    if (!service.isApproved) {
      return 'Pending Approval';
    }

    if (!service.isActive) {
      return 'Inactive';
    }

    return 'Active';
  }
}

// =====================================================
// DETAILS CARD
// =====================================================

class _DetailsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailsCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            ...children,
          ],
        ),
      ),
    );
  }
}

// =====================================================
// INFO ROW
// =====================================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color:
                    AppColors.textSecondary,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// STAT CARD
// =====================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color:
                    color.withOpacity(0.10),
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

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                          color: AppColors
                              .textPrimary,
                        ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// MINI INFO BOX
// =====================================================

class _MiniInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniInfoBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 145,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.padding14,
      ),
      decoration: BoxDecoration(
        color:
            color.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(
          AppDimensions.radius14,
        ),
        border: Border.all(
          color:
              color.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w800,
                  color:
                      AppColors.textPrimary,
                ),
              ),

              Text(
                title,
                style: const TextStyle(
                  color:
                      AppColors.textSecondary,
                  fontSize: 12,
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
// RATING CHIP
// =====================================================

class _RatingChip extends StatelessWidget {
  final double rating;
  final int totalReviews;

  const _RatingChip({
    required this.rating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning
            .withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.warning
              .withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.warning,
            size: 17,
          ),

          const SizedBox(width: 4),

          Text(
            '${rating.toStringAsFixed(1)} ($totalReviews)',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
        horizontal: 12,
        vertical: 7,
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