import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';

class WishlistRepository {
  WishlistRepository._();

  static final WishlistRepository instance =
      WishlistRepository._();

  final WishlistService _wishlistService =
      WishlistService.instance;

  // ==========================================
  // GET WISHLIST
  // ==========================================

  Future<List<WishlistModel>> getWishlist({
    int page = 1,
    int limit = 20,
  }) async {
    return await _wishlistService.getWishlist(
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // ADD SERVICE
  // ==========================================

  Future<WishlistModel> addService({
    required String serviceId,
  }) async {
    return await _wishlistService.addService(
      serviceId: serviceId,
    );
  }

  // ==========================================
  // ADD PROVIDER
  // ==========================================

  Future<WishlistModel> addProvider({
    required String providerId,
  }) async {
    return await _wishlistService.addProvider(
      providerId: providerId,
    );
  }

  // ==========================================
  // ADD PRODUCT
  // ==========================================

  Future<WishlistModel> addProduct({
    required String productId,
  }) async {
    return await _wishlistService.addProduct(
      productId: productId,
    );
  }

  // ==========================================
  // REMOVE ITEM
  // ==========================================

  Future<bool> removeItem(
    String wishlistId,
  ) async {
    return await _wishlistService.removeItem(
      wishlistId,
    );
  }

  // ==========================================
  // CLEAR WISHLIST
  // ==========================================

  Future<bool> clearWishlist() async {
    return await _wishlistService.clearWishlist();
  }

  // ==========================================
  // CHECK SERVICE
  // ==========================================

  Future<bool> isServiceWishlisted(
    String serviceId,
  ) async {
    return await _wishlistService
        .isServiceWishlisted(serviceId);
  }

  // ==========================================
  // CHECK PROVIDER
  // ==========================================

  Future<bool> isProviderWishlisted(
    String providerId,
  ) async {
    return await _wishlistService
        .isProviderWishlisted(providerId);
  }

  // ==========================================
  // CHECK PRODUCT
  // ==========================================

  Future<bool> isProductWishlisted(
    String productId,
  ) async {
    return await _wishlistService
        .isProductWishlisted(productId);
  }

  // ==========================================
  // TOGGLE SERVICE
  // ==========================================

  Future<bool> toggleServiceWishlist(
    String serviceId,
  ) async {
    return await _wishlistService
        .toggleServiceWishlist(serviceId);
  }

  // ==========================================
  // TOGGLE PROVIDER
  // ==========================================

  Future<bool> toggleProviderWishlist(
    String providerId,
  ) async {
    return await _wishlistService
        .toggleProviderWishlist(providerId);
  }

  // ==========================================
  // TOGGLE PRODUCT
  // ==========================================

  Future<bool> toggleProductWishlist(
    String productId,
  ) async {
    return await _wishlistService
        .toggleProductWishlist(productId);
  }

  // ==========================================
  // WISHLIST COUNT
  // ==========================================

  Future<int> getWishlistCount() async {
    return await _wishlistService
        .getWishlistCount();
  }
}