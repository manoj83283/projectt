import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class CategoryService {
  CategoryService._();

  static final CategoryService _instance =
      CategoryService._();

  factory CategoryService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL CATEGORIES
  // =====================================================

  Future<Map<String, dynamic>> getCategories({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    try {
      final response = await _api.get(
        '/admin/categories',
        query: {
          'page': page,
          'limit': limit,
          if (search != null &&
              search.isNotEmpty)
            'search': search,
          if (isActive != null)
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
  // GET CATEGORY DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getCategoryDetails(
    String categoryId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/categories/$categoryId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CREATE CATEGORY
  // =====================================================

  Future<Map<String, dynamic>>
      createCategory({
    required String name,
    required String description,
    String? image,
    String? icon,
    bool isActive = true,
  }) async {
    try {
      final response = await _api.post(
        '/admin/categories',
        data: {
          'name': name,
          'description': description,
          'image': image,
          'icon': icon,
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
  // UPDATE CATEGORY
  // =====================================================

  Future<Map<String, dynamic>>
      updateCategory({
    required String categoryId,
    String? name,
    String? description,
    String? image,
    String? icon,
    bool? isActive,
  }) async {
    try {
      final response = await _api.put(
        '/admin/categories/$categoryId',
        data: {
          if (name != null)
            'name': name,
          if (description != null)
            'description': description,
          if (image != null)
            'image': image,
          if (icon != null)
            'icon': icon,
          if (isActive != null)
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
  // DELETE CATEGORY
  // =====================================================

  Future<bool> deleteCategory(
    String categoryId,
  ) async {
    try {
      await _api.delete(
        '/admin/categories/$categoryId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ACTIVATE CATEGORY
  // =====================================================

  Future<bool> activateCategory(
    String categoryId,
  ) async {
    try {
      await _api.patch(
        '/admin/categories/$categoryId/activate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DEACTIVATE CATEGORY
  // =====================================================

  Future<bool> deactivateCategory(
    String categoryId,
  ) async {
    try {
      await _api.patch(
        '/admin/categories/$categoryId/deactivate',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // REORDER CATEGORIES
  // =====================================================

  Future<bool> reorderCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      await _api.put(
        '/admin/categories/reorder',
        data: {
          'categories': categories,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CATEGORY ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCategoryAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/categories/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // TOP CATEGORIES
  // =====================================================

  Future<List<dynamic>>
      getTopCategories() async {
    try {
      final response = await _api.get(
        '/admin/categories/top',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CATEGORY SERVICES
  // =====================================================

  Future<List<dynamic>>
      getCategoryServices(
    String categoryId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/categories/$categoryId/services',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CATEGORY PROVIDERS
  // =====================================================

  Future<List<dynamic>>
      getCategoryProviders(
    String categoryId,
  ) async {
    try {
      final response = await _api.get(
        '/admin/categories/$categoryId/providers',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEARCH CATEGORIES
  // =====================================================

  Future<List<dynamic>>
      searchCategories(
    String keyword,
  ) async {
    try {
      final response = await _api.get(
        '/admin/categories/search',
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
  // CATEGORY STATISTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCategoryStatistics() async {
    try {
      final response = await _api.get(
        '/admin/categories/statistics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT CATEGORIES
  // =====================================================

  Future<Response<dynamic>>
      exportCategories({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/categories/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // BULK DELETE
  // =====================================================

  Future<bool> bulkDeleteCategories(
    List<String> categoryIds,
  ) async {
    try {
      await _api.post(
        '/admin/categories/bulk-delete',
        data: {
          'categoryIds': categoryIds,
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
    required List<String> categoryIds,
    required bool isActive,
  }) async {
    try {
      await _api.post(
        '/admin/categories/bulk-status',
        data: {
          'categoryIds': categoryIds,
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