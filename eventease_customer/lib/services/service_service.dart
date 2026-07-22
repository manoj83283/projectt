import '../models/service_model.dart';
import 'api_service.dart';

class ServiceService {
  ServiceService._();

  static final ServiceService instance =
      ServiceService._();

  // ==========================================
  // GET ALL SERVICES
  // ==========================================

  Future<List<ServiceModel>> getServices({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? keyword,
  }) async {
    final response =
        await ApiService.instance.get(
      '/services',
      queryParameters: {
        'page': page,
        'limit': limit,
        'categoryId': categoryId,
        'keyword': keyword,
      },
    );

    final List services =
        response.data['data'] ??
            response.data['services'] ??
            [];

    return services
        .map(
          (e) => ServiceModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET SERVICE BY ID
  // ==========================================

  Future<ServiceModel> getServiceById(
    String serviceId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/services/$serviceId',
    );

    return ServiceModel.fromMap(
      response.data['data'] ??
          response.data['service'],
    );
  }

  // ==========================================
  // FEATURED SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getFeaturedServices() async {
    final response =
        await ApiService.instance.get(
      '/services/featured',
    );

    final List services =
        response.data['data'] ??
            response.data['services'] ??
            [];

    return services
        .map(
          (e) => ServiceModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // POPULAR SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getPopularServices() async {
    final response =
        await ApiService.instance.get(
      '/services/popular',
    );

    final List services =
        response.data['data'] ??
            response.data['services'] ??
            [];

    return services
        .map(
          (e) => ServiceModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // SEARCH SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      searchServices(
    String keyword,
  ) async {
    final response =
        await ApiService.instance.get(
      '/services/search',
      queryParameters: {
        'keyword': keyword,
      },
    );

    final List services =
        response.data['data'] ??
            response.data['services'] ??
            [];

    return services
        .map(
          (e) => ServiceModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // CATEGORY SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getServicesByCategory(
    String categoryId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/services/category/$categoryId',
    );

    final List services =
        response.data['data'] ??
            response.data['services'] ??
            [];

    return services
        .map(
          (e) => ServiceModel.fromMap(e),
        )
        .toList();
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
    final response =
        await ApiService.instance.get(
      '/services/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );

    final List services =
        response.data['data'] ??
            response.data['services'] ??
            [];

    return services
        .map(
          (e) => ServiceModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // CREATE SERVICE
  // ==========================================

  Future<ServiceModel> createService({
    required String name,
    required String description,
    required String categoryId,
    required double price,
    List<String> gallery = const [],
    bool isFeatured = false,
  }) async {
    final response =
        await ApiService.instance.post(
      '/services',
      data: {
        'name': name,
        'description': description,
        'categoryId': categoryId,
        'price': price,
        'gallery': gallery,
        'isFeatured': isFeatured,
      },
    );

    return ServiceModel.fromMap(
      response.data['data'] ??
          response.data['service'],
    );
  }

  // ==========================================
  // UPDATE SERVICE
  // ==========================================

  Future<ServiceModel> updateService({
    required String serviceId,
    String? name,
    String? description,
    double? price,
    bool? isAvailable,
    bool? isFeatured,
  }) async {
    final response =
        await ApiService.instance.put(
      '/services/$serviceId',
      data: {
        'name': name,
        'description': description,
        'price': price,
        'isAvailable': isAvailable,
        'isFeatured': isFeatured,
      },
    );

    return ServiceModel.fromMap(
      response.data['data'] ??
          response.data['service'],
    );
  }

  // ==========================================
  // DELETE SERVICE
  // ==========================================

  Future<bool> deleteService(
    String serviceId,
  ) async {
    await ApiService.instance.delete(
      '/services/$serviceId',
    );

    return true;
  }

  // ==========================================
  // HOME SERVICES
  // ==========================================

  Future<List<ServiceModel>>
      getHomeServices() async {
    final response =
        await ApiService.instance.get(
      '/services/home',
    );

    final List services =
        response.data['data'] ??
            response.data['services'] ??
            [];

    return services
        .map(
          (e) => ServiceModel.fromMap(e),
        )
        .toList();
  }
}