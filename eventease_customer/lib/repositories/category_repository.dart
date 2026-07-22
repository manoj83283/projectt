import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryRepository {
  CategoryRepository._();

  static final CategoryRepository instance =
      CategoryRepository._();

  final CategoryService _categoryService =
      CategoryService.instance;

  // ==========================================
  // GET ALL CATEGORIES
  // ==========================================

  Future<List<CategoryModel>> getCategories({
    int page = 1,
    int limit = 50,
  }) async {
    return await _categoryService
        .getCategories(
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // GET CATEGORY BY ID
  // ==========================================

  Future<CategoryModel> getCategoryById(
    String categoryId,
  ) async {
    return await _categoryService
        .getCategoryById(categoryId);
  }

  // ==========================================
  // GET FEATURED CATEGORIES
  // ==========================================

  Future<List<CategoryModel>>
      getFeaturedCategories() async {
    return await _categoryService
        .getFeaturedCategories();
  }

  // ==========================================
  // SEARCH CATEGORIES
  // ==========================================

  Future<List<CategoryModel>>
      searchCategories(
    String keyword,
  ) async {
    return await _categoryService
        .searchCategories(keyword);
  }

  // ==========================================
  // GET POPULAR CATEGORIES
  // ==========================================

  Future<List<CategoryModel>>
      getPopularCategories() async {
    return await _categoryService
        .getPopularCategories();
  }

  // ==========================================
  // GET SUB CATEGORIES
  // ==========================================

  Future<List<CategoryModel>>
      getSubCategories(
    String parentId,
  ) async {
    return await _categoryService
        .getSubCategories(parentId);
  }

  // ==========================================
  // CREATE CATEGORY
  // ADMIN
  // ==========================================

  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    required String image,
    String? description,
    String? parentId,
  }) async {
    return await _categoryService
        .createCategory(
      name: name,
      icon: icon,
      image: image,
      description: description,
      parentId: parentId,
    );
  }

  // ==========================================
  // UPDATE CATEGORY
  // ADMIN
  // ==========================================

  Future<CategoryModel> updateCategory({
    required String categoryId,
    required Map<String, dynamic> data,
  }) async {
    return await _categoryService
        .updateCategory(
      categoryId: categoryId,
      data: data,
    );
  }

  // ==========================================
  // DELETE CATEGORY
  // ADMIN
  // ==========================================

  Future<bool> deleteCategory(
    String categoryId,
  ) async {
    return await _categoryService
        .deleteCategory(categoryId);
  }
}