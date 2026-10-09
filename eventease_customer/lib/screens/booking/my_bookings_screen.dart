import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/route_config.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

enum BookingFilter {
  recent,
  pending,
  inProgress,
  completed,
  cancelled,
}

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({
    super.key,
  });

  @override
  State<MyBookingsScreen> createState() {
    return _MyBookingsScreenState();
  }
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  BookingFilter _selectedFilter = BookingFilter.recent;

  bool _initialLoadRequested = false;

  static const List<BookingFilter> _filters = <BookingFilter>[
    BookingFilter.recent,
    BookingFilter.pending,
    BookingFilter.inProgress,
    BookingFilter.completed,
    BookingFilter.cancelled,
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: _filters.length,
      vsync: this,
    );

    _tabController.addListener(
      _handleTabChanged,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _loadBookings();
      },
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(
      _handleTabChanged,
    );

    _tabController.dispose();

    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) {
      return;
    }

    final filter = _filters[
        _tabController.index];

    if (_selectedFilter == filter) {
      return;
    }

    setState(() {
      _selectedFilter = filter;
    });
  }

  Future<void> _loadBookings({
    bool showLoading = true,
  }) async {
    if (!mounted) {
      return;
    }

    if (_initialLoadRequested &&
        showLoading) {
      return;
    }

    if (showLoading) {
      _initialLoadRequested = true;
    }

    await context
        .read<BookingProvider>()
        .getMyBookings(
          page: 1,
          limit: 100,
          forceRefresh: true,
          showLoading: showLoading,
        );
  }

  Future<void> _refreshBookings() async {
    await context
        .read<BookingProvider>()
        .getMyBookings(
          page: 1,
          limit: 100,
          forceRefresh: true,
          showLoading: false,
        );
  }

  List<BookingModel> _filterBookings(
    List<BookingModel> bookings,
  ) {
    final sortedBookings =
        List<BookingModel>.from(
      bookings,
    );

    sortedBookings.sort(
      (
        first,
        second,
      ) {
        return second.lastActivityAt.compareTo(
          first.lastActivityAt,
        );
      },
    );

    switch (_selectedFilter) {
      case BookingFilter.recent:
        return sortedBookings;

      case BookingFilter.pending:
        return sortedBookings.where(
          (booking) {
            return booking.isPending ||
                booking.isAccepted ||
                booking.isOtpVerified;
          },
        ).toList();

      case BookingFilter.inProgress:
        return sortedBookings.where(
          (booking) {
            return booking.isInProgress;
          },
        ).toList();

      case BookingFilter.completed:
        return sortedBookings.where(
          (booking) {
            return booking.isCompleted;
          },
        ).toList();

      case BookingFilter.cancelled:
        return sortedBookings.where(
          (booking) {
            return booking.isCancelled ||
                booking.isRejected;
          },
        ).toList();
    }
  }

  Future<void> _openBookingDetails(
    BookingModel booking,
  ) async {
    final bookingProvider =
        context.read<BookingProvider>();

    bookingProvider.setSelectedBooking(
      booking,
    );

    await Navigator.pushNamed(
      context,
      RouteConfig.bookingDetails,
      arguments: booking,
    );

    if (!mounted) {
      return;
    }

    await bookingProvider.getMyBookings(
      page: 1,
      limit: 100,
      forceRefresh: true,
      showLoading: false,
    );
  }

  String _tabLabel(
    BookingFilter filter,
  ) {
    switch (filter) {
      case BookingFilter.recent:
        return 'Recent';

      case BookingFilter.pending:
        return 'Pending';

      case BookingFilter.inProgress:
        return 'In Progress';

      case BookingFilter.completed:
        return 'Completed';

      case BookingFilter.cancelled:
        return 'Cancelled';
    }
  }

  String _emptyTitle(
    BookingFilter filter,
  ) {
    switch (filter) {
      case BookingFilter.recent:
        return 'No Bookings Found';

      case BookingFilter.pending:
        return 'No Pending Bookings';

      case BookingFilter.inProgress:
        return 'No Services In Progress';

      case BookingFilter.completed:
        return 'No Completed Bookings';

      case BookingFilter.cancelled:
        return 'No Cancelled Bookings';
    }
  }

  String _emptyDescription(
    BookingFilter filter,
  ) {
    switch (filter) {
      case BookingFilter.recent:
        return 'Your service bookings will appear here.';

      case BookingFilter.pending:
        return 'Bookings waiting for a Provider or service start will appear here.';

      case BookingFilter.inProgress:
        return 'Services currently in progress will appear here.';

      case BookingFilter.completed:
        return 'Your completed services will appear here.';

      case BookingFilter.cancelled:
        return 'Cancelled and rejected bookings will appear here.';
    }
  }

  IconData _emptyIcon(
    BookingFilter filter,
  ) {
    switch (filter) {
      case BookingFilter.recent:
        return Icons.event_note_outlined;

      case BookingFilter.pending:
        return Icons.pending_actions_outlined;

      case BookingFilter.inProgress:
        return Icons.play_circle_outline;

      case BookingFilter.completed:
        return Icons.task_alt_outlined;

      case BookingFilter.cancelled:
        return Icons.cancel_outlined;
    }
  }

  int _filterCount(
    BookingFilter filter,
    List<BookingModel> bookings,
  ) {
    switch (filter) {
      case BookingFilter.recent:
        return bookings.length;

      case BookingFilter.pending:
        return bookings.where(
          (booking) {
            return booking.isPending ||
                booking.isAccepted ||
                booking.isOtpVerified;
          },
        ).length;

      case BookingFilter.inProgress:
        return bookings.where(
          (booking) {
            return booking.isInProgress;
          },
        ).length;

      case BookingFilter.completed:
        return bookings.where(
          (booking) {
            return booking.isCompleted;
          },
        ).length;

      case BookingFilter.cancelled:
        return bookings.where(
          (booking) {
            return booking.isCancelled ||
                booking.isRejected;
          },
        ).length;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer<BookingProvider>(
      builder: (
        context,
        bookingProvider,
        child,
      ) {
        debugPrint('REAL MY BOOKINGS SCREEN OPENED');
        debugPrint('BOOKINGS COUNT: ${bookingProvider.myBookings.length}');
        
        final allBookings =
            bookingProvider.myBookings;

        final filteredBookings =
            _filterBookings(
          allBookings,
        );

        return Scaffold(
          backgroundColor:
              const Color(
            0xFFF8F9FC,
          ),
          appBar: AppBar(
            title: const Text(
              'My Bookings',
            ),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip:
                    'Refresh bookings',
                onPressed:
                    bookingProvider
                            .isRefreshing
                        ? null
                        : _refreshBookings,
                icon: bookingProvider
                        .isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                      ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(
                64,
              ),
              child: ColoredBox(
                color: Theme.of(context)
                    .appBarTheme
                    .backgroundColor ??
                    Theme.of(context)
                        .colorScheme
                        .surface,
                child: TabBar(
                  controller:
                      _tabController,
                  isScrollable: true,
                  tabAlignment:
                      TabAlignment.start,
                  tabs: _filters.map(
                    (filter) {
                      final count =
                          _filterCount(
                        filter,
                        allBookings,
                      );

                      return Tab(
                        child: Row(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            Text(
                              _tabLabel(
                                filter,
                              ),
                            ),
                            if (count >
                                0) ...[
                              const SizedBox(
                                width: 6,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      7,
                                  vertical:
                                      2,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  )
                                      .colorScheme
                                      .primary
                                      .withValues(
                                        alpha:
                                            0.12,
                                      ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                ),
                                child: Text(
                                  count
                                      .toString(),
                                  style:
                                      TextStyle(
                                    fontSize:
                                        12,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    color: Theme.of(
                                      context,
                                    )
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ),
          body: _buildBody(
            bookingProvider:
                bookingProvider,
            filteredBookings:
                filteredBookings,
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required BookingProvider bookingProvider,
    required List<BookingModel> filteredBookings,
  }) {
    if (bookingProvider.isLoading &&
        bookingProvider.myBookings.isEmpty) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (bookingProvider.hasError &&
        bookingProvider.myBookings.isEmpty) {
      return _buildErrorState(
        bookingProvider,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBookings,
      child: filteredBookings.isEmpty
          ? _buildEmptyState(
              _selectedFilter,
            )
          : ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                32,
              ),
              itemCount:
                  filteredBookings.length,
              itemBuilder: (
                context,
                index,
              ) {
                final booking =
                    filteredBookings[
                        index];

                return _BookingCard(
                  booking: booking,
                  onTap: () {
                    _openBookingDetails(
                      booking,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildErrorState(
    BookingProvider bookingProvider,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshBookings,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          24,
        ),
        children: [
          const SizedBox(
            height: 120,
          ),
          Icon(
            Icons
                .cloud_off_outlined,
            size: 90,
            color:
                Colors.red.shade300,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Unable to Load Bookings',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            bookingProvider.error ??
                'Please check your connection and try again.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          Center(
            child:
                ElevatedButton.icon(
              onPressed: () {
                _loadBookings(
                  showLoading:
                      true,
                );
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BookingFilter filter,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.all(
        24,
      ),
      children: [
        const SizedBox(
          height: 120,
        ),
        Icon(
          _emptyIcon(
            filter,
          ),
          size: 96,
          color:
              Colors.grey.shade400,
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          _emptyTitle(
            filter,
          ),
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          _emptyDescription(
            filter,
          ),
          textAlign:
              TextAlign.center,
          style: TextStyle(
            color:
                Colors.grey.shade600,
            fontWeight:
                FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        if (filter !=
            BookingFilter.recent)
          Center(
            child:
                OutlinedButton.icon(
              onPressed: () {
                _tabController
                    .animateTo(
                  0,
                );
              },
              icon: const Icon(
                Icons.history,
              ),
              label: const Text(
                'View Recent Bookings',
              ),
            ),
          ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const _BookingCard({
    required this.booking,
    required this.onTap,
  });

  Color _statusColor() {
    if (booking.isPending) {
      return Colors.orange;
    }

    if (booking.isAccepted) {
      return booking.providerArrived
          ? Colors.teal
          : Colors.blue;
    }

    if (booking.isOtpVerified) {
      return Colors.deepPurple;
    }

    if (booking.isInProgress) {
      return Colors.orange.shade800;
    }

    if (booking.isCompleted) {
      return Colors.green;
    }

    if (booking.isRejected) {
      return Colors.redAccent;
    }

    if (booking.isCancelled) {
      return Colors.red;
    }

    return Colors.grey;
  }

  IconData _statusIcon() {
    if (booking.isPending) {
      return Icons
          .pending_actions_outlined;
    }

    if (booking.isAccepted &&
        booking.providerArrived) {
      return Icons
          .location_on_outlined;
    }

    if (booking.isAccepted) {
      return Icons
          .event_available_outlined;
    }

    if (booking.isOtpVerified) {
      return Icons.verified_outlined;
    }

    if (booking.isInProgress) {
      return Icons
          .play_circle_outline;
    }

    if (booking.isCompleted) {
      return Icons
          .task_alt_outlined;
    }

    if (booking.isRejected) {
      return Icons.block_outlined;
    }

    if (booking.isCancelled) {
      return Icons
          .cancel_outlined;
    }

    return Icons
        .event_note_outlined;
  }

  String _formatDate(
    DateTime value,
  ) {
    final date =
        value.toLocal();

    final day = date.day
        .toString()
        .padLeft(
          2,
          '0',
        );

    final month = date.month
        .toString()
        .padLeft(
          2,
          '0',
        );

    return '$day-$month-${date.year}';
  }

  String _formatAmount(
    double value,
  ) {
    final amount =
        value.toStringAsFixed(
      2,
    );

    return '${booking.currency} $amount';
  }

  String _displayLocation() {
    if (booking.address
        .trim()
        .isNotEmpty) {
      return booking.address.trim();
    }

    if (booking.location
        .trim()
        .isNotEmpty) {
      return booking.location.trim();
    }

    return 'Not available';
  }

  String _reasonText() {
    if (booking.isRejected &&
        booking.rejectionReason
            .trim()
            .isNotEmpty) {
      return booking
          .rejectionReason
          .trim();
    }

    if (booking.isCancelled &&
        booking.cancellationReason
            .trim()
            .isNotEmpty) {
      return booking
          .cancellationReason
          .trim();
    }

    return '';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final statusColor =
        _statusColor();

    final reason =
        _reasonText();

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 1.5,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration:
                        BoxDecoration(
                      color: statusColor
                          .withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                    child: Icon(
                      _statusIcon(),
                      color:
                          statusColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          booking
                              .displayServiceName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          booking
                              .displayProviderName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade700,
                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration:
                              BoxDecoration(
                            color: statusColor
                                .withValues(
                              alpha: 0.12,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child: Text(
                            booking
                                .statusText,
                            style:
                                TextStyle(
                              color:
                                  statusColor,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons
                        .arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              const Divider(
                height: 1,
              ),
              const SizedBox(
                height: 12,
              ),
              _BookingInfoRow(
                title:
                    'Booking Number',
                value: booking
                    .displayBookingNumber,
              ),
              _BookingInfoRow(
                title:
                    'Booking Date',
                value: _formatDate(
                  booking.bookingDate,
                ),
              ),
              if (booking.bookingTime
                  .trim()
                  .isNotEmpty)
                _BookingInfoRow(
                  title: 'Time',
                  value: booking
                      .bookingTime
                      .trim(),
                ),
              _BookingInfoRow(
                title: 'Amount',
                value: _formatAmount(
                  booking.totalAmount,
                ),
              ),
              _BookingInfoRow(
                title: 'Location',
                value:
                    _displayLocation(),
              ),
              if (booking.providerArrived)
                _BookingInfoRow(
                  title:
                      'Provider Arrival',
                  value: booking
                          .providerArrivalVerified
                      ? 'Location verified'
                      : 'Provider arrived',
                  valueColor:
                      Colors.teal,
                ),
              if (booking.otpVerified)
                const _BookingInfoRow(
                  title:
                      'Service OTP',
                  value: 'Verified',
                  valueColor:
                      Colors.green,
                ),
              if (reason.isNotEmpty) ...[
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .all(
                    10,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.red
                        .withValues(
                      alpha: 0.06,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                  ),
                  child: Text(
                    reason,
                    style:
                        const TextStyle(
                      color: Colors.red,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _BookingInfoRow({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color:
                    Colors.grey.shade700,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    valueColor ??
                    Colors.black87,
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