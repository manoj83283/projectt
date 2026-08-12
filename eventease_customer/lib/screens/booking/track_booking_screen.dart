import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class TrackBookingScreen extends StatefulWidget {
  const TrackBookingScreen({
    super.key,
  });

  @override
  State<TrackBookingScreen> createState() =>
      _TrackBookingScreenState();
}

class _TrackBookingScreenState
    extends State<TrackBookingScreen> {
  final Map<String, dynamic> booking = {
    'bookingId': 'BK-20260709',
    'service': 'Wedding Photography',
    'provider': 'RK Photography',
    'status': 'On The Way',
    'eta': '25 mins',
    'location': 'Hyderabad',
    'amount': '₹15,500',
  };

  final List<Map<String, dynamic>> timeline = [
    {
      'title': 'Booking Created',
      'completed': true,
    },
    {
      'title': 'Booking Confirmed',
      'completed': true,
    },
    {
      'title': 'Provider Assigned',
      'completed': true,
    },
    {
      'title': 'On The Way',
      'completed': true,
    },
    {
      'title': 'Reached Location',
      'completed': false,
    },
    {
      'title': 'Service Completed',
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FC,
      ),
      appBar: AppBar(
        title: const Text(
          'Track Booking',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==================================
            // MAP SECTION
            // ==================================

            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.map,
                    size: 80,
                    color: Colors.grey,
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: const Text(
                        'Google Maps Integration',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================
            // STATUS CARD
            // ==================================

            Container(
              margin:
                  const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.orange
                                  .withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                        ),
                        child: const Text(
                          'ON THE WAY',
                          style: TextStyle(
                            color:
                                Colors.orange,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      Text(
                        booking['service'],
                        style:
                            const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        'ETA : ${booking['eta']}',
                        style:
                            const TextStyle(
                          color:
                              Colors.green,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================
            // PROVIDER CARD
            // ==================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Card(
                child: ListTile(
                  leading:
                      const CircleAvatar(
                    radius: 25,
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                  title: Text(
                    booking['provider'],
                  ),
                  subtitle: const Text(
                    'Verified Provider',
                  ),
                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Container(
                        decoration:
                            BoxDecoration(
                          color: Colors
                              .green
                              .withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.call,
                            color:
                                Colors.green,
                          ),
                          onPressed: () {},
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Container(
                        decoration:
                            BoxDecoration(
                          color: ThemeConfig
                              .primaryColor
                              .withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.chat,
                            color: ThemeConfig
                                .primaryColor,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              RouteConfig.chat,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================
            // BOOKING INFO
            // ==================================

            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    children: [
                      _infoRow(
                        'Booking ID',
                        booking[
                            'bookingId'],
                      ),
                      _infoRow(
                        'Location',
                        booking[
                            'location'],
                      ),
                      _infoRow(
                        'Amount',
                        booking[
                            'amount'],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================
            // TIMELINE
            // ==================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Card(
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
                      const Text(
                        'Booking Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ...timeline.map(
                        (item) =>
                            _timelineItem(
                          item['title'],
                          item[
                              'completed'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(
            value,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w600,
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
                  : Icons
                      .radio_button_unchecked,
              color: completed
                  ? Colors.green
                  : Colors.grey,
            ),
            Container(
              width: 2,
              height: 35,
              color:
                  Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding:
              const EdgeInsets.only(
            top: 2,
          ),
          child: Text(title),
        ),
      ],
    );
  }
}