import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final order =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?;

    final String orderId =
        order?['id'] ?? 'ORD1001';

    final String serviceName =
        order?['service'] ??
            'Wedding Photography';

    final String provider =
        order?['provider'] ??
            'RK Photography';

    final String status =
        order?['status'] ?? 'Active';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Order Details',
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.download,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ==================================
            // ORDER STATUS
            // ==================================

            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          status,
                        ).withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color:
                              _getStatusColor(
                            status,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      orderId,
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================
            // SERVICE DETAILS
            // ==================================

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
                        width: 70,
                        height: 70,
                        decoration:
                            BoxDecoration(
                          color: ThemeConfig
                              .primaryColor
                              .withOpacity(
                            0.1,
                          ),
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
                        serviceName,
                      ),
                      subtitle: Text(
                        provider,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================
            // ORDER INFO
            // ==================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow(
                      'Order ID',
                      orderId,
                    ),
                    _infoRow(
                      'Booking Date',
                      '20 Jul 2026',
                    ),
                    _infoRow(
                      'Time Slot',
                      '10:00 AM',
                    ),
                    _infoRow(
                      'Location',
                      'Hyderabad',
                    ),
                    _infoRow(
                      'Guests',
                      '100',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================
            // PROVIDER DETAILS
            // ==================================

            Card(
              child: ListTile(
                leading:
                    const CircleAvatar(
                  radius: 26,
                  child: Icon(
                    Icons.person,
                  ),
                ),
                title: Text(provider),
                subtitle: const Text(
                  'Verified Provider',
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RouteConfig
                          .providerProfile,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================
            // ORDER TIMELINE
            // ==================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _timelineItem(
                      'Order Created',
                      true,
                    ),
                    _timelineItem(
                      'Payment Successful',
                      true,
                    ),
                    _timelineItem(
                      'Provider Assigned',
                      true,
                    ),
                    _timelineItem(
                      'In Progress',
                      status ==
                          'Active',
                    ),
                    _timelineItem(
                      'Completed',
                      status ==
                          'Completed',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==================================
            // PAYMENT SUMMARY
            // ==================================

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
                      'Total Amount',
                      '₹15,500',
                      isTotal: true,
                    ),

                    _infoRow(
                      'Payment Method',
                      'UPI',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 120),
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
                  'Reorder',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _getStatusColor(
    String status,
  ) {
    switch (status) {
      case 'Completed':
        return Colors.green;

      case 'Cancelled':
        return Colors.red;

      case 'Active':
        return Colors.orange;

      default:
        return Colors.blue;
    }
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