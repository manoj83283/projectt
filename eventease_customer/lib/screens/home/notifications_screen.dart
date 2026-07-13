import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  List<Map<String, dynamic>>
      notifications = [
    {
      'title': 'Booking Confirmed',
      'message':
          'Your photography booking has been confirmed.',
      'time': '2 min ago',
      'isRead': false,
      'type': 'booking',
      'icon': Icons.event_available,
      'color': Colors.green,
    },
    {
      'title': 'New Message',
      'message':
          'You received a message from a provider.',
      'time': '15 min ago',
      'isRead': false,
      'type': 'chat',
      'icon': Icons.chat,
      'color': Colors.blue,
    },
    {
      'title': 'Payment Successful',
      'message':
          'Your payment was processed successfully.',
      'time': '1 hour ago',
      'isRead': true,
      'type': 'payment',
      'icon': Icons.payment,
      'color': Colors.orange,
    },
    {
      'title': 'Order Completed',
      'message':
          'Your catering service has been completed.',
      'time': 'Yesterday',
      'isRead': true,
      'type': 'order',
      'icon': Icons.check_circle,
      'color': Colors.purple,
    },
  ];

  Future<void> refreshNotifications() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void markAllAsRead() {
    setState(() {
      for (var item in notifications) {
        item['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        notifications
            .where(
              (e) => e['isRead'] == false,
            )
            .length;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Notifications',
            ),
            const SizedBox(width: 8),
            if (unreadCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: markAllAsRead,
            child: const Text(
              'Mark All Read',
            ),
          ),
        ],
      ),

      body: notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh:
                  refreshNotifications,
              child: ListView.builder(
                padding:
                    const EdgeInsets.all(16),
                itemCount:
                    notifications.length,
                itemBuilder:
                    (context, index) {
                  final item =
                      notifications[index];

                  return Card(
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    elevation:
                        item['isRead']
                            ? 1
                            : 3,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.all(
                        12,
                      ),

                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration:
                            BoxDecoration(
                          color: (item['color']
                                  as Color)
                              .withOpacity(
                            0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Icon(
                          item['icon'],
                          color:
                              item['color'],
                        ),
                      ),

                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['title'],
                              style:
                                  TextStyle(
                                fontWeight:
                                    item['isRead']
                                        ? FontWeight
                                            .w500
                                        : FontWeight
                                            .bold,
                              ),
                            ),
                          ),
                          if (item['isRead'] ==
                              false)
                            Container(
                              width: 10,
                              height: 10,
                              decoration:
                                  const BoxDecoration(
                                color: Colors.red,
                                shape:
                                    BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(
                          top: 6,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              item['message'],
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              item['time'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors
                                    .grey
                                    .shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      onTap: () {
                        setState(() {
                          item['isRead'] = true;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You have no notifications at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}