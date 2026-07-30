import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/service_model.dart';

class ServiceService {
  ServiceService._();

  static final ServiceService _instance =
      ServiceService._();

  static ServiceService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // CREATE SERVICE
  // =========================

  Future<ServiceModel> createService({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.post(
        '/provider/services',
        body: data,
      );

      return ServiceModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Create Service Error: $e');
      rethrow;
    }
  }

  // =========================
  // GET MY SERVICES
  // =========================

  Future<List<ServiceModel>>
      getMyServices() async {
    try {
      final response = await _apiService.get(
        '/provider/services',
      );

      final List<dynamic> services =
          response['data'] ?? [];

      return services
          .map(
            (json) =>
                ServiceModel.fromJson(json),
          )
          .toList();
    } catch (e) {
      log('Get My Services Error: $e');
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
      final response = await _apiService.get(
        '/provider/services/$serviceId',
      );

      return ServiceModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Get Service By Id Error: $e');
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
      final response = await _apiService.put(
        '/provider/services/$serviceId',
        body: data,
      );

      return ServiceModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Update Service Error: $e');
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
      await _apiService.delete(
        '/provider/services/$serviceId',
      );

      return true;
    } catch (e) {
      log('Delete Service Error: $e');
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
      await _apiService.patch(
        '/provider/services/$serviceId/status',
        body: {
          'isActive': true,
        },
      );

      return true;
    } catch (e) {
      log('Activate Service Error: $e');
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
      await _apiService.patch(
        '/provider/services/$serviceId/status',
        body: {
          'isActive': false,
        },
      );

      return true;
    } catch (e) {
      log('Deactivate Service Error: $e');
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
      final response = await _apiService.get(
        '/provider/services/search?keyword=$keyword',
      );

      final List<dynamic> services =
          response['data'] ?? [];

      return services
          .map(
            (e) =>
                ServiceModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Search Service Error: $e');
      return [];
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
      final response = await _apiService.get(
        '/provider/services/category/$categoryId',
      );

      final List<dynamic> services =
          response['data'] ?? [];

      return services
          .map(
            (e) =>
                ServiceModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log(
        'Get Services By Category Error: $e',
      );
      return [];
    }
  }

  // =========================
  // GET FEATURED SERVICES
  // =========================

  Future<List<ServiceModel>>
      getFeaturedServices() async {
    try {
      final response = await _apiService.get(
        '/provider/services/featured',
      );

      final List<dynamic> services =
          response['data'] ?? [];

      return services
          .map(
            (e) =>
                ServiceModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log(
        'Get Featured Services Error: $e',
      );
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
      final response = await _apiService.post(
        '/provider/services/upload-images',
        body: {
          'images': imageUrls,
        },
      );

      return List<String>.from(
        response['data'] ?? [],
      );
    } catch (e) {
      log(
        'Upload Service Images Error: $e',
      );
      rethrow;
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
      await _apiService.delete(
        '/provider/services/$serviceId/image',
        body: {
          'imageUrl': imageUrl,
        },
      );

      return true;
    } catch (e) {
      log(
        'Remove Service Image Error: $e',
      );
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
      await _apiService.patch(
        '/provider/services/$serviceId/price',
        body: {
          'price': price,
          'discountedPrice':
              discountedPrice,
        },
      );

      return true;
    } catch (e) {
      log(
        'Update Service Price Error: $e',
      );
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
      return await _apiService.get(
        '/provider/services/$serviceId/analytics',
      );
    } catch (e) {
      log(
        'Get Service Analytics Error: $e',
      );
      rethrow;
    }
  }

  // =========================
  // GET TOTAL SERVICE COUNT
  // =========================

  Future<int> getTotalServiceCount() async {
    try {
      final response = await _apiService.get(
        '/provider/services/count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      log(
        'Get Total Service Count Error: $e',
      );
      return 0;
    }
  }
}