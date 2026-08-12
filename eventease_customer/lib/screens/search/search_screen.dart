import 'package:flutter/material.dart';

import '../../config/route_config.dart';
import '../../config/theme_config.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  final List<Map<String, dynamic>> _allServices = [
    {
      'id': '1',
      'name': 'Premium Wedding Photography',
      'provider': 'RK Photography',
      'category': 'Photographer',
      'rating': 4.9,
      'price': 15000,
      'location': 'Hyderabad',
    },
    {
      'id': '2',
      'name': 'Royal Convention Hall',
      'provider': 'Royal Events',
      'category': 'Convention Hall',
      'rating': 4.8,
      'price': 50000,
      'location': 'Gachibowli',
    },
    {
      'id': '3',
      'name': 'Premium Catering',
      'provider': 'Tasty Catering',
      'category': 'Catering',
      'rating': 4.7,
      'price': 25000,
      'location': 'Madhapur',
    },
    {
      'id': '4',
      'name': 'Event Decoration',
      'provider': 'Royal Decorations',
      'category': 'Decoration',
      'rating': 4.8,
      'price': 12000,
      'location': 'Hitech City',
    },
    {
      'id': '5',
      'name': 'DJ Night Service',
      'provider': 'DJ Beats',
      'category': 'DJ',
      'rating': 4.6,
      'price': 12000,
      'location': 'Kondapur',
    },
    {
      'id': '6',
      'name': 'Bridal Makeup Artist',
      'provider': 'Glow Studio',
      'category': 'Makeup',
      'rating': 4.8,
      'price': 18000,
      'location': 'Jubilee Hills',
    },
  ];

  List<Map<String, dynamic>> _filteredServices = [];

  final List<String> _popularSearches = [
    'Photographer',
    'Catering',
    'Decoration',
    'Makeup',
    'DJ',
    'Convention Hall',
  ];

  @override
  void initState() {
    super.initState();

    _filteredServices =
        List<Map<String, dynamic>>.from(_allServices);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments;

      if (args is String && args.trim().isNotEmpty) {
        _searchController.text = args.trim();
        _searchServices(args.trim());
      }

      if (args is Map) {
        final query = args['query']?.toString() ??
            args['category']?.toString() ??
            '';

        if (query.trim().isNotEmpty) {
          _searchController.text = query.trim();
          _searchServices(query.trim());
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  void _searchServices(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredServices =
            List<Map<String, dynamic>>.from(_allServices);
        return;
      }

      _filteredServices = _allServices.where(
        (service) {
          final name =
              service['name']?.toString().toLowerCase() ?? '';
          final category =
              service['category']?.toString().toLowerCase() ?? '';
          final provider =
              service['provider']?.toString().toLowerCase() ?? '';
          final location =
              service['location']?.toString().toLowerCase() ?? '';

          return name.contains(query) ||
              category.contains(query) ||
              provider.contains(query) ||
              location.contains(query);
        },
      ).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchServices('');
  }

  void _openServiceDetails(
    Map<String, dynamic> service,
  ) {
    Navigator.pushNamed(
      context,
      RouteConfig.serviceDetails,
      arguments: service,
    );
  }

  void _openCategory(String category) {
    Navigator.pushNamed(
      context,
      RouteConfig.serviceList,
      arguments: {
        'category': category,
      },
    );
  }

  String _formatPrice(dynamic value) {
    final price = value is num
        ? value
        : num.tryParse(value?.toString() ?? '') ?? 0;

    return '₹${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FC,
      ),
      appBar: AppBar(
        title: const Text(
          'Search Services',
        ),
      ),
      body: Column(
        children: [
          // ==============================
          // SEARCH BAR
          // ==============================

          Padding(
            padding: const EdgeInsets.all(
              16,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _searchServices,
              onSubmitted: _searchServices,
              decoration: InputDecoration(
                hintText: 'Search photographers, catering, halls...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.close,
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // ==============================
          // POPULAR SEARCHES
          // ==============================

          if (_searchController.text.trim().isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularSearches.map(
                      (category) {
                        return ActionChip(
                          label: Text(
                            category,
                          ),
                          onPressed: () {
                            _searchController.text = category;
                            _searchServices(category);
                          },
                        );
                      },
                    ).toList(),
                  ),

                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),

          // ==============================
          // RESULT COUNT
          // ==============================

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Text(
                  '${_filteredServices.length} Services Found',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RouteConfig.serviceFilter,
                    );
                  },
                  icon: const Icon(
                    Icons.filter_list,
                    size: 18,
                  ),
                  label: const Text(
                    'Filter',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          // ==============================
          // RESULTS
          // ==============================

          Expanded(
            child: _filteredServices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ),
                    itemCount: _filteredServices.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final service =
                          _filteredServices[index];

                      return _serviceCard(
                        service: service,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard({
    required Map<String, dynamic> service,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          16,
        ),
        onTap: () {
          _openServiceDetails(service);
        },
        child: Padding(
          padding: const EdgeInsets.all(
            12,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color:
                      ThemeConfig.primaryColor.withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: ThemeConfig.primaryColor,
                  size: 34,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      service['provider']?.toString() ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    InkWell(
                      onTap: () {
                        _openCategory(
                          service['category']?.toString() ??
                              '',
                        );
                      },
                      child: Text(
                        service['category']?.toString() ?? '',
                        style: const TextStyle(
                          color: ThemeConfig.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Expanded(
                          child: Text(
                            service['location']?.toString() ??
                                '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Text(
                          service['rating']?.toString() ??
                              '0',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              SizedBox(
                width: 86,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatPrice(
                        service['price'],
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    SizedBox(
                      width: 78,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(
                            0,
                            40,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          _openServiceDetails(service);
                        },
                        child: const Text(
                          'View',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(
          height: 100,
        ),
        Icon(
          Icons.search_off,
          size: 90,
          color: Colors.grey.shade400,
        ),
        const SizedBox(
          height: 16,
        ),
        const Center(
          child: Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Center(
          child: Text(
            'Try searching with another keyword.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}