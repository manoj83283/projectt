import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() =>
      _MyOrdersScreenState();
}

class _MyOrdersScreenState
    extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<OrderProvider>()
          .getMyOrders();
    });
  }

  Future<void> _refresh() async {
    await context
        .read<OrderProvider>()
        .getMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Orders',
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          if (provider.isLoading &&
              provider.myOrders.isEmpty) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (provider.error != null &&
              provider.myOrders.isEmpty) {
            return Center(
              child: Text(
                provider.error!,
              ),
            );
          }

          if (provider.myOrders.isEmpty) {
            return const Center(
              child: Text(
                'No orders found',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(16),
              itemCount:
                  provider.myOrders.length,
              itemBuilder:
                  (context, index) {
                final OrderModel order =
                    provider.myOrders[
                        index];

                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Order #${order.id}',
                                style:
                                    const TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                            _buildStatusChip(
                              order.status ??
                                  'Pending',
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          'Amount: ₹${order.totalAmount ?? 0}',
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          'Payment: ${order.paymentStatus ?? 'Pending'}',
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        if (order.createdAt !=
                            null)
                          Text(
                            'Date: ${order.createdAt}',
                          ),

                        const SizedBox(
                          height: 12,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  OutlinedButton(
                                onPressed: () {
                                  context
                                      .read<
                                          OrderProvider>()
                                      .getOrderById(
                                        order.id,
                                      );
                                },
                                child:
                                    const Text(
                                  'View',
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child:
                                  ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<
                                          OrderProvider>()
                                      .trackOrder(
                                        order.id,
                                      );
                                },
                                child:
                                    const Text(
                                  'Track',
                                ),
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
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(
    String status,
  ) {
    Color color;

    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;

      case 'cancelled':
        color = Colors.red;
        break;

      case 'processing':
        color = Colors.orange;
        break;

      case 'confirmed':
        color = Colors.blue;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}