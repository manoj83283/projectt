import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/storage_helper.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() =>
      _MapPickerScreenState();
}

class _MapPickerScreenState
    extends State<MapPickerScreen> {
  GoogleMapController? _mapController;

  LatLng _selectedLocation =
      const LatLng(
    17.3850,
    78.4867,
  ); // Hyderabad

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _updateMarker();
  }

  void _updateMarker() {
    _markers.clear();

    _markers.add(
      Marker(
        markerId:
            const MarkerId("selected"),
        position: _selectedLocation,
        draggable: true,
        onDragEnd: (position) {
          setState(() {
            _selectedLocation = position;
            _updateMarker();
          });
        },
      ),
    );

    setState(() {});
  }

  Future<void> _saveLocation() async {
    await StorageHelper.saveLocation(
      latitude:
          _selectedLocation.latitude,
      longitude:
          _selectedLocation.longitude,
      address: "Selected From Map",
    );

    if (!mounted) return;

    Navigator.pop(
      context,
      {
        "latitude":
            _selectedLocation.latitude,
        "longitude":
            _selectedLocation.longitude,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Pick Location",
        ),
      ),

      body: Stack(
        children: [
          // =====================
          // GOOGLE MAP
          // =====================

          GoogleMap(
            initialCameraPosition:
                CameraPosition(
              target:
                  _selectedLocation,
              zoom: 15,
            ),

            markers: _markers,

            myLocationEnabled: true,

            myLocationButtonEnabled:
                true,

            zoomControlsEnabled:
                true,

            onMapCreated:
                (controller) {
              _mapController =
                  controller;
            },

            onTap: (LatLng position) {
              setState(() {
                _selectedLocation =
                    position;

                _updateMarker();
              });
            },
          ),

          // =====================
          // LOCATION CARD
          // =====================

          Positioned(
            left: 16,
            right: 16,
            bottom: 100,
            child: Card(
              elevation: 5,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      "Selected Location",
                      style:
                          AppStyles.title,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      "Latitude : ${_selectedLocation.latitude.toStringAsFixed(6)}",
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      "Longitude : ${_selectedLocation.longitude.toStringAsFixed(6)}",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // =====================
          // SAVE BUTTON
          // =====================

          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                style:
                    AppStyles.primaryButton,
                onPressed:
                    _saveLocation,
                icon: const Icon(
                  Icons.check_circle,
                ),
                label: const Text(
                  "Confirm Location",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}