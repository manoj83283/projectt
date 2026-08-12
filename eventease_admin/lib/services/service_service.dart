import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class ServiceService {
  ServiceService._();

  static final ServiceService _instance =
      ServiceService._();

  factory ServiceService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL SERVICES
  // =====================================================

  Future<Map<String, dynamic>> getServices({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    String? providerId,
    String? status,
    bool? isActive,
  }) async {
    try {
      final response = await _api.get(
        '/admin/services',
        query: {
          'page': page,
          'limit': limit,
          'search': ?search,
          'categoryId': ?categoryId,
          'providerId': ?providerId,
          'status': ?status,
          'isActive': ?isActive,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET SERVICE DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getServiceDetails(
    String serviceId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/services/$serviceId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CREATE SERVICE
  // =====================================================

  Future<Map<String, dynamic>>
      createService({
    required String name,
    required String description,
    required String categoryId,
    required String providerId,
    required double price,
    List<String>? images,
    bool isActive = true,
  }) async {
    try {
      final response = await _api.post(
        '/admin/services',
        data: {
          'name': name,
          'description': description,
          'categoryId': categoryId,
          'providerId': providerId,
          'price': price,
          'images': images ?? [],
          'isActive': isActive,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // UPDATE SERVICE
  // =====================================================

  Future<Map<String, dynamic>>
      updateService({
    required String serviceId,
    String? name,
    String? description,
    String? categoryId,
    double? price,
    List<String>? images,
    bool? isActive,
  }) async {
    try {
      final response = await _api.put(
        '/admin/services/$serviceId',
        data: {
          'name': ?name,
          'description': ?description,
          'categoryId': ?categoryId,
          'price': ?price,
          'images': ?images,
          'isActive': ?isActive,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE SERVICE
  // =====================================================

  Future<bool> deleteService(
    String serviceId,
  ) async {
    try {
      await _api.delete(
        '/admin/services/$serviceId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // APPROVE SERVICE
  // =====================================================

  Future<bool> approveService(
    String serviceId,
  ) async {
    try {
      await _api.patch(
        '/admin/services/$serviceId/approve',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REJECT SERVICE
  // =====================================================

  Future<bool> rejectService({
    required String serviceId,
    required String reason,
  }) async {
    try {
      await _api.patch(
        '/admin/services/$serviceId/reject',
        data: {
          'reason': reason,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ACTIVATE SERVICE
  // =====================================================

  Future<bool> activateService(
    String serviceId,
  ) async {
    try {
      await _api.patch(
        '/admin/services/$serviceId/activate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DEACTIVATE SERVICE
  // =====================================================

  Future<bool> deactivateService(
    String serviceId,
  ) async {
    try {
      await _api.patch(
        '/admin/services/$serviceId/deactivate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // FEATURE SERVICE
  // =====================================================

  Future<bool> featureService(
    String serviceId,
  ) async {
    try {
      await _api.patch(
        '/admin/services/$serviceId/feature',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REMOVE FEATURED
  // =====================================================

  Future<bool> removeFeatured(
    String serviceId,
  ) async {
    try {
      await _api.patch(
        '/admin/services/$serviceId/remove-featured',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SERVICE REVIEWS
  // =====================================================

  Future<List<dynamic>>
      getServiceReviews(
    String serviceId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/services/$serviceId/reviews',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SERVICE BOOKINGS
  // =====================================================

  Future<List<dynamic>>
      getServiceBookings(
    String serviceId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/services/$serviceId/bookings',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SERVICE ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getServiceAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/services/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // TOP SERVICES
  // =====================================================

  Future<List<dynamic>>
      getTopServices() async {
    try {
      final response = await _api.get(
        '/admin/services/top',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH SERVICES
  // =====================================================

  Future<List<dynamic>>
      searchServices(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/services/search',
        query: {
          'keyword': keyword,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SERVICE STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getServiceStatistics() async {
    try {
      final response = await _api.get(
        '/admin/services/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT SERVICES
  // =====================================================

  Future<Response<dynamic>>
      exportServices({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/services/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK DELETE SERVICES
  // =====================================================

  Future<bool> bulkDeleteServices(
    List<String> serviceIds,
  ) async {
    try {
      await _api.post(
        '/admin/services/bulk-delete',
        data: {
          'serviceIds': serviceIds,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK STATUS UPDATE
  // =====================================================

  Future<bool> bulkStatusUpdate({
    required List<String> serviceIds,
    required bool isActive,
  }) async {
    try {
      await _api.post(
        '/admin/services/bulk-status',
        data: {
          'serviceIds': serviceIds,
          'isActive': isActive,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ERROR HANDLER
  // =====================================================

  String _parseError(
    DioException e,
  ) {
    return e.response?.data?['message']
            ?.toString() ??
        e.message ??
        'Something went wrong';
  }
}