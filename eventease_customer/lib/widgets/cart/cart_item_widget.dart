import 'package:flutter/material.dart';

class CartItemWidget extends StatelessWidget {
  final String id;
  final String serviceName;
  final String providerName;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final int quantity;

  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const CartItemWidget({
    required this.id, required this.serviceName, required this.providerName, required this.imageUrl, required this.price, super.key,
    this.originalPrice,
    this.quantity = 1,
    this.onIncrement,
    this.onDecrement,
    this.onRemove,
    this.onTap,
  });

  bool get hasDiscount =>
      originalPrice != null &&
      originalPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;

    return (((originalPrice! - price) /
                originalPrice!) *
            100)
        .round();
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
              const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ======================
              // IMAGE
              // ======================

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      width: 100,
                      height: 100,
                      color:
                          Colors.grey.shade300,
                      child: const Icon(
                        Icons.image,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // ======================
              // DETAILS
              // ======================

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
                        fontSize: 16,
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
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    if (hasDiscount)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.red
                              .withValues(
                            alpha: 0.1,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          '$discountPercentage% OFF',
                          style:
                              const TextStyle(
                            color:
                                Colors.red,
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        Text(
                          '₹${price.toStringAsFixed(0)}',
                          style:
                              const TextStyle(
                            color:
                                Colors.green,
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        if (hasDiscount)
                          Text(
                            '₹${originalPrice!.toStringAsFixed(0)}',
                            style:
                                const TextStyle(
                              color:
                                  Colors.grey,
                              decoration:
                                  TextDecoration
                                      .lineThrough,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      'Subtotal: ₹${(price * quantity).toStringAsFixed(0)}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ======================
              // ACTIONS
              // ======================

              Column(
                children: [
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),

                  Container(
                    decoration:
                        BoxDecoration(
                      border: Border.all(
                        color: Colors
                            .grey.shade300,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        IconButton(
                          icon:
                              const Icon(
                            Icons.remove,
                            size: 18,
                          ),
                          onPressed:
                              onDecrement,
                        ),

                        Text(
                          quantity
                              .toString(),
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        IconButton(
                          icon:
                              const Icon(
                            Icons.add,
                            size: 18,
                          ),
                          onPressed:
                              onIncrement,
                        ),
                      ],
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