import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailsScreen> createState() =>
      _OrderDetailsScreenState();
}

class _OrderDetailsScreenState
    extends State<OrderDetailsScreen> {
  late OrderModel order;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  Future<void> _confirmOrder() async {
    final success = await context
        .read<OrderProvider>()
        .confirmOrder(order.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Order confirmed successfully',
          ),
        ),
      );
    }
  }

  Future<void> _startOrder() async {
    final success = await context
        .read<OrderProvider>()
        .startOrder(order.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Order started successfully',
          ),
        ),
      );
    }
  }

  Future<void> _completeOrder() async {
    final success = await context
        .read<OrderProvider>()
        .completeOrder(order.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Order completed successfully',
          ),
        ),
      );
    }
  }

  Future<void> _cancelOrder() async {
    final controller =
        TextEditingController();

    final reason =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Cancel Order'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration:
                const InputDecoration(
              hintText:
                  'Enter cancellation reason',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                controller.text,
              ),
              child:
                  const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (reason == null ||
        reason.trim().isEmpty) {
      return;
    }

    final success = await context
        .read<OrderProvider>()
        .cancelOrder(
          orderId: order.id,
          reason: reason,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Order cancelled'),
        ),
      );
    }
  }

  Color _statusColor(
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

      case 'inprogress':
      case 'in_progress':
        return Colors.purple;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Details',
        ),
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =========================
            // STATUS CARD
            // =========================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            _statusColor(
                          order.status,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          30,
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
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 16),
                    Text(
                      order.serviceName ??
                          'Service Order',
                      textAlign:
                          TextAlign.center,
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _sectionTitle(
              'Customer Information',
            ),

            _infoCard(
              children: [
                _infoTile(
                  Icons.person,
                  'Customer Name',
                  order.customerName ??
                      'N/A',
                ),
                _infoTile(
                  Icons.phone,
                  'Phone',
                  order.customerPhone ??
                      'N/A',
                ),
                _infoTile(
                  Icons.email,
                  'Email',
                  order.customerEmail ??
                      'N/A',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionTitle(
              'Order Information',
            ),

            _infoCard(
              children: [
                _infoTile(
                  Icons.receipt_long,
                  'Order ID',
                  order.id,
                ),
                _infoTile(
                  Icons.calendar_today,
                  'Order Date',
                  order.orderDate ??
                      'N/A',
                ),
                _infoTile(
                  Icons.event,
                  'Event Date',
                  order.eventDate ??
                      'N/A',
                ),
                _infoTile(
                  Icons.location_on,
                  'Location',
                  order.location ??
                      'N/A',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionTitle(
              'Payment Information',
            ),

            _infoCard(
              children: [
                _infoTile(
                  Icons.currency_rupee,
                  'Order Amount',
                  '₹${order.totalAmount ?? 0}',
                ),
                _infoTile(
                  Icons.payment,
                  'Payment Status',
                  order.paymentStatus ??
                      'Pending',
                ),
                _infoTile(
                  Icons.receipt,
                  'Transaction ID',
                  order.transactionId ??
                      'N/A',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _sectionTitle('Notes'),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Text(
                  order.notes ??
                      'No notes available',
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // ACTION BUTTONS
            // =========================

            if ((order.status ?? '')
                    .toLowerCase() ==
                'pending')
              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _confirmOrder,
                  icon: const Icon(
                    Icons.check,
                  ),
                  label: const Text(
                    'CONFIRM ORDER',
                  ),
                ),
              ),

            if ((order.status ?? '')
                    .toLowerCase() ==
                'confirmed')
              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _startOrder,
                  icon: const Icon(
                    Icons.play_arrow,
                  ),
                  label: const Text(
                    'START ORDER',
                  ),
                ),
              ),

            if ((order.status ?? '')
                    .toLowerCase() ==
                'inprogress' ||
                (order.status ?? '')
                        .toLowerCase() ==
                    'in_progress')
              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      _completeOrder,
                  icon: const Icon(
                    Icons.done_all,
                  ),
                  label: const Text(
                    'COMPLETE ORDER',
                  ),
                ),
              ),

            const SizedBox(height: 12),

            if ((order.status ?? '')
                        .toLowerCase() !=
                    'completed' &&
                (order.status ?? '')
                        .toLowerCase() !=
                    'cancelled')
              SizedBox(
                width:
                    double.infinity,
                child:
                    OutlinedButton.icon(
                  onPressed:
                      _cancelOrder,
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'CANCEL ORDER',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard({
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}