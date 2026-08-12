import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/provider_model.dart';
import '../common/empty_widget.dart';
import '../common/loading_widget.dart';

class ProviderTable extends StatelessWidget {
  final List<ProviderModel> providers;

  final bool isLoading;

  final Function(ProviderModel provider)? onView;
  final Function(ProviderModel provider)? onEdit;
  final Function(ProviderModel provider)? onApprove;
  final Function(ProviderModel provider)? onReject;
  final Function(ProviderModel provider)? onBlock;
  final Function(ProviderModel provider)? onUnblock;
  final Function(ProviderModel provider)? onDelete;
  final Function(ProviderModel provider)? onViewKyc;

  final VoidCallback? onRefresh;

  const ProviderTable({
    super.key,
    required this.providers,
    this.isLoading = false,
    this.onView,
    this.onEdit,
    this.onApprove,
    this.onReject,
    this.onBlock,
    this.onUnblock,
    this.onDelete,
    this.onViewKyc,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading providers...',
      );
    }

    if (providers.isEmpty) {
      return NoProvidersWidget(
        onRefresh: onRefresh,
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
                  title: 'Provider',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Business',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Category',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Rating',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Bookings',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Earnings',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'KYC',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Status',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Joined',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Actions',
                ),
              ),
            ],
            rows: providers.map(
              (provider) {
                return DataRow(
                  cells: [
                    DataCell(
                      _ProviderInfoCell(
                        provider: provider,
                      ),
                    ),
                    DataCell(
                      _BusinessCell(
                        provider: provider,
                      ),
                    ),
                    DataCell(
                      Text(
                        provider.categoryName
                                .isNotEmpty
                            ? provider.categoryName
                            : '-',
                      ),
                    ),
                    DataCell(
                      _RatingCell(
                        provider: provider,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatNumber(
                          provider.totalBookings,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatCurrency(
                          provider.totalEarnings,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      _KycStatusBadge(
                        provider: provider,
                      ),
                    ),
                    DataCell(
                      _ProviderStatusBadge(
                        provider: provider,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatDate(
                          provider.createdAt,
                        ),
                      ),
                    ),
                    DataCell(
                      _ProviderActions(
                        provider: provider,
                        onView: onView,
                        onEdit: onEdit,
                        onApprove: onApprove,
                        onReject: onReject,
                        onBlock: onBlock,
                        onUnblock: onUnblock,
                        onDelete: onDelete,
                        onViewKyc: onViewKyc,
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
// PROVIDER INFO CELL
// =====================================================

class _ProviderInfoCell extends StatelessWidget {
  final ProviderModel provider;

  const _ProviderInfoCell({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        provider.profileImage != null &&
            provider.profileImage!.isNotEmpty;

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              AppColors.primary.withValues(alpha: 0.10),
          backgroundImage: hasImage
              ? NetworkImage(
                  provider.profileImage!,
                )
              : null,
          child: hasImage
              ? null
              : Text(
                  AppFormatters.getInitials(
                    provider.displayName,
                  ),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 180,
            maxWidth: 240,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                provider.fullName.isNotEmpty
                    ? provider.fullName
                    : provider.displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                provider.email.isNotEmpty
                    ? provider.email
                    : '-',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =====================================================
// BUSINESS CELL
// =====================================================

class _BusinessCell extends StatelessWidget {
  final ProviderModel provider;

  const _BusinessCell({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 180,
        maxWidth: 250,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            provider.businessName.isNotEmpty
                ? provider.businessName
                : '-',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.phone.isNotEmpty
                ? AppFormatters.formatPhone(
                    provider.phone,
                  )
                : '-',
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
  final ProviderModel provider;

  const _RatingCell({
    required this.provider,
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
          provider.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${provider.totalReviews})',
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
// KYC STATUS BADGE
// =====================================================

class _KycStatusBadge extends StatelessWidget {
  final ProviderModel provider;

  const _KycStatusBadge({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.kycVerified) {
      return const _StatusChip(
        label: 'Verified',
        color: AppColors.success,
      );
    }

    return const _StatusChip(
      label: 'Pending',
      color: AppColors.warning,
    );
  }
}

// =====================================================
// PROVIDER STATUS BADGE
// =====================================================

class _ProviderStatusBadge extends StatelessWidget {
  final ProviderModel provider;

  const _ProviderStatusBadge({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
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
}

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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(
          30,
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// =====================================================
// PROVIDER ACTIONS
// =====================================================

class _ProviderActions extends StatelessWidget {
  final ProviderModel provider;

  final Function(ProviderModel provider)? onView;
  final Function(ProviderModel provider)? onEdit;
  final Function(ProviderModel provider)? onApprove;
  final Function(ProviderModel provider)? onReject;
  final Function(ProviderModel provider)? onBlock;
  final Function(ProviderModel provider)? onUnblock;
  final Function(ProviderModel provider)? onDelete;
  final Function(ProviderModel provider)? onViewKyc;

  const _ProviderActions({
    required this.provider,
    this.onView,
    this.onEdit,
    this.onApprove,
    this.onReject,
    this.onBlock,
    this.onUnblock,
    this.onDelete,
    this.onViewKyc,
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
            onView?.call(provider);
            break;

          case 'edit':
            onEdit?.call(provider);
            break;

          case 'kyc':
            onViewKyc?.call(provider);
            break;

          case 'approve':
            onApprove?.call(provider);
            break;

          case 'reject':
            onReject?.call(provider);
            break;

          case 'block':
            onBlock?.call(provider);
            break;

          case 'unblock':
            onUnblock?.call(provider);
            break;

          case 'delete':
            onDelete?.call(provider);
            break;
        }
      },
      itemBuilder: (context) {
        return [
          if (onView != null)
            const PopupMenuItem(
              value: 'view',
              child: _MenuItem(
                icon: Icons.visibility_outlined,
                label: 'View',
              ),
            ),

          if (onEdit != null)
            const PopupMenuItem(
              value: 'edit',
              child: _MenuItem(
                icon: Icons.edit_outlined,
                label: 'Edit',
              ),
            ),

          if (onViewKyc != null)
            const PopupMenuItem(
              value: 'kyc',
              child: _MenuItem(
                icon: Icons.verified_user_outlined,
                label: 'View KYC',
                color: AppColors.primary,
              ),
            ),

          if (provider.isPendingVerification &&
              onApprove != null)
            const PopupMenuItem(
              value: 'approve',
              child: _MenuItem(
                icon: Icons.check_circle_outline,
                label: 'Approve',
                color: AppColors.success,
              ),
            ),

          if (provider.isPendingVerification &&
              onReject != null)
            const PopupMenuItem(
              value: 'reject',
              child: _MenuItem(
                icon: Icons.cancel_outlined,
                label: 'Reject',
                color: AppColors.error,
              ),
            ),

          if (!provider.isBlocked &&
              onBlock != null)
            const PopupMenuItem(
              value: 'block',
              child: _MenuItem(
                icon: Icons.block_outlined,
                label: 'Block',
                color: AppColors.warning,
              ),
            ),

          if (provider.isBlocked &&
              onUnblock != null)
            const PopupMenuItem(
              value: 'unblock',
              child: _MenuItem(
                icon: Icons.lock_open_outlined,
                label: 'Unblock',
                color: AppColors.success,
              ),
            ),

          if (onDelete != null)
            const PopupMenuDivider(),

          if (onDelete != null)
            const PopupMenuItem(
              value: 'delete',
              child: _MenuItem(
                icon: Icons.delete_outline,
                label: 'Delete',
                color: AppColors.error,
              ),
            ),
        ];
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