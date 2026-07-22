import '../models/provider_model.dart';
import 'api_service.dart';

class ProviderService {
  ProviderService._();

  static final ProviderService instance =
      ProviderService._();

  // ==========================================
  // GET ALL PROVIDERS
  // ==========================================

  Future<List<ProviderModel>> getProviders({
    int page = 1,
    int limit = 20,
    String? categoryId,
  }) async {
    final response =
        await ApiService.instance.get(
      '/providers',
      queryParameters: {
        'page': page,
        'limit': limit,
        'categoryId': categoryId,
      },
    );

    final List providers =
        response.data['data'] ??
            response.data['providers'] ??
            [];

    return providers
        .map(
          (e) => ProviderModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET PROVIDER BY ID
  // ==========================================

  Future<ProviderModel> getProviderById(
    String providerId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/providers/$providerId',
    );

    return ProviderModel.fromMap(
      response.data['data'] ??
          response.data['provider'],
    );
  }

  // ==========================================
  // FEATURED PROVIDERS
  // ==========================================

  Future<List<ProviderModel>>
      getFeaturedProviders() async {
    final response =
        await ApiService.instance.get(
      '/providers/featured',
    );

    final List providers =
        response.data['data'] ??
            response.data['providers'] ??
            [];

    return providers
        .map(
          (e) => ProviderModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // NEARBY PROVIDERS
  // ==========================================

  Future<List<ProviderModel>>
      getNearbyProviders({
    required double latitude,
    required double longitude,
    double radius = 20,
  }) async {
    final response =
        await ApiService.instance.get(
      '/providers/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );

    final List providers =
        response.data['data'] ??
            response.data['providers'] ??
            [];

    return providers
        .map(
          (e) => ProviderModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // SEARCH PROVIDERS
  // ==========================================

  Future<List<ProviderModel>>
      searchProviders(
    String keyword,
  ) async {
    final response =
        await ApiService.instance.get(
      '/providers/search',
      queryParameters: {
        'keyword': keyword,
      },
    );

    final List providers =
        response.data['data'] ??
            response.data['providers'] ??
            [];

    return providers
        .map(
          (e) => ProviderModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // PROVIDERS BY CATEGORY
  // ==========================================

  Future<List<ProviderModel>>
      getProvidersByCategory(
    String categoryId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/providers/category/$categoryId',
    );

    final List providers =
        response.data['data'] ??
            response.data['providers'] ??
            [];

    return providers
        .map(
          (e) => ProviderModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // UPDATE PROVIDER PROFILE
  // ==========================================

  Future<ProviderModel> updateProfile({
    required String providerId,
    String? businessName,
    String? businessDescription,
    String? address,
    double? latitude,
    double? longitude,
    bool? isAvailable,
  }) async {
    final response =
        await ApiService.instance.put(
      '/providers/$providerId',
      data: {
        'businessName': businessName,
        'businessDescription':
            businessDescription,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'isAvailable': isAvailable,
      },
    );

    return ProviderModel.fromMap(
      response.data['data'] ??
          response.data['provider'],
    );
  }

  // ==========================================
  // GET PROVIDER SERVICES
  // ==========================================

  Future<List<dynamic>>
      getProviderServices(
    String providerId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/providers/$providerId/services',
    );

    return response.data['data'] ??
        response.data['services'] ??
        [];
  }

  // ==========================================
  // GET PROVIDER REVIEWS
  // ==========================================

  Future<List<dynamic>>
      getProviderReviews(
    String providerId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/providers/$providerId/reviews',
    );

    return response.data['data'] ??
        response.data['reviews'] ??
        [];
  }

  // ==========================================
  // TOGGLE AVAILABILITY
  // ==========================================

  Future<bool> toggleAvailability({
    required String providerId,
    required bool isAvailable,
  }) async {
    await ApiService.instance.patch(
      '/providers/$providerId/availability',
      data: {
        'isAvailable': isAvailable,
      },
    );

    return true;
  }

  // ==========================================
  // DELETE PROVIDER
  // ==========================================

  Future<bool> deleteProvider(
    String providerId,
  ) async {
    await ApiService.instance.delete(
      '/providers/$providerId',
    );

    return true;
  }
}