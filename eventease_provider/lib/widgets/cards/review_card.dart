import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import '../../core/utils/helpers.dart';

class ReviewCard extends StatelessWidget {
  final String reviewId;
  final String customerName;
  final String review;

  final double rating;

  final DateTime reviewDate;

  final String? customerImage;

  final String? providerReply;

  final VoidCallback? onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ReviewCard({
    super.key,
    required this.reviewId,
    required this.customerName,
    required this.review,
    required this.rating,
    required this.reviewDate,
    this.customerImage,
    this.providerReply,
    this.onReply,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =========================
              // CUSTOMER INFO
              // =========================

              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        customerImage != null &&
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
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          AppDateUtils
                              .formatDateTime(
                            reviewDate,
                          ),
                          style: TextStyle(
                            color: Colors
                                .grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.amber
                          .withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
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
                                    .bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              // =========================
              // REVIEW ID
              // =========================

              Text(
                'Review ID: $reviewId',
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // =========================
              // REVIEW TEXT
              // =========================

              Text(
                review,
                style: const TextStyle(
                  height: 1.5,
                ),
              ),

              // =========================
              // PROVIDER REPLY
              // =========================

              if (providerReply != null &&
                  providerReply!
                      .trim()
                      .isNotEmpty) ...[
                const SizedBox(
                  height: 16,
                ),

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.blue.shade50,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                    border: Border.all(
                      color:
                          Colors.blue.shade100,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.reply,
                            size: 18,
                            color:
                                Colors.blue,
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Text(
                            'Your Reply',
                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color: Colors
                                  .blue,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        providerReply!,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(
                height: 16,
              ),

              const Divider(),

              const SizedBox(
                height: 8,
              ),

              // =========================
              // ACTIONS
              // =========================

              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: onReply,
                      icon: const Icon(
                        Icons.reply,
                      ),
                      label: Text(
                        providerReply ==
                                null
                            ? 'Reply'
                            : 'Edit Reply',
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        ElevatedButton.icon(
                      style: ElevatedButton
                          .styleFrom(
                        backgroundColor:
                            Colors.red,
                      ),
                      onPressed:
                          onDelete,
                      icon: const Icon(
                        Icons.delete,
                        color:
                            Colors.white,
                      ),
                      label: const Text(
                        'Delete',
                        style:
                            TextStyle(
                          color: Colors
                              .white,
                        ),
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
}