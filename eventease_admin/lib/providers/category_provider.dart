import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService =
      CategoryService();

  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryModel> _categories = [];

  CategoryModel? _selectedCategory;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCategories = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<CategoryModel> get categories =>
      _categories;

  CategoryModel? get selectedCategory =>
      _selectedCategory;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalCategories =>
      _totalCategories;

  bool get hasCategories =>
      _categories.isNotEmpty;

  // =====================================================
  // GET CATEGORIES
  // =====================================================

  Future<void> getCategories({
    int page = 1,
    int limit = 20,
    String? search,
    bool? isActive,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _categoryService.getCategories(
        page: page,
        limit: limit,
        search: search,
        isActive: isActive,
      );

      _categories =
          (response['categories'] as List? ??
                  [])
              .map(
                (e) =>
                    CategoryModel.fromJson(e),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalCategories =
          response['totalCategories'] ??
              _categories.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET CATEGORY DETAILS
  // =====================================================

  Future<void> getCategoryDetails(
    String categoryId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _categoryService
              .getCategoryDetails(
        categoryId,
      );

      _selectedCategory =
          CategoryModel.fromJson(
        response,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // CREATE CATEGORY
  // =====================================================

  Future<bool> createCategory({
    required String name,
    required String description,
    String? image,
    String? icon,
    bool isFeatured = false,
    int sortOrder = 0,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _categoryService
              .createCategory(
        name: name,
        description: description,
        image: image,
        icon: icon,
        isFeatured: isFeatured,
        sortOrder: sortOrder,
      );

      final category =
          CategoryModel.fromJson(
        response,
      );

      _categories.insert(0, category);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // UPDATE CATEGORY
  // =====================================================

  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    required String description,
    String? image,
    String? icon,
    bool? isFeatured,
    int? sortOrder,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _categoryService
              .updateCategory(
        categoryId: categoryId,
        name: name,
        description: description,
        image: image,
        icon: icon,
        isFeatured: isFeatured,
        sortOrder: sortOrder,
      );

      final updatedCategory =
          CategoryModel.fromJson(
        response,
      );

      final index =
          _categories.indexWhere(
        (e) => e.id == categoryId,
      );

      if (index != -1) {
        _categories[index] =
            updatedCategory;
      }

      if (_selectedCategory?.id ==
          categoryId) {
        _selectedCategory =
            updatedCategory;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // ACTIVATE CATEGORY
  // =====================================================

  Future<bool> activateCategory(
    String categoryId,
  ) async {
    try {
      _setLoading(true);

      await _categoryService
          .activateCategory(
        categoryId,
      );

      final index =
          _categories.indexWhere(
        (e) => e.id == categoryId,
      );

      if (index != -1) {
        _categories[index] =
            _categories[index].copyWith(
          isActive: true,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DEACTIVATE CATEGORY
  // =====================================================

  Future<bool> deactivateCategory(
    String categoryId,
  ) async {
    try {
      _setLoading(true);

      await _categoryService
          .deactivateCategory(
        categoryId,
      );

      final index =
          _categories.indexWhere(
        (e) => e.id == categoryId,
      );

      if (index != -1) {
        _categories[index] =
            _categories[index].copyWith(
          isActive: false,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // FEATURE CATEGORY
  // =====================================================

  Future<bool> featureCategory(
    String categoryId,
  ) async {
    try {
      _setLoading(true);

      await _categoryService
          .featureCategory(
        categoryId,
      );

      final index =
          _categories.indexWhere(
        (e) => e.id == categoryId,
      );

      if (index != -1) {
        _categories[index] =
            _categories[index].copyWith(
          isFeatured: true,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // UNFEATURE CATEGORY
  // =====================================================

  Future<bool> unFeatureCategory(
    String categoryId,
  ) async {
    try {
      _setLoading(true);

      await _categoryService
          .unFeatureCategory(
        categoryId,
      );

      final index =
          _categories.indexWhere(
        (e) => e.id == categoryId,
      );

      if (index != -1) {
        _categories[index] =
            _categories[index].copyWith(
          isFeatured: false,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DELETE CATEGORY
  // =====================================================

  Future<bool> deleteCategory(
    String categoryId,
  ) async {
    try {
      _setLoading(true);

      await _categoryService
          .deleteCategory(
        categoryId,
      );

      _categories.removeWhere(
        (e) => e.id == categoryId,
      );

      if (_selectedCategory?.id ==
          categoryId) {
        _selectedCategory = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEARCH CATEGORIES
  // =====================================================

  Future<void> searchCategories(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _categoryService
              .searchCategories(
        keyword,
      );

      _categories =
          (response)
              .map(
                (e) =>
                    CategoryModel.fromJson(
                  e,
                ),
              )
              .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refreshCategories() async {
    await getCategories(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED CATEGORY
  // =====================================================

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =====================================================
  // LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}