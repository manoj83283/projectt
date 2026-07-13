import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final booking =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Booking Details',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // STATUS CARD
            // =========================

            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(
                          30,
                        ),
                      ),
                      child: const Text(
                        'Confirmed',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      booking?['bookingId'] ??
                          'BK-20260709001',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // SERVICE DETAILS
            // =========================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ListTile(
                      contentPadding:
                          EdgeInsets.zero,
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: ThemeConfig
                              .primaryColor
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: const Icon(
                          Icons.business_center,
                          color: ThemeConfig
                              .primaryColor,
                        ),
                      ),
                      title: Text(
                        booking?['serviceName'] ??
                            'Wedding Photography',
                      ),
                      subtitle: Text(
                        booking?['provider'] ??
                            'RK Photography',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // BOOKING INFO
            // =========================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(
                      'Booking Date',
                      '20 Jul 2026',
                    ),
                    _infoRow(
                      'Time Slot',
                      '10:00 AM',
                    ),
                    _infoRow(
                      'Guests',
                      '100',
                    ),
                    _infoRow(
                      'Location',
                      'Hyderabad',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // STATUS TIMELINE
            // =========================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _timelineItem(
                      'Booking Created',
                      true,
                    ),

                    _timelineItem(
                      'Booking Confirmed',
                      true,
                    ),

                    _timelineItem(
                      'Provider Assigned',
                      true,
                    ),

                    _timelineItem(
                      'Service Completed',
                      false,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // =========================
            // PAYMENT
            // =========================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        'Payment Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    _infoRow(
                      'Service Fee',
                      '₹15,000',
                    ),
                    _infoRow(
                      'Platform Fee',
                      '₹500',
                    ),

                    const Divider(),

                    _infoRow(
                      'Total',
                      '₹15,500',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child:
                  OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.call,
                ),
                label: const Text(
                  'Call',
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child:
                  OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConfig.chat,
                  );
                },
                icon: const Icon(
                  Icons.chat,
                ),
                label: const Text(
                  'Chat',
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConfig.booking,
                  );
                },
                child: const Text(
                  'Rebook',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: isTotal
                  ? Colors.green
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(
    String title,
    bool completed,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: completed
                  ? Colors.green
                  : Colors.grey,
            ),
            Container(
              width: 2,
              height: 35,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(
            top: 2,
          ),
          child: Text(title),
        ),
      ],
    );
  }
}