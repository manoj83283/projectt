import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_dimensions.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common/custom_search_bar.dart';
import '../../widgets/common/pagination_widget.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _page = 1;
  final int _limit = 20;

  String? _bookingStatus;
  String? _paymentStatus;
  String? _categoryId;
  String? _providerId;

  final List<String> _bookingStatuses = const [
    'pending',
    'confirmed',
    'assigned',
    'in_progress',
    'completed',
    'cancelled',
  ];

  final List<String> _paymentStatuses = const [
    'pending',
    'paid',
    'partial',
    'failed',
    'refunded',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookings();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    await context.read<BookingProvider>().getBookings(
          page: _page,
          limit: _limit,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          bookingStatus: _bookingStatus,
          paymentStatus: _paymentStatus,
          categoryId: _categoryId,
          providerId: _providerId,
        );
  }

  Future<void> _refresh() async {
    _page = 1;
    await _fetchBookings();
  }

  void _onSearch(String value) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        _page = 1;
        _fetchBookings();
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _page = 1;
      _bookingStatus = null;
      _paymentStatus = null;
      _categoryId = null;
      _providerId = null;
      _searchController.clear();
    });

    _fetchBookings();
  }

  void _onBookingStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _bookingStatus = value;
    });

    _fetchBookings();
  }

  void _onPaymentStatusChanged(String? value) {
    setState(() {
      _page = 1;
      _paymentStatus = value;
    });

    _fetchBookings();
  }

  void _onCategoryChanged(String value) {
    setState(() {
      _page = 1;
      _categoryId = value.trim().isEmpty ? null : value.trim();
    });

    _fetchBookings();
  }

  void _onProviderChanged(String value) {
    setState(() {
      _page = 1;
      _providerId = value.trim().isEmpty ? null : value.trim();
    });

    _fetchBookings();
  }

  void _previousPage() {
    if (_page <= 1) return;

    setState(() {
      _page--;
    });

    _fetchBookings();
  }

  void _nextPage(int totalPages) {
    if (_page >= totalPages) return;

    setState(() {
      _page++;
    });

    _fetchBookings();
  }

  void _goToPage(int page) {
    if (page == _page) return;

    setState(() {
      _page = page;
    });

    _fetchBookings();
  }

  Future<void> _viewBooking(BookingModel booking) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 620,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.padding24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Booking Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(
                    label: 'Booking ID',
                    value: booking.bookingNumber,
                  ),
                  _DetailRow(
                    label: 'Customer',
                    value: booking.customerName,
                  ),
                  _DetailRow(
                    label: 'Provider',
                    value: booking.providerName.isEmpty
                        ? 'Not Assigned'
                        : booking.providerName,
                  ),
                  _DetailRow(
                    label: 'Service',
                    value: booking.serviceName,
                  ),
                  _DetailRow(
                    label: 'Category',
                    value: booking.categoryName,
                  ),
                  _DetailRow(
                    label: 'Amount',
                    value: _formatCurrency(booking.amount),
                  ),
                  _DetailRow(
                    label: 'Booking Date',
                    value: _formatDateTime(booking.bookingDate),
                  ),
                  _DetailRow(
                    label: 'Event Date',
                    value: _formatDateTime(booking.eventDate),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _BookingStatusBadge(
                        status: booking.bookingStatus,
                      ),
                      _PaymentStatusBadge(
                        status: booking.paymentStatus,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _approveBooking(BookingModel booking) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Approve Booking',
      message:
          'Are you sure you want to approve booking ${booking.bookingNumber}?',
      confirmText: 'Approve',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success = await context
        .read<BookingProvider>()
        .approveBooking(booking.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Booking approved successfully',
      errorMessage: 'Failed to approve booking',
    );
  }

  Future<void> _assignProvider(BookingModel booking) async {
    final TextEditingController providerController =
        TextEditingController(text: booking.providerId);

    final String? providerId = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Assign Provider'),
          content: TextField(
            controller: providerController,
            decoration: const InputDecoration(
              labelText: 'Provider ID',
              hintText: 'Enter providerId',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final value = providerController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Assign'),
            ),
          ],
        );
      },
    );

    providerController.dispose();

    if (providerId == null || providerId.isEmpty) return;

    final bool success =
        await context.read<BookingProvider>().assignProvider(
              bookingId: booking.id,
              providerId: providerId,
            );

    _handleMutationResult(
      success: success,
      successMessage: 'Provider assigned successfully',
      errorMessage: 'Failed to assign provider',
    );
  }

  Future<void> _startBooking(BookingModel booking) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Start Service',
      message:
          'Do you want to mark booking ${booking.bookingNumber} as in progress?',
      confirmText: 'Start',
      confirmColor: AppColors.primary,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<BookingProvider>().startBooking(booking.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Booking started successfully',
      errorMessage: 'Failed to start booking',
    );
  }

  Future<void> _completeBooking(BookingModel booking) async {
    final bool confirmed = await _showConfirmationDialog(
      title: 'Complete Service',
      message:
          'Do you want to mark booking ${booking.bookingNumber} as completed?',
      confirmText: 'Complete',
      confirmColor: AppColors.success,
    );

    if (!confirmed) return;

    final bool success =
        await context.read<BookingProvider>().completeBooking(booking.id);

    _handleMutationResult(
      success: success,
      successMessage: 'Booking completed successfully',
      errorMessage: 'Failed to complete booking',
    );
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final TextEditingController reasonController = TextEditingController();

    final String? reason = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: TextField(
            controller: reasonController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Cancellation Reason',
              hintText: 'Enter valid cancellation reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final value = reasonController.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(context, value);
              },
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );

    reasonController.dispose();

    if (reason == null || reason.isEmpty) return;

    final bool success =
        await context.read<BookingProvider>().cancelBooking(
              bookingId: booking.id,
              reason: reason,
            );

    _handleMutationResult(
      success: success,
      successMessage: 'Booking cancelled successfully',
      errorMessage: 'Failed to cancel booking',
    );
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _handleMutationResult({
    required bool success,
    required String successMessage,
    required String errorMessage,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : errorMessage),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );

    if (success) {
      _fetchBookings();
    }
  }

  Widget _buildHeader(BookingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage customer bookings, provider assignments, service lifecycle, and payments.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 900;

            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isCompact ? 2 : 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isCompact ? 1.8 : 1.45,
              ),
              children: [
                _BookingSummaryCard(
                  title: 'Total Bookings',
                  value: provider.totalBookings.toString(),
                  icon: Icons.assignment_outlined,
                  color: AppColors.primary,
                ),
                _BookingSummaryCard(
                  title: 'Pending',
                  value: provider.pendingBookings.toString(),
                  icon: Icons.pending_actions_outlined,
                  color: AppColors.warning,
                ),
                _BookingSummaryCard(
                  title: 'Confirmed',
                  value: provider.confirmedBookings.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.info,
                ),
                _BookingSummaryCard(
                  title: 'Completed',
                  value: provider.completedBookings.toString(),
                  icon: Icons.task_alt_outlined,
                  color: AppColors.success,
                ),
                _BookingSummaryCard(
                  title: 'Cancelled',
                  value: provider.cancelledBookings.toString(),
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(AppDimensions.padding20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            hintText: 'Search booking id, customer, provider, service...',
            onChanged: _onSearch,
            onClear: _clearFilters,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isCompact = constraints.maxWidth < 850;

              if (isCompact) {
                return Column(
                  children: [
                    _buildStatusDropdown(),
                    const SizedBox(height: 14),
                    _buildPaymentDropdown(),
                    const SizedBox(height: 14),
                    _buildCategoryField(),
                    const SizedBox(height: 14),
                    _buildProviderField(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildStatusDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildPaymentDropdown()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildCategoryField()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildProviderField()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _bookingStatus,
      decoration: const InputDecoration(
        labelText: 'Booking Status',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Status'),
        ),
        ..._bookingStatuses.map(
          (status) => DropdownMenuItem<String>(
            value: status,
            child: Text(_formatStatus(status)),
          ),
        ),
      ],
      onChanged: _onBookingStatusChanged,
    );
  }

  Widget _buildPaymentDropdown() {
    return DropdownButtonFormField<String>(
      value: _paymentStatus,
      decoration: const InputDecoration(
        labelText: 'Payment Status',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Payments'),
        ),
        ..._paymentStatuses.map(
          (status) => DropdownMenuItem<String>(
            value: status,
            child: Text(_formatStatus(status)),
          ),
        ),
      ],
      onChanged: _onPaymentStatusChanged,
    );
  }

  Widget _buildCategoryField() {
    return TextFormField(
      initialValue: _categoryId,
      decoration: const InputDecoration(
        labelText: 'Category ID',
        hintText: 'categoryId',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        _searchDebounce?.cancel();
        _searchDebounce = Timer(
          const Duration(milliseconds: 500),
          () => _onCategoryChanged(value),
        );
      },
    );
  }

  Widget _buildProviderField() {
    return TextFormField(
      initialValue: _providerId,
      decoration: const InputDecoration(
        labelText: 'Provider ID',
        hintText: 'providerId',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        _searchDebounce?.cancel();
        _searchDebounce = Timer(
          const Duration(milliseconds: 500),
          () => _onProviderChanged(value),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (
        context,
        bookingProvider,
        child,
      ) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
              AppDimensions.padding24,
            ),
            child: Column(
              children: [
                _buildHeader(
                  bookingProvider,
                ),
                _buildFilters(),
                if (bookingProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      bookingProvider.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                BookingsTable(
                  bookings: bookingProvider.bookings,
                  isLoading: bookingProvider.isLoading,
                  onView: _viewBooking,
                  onApprove: _approveBooking,
                  onAssign: _assignProvider,
                  onStart: _startBooking,
                  onComplete: _completeBooking,
                  onCancel: _cancelBooking,
                ),
                const SizedBox(height: 20),
                PaginationWidget(
                  currentPage: bookingProvider.currentPage,
                  totalPages: bookingProvider.totalPages,
                  totalRecords: bookingProvider.totalBookings,
                  pageSize: _limit,
                  onPrevious: _previousPage,
                  onNext: () {
                    _nextPage(
                      bookingProvider.totalPages,
                    );
                  },
                  onPageSelected: _goToPage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  static String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String _formatStatus(String value) {
    return value
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class BookingsTable extends StatelessWidget {
  final List<BookingModel> bookings;
  final bool isLoading;
  final ValueChanged<BookingModel> onView;
  final ValueChanged<BookingModel> onApprove;
  final ValueChanged<BookingModel> onAssign;
  final ValueChanged<BookingModel> onStart;
  final ValueChanged<BookingModel> onComplete;
  final ValueChanged<BookingModel> onCancel;

  const BookingsTable({
    super.key,
    required this.bookings,
    required this.isLoading,
    required this.onView,
    required this.onApprove,
    required this.onAssign,
    required this.onStart,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const _TableHeader(),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (bookings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 54,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No bookings found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bookings matching your filters will appear here.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 66,
                dataRowMaxHeight: 76,
                columnSpacing: 28,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
                columns: const [
                  DataColumn(label: Text('Booking ID')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Provider')),
                  DataColumn(label: Text('Service')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Booking Date')),
                  DataColumn(label: Text('Event Date')),
                  DataColumn(label: Text('Booking Status')),
                  DataColumn(label: Text('Payment Status')),
                  DataColumn(label: Text('Actions')),
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
                          SizedBox(
                            width: 180,
                            child: Text(
                              booking.serviceName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              booking.categoryName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _BookingsScreenState._formatCurrency(
                              booking.amount,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _BookingsScreenState._formatDateTime(
                              booking.bookingDate,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            _BookingsScreenState._formatDateTime(
                              booking.eventDate,
                            ),
                          ),
                        ),
                        DataCell(
                          _BookingStatusBadge(
                            status: booking.bookingStatus,
                          ),
                        ),
                        DataCell(
                          _PaymentStatusBadge(
                            status: booking.paymentStatus,
                          ),
                        ),
                        DataCell(
                          _BookingActions(
                            booking: booking,
                            onView: onView,
                            onApprove: onApprove,
                            onAssign: onAssign,
                            onStart: onStart,
                            onComplete: onComplete,
                            onCancel: onCancel,
                          ),
                        ),
                      ],
                    );
                  },
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingInfoCell extends StatelessWidget {
  final BookingModel booking;

  const _BookingInfoCell({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 135,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.bookingNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            booking.id,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCell extends StatelessWidget {
  final BookingModel booking;

  const _CustomerCell({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              booking.customerName.isEmpty
                  ? 'C'
                  : booking.customerName[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              booking.customerName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCell extends StatelessWidget {
  final BookingModel booking;

  const _ProviderCell({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final bool assigned = booking.isAssigned || booking.providerName.isNotEmpty;

    return SizedBox(
      width: 170,
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: assigned
                ? AppColors.success.withOpacity(0.1)
                : AppColors.warning.withOpacity(0.1),
            child: Icon(
              assigned ? Icons.person_outline : Icons.person_off_outlined,
              size: 18,
              color: assigned ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              assigned ? booking.providerName : 'Not Assigned',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: assigned ? Colors.black87 : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingStatusBadge extends StatelessWidget {
  final String status;

  const _BookingStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        break;
      case 'confirmed':
        color = AppColors.info;
        break;
      case 'assigned':
        color = AppColors.primary;
        break;
      case 'in_progress':
        color = Colors.orange;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: _BookingsScreenState._formatStatus(status),
      color: color,
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  final String status;

  const _PaymentStatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final Color color;

    switch (status) {
      case 'pending':
        color = AppColors.warning;
        break;
      case 'paid':
        color = AppColors.success;
        break;
      case 'partial':
        color = AppColors.info;
        break;
      case 'failed':
        color = AppColors.error;
        break;
      case 'refunded':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return _StatusChip(
      label: _BookingsScreenState._formatStatus(status),
      color: color,
    );
  }
}

class _BookingActions extends StatelessWidget {
  final BookingModel booking;
  final ValueChanged<BookingModel> onView;
  final ValueChanged<BookingModel> onApprove;
  final ValueChanged<BookingModel> onAssign;
  final ValueChanged<BookingModel> onStart;
  final ValueChanged<BookingModel> onComplete;
  final ValueChanged<BookingModel> onCancel;

  const _BookingActions({
    required this.booking,
    required this.onView,
    required this.onApprove,
    required this.onAssign,
    required this.onStart,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Booking Actions',
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView(booking);
            break;
          case 'assign':
            onAssign(booking);
            break;
          case 'approve':
            onApprove(booking);
            break;
          case 'start':
            onStart(booking);
            break;
          case 'complete':
            onComplete(booking);
            break;
          case 'cancel':
            onCancel(booking);
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: _MenuItem(
            icon: Icons.visibility_outlined,
            label: 'View',
          ),
        ),
        const PopupMenuItem(
          value: 'assign',
          child: _MenuItem(
            icon: Icons.person_add_alt_1,
            label: 'Assign Provider',
          ),
        ),
        const PopupMenuItem(
          value: 'approve',
          child: _MenuItem(
            icon: Icons.check_circle_outline,
            label: 'Approve Booking',
            color: AppColors.success,
          ),
        ),
        const PopupMenuItem(
          value: 'start',
          child: _MenuItem(
            icon: Icons.play_circle_outline,
            label: 'Start Service',
            color: AppColors.primary,
          ),
        ),
        const PopupMenuItem(
          value: 'complete',
          child: _MenuItem(
            icon: Icons.task_alt_outlined,
            label: 'Complete Service',
            color: AppColors.success,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'cancel',
          child: _MenuItem(
            icon: Icons.cancel_outlined,
            label: 'Cancel Booking',
            color: AppColors.error,
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.more_vert,
          size: 20,
        ),
      ),
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _BookingSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.padding18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
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

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padding20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.table_chart_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Booking Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            'Live operational view',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
    final Color effectiveColor = color ?? Colors.black87;

    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: effectiveColor,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: effectiveColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.24),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}