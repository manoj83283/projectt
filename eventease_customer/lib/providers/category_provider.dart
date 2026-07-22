import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider();

  final CategoryRepository _repository =
      CategoryRepository.instance;

  List<CategoryModel> _categories = [];
  List<CategoryModel> _featuredCategories = [];
  List<CategoryModel> _popularCategories = [];
  List<CategoryModel> _subCategories = [];

  CategoryModel? _selectedCategory;

  bool _isLoading = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  List<CategoryModel> get categories =>
      _categories;

  List<CategoryModel>
      get featuredCategories =>
          _featuredCategories;

  List<CategoryModel>
      get popularCategories =>
          _popularCategories;

  List<CategoryModel> get subCategories =>
      _subCategories;

  CategoryModel? get selectedCategory =>
      _selectedCategory;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // ==========================================
  // SET LOADING
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // SET ERROR
  // ==========================================

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ==========================================
  // GET CATEGORIES
  // ==========================================

  Future<void> getCategories({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _categories =
          await _repository.getCategories(
        page: page,
        limit: limit,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GET CATEGORY BY ID
  // ==========================================

  Future<void> getCategoryById(
    String categoryId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _selectedCategory =
          await _repository.getCategoryById(
        categoryId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // FEATURED CATEGORIES
  // ==========================================

  Future<void>
      getFeaturedCategories() async {
    try {
      _setLoading(true);
      _setError(null);

      _featuredCategories =
          await _repository
              .getFeaturedCategories();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // POPULAR CATEGORIES
  // ==========================================

  Future<void>
      getPopularCategories() async {
    try {
      _setLoading(true);
      _setError(null);

      _popularCategories =
          await _repository
              .getPopularCategories();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SEARCH CATEGORIES
  // ==========================================

  Future<List<CategoryModel>>
      searchCategories(
    String keyword,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      return await _repository
          .searchCategories(keyword);
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GET SUB CATEGORIES
  // ==========================================

  Future<void> getSubCategories(
    String parentId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _subCategories =
          await _repository.getSubCategories(
        parentId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SET CATEGORY
  // ==========================================

  void setSelectedCategory(
    CategoryModel category,
  ) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ==========================================
  // CLEAR CATEGORY
  // ==========================================

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  // ==========================================
  // CREATE CATEGORY
  // ADMIN
  // ==========================================

  Future<bool> createCategory({
    required String name,
    required String icon,
    required String image,
    String? description,
    String? parentId,
  }) async {
    try {
      _setLoading(true);

      final category =
          await _repository.createCategory(
        name: name,
        icon: icon,
        image: image,
        description: description,
        parentId: parentId,
      );

      _categories.insert(0, category);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // UPDATE CATEGORY
  // ADMIN
  // ==========================================

  Future<bool> updateCategory({
    required String categoryId,
    required Map<String, dynamic> data,
  }) async {
    try {
      _setLoading(true);

      final updated =
          await _repository.updateCategory(
        categoryId: categoryId,
        data: data,
      );

      final index = _categories.indexWhere(
        (e) => e.id == categoryId,
      );

      if (index != -1) {
        _categories[index] = updated;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // DELETE CATEGORY
  // ADMIN
  // ==========================================

  Future<bool> deleteCategory(
    String categoryId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.deleteCategory(
        categoryId,
      );

      if (success) {
        _categories.removeWhere(
          (e) => e.id == categoryId,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ==========================================
  // RESET
  // ==========================================

  void reset() {
    _categories.clear();
    _featuredCategories.clear();
    _popularCategories.clear();
    _subCategories.clear();

    _selectedCategory = null;
    _error = null;

    notifyListeners();
  }
}