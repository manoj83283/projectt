import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() =>
      _ReviewsScreenState();
}

class _ReviewsScreenState
    extends State<ReviewsScreen> {
  final TextEditingController searchController =
      TextEditingController();

  List<Map<String, dynamic>> reviews = [
    {
      'name': 'Manoj Kumar',
      'rating': 5,
      'date': '08 Jul 2026',
      'comment':
          'Excellent service. Very professional and delivered everything on time.',
      'verified': true,
    },
    {
      'name': 'Ravi Kumar',
      'rating': 4,
      'date': '05 Jul 2026',
      'comment':
          'Good experience with the provider. Highly recommended.',
      'verified': true,
    },
    {
      'name': 'Suresh',
      'rating': 5,
      'date': '01 Jul 2026',
      'comment':
          'Amazing photography and customer support.',
      'verified': false,
    },
    {
      'name': 'Anil',
      'rating': 3,
      'date': '28 Jun 2026',
      'comment':
          'Service was okay but can improve response time.',
      'verified': true,
    },
  ];

  List<Map<String, dynamic>> filteredReviews =
      [];

  @override
  void initState() {
    super.initState();
    filteredReviews = reviews;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshReviews() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void searchReviews(String query) {
    setState(() {
      filteredReviews = reviews.where(
        (review) {
          return review['name']
                  .toString()
                  .toLowerCase()
                  .contains(
                    query.toLowerCase(),
                  ) ||
              review['comment']
                  .toString()
                  .toLowerCase()
                  .contains(
                    query.toLowerCase(),
                  );
        },
      ).toList();
    });
  }

  Widget buildStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating
              ? Icons.star
              : Icons.star_border,
          color: Colors.orange,
          size: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double averageRating = 4.6;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Reviews & Ratings',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: refreshReviews,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: TextField(
                controller:
                    searchController,
                onChanged:
                    searchReviews,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Search reviews...',
                  prefixIcon:
                      Icon(Icons.search),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                children: [
                  // ==========================
                  // RATING SUMMARY
                  // ==========================

                  Card(
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Overall Rating',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const Text(
                            '4.6',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          buildStars(
                            averageRating
                                .round(),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Text(
                            '${reviews.length} Reviews',
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==========================
                  // RATING BREAKDOWN
                  // ==========================

                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(16),
                      child: Column(
                        children: [
                          _ratingBar(
                            5,
                            0.75,
                          ),
                          _ratingBar(
                            4,
                            0.55,
                          ),
                          _ratingBar(
                            3,
                            0.20,
                          ),
                          _ratingBar(
                            2,
                            0.05,
                          ),
                          _ratingBar(
                            1,
                            0.02,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ==========================
                  // REVIEWS LIST
                  // ==========================

                  const Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ...filteredReviews.map(
                    (review) =>
                        Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      ThemeConfig
                                          .primaryColor,
                                  child: Text(
                                    review['name']
                                        .toString()
                                        .substring(
                                            0,
                                            1),
                                    style:
                                        const TextStyle(
                                      color: Colors
                                          .white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        review[
                                            'name'],
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        review[
                                            'date'],
                                        style:
                                            const TextStyle(
                                          color: Colors
                                              .grey,
                                          fontSize:
                                              12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (review[
                                        'verified'] ==
                                    true)
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal:
                                          8,
                                      vertical:
                                          4,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors
                                          .green
                                          .withValues(
                                              alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(
                                              12),
                                    ),
                                    child:
                                        const Text(
                                      'Verified',
                                      style:
                                          TextStyle(
                                        color:
                                            Colors.green,
                                        fontSize:
                                            12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            buildStars(
                              review[
                                  'rating'],
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              review[
                                  'comment'],
                              style:
                                  const TextStyle(
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            ThemeConfig.primaryColor,
        onPressed: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Write Review Feature Coming Soon',
              ),
            ),
          );
        },
        icon: const Icon(
          Icons.rate_review,
          color: Colors.white,
        ),
        label: const Text(
          'Write Review',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _ratingBar(
    int star,
    double value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Text('$star'),
          const Icon(
            Icons.star,
            color: Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child:
                LinearProgressIndicator(
              value: value,
              minHeight: 8,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}