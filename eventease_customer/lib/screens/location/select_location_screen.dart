import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/storage_helper.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() =>
      _SelectLocationScreenState();
}

class _SelectLocationScreenState
    extends State<SelectLocationScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String selectedLocation = 'Hyderabad';

  final List<String> popularLocations = [
    'Hyderabad',
    'Bangalore',
    'Chennai',
    'Mumbai',
    'Delhi',
    'Pune',
    'Vijayawada',
    'Warangal',
    'Karimnagar',
    'Nizamabad',
  ];

  final List<String> recentLocations = [
    'Madhapur',
    'Gachibowli',
    'Kondapur',
    'Kukatpally',
  ];

  Future<void> _saveLocation(
    String location,
  ) async {
    await StorageHelper.setString(
      'selected_location',
      location,
    );

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '$location selected',
          ),
        ),
      );

      Navigator.pop(context, location);
    }
  }

  Future<void> _useCurrentLocation() async {
    // Replace with Geolocator implementation

    const currentLocation =
        'Current GPS Location';

    setState(() {
      selectedLocation = currentLocation;
    });

    await _saveLocation(currentLocation);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLocations =
        popularLocations.where((location) {
      return location.toLowerCase().contains(
            _searchController.text
                .toLowerCase(),
          );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Select Location',
        ),
      ),

      body: Column(
        children: [
          // ============================
          // SEARCH BAR
          // ============================

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration:
                  AppStyles.inputDecoration(
                hintText:
                    'Search city or area',
                prefixIcon: const Icon(
                  Icons.search,
                ),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
          ),

          // ============================
          // CURRENT LOCATION
          // ============================

          ListTile(
            leading: const CircleAvatar(
              backgroundColor:
                  AppColors.primary,
              child: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
            title: const Text(
              'Use Current Location',
            ),
            subtitle: const Text(
              'Detect using GPS',
            ),
            onTap: _useCurrentLocation,
          ),

          const Divider(),

          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              children: [
                // ============================
                // RECENT LOCATIONS
                // ============================

                if (_searchController
                    .text.isEmpty) ...[
                  const Text(
                    'Recent Locations',
                    style: AppStyles.title,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  ...recentLocations.map(
                    (location) => Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.history,
                        ),
                        title: Text(location),
                        onTap: () =>
                            _saveLocation(
                          location,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                ],

                // ============================
                // POPULAR LOCATIONS
                // ============================

                const Text(
                  'Popular Locations',
                  style: AppStyles.title,
                ),

                const SizedBox(height: 12),

                ...filteredLocations.map(
                  (location) => Card(
                    elevation: 0,
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color:
                            AppColors.primary,
                      ),
                      title: Text(location),
                      trailing:
                          selectedLocation ==
                                  location
                              ? const Icon(
                                  Icons.check_circle,
                                  color:
                                      Colors.green,
                                )
                              : null,
                      onTap: () =>
                          _saveLocation(
                        location,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // ============================
                // MAP PICKER BUTTON
                // ============================

                ElevatedButton.icon(
                  style:
                      AppStyles.primaryButton,
                  onPressed: () {
                    // Navigate to Map Picker
                    // Navigator.push(...)
                  },
                  icon: const Icon(
                    Icons.map,
                  ),
                  label: const Text(
                    'Select On Map',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}