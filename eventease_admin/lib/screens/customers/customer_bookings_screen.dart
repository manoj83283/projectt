import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../models/booking_model.dart';
import '../../models/customer_model.dart';
import '../../providers/booking_provider.dart';
import '../../routes/app_routes.dart';
import '../../routes/navigation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_dropdown.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/pagination_widget.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/dialogs/delete_dialog.dart';
import '../../widgets/tables/booking_table.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({
    super.key,
  });

  @override
  State<CustomerBookingsScreen> createState() =>
      _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState
    extends State<CustomerBookingsScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  CustomerModel? _customer;

  String? _selectedStatus;

  int _page = 1;
  final int _limit = 20;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is CustomerModel) {
      _customer = args;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadBookings();
        },
      );
    } else if (args is Map<String, dynamic>) {
      final customerArg = args['customer'];

      if (customerArg is CustomerModel) {
        _customer = customerArg;
      }

      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _loadBookings();
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
  // LOAD BOOKINGS
  // =====================================================

  Future<void> _loadBookings({
    int page = 1,
  }) async {
    if (_customer == null) return;

    _page = page;

    await context
        .read<BookingProvider>()
        .getBookings(
          page: _page,
          limit: _limit,
          customerId: _customer!.id,
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
    await _loadBookings(
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

    await _loadBookings(
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

    await _loadBookings(
      page: 1,
    );
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> _refresh() async {
    await _loadBookings(
      page: _page,
    );
  }

  // =====================================================
  // BOOKING ACTIONS
  // =====================================================

  void _viewBooking(
    BookingModel booking,
  ) {
    Navigator.pushNamed(
      context,
      AppRoutes.bookingDetails,
      arguments: booking,
    );
  }

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
    } else {
      _showProviderError();
    }
  }

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
    } else {
      _showProviderError();
    }
  }

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
                maxLines: 3,
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
    } else {
      _showProviderError();
    }
  }

  Future<void> _updatePayment(
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
    } else {
      _showProviderError();
    }
  }

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
    } else {
      _showProviderError();
    }
  }

  void _showProviderError() {
    final error =
        context
            .read<BookingProvider>()
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

    await _loadBookings(
      page: _page - 1,
    );
  }

  Future<void> _nextPage(
    int totalPages,
  ) async {
    if (_page >= totalPages) return;

    await _loadBookings(
      page: _page + 1,
    );
  }

  Future<void> _goToPage(
    int page,
  ) async {
    await _loadBookings(
      page: page,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Customer Bookings',
          ),
        ),
        body: const Center(
          child: Text(
            'Customer data not found',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Customer Bookings',
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
                      bookingProvider,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildCustomerSummary(),

                    const SizedBox(
                      height:
                          AppDimensions.padding24,
                    ),

                    _buildFilters(),

                    const SizedBox(
                      height:
                          AppDimensions.padding20,
                    ),

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

                    BookingTable(
                      bookings:
                          bookingProvider.bookings,
                      isLoading:
                          bookingProvider.isLoading,
                      onRefresh: _refresh,
                      onView: _viewBooking,
                      onConfirm: _confirmBooking,
                      onComplete:
                          _completeBooking,
                      onCancel: _cancelBooking,
                      onUpdatePayment:
                          _updatePayment,
                      onDelete: _deleteBooking,
                    ),

                    const SizedBox(
                      height:
                          AppDimensions.padding16,
                    ),

                    PaginationWidget(
                      currentPage:
                          bookingProvider.currentPage,
                      totalPages:
                          bookingProvider.totalPages,
                      totalRecords:
                          bookingProvider
                              .totalBookings,
                      pageSize: _limit,
                      onPrevious:
                          _previousPage,
                      onNext: () {
                        _nextPage(
                          bookingProvider
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
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader(
    BookingProvider provider,
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
                'Customer Bookings',
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
                'View and manage all bookings created by ${_customer!.displayName}.',
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
          title: 'Bookings',
          value: provider.totalBookings
              .toString(),
          icon:
              Icons.calendar_month_outlined,
          color: AppColors.primary,
        ),
      ],
    );
  }

  // =====================================================
  // CUSTOMER SUMMARY
  // =====================================================

  Widget _buildCustomerSummary() {
    final customer = _customer!;

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
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor:
                  AppColors.primary
                      .withOpacity(0.10),
              backgroundImage:
                  customer.profileImage != null &&
                          customer
                              .profileImage!
                              .isNotEmpty
                      ? NetworkImage(
                          customer.profileImage!,
                        )
                      : null,
              child: customer.profileImage ==
                          null ||
                      customer
                          .profileImage!
                          .isEmpty
                  ? Text(
                      AppFormatters
                          .getInitials(
                        customer.displayName,
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
                    customer.displayName,
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
                    customer.email.isNotEmpty
                        ? customer.email
                        : '-',
                    style: const TextStyle(
                      color:
                          AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    customer.phone.isNotEmpty
                        ? AppFormatters
                            .formatPhone(
                            customer.phone,
                          )
                        : '-',
                    style: const TextStyle(
                      color:
                          AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MiniMetric(
                  label: 'Total Bookings',
                  value: customer.totalBookings
                      .toString(),
                  color: AppColors.primary,
                ),
                _MiniMetric(
                  label: 'Total Spent',
                  value: AppFormatters
                      .formatCurrency(
                    customer.totalSpent,
                  ),
                  color: AppColors.success,
                ),
              ],
            ),
          ],
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
                  'Search bookings by booking number, service or provider...',
              onChanged: _onSearch,
              onClear: _clearFilters,
            );

            final statusDropdown =
                CustomDropdown<String>(
              labelText: 'Booking Status',
              hintText: 'All Status',
              value: _selectedStatus,
              items: const [
                'pending',
                'confirmed',
                'completed',
                'cancelled',
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
        minWidth: 130,
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