import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    await context
        .read<NotificationProvider>()
        .refreshData();
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> notifications,
  ) {
    switch (_selectedFilter) {
      case 'unread':
        return notifications
            .where(
              (e) => !(e.isRead ?? false),
            )
            .toList();

      case 'read':
        return notifications
            .where(
              (e) => e.isRead ?? false,
            )
            .toList();

      default:
        return notifications;
    }
  }

  IconData _getNotificationIcon(
    String? type,
  ) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return Icons.calendar_month;

      case 'order':
        return Icons.shopping_bag;

      case 'payment':
        return Icons.payments;

      case 'review':
        return Icons.star;

      case 'chat':
        return Icons.chat;

      case 'system':
        return Icons.settings;

      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(
    String? type,
  ) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return Colors.blue;

      case 'order':
        return Colors.orange;

      case 'payment':
        return Colors.green;

      case 'review':
        return Colors.amber;

      case 'chat':
        return Colors.purple;

      case 'system':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await context
        .read<NotificationProvider>()
        .markAllAsRead();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'All notifications marked as read'
              : 'Operation failed',
        ),
      ),
    );
  }

  Future<void> _deleteNotification(
    String notificationId,
  ) async {
    final success = await context
        .read<NotificationProvider>()
        .deleteNotification(
          notificationId,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Notification deleted',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
        ),
        actions: [
          IconButton(
            tooltip: 'Mark All Read',
            onPressed: _markAllAsRead,
            icon: const Icon(
              Icons.done_all,
            ),
          ),
        ],
      ),
      body:
          Consumer<NotificationProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          final notifications =
              _filterNotifications(
            provider.notifications,
          );

          return Column(
            children: [
              // =====================
              // HEADER
              // =====================

              Container(
                margin:
                    const EdgeInsets.all(
                  16,
                ),
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Theme.of(context)
                          .primaryColor
                          .withValues(
                            alpha: 0.08,
                          ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .notifications_active,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        'Unread Notifications: ${provider.unreadCount}',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // =====================
              // FILTERS
              // =====================

              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    ChoiceChip(
                      label:
                          const Text('All'),
                      selected:
                          _selectedFilter ==
                              'all',
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter =
                              'all';
                        });
                      },
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ChoiceChip(
                      label: const Text(
                        'Unread',
                      ),
                      selected:
                          _selectedFilter ==
                              'unread',
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter =
                              'unread';
                        });
                      },
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ChoiceChip(
                      label:
                          const Text('Read'),
                      selected:
                          _selectedFilter ==
                              'read',
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter =
                              'read';
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // =====================
              // LIST
              // =====================

              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : notifications
                            .isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Icon(
                                  Icons
                                      .notifications_off_outlined,
                                  size:
                                      80,
                                  color:
                                      Colors.grey,
                                ),
                                SizedBox(
                                  height:
                                      12,
                                ),
                                Text(
                                  'No Notifications Found',
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh:
                                _loadNotifications,
                            child:
                                ListView.builder(
                              padding:
                                  const EdgeInsets
                                      .all(
                                16,
                              ),
                              itemCount:
                                  notifications
                                      .length,
                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                final notification =
                                    notifications[
                                        index];

                                final color =
                                    _getNotificationColor(
                                  notification
                                      .type,
                                );

                                return Dismissible(
                                  key: Key(
                                    notification
                                        .id,
                                  ),
                                  direction:
                                      DismissDirection
                                          .endToStart,
                                  background:
                                      Container(
                                    alignment:
                                        Alignment
                                            .centerRight,
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      right:
                                          20,
                                    ),
                                    color:
                                        Colors
                                            .red,
                                    child:
                                        const Icon(
                                      Icons
                                          .delete,
                                      color:
                                          Colors
                                              .white,
                                    ),
                                  ),
                                  onDismissed:
                                      (_) {
                                    _deleteNotification(
                                      notification
                                          .id,
                                    );
                                  },
                                  child: Card(
                                    margin:
                                        const EdgeInsets
                                            .only(
                                      bottom:
                                          10,
                                    ),
                                    child:
                                        ListTile(
                                      leading:
                                          CircleAvatar(
                                        backgroundColor:
                                            color.withValues(
                                          alpha: 0.15,
                                        ),
                                        child:
                                            Icon(
                                          _getNotificationIcon(
                                            notification
                                                .type,
                                          ),
                                          color:
                                              color,
                                        ),
                                      ),
                                      title:
                                          Text(
                                        notification
                                                .title ??
                                            'Notification',
                                        style:
                                            TextStyle(
                                          fontWeight: notification.isRead ==
                                                  true
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                        ),
                                      ),
                                      subtitle:
                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height:
                                                4,
                                          ),
                                          Text(
                                            notification.message ??
                                                '',
                                          ),
                                          const SizedBox(
                                            height:
                                                6,
                                          ),
                                          Text(
                                            notification.createdAt ??
                                                '',
                                            style:
                                                const TextStyle(
                                              fontSize:
                                                  12,
                                              color:
                                                  Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: notification.isRead ==
                                              true
                                          ? null
                                          : Container(
                                              width:
                                                  10,
                                              height:
                                                  10,
                                              decoration:
                                                  const BoxDecoration(
                                                color:
                                                    Colors.blue,
                                                shape:
                                                    BoxShape.circle,
                                              ),
                                            ),
                                      onTap:
                                          () async {
                                        if (!(notification
                                                .isRead ??
                                            false)) {
                                          await provider
                                              .markAsRead(
                                            notification
                                                .id,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}