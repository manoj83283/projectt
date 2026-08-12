import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../../utils/storage_helper.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({super.key});

  @override
  State<CurrentLocationScreen> createState() =>
      _CurrentLocationScreenState();
}

class _CurrentLocationScreenState
    extends State<CurrentLocationScreen> {
  bool _isLoading = true;

  String _address = '';
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled.',
        );
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();

        if (permission ==
            LocationPermission.denied) {
          throw Exception(
            'Location permission denied.',
          );
        }
      }

      if (permission ==
          LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied.',
        );
      }

      final position =
          await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      try {
        final placemarks =
            await placemarkFromCoordinates(
          _latitude!,
          _longitude!,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          _address =
              "${place.name ?? ''}, "
              "${place.locality ?? ''}, "
              "${place.administrativeArea ?? ''}, "
              "${place.country ?? ''}";
        }
      } catch (_) {
        _address =
            'Location detected successfully';
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLocation() async {
    if (_latitude == null ||
        _longitude == null) {
      return;
    }

    await StorageHelper.saveLocation(
      latitude: _latitude!,
      longitude: _longitude!,
      address: _address,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Location saved successfully',
        ),
      ),
    );

    Navigator.pop(context, {
      'latitude': _latitude,
      'longitude': _longitude,
      'address': _address,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Current Location',
        ),
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration:
                        BoxDecoration(
                      color: AppColors.primary
                          .withValues(
                        alpha: 0.1,
                      ),
                      shape:
                          BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 70,
                      color:
                          AppColors.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    decoration:
                        AppStyles
                            .cardDecoration,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          'Detected Address',
                          style:
                              AppStyles.title,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          _address.isEmpty
                              ? 'Address not available'
                              : _address,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        const Divider(),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          "Latitude : ${_latitude?.toStringAsFixed(6) ?? '-'}",
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          "Longitude : ${_longitude?.toStringAsFixed(6) ?? '-'}",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child: ElevatedButton.icon(
                      style: AppStyles
                          .primaryButton,
                      onPressed:
                          _saveLocation,
                      icon: const Icon(
                        Icons.save,
                      ),
                      label: const Text(
                        'Save Location',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        OutlinedButton.icon(
                      style: AppStyles
                          .secondaryButton,
                      onPressed:
                          _getCurrentLocation,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: const Text(
                        'Refresh Location',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}