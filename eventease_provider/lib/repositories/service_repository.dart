import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceRepository {
  ServiceRepository._();

  static final ServiceRepository _instance =
      ServiceRepository._();

  static ServiceRepository get instance =>
      _instance;

  final ServiceService _serviceService =
      ServiceService.instance;

  // =========================
  // CREATE SERVICE
  // =========================

  Future<ServiceModel> createService({
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _serviceService.createService(
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET MY SERVICES
  // =========================

  Future<List<ServiceModel>>
      getMyServices() async {
    try {
      return await _serviceService
          .getMyServices();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET SERVICE BY ID
  // =========================

  Future<ServiceModel> getServiceById(
    String serviceId,
  ) async {
    try {
      return await _serviceService
          .getServiceById(serviceId);
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // UPDATE SERVICE
  // =========================

  Future<ServiceModel> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _serviceService.updateService(
        serviceId: serviceId,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // DELETE SERVICE
  // =========================

  Future<bool> deleteService(
    String serviceId,
  ) async {
    try {
      return await _serviceService
          .deleteService(serviceId);
    } catch (e) {
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
      return await _serviceService
          .activateService(serviceId);
    } catch (e) {
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
      return await _serviceService
          .deactivateService(serviceId);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // SEARCH SERVICES
  // =========================

  Future<List<ServiceModel>>
      searchServices({
    required String keyword,
  }) async {
    try {
      return await _serviceService
          .searchServices(
        keyword: keyword,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // SERVICES BY CATEGORY
  // =========================

  Future<List<ServiceModel>>
      getServicesByCategory(
    String categoryId,
  ) async {
    try {
      return await _serviceService
          .getServicesByCategory(
        categoryId,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // FEATURED SERVICES
  // =========================

  Future<List<ServiceModel>>
      getFeaturedServices() async {
    try {
      return await _serviceService
          .getFeaturedServices();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // UPLOAD SERVICE IMAGES
  // =========================

  Future<List<String>>
      uploadServiceImages({
    required List<String> imageUrls,
  }) async {
    try {
      return await _serviceService
          .uploadServiceImages(
        imageUrls: imageUrls,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // REMOVE SERVICE IMAGE
  // =========================

  Future<bool> removeServiceImage({
    required String serviceId,
    required String imageUrl,
  }) async {
    try {
      return await _serviceService
          .removeServiceImage(
        serviceId: serviceId,
        imageUrl: imageUrl,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // UPDATE SERVICE PRICE
  // =========================

  Future<bool> updateServicePrice({
    required String serviceId,
    required double price,
    double? discountedPrice,
  }) async {
    try {
      return await _serviceService
          .updateServicePrice(
        serviceId: serviceId,
        price: price,
        discountedPrice:
            discountedPrice,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // GET SERVICE ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getServiceAnalytics(
    String serviceId,
  ) async {
    try {
      return await _serviceService
          .getServiceAnalytics(
        serviceId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // TOTAL SERVICE COUNT
  // =========================

  Future<int> getTotalServiceCount() async {
    try {
      return await _serviceService
          .getTotalServiceCount();
    } catch (e) {
      return 0;
    }
  }
}