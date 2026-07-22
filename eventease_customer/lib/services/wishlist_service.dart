import '../models/wishlist_model.dart';
import 'api_service.dart';

class WishlistService {
  WishlistService._();

  static final WishlistService instance =
      WishlistService._();

  // ==========================================
  // GET WISHLIST
  // ==========================================

  Future<List<WishlistModel>> getWishlist({
    int page = 1,
    int limit = 20,
  }) async {
    final response =
        await ApiService.instance.get(
      '/wishlist',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List wishlist =
        response.data['data'] ??
            response.data['wishlist'] ??
            [];

    return wishlist
        .map(
          (e) => WishlistModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // ADD SERVICE TO WISHLIST
  // ==========================================

  Future<WishlistModel> addService({
    required String serviceId,
  }) async {
    final response =
        await ApiService.instance.post(
      '/wishlist/service',
      data: {
        'serviceId': serviceId,
      },
    );

    return WishlistModel.fromMap(
      response.data['data'] ??
          response.data['wishlist'],
    );
  }

  // ==========================================
  // ADD PROVIDER TO WISHLIST
  // ==========================================

  Future<WishlistModel> addProvider({
    required String providerId,
  }) async {
    final response =
        await ApiService.instance.post(
      '/wishlist/provider',
      data: {
        'providerId': providerId,
      },
    );

    return WishlistModel.fromMap(
      response.data['data'] ??
          response.data['wishlist'],
    );
  }

  // ==========================================
  // ADD PRODUCT TO WISHLIST
  // ==========================================

  Future<WishlistModel> addProduct({
    required String productId,
  }) async {
    final response =
        await ApiService.instance.post(
      '/wishlist/product',
      data: {
        'productId': productId,
      },
    );

    return WishlistModel.fromMap(
      response.data['data'] ??
          response.data['wishlist'],
    );
  }

  // ==========================================
  // REMOVE WISHLIST ITEM
  // ==========================================

  Future<bool> removeItem(
    String wishlistId,
  ) async {
    await ApiService.instance.delete(
      '/wishlist/$wishlistId',
    );

    return true;
  }

  // ==========================================
  // CLEAR WISHLIST
  // ==========================================

  Future<bool> clearWishlist() async {
    await ApiService.instance.delete(
      '/wishlist/clear',
    );

    return true;
  }

  // ==========================================
  // CHECK SERVICE WISHLIST
  // ==========================================

  Future<bool> isServiceWishlisted(
    String serviceId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/wishlist/service/$serviceId',
    );

    return response.data['exists'] ??
        response.data['data']
            ?['exists'] ??
        false;
  }

  // ==========================================
  // CHECK PROVIDER WISHLIST
  // ==========================================

  Future<bool> isProviderWishlisted(
    String providerId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/wishlist/provider/$providerId',
    );

    return response.data['exists'] ??
        response.data['data']
            ?['exists'] ??
        false;
  }

  // ==========================================
  // CHECK PRODUCT WISHLIST
  // ==========================================

  Future<bool> isProductWishlisted(
    String productId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/wishlist/product/$productId',
    );

    return response.data['exists'] ??
        response.data['data']
            ?['exists'] ??
        false;
  }

  // ==========================================
  // TOGGLE SERVICE WISHLIST
  // ==========================================

  Future<bool> toggleServiceWishlist(
    String serviceId,
  ) async {
    final response =
        await ApiService.instance.post(
      '/wishlist/service/toggle',
      data: {
        'serviceId': serviceId,
      },
    );

    return response.data['wishlisted'] ??
        response.data['data']
            ?['wishlisted'] ??
        false;
  }

  // ==========================================
  // TOGGLE PROVIDER WISHLIST
  // ==========================================

  Future<bool> toggleProviderWishlist(
    String providerId,
  ) async {
    final response =
        await ApiService.instance.post(
      '/wishlist/provider/toggle',
      data: {
        'providerId': providerId,
      },
    );

    return response.data['wishlisted'] ??
        response.data['data']
            ?['wishlisted'] ??
        false;
  }

  // ==========================================
  // TOGGLE PRODUCT WISHLIST
  // ==========================================

  Future<bool> toggleProductWishlist(
    String productId,
  ) async {
    final response =
        await ApiService.instance.post(
      '/wishlist/product/toggle',
      data: {
        'productId': productId,
      },
    );

    return response.data['wishlisted'] ??
        response.data['data']
            ?['wishlisted'] ??
        false;
  }

  // ==========================================
  // WISHLIST COUNT
  // ==========================================

  Future<int> getWishlistCount() async {
    final response =
        await ApiService.instance.get(
      '/wishlist/count',
    );

    return response.data['count'] ??
        response.data['data']
            ?['count'] ??
        0;
  }
}