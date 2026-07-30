import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dialogs/delete_dialog.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({
    super.key,
  });

  @override
  State<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState
    extends State<BookingDetailsScreen> {
  BookingModel? _booking;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is BookingModel) {
      _booking = args;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadBookingDetails();
        },
      );
    } else if (args is Map<String, dynamic>) {
      final bookingArg = args['booking'];

      if (bookingArg is BookingModel) {
        _booking = bookingArg;
      }

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadBookingDetails();
        },
      );
    }

    _initialized = true;
  }

  // =====================================================
  // LOAD BOOKING DETAILS
  // =====================================================

  Future<void> _loadBookingDetails() async {
    if (_booking == null) return;

    await context
        .read<BookingProvider>()
        .getBookingDetails(
          _booking!.id,
        );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadBookingDetails();
  }

  // =====================================================
  // CONFIRM BOOKING
  // =====================================================

  Future<void> _confirmBooking(
    BookingModel booking,
  ) async {
    final success =
        await context
            .read<BookingProvider>()
            .confirmBooking(
              booking.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Booking confirmed successfully',
      );

      await _refresh();
    } else {
      _showBookingError();
    }
  }

  // =====================================================
  // COMPLETE BOOKING
  // =====================================================

  Future<void> _completeBooking(
    BookingModel booking,
  ) async {
    final success =
        await context
            .read<BookingProvider>()
            .completeBooking(
              booking.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Booking completed successfully',
      );

      await _refresh();
    } else {
      _showBookingError();
    }
  }

  // =====================================================
  // CANCEL BOOKING
  // =====================================================

  Future<void> _cancelBooking(
    BookingModel booking,
  ) async {
    final reasonController =
        TextEditingController();

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Cancel Booking',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Please enter cancellation reason.',
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    reasonController,
                maxLines: 4,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Cancellation reason',
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
                'Cancel Booking',
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
        'Cancellation reason is required',
      );
      return;
    }

    final success =
        await context
            .read<BookingProvider>()
            .cancelBooking(
              bookingId: booking.id,
              reason: reason,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Booking cancelled successfully',
      );

      await _refresh();
    } else {
      _showBookingError();
    }
  }

  // =====================================================
  // UPDATE PAYMENT STATUS
  // =====================================================

  Future<void> _updatePaymentStatus(
    BookingModel booking,
  ) async {
    final paymentStatus =
        await showDialog<String>(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: const Text(
            'Update Payment Status',
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  'paid',
                );
              },
              child: const Text('Paid'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  'pending',
                );
              },
              child: const Text('Pending'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  'failed',
                );
              },
              child: const Text('Failed'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  'refunded',
                );
              },
              child: const Text('Refunded'),
            ),
          ],
        );
      },
    );

    if (paymentStatus == null) return;

    final success =
        await context
            .read<BookingProvider>()
            .updatePaymentStatus(
              bookingId: booking.id,
              paymentStatus: paymentStatus,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Payment status updated successfully',
      );

      await _refresh();
    } else {
      _showBookingError();
    }
  }

  // =====================================================
  // DELETE BOOKING
  // =====================================================

  Future<void> _deleteBooking(
    BookingModel booking,
  ) async {
    final confirmed =
        await DeleteBookingDialog.show(
      context: context,
    );

    if (confirmed != true) return;

    final success =
        await context
            .read<BookingProvider>()
            .deleteBooking(
              booking.id,
            );

    if (!mounted) return;

    if (success) {
      NavigationService.showSuccess(
        'Booking deleted successfully',
      );

      Navigator.pop(
        context,
        true,
      );
    } else {
      _showBookingError();
    }
  }

  // =====================================================
  // ERROR
  // =====================================================

  void _showBookingError() {
    final error =
        context
            .read<BookingProvider>()
            .errorMessage;

    NavigationService.showError(
      error ?? AppStrings.somethingWentWrong,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Booking Details',
          ),
        ),
        body: const Center(
          child: Text(
            'Booking data not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Booking Details',
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
        child: Consumer<BookingProvider>(
          builder: (
            context,
            bookingProvider,
            child,
          ) {
            if (bookingProvider.isLoading) {
              return const FullScreenLoadingWidget(
                message:
                    'Loading booking details...',
              );
            }

            final booking =
                bookingProvider.selectedBooking ??
                    _booking!;

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
                    if (bookingProvider
                            .errorMessage !=
                        null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom:
                              AppDimensions.padding16,
                        ),
                        child: ErrorCard(
                          message: bookingProvider
                              .errorMessage!,
                          onRetry: _refresh,
                        ),
                      ),

                    _buildHeroCard(
                      booking,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildOverviewGrid(
                      booking,
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
                              _buildCustomerCard(
                                booking,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildProviderCard(
                                booking,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildServiceCard(
                                booking,
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
                                  _buildCustomerCard(
                                booking,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child:
                                  _buildProviderCard(
                                booking,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child:
                                  _buildServiceCard(
                                booking,
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
                              _buildBookingInfoCard(
                                booking,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              _buildPaymentInfoCard(
                                booking,
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
                                  _buildBookingInfoCard(
                                booking,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child:
                                  _buildPaymentInfoCard(
                                booking,
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

                    _buildAddressCard(
                      booking,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildActionsCard(
                      booking,
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
    BookingModel booking,
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
          AppDimensions.padding24,
        ),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final bool isMobile =
                constraints.maxWidth < 760;

            final iconBox = Container(
              height: isMobile ? 96 : 112,
              width: isMobile ? 96 : 112,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withOpacity(0.10),
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radius20,
                ),
              ),
              child: const Icon(
                Icons.event_available_outlined,
                color: AppColors.primary,
                size: 48,
              ),
            );

            final content = Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.bookingNumber
                            .isNotEmpty
                        ? booking.bookingNumber
                        : booking.id,
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

                  const SizedBox(height: 8),

                  Text(
                    booking.serviceName
                            .isNotEmpty
                        ? booking.serviceName
                        : 'Service Booking',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBookingStatusChip(
                        booking,
                      ),
                      _buildPaymentStatusChip(
                        booking,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _MiniInfoBox(
                        title: 'Amount',
                        value: AppFormatters
                            .formatCurrency(
                          booking.totalAmount,
                        ),
                        icon:
                            Icons.currency_rupee_rounded,
                        color: AppColors.success,
                      ),
                      _MiniInfoBox(
                        title: 'Booking Date',
                        value: AppFormatters
                            .formatDate(
                          booking.bookingDate,
                        ),
                        icon:
                            Icons.calendar_today_outlined,
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
                  iconBox,
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
                iconBox,
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
    BookingModel booking,
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
              title: 'Total Amount',
              value: AppFormatters
                  .formatCurrency(
                booking.totalAmount,
              ),
              icon:
                  Icons.currency_rupee_rounded,
              color: AppColors.success,
            ),
            _StatCard(
              title: 'Discount',
              value: AppFormatters
                  .formatCurrency(
                booking.discount,
              ),
              icon:
                  Icons.local_offer_outlined,
              color: AppColors.warning,
            ),
            _StatCard(
              title: 'Tax',
              value: AppFormatters
                  .formatCurrency(
                booking.tax,
              ),
              icon:
                  Icons.receipt_long_outlined,
              color: AppColors.info,
            ),
            _StatCard(
              title: 'Payment',
              value: AppFormatters
                  .formatStatus(
                booking.paymentStatus,
              ),
              icon:
                  Icons.payments_outlined,
              color: _paymentStatusColor(
                booking.paymentStatus,
              ),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // CUSTOMER CARD
  // =====================================================

  Widget _buildCustomerCard(
    BookingModel booking,
  ) {
    return _DetailsCard(
      title: 'Customer Information',
      icon: Icons.person_outline,
      children: [
        _InfoRow(
          label: 'Customer Name',
          value: booking.customerName
                  .isNotEmpty
              ? booking.customerName
              : '-',
        ),
        _InfoRow(
          label: 'Phone',
          value: booking.customerPhone
                  .isNotEmpty
              ? AppFormatters.formatPhone(
                  booking.customerPhone,
                )
              : '-',
        ),
      ],
    );
  }

  // =====================================================
  // PROVIDER CARD
  // =====================================================

  Widget _buildProviderCard(
    BookingModel booking,
  ) {
    return _DetailsCard(
      title: 'Provider Information',
      icon: Icons.business_center_outlined,
      children: [
        _InfoRow(
          label: 'Provider',
          value: booking.providerName
                  .isNotEmpty
              ? booking.providerName
              : '-',
        ),
        _InfoRow(
          label: 'Assigned',
          value: booking.providerName
                  .isNotEmpty
              ? 'Yes'
              : 'No',
        ),
      ],
    );
  }

  // =====================================================
  // SERVICE CARD
  // =====================================================

  Widget _buildServiceCard(
    BookingModel booking,
  ) {
    return _DetailsCard(
      title: 'Service Information',
      icon: Icons.miscellaneous_services_outlined,
      children: [
        _InfoRow(
          label: 'Service',
          value: booking.serviceName
                  .isNotEmpty
              ? booking.serviceName
              : '-',
        ),
        _InfoRow(
          label: 'Service Address',
          value: booking.eventAddress
                  .isNotEmpty
              ? booking.eventAddress
              : '-',
        ),
      ],
    );
  }

  // =====================================================
  // BOOKING INFO CARD
  // =====================================================

  Widget _buildBookingInfoCard(
    BookingModel booking,
  ) {
    return _DetailsCard(
      title: 'Booking Information',
      icon: Icons.event_note_outlined,
      children: [
        _InfoRow(
          label: 'Booking ID',
          value: booking.id,
        ),
        _InfoRow(
          label: 'Booking No.',
          value: booking.bookingNumber
                  .isNotEmpty
              ? booking.bookingNumber
              : '-',
        ),
        _InfoRow(
          label: 'Booking Date',
          value: AppFormatters.formatDate(
            booking.bookingDate,
          ),
        ),
        _InfoRow(
          label: 'Booking Time',
          value: booking.bookingTime
                  .isNotEmpty
              ? booking.bookingTime
              : '-',
        ),
        _InfoRow(
          label: 'Created At',
          value: AppFormatters.formatDate(
            booking.createdAt,
          ),
        ),
        _InfoRow(
          label: 'Status',
          value: _bookingStatusText(
            booking,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // PAYMENT INFO CARD
  // =====================================================

  Widget _buildPaymentInfoCard(
    BookingModel booking,
  ) {
    return _DetailsCard(
      title: 'Payment Information',
      icon: Icons.payments_outlined,
      action: TextButton(
        onPressed: () {
          _updatePaymentStatus(
            booking,
          );
        },
        child: const Text(
          'Update',
        ),
      ),
      children: [
        _InfoRow(
          label: 'Payment Status',
          value: booking.paymentStatus
                  .isNotEmpty
              ? AppFormatters.formatStatus(
                  booking.paymentStatus,
                )
              : '-',
        ),
        _InfoRow(
          label: 'Subtotal',
          value: AppFormatters
              .formatCurrency(
            booking.totalAmount -
                booking.tax +
                booking.discount,
          ),
        ),
        _InfoRow(
          label: 'Discount',
          value: AppFormatters
              .formatCurrency(
            booking.discount,
          ),
        ),
        _InfoRow(
          label: 'Tax',
          value: AppFormatters
              .formatCurrency(
            booking.tax,
          ),
        ),
        _InfoRow(
          label: 'Total Amount',
          value: AppFormatters
              .formatCurrency(
            booking.totalAmount,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // ADDRESS CARD
  // =====================================================

  Widget _buildAddressCard(
    BookingModel booking,
  ) {
    return _DetailsCard(
      title: 'Event Address',
      icon: Icons.location_on_outlined,
      children: [
        Text(
          booking.eventAddress.isNotEmpty
              ? booking.eventAddress
              : 'No event address available.',
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
    BookingModel booking,
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
              if (booking.isPending)
                CustomButton(
                  text: 'Confirm',
                  type: ButtonType.success,
                  icon:
                      Icons.check_circle_outline,
                  onPressed: () {
                    _confirmBooking(
                      booking,
                    );
                  },
                ),
              if (booking.isConfirmed)
                CustomButton(
                  text: 'Complete',
                  type: ButtonType.success,
                  icon:
                      Icons.done_all_outlined,
                  onPressed: () {
                    _completeBooking(
                      booking,
                    );
                  },
                ),
              if (!booking.isCancelled &&
                  !booking.isCompleted)
                CustomButton(
                  text: 'Cancel',
                  type: ButtonType.danger,
                  icon: Icons.cancel_outlined,
                  onPressed: () {
                    _cancelBooking(
                      booking,
                    );
                  },
                ),
              CustomButton(
                text: 'Payment',
                type: ButtonType.outline,
                icon: Icons.payments_outlined,
                onPressed: () {
                  _updatePaymentStatus(
                    booking,
                  );
                },
              ),
              CustomButton(
                text: 'Delete',
                type: ButtonType.danger,
                icon: Icons.delete_outline,
                onPressed: () {
                  _deleteBooking(
                    booking,
                  );
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

  Widget _buildBookingStatusChip(
    BookingModel booking,
  ) {
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

  Widget _buildPaymentStatusChip(
    BookingModel booking,
  ) {
    return _StatusChip(
      label: booking.paymentStatus.isNotEmpty
          ? AppFormatters.formatStatus(
              booking.paymentStatus,
            )
          : 'Pending',
      color: _paymentStatusColor(
        booking.paymentStatus,
      ),
    );
  }

  String _bookingStatusText(
    BookingModel booking,
  ) {
    if (booking.isCompleted) {
      return 'Completed';
    }

    if (booking.isCancelled) {
      return 'Cancelled';
    }

    if (booking.isConfirmed) {
      return 'Confirmed';
    }

    return 'Pending';
  }

  Color _paymentStatusColor(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'success':
        return AppColors.paymentPaid;

      case 'failed':
        return AppColors.paymentFailed;

      case 'refunded':
        return AppColors.paymentRefunded;

      case 'pending':
      default:
        return AppColors.paymentPending;
    }
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

                if (action != null) action!,
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