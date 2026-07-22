import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceRepository {
  ServiceRepository._();

  static final ServiceRepository instance =
      ServiceRepository._();

  final ServiceService _serviceService =
      ServiceService.instance;

  // ==========================================
  // GET ALL SERVICES
  // ==========================================

  Future<List<ServiceModel>> getServices({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? search,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    return await _serviceService.getServices(
      page: page,
      limit: limit,
      categoryId: categoryId,
      search: search,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }

  // ==========================================
  // GET SERVICE BY ID
  // ==========================================

  Future<ServiceModel> getServiceById(
    String serviceId,
  ) async {
    return await _serviceService.getServiceById(
      serviceId,
    );
  }

  // ==========================================
  // FEATURED SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getFeaturedServices() async {
    return await _serviceService
        .getFeaturedServices();
  }

  // ==========================================
  // POPULAR SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getPopularServices() async {
    return await _serviceService
        .getPopularServices();
  }

  // ==========================================
  // NEARBY SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getNearbyServices({
    required double latitude,
    required double longitude,
    double radius = 20,
  }) async {
    return await _serviceService
        .getNearbyServices(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }

  // ==========================================
  // SEARCH SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      searchServices(
    String keyword,
  ) async {
    return await _serviceService
        .searchServices(keyword);
  }

  // ==========================================
  // CATEGORY SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getServicesByCategory(
    String categoryId,
  ) async {
    return await _serviceService
        .getServicesByCategory(
      categoryId,
    );
  }

  // ==========================================
  // PROVIDER SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getProviderServices(
    String providerId,
  ) async {
    return await _serviceService
        .getProviderServices(
      providerId,
    );
  }

  // ==========================================
  // SERVICE AVAILABILITY
  // ==========================================

  Future<Map<String, dynamic>>
      checkAvailability({
    required String serviceId,
    required DateTime bookingDate,
  }) async {
    return await _serviceService
        .checkAvailability(
      serviceId: serviceId,
      bookingDate: bookingDate,
    );
  }

  // ==========================================
  // CREATE SERVICE
  // PROVIDER
  // ==========================================

  Future<ServiceModel> createService({
    required String title,
    required String categoryId,
    required String description,
    required double price,
    List<String>? images,
  }) async {
    return await _serviceService
        .createService(
      title: title,
      categoryId: categoryId,
      description: description,
      price: price,
      images: images,
    );
  }

  // ==========================================
  // UPDATE SERVICE
  // PROVIDER
  // ==========================================

  Future<ServiceModel> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  }) async {
    return await _serviceService
        .updateService(
      serviceId: serviceId,
      data: data,
    );
  }

  // ==========================================
  // DELETE SERVICE
  // PROVIDER
  // ==========================================

  Future<bool> deleteService(
    String serviceId,
  ) async {
    return await _serviceService
        .deleteService(serviceId);
  }

  // ==========================================
  // SERVICE REVIEWS
  // ==========================================

  Future<Map<String, dynamic>>
      getServiceReviews(
    String serviceId,
  ) async {
    return await _serviceService
        .getServiceReviews(serviceId);
  }

  // ==========================================
  // SERVICE ANALYTICS
  // PROVIDER
  // ==========================================

  Future<Map<String, dynamic>>
      getServiceAnalytics(
    String serviceId,
  ) async {
    return await _serviceService
        .getServiceAnalytics(
      serviceId,
    );
  }
}