import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../common/empty_widget.dart';
import '../common/loading_widget.dart';

class OrderTable extends StatelessWidget {
  final List<OrderModel> orders;

  final bool isLoading;

  final Function(OrderModel order)? onView;
  final Function(OrderModel order)? onProcess;
  final Function(OrderModel order)? onShip;
  final Function(OrderModel order)? onDeliver;
  final Function(OrderModel order)? onCancel;
  final Function(OrderModel order)? onUpdatePayment;
  final Function(OrderModel order)? onDelete;

  final VoidCallback? onRefresh;

  const OrderTable({
    super.key,
    required this.orders,
    this.isLoading = false,
    this.onView,
    this.onProcess,
    this.onShip,
    this.onDeliver,
    this.onCancel,
    this.onUpdatePayment,
    this.onDelete,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading orders...',
      );
    }

    if (orders.isEmpty) {
      return NoOrdersWidget(
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
                  title: 'Order',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Customer',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Provider',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Items',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Amount',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Payment',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Status',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Delivery',
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
            rows: orders.map(
              (order) {
                return DataRow(
                  cells: [
                    DataCell(
                      _OrderInfoCell(
                        order: order,
                      ),
                    ),
                    DataCell(
                      _CustomerCell(
                        order: order,
                      ),
                    ),
                    DataCell(
                      _ProviderCell(
                        order: order,
                      ),
                    ),
                    DataCell(
                      _ItemsCell(
                        order: order,
                      ),
                    ),
                    DataCell(
                      _AmountCell(
                        order: order,
                      ),
                    ),
                    DataCell(
                      _PaymentStatusBadge(
                        order: order,
                      ),
                    ),
                    DataCell(
                      _OrderStatusBadge(
                        order: order,
                      ),
                    ),
                    DataCell(
                      _DeliveryCell(
                        order: order,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatDate(
                          order.createdAt,
                        ),
                      ),
                    ),
                    DataCell(
                      _OrderActions(
                        order: order,
                        onView: onView,
                        onProcess: onProcess,
                        onShip: onShip,
                        onDeliver: onDeliver,
                        onCancel: onCancel,
                        onUpdatePayment:
                            onUpdatePayment,
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
// ORDER INFO CELL
// =====================================================

class _OrderInfoCell extends StatelessWidget {
  final OrderModel order;

  const _OrderInfoCell({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 220,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            order.orderNumber.isNotEmpty
                ? order.orderNumber
                : order.id,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.id,
            overflow: TextOverflow.ellipsis,
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
// CUSTOMER CELL
// =====================================================

class _CustomerCell extends StatelessWidget {
  final OrderModel order;

  const _CustomerCell({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 190,
        maxWidth: 250,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
                AppColors.primary.withValues(alpha: 0.10),
            child: Text(
              AppFormatters.getInitials(
                order.customerName,
              ),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName.isNotEmpty
                      ? order.customerName
                      : '-',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerPhone.isNotEmpty
                      ? AppFormatters.formatPhone(
                          order.customerPhone,
                        )
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
      ),
    );
  }
}

// =====================================================
// PROVIDER CELL
// =====================================================

class _ProviderCell extends StatelessWidget {
  final OrderModel order;

  const _ProviderCell({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 220,
      ),
      child: Text(
        order.providerName.isNotEmpty
            ? order.providerName
            : '-',
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// =====================================================
// ITEMS CELL
// =====================================================

class _ItemsCell extends StatelessWidget {
  final OrderModel order;

  const _ItemsCell({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty
        ? order.items.first.productName
        : '-';

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 180,
        maxWidth: 260,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            firstItem,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${order.totalItems} item(s)',
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
// AMOUNT CELL
// =====================================================

class _AmountCell extends StatelessWidget {
  final OrderModel order;

  const _AmountCell({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 130,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            AppFormatters.formatCurrency(
              order.totalAmount,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          if (order.discountAmount > 0)
            Text(
              'Discount ${AppFormatters.formatCurrency(order.discountAmount)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.success,
              ),
            )
          else
            Text(
              'Delivery ${AppFormatters.formatCurrency(order.deliveryCharge)}',
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
// DELIVERY CELL
// =====================================================

class _DeliveryCell extends StatelessWidget {
  final OrderModel order;

  const _DeliveryCell({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 220,
        maxWidth: 300,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            order.deliveryAddress.isNotEmpty
                ? order.deliveryAddress
                : '-',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              order.city,
              order.state,
              order.pincode,
            ]
                .where(
                  (e) =>
                      e != null &&
                      e.toString().isNotEmpty,
                )
                .join(', ')
                .ifEmpty('-'),
            overflow: TextOverflow.ellipsis,
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
// ORDER STATUS BADGE
// =====================================================

class _OrderStatusBadge extends StatelessWidget {
  final OrderModel order;

  const _OrderStatusBadge({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        order.orderStatus.toLowerCase();

    if (status == 'delivered') {
      return const _StatusChip(
        label: 'Delivered',
        color: AppColors.orderDelivered,
      );
    }

    if (status == 'cancelled') {
      return const _StatusChip(
        label: 'Cancelled',
        color: AppColors.orderCancelled,
      );
    }

    if (status == 'shipped') {
      return const _StatusChip(
        label: 'Shipped',
        color: AppColors.orderShipped,
      );
    }

    if (status == 'processing') {
      return const _StatusChip(
        label: 'Processing',
        color: AppColors.orderProcessing,
      );
    }

    return const _StatusChip(
      label: 'Placed',
      color: AppColors.orderPlaced,
    );
  }
}

// =====================================================
// PAYMENT STATUS BADGE
// =====================================================

class _PaymentStatusBadge extends StatelessWidget {
  final OrderModel order;

  const _PaymentStatusBadge({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        order.paymentStatus.toLowerCase();

    if (status == 'paid' ||
        status == 'success') {
      return const _StatusChip(
        label: 'Paid',
        color: AppColors.paymentPaid,
      );
    }

    if (status == 'failed') {
      return const _StatusChip(
        label: 'Failed',
        color: AppColors.paymentFailed,
      );
    }

    if (status == 'refunded') {
      return const _StatusChip(
        label: 'Refunded',
        color: AppColors.paymentRefunded,
      );
    }

    return const _StatusChip(
      label: 'Pending',
      color: AppColors.paymentPending,
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
// ACTIONS
// =====================================================

class _OrderActions extends StatelessWidget {
  final OrderModel order;

  final Function(OrderModel order)? onView;
  final Function(OrderModel order)? onProcess;
  final Function(OrderModel order)? onShip;
  final Function(OrderModel order)? onDeliver;
  final Function(OrderModel order)? onCancel;
  final Function(OrderModel order)? onUpdatePayment;
  final Function(OrderModel order)? onDelete;

  const _OrderActions({
    required this.order,
    this.onView,
    this.onProcess,
    this.onShip,
    this.onDeliver,
    this.onCancel,
    this.onUpdatePayment,
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
            onView?.call(order);
            break;

          case 'process':
            onProcess?.call(order);
            break;

          case 'ship':
            onShip?.call(order);
            break;

          case 'deliver':
            onDeliver?.call(order);
            break;

          case 'cancel':
            onCancel?.call(order);
            break;

          case 'payment':
            onUpdatePayment?.call(order);
            break;

          case 'delete':
            onDelete?.call(order);
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

        if (order.isPending &&
            onProcess != null) {
          items.add(
            const PopupMenuItem(
              value: 'process',
              child: _MenuItem(
                icon: Icons.sync_outlined,
                label: 'Process',
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (order.isProcessing &&
            onShip != null) {
          items.add(
            const PopupMenuItem(
              value: 'ship',
              child: _MenuItem(
                icon:
                    Icons.local_shipping_outlined,
                label: 'Ship',
                color: AppColors.secondary,
              ),
            ),
          );
        }

        if (!order.isDelivered &&
            !order.isCancelled &&
            onDeliver != null) {
          items.add(
            const PopupMenuItem(
              value: 'deliver',
              child: _MenuItem(
                icon:
                    Icons.done_all_outlined,
                label: 'Deliver',
                color: AppColors.success,
              ),
            ),
          );
        }

        if (!order.isDelivered &&
            !order.isCancelled &&
            onCancel != null) {
          items.add(
            const PopupMenuItem(
              value: 'cancel',
              child: _MenuItem(
                icon: Icons.cancel_outlined,
                label: 'Cancel',
                color: AppColors.error,
              ),
            ),
          );
        }

        if (onUpdatePayment != null) {
          items.add(
            const PopupMenuItem(
              value: 'payment',
              child: _MenuItem(
                icon: Icons.payments_outlined,
                label: 'Payment',
                color: AppColors.primary,
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
// STRING EXTENSION
// =====================================================

extension _StringListExtension on String {
  String ifEmpty(
    String fallback,
  ) {
    return isEmpty ? fallback : this;
  }
}