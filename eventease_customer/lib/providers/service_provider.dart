import 'package:flutter/material.dart';

import '../models/service_model.dart';
import '../repositories/service_repository.dart';

class ServiceProvider extends ChangeNotifier {
  ServiceProvider();

  final ServiceRepository _repository =
      ServiceRepository.instance;

  List<ServiceModel> _services = [];
  List<ServiceModel> _featuredServices = [];
  List<ServiceModel> _popularServices = [];
  List<ServiceModel> _nearbyServices = [];

  ServiceModel? _selectedService;

  bool _isLoading = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  List<ServiceModel> get services =>
      _services;

  List<ServiceModel> get featuredServices =>
      _featuredServices;

  List<ServiceModel> get popularServices =>
      _popularServices;

  List<ServiceModel> get nearbyServices =>
      _nearbyServices;

  ServiceModel? get selectedService =>
      _selectedService;

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
  // GET SERVICES
  // ==========================================

  Future<void> getServices({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _services =
          await _repository.getServices(
        page: page,
        limit: limit,
        categoryId: categoryId,
        search: search,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GET SERVICE DETAILS
  // ==========================================

  Future<void> getServiceById(
    String serviceId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _selectedService =
          await _repository.getServiceById(
        serviceId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // FEATURED SERVICES
  // ==========================================

  Future<void>
      getFeaturedServices() async {
    try {
      _setLoading(true);
      _setError(null);

      _featuredServices =
          await _repository
              .getFeaturedServices();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // POPULAR SERVICES
  // ==========================================

  Future<void>
      getPopularServices() async {
    try {
      _setLoading(true);
      _setError(null);

      _popularServices =
          await _repository
              .getPopularServices();

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
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _nearbyServices =
          await _repository
              .getNearbyServices(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SEARCH SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      searchServices(
    String keyword,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .searchServices(keyword);
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SERVICES BY CATEGORY
  // ==========================================

  Future<List<ServiceModel>>
      getServicesByCategory(
    String categoryId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .getServicesByCategory(
        categoryId,
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // PROVIDER SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getProviderServices(
    String providerId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .getProviderServices(
        providerId,
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CHECK AVAILABILITY
  // ==========================================

  Future<Map<String, dynamic>>
      checkAvailability({
    required String serviceId,
    required DateTime bookingDate,
  }) async {
    try {
      _setLoading(true);

      return await _repository
          .checkAvailability(
        serviceId: serviceId,
        bookingDate: bookingDate,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CREATE SERVICE
  // ==========================================

  Future<bool> createService({
    required String title,
    required String categoryId,
    required String description,
    required double price,
    List<String>? images,
  }) async {
    try {
      _setLoading(true);

      final service =
          await _repository.createService(
        title: title,
        categoryId: categoryId,
        description: description,
        price: price,
        images: images,
      );

      _services.insert(0, service);

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
  // UPDATE SERVICE
  // ==========================================

  Future<bool> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _setLoading(true);

      final updated =
          await _repository.updateService(
        serviceId: serviceId,
        data: data,
      );

      final index = _services.indexWhere(
        (e) => e.id == serviceId,
      );

      if (index != -1) {
        _services[index] = updated;
      }

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
  // DELETE SERVICE
  // ==========================================

  Future<bool> deleteService(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.deleteService(
        serviceId,
      );

      if (success) {
        _services.removeWhere(
          (e) => e.id == serviceId,
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
  // SERVICE ANALYTICS
  // ==========================================

  Future<Map<String, dynamic>>
      getServiceAnalytics(
    String serviceId,
  ) async {
    try {
      return await _repository
          .getServiceAnalytics(
        serviceId,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // SERVICE REVIEWS
  // ==========================================

  Future<Map<String, dynamic>>
      getServiceReviews(
    String serviceId,
  ) async {
    try {
      return await _repository
          .getServiceReviews(
        serviceId,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // SELECT SERVICE
  // ==========================================

  void setSelectedService(
    ServiceModel service,
  ) {
    _selectedService = service;
    notifyListeners();
  }

  // ==========================================
  // CLEAR SERVICE
  // ==========================================

  void clearSelectedService() {
    _selectedService = null;
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
    _services.clear();
    _featuredServices.clear();
    _popularServices.clear();
    _nearbyServices.clear();

    _selectedService = null;
    _error = null;

    notifyListeners();
  }
}