import 'package:flutter/material.dart';

import '../../config/route_config.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() =>
      _MyBookingsScreenState();
}

class _MyBookingsScreenState
    extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> bookings = [
    {
      'id': 'BK1001',
      'service':
          'Wedding Photography',
      'provider':
          'RK Photography',
      'date': '20 Jul 2026',
      'amount': '₹15,500',
      'status': 'Confirmed',
    },
    {
      'id': 'BK1002',
      'service': 'Catering',
      'provider':
          'Tasty Catering',
      'date': '05 Jul 2026',
      'amount': '₹25,500',
      'status': 'Completed',
    },
    {
      'id': 'BK1003',
      'service': 'DJ Service',
      'provider': 'DJ Beats',
      'date': '12 Jun 2026',
      'amount': '₹10,000',
      'status': 'Cancelled',
    },
  ];

  List<Map<String, dynamic>>
      filteredBookings = [];

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(
      length: 3,
      vsync: this,
    );

    filteredBookings = bookings;

    _tabController.addListener(() {
      filterBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshBookings() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void filterBookings() {
    String status = '';

    switch (_tabController.index) {
      case 0:
        status = 'Confirmed';
        break;

      case 1:
        status = 'Completed';
        break;

      case 2:
        status = 'Cancelled';
        break;
    }

    setState(() {
      filteredBookings =
          bookings.where((booking) {
        return booking['status'] ==
            status;
      }).toList();
    });
  }

  Color getStatusColor(
      String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;

      case 'Completed':
        return Colors.blue;

      case 'Cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'My Bookings',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Upcoming',
            ),
            Tab(
              text: 'Completed',
            ),
            Tab(
              text: 'Cancelled',
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: refreshBookings,
        child: filteredBookings.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                itemCount:
                    filteredBookings.length,
                itemBuilder:
                    (context, index) {
                  final booking =
                      filteredBookings[
                          index];

                  return Card(
                    margin:
                        const EdgeInsets.only(
                      bottom: 14,
                    ),
                    elevation: 2,
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
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteConfig
                              .bookingDetails,
                          arguments:
                              booking,
                        );
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .blue
                                        .withOpacity(
                                      0.1,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .event_available,
                                    color: Colors
                                        .blue,
                                  ),
                                ),

                                const SizedBox(
                                    width:
                                        12),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        booking[
                                            'service'],
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize:
                                              16,
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              4),
                                      Text(
                                        booking[
                                            'provider'],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 14),

                            const Divider(),

                            const SizedBox(
                                height: 5),

                            _infoRow(
                              'Booking ID',
                              booking['id'],
                            ),

                            _infoRow(
                              'Date',
                              booking['date'],
                            ),

                            _infoRow(
                              'Amount',
                              booking[
                                  'amount'],
                            ),

                            const SizedBox(
                                height: 10),

                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal:
                                        12,
                                    vertical:
                                        6,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: getStatusColor(
                                            booking[
                                                'status'])
                                        .withOpacity(
                                      0.12,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child: Text(
                                    booking[
                                        'status'],
                                    style:
                                        TextStyle(
                                      color: getStatusColor(
                                          booking[
                                              'status']),
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons
                                      .arrow_forward_ios,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
        vertical: 4,
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

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 150),
        Icon(
          Icons.event_busy,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'No Bookings Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}