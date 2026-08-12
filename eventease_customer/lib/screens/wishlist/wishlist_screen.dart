import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/currency_formatter.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() =>
      _WishlistScreenState();
}

class _WishlistScreenState
    extends State<WishlistScreen> {
  final List<Map<String, dynamic>> wishlistItems = [
    {
      'id': '1',
      'name': 'Wedding Photography',
      'provider': 'Royal Photography',
      'price': 25000,
      'rating': 4.8,
      'image':
          'https://via.placeholder.com/300',
    },
    {
      'id': '2',
      'name': 'Event Decoration',
      'provider': 'Dream Decorators',
      'price': 18000,
      'rating': 4.6,
      'image':
          'https://via.placeholder.com/300',
    },
    {
      'id': '3',
      'name': 'Luxury Convention Hall',
      'provider': 'Grand Hall',
      'price': 65000,
      'rating': 4.9,
      'image':
          'https://via.placeholder.com/300',
    },
  ];

  Future<void> _refresh() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void _removeFromWishlist(int index) {
    final serviceName =
        wishlistItems[index]['name'];

    setState(() {
      wishlistItems.removeAt(index);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$serviceName removed from wishlist',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: wishlistItems.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding:
                    const EdgeInsets.all(16),
                itemCount:
                    wishlistItems.length,
                itemBuilder:
                    (context, index) {
                  final item =
                      wishlistItems[index];

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 16,
                    ),
                    decoration:
                        AppStyles
                            .cardDecoration,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(
                            top:
                                Radius.circular(
                              16,
                            ),
                          ),
                          child: Image.network(
                            item['image'],
                            height: 180,
                            width:
                                double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                height: 180,
                                color:
                                    Colors.grey
                                        .shade200,
                                child:
                                    const Icon(
                                  Icons.image,
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item[
                                          'name'],
                                      style:
                                          AppStyles
                                              .title,
                                      maxLines:
                                          2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed:
                                        () {
                                      _removeFromWishlist(
                                        index,
                                      );
                                    },
                                    icon:
                                        const Icon(
                                      Icons
                                          .favorite,
                                      color:
                                          Colors.red,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                item[
                                    'provider'],
                                style: AppStyles
                                    .bodyMedium,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors
                                        .amber,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    item[
                                            'rating']
                                        .toString(),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              Text(
                                CurrencyFormatter
                                    .format(
                                  item[
                                      'price'],
                                ),
                                style:
                                    const TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      AppColors
                                          .primary,
                                ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        OutlinedButton(
                                      onPressed:
                                          () {
                                        // Navigate to Service Details
                                      },
                                      child:
                                          const Text(
                                        'View Details',
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  Expanded(
                                    child:
                                        ElevatedButton(
                                      style: AppStyles
                                          .primaryButton,
                                      onPressed:
                                          () {
                                        ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text(
                                              'Added to cart',
                                            ),
                                          ),
                                        );
                                      },
                                      child:
                                          const Text(
                                        'Add To Cart',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(
          Icons.favorite_border,
          size: 100,
          color: Colors.grey,
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Text(
            'Save services and providers you like.',
          ),
        ),
      ],
    );
  }
}