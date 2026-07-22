import 'package:flutter/material.dart';

import '../models/wishlist_model.dart';
import '../repositories/wishlist_repository.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider();

  final WishlistRepository _repository =
      WishlistRepository.instance;

  List<WishlistModel> _wishlist = [];

  bool _isLoading = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  List<WishlistModel> get wishlist =>
      _wishlist;

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get wishlistCount =>
      _wishlist.length;

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
  // GET WISHLIST
  // ==========================================

  Future<void> getWishlist({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _wishlist =
          await _repository.getWishlist(
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
  // ADD SERVICE
  // ==========================================

  Future<bool> addService({
    required String serviceId,
  }) async {
    try {
      _setLoading(true);

      final item =
          await _repository.addService(
        serviceId: serviceId,
      );

      _wishlist.insert(0, item);

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
  // ADD PROVIDER
  // ==========================================

  Future<bool> addProvider({
    required String providerId,
  }) async {
    try {
      _setLoading(true);

      final item =
          await _repository.addProvider(
        providerId: providerId,
      );

      _wishlist.insert(0, item);

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
  // ADD PRODUCT
  // ==========================================

  Future<bool> addProduct({
    required String productId,
  }) async {
    try {
      _setLoading(true);

      final item =
          await _repository.addProduct(
        productId: productId,
      );

      _wishlist.insert(0, item);

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
  // REMOVE ITEM
  // ==========================================

  Future<bool> removeItem(
    String wishlistId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.removeItem(
        wishlistId,
      );

      if (success) {
        _wishlist.removeWhere(
          (e) => e.id == wishlistId,
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
  // CLEAR WISHLIST
  // ==========================================

  Future<bool> clearWishlist() async {
    try {
      _setLoading(true);

      final success =
          await _repository.clearWishlist();

      if (success) {
        _wishlist.clear();
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
  // CHECK SERVICE
  // ==========================================

  Future<bool> isServiceWishlisted(
    String serviceId,
  ) async {
    try {
      return await _repository
          .isServiceWishlisted(
        serviceId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // CHECK PROVIDER
  // ==========================================

  Future<bool> isProviderWishlisted(
    String providerId,
  ) async {
    try {
      return await _repository
          .isProviderWishlisted(
        providerId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // CHECK PRODUCT
  // ==========================================

  Future<bool> isProductWishlisted(
    String productId,
  ) async {
    try {
      return await _repository
          .isProductWishlisted(
        productId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // TOGGLE SERVICE
  // ==========================================

  Future<bool> toggleServiceWishlist(
    String serviceId,
  ) async {
    try {
      _setLoading(true);

      final result =
          await _repository
              .toggleServiceWishlist(
        serviceId,
      );

      return result;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // TOGGLE PROVIDER
  // ==========================================

  Future<bool> toggleProviderWishlist(
    String providerId,
  ) async {
    try {
      _setLoading(true);

      final result =
          await _repository
              .toggleProviderWishlist(
        providerId,
      );

      return result;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // TOGGLE PRODUCT
  // ==========================================

  Future<bool> toggleProductWishlist(
    String productId,
  ) async {
    try {
      _setLoading(true);

      final result =
          await _repository
              .toggleProductWishlist(
        productId,
      );

      return result;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GET WISHLIST COUNT
  // ==========================================

  Future<int> getWishlistCount() async {
    try {
      return await _repository
          .getWishlistCount();
    } catch (e) {
      _setError(e.toString());
      return 0;
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
    _wishlist.clear();
    _error = null;

    notifyListeners();
  }
}