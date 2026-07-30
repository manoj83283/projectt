import '../services/category_service.dart';

class CategoryRepository {
  final CategoryService _categoryService;

  CategoryRepository({
    CategoryService? categoryService,
  }) : _categoryService =
            categoryService ??
                CategoryService();

  // =====================================================
  // GET CATEGORIES
  // =====================================================

  Future<Map<String, dynamic>> getCategories({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
    bool? isFeatured,
  }) async {
    try {
      return await _categoryService
          .getCategories(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
        isFeatured: isFeatured,
      );
    } catch (e) {
      rethrow;
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
      return await _categoryService
          .getCategoryDetails(
        categoryId,
      );
    } catch (e) {
      rethrow;
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
      return await _categoryService
          .searchCategories(
        keyword,
      );
    } catch (e) {
      rethrow;
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
    bool isFeatured = false,
    int sortOrder = 0,
  }) async {
    try {
      return await _categoryService
          .createCategory(
        name: name,
        description: description,
        image: image,
        icon: icon,
        isFeatured: isFeatured,
        sortOrder: sortOrder,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UPDATE CATEGORY
  // =====================================================

  Future<Map<String, dynamic>>
      updateCategory({
    required String categoryId,
    required String name,
    required String description,
    String? image,
    String? icon,
    bool? isFeatured,
    int? sortOrder,
  }) async {
    try {
      return await _categoryService
          .updateCategory(
        categoryId: categoryId,
        name: name,
        description: description,
        image: image,
        icon: icon,
        isFeatured: isFeatured,
        sortOrder: sortOrder,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // ACTIVATE CATEGORY
  // =====================================================

  Future<Map<String, dynamic>>
      activateCategory(
    String categoryId,
  ) async {
    try {
      return await _categoryService
          .activateCategory(
        categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DEACTIVATE CATEGORY
  // =====================================================

  Future<Map<String, dynamic>>
      deactivateCategory(
    String categoryId,
  ) async {
    try {
      return await _categoryService
          .deactivateCategory(
        categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // FEATURE CATEGORY
  // =====================================================

  Future<Map<String, dynamic>>
      featureCategory(
    String categoryId,
  ) async {
    try {
      return await _categoryService
          .featureCategory(
        categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // UNFEATURE CATEGORY
  // =====================================================

  Future<Map<String, dynamic>>
      unFeatureCategory(
    String categoryId,
  ) async {
    try {
      return await _categoryService
          .unFeatureCategory(
        categoryId,
      );
    } catch (e) {
      rethrow;
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
      return await _categoryService
          .getCategoryServices(
        categoryId,
      );
    } catch (e) {
      rethrow;
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
      return await _categoryService
          .getCategoryProviders(
        categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CATEGORY ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getCategoryAnalytics(
    String categoryId,
  ) async {
    try {
      return await _categoryService
          .getCategoryAnalytics(
        categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // REORDER CATEGORIES
  // =====================================================

  Future<Map<String, dynamic>>
      updateCategoryOrder(
    List<Map<String, dynamic>>
        categories,
  ) async {
    try {
      return await _categoryService
          .updateCategoryOrder(
        categories,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE CATEGORY
  // =====================================================

  Future<void> deleteCategory(
    String categoryId,
  ) async {
    try {
      await _categoryService
          .deleteCategory(
        categoryId,
      );
    } catch (e) {
      rethrow;
    }
  }
}