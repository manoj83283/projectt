import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/formatters.dart';
import '../../models/booking_model.dart';
import '../common/empty_widget.dart';
import '../common/loading_widget.dart';

class BookingTable extends StatelessWidget {
  final List<BookingModel> bookings;

  final bool isLoading;

  final Function(BookingModel booking)? onView;
  final Function(BookingModel booking)? onConfirm;
  final Function(BookingModel booking)? onComplete;
  final Function(BookingModel booking)? onCancel;
  final Function(BookingModel booking)? onUpdatePayment;
  final Function(BookingModel booking)? onDelete;

  final VoidCallback? onRefresh;

  const BookingTable({
    super.key,
    required this.bookings,
    this.isLoading = false,
    this.onView,
    this.onConfirm,
    this.onComplete,
    this.onCancel,
    this.onUpdatePayment,
    this.onDelete,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const TableLoadingWidget(
        message: 'Loading bookings...',
      );
    }

    if (bookings.isEmpty) {
      return NoBookingsWidget(
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
                  title: 'Booking',
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
                  title: 'Service',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Date & Time',
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
                  title: 'Created',
                ),
              ),
              DataColumn(
                label: _TableHeader(
                  title: 'Actions',
                ),
              ),
            ],
            rows: bookings.map(
              (booking) {
                return DataRow(
                  cells: [
                    DataCell(
                      _BookingInfoCell(
                        booking: booking,
                      ),
                    ),
                    DataCell(
                      _CustomerCell(
                        booking: booking,
                      ),
                    ),
                    DataCell(
                      _ProviderCell(
                        booking: booking,
                      ),
                    ),
                    DataCell(
                      _ServiceCell(
                        booking: booking,
                      ),
                    ),
                    DataCell(
                      _DateTimeCell(
                        booking: booking,
                      ),
                    ),
                    DataCell(
                      _AmountCell(
                        booking: booking,
                      ),
                    ),
                    DataCell(
                      _PaymentStatusBadge(
                        booking: booking,
                      ),
                    ),
                    DataCell(
                      _BookingStatusBadge(
                        booking: booking,
                      ),
                    ),
                    DataCell(
                      Text(
                        AppFormatters.formatDate(
                          booking.createdAt,
                        ),
                      ),
                    ),
                    DataCell(
                      _BookingActions(
                        booking: booking,
                        onView: onView,
                        onConfirm: onConfirm,
                        onComplete: onComplete,
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
// BOOKING INFO CELL
// =====================================================

class _BookingInfoCell extends StatelessWidget {
  final BookingModel booking;

  const _BookingInfoCell({
    required this.booking,
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
            booking.bookingNumber.isNotEmpty
                ? booking.bookingNumber
                : booking.id,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.id,
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
  final BookingModel booking;

  const _CustomerCell({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 180,
        maxWidth: 240,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
                AppColors.primary.withValues(alpha: 0.10),
            child: Text(
              AppFormatters.getInitials(
                booking.customerName,
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
                  booking.customerName.isNotEmpty
                      ? booking.customerName
                      : '-',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.customerPhone.isNotEmpty
                      ? AppFormatters.formatPhone(
                          booking.customerPhone,
                        )
                      : '-',
                  overflow: TextOverflow.ellipsis,
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
  final BookingModel booking;

  const _ProviderCell({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 160,
        maxWidth: 220,
      ),
      child: Text(
        booking.providerName.isNotEmpty
            ? booking.providerName
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
// SERVICE CELL
// =====================================================

class _ServiceCell extends StatelessWidget {
  final BookingModel booking;

  const _ServiceCell({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
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
            booking.serviceName.isNotEmpty
                ? booking.serviceName
                : '-',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.eventAddress.isNotEmpty
                ? booking.eventAddress
                : '-',
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
// DATE TIME CELL
// =====================================================

class _DateTimeCell extends StatelessWidget {
  final BookingModel booking;

  const _DateTimeCell({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 140,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            AppFormatters.formatDate(
              booking.bookingDate,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.bookingTime.isNotEmpty
                ? booking.bookingTime
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
// AMOUNT CELL
// =====================================================

class _AmountCell extends StatelessWidget {
  final BookingModel booking;

  const _AmountCell({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 120,
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            AppFormatters.formatCurrency(
              booking.totalAmount,
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          if (booking.discount > 0)
            Text(
              'Discount ${AppFormatters.formatCurrency(booking.discount)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.success,
              ),
            )
          else
            Text(
              'Tax ${AppFormatters.formatCurrency(booking.tax)}',
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
// BOOKING STATUS BADGE
// =====================================================

class _BookingStatusBadge extends StatelessWidget {
  final BookingModel booking;

  const _BookingStatusBadge({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    if (booking.isCompleted) {
      return const _StatusChip(
        label: 'Completed',
        color: AppColors.bookingCompleted,
      );
    }

    if (booking.isCancelled) {
      return const _StatusChip(
        label: 'Cancelled',
        color: AppColors.bookingCancelled,
      );
    }

    if (booking.isConfirmed) {
      return const _StatusChip(
        label: 'Confirmed',
        color: AppColors.bookingConfirmed,
      );
    }

    return const _StatusChip(
      label: 'Pending',
      color: AppColors.bookingPending,
    );
  }
}

// =====================================================
// PAYMENT STATUS BADGE
// =====================================================

class _PaymentStatusBadge extends StatelessWidget {
  final BookingModel booking;

  const _PaymentStatusBadge({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        booking.paymentStatus.toLowerCase();

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

class _BookingActions extends StatelessWidget {
  final BookingModel booking;

  final Function(BookingModel booking)? onView;
  final Function(BookingModel booking)? onConfirm;
  final Function(BookingModel booking)? onComplete;
  final Function(BookingModel booking)? onCancel;
  final Function(BookingModel booking)? onUpdatePayment;
  final Function(BookingModel booking)? onDelete;

  const _BookingActions({
    required this.booking,
    this.onView,
    this.onConfirm,
    this.onComplete,
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
            onView?.call(booking);
            break;

          case 'confirm':
            onConfirm?.call(booking);
            break;

          case 'complete':
            onComplete?.call(booking);
            break;

          case 'cancel':
            onCancel?.call(booking);
            break;

          case 'payment':
            onUpdatePayment?.call(booking);
            break;

          case 'delete':
            onDelete?.call(booking);
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

        if (booking.isPending &&
            onConfirm != null) {
          items.add(
            const PopupMenuItem(
              value: 'confirm',
              child: _MenuItem(
                icon:
                    Icons.check_circle_outline,
                label: 'Confirm',
                color: AppColors.success,
              ),
            ),
          );
        }

        if (booking.isConfirmed &&
            onComplete != null) {
          items.add(
            const PopupMenuItem(
              value: 'complete',
              child: _MenuItem(
                icon:
                    Icons.done_all_outlined,
                label: 'Complete',
                color: AppColors.success,
              ),
            ),
          );
        }

        if (!booking.isCancelled &&
            !booking.isCompleted &&
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