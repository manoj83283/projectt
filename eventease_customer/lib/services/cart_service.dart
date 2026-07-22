import '../models/cart_model.dart';
import 'api_service.dart';

class CartService {
  CartService._();

  static final CartService instance =
      CartService._();

  // ==========================================
  // GET CART
  // ==========================================

  Future<CartModel> getCart() async {
    final response =
        await ApiService.instance.get(
      '/cart',
    );

    return CartModel.fromMap(
      response.data['data'] ??
          response.data['cart'],
    );
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
    final response =
        await ApiService.instance.post(
      '/cart/add',
      data: {
        'serviceId': serviceId,
        'quantity': quantity,
        'bookingDate':
            bookingDate?.toIso8601String(),
        'bookingTime': bookingTime,
        'notes': notes,
      },
    );

    return CartModel.fromMap(
      response.data['data'] ??
          response.data['cart'],
    );
  }

  // ==========================================
  // UPDATE CART ITEM
  // ==========================================

  Future<CartModel> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    final response =
        await ApiService.instance.patch(
      '/cart/item/$cartItemId',
      data: {
        'quantity': quantity,
      },
    );

    return CartModel.fromMap(
      response.data['data'] ??
          response.data['cart'],
    );
  }

  // ==========================================
  // REMOVE CART ITEM
  // ==========================================

  Future<bool> removeCartItem(
    String cartItemId,
  ) async {
    await ApiService.instance.delete(
      '/cart/item/$cartItemId',
    );

    return true;
  }

  // ==========================================
  // CLEAR CART
  // ==========================================

  Future<bool> clearCart() async {
    await ApiService.instance.delete(
      '/cart/clear',
    );

    return true;
  }

  // ==========================================
  // APPLY COUPON
  // ==========================================

  Future<CartModel> applyCoupon(
    String couponCode,
  ) async {
    final response =
        await ApiService.instance.post(
      '/cart/apply-coupon',
      data: {
        'couponCode': couponCode,
      },
    );

    return CartModel.fromMap(
      response.data['data'] ??
          response.data['cart'],
    );
  }

  // ==========================================
  // REMOVE COUPON
  // ==========================================

  Future<CartModel> removeCoupon() async {
    final response =
        await ApiService.instance.delete(
      '/cart/remove-coupon',
    );

    return CartModel.fromMap(
      response.data['data'] ??
          response.data['cart'],
    );
  }

  // ==========================================
  // CART COUNT
  // ==========================================

  Future<int> getCartCount() async {
    final response =
        await ApiService.instance.get(
      '/cart/count',
    );

    return response.data['count'] ??
        response.data['data']?['count'] ??
        0;
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
    final response =
        await ApiService.instance.post(
      '/cart/checkout',
      data: {
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        'couponCode': couponCode,
        'notes': notes,
      },
    );

    return response.data['data'] ??
        response.data;
  }

  // ==========================================
  // SAVE FOR LATER
  // ==========================================

  Future<bool> saveForLater(
    String cartItemId,
  ) async {
    await ApiService.instance.patch(
      '/cart/item/$cartItemId/save',
    );

    return true;
  }

  // ==========================================
  // MOVE TO CART
  // ==========================================

  Future<bool> moveToCart(
    String cartItemId,
  ) async {
    await ApiService.instance.patch(
      '/cart/item/$cartItemId/move',
    );

    return true;
  }

  // ==========================================
  // CART SUMMARY
  // ==========================================

  Future<Map<String, dynamic>>
      getCartSummary() async {
    final response =
        await ApiService.instance.get(
      '/cart/summary',
    );

    return response.data['data'] ??
        response.data;
  }
}