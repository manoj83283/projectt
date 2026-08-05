import '../models/category_model.dart';
import 'api_service.dart';

class CategoryService {
  CategoryService._();

  static final CategoryService instance = CategoryService._();

  // ==========================================
  // RESPONSE HELPERS
  // ==========================================

  dynamic _responseData(dynamic response) {
    try {
      return response.data;
    } catch (_) {
      return response;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  dynamic _extractSingle(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map<String, dynamic>) {
      return data['data'] ??
          data['category'] ??
          data['result'] ??
          data;
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      return map['data'] ??
          map['category'] ??
          map['result'] ??
          map;
    }

    return data;
  }

  List<dynamic> _extractList(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map<String, dynamic>) {
      final dynamic list = data['data'] ??
          data['categories'] ??
          data['subCategories'] ??
          data['subcategories'] ??
          data['items'] ??
          data['results'];

      if (list is List) {
        return list;
      }
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      final dynamic list = map['data'] ??
          map['categories'] ??
          map['subCategories'] ??
          map['subcategories'] ??
          map['items'] ??
          map['results'];

      if (list is List) {
        return list;
      }
    }

    if (data is List) {
      return data;
    }

    return [];
  }

  CategoryModel _categoryFromResponse(dynamic response) {
    return CategoryModel.fromMap(
      _asMap(
        _extractSingle(response),
      ),
    );
  }

  List<CategoryModel> _categoriesFromResponse(dynamic response) {
    return _extractList(response)
        .map(
          (item) => CategoryModel.fromMap(
            _asMap(item),
          ),
        )
        .toList();
  }

  // ==========================================
  // GET ALL CATEGORIES
  // ==========================================

  Future<List<CategoryModel>> getCategories({
    int page = 1,
    int limit = 20,
    bool activeOnly = true,
    String? type,
    String? search,
    String? keyword,
    String? parentId,
  }) async {
    final String? searchValue = search ?? keyword;

    final dynamic response = await ApiService.instance.get(
      '/categories',
      queryParameters: {
        'page': page,
        'limit': limit,
        'activeOnly': activeOnly,
        if (type != null && type.trim().isNotEmpty)
          'type': type.trim(),
        if (searchValue != null && searchValue.trim().isNotEmpty)
          'search': searchValue.trim(),
        if (searchValue != null && searchValue.trim().isNotEmpty)
          'keyword': searchValue.trim(),
        if (parentId != null && parentId.trim().isNotEmpty)
          'parentId': parentId.trim(),
      },
    );

    return _categoriesFromResponse(response);
  }

  // ==========================================
  // GET CATEGORY BY ID
  // ==========================================

  Future<CategoryModel> getCategoryById(
    String categoryId,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/categories/$categoryId',
    );

