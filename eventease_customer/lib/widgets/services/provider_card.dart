import 'package:flutter/material.dart';

class ProviderCard extends StatelessWidget {
  final String providerId;
  final String providerName;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final double startingPrice;
  final bool isVerified;
  final bool isOnline;
  final bool isFavorite;

  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onCall;
  final VoidCallback? onChat;
  final VoidCallback? onBook;

  const ProviderCard({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.startingPrice,
    this.isVerified = false,
    this.isOnline = false,
    this.isFavorite = false,
    this.onTap,
    this.onFavorite,
    this.onCall,
    this.onChat,
    this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor:
                            Colors.grey.shade200,
                        backgroundImage:
                            imageUrl.isNotEmpty
                                ? NetworkImage(
                                    imageUrl,
                                  )
                                : null,
                        child: imageUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 40,
                              )
                            : null,
                      ),

                      if (isOnline)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            height: 14,
                            width: 14,
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.green,
                              border:
                                  Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                providerName,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),

                            if (isVerified)
                              const Padding(
                                padding:
                                    EdgeInsets.only(
                                  left: 4,
                                ),
                                child: Icon(
                                  Icons.verified,
                                  color:
                                      Colors.blue,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          category,
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 8),

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

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.work_outline,
                              size: 18,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$experienceYears Years Experience',
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Starting From ₹${startingPrice.toStringAsFixed(0)}',
                          style:
                              const TextStyle(
                            color: Colors.green,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: onCall,
                      icon:
                          const Icon(Icons.call),
                      label:
                          const Text("Call"),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: onChat,
                      icon:
                          const Icon(Icons.chat),
                      label:
                          const Text("Chat"),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: onBook,
                      child: const Text(
                        "Book",
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