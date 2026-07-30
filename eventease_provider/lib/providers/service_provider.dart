import 'package:flutter/foundation.dart';

import '../models/service_model.dart';
import '../repositories/service_repository.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _repository =
      ServiceRepository.instance;

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;

  String? _errorMessage;

  List<ServiceModel> _services = [];

  List<ServiceModel> _featuredServices = [];

  ServiceModel? _selectedService;

  Map<String, dynamic> _analytics = {};

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<ServiceModel> get services =>
      _services;

  List<ServiceModel> get featuredServices =>
      _featuredServices;

  ServiceModel? get selectedService =>
      _selectedService;

  Map<String, dynamic> get analytics =>
      _analytics;

  // =========================
  // HELPERS
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // CREATE SERVICE
  // =========================

  Future<bool> createService({
    required Map<String, dynamic> data,
  }) async {
    try {
      _setLoading(true);

      final service =
          await _repository.createService(
        data: data,
      );

      _services.insert(0, service);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET MY SERVICES
  // =========================

  Future<void> getMyServices() async {
    try {
      _setLoading(true);

      _services =
          await _repository.getMyServices();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET SERVICE BY ID
  // =========================

  Future<ServiceModel?> getServiceById(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      _selectedService =
          await _repository.getServiceById(
        serviceId,
      );

      notifyListeners();

      return _selectedService;
    } catch (e) {
      _errorMessage = e.toString();

      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // UPDATE SERVICE
  // =========================

  Future<bool> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _setLoading(true);

      final updatedService =
          await _repository.updateService(
        serviceId: serviceId,
        data: data,
      );

      final index = _services.indexWhere(
        (service) =>
            service.id == serviceId,
      );

      if (index != -1) {
        _services[index] =
            updatedService;
      }

      if (_selectedService?.id ==
          serviceId) {
        _selectedService =
            updatedService;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // DELETE SERVICE
  // =========================

  Future<bool> deleteService(
    String serviceId,
  ) async {
    try {
      final success =
          await _repository.deleteService(
        serviceId,
      );

      if (success) {
        _services.removeWhere(
          (service) =>
              service.id == serviceId,
        );

        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    }
  }

  // =========================
  // ACTIVATE SERVICE
  // =========================

  Future<bool> activateService(
    String serviceId,
  ) async {
    try {
      final success =
          await _repository.activateService(
        serviceId,
      );

      if (success) {
        await getMyServices();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    }
  }

  // =========================
  // DEACTIVATE SERVICE
  // =========================

  Future<bool> deactivateService(
    String serviceId,
  ) async {
    try {
      final success =
          await _repository
              .deactivateService(
        serviceId,
      );

      if (success) {
        await getMyServices();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    }
  }

  // =========================
  // SEARCH SERVICES
  // =========================

  Future<List<ServiceModel>>
      searchServices(
    String keyword,
  ) async {
    try {
      return await _repository
          .searchServices(
        keyword: keyword,
      );
    } catch (e) {
      _errorMessage = e.toString();

      return [];
    }
  }

  // =========================
  // GET FEATURED SERVICES
  // =========================

  Future<void>
      getFeaturedServices() async {
    try {
      _featuredServices =
          await _repository
              .getFeaturedServices();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // GET SERVICES BY CATEGORY
  // =========================

  Future<List<ServiceModel>>
      getServicesByCategory(
    String categoryId,
  ) async {
    try {
      return await _repository
          .getServicesByCategory(
        categoryId,
      );
    } catch (e) {
      _errorMessage = e.toString();

      return [];
    }
  }

  // =========================
  // UPLOAD IMAGES
  // =========================

  Future<List<String>>
      uploadServiceImages({
    required List<String> imageUrls,
  }) async {
    try {
      return await _repository
          .uploadServiceImages(
        imageUrls: imageUrls,
      );
    } catch (e) {
      _errorMessage = e.toString();

      return [];
    }
  }

  // =========================
  // REMOVE IMAGE
  // =========================

  Future<bool> removeServiceImage({
    required String serviceId,
    required String imageUrl,
  }) async {
    try {
      return await _repository
          .removeServiceImage(
        serviceId: serviceId,
        imageUrl: imageUrl,
      );
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    }
  }

  // =========================
  // UPDATE PRICE
  // =========================

  Future<bool> updateServicePrice({
    required String serviceId,
    required double price,
    double? discountedPrice,
  }) async {
    try {
      return await _repository
          .updateServicePrice(
        serviceId: serviceId,
        price: price,
        discountedPrice:
            discountedPrice,
      );
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    }
  }

  // =========================
  // SERVICE ANALYTICS
  // =========================

  Future<void> getServiceAnalytics(
    String serviceId,
  ) async {
    try {
      _analytics =
          await _repository
              .getServiceAnalytics(
        serviceId,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // TOTAL SERVICE COUNT
  // =========================

  Future<int>
      getTotalServiceCount() async {
    try {
      return await _repository
          .getTotalServiceCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // REFRESH ALL
  // =========================

  Future<void> refreshData() async {
    await Future.wait([
      getMyServices(),
      getFeaturedServices(),
    ]);
  }
}