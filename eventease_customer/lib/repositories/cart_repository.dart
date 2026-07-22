import '../models/cart_model.dart';
import '../services/cart_service.dart';

class CartRepository {
  CartRepository._();

  static final CartRepository instance =
      CartRepository._();

  final CartService _cartService =
      CartService.instance;

  // ==========================================
  // GET CART
  // ==========================================

  Future<CartModel> getCart() async {
    return await _cartService.getCart();
  }

  // ==========================================
  // ADD TO CART
  // ==========================================

  Future<CartModel> addToCart({
    required String serviceId,
    int quantity = 1,
    DateTime? bookingDate,
    String? bookingTime,
    String? notes,
  }) async {
    return await _cartService.addToCart(
      serviceId: serviceId,
      quantity: quantity,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      notes: notes,
    );
  }

  // ==========================================
  // UPDATE CART ITEM
  // ==========================================

  Future<CartModel> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    return await _cartService.updateCartItem(
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }

  // ==========================================
  // REMOVE CART ITEM
  // ==========================================

  Future<bool> removeCartItem(
    String cartItemId,
  ) async {
    return await _cartService.removeCartItem(
      cartItemId,
    );
  }

  // ==========================================
  // CLEAR CART
  // ==========================================

  Future<bool> clearCart() async {
    return await _cartService.clearCart();
  }

  // ==========================================
  // APPLY COUPON
  // ==========================================

  Future<CartModel> applyCoupon(
    String couponCode,
  ) async {
    return await _cartService.applyCoupon(
      couponCode,
    );
  }

  // ==========================================
  // REMOVE COUPON
  // ==========================================

  Future<CartModel> removeCoupon() async {
    return await _cartService.removeCoupon();
  }

  // ==========================================
  // CART COUNT
  // ==========================================

  Future<int> getCartCount() async {
    return await _cartService.getCartCount();
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
    return await _cartService.checkout(
      addressId: addressId,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
      notes: notes,
    );
  }

  // ==========================================
  // SAVE FOR LATER
  // ==========================================

  Future<bool> saveForLater(
    String cartItemId,
  ) async {
    return await _cartService.saveForLater(
      cartItemId,
    );
  }

  // ==========================================
  // MOVE TO CART
  // ==========================================

  Future<bool> moveToCart(
    String cartItemId,
  ) async {
    return await _cartService.moveToCart(
      cartItemId,
    );
  }

  // ==========================================
  // CART SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getCartSummary() async {
    return await _cartService.getCartSummary();
  }
}