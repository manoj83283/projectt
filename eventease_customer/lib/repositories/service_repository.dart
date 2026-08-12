import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceRepository {
  ServiceRepository._();

  static final ServiceRepository instance =
      ServiceRepository._();

  final ServiceService _serviceService =
      ServiceService.instance;

  // =====================================================
  // GET ALL SERVICES
  // =====================================================

  Future<List<ServiceModel>> getServices({
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
    return await _serviceService.getServices(
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
  }

  // =====================================================
  // GET SERVICE BY ID
  // =====================================================

  Future<ServiceModel> getServiceById(
    String serviceId,
  ) async {
    return await _serviceService.getServiceById(
      serviceId,
    );
  }

  // =====================================================
  // FEATURED SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getFeaturedServices() async {
    return await _serviceService
        .getFeaturedServices();
  }

  // =====================================================
  // POPULAR SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getPopularServices() async {
    return await _serviceService
        .getPopularServices();
  }

  // =====================================================
  // RECOMMENDED SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getRecommendedServices() async {
    return await _serviceService
        .getRecommendedServices();
  }

  // =====================================================
  // HOME SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getHomeServices() async {
    return await _serviceService
        .getHomeServices();
  }

  // =====================================================
  // TOP RATED SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getTopRatedServices() async {
    return await _serviceService
        .getTopRatedServices();
  }

  // =====================================================
  // SEARCH SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      searchServices(
    String keyword,
  ) async {
    return await _serviceService.searchServices(
      keyword,
    );
  }

  // =====================================================
  // SEARCH SERVICES WITH CATEGORY
  // =====================================================

  Future<List<ServiceModel>>
      searchServicesByKeyword({
    required String keyword,
    String? category,
  }) async {
    return await _serviceService
        .searchServicesByKeyword(
      keyword: keyword,
      category: category,
    );
  }

  // =====================================================
  // SERVICES BY CATEGORY
  // =====================================================

  Future<List<ServiceModel>>
      getServicesByCategory(
    String category,
  ) async {
    return await _serviceService
        .getServicesByCategory(
      category,
    );
  }

  // =====================================================
  // NEARBY SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getNearbyServices({
    required double latitude,
    required double longitude,
    double radius = 30000,
    String? category,
  }) async {
    return await _serviceService
        .getNearbyServices(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      category: category,
    );
  }

  // =====================================================
  // PROVIDER SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getProviderServices(
    String providerId,
  ) async {
    return await _serviceService
        .getProviderServices(
      providerId,
    );
  }

  // =====================================================
  // SERVICE AVAILABILITY
  // =====================================================

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

  // =====================================================
  // SERVICE REVIEWS
  // =====================================================

  Future<dynamic> getServiceReviews(
    String serviceId,
  ) async {
    return await _serviceService
        .getServiceReviews(
      serviceId,
    );
  }

  // =====================================================
  // SERVICE ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getServiceAnalytics(
    String serviceId,
  ) async {
    return await _serviceService
        .getServiceAnalytics(
      serviceId,
    );
  }

  // =====================================================
  // REFRESH SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      refreshServices() async {
    return await _serviceService.getServices(
      page: 1,
      limit: 100,
      sort: 'newest',
    );
  }
}