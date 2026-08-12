import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  final TextEditingController
      searchController =
      TextEditingController();

  final List<String> recentSearches = [
    'Wedding Photographer',
    'Convention Hall',
    'Catering Service',
    'DJ Service',
  ];

  final List<String> popularSearches = [
    'Photographer',
    'Makeup Artist',
    'Decoration',
    'Resort',
    'Catering',
    'Wedding Hall',
    'Videographer',
    'Event Planner',
  ];

  final List<Map<String, dynamic>>
      searchResults = [
    {
      'name': 'Premium Wedding Photography',
      'rating': 4.9,
      'price': '₹15,000',
    },
    {
      'name': 'Luxury Convention Hall',
      'rating': 4.8,
      'price': '₹50,000',
    },
    {
      'name': 'Decoration Services',
      'rating': 4.7,
      'price': '₹12,000',
    },
  ];

  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void updateSearch(String value) {
    setState(() {
      query = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        title: const Text(
          'Search Services',
        ),
      ),

      body: Column(
        children: [
          // ==================================
          // SEARCH BAR
          // ==================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: updateSearch,
              decoration: InputDecoration(
                hintText:
                    'Search services...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon:
                    searchController
                            .text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController
                                  .clear();

                              setState(() {
                                query = '';
                              });
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,
              ),
            ),
          ),

          Expanded(
            child: query.isEmpty
                ? _buildSuggestions()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ==================================
          // RECENT SEARCHES
          // ==================================

          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  recentSearches.map(
                (search) {
                  return ActionChip(
                    label: Text(search),
                    onPressed: () {
                      searchController.text =
                          search;

                      updateSearch(
                        search,
                      );
                    },
                  );
                },
              ).toList(),
            ),
          ),

          const SizedBox(height: 25),

          // ==================================
          // POPULAR SEARCHES
          // ==================================

          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              'Popular Searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  popularSearches.map(
                (search) {
                  return Chip(
                    backgroundColor:
                        ThemeConfig
                            .primaryColor
                            .withValues(
                      alpha: 0.08,
                    ),
                    label: Text(
                      search,
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final service =
            searchResults[index];

        return Card(
          margin:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: ListTile(
            leading: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: ThemeConfig
                    .primaryColor
                    .withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons.business_center,
                color:
                    ThemeConfig.primaryColor,
              ),
            ),
            title: Text(
              service['name'],
            ),
            subtitle: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  service['rating']
                      .toString(),
                ),
              ],
            ),
            trailing: Text(
              service['price'],
              style: const TextStyle(
                color: Colors.green,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            onTap: () {
              // Navigate to service details
            },
          ),
        );
      },
    );
  }
}