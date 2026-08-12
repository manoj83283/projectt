import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() =>
      _OrdersScreenState();
}

class _OrdersScreenState
    extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    await context
        .read<OrderProvider>()
        .getOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(
    List<OrderModel> orders,
    String status,
  ) {
    if (status == 'all') return orders;

    return orders.where((order) {
      return (order.status ?? '')
              .toLowerCase() ==
          status.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading &&
              provider.orders.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (provider.orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView(
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No Orders Found',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderList(
                  orders: provider.orders,
                ),
                _OrderList(
                  orders: _filterOrders(
                    provider.orders,
                    'pending',
                  ),
                ),
                _OrderList(
                  orders: _filterOrders(
                    provider.orders,
                    'confirmed',
                  ),
                ),
                _OrderList(
                  orders: _filterOrders(
                    provider.orders,
                    'completed',
                  ),
                ),
                _OrderList(
                  orders: _filterOrders(
                    provider.orders,
                    'cancelled',
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

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;

  const _OrderList({
    required this.orders,
  });

  Color getStatusColor(
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

      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No Orders Available',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        return Card(
          margin:
              const EdgeInsets.only(
            bottom: 12,
          ),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      OrderDetailsScreen(
                    order: order,
                  ),
                ),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.serviceName ??
                              'Service Order',
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              getStatusColor(
                            order.status,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child: Text(
                          order.status
                                  .toUpperCase() ??
                              'PENDING',
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 11,
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
                          order.customerName ??
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
                        Icons.calendar_today,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        order.orderDate ??
                            '',
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
                        '₹${order.totalAmount ?? 0}',
                        style:
                            const TextStyle(
                          fontSize: 18,
                          color:
                              Colors.green,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailsScreen(
                                order: order,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'View',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}