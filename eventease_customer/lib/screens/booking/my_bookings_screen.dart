import 'package:flutter/material.dart';

import '../../config/route_config.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() =>
      _MyOrdersScreenState();
}

class _MyOrdersScreenState
    extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>>
      orders = [
    {
      'id': 'OD1001',
      'service':
          'Wedding Photography',
      'provider':
          'RK Photography',
      'date': '20 Jul 2026',
      'amount': '₹15,500',
      'status': 'Processing',
    },
    {
      'id': 'OD1002',
      'service': 'Catering',
      'provider':
          'Tasty Catering',
      'date': '05 Jul 2026',
      'amount': '₹25,500',
      'status': 'Delivered',
    },
    {
      'id': 'OD1003',
      'service': 'DJ Service',
      'provider': 'DJ Beats',
      'date': '12 Jun 2026',
      'amount': '₹10,000',
      'status': 'Cancelled',
    },
  ];

  List<Map<String, dynamic>>
      filteredOrders = [];

  @override
  void initState() {
    super.initState();

    _tabController =
        TabController(
      length: 3,
      vsync: this,
    );

    filteredOrders = orders;

    _tabController.addListener(
      filterOrders,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshOrders() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void filterOrders() {
    String status = '';

    switch (_tabController.index) {
      case 0:
        status = 'Processing';
        break;

      case 1:
        status = 'Delivered';
        break;

      case 2:
        status = 'Cancelled';
        break;
    }

    setState(() {
      filteredOrders =
          orders.where((order) {
        return order['status'] ==
            status;
      }).toList();
    });
  }

  Color getStatusColor(
    String status,
  ) {
    switch (status) {
      case 'Processing':
        return Colors.orange;

      case 'Delivered':
        return Colors.green;

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
          'My Orders',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Processing',
            ),
            Tab(
              text: 'Delivered',
            ),
            Tab(
              text: 'Cancelled',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshOrders,
        child: filteredOrders.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                itemCount:
                    filteredOrders.length,
                itemBuilder:
                    (context, index) {
                  final order =
                      filteredOrders[
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
                              .orderDetails,
                          arguments:
                              order,
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
                                        .orange
                                        .withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .shopping_bag,
                                    color: Colors
                                        .orange,
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        order[
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
                                            4,
                                      ),
                                      Text(
                                        order[
                                            'provider'],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            const Divider(),

                            const SizedBox(
                              height: 5,
                            ),

                            _infoRow(
                              'Order ID',
                              order['id'],
                            ),

                            _infoRow(
                              'Date',
                              order['date'],
                            ),

                            _infoRow(
                              'Amount',
                              order[
                                  'amount'],
                            ),

                            const SizedBox(
                              height: 10,
                            ),

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
                                            order[
                                                'status'])
                                        .withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),
                                  child: Text(
                                    order[
                                        'status'],
                                    style:
                                        TextStyle(
                                      color: getStatusColor(
                                        order[
                                            'status'],
                                      ),
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
          Icons.shopping_bag_outlined,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'No Orders Found',
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