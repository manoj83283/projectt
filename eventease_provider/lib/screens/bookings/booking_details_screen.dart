import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState
    extends State<BookingDetailsScreen> {
  late BookingModel booking;

  @override
  void initState() {
    super.initState();
    booking = widget.booking;
  }

  Future<void> _confirmBooking() async {
    final success = await context
        .read<BookingProvider>()
        .confirmBooking(booking.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Booking confirmed'),
        ),
      );
    }
  }

  Future<void> _startBooking() async {
    final success = await context
        .read<BookingProvider>()
        .startBooking(booking.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Booking started'),
        ),
      );
    }
  }

  Future<void> _completeBooking() async {
    final success = await context
        .read<BookingProvider>()
        .completeBooking(
          booking.id,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Booking completed'),
        ),
      );
    }
  }

  Future<void> _cancelBooking() async {
    final reasonController =
        TextEditingController();

    final result =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Cancel Booking'),
          content: TextField(
            controller:
                reasonController,
            decoration:
                const InputDecoration(
              labelText:
                  'Cancellation Reason',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                reasonController.text,
              ),
              child:
                  const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (result == null ||
        result.trim().isEmpty) {
      return;
    }

    final success = await context
        .read<BookingProvider>()
        .cancelBooking(
          bookingId: booking.id,
          reason: result,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Booking cancelled'),
        ),
      );
    }
  }

  Color _statusColor(
    String? status,
  ) {
    switch (
        status?.toLowerCase()) {
      case 'completed':
        return Colors.green;

      case 'confirmed':
        return Colors.blue;

      case 'cancelled':
        return Colors.red;

      case 'inprogress':
      case 'in_progress':
        return Colors.purple;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            _statusColor(
                          booking.status,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child: Text(
                        booking.status
                                ?.toUpperCase() ??
                            'PENDING',
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    Text(
                      booking.serviceName ??
                          'Service',
                      textAlign:
                          TextAlign.center,
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _sectionTitle(
                'Customer Information'),

            _infoCard(
              children: [
                _infoTile(
                  Icons.person,
                  'Customer Name',
                  booking.customerName ??
                      'N/A',
                ),
                _infoTile(
                  Icons.phone,
                  'Phone',
                  booking.customerPhone ??
                      'N/A',
                ),
                _infoTile(
                  Icons.email,
                  'Email',
                  booking.customerEmail ??
                      'N/A',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionTitle(
                'Booking Information'),

            _infoCard(
              children: [
                _infoTile(
                  Icons.confirmation_num,
                  'Booking ID',
                  booking.id,
                ),
                _infoTile(
                  Icons.calendar_today,
                  'Booking Date',
                  booking.bookingDate ??
                      'N/A',
                ),
                _infoTile(
                  Icons.access_time,
                  'Booking Time',
                  booking.bookingTime ??
                      'N/A',
                ),
                _infoTile(
                  Icons.location_on,
                  'Location',
                  booking.location ??
                      'N/A',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionTitle(
                'Payment Information'),

            _infoCard(
              children: [
                _infoTile(
                  Icons.currency_rupee,
                  'Amount',
                  '₹${booking.totalAmount ?? 0}',
                ),
                _infoTile(
                  Icons.payment,
                  'Payment Status',
                  booking
                          .paymentStatus ??
                      'Pending',
                ),
                _infoTile(
                  Icons.receipt_long,
                  'Transaction ID',
                  booking.transactionId ??
                      'N/A',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionTitle('Notes'),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Text(
                  booking.notes ??
                      'No notes available',
                ),
              ),
            ),

            const SizedBox(height: 25),

            if ((booking.status ?? '')
                    .toLowerCase() ==
                'pending')
              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _confirmBooking,
                  icon: const Icon(
                    Icons.check,
                  ),
                  label: const Text(
                    'CONFIRM BOOKING',
                  ),
                ),
              ),

            if ((booking.status ?? '')
                    .toLowerCase() ==
                'confirmed')
              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _startBooking,
                  icon: const Icon(
                    Icons.play_arrow,
                  ),
                  label: const Text(
                    'START SERVICE',
                  ),
                ),
              ),

            if ((booking.status ?? '')
                    .toLowerCase() ==
                'inprogress' ||
                (booking.status ?? '')
                        .toLowerCase() ==
                    'in_progress')
              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _completeBooking,
                  icon: const Icon(
                    Icons.done_all,
                  ),
                  label: const Text(
                    'COMPLETE BOOKING',
                  ),
                ),
              ),

            const SizedBox(height: 12),

            if ((booking.status ?? '')
                        .toLowerCase() !=
                    'completed' &&
                (booking.status ?? '')
                        .toLowerCase() !=
                    'cancelled')
              SizedBox(
                width:
                    double.infinity,
                child:
                    OutlinedButton.icon(
                  onPressed:
                      _cancelBooking,
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'CANCEL BOOKING',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard({
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}