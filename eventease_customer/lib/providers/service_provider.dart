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
  List<ServiceModel> _recommendedServices = [];
  List<ServiceModel> _nearbyServices = [];

  ServiceModel? _selectedService;

  bool _isLoading = false;
  String? _error;

  // =====================================================
  // GETTERS
  // =====================================================

  List<ServiceModel> get services => _services;

  List<ServiceModel> get featuredServices =>
      _featuredServices;

  List<ServiceModel> get popularServices =>
      _popularServices;

  List<ServiceModel> get recommendedServices =>
      _recommendedServices;

  List<ServiceModel> get nearbyServices =>
      _nearbyServices;

  ServiceModel? get selectedService =>
      _selectedService;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasError =>
      _error != null && _error!.isNotEmpty;

  bool get hasServices => _services.isNotEmpty;

  // =====================================================
  // INTERNAL HELPERS
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // =====================================================
  // LOAD SERVICES
  // =====================================================

  Future<void> getServices({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? radius,
    String? sort,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _services = await _repository.getServices(
        page: page,
        limit: limit,
        category: category,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        sort: sort,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH SERVICES
  // =====================================================

  Future<void> refreshServices() async {
    await getServices(
      page: 1,
      limit: 100,
      sort: 'newest',
    );
  }

  // =====================================================
  // HOME SERVICES
  // =====================================================

  Future<void> getHomeServices() async {
    try {
      _setLoading(true);
      _setError(null);

      _services =
          await _repository.getHomeServices();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SERVICE DETAILS
  // =====================================================

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
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // FEATURED SERVICES
  // =====================================================

  Future<void> getFeaturedServices() async {
    try {
      _setLoading(true);
      _setError(null);

      _featuredServices =
          await _repository.getFeaturedServices();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // POPULAR SERVICES
  // =====================================================

  Future<void> getPopularServices() async {
    try {
      _setLoading(true);
      _setError(null);

      _popularServices =
          await _repository.getPopularServices();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // RECOMMENDED SERVICES
  // =====================================================

  Future<void> getRecommendedServices() async {
    try {
      _setLoading(true);
      _setError(null);

      _recommendedServices =
          await _repository
              .getRecommendedServices();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // TOP RATED SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getTopRatedServices() async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .getTopRatedServices();
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // NEARBY SERVICES
  // =====================================================

  Future<void> getNearbyServices({
    required double latitude,
    required double longitude,
    double radius = 30000,
    String? category,
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
        category: category,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEARCH SERVICES
  // =====================================================

  Future<List<ServiceModel>> searchServices(
    String keyword,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository.searchServices(
        keyword,
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // ADVANCED SEARCH
  // =====================================================

  Future<List<ServiceModel>>
      searchServicesByKeyword({
    required String keyword,
    String? category,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .searchServicesByKeyword(
        keyword: keyword,
        category: category,
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CATEGORY SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getServicesByCategory(
    String category,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .getServicesByCategory(
        category,
      );
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // PROVIDER SERVICES
  // =====================================================

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

  // =====================================================
  // CHECK AVAILABILITY
  // =====================================================

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

  // =====================================================
  // REVIEWS
  // =====================================================

  Future<dynamic> getServiceReviews(
    String serviceId,
  ) async {
    try {
      return await _repository
          .getServiceReviews(
        serviceId,
      );
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // =====================================================
  // ANALYTICS
  // =====================================================

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

  // =====================================================
  // SELECT SERVICE
  // =====================================================

  void setSelectedService(
    ServiceModel service,
  ) {
    _selectedService = service;
    notifyListeners();
  }

  // =====================================================
  // CLEAR SELECTED SERVICE
  // =====================================================

  void clearSelectedService() {
    _selectedService = null;
    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // =====================================================
  // RESET
  // =====================================================

  void reset() {
    _services = [];
    _featuredServices = [];
    _popularServices = [];
    _recommendedServices = [];
    _nearbyServices = [];

    _selectedService = null;
    _error = null;

    notifyListeners();
  }
}