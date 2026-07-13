import 'package:flutter/material.dart';

import '../../config/theme_config.dart';
import '../../config/route_config.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() =>
      _ServiceListScreenState();
}

class _ServiceListScreenState
    extends State<ServiceListScreen> {
  final TextEditingController searchController =
      TextEditingController();

  List<Map<String, dynamic>> services = [
    {
      'id': '1',
      'name': 'Premium Wedding Photography',
      'provider': 'RK Photography',
      'category': 'Photographer',
      'rating': 4.9,
      'price': 15000,
      'location': 'Hyderabad',
      'image': '',
    },
    {
      'id': '2',
      'name': 'Royal Convention Hall',
      'provider': 'Royal Events',
      'category': 'Convention Hall',
      'rating': 4.8,
      'price': 50000,
      'location': 'Gachibowli',
      'image': '',
    },
    {
      'id': '3',
      'name': 'Premium Catering',
      'provider': 'Tasty Catering',
      'category': 'Catering',
      'rating': 4.7,
      'price': 25000,
      'location': 'Madhapur',
      'image': '',
    },
    {
      'id': '4',
      'name': 'DJ Night Service',
      'provider': 'DJ Beats',
      'category': 'DJ',
      'rating': 4.6,
      'price': 12000,
      'location': 'Hitech City',
      'image': '',
    },
  ];

  List<Map<String, dynamic>> filteredServices =
      [];

  @override
  void initState() {
    super.initState();
    filteredServices = services;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshServices() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void searchServices(String value) {
    setState(() {
      filteredServices = services
          .where(
            (service) =>
                service['name']
                    .toString()
                    .toLowerCase()
                    .contains(
                      value.toLowerCase(),
                    ) ||
                service['category']
                    .toString()
                    .toLowerCase()
                    .contains(
                      value.toLowerCase(),
                    ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text('Services'),
      ),

      body: RefreshIndicator(
        onRefresh: refreshServices,
        child: Column(
          children: [
            // SEARCH

            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: TextField(
                controller:
                    searchController,
                onChanged:
                    searchServices,
                decoration:
                    InputDecoration(
                  hintText:
                      'Search services...',
                  prefixIcon:
                      const Icon(
                    Icons.search,
                  ),
                  suffixIcon:
                      searchController
                              .text
                              .isNotEmpty
                          ? IconButton(
                              onPressed:
                                  () {
                                searchController
                                    .clear();

                                searchServices(
                                  '',
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .close,
                              ),
                            )
                          : null,
                ),
              ),
            ),

            // COUNT

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Text(
                    '${filteredServices.length} Services Found',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // LIST

            Expanded(
              child: ListView.builder(
                itemCount:
                    filteredServices.length,
                itemBuilder:
                    (context, index) {
                  final service =
                      filteredServices[
                          index];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),
                    child: InkWell(
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteConfig
                              .serviceDetails,
                          arguments:
                              service,
                        );
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration:
                                  BoxDecoration(
                                color:
                                    ThemeConfig
                                        .primaryColor
                                        .withOpacity(
                                  0.1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .business_center,
                                size: 35,
                                color: ThemeConfig
                                    .primaryColor,
                              ),
                            ),

                            const SizedBox(
                                width:
                                    12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    service[
                                        'name'],
                                    maxLines:
                                        2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        6,
                                  ),

                                  Text(
                                    service[
                                        'provider'],
                                    style: TextStyle(
                                        color: Colors
                                            .grey
                                            .shade600),
                                  ),

                                  const SizedBox(
                                    height:
                                        6,
                                  ),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .location_on,
                                        size:
                                            16,
                                        color:
                                            Colors.red,
                                      ),
                                      Expanded(
                                        child:
                                            Text(
                                          service[
                                              'location'],
                                          overflow:
                                              TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height:
                                        6,
                                  ),

                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .star,
                                        size:
                                            18,
                                        color: Colors
                                            .orange,
                                      ),
                                      Text(
                                        service[
                                                'rating']
                                            .toString(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .end,
                              children: [
                                Text(
                                  '₹${service['price']}',
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors.green,
                                  ),
                                ),

                                const SizedBox(
                                  height:
                                      16,
                                ),

                                ElevatedButton(
                                  onPressed:
                                      () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteConfig
                                          .serviceDetails,
                                      arguments:
                                          service,
                                    );
                                  },
                                  child:
                                      const Text(
                                    'View',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}