import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() =>
      _CategoryScreenState();
}

class _CategoryScreenState
    extends State<CategoryScreen> {
  final TextEditingController
      searchController =
      TextEditingController();

  List<Map<String, dynamic>>
      categories = [
    {
      'name': 'Convention Hall',
      'icon': Icons.apartment,
      'count': '120+ Services',
    },
    {
      'name': 'Resort',
      'icon': Icons.hotel,
      'count': '80+ Services',
    },
    {
      'name': 'Photographer',
      'icon': Icons.camera_alt,
      'count': '250+ Services',
    },
    {
      'name': 'Videographer',
      'icon': Icons.videocam,
      'count': '180+ Services',
    },
    {
      'name': 'Makeup Artist',
      'icon': Icons.face,
      'count': '90+ Services',
    },
    {
      'name': 'Catering',
      'icon': Icons.restaurant,
      'count': '300+ Services',
    },
    {
      'name': 'Decoration',
      'icon': Icons.celebration,
      'count': '140+ Services',
    },
    {
      'name': 'DJ Services',
      'icon': Icons.music_note,
      'count': '75+ Services',
    },
    {
      'name': 'Event Planner',
      'icon': Icons.event,
      'count': '110+ Services',
    },
    {
      'name': 'Vegetables',
      'icon': Icons.grass,
      'count': '50+ Products',
    },
    {
      'name': 'Rice',
      'icon': Icons.rice_bowl,
      'count': '40+ Products',
    },
    {
      'name': 'Chicken',
      'icon': Icons.egg,
      'count': '70+ Products',
    },
  ];

  List<Map<String, dynamic>>
      filteredCategories = [];

  @override
  void initState() {
    super.initState();
    filteredCategories = categories;
  }

  Future<void> refreshCategories() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );
  }

  void searchCategory(String value) {
    setState(() {
      filteredCategories =
          categories.where((category) {
        return category['name']
            .toString()
            .toLowerCase()
            .contains(
              value.toLowerCase(),
            );
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Categories',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: refreshCategories,
        child: Column(
          children: [
            // =============================
            // SEARCH
            // =============================

            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: TextField(
                controller:
                    searchController,
                onChanged:
                    searchCategory,
                decoration:
                    InputDecoration(
                  hintText:
                      'Search category...',
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

                                searchCategory(
                                    '');
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .clear,
                              ),
                            )
                          : null,
                ),
              ),
            ),

            // =============================
            // CATEGORY COUNT
            // =============================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Text(
                    '${filteredCategories.length} Categories Available',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // =============================
            // GRID VIEW
            // =============================

            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                itemCount:
                    filteredCategories
                        .length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder:
                    (context, index) {
                  final category =
                      filteredCategories[
                          index];

                  return Card(
                    elevation: 3,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),
                    child: InkWell(
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                      onTap: () {
                        // Navigate to Services List Screen
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(16),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              decoration:
                                  BoxDecoration(
                                color: ThemeConfig
                                    .primaryColor
                                    .withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),
                              ),
                              child: Icon(
                                category[
                                    'icon'],
                                size: 36,
                                color:
                                    ThemeConfig
                                        .primaryColor,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            Text(
                              category[
                                  'name'],
                              textAlign:
                                  TextAlign
                                      .center,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize:
                                    15,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              category[
                                  'count'],
                              textAlign:
                                  TextAlign
                                      .center,
                              style:
                                  TextStyle(
                                fontSize:
                                    12,
                                color: Colors
                                    .grey
                                    .shade600,
                              ),
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