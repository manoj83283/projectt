import 'package:flutter/material.dart';

import '../../core/utils/helpers.dart';

class ServiceCard extends StatelessWidget {
  final String serviceId;
  final String serviceName;
  final String category;
  final String description;

  final double price;
  final double rating;

  final int totalReviews;

  final bool isActive;

  final String? imageUrl;

  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const ServiceCard({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.category,
    required this.description,
    required this.price,
    required this.rating,
    required this.totalReviews,
    required this.isActive,
    this.imageUrl,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isActive ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================
            // SERVICE IMAGE
            // ==================================

            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: imageUrl != null &&
                            imageUrl!.isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context,
                                    error,
                                    stackTrace) {
                              return Container(
                                color: Colors
                                    .grey.shade200,
                                child: const Icon(
                                  Icons
                                      .image_not_supported,
                                  size: 50,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors
                                .grey.shade200,
                            child: const Icon(
                              Icons
                                  .miscellaneous_services,
                              size: 60,
                              color:
                                  Colors.grey,
                            ),
                          ),
                  ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: statusColor,
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      isActive
                          ? 'ACTIVE'
                          : 'INACTIVE',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ==================================
            // CONTENT
            // ==================================

            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Theme.of(
                        context,
                      )
                          .primaryColor
                          .withValues(
                            alpha: 0.1,
                          ),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color:
                            Theme.of(context)
                                .primaryColor,
                        fontWeight:
                            FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    description,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style: TextStyle(
                      color: Colors
                          .grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============================
                  // PRICE & RATING
                  // ============================

                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .currency_rupee,
                              color:
                                  Colors.green,
                              size: 20,
                            ),
                            Text(
                              Helpers
                                  .formatCurrency(
                                price,
                              ),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                                fontSize:
                                    16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 18,
                            color:
                                Colors.amber,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            rating
                                .toStringAsFixed(
                              1,
                            ),
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                          Text(
                            ' ($totalReviews)',
                            style:
                                TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Divider(),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child:
                            Text(
                          'ID: $serviceId',
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ============================
                  // ACTION BUTTONS
                  // ============================

                  Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton.icon(
                          onPressed:
                              onEdit,
                          icon:
                              const Icon(
                            Icons.edit,
                          ),
                          label:
                              const Text(
                            'Edit',
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              onToggleStatus,
                          icon:
                              Icon(
                            isActive
                                ? Icons
                                    .pause_circle
                                : Icons
                                    .play_circle,
                          ),
                          label:
                              Text(
                            isActive
                                ? 'Disable'
                                : 'Enable',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child:
                        TextButton.icon(
                      onPressed:
                          onDelete,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete Service',
                        style: TextStyle(
                          color:
                              Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}