import '../models/location_model.dart';
import 'api_service.dart';

class LocationService {
  LocationService._();

  static final LocationService instance =
      LocationService._();

  // ==========================================
  // CURRENT LOCATION
  // ==========================================

  Future<LocationModel> getCurrentLocation() async {
    final response =
        await ApiService.instance.get(
      '/locations/current',
    );

    return LocationModel.fromMap(
      response.data['data'] ??
          response.data['location'],
    );
  }

  // ==========================================
  // REVERSE GEOCODE
  // ==========================================

  Future<Map<String, dynamic>>
      reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final response =
        await ApiService.instance.post(
      '/locations/reverse-geocode',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // SEARCH LOCATION
  // ==========================================

  Future<List<LocationModel>>
      searchLocation(
    String keyword,
  ) async {
    final response =
        await ApiService.instance.get(
      '/locations/search',
      queryParameters: {
        'keyword': keyword,
      },
    );

    final List locations =
        response.data['data'] ??
            response.data['locations'] ??
            [];

    return locations
        .map(
          (e) => LocationModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // SAVE LOCATION
  // ==========================================

  Future<LocationModel> saveLocation({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final response =
        await ApiService.instance.post(
      '/locations',
      data: {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return LocationModel.fromMap(
      response.data['data'] ??
          response.data['location'],
    );
  }

  // ==========================================
  // SAVED LOCATIONS
  // ==========================================

  Future<List<LocationModel>>
      getSavedLocations() async {
    final response =
        await ApiService.instance.get(
      '/locations',
    );

    final List locations =
        response.data['data'] ??
            response.data['locations'] ??
            [];

    return locations
        .map(
          (e) => LocationModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // DELETE LOCATION
  // ==========================================

  Future<bool> deleteLocation(
    String locationId,
  ) async {
    await ApiService.instance.delete(
      '/locations/$locationId',
    );

    return true;
  }

  // ==========================================
  // NEARBY PROVIDERS
  // ==========================================

  Future<List<dynamic>>
      getNearbyProviders({
    required double latitude,
    required double longitude,
    double radius = 20,
    String? categoryId,
  }) async {
    final response =
        await ApiService.instance.get(
      '/locations/nearby-providers',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'categoryId': categoryId,
      },
    );

    return response.data['data'] ??
        response.data['providers'] ??
        [];
  }

  // ==========================================
  // NEARBY SERVICES
  // ==========================================

  Future<List<dynamic>>
      getNearbyServices({
    required double latitude,
    required double longitude,
    double radius = 20,
    String? categoryId,
  }) async {
    final response =
        await ApiService.instance.get(
      '/locations/nearby-services',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'categoryId': categoryId,
      },
    );

    return response.data['data'] ??
        response.data['services'] ??
        [];
  }

  // ==========================================
  // CALCULATE DISTANCE
  // ==========================================

  Future<Map<String, dynamic>>
      calculateDistance({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final response =
        await ApiService.instance.post(
      '/locations/distance',
      data: {
        'originLat': originLat,
        'originLng': originLng,
        'destinationLat':
            destinationLat,
        'destinationLng':
            destinationLng,
      },
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // SERVICE AREA CHECK
  // ==========================================

  Future<bool> isServiceAvailable({
    required double latitude,
    required double longitude,
  }) async {
    final response =
        await ApiService.instance.post(
      '/locations/check-service-area',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return response.data['available'] ??
        response.data['data']
            ?['available'] ??
        false;
  }

  // ==========================================
  // PROVIDER LIVE TRACKING
  // ==========================================

  Future<Map<String, dynamic>>
      trackProvider(
    String providerId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/locations/provider/$providerId',
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // UPDATE USER LOCATION
  // ==========================================

  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await ApiService.instance.patch(
      '/locations/update',
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return true;
  }
}