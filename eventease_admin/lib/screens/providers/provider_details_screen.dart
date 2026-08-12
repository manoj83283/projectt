import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/provider_model.dart';
import '../../providers/provider_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dialogs/approve_dialog.dart';
import '../../widgets/dialogs/delete_dialog.dart';

class ProviderDetailsScreen extends StatefulWidget {
  const ProviderDetailsScreen({
    super.key,
  });

  @override
  State<ProviderDetailsScreen> createState() =>
      _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState
    extends State<ProviderDetailsScreen> {
  ProviderModel? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments =
        ModalRoute.of(context)?.settings.arguments;

    if (arguments is ProviderModel) {
      _provider = arguments;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadProviderDetails();
        },
      );
    }
  }

  // =====================================================
  // LOAD PROVIDER DETAILS
  // =====================================================

  Future<void> _loadProviderDetails() async {
    if (_provider == null) return;

    await context
        .read<ProviderProvider>()
        .getProviderDetails(
          _provider!.id,
        );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadProviderDetails();
  }

  // =====================================================
  // VIEW KYC
  // =====================================================

  void _viewKyc(
    ProviderModel provider,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.providerKyc,
      arguments: provider,
    );
  }

  // =====================================================
  // APPROVE PROVIDER
  // =====================================================

  Future<void> _approveProvider(
    ProviderModel provider,
  ) async {
    final confirmed =
        await ApproveProviderDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<ProviderProvider>()
            .approveProvider(
              provider.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider approved successfully',
      );

      await _refresh();
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // REJECT PROVIDER
  // =====================================================

  Future<void> _rejectProvider(
    ProviderModel provider,
  ) async {
    final reasonController =
        TextEditingController();

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Reject Provider',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter rejection reason for ${provider.displayName}.',
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
            .read<ProviderProvider>()
            .rejectProvider(
              providerId: provider.id,
              reason: reason,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider rejected successfully',
      );

      await _refresh();
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // BLOCK PROVIDER
  // =====================================================

  Future<void> _blockProvider(
    ProviderModel provider,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Block Provider',
          ),
          content: Text(
            'Are you sure you want to block ${provider.displayName}?',
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
                'Block',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<ProviderProvider>()
            .blockProvider(
              provider.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider blocked successfully',
      );

      await _refresh();
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // UNBLOCK PROVIDER
  // =====================================================

  Future<void> _unblockProvider(
    ProviderModel provider,
  ) async {
    final success =
        await context
            .read<ProviderProvider>()
            .unblockProvider(
              provider.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider unblocked successfully',
      );

      await _refresh();
    } else {
      _showProviderError();
    }
  }

  // =====================================================
  // DELETE PROVIDER
  // =====================================================

  Future<void> _deleteProvider(
    ProviderModel provider,
  ) async {
    final confirmed =
        await DeleteProviderDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<ProviderProvider>()
            .deleteProvider(
              provider.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Provider deleted successfully',
      );

      Navigator.pop(context);
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
            .read<ProviderProvider>()
            .errorMessage;

    NavigationService.showError(
      error ?? AppStrings.somethingWentWrong,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_provider == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Provider Details',
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
          'Provider Details',
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
        child: Consumer<ProviderProvider>(
          builder: (
            context,
            providerProvider,
            child,
          ) {
            if (providerProvider.isLoading) {
              return const FullScreenLoadingWidget(
                message:
                    'Loading provider details...',
              );
            }

            final provider =
                providerProvider.selectedProvider ??
                    _provider!;

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
                    if (providerProvider
                            .errorMessage !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: providerProvider
                              .errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    _buildProfileCard(
                      provider,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildOverviewGrid(
                      provider,
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
                              _buildBusinessInfoCard(
                                provider,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildPerformanceCard(
                                provider,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildKycCard(
                                provider,
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
                                  _buildBusinessInfoCard(
                                provider,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child:
                                  _buildPerformanceCard(
                                provider,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child:
                                  _buildKycCard(
                                provider,
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

                    _buildActionsCard(
                      provider,
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
  // PROFILE CARD
  // =====================================================

  Widget _buildProfileCard(
    ProviderModel provider,
  ) {
    final bool hasImage =
        provider.profileImage != null &&
            provider.profileImage!.isNotEmpty;

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
                constraints.maxWidth < 700;

            final profile = Row(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor:
                      AppColors.primary
                          .withValues(alpha: 0.10),
                  backgroundImage: hasImage
                      ? NetworkImage(
                          provider.profileImage!,
                        )
                      : null,
                  child: hasImage
                      ? null
                      : Text(
                          AppFormatters
                              .getInitials(
                            provider.displayName,
                          ),
                          style:
                              const TextStyle(
                            color:
                                AppColors.primary,
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.fullName.isNotEmpty
                            ? provider.fullName
                            : provider.displayName,
                        maxLines: 1,
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

                      const SizedBox(height: 6),

                      Text(
                        provider.email.isNotEmpty
                            ? provider.email
                            : '-',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        provider.phone.isNotEmpty
                            ? AppFormatters
                                .formatPhone(
                                provider.phone,
                              )
                            : '-',
                        style: const TextStyle(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusChip(
                            provider,
                          ),
                          _buildKycStatusChip(
                            provider,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );

            final action = CustomButton(
              text: 'View KYC',
              type: ButtonType.outline,
              icon:
                  Icons.verified_user_outlined,
              onPressed: () {
                _viewKyc(provider);
              },
            );

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  profile,
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: action,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: profile,
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 160,
                  child: action,
                ),
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
    ProviderModel provider,
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
              title: 'Bookings',
              value: AppFormatters
                  .formatNumber(
                provider.totalBookings,
              ),
              icon:
                  Icons.calendar_month_outlined,
              color: AppColors.primary,
            ),
            _StatCard(
              title: 'Earnings',
              value: AppFormatters
                  .formatCurrency(
                provider.totalEarnings,
              ),
              icon:
                  Icons.currency_rupee_outlined,
              color: AppColors.success,
            ),
            _StatCard(
              title: 'Services',
              value: AppFormatters
                  .formatNumber(
                provider.totalServices,
              ),
              icon: Icons
                  .miscellaneous_services_outlined,
              color: AppColors.info,
            ),
            _StatCard(
              title: 'Rating',
              value:
                  provider.rating.toStringAsFixed(
                1,
              ),
              icon: Icons.star_outline,
              color: AppColors.warning,
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // BUSINESS INFO
  // =====================================================

  Widget _buildBusinessInfoCard(
    ProviderModel provider,
  ) {
    return _DetailsCard(
      title: 'Business Information',
      icon: Icons.business_center_outlined,
      children: [
        _InfoRow(
          label: 'Provider ID',
          value: provider.id,
        ),
        _InfoRow(
          label: 'Business Name',
          value: provider.businessName.isNotEmpty
              ? provider.businessName
              : '-',
        ),
        _InfoRow(
          label: 'Category',
          value: provider.categoryName.isNotEmpty
              ? provider.categoryName
              : '-',
        ),
        _InfoRow(
          label: 'Email',
          value: provider.email.isNotEmpty
              ? provider.email
              : '-',
        ),
        _InfoRow(
          label: 'Phone',
          value: provider.phone.isNotEmpty
              ? AppFormatters.formatPhone(
                  provider.phone,
                )
              : '-',
        ),
        _InfoRow(
          label: 'Joined',
          value: AppFormatters.formatDate(
            provider.createdAt,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PERFORMANCE
  // =====================================================

  Widget _buildPerformanceCard(
    ProviderModel provider,
  ) {
    return _DetailsCard(
      title: 'Performance',
      icon: Icons.analytics_outlined,
      children: [
        _InfoRow(
          label: 'Total Bookings',
          value: AppFormatters.formatNumber(
            provider.totalBookings,
          ),
        ),
        _InfoRow(
          label: 'Total Earnings',
          value:
              AppFormatters.formatCurrency(
            provider.totalEarnings,
          ),
        ),
        _InfoRow(
          label: 'Rating',
          value:
              '${provider.rating.toStringAsFixed(1)} / 5',
        ),
        _InfoRow(
          label: 'Reviews',
          value: AppFormatters.formatNumber(
            provider.totalReviews,
          ),
        ),
        _InfoRow(
          label: 'Services',
          value: AppFormatters.formatNumber(
            provider.totalServices,
          ),
        ),
        _InfoRow(
          label: 'Account Status',
          value: provider.isBlocked
              ? 'Blocked'
              : provider.isActive
                  ? 'Active'
                  : 'Inactive',
        ),
      ],
    );
  }

  // =====================================================
  // KYC CARD
  // =====================================================

  Widget _buildKycCard(
    ProviderModel provider,
  ) {
    return _DetailsCard(
      title: 'KYC & Verification',
      icon: Icons.verified_user_outlined,
      action: TextButton(
        onPressed: () {
          _viewKyc(provider);
        },
        child: const Text(
          'View',
        ),
      ),
      children: [
        _InfoRow(
          label: 'KYC Status',
          value: provider.kycVerified
              ? 'Verified'
              : 'Pending',
        ),
        _InfoRow(
          label: 'Approval',
          value: provider.isApproved
              ? 'Approved'
              : provider.isRejected
                  ? 'Rejected'
                  : 'Pending',
        ),
        _InfoRow(
          label: 'Pending Review',
          value:
              provider.isPendingVerification
                  ? 'Yes'
                  : 'No',
        ),
        _InfoRow(
          label: 'Can Serve',
          value: provider.isApproved &&
                  provider.kycVerified &&
                  provider.isActive &&
                  !provider.isBlocked
              ? 'Yes'
              : 'No',
        ),
      ],
    );
  }

  // =====================================================
  // ACTIONS CARD
  // =====================================================

  Widget _buildActionsCard(
    ProviderModel provider,
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
                constraints.maxWidth < 800;

            final actions = [
              if (provider
                  .isPendingVerification)
                CustomButton(
                  text: 'Approve',
                  type: ButtonType.success,
                  icon: Icons.check_circle_outline,
                  onPressed: () {
                    _approveProvider(provider);
                  },
                ),
              if (provider
                  .isPendingVerification)
                CustomButton(
                  text: 'Reject',
                  type: ButtonType.danger,
                  icon: Icons.cancel_outlined,
                  onPressed: () {
                    _rejectProvider(provider);
                  },
                ),
              CustomButton(
                text: provider.isBlocked
                    ? 'Unblock'
                    : 'Block',
                type: provider.isBlocked
                    ? ButtonType.success
                    : ButtonType.warning,
                icon: provider.isBlocked
                    ? Icons.lock_open_outlined
                    : Icons.block_outlined,
                onPressed: () {
                  if (provider.isBlocked) {
                    _unblockProvider(provider);
                  } else {
                    _blockProvider(provider);
                  }
                },
              ),
              CustomButton(
                text: 'Delete',
                type: ButtonType.danger,
                icon: Icons.delete_outline,
                onPressed: () {
                  _deleteProvider(provider);
                },
              ),
            ];

            if (isMobile) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildActionsHeader(),
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
                _buildActionsHeader(),
                const SizedBox(height: 16),
                Row(
                  children: actions
                      .map(
                        (action) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets
                                    .only(
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

  Widget _buildActionsHeader() {
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
  // STATUS CHIP
  // =====================================================

  Widget _buildStatusChip(
    ProviderModel provider,
  ) {
    if (provider.isBlocked) {
      return const _StatusChip(
        label: 'Blocked',
        color: AppColors.error,
      );
    }

    if (!provider.isActive) {
      return const _StatusChip(
        label: 'Inactive',
        color: AppColors.warning,
      );
    }

    if (provider.isApproved) {
      return const _StatusChip(
        label: 'Approved',
        color: AppColors.success,
      );
    }

    if (provider.isRejected) {
      return const _StatusChip(
        label: 'Rejected',
        color: AppColors.error,
      );
    }

    return const _StatusChip(
      label: 'Pending',
      color: AppColors.warning,
    );
  }

  Widget _buildKycStatusChip(
    ProviderModel provider,
  ) {
    if (provider.kycVerified) {
      return const _StatusChip(
        label: 'KYC Verified',
        color: AppColors.success,
      );
    }

    return const _StatusChip(
      label: 'KYC Pending',
      color: AppColors.warning,
    );
  }
}

// =====================================================
// DETAILS CARD
// =====================================================

class _DetailsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? action;

  const _DetailsCard({
    required this.title,
    required this.icon,
    required this.children,
    this.action,
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

                ?action,
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
            width: 135,
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
                color: color.withValues(
                  alpha: 0.10,
                ),
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