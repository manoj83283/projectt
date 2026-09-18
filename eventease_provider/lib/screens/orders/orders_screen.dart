import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({
    super.key,
  });

  @override
  State<OrdersScreen> createState() {
    return _OrdersScreenState();
  }
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          _loadOrders();
        }
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      await context
          .read<OrderProvider>()
          .getOrders();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _cleanError(error),
            ),
            backgroundColor:
                Colors.red.shade700,
            behavior:
                SnackBarBehavior.floating,
          ),
        );
    }
  }

  String _cleanError(
    Object error,
  ) {
    var message =
        error.toString().trim();

    const prefixes = <String>[
      'Exception: ',
      'FormatException: ',
      'Invalid argument(s): ',
    ];

    for (final prefix in prefixes) {
      if (message.startsWith(prefix)) {
        message = message
            .substring(prefix.length)
            .trim();
      }
    }

    return message.isEmpty
        ? 'Unable to load Provider orders.'
        : message;
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

  List<OrderModel> _filterOrders(
    List<OrderModel> orders,
    String status,
  ) {
    final normalizedStatus =
        _normalizeStatus(status);

    if (normalizedStatus == 'all') {
      return List<OrderModel>.from(
        orders,
      );
    }

    return orders.where(
      (order) {
        final orderStatus =
            _normalizeStatus(
          order.status,
        );

        if (normalizedStatus ==
            'accepted') {
          return orderStatus ==
                  'accepted' ||
              orderStatus ==
                  'confirmed';
        }

        if (normalizedStatus ==
            'cancelled') {
          return orderStatus ==
                  'cancelled' ||
              orderStatus ==
                  'canceled' ||
              orderStatus ==
                  'rejected';
        }

        return orderStatus ==
            normalizedStatus;
      },
    ).toList();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orders',
        ),
        bottom: TabBar(
          controller:
              _tabController,
          isScrollable: true,
          tabs: const <Widget>[
            Tab(
              text: 'All',
            ),
            Tab(
              text: 'Pending',
            ),
            Tab(
              text: 'Accepted',
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
      body: Consumer<OrderProvider>(
        builder: (
          BuildContext context,
          OrderProvider provider,
          Widget? child,
        ) {
          if (provider.isLoading &&
              provider.orders.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (provider.orders.isEmpty) {
            return _EmptyOrdersView(
              onRefresh: _loadOrders,
            );
          }

          return TabBarView(
            controller:
                _tabController,
            children: <Widget>[
              _OrderList(
                orders:
                    provider.orders,
                onRefresh:
                    _loadOrders,
              ),
              _OrderList(
                orders: _filterOrders(
                  provider.orders,
                  'pending',
                ),
                onRefresh:
                    _loadOrders,
              ),
              _OrderList(
                orders: _filterOrders(
                  provider.orders,
                  'accepted',
                ),
                onRefresh:
                    _loadOrders,
              ),
              _OrderList(
                orders: _filterOrders(
                  provider.orders,
                  'completed',
                ),
                onRefresh:
                    _loadOrders,
              ),
              _OrderList(
                orders: _filterOrders(
                  provider.orders,
                  'cancelled',
                ),
                onRefresh:
                    _loadOrders,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyOrdersView
    extends StatelessWidget {
  const _EmptyOrdersView({
    required this.onRefresh,
  });

  final Future<void> Function()
      onRefresh;

  @override
  Widget build(
    BuildContext context,
  ) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        children: const <Widget>[
          SizedBox(
            height: 150,
          ),
          Center(
            child: Column(
              children: <Widget>[
                Icon(
                  Icons
                      .shopping_bag_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 14,
                ),
                Text(
                  'No Orders Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  'New Customer bookings assigned to you will appear here.',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color:
                        Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderList
    extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.onRefresh,
  });

  final List<OrderModel> orders;

  final Future<void> Function()
      onRefresh;

  String _normalizeStatus(
    String? value,
  ) {
    return (value ?? 'pending')
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
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
      case 'canceled':
        return 'CANCELLED';

      case 'rejected':
        return 'REJECTED';

      case 'pending':
      default:
        return 'PENDING';
    }
  }

  Color _statusColor(
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
      case 'canceled':
      case 'rejected':
        return Colors.red;

      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _serviceName(
    OrderModel order,
  ) {
    final name =
        order.serviceName?.trim() ??
            '';

    return name.isEmpty
        ? 'Service Order'
        : name;
  }

  String _customerName(
    OrderModel order,
  ) {
    final name =
        order.customerName?.trim() ??
            '';

    return name.isEmpty
        ? 'Customer'
        : name;
  }

  String _orderDate(
    OrderModel order,
  ) {
    final date =
        order.orderDate?.trim() ??
            '';

    return date.isEmpty
        ? 'Date not available'
        : date;
  }

  double _totalAmount(
    OrderModel order,
  ) {
    final dynamic value =
        order.totalAmount;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _formatAmount(
    double amount,
  ) {
    if (amount ==
        amount.truncateToDouble()) {
      return amount
          .toInt()
          .toString();
    }

    return amount.toStringAsFixed(
      2,
    );
  }

  void _openOrderDetails(
    BuildContext context,
    OrderModel order,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (
          BuildContext context,
        ) {
          return OrderDetailsScreen(
            order: order,
          );
        },
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: const <Widget>[
            SizedBox(
              height: 160,
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons
                        .inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'No Orders Available',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(
          16,
        ),
        itemCount:
            orders.length,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          final order =
              orders[index];

          final status =
              _normalizeStatus(
            order.status,
          );

          final amount =
              _totalAmount(order);

          return Card(
            margin:
                const EdgeInsets.only(
              bottom: 12,
            ),
            clipBehavior:
                Clip.antiAlias,
            child: InkWell(
              onTap: () {
                _openOrderDetails(
                  context,
                  order,
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _serviceName(
                              order,
                            ),
                            style:
                                const TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
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
                                _statusColor(
                              status,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                          child: Text(
                            _statusLabel(
                              status,
                            ),
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
                      height: 14,
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons
                              .person_outline,
                          size: 18,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            _customerName(
                              order,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons
                              .calendar_today_outlined,
                          size: 18,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            _orderDate(
                              order,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '₹${_formatAmount(amount)}',
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
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _openOrderDetails(
                              context,
                              order,
                            );
                          },
                          icon: const Icon(
                            Icons
                                .visibility_outlined,
                            size: 18,
                          ),
                          label:
                              const Text(
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
      ),
    );
  }
}