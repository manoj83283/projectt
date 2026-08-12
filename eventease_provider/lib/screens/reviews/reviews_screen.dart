import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/review_model.dart';
import '../../providers/review_provider.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() =>
      _ReviewsScreenState();
}

class _ReviewsScreenState
    extends State<ReviewsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    await context
        .read<ReviewProvider>()
        .refreshData();
  }

  List<ReviewModel> _filterReviews(
    List<ReviewModel> reviews,
  ) {
    if (_selectedFilter == 'all') {
      return reviews;
    }

    return reviews.where((review) {
      return review.rating
              .toString() ==
          _selectedFilter;
    }).toList();
  }

  Color _ratingColor(
    double rating,
  ) {
    if (rating >= 4.5) {
      return Colors.green;
    }

    if (rating >= 3) {
      return Colors.orange;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reviews & Ratings',
        ),
      ),
      body: Consumer<ReviewProvider>(
        builder: (
          context,
          provider,
          child,
        ) {
          final reviews =
              _filterReviews(
            provider.reviews,
          );

          return RefreshIndicator(
            onRefresh: _loadReviews,
            child: Column(
              children: [
                // =====================
                // ANALYTICS HEADER
                // =====================

                Container(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              title:
                                  'Rating',
                              value: provider
                                  .averageRating
                                  .toStringAsFixed(
                                    1,
                                  ),
                              icon:
                                  Icons.star,
                              color: Colors
                                  .orange,
                            ),
                          ),
                          const SizedBox(
                              width: 10),
                          Expanded(
                            child: _statCard(
                              title:
                                  'Reviews',
                              value: provider
                                  .totalReviews
                                  .toString(),
                              icon: Icons
                                  .reviews,
                              color:
                                  Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // =====================
                // FILTERS
                // =====================

                SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      _filterChip('all'),
                      _filterChip('5'),
                      _filterChip('4'),
                      _filterChip('3'),
                      _filterChip('2'),
                      _filterChip('1'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // =====================
                // REVIEW LIST
                // =====================

                Expanded(
                  child: provider
                              .isLoading &&
                          provider
                              .reviews
                              .isEmpty
                      ? const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                      : reviews.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  Icon(
                                    Icons
                                        .reviews_outlined,
                                    size: 80,
                                    color:
                                        Colors.grey,
                                  ),
                                  SizedBox(
                                      height:
                                          12),
                                  Text(
                                    'No Reviews Found',
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets
                                      .all(
                                16,
                              ),
                              itemCount:
                                  reviews
                                      .length,
                              itemBuilder:
                                  (
                                context,
                                index,
                              ) {
                                final review =
                                    reviews[
                                        index];

                                return Card(
                                  margin:
                                      const EdgeInsets.only(
                                    bottom:
                                        12,
                                  ),
                                  child:
                                      Padding(
                                    padding:
                                        const EdgeInsets.all(
                                      16,
                                    ),
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              child:
                                                  Text(
                                                (review.customerName ?? 'U')
                                                    .substring(
                                                  0,
                                                  1,
                                                )
                                                    .toUpperCase(),
                                              ),
                                            ),

                                            const SizedBox(
                                              width:
                                                  12,
                                            ),

                                            Expanded(
                                              child:
                                                  Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    review.customerName ??
                                                        'Customer',
                                                    style:
                                                        const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    review.createdAt ??
                                                        '',
                                                    style:
                                                        const TextStyle(
                                                      fontSize:
                                                          12,
                                                      color:
                                                          Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal:
                                                    10,
                                                vertical:
                                                    5,
                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                color:
                                                    _ratingColor(
                                                  review.rating.toDouble() ??
                                                      0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  20,
                                                ),
                                              ),
                                              child:
                                                  Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color:
                                                        Colors.white,
                                                    size:
                                                        14,
                                                  ),
                                                  const SizedBox(
                                                    width:
                                                        4,
                                                  ),
                                                  Text(
                                                    '${review.rating}',
                                                    style:
                                                        const TextStyle(
                                                      color:
                                                          Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(
                                          height:
                                              12,
                                        ),

                                        Text(
                                          review
                                              .serviceName,
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                              8,
                                        ),

                                        Text(
                                          review.comment ??
                                              '',
                                        ),

                                        if (review.reply
                                                .isNotEmpty)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(
                                              top:
                                                  12,
                                            ),
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
                                                8,
                                              ),
                                            ),
                                            child:
                                                Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Your Reply',
                                                  style:
                                                      TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height:
                                                      4,
                                                ),
                                                Text(
                                                  review.reply,
                                                ),
                                              ],
                                            ),
                                          ),

                                        const SizedBox(
                                          height:
                                              12,
                                        ),

                                        Align(
                                          alignment:
                                              Alignment.centerRight,
                                          child:
                                              OutlinedButton.icon(
                                            onPressed:
                                                () {
                                              _showReplyDialog(
                                                context,
                                                review,
                                              );
                                            },
                                            icon:
                                                const Icon(
                                              Icons.reply,
                                            ),
                                            label:
                                                Text(
                                              review.reply.isNotEmpty
                                                  ? 'Edit Reply'
                                                  : 'Reply',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterChip(
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),
      child: ChoiceChip(
        label: Text(
          value == 'all'
              ? 'All'
              : '$value ★',
        ),
        selected:
            _selectedFilter == value,
        onSelected: (_) {
          setState(() {
            _selectedFilter = value;
          });
        },
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(
    BuildContext context,
    ReviewModel review,
  ) {
    final controller =
        TextEditingController(
      text: review.reply,
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title:
              const Text('Reply Review'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration:
                const InputDecoration(
              hintText:
                  'Enter your response...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final reply =
                    controller.text
                        .trim();

                if (reply.isEmpty) {
                  return;
                }

                await context
                    .read<
                        ReviewProvider>()
                    .replyToReview(
                  reviewId:
                      review.id,
                  reply: reply,
                );

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(
                  context,
                );

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Reply submitted successfully',
                    ),
                  ),
                );
              },
              child:
                  const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}