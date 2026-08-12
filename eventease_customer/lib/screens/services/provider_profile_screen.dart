import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({
    super.key,
  });

  @override
  State<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState
    extends State<ProviderProfileScreen> {
  final provider = {
    'name': 'RK Event Services',
    'rating': 4.9,
    'reviews': 325,
    'experience': '8 Years',
    'bookings': 1250,
    'location': 'Hyderabad',
    'phone': '+91 9876543210',
    'description':
        'Professional event services provider specializing in weddings, corporate events, photography, catering and decoration.',
  };

  final List<String> services = [
    'Wedding Photography',
    'Event Decoration',
    'Catering',
    'DJ Services',
    'Corporate Events',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Provider Profile',
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // =====================================
            // HEADER
            // =====================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: ThemeConfig.primaryColor,
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: ThemeConfig
                          .primaryColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    provider['name']
                        .toString(),
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified Provider',
                        style: TextStyle(
                          color:
                              Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =====================================
            // STATS
            // =====================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  _buildStatCard(
                    Icons.star,
                    provider['rating']
                        .toString(),
                    'Rating',
                    Colors.orange,
                  ),
                  _buildStatCard(
                    Icons.reviews,
                    provider['reviews']
                        .toString(),
                    'Reviews',
                    Colors.blue,
                  ),
                  _buildStatCard(
                    Icons.work,
                    provider[
                            'experience']
                        .toString(),
                    'Experience',
                    Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  title: Text(
                    provider['location']
                        .toString(),
                  ),
                  subtitle: const Text(
                    'Service Location',
                  ),
                ),
              ),
            ),

            // =====================================
            // ABOUT
            // =====================================

            const SizedBox(height: 15),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'About Provider',
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

                      Text(
                        provider[
                                'description']
                            .toString(),
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

            // =====================================
            // SERVICES
            // =====================================

            const SizedBox(height: 15),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Services Offered',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      ...services.map(
                        (service) =>
                            Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .check_circle,
                                color: Colors
                                    .green,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                service,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // =====================================
            // PORTFOLIO
            // =====================================

            const SizedBox(height: 15),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'Portfolio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              3,
                          crossAxisSpacing:
                              10,
                          mainAxisSpacing:
                              10,
                        ),
                        itemBuilder:
                            (context,
                                index) {
                          return Container(
                            decoration:
                                BoxDecoration(
                              color: ThemeConfig
                                  .primaryColor
                                  .withValues(
                                alpha: 0.1,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                            child:
                                const Icon(
                              Icons.image,
                              color:
                                  ThemeConfig
                                      .primaryColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),

      // =====================================
      // ACTION BUTTONS
      // =====================================

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child:
                  OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.call,
                ),
                label: const Text(
                  'Call',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child:
                  OutlinedButton.icon(
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
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConfig.booking,
                  );
                },
                child: const Text(
                  'Book',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String title,
    Color color,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}