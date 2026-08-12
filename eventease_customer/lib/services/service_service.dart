import 'dart:developer';

import '../models/service_model.dart';
import 'api_service.dart';

class ServiceService {
  ServiceService._();

  static final ServiceService _instance =
      ServiceService._();

  static ServiceService get instance => _instance;

  final ApiService _apiService = ApiService.instance;

  // =====================================================
  // ENDPOINTS
  // ApiService base URL already includes /api.
  // =====================================================

  static const String _servicesEndpoint = '/services';

  // =====================================================
  // GET ALL CUSTOMER-VISIBLE SERVICES
  // GET /api/services
  // =====================================================

  Future<List<ServiceModel>> getServices({
    String? search,
    String? keyword,
    String? category,
    String? categoryId,
    String? location,
    double? minPrice,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? radius,
    String? sort,
    String? sortBy,
    String? sortOrder,
    bool? featured,
    bool? popular,
    bool? recommended,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final resolvedSearch = _firstNonEmpty([
        search,
        keyword,
      ]);

      final resolvedCategory = _firstNonEmpty([
        category,
        categoryId,
      ]);

      final resolvedSort = _resolveSort(
        sort: sort,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final queryParameters = <String, dynamic>{
        'page': page < 1 ? 1 : page,
        'limit': limit < 1 ? 20 : limit,
        if (resolvedSearch != null)
          'search': resolvedSearch,
        if (resolvedCategory != null)
          'category': resolvedCategory.toLowerCase(),
        if (location != null &&
            location.trim().isNotEmpty)
          'location': location.trim(),
        if (minPrice != null)
          'minPrice': minPrice,
        if (maxPrice != null)
          'maxPrice': maxPrice,
        if (latitude != null)
          'lat': latitude,
        if (longitude != null)
          'lng': longitude,
        if (radius != null)
          'radius': radius,
        if (resolvedSort != null)
          'sort': resolvedSort,
        if (featured != null)
          'featured': featured,
        if (popular != null)
          'popular': popular,
        if (recommended != null)
          'recommended': recommended,
      };

      final response = await _apiService.get(
        _servicesEndpoint,
        queryParameters: queryParameters,
      );

      return _servicesFromResponse(response);
    } catch (error, stackTrace) {
      log(
        'Get Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET SERVICE BY ID
  // GET /api/services/:id
  // =====================================================

  Future<ServiceModel> getServiceById(
    String serviceId,
  ) async {
    try {
      final normalizedId = _requireServiceId(
        serviceId,
      );

      final response = await _apiService.get(
        '$_servicesEndpoint/$normalizedId',
      );

      return _serviceFromResponse(response);
    } catch (error, stackTrace) {
      log(
        'Get Service By ID Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // SEARCH SERVICES
  // GET /api/services/search
  // =====================================================

  Future<List<ServiceModel>> searchServices(
    String keyword, {
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final normalizedKeyword = keyword.trim();

      final queryParameters = <String, dynamic>{
        if (normalizedKeyword.isNotEmpty)
          'keyword': normalizedKeyword,
        if (category != null &&
            category.trim().isNotEmpty)
          'category': category.trim().toLowerCase(),
        if (latitude != null)
          'lat': latitude,
        if (longitude != null)
          'lng': longitude,
        if (radius != null)
          'radius': radius,
      };

      final response = await _apiService.get(
        '$_servicesEndpoint/search',
        queryParameters: queryParameters,
      );

      return _servicesFromResponse(response);
    } catch (error, stackTrace) {
      log(
        'Search Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // SEARCH SERVICES - NAMED ARGUMENT COMPATIBILITY
  // =====================================================

  Future<List<ServiceModel>> searchServicesByKeyword({
    required String keyword,
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    return searchServices(
      keyword,
      category: category,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }

  // =====================================================
  // GET SERVICES BY CATEGORY
  // GET /api/services?category=...
  // =====================================================

  Future<List<ServiceModel>> getServicesByCategory(
    String category,
  ) async {
    try {
      final normalizedCategory = category.trim();

      if (normalizedCategory.isEmpty) {
        return getServices(
          page: 1,
          limit: 100,
        );
      }

      return getServices(
        category: normalizedCategory,
        page: 1,
        limit: 100,
        sort: 'newest',
      );
    } catch (error, stackTrace) {
      log(
        'Get Services By Category Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET FEATURED SERVICES
  // GET /api/services?featured=true
  // =====================================================

  Future<List<ServiceModel>>
      getFeaturedServices() async {
    try {
      return getServices(
        featured: true,
        page: 1,
        limit: 20,
        sort: 'newest',
      );
    } catch (error, stackTrace) {
      log(
        'Get Featured Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET POPULAR SERVICES
  // GET /api/services?popular=true
  // =====================================================

  Future<List<ServiceModel>>
      getPopularServices() async {
    try {
      return getServices(
        popular: true,
        page: 1,
        limit: 20,
        sort: 'rating',
      );
    } catch (error, stackTrace) {
      log(
        'Get Popular Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET RECOMMENDED SERVICES
  // GET /api/services?recommended=true
  // =====================================================

  Future<List<ServiceModel>>
      getRecommendedServices() async {
    try {
      return getServices(
        recommended: true,
        page: 1,
        limit: 20,
        sort: 'rating',
      );
    } catch (error, stackTrace) {
      log(
        'Get Recommended Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET HOME SERVICES
  //
  // Uses the supported GET /api/services endpoint.
  // Newly created Provider services appear first.
  // =====================================================

  Future<List<ServiceModel>> getHomeServices() async {
    try {
      return getServices(
        page: 1,
        limit: 20,
        sort: 'newest',
      );
    } catch (error, stackTrace) {
      log(
        'Get Home Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET TOP-RATED SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getTopRatedServices() async {
    try {
      return getServices(
        page: 1,
        limit: 20,
        sort: 'rating',
      );
    } catch (error, stackTrace) {
      log(
        'Get Top Rated Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET NEARBY SERVICES
  // GET /api/services/nearby
  //
  // Backend radius is measured in meters.
  // =====================================================

  Future<List<ServiceModel>> getNearbyServices({
    required double latitude,
    required double longitude,
    double radius = 30000,
    String? category,
  }) async {
    try {
      final normalizedRadius =
          radius <= 0 ? 30000 : radius;

      final response = await _apiService.get(
        '$_servicesEndpoint/nearby',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': normalizedRadius,
          if (category != null &&
              category.trim().isNotEmpty)
            'category': category.trim().toLowerCase(),
        },
      );

      return _servicesFromResponse(response);
    } catch (error, stackTrace) {
      log(
        'Get Nearby Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET SERVICES FOR A PROVIDER
  //
  // The current backend does not provide a dedicated
  // /providers/:id/services endpoint. This method fetches
  // public services and filters by provider ID locally.
  // =====================================================

  Future<List<ServiceModel>> getProviderServices(
    String providerId, {
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final normalizedProviderId =
          providerId.trim();

      if (normalizedProviderId.isEmpty) {
        return <ServiceModel>[];
      }

      final services = await getServices(
        page: page,
        limit: limit,
        sort: 'newest',
      );

      return services
          .where(
            (service) =>
                service.providerId ==
                normalizedProviderId,
          )
          .toList();
    } catch (error, stackTrace) {
      log(
        'Get Provider Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // CHECK AVAILABILITY
  //
  // No dedicated public availability route exists in the
  // current backend. Use the service visibility fields.
  // =====================================================

  Future<Map<String, dynamic>> checkAvailability({
    required String serviceId,
    DateTime? date,
    dynamic bookingDate,
    String? time,
    String? bookingTime,
  }) async {
    try {
      final service = await getServiceById(
        serviceId,
      );

      final available =
          service.isActive &&
          service.isAvailable &&
          service.approvalStatus == 'approved';

      return <String, dynamic>{
        'success': true,
        'available': available,
        'isAvailable': available,
        'serviceId': service.id,
        'service': service.toMap(),
        if (date != null)
          'date': date.toIso8601String(),
        if (bookingDate != null)
          'bookingDate':
              bookingDate is DateTime
                  ? bookingDate.toIso8601String()
                  : bookingDate.toString(),
        if (time != null &&
            time.trim().isNotEmpty)
          'time': time.trim(),
        if (bookingTime != null &&
            bookingTime.trim().isNotEmpty)
          'bookingTime':
              bookingTime.trim(),
      };
    } catch (error, stackTrace) {
      log(
        'Check Service Availability Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // SERVICE REVIEWS
  //
  // Reviews are mounted separately at /api/reviews.
  // The exact review filtering field may differ by backend.
  // =====================================================

  Future<dynamic> getServiceReviews(
    String serviceId,
  ) async {
    try {
      final normalizedId = _requireServiceId(
        serviceId,
      );

      final response = await _apiService.get(
        '/reviews',
        queryParameters: {
          'serviceId': normalizedId,
        },
      );

      return _responseData(response);
    } catch (error, stackTrace) {
      log(
        'Get Service Reviews Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // SERVICE ANALYTICS
  //
  // Customer app derives public analytics from the service
  // because no public /services/:id/analytics route exists.
  // =====================================================

  Future<Map<String, dynamic>> getServiceAnalytics(
    String serviceId,
  ) async {
    try {
      final service = await getServiceById(
        serviceId,
      );

      return <String, dynamic>{
        'success': true,
        'serviceId': service.id,
        'rating': service.rating,
        'reviewsCount':
            service.reviewsCount,
        'bookingCount':
            service.bookingCount,
        'isAvailable':
            service.isAvailable,
        'isActive': service.isActive,
        'service': service.toMap(),
      };
    } catch (error, stackTrace) {
      log(
        'Get Service Analytics Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // RESPONSE HELPERS
  // =====================================================

  dynamic _responseData(dynamic response) {
    if (response == null) {
      return null;
    }

    /*
     * Some ApiService implementations return Dio Response.
     * Other implementations return the decoded response map.
     */
    try {
      return response.data;
    } catch (_) {
      return response;
    }
  }

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key.toString(),
          item,
        ),
      );
    }

    return <String, dynamic>{};
  }

  dynamic _extractSingle(
    dynamic response,
  ) {
    final data = _responseData(response);

    if (data is Map) {
      final map = _asMap(data);

      return map['service'] ??
          map['data'] ??
          map['result'] ??
          map;
    }

    return data;
  }

  List<dynamic> _extractList(
    dynamic response,
  ) {
    final data = _responseData(response);

    if (data is List) {
      return data;
    }

    if (data is Map) {
      final map = _asMap(data);

      final possibleLists = [
        map['services'],
        map['data'],
        map['items'],
        map['results'],
      ];

      for (final possibleList
          in possibleLists) {
        if (possibleList is List) {
          return possibleList;
        }

        /*
         * Some APIs return:
         * data: { services: [...] }
         */
        if (possibleList is Map) {
          final nestedMap =
              _asMap(possibleList);

          final nestedList =
              nestedMap['services'] ??
                  nestedMap['items'] ??
                  nestedMap['results'];

          if (nestedList is List) {
            return nestedList;
          }
        }
      }
    }

    return <dynamic>[];
  }

  ServiceModel _serviceFromResponse(
    dynamic response,
  ) {
    final serviceData = _asMap(
      _extractSingle(response),
    );

    if (serviceData.isEmpty) {
      throw const FormatException(
        'The backend returned an invalid service response.',
      );
    }

    return ServiceModel.fromMap(
      serviceData,
    );
  }

  List<ServiceModel> _servicesFromResponse(
    dynamic response,
  ) {
    final rawServices =
        _extractList(response);

    return rawServices
        .whereType<Map>()
        .map(
          (item) => ServiceModel.fromMap(
            _asMap(item),
          ),
        )
        .where(
          (service) => service.id.isNotEmpty,
        )
        .toList();
  }

  // =====================================================
  // INPUT HELPERS
  // =====================================================

  String _requireServiceId(
    String serviceId,
  ) {
    final normalizedId = serviceId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError(
        'Service ID is required.',
      );
    }

    return normalizedId;
  }

  String? _firstNonEmpty(
    List<String?> values,
  ) {
    for (final value in values) {
      if (value != null &&
          value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  String? _resolveSort({
    String? sort,
    String? sortBy,
    String? sortOrder,
  }) {
    if (sort != null &&
        sort.trim().isNotEmpty) {
      return sort.trim();
    }

    final normalizedSortBy =
        sortBy?.trim().toLowerCase();

    final normalizedSortOrder =
        sortOrder?.trim().toLowerCase();

    switch (normalizedSortBy) {
      case 'price':
        return normalizedSortOrder == 'desc'
            ? 'high_price'
            : 'low_price';

      case 'rating':
        return 'rating';

      case 'distance':
        return 'nearest';

      case 'createdat':
      case 'created_at':
      case 'date':
        return normalizedSortOrder == 'asc'
            ? 'oldest'
            : 'newest';

      default:
        return null;
    }
  }
}