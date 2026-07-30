import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/customer_model.dart';
import '../common/empty_widget.dart';
import '../common/loading_widget.dart';

class CustomerTable extends StatelessWidget {
  final List<CustomerModel> customers;

  final bool isLoading;

  final Function(CustomerModel customer)? onView;
  final Function(CustomerModel customer)? onEdit;
  final Function(CustomerModel customer)? onBlock;
  final Function(CustomerModel customer)? onUnblock;
  final Function(CustomerModel customer)? onDelete;

  final VoidCallback? onRefresh;

  const CustomerTable({
    super.key,
    required this.customers,
    this.isLoading = false,
    this.onView,
    this.onEdit,
    this.onBlock,
    this.onUnblock,
    this.onDelete,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading customers...',
      );
    }

    if (customers.isEmpty) {
      return NoCustomersWidget(
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
                  title: 'Customer',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Contact',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Bookings',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Orders',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Total Spent',
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
            rows: customers.map(
              (customer) {
                return DataRow(
                  cells: [
                    DataCell(
                      _CustomerInfoCell(
                        customer: customer,
                      ),
                    ),
                    DataCell(
                      _ContactCell(
                        customer: customer,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatNumber(
                          customer.totalBookings,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatNumber(
                          customer.totalOrders,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatCurrency(
                          customer.totalSpent,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      _CustomerStatusBadge(
                        customer: customer,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatDate(
                          customer.createdAt,
                        ),
                      ),
                    ),
                    DataCell(
                      _CustomerActions(
                        customer: customer,
                        onView: onView,
                        onEdit: onEdit,
                        onBlock: onBlock,
                        onUnblock: onUnblock,
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
// CUSTOMER INFO CELL
// =====================================================

class _CustomerInfoCell extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerInfoCell({
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor:
              AppColors.primary.withOpacity(0.10),
          backgroundImage:
              customer.hasProfileImage
                  ? NetworkImage(
                      customer.profileImage!,
                    )
                  : null,
          child: customer.hasProfileImage
              ? null
              : Text(
                  AppFormatters.getInitials(
                    customer.displayName,
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
            minWidth: 170,
            maxWidth: 220,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                customer.displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                customer.id,
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
// CONTACT CELL
// =====================================================

class _ContactCell extends StatelessWidget {
  final CustomerModel customer;

  const _ContactCell({
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
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
            customer.email.isNotEmpty
                ? customer.email
                : '-',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            customer.phone.isNotEmpty
                ? AppFormatters.formatPhone(
                    customer.phone,
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
// STATUS BADGE
// =====================================================

class _CustomerStatusBadge extends StatelessWidget {
  final CustomerModel customer;

  const _CustomerStatusBadge({
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    if (customer.isBlocked) {
      return const _StatusChip(
        label: 'Blocked',
        color: AppColors.error,
      );
    }

    if (!customer.isActive) {
      return const _StatusChip(
        label: 'Inactive',
        color: AppColors.warning,
      );
    }

    if (customer.isVerified) {
      return const _StatusChip(
        label: 'Verified',
        color: AppColors.success,
      );
    }

    return const _StatusChip(
      label: 'Active',
      color: AppColors.primary,
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
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(
          30,
        ),
        border: Border.all(
          color: color.withOpacity(0.25),
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
// ACTIONS
// =====================================================

class _CustomerActions extends StatelessWidget {
  final CustomerModel customer;

  final Function(CustomerModel customer)? onView;
  final Function(CustomerModel customer)? onEdit;
  final Function(CustomerModel customer)? onBlock;
  final Function(CustomerModel customer)? onUnblock;
  final Function(CustomerModel customer)? onDelete;

  const _CustomerActions({
    required this.customer,
    this.onView,
    this.onEdit,
    this.onBlock,
    this.onUnblock,
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
            onView?.call(customer);
            break;

          case 'edit':
            onEdit?.call(customer);
            break;

          case 'block':
            onBlock?.call(customer);
            break;

          case 'unblock':
            onUnblock?.call(customer);
            break;

          case 'delete':
            onDelete?.call(customer);
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

          if (!customer.isBlocked &&
              onBlock != null)
            const PopupMenuItem(
              value: 'block',
              child: _MenuItem(
                icon: Icons.block_outlined,
                label: 'Block',
                color: AppColors.warning,
              ),
            ),

          if (customer.isBlocked &&
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