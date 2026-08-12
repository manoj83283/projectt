import 'package:flutter/material.dart';

enum BookingStatus {
  pending,
  confirmed,
  assigned,
  inProgress,
  completed,
  cancelled,
}

class BookingStatusWidget extends StatelessWidget {
  final BookingStatus currentStatus;
  final bool showTitle;
  final EdgeInsetsGeometry padding;

  const BookingStatusWidget({
    required this.currentStatus, super.key,
    this.showTitle = true,
    this.padding =
        const EdgeInsets.all(16),
  });

  int get currentIndex {
    switch (currentStatus) {
      case BookingStatus.pending:
        return 0;

      case BookingStatus.confirmed:
        return 1;

      case BookingStatus.assigned:
        return 2;

      case BookingStatus.inProgress:
        return 3;

      case BookingStatus.completed:
        return 4;

      case BookingStatus.cancelled:
        return -1;
    }
  }

  List<Map<String, dynamic>> get statuses => [
        {
          'title': 'Booking Placed',
          'icon': Icons.receipt_long,
        },
        {
          'title': 'Confirmed',
          'icon': Icons.verified,
        },
        {
          'title': 'Provider Assigned',
          'icon': Icons.person_pin,
        },
        {
          'title': 'Service Started',
          'icon': Icons.play_circle_fill,
        },
        {
          'title': 'Completed',
          'icon': Icons.check_circle,
        },
      ];

  Color getStatusColor() {
    switch (currentStatus) {
      case BookingStatus.pending:
        return Colors.orange;

      case BookingStatus.confirmed:
        return Colors.blue;

      case BookingStatus.assigned:
        return Colors.indigo;

      case BookingStatus.inProgress:
        return Colors.purple;

      case BookingStatus.completed:
        return Colors.green;

      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String getStatusText() {
    switch (currentStatus) {
      case BookingStatus.pending:
        return 'Pending';

      case BookingStatus.confirmed:
        return 'Confirmed';

      case BookingStatus.assigned:
        return 'Provider Assigned';

      case BookingStatus.inProgress:
        return 'In Progress';

      case BookingStatus.completed:
        return 'Completed';

      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus ==
        BookingStatus.cancelled) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              const Icon(
                Icons.cancel,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 12),
              const Text(
                'Booking Cancelled',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This booking has been cancelled.',
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              Row(
                children: [
                  Icon(
                    Icons.track_changes,
                    color:
                        getStatusColor(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Booking Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: getStatusColor()
                    .withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                getStatusText(),
                style: TextStyle(
                  color:
                      getStatusColor(),
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Column(
              children: List.generate(
                statuses.length,
                (index) {
                  final item =
                      statuses[index];

                  final bool completed =
                      index <= currentIndex;

                  final bool isCurrent =
                      index ==
                          currentIndex;

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape.circle,
                              color: completed
                                  ? Colors.green
                                  : Colors
                                      .grey
                                      .shade300,
                            ),
                            child: Icon(
                              item['icon'],
                              size: 18,
                              color:
                                  Colors
                                      .white,
                            ),
                          ),

                          if (index <
                              statuses
                                      .length -
                                  1)
                            Container(
                              width: 3,
                              height: 45,
                              color: completed
                                  ? Colors
                                      .green
                                  : Colors
                                      .grey
                                      .shade300,
                            ),
                        ],
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            top: 6,
                          ),
                          child: Text(
                            item['title'],
                            style:
                                TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isCurrent
                                      ? FontWeight
                                          .bold
                                      : FontWeight
                                          .normal,
                              color: completed
                                  ? Colors
                                      .black
                                  : Colors
                                      .grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}