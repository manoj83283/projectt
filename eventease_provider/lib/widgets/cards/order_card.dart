import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/helpers.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String productName;

  final DateTime orderDate;

  final double amount;

  final int quantity;

  final String status;

  final String? customerImage;

  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onViewDetails;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.productName,
    required this.orderDate,
    required this.amount,
    required this.quantity,
    required this.status,
    this.customerImage,
    this.onTap,
    this.onCall,
    this.onViewDetails,
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
              // ===========================
              // HEADER
              // ===========================

              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
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
                          productName,
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
                      horizontal: 12,
                      vertical: 6,
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
                        fontSize: 12,
                        fontWeight:
                            FontWeight
                                .w600,
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

              // ===========================
              // ORDER DETAILS
              // ===========================

              _infoRow(
                Icons.receipt_long,
                'Order ID',
                orderId,
              ),

              const SizedBox(
                height: 10,
              ),

              _infoRow(
                Icons.calendar_today,
                'Order Date',
                AppDateUtils
                    .formatDateTime(
                  orderDate,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              _infoRow(
                Icons.inventory_2,
                'Quantity',
                quantity.toString(),
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

              // ===========================
              // ACTIONS
              // ===========================

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
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          onViewDetails,
                      icon: const Icon(
                        Icons
                            .visibility_outlined,
                      ),
                      label: const Text(
                        'Details',
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
    String label,
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
          '$label : ',
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