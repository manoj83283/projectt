import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../repositories/location_repository.dart';

class LocationProvider extends ChangeNotifier {
  LocationProvider();

  final LocationRepository _repository =
      LocationRepository.instance;

  LocationModel? _currentLocation;

  List<LocationModel> _savedLocations = [];
  List<LocationModel> _searchResults = [];
  List<dynamic> _nearbyProviders = [];
  List<dynamic> _nearbyServices = [];

  bool _isLoading = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  LocationModel? get currentLocation =>
      _currentLocation;

  List<LocationModel> get savedLocations =>
      _savedLocations;

  List<LocationModel> get searchResults =>
      _searchResults;

  List<dynamic> get nearbyProviders =>
      _nearbyProviders;

  List<dynamic> get nearbyServices =>
      _nearbyServices;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // ==========================================
  // SET LOADING
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // SET ERROR
  // ==========================================

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ==========================================
  // CURRENT LOCATION
  // ==========================================

  Future<void> getCurrentLocation() async {
    try {
      _setLoading(true);
      _setError(null);

      _currentLocation =
          await _repository.getCurrentLocation();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // REVERSE GEOCODE
  // ==========================================

  Future<Map<String, dynamic>>
      reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _repository.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // SEARCH LOCATION
  // ==========================================

  Future<void> searchLocation(
    String keyword,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _searchResults =
          await _repository.searchLocation(
        keyword,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SAVE LOCATION
  // ==========================================

  Future<bool> saveLocation({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      _setLoading(true);

      final location =
          await _repository.saveLocation(
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );

      _savedLocations.insert(
        0,
        location,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SAVED LOCATIONS
  // ==========================================

  Future<void> getSavedLocations() async {
    try {
      _setLoading(true);
      _setError(null);

      _savedLocations =
          await _repository.getSavedLocations();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // DELETE LOCATION
  // ==========================================

  Future<bool> deleteLocation(
    String locationId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.deleteLocation(
        locationId,
      );

      if (success) {
        _savedLocations.removeWhere(
          (e) => e.id == locationId,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // NEARBY PROVIDERS
  // ==========================================

  Future<void> getNearbyProviders({
    required double latitude,
    required double longitude,
    double radius = 20,
    String? categoryId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _nearbyProviders =
          await _repository.getNearbyProviders(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        categoryId: categoryId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // NEARBY SERVICES
  // ==========================================

  Future<void> getNearbyServices({
    required double latitude,
    required double longitude,
    double radius = 20,
    String? categoryId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _nearbyServices =
          await _repository.getNearbyServices(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        categoryId: categoryId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
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
    try {
      return await _repository.calculateDistance(
        originLat: originLat,
        originLng: originLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // SERVICE AREA CHECK
  // ==========================================

  Future<bool> isServiceAvailable({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _repository.isServiceAvailable(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // TRACK PROVIDER
  // ==========================================

  Future<Map<String, dynamic>>
      trackProvider(
    String providerId,
  ) async {
    try {
      return await _repository.trackProvider(
        providerId,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // UPDATE LOCATION
  // ==========================================

  Future<bool> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      _setLoading(true);

      return await _repository.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CLEAR SEARCH RESULT
  // ==========================================

  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==========================================
  // RESET
  // ==========================================

  void reset() {
    _currentLocation = null;

    _savedLocations.clear();
    _searchResults.clear();
    _nearbyProviders.clear();
    _nearbyServices.clear();

    _error = null;

    notifyListeners();
  }
}