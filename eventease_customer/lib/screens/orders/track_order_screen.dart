import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() =>
      _TrackOrderScreenState();
}

class _TrackOrderScreenState
    extends State<TrackOrderScreen> {
  final Map<String, dynamic> order = {
    'orderId': 'ORD2026001',
    'service': 'Wedding Photography',
    'provider': 'RK Photography',
    'status': 'On The Way',
    'eta': '25 Minutes',
    'location': 'Hyderabad, Telangana',
    'amount': '₹15,500',
  };

  final List<Map<String, dynamic>> timeline = [
    {
      'title': 'Order Placed',
      'completed': true,
    },
    {
      'title': 'Payment Successful',
      'completed': true,
    },
    {
      'title': 'Provider Assigned',
      'completed': true,
    },
    {
      'title': 'Provider On The Way',
      'completed': true,
    },
    {
      'title': 'Service Started',
      'completed': false,
    },
    {
      'title': 'Order Completed',
      'completed': false,
    },
  ];

  Future<void> _refreshOrder() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Track Order',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshOrder,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // =========================
              // MAP SECTION
              // =========================

              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.map,
                        size: 90,
                        color: Colors.grey,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: const Text(
                          'Live Tracking',
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

              const SizedBox(height: 16),

              // =========================
              // STATUS CARD
              // =========================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Card(
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
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration:
                              BoxDecoration(
                            color: Colors.orange
                                .withValues(
                              alpha: 0.15,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              25,
                            ),
                          ),
                          child: Text(
                            order['status'],
                            style:
                                const TextStyle(
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
                          order['service'],
                          textAlign:
                              TextAlign.center,
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
                          "ETA : ${order['eta']}",
                          style:
                              const TextStyle(
                            fontSize: 18,
                            color:
                                Colors.green,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // PROVIDER
              // =========================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Card(
                  child: ListTile(
                    leading:
                        const CircleAvatar(
                      radius: 28,
                      child: Icon(
                        Icons.person,
                      ),
                    ),
                    title: Text(
                      order['provider'],
                    ),
                    subtitle: const Text(
                      'Verified Provider',
                    ),
                    trailing: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.call,
                            color:
                                Colors.green,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
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
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // ORDER INFO
              // =========================

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
                      children: [
                        _infoRow(
                          'Order ID',
                          order['orderId'],
                        ),
                        _infoRow(
                          'Location',
                          order['location'],
                        ),
                        _infoRow(
                          'Amount',
                          order['amount'],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // TIMELINE
              // =========================

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
                          'Order Timeline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
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

              const SizedBox(height: 16),

              // =========================
              // PAYMENT SUMMARY
              // =========================

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
                      children: [
                        const Align(
                          alignment:
                              Alignment.centerLeft,
                          child: Text(
                            'Payment Summary',
                            style:
                                TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

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
                          'Total Paid',
                          '₹15,500',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.chat,
                ),
                label: const Text(
                  'Chat',
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConfig.chat,
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.receipt_long,
                ),
                label: const Text(
                  'Details',
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConfig.orderDetails,
                    arguments: order,
                  );
                },
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
        vertical: 8,
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
                  : FontWeight.w600,
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
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 2,
            ),
            child: Text(title),
          ),
        ),
      ],
    );
  }
}