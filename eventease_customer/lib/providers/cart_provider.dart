import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider();

  final CartRepository _repository =
      CartRepository.instance;

  CartModel? _cart;

  bool _isLoading = false;
  String? _error;

  // ==========================================
  // GETTERS
  // ==========================================

  CartModel? get cart => _cart;

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get cartCount {
    if (_cart == null) return 0;

    return _cart!.items.length;
  }

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
  // GET CART
  // ==========================================

  Future<void> getCart() async {
    try {
      _setLoading(true);
      _setError(null);

      _cart = await _repository.getCart();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // ADD TO CART
  // ==========================================

  Future<bool> addToCart({
    required String serviceId,
    int quantity = 1,
    DateTime? bookingDate,
    String? bookingTime,
    String? notes,
  }) async {
    try {
      _setLoading(true);

      _cart = await _repository.addToCart(
        serviceId: serviceId,
        quantity: quantity,
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        notes: notes,
      );

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
  // UPDATE CART ITEM
  // ==========================================

  Future<bool> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    try {
      _setLoading(true);

      _cart =
          await _repository.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
      );

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
  // REMOVE CART ITEM
  // ==========================================

  Future<bool> removeCartItem(
    String cartItemId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.removeCartItem(
        cartItemId,
      );

      if (success) {
        await getCart();
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CLEAR CART
  // ==========================================

  Future<bool> clearCart() async {
    try {
      _setLoading(true);

      final success =
          await _repository.clearCart();

      if (success) {
        _cart = null;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // APPLY COUPON
  // ==========================================

  Future<bool> applyCoupon(
    String couponCode,
  ) async {
    try {
      _setLoading(true);

      _cart = await _repository.applyCoupon(
        couponCode,
      );

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
  // REMOVE COUPON
  // ==========================================

  Future<bool> removeCoupon() async {
    try {
      _setLoading(true);

      _cart = await _repository.removeCoupon();

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
  // CART COUNT
  // ==========================================

  Future<int> getCartCount() async {
    try {
      return await _repository
          .getCartCount();
    } catch (e) {
      _setError(e.toString());
      return 0;
    }
  }

  // ==========================================
  // CHECKOUT
  // ==========================================

  Future<Map<String, dynamic>> checkout({
    required String addressId,
    required String paymentMethod,
    String? couponCode,
    String? notes,
  }) async {
    try {
      _setLoading(true);

      return await _repository.checkout(
        addressId: addressId,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        notes: notes,
      );
    } catch (e) {
      _setError(e.toString());
      return {};
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // SAVE FOR LATER
  // ==========================================

  Future<bool> saveForLater(
    String cartItemId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.saveForLater(
        cartItemId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // MOVE TO CART
  // ==========================================

  Future<bool> moveToCart(
    String cartItemId,
  ) async {
    try {
      _setLoading(true);

      return await _repository.moveToCart(
        cartItemId,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // CART SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getCartSummary() async {
    try {
      return await _repository
          .getCartSummary();
    } catch (e) {
      _setError(e.toString());
      return {};
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
    _cart = null;
    _error = null;

    notifyListeners();
  }
}