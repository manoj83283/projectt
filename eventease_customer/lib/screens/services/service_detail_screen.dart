import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({
    super.key,
  });

  @override
  State<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState
    extends State<ServiceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final service =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Service Details',
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =====================================
            // SERVICE IMAGE
            // =====================================

            Container(
              height: 250,
              width: double.infinity,
              color: ThemeConfig.primaryColor
                  .withOpacity(0.1),
              child: const Icon(
                Icons.image,
                size: 100,
                color: ThemeConfig.primaryColor,
              ),
            ),

            // =====================================
            // SERVICE INFO
            // =====================================

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    service?['name'] ??
                        'Service Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        service?['rating']
                                ?.toString() ??
                            '4.8',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        '(245 Reviews)',
                        style: TextStyle(
                          color: Colors
                              .grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        service?['location'] ??
                            'Hyderabad',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.currency_rupee,
                          color: Colors.green,
                        ),
                        Text(
                          '${service?['price'] ?? 10000}',
                          style:
                              const TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =====================================
                  // PROVIDER
                  // =====================================

                  const Text(
                    'Provider',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: ListTile(
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                      title: Text(
                        service?['provider'] ??
                            'Provider Name',
                      ),
                      subtitle: const Text(
                        'Verified Provider',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteConfig
                                .providerProfile,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================================
                  // DESCRIPTION
                  // =====================================

                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Professional event service with experienced staff, high-quality equipment, and excellent customer support. Perfect for weddings, birthday events, corporate functions, and special occasions.',
                    style: TextStyle(
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =====================================
                  // FEATURES
                  // =====================================

                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  buildFeature(
                    Icons.check_circle,
                    'Experienced Team',
                  ),
                  buildFeature(
                    Icons.check_circle,
                    'Affordable Pricing',
                  ),
                  buildFeature(
                    Icons.check_circle,
                    '24x7 Support',
                  ),
                  buildFeature(
                    Icons.check_circle,
                    'Instant Booking',
                  ),

                  const SizedBox(height: 25),

                  // =====================================
                  // REVIEWS
                  // =====================================

                  const Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: ListTile(
                      leading:
                          const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: const Text(
                        'Excellent Service',
                      ),
                      subtitle: const Text(
                        'Highly recommended for events.',
                      ),
                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.star,
                            color:
                                Colors.orange,
                            size: 18,
                          ),
                          Text('5'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      // =====================================
      // BOTTOM ACTIONS
      // =====================================

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConfig.chat,
                  );
                },
                icon: const Icon(
                  Icons.chat,
                ),
                label: const Text(
                  'Chat',
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Added To Cart',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Add Cart',
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConfig.booking,
                  );
                },
                child: const Text(
                  'Book Now',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeature(
    IconData icon,
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}