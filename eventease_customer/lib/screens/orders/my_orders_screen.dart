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

  final TextEditingController searchController =
      TextEditingController();

  final List<Map<String, dynamic>> orders = [
    {
      'id': 'ORD1001',
      'service': 'Wedding Photography',
      'provider': 'RK Photography',
      'date': '20 Jul 2026',
      'amount': '₹15,500',
      'status': 'Active',
    },
    {
      'id': 'ORD1002',
      'service': 'Premium Catering',
      'provider': 'Tasty Catering',
      'date': '10 Jul 2026',
      'amount': '₹25,000',
      'status': 'Completed',
    },
    {
      'id': 'ORD1003',
      'service': 'Event Decoration',
      'provider': 'Royal Decorators',
      'date': '05 Jul 2026',
      'amount': '₹12,000',
      'status': 'Cancelled',
    },
  ];

  List<Map<String, dynamic>> filteredOrders =
      [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    filterOrders();

    _tabController.addListener(() {
      filterOrders();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> refreshOrders() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void filterOrders() {
    String status = 'Active';

    if (_tabController.index == 1) {
      status = 'Completed';
    } else if (_tabController.index == 2) {
      status = 'Cancelled';
    }

    setState(() {
      filteredOrders = orders
          .where(
            (order) =>
                order['status'] == status,
          )
          .toList();
    });
  }

  void searchOrders(String query) {
    String status = 'Active';

    if (_tabController.index == 1) {
      status = 'Completed';
    } else if (_tabController.index == 2) {
      status = 'Cancelled';
    }

    setState(() {
      filteredOrders = orders.where((order) {
        return order['status'] == status &&
            (order['service']
                    .toString()
                    .toLowerCase()
                    .contains(
                      query.toLowerCase(),
                    ) ||
                order['id']
                    .toString()
                    .toLowerCase()
                    .contains(
                      query.toLowerCase(),
                    ));
      }).toList();
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Active':
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
          'My Orders',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: refreshOrders,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: TextField(
                controller:
                    searchController,
                onChanged: searchOrders,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Search orders...',
                  prefixIcon:
                      Icon(Icons.search),
                ),
              ),
            ),

            Expanded(
              child: filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
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
                              16,
                            ),
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
                                            .shopping_bag,
                                        color: Colors
                                            .blue,
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
                                  height: 15,
                                ),

                                const Divider(),

                                _orderRow(
                                  'Order ID',
                                  order['id'],
                                ),
                                _orderRow(
                                  'Date',
                                  order['date'],
                                ),
                                _orderRow(
                                  'Amount',
                                  order[
                                      'amount'],
                                ),

                                const SizedBox(
                                  height: 12,
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
                                            .withOpacity(
                                          0.15,
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
                                          fontWeight:
                                              FontWeight.bold,
                                          color: getStatusColor(
                                            order[
                                                'status'],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const Spacer(),

                                    if (order[
                                            'status'] ==
                                        'Active')
                                      ElevatedButton(
                                        onPressed:
                                            () {
                                          Navigator.pushNamed(
                                            context,
                                            RouteConfig
                                                .trackBooking,
                                          );
                                        },
                                        child:
                                            const Text(
                                          'Track',
                                        ),
                                      ),

                                    if (order[
                                            'status'] ==
                                        'Completed')
                                      OutlinedButton(
                                        onPressed:
                                            () {
                                          Navigator.pushNamed(
                                            context,
                                            RouteConfig
                                                .booking,
                                          );
                                        },
                                        child:
                                            const Text(
                                          'Reorder',
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderRow(
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
            style: const TextStyle(
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
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}