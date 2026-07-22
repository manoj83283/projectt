import '../models/category_model.dart';
import 'api_service.dart';

class CategoryService {
  CategoryService._();

  static final CategoryService instance =
      CategoryService._();

  // ==========================================
  // GET ALL CATEGORIES
  // ==========================================

  Future<List<CategoryModel>> getCategories({
    int page = 1,
    int limit = 20,
    bool activeOnly = true,
  }) async {
    final response = await ApiService.instance.get(
      '/categories',
      queryParameters: {
        'page': page,
        'limit': limit,
        'activeOnly': activeOnly,
      },
    );

    final List categories =
        response.data['data'] ??
        response.data['categories'] ??
        [];

    return categories
        .map(
          (e) => CategoryModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET CATEGORY BY ID
  // ==========================================

  Future<CategoryModel> getCategoryById(
    String categoryId,
  ) async {
    final response = await ApiService.instance.get(
      '/categories/$categoryId',
    );

    return CategoryModel.fromMap(
      response.data['data'] ??
          response.data['category'],
    );
  }

  // ==========================================
  // FEATURED CATEGORIES
  // ==========================================

  Future<List<CategoryModel>>
      getFeaturedCategories() async {
    final response = await ApiService.instance.get(
      '/categories/featured',
    );

    final List categories =
        response.data['data'] ??
        response.data['categories'] ??
        [];

    return categories
        .map(
          (e) => CategoryModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // SEARCH CATEGORIES
  // ==========================================

  Future<List<CategoryModel>>
      searchCategories(
    String keyword,
  ) async {
    final response = await ApiService.instance.get(
      '/categories/search',
      queryParameters: {
        'keyword': keyword,
      },
    );

    final List categories =
        response.data['data'] ??
        response.data['categories'] ??
        [];

    return categories
        .map(
          (e) => CategoryModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // CREATE CATEGORY
  // ==========================================

  Future<CategoryModel> createCategory({
    required String name,
    String? description,
    String? image,
    String? icon,
    bool isFeatured = false,
  }) async {
    final response = await ApiService.instance.post(
      '/categories',
      data: {
        'name': name,
        'description': description,
        'image': image,
        'icon': icon,
        'isFeatured': isFeatured,
      },
    );

    return CategoryModel.fromMap(
      response.data['data'] ??
          response.data['category'],
    );
  }

  // ==========================================
  // UPDATE CATEGORY
  // ==========================================

  Future<CategoryModel> updateCategory({
    required String categoryId,
    String? name,
    String? description,
    String? image,
    String? icon,
    bool? isFeatured,
    bool? isActive,
  }) async {
    final response = await ApiService.instance.put(
      '/categories/$categoryId',
      data: {
        'name': name,
        'description': description,
        'image': image,
        'icon': icon,
        'isFeatured': isFeatured,
        'isActive': isActive,
      },
    );

    return CategoryModel.fromMap(
      response.data['data'] ??
          response.data['category'],
    );
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

  Future<List<CategoryModel>>
      getHomeCategories() async {
    final response = await ApiService.instance.get(
      '/categories/home',
    );

    final List categories =
        response.data['data'] ??
        response.data['categories'] ??
        [];

    return categories
        .map(
          (e) => CategoryModel.fromMap(e),
        )
        .toList();
  }
}