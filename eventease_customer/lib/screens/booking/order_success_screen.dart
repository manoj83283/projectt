import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../models/booking_model.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Object? arguments =
        ModalRoute.of(context)
            ?.settings
            .arguments;

    BookingModel? booking;

    if (arguments is BookingModel) {
      booking = arguments;
    }

    final bookingId =
        booking?.id ?? '';

    final bookingNumber =
        booking?.bookingNumber.isNotEmpty ==
                true
            ? booking!.bookingNumber
            : bookingId;

    final amount =
        booking?.totalAmount ??
        booking?.amount ??
        0;

    final bookingStatus =
        booking?.bookingStatus.isNotEmpty ==
                true
            ? booking!.bookingStatus
            : 'pending';

    final paymentStatus =
        booking?.paymentStatus.isNotEmpty ==
                true
            ? booking!.paymentStatus
            : 'pending';

    final serviceName =
        booking?.serviceName ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(
              minHeight:
                  MediaQuery.of(
                context,
              ).size.height -
                      48,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),

                // ==================================
                // SUCCESS ICON
                // ==================================

                Container(
                  width: 140,
                  height: 140,
                  decoration:
                      BoxDecoration(
                    color: Colors.green
                        .withValues(
                      alpha: 0.1,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 100,
                    color:
                        Colors.green,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // ==================================
                // TITLE
                // ==================================

                const Text(
                  'Booking Confirmed!',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  booking != null
                      ? 'Your booking has been created successfully and saved to the EventEase backend.'
                      : 'Booking completed successfully.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors
                        .grey
                        .shade600,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // ==================================
                // BOOKING CARD
                // ==================================

                Card(
                  elevation: 2,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          'Booking Number',
                          bookingNumber
                                  .trim()
                                  .isEmpty
                              ? 'N/A'
                              : bookingNumber,
                        ),

                        if (bookingId
                            .isNotEmpty) ...[
                          const Divider(),
                          _infoRow(
                            'Booking ID',
                            bookingId,
                          ),
                        ],

                        if (serviceName
                            .trim()
                            .isNotEmpty) ...[
                          const Divider(),
                          _infoRow(
                            'Service',
                            serviceName,
                          ),
                        ],

                        const Divider(),

                        _infoRow(
                          'Status',
                          bookingStatus
                              .replaceAll(
                                '_',
                                ' ',
                              )
                              .toUpperCase(),
                          valueColor:
                              Colors.green,
                        ),

                        const Divider(),

                        _infoRow(
                          'Payment',
                          paymentStatus
                              .toUpperCase(),
                          valueColor:
                              paymentStatus
                                          .toLowerCase() ==
                                      'paid'
                                  ? Colors
                                      .green
                                  : Colors
                                      .orange,
                        ),

                        const Divider(),

                        _infoRow(
                          'Amount',
                          '₹${amount.toStringAsFixed(0)}',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors
                        .green
                        .shade50,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Text(
                    booking != null
                        ? 'Booking saved successfully. Provider and Admin applications will receive the same booking record using Booking ID: ${booking.id}'
                        : 'Booking completed successfully.',
                    style:
                        const TextStyle(
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                // ==================================
                // TRACK BOOKING
                // ==================================

                SizedBox(
                  width:
                      double.infinity,
                  height: 55,
                  child:
                      ElevatedButton.icon(
                    icon: const Icon(
                      Icons
                          .location_on,
                    ),
                    label: const Text(
                      'Track Booking',
                    ),
                    onPressed:
                        booking == null
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  RouteConfig
                                      .trackBooking,
                                  arguments:
                                      booking,
                                );
                              },
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ==================================
                // MY BOOKINGS
                // ==================================

                SizedBox(
                  width:
                      double.infinity,
                  height: 55,
                  child:
                      OutlinedButton.icon(
                    icon: const Icon(
                      Icons.list_alt,
                    ),
                    label: const Text(
                      'My Bookings',
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        RouteConfig
                            .myBookings,
                      );
                    },
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ==================================
                // HOME BUTTON
                // ==================================

                SizedBox(
                  width:
                      double.infinity,
                  height: 55,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteConfig.home,
                        (
                          route,
                        ) =>
                            false,
                      );
                    },
                    child: const Text(
                      'Back To Home',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.end,
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                color:
                    valueColor ??
                    Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}