    return _categoryFromResponse(response);
  }

  // ==========================================
  // FEATURED CATEGORIES
  // ==========================================

  Future<List<CategoryModel>> getFeaturedCategories() async {
    final dynamic response = await ApiService.instance.get(
      '/categories/featured',
    );

    return _categoriesFromResponse(response);
  }

  // ==========================================
  // POPULAR CATEGORIES
  // Repository compatibility method.
  // ==========================================

  Future<List<CategoryModel>> getPopularCategories() async {
    final dynamic response = await ApiService.instance.get(
      '/categories/popular',
    );

    return _categoriesFromResponse(response);
  }

  // ==========================================
  // SUB CATEGORIES
  // Repository compatibility method.
  // ==========================================

  Future<List<CategoryModel>> getSubCategories(
    String parentId,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/categories/$parentId/subcategories',
    );

    return _categoriesFromResponse(response);
  }

  // ==========================================
  // SEARCH CATEGORIES
  // ==========================================

  Future<List<CategoryModel>> searchCategories(
    String keyword,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/categories/search',
      queryParameters: {
        'keyword': keyword.trim(),
        'search': keyword.trim(),
      },
    );

    return _categoriesFromResponse(response);
  }

  // ==========================================
  // CREATE CATEGORY
  // Supports existing params and repository params:
  // parentId, data
  // ==========================================

  Future<CategoryModel> createCategory({
    String? name,
    String? title,
    String? description,
    String? image,
    String? icon,
    String? type,
    String? parentId,
    bool isFeatured = false,
    bool isActive = true,
    Map<String, dynamic>? data,
  }) async {
    final String resolvedName = (name ?? title ?? '').trim();

    final dynamic response = await ApiService.instance.post(
      '/categories',
      data: {
        ...?data,
        if (resolvedName.isNotEmpty) 'name': resolvedName,
        if (resolvedName.isNotEmpty) 'title': resolvedName,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (image != null && image.trim().isNotEmpty)
          'image': image.trim(),
        if (icon != null && icon.trim().isNotEmpty)
          'icon': icon.trim(),
        if (type != null && type.trim().isNotEmpty)
          'type': type.trim(),
        if (parentId != null && parentId.trim().isNotEmpty)
          'parentId': parentId.trim(),
        'isFeatured': isFeatured,
        'isActive': isActive,
      },
    );

    return _categoryFromResponse(response);
  }

  // ==========================================
  // CREATE SUB CATEGORY
  // ==========================================

  Future<CategoryModel> createSubCategory({
    required String parentId,
    String? name,
    String? title,
    String? description,
    String? image,
    String? icon,
    String? type,
    bool isFeatured = false,
    bool isActive = true,
    Map<String, dynamic>? data,
  }) async {
    final String resolvedName = (name ?? title ?? '').trim();

    final dynamic response = await ApiService.instance.post(
      '/categories/$parentId/subcategories',
      data: {
        ...?data,
        if (resolvedName.isNotEmpty) 'name': resolvedName,
        if (resolvedName.isNotEmpty) 'title': resolvedName,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (image != null && image.trim().isNotEmpty)
          'image': image.trim(),
        if (icon != null && icon.trim().isNotEmpty)
          'icon': icon.trim(),
        if (type != null && type.trim().isNotEmpty)
          'type': type.trim(),
        'parentId': parentId,
        'isFeatured': isFeatured,
        'isActive': isActive,
      },
    );

    return _categoryFromResponse(response);
  }

  // ==========================================
  // UPDATE CATEGORY
  // Supports existing params and repository data param
  // ==========================================

  Future<CategoryModel> updateCategory({
    required String categoryId,
    String? name,
    String? title,
    String? description,
    String? image,
    String? icon,
    String? type,
    String? parentId,
    bool? isFeatured,
    bool? isActive,
    Map<String, dynamic>? data,
  }) async {
    final String? resolvedName = name ?? title;

    final dynamic response = await ApiService.instance.put(
      '/categories/$categoryId',
      data: {
        ...?data,
        if (resolvedName != null && resolvedName.trim().isNotEmpty)
          'name': resolvedName.trim(),
        if (resolvedName != null && resolvedName.trim().isNotEmpty)
          'title': resolvedName.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (image != null && image.trim().isNotEmpty)
          'image': image.trim(),
        if (icon != null && icon.trim().isNotEmpty)
          'icon': icon.trim(),
        if (type != null && type.trim().isNotEmpty)
          'type': type.trim(),
        if (parentId != null && parentId.trim().isNotEmpty)
          'parentId': parentId.trim(),
        if (isFeatured != null) 'isFeatured': isFeatured,
        if (isActive != null) 'isActive': isActive,
      },
    );

    return _categoryFromResponse(response);
  }

  // ==========================================
  // DELETE CATEGORY
  // ==========================================

  Future<bool> deleteCategory(
    String categoryId,
  ) async {
    await ApiService.instance.delete(
      '/categories/$categoryId',
    );

    return true;
  }

  // ==========================================
  // GET HOME CATEGORIES
  // ==========================================

  Future<List<CategoryModel>> getHomeCategories() async {
    final dynamic response = await ApiService.instance.get(
      '/categories/home',
    );

    return _categoriesFromResponse(response);
  }
}