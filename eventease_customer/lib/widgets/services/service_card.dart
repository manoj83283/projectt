import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String id;
  final String title;
  final String category;
  final String providerName;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double price;
  final double? originalPrice;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onBookNow;

  const ServiceCard({
    required this.id, required this.title, required this.category, required this.providerName, required this.imageUrl, required this.rating, required this.reviewCount, required this.price, super.key,
    this.originalPrice,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount =
        originalPrice != null &&
        originalPrice! > price;

    final int discountPercent = hasDiscount
        ? (((originalPrice! - price) /
                    originalPrice!) *
                100)
            .round()
        : 0;

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
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==========================
            // IMAGE
            // ==========================

            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.only(
                    topLeft:
                        Radius.circular(16),
                    topRight:
                        Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        height: 180,
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                if (hasDiscount)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        '$discountPercent% OFF',
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor:
                        Colors.white,
                    child: IconButton(
                      onPressed:
                          onFavorite,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons
                                .favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ==========================
            // CONTENT
            // ==========================

            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      color: Colors
                          .grey.shade600,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.store,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          providerName,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color:
                            Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating
                            .toStringAsFixed(
                                1),
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '($reviewCount Reviews)',
                        style: TextStyle(
                          color: Colors
                              .grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            '₹${price.toStringAsFixed(0)}',
                            style:
                                const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color:
                                  Colors.green,
                            ),
                          ),

                          if (hasDiscount)
                            Text(
                              '₹${originalPrice!.toStringAsFixed(0)}',
                              style:
                                  const TextStyle(
                                decoration:
                                    TextDecoration
                                        .lineThrough,
                                color:
                                    Colors.grey,
                              ),
                            ),
                        ],
                      ),

                      const Spacer(),

                      ElevatedButton(
                        onPressed:
                            onBookNow,
                        child: const Text(
                          'Book Now',
                        ),
                      ),
                    ],
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