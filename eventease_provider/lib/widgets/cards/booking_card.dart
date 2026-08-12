import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/helpers.dart';

class BookingCard extends StatelessWidget {
  final String bookingId;
  final String customerName;
  final String serviceName;

  final DateTime bookingDate;

  final double amount;

  final String status;

  final String? customerImage;

  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  const BookingCard({
    super.key,
    required this.bookingId,
    required this.customerName,
    required this.serviceName,
    required this.bookingDate,
    required this.amount,
    required this.status,
    this.customerImage,
    this.onTap,
    this.onCall,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor =
        Helpers.getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
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
              // ========================
              // HEADER
              // ========================

              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage:
                        customerImage !=
                                    null &&
                                customerImage!
                                    .isNotEmpty
                            ? NetworkImage(
                                customerImage!,
                              )
                            : null,
                    child: customerImage ==
                                null ||
                            customerImage!
                                .isEmpty
                        ? Text(
                            Helpers
                                .getInitials(
                              customerName,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          customerName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          serviceName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            color: Colors
                                .grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      color: statusColor
                          .withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      Helpers
                          .formatStatus(
                        status,
                      ),
                      style: TextStyle(
                        color:
                            statusColor,
                        fontWeight:
                            FontWeight
                                .w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              const Divider(),

              const SizedBox(
                height: 8,
              ),

              // ========================
              // BOOKING INFO
              // ========================

              _infoRow(
                Icons.tag,
                'Booking ID',
                bookingId,
              ),

              const SizedBox(
                height: 10,
              ),

              _infoRow(
                Icons.calendar_month,
                'Booking Date',
                AppDateUtils
                    .formatDateTime(
                  bookingDate,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _infoRow(
                Icons.currency_rupee,
                'Amount',
                Helpers
                    .formatCurrency(
                  amount,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ========================
              // ACTION BUTTONS
              // ========================

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton
                        .icon(
                      onPressed: onCall,
                      icon: const Icon(
                        Icons.call,
                      ),
                      label: const Text(
                        'Call',
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: ElevatedButton
                        .icon(
                      onPressed: onChat,
                      icon: const Icon(
                        Icons.chat,
                      ),
                      label: const Text(
                        'Chat',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey,
        ),

        const SizedBox(width: 8),

        Text(
          '$title : ',
          style: const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}