import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final String bookingId;
  final String serviceName;
  final String providerName;
  final String imageUrl;
  final DateTime bookingDate;
  final DateTime eventDate;
  final double amount;
  final String status;

  final VoidCallback? onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onCancel;
  final VoidCallback? onViewDetails;

  const BookingCard({
    required this.bookingId, required this.serviceName, required this.providerName, required this.imageUrl, required this.bookingDate, required this.eventDate, required this.amount, required this.status, super.key,
    this.onTap,
    this.onTrack,
    this.onCancel,
    this.onViewDetails,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'completed':
        return Colors.blue;

      case 'cancelled':
        return Colors.red;

      case 'in progress':
        return Colors.purple;

      default:
        return Colors.grey;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Booking #$bookingId',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: getStatusColor()
                          .withValues(
                        alpha: 0.15,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      status,
                      style:
                          TextStyle(
                        color:
                            getStatusColor(),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                    child: Image.network(
                      imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          width: 90,
                          height: 90,
                          color:
                              Colors.grey.shade300,
                          child: const Icon(
                            Icons.image,
                            size: 35,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          serviceName,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          providerName,
                          style: TextStyle(
                            color: Colors
                                .grey.shade600,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 16,
                              color:
                                  Colors.blue,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                'Event: ${formatDate(eventDate)}',
                                style:
                                    const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Row(
                          children: [
                            const Icon(
                              Icons.receipt,
                              size: 16,
                              color:
                                  Colors.green,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              '₹${amount.toStringAsFixed(0)}',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.green,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      'Booked on ${formatDate(bookingDate)}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton(
                      onPressed:
                          onViewDetails,
                      child: const Text(
                        'Details',
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child:
                        ElevatedButton(
                      onPressed:
                          onTrack,
                      child: const Text(
                        'Track',
                      ),
                    ),
                  ),
                ],
              ),

              if (status.toLowerCase() !=
                      'completed' &&
                  status.toLowerCase() !=
                      'cancelled') ...[
                const SizedBox(height: 8),

                SizedBox(
                  width:
                      double.infinity,
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Cancel Booking',
                      style: TextStyle(
                        color:
                            Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}