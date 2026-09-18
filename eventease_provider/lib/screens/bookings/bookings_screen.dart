import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({
    super.key,
  });

  @override
  State<BookingsScreen> createState() =>
      _BookingsScreenState();
}

class _BookingsScreenState
    extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    await context
        .read<BookingProvider>()
        .getBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _normalizeStatus(
    String? value,
  ) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  List<BookingModel> _filterBookings(
    List<BookingModel> bookings,
    String status,
  ) {
    final normalizedStatus =
        _normalizeStatus(status);

    if (normalizedStatus == 'all') {
      return bookings;
    }

    return bookings.where((booking) {
      final bookingStatus =
          _normalizeStatus(
        booking.status,
      );

      if (normalizedStatus ==
          'accepted') {
        return bookingStatus ==
                'accepted' ||
            bookingStatus ==
                'confirmed';
      }

      return bookingStatus ==
          normalizedStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookings',
        ),
        bottom: TabBar(
          controller:
              _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (
          context,
          bookingProvider,
          child,
        ) {
          if (bookingProvider.isLoading &&
              bookingProvider
                  .bookings.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (bookingProvider
              .bookings.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadBookings,
              child: ListView(
                children: const [
                  SizedBox(
                    height: 150,
                  ),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons
                              .event_busy_outlined,
                          size: 80,
                          color:
                              Colors.grey,
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          'No Bookings Found',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadBookings,
            child: TabBarView(
              controller:
                  _tabController,
              children: [
                _BookingList(
                  bookings:
                      bookingProvider.bookings,
                ),
                _BookingList(
                  bookings:
                      _filterBookings(
                    bookingProvider
                        .bookings,
                    'pending',
                  ),
                ),
                _BookingList(
                  bookings:
                      _filterBookings(
                    bookingProvider
                        .bookings,
                    'accepted',
                  ),
                ),
                _BookingList(
                  bookings:
                      _filterBookings(
                    bookingProvider
                        .bookings,
                    'completed',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;

  const _BookingList({
    required this.bookings,
  });

  String _normalizeStatus(
    String? value,
  ) {
    return (value ?? 'pending')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  Color _getStatusColor(
    String? status,
  ) {
    switch (
        _normalizeStatus(status)) {
      case 'accepted':
      case 'confirmed':
        return Colors.blue;

      case 'in_progress':
        return Colors.deepPurple;

      case 'completed':
        return Colors.green;

      case 'cancelled':
      case 'rejected':
        return Colors.red;

      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(
    String? status,
  ) {
    switch (
        _normalizeStatus(status)) {
      case 'accepted':
      case 'confirmed':
        return 'ACCEPTED';

      case 'in_progress':
        return 'IN PROGRESS';

      case 'completed':
        return 'COMPLETED';

      case 'cancelled':
        return 'CANCELLED';

      case 'rejected':
        return 'REJECTED';

      case 'pending':
      default:
        return 'PENDING';
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          'No Bookings Available',
        ),
      );
    }

    return ListView.builder(
      padding:
          const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (
        context,
        index,
      ) {
        final booking =
            bookings[index];

        return Card(
          margin:
              const EdgeInsets.only(
            bottom: 12,
          ),
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
                    Expanded(
                      child: Text(
                        (booking.serviceName ??
                                '')
                                .isEmpty
                            ? 'Service'
                            : booking
                                .serviceName!,
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            _getStatusColor(
                          booking.status,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        _statusLabel(
                          booking.status,
                        ),
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 12,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        booking.customerName ??
                            'Customer',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        booking.bookingDate ??
                            '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        booking.bookingTime ??
                            '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    Text(
                      '₹${booking.totalAmount ?? 0}',
                      style:
                          const TextStyle(
                        fontSize: 18,
                        color:
                            Colors.green,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Booking Details Screen
                      },
                      child:
                          const Text(
                        'View',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}