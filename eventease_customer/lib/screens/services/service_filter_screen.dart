import 'package:flutter/material.dart';

class ServiceFilterScreen extends StatefulWidget {
  const ServiceFilterScreen({super.key});

  @override
  State<ServiceFilterScreen> createState() =>
      _ServiceFilterScreenState();
}

class _ServiceFilterScreenState
    extends State<ServiceFilterScreen> {
  String selectedCategory = 'All';

  String selectedSort = 'Popularity';

  double minPrice = 0;
  double maxPrice = 100000;

  double selectedRating = 0;

  final TextEditingController
      locationController =
      TextEditingController();

  final List<String> categories = [
    'All',
    'Photographer',
    'Videographer',
    'Convention Hall',
    'Resort',
    'Catering',
    'Decoration',
    'DJ',
    'Makeup Artist',
    'Event Planner',
  ];

  final List<String> sortOptions = [
    'Popularity',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated',
    'Newest',
  ];

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  void clearFilters() {
    setState(() {
      selectedCategory = 'All';
      selectedSort = 'Popularity';
      minPrice = 0;
      maxPrice = 100000;
      selectedRating = 0;
      locationController.clear();
    });
  }

  void applyFilters() {
    Navigator.pop(
      context,
      {
        'category': selectedCategory,
        'sort': selectedSort,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'rating': selectedRating,
        'location':
            locationController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Filter Services',
        ),
        actions: [
          TextButton(
            onPressed: clearFilters,
            child: const Text(
              'Clear',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // CATEGORY

            const Text(
              'Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  categories.map((cat) {
                final selected =
                    selectedCategory ==
                        cat;

                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory =
                          cat;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            // LOCATION

            const Text(
              'Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  locationController,
              decoration:
                  const InputDecoration(
                hintText:
                    'Enter city/location',
                prefixIcon: Icon(
                  Icons.location_on,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // PRICE RANGE

            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '₹${minPrice.round()} - ₹${maxPrice.round()}',
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            RangeSlider(
              values: RangeValues(
                minPrice,
                maxPrice,
              ),
              min: 0,
              max: 100000,
              divisions: 100,
              labels: RangeLabels(
                '₹${minPrice.round()}',
                '₹${maxPrice.round()}',
              ),
              onChanged: (value) {
                setState(() {
                  minPrice =
                      value.start;
                  maxPrice =
                      value.end;
                });
              },
            ),

            const SizedBox(height: 25),

            // RATING

            const Text(
              'Minimum Rating',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Slider(
              value: selectedRating,
              min: 0,
              max: 5,
              divisions: 5,
              label:
                  selectedRating.toString(),
              onChanged: (value) {
                setState(() {
                  selectedRating =
                      value;
                });
              },
            ),

            const Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text('0'),
                Text('5 Stars'),
              ],
            ),

            const SizedBox(height: 25),

            // SORT

            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Column(
              children:
                  sortOptions.map((sort) {
                return RadioListTile<
                    String>(
                  value: sort,
                  groupValue:
                      selectedSort,
                  title: Text(sort),
                  onChanged: (value) {
                    setState(() {
                      selectedSort =
                          value!;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding:
            const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    clearFilters,
                child: const Text(
                  'Reset',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed:
                    applyFilters,
                child: const Text(
                  'Apply Filters',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}