import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/service_model.dart';

class ServiceService {
  ServiceService._();

  static final ServiceService _instance =
      ServiceService._();

  static ServiceService get instance => _instance;

  final ApiService _apiService = ApiService.instance;

  // =====================================================
  // ENDPOINTS
  // ApiService base URL already includes /api
  // =====================================================

  static const String _servicesEndpoint = '/services';

  static const String _myServicesEndpoint =
      '/services/my-services';

  // =====================================================
  // CREATE SERVICE
  // POST /api/services
  // Authentication: provider token required
  // =====================================================

  Future<ServiceModel> createService({
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.post(
        _servicesEndpoint,
        body: _normalizeServicePayload(data),
      );

      final responseMap = _normalizeMap(response);

      final serviceData = _extractSingleService(
        responseMap,
      );

      return ServiceModel.fromJson(serviceData);
    } catch (error, stackTrace) {
      log(
        'Create Service Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET PROVIDER'S SERVICES
  // GET /api/services/my-services
  // Authentication: provider token required
  // =====================================================

  Future<List<ServiceModel>> getMyServices() async {
    try {
      final response = await _apiService.get(
        _myServicesEndpoint,
      );

      return _parseServiceList(response);
    } catch (error, stackTrace) {
      log(
        'Get My Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET ALL PUBLIC SERVICES
  // GET /api/services
  // =====================================================

  Future<List<ServiceModel>> getServices({
    String? search,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim().toLowerCase(),
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (sort != null && sort.trim().isNotEmpty)
          'sort': sort.trim(),
        'page': page < 1 ? 1 : page,
        'limit': limit < 1 ? 20 : limit,
      };

      final endpoint = _buildEndpoint(
        _servicesEndpoint,
        queryParameters,
      );

      final response = await _apiService.get(
        endpoint,
      );

      return _parseServiceList(response);
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
      final normalizedId = _requireServiceId(serviceId);

      final response = await _apiService.get(
        '$_servicesEndpoint/$normalizedId',
      );

      final responseMap = _normalizeMap(response);

      return ServiceModel.fromJson(
        _extractSingleService(responseMap),
      );
    } catch (error, stackTrace) {
      log(
        'Get Service By ID Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // UPDATE SERVICE
  // PUT /api/services/:id
  // Authentication: provider token required
  // =====================================================

  Future<ServiceModel> updateService({
    required String serviceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final normalizedId = _requireServiceId(serviceId);

      final response = await _apiService.put(
        '$_servicesEndpoint/$normalizedId',
        body: _normalizeServicePayload(data),
      );

      final responseMap = _normalizeMap(response);

      return ServiceModel.fromJson(
        _extractSingleService(responseMap),
      );
    } catch (error, stackTrace) {
      log(
        'Update Service Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // DELETE SERVICE
  // DELETE /api/services/:id
  // Authentication: provider token required
  // =====================================================

  Future<bool> deleteService(
    String serviceId,
  ) async {
    try {
      final normalizedId = _requireServiceId(serviceId);

      final response = await _apiService.delete(
        '$_servicesEndpoint/$normalizedId',
      );

      final responseMap = _normalizeMap(response);

      return responseMap.isEmpty ||
          responseMap['success'] == true ||
          responseMap['deletedId'] != null;
    } catch (error, stackTrace) {
      log(
        'Delete Service Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // UPDATE SERVICE STATUS
  // PATCH /api/services/:id/status
  // =====================================================

  Future<ServiceModel> updateServiceStatus({
    required String serviceId,
    bool? isActive,
    bool? isAvailable,
  }) async {
    try {
      final normalizedId = _requireServiceId(serviceId);

      if (isActive == null && isAvailable == null) {
        throw ArgumentError(
          'isActive or isAvailable must be provided.',
        );
      }

      final response = await _apiService.patch(
        '$_servicesEndpoint/$normalizedId/status',
        body: {
          if (isActive != null) 'isActive': isActive,
          if (isAvailable != null)
            'isAvailable': isAvailable,
        },
      );

      final responseMap = _normalizeMap(response);

      return ServiceModel.fromJson(
        _extractSingleService(responseMap),
      );
    } catch (error, stackTrace) {
      log(
        'Update Service Status Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // ACTIVATE SERVICE
  // =====================================================

  Future<bool> activateService(
    String serviceId,
  ) async {
    try {
      await updateServiceStatus(
        serviceId: serviceId,
        isActive: true,
        isAvailable: true,
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Activate Service Error: $error',
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // =====================================================
  // DEACTIVATE SERVICE
  // =====================================================

  Future<bool> deactivateService(
    String serviceId,
  ) async {
    try {
      await updateServiceStatus(
        serviceId: serviceId,
        isActive: false,
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Deactivate Service Error: $error',
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // =====================================================
  // UPDATE AVAILABILITY
  // PATCH /api/services/:id/status
  // =====================================================

  Future<bool> updateAvailability({
    required String serviceId,
    required bool isAvailable,
  }) async {
    try {
      await updateServiceStatus(
        serviceId: serviceId,
        isAvailable: isAvailable,
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Update Service Availability Error: $error',
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // =====================================================
  // SEARCH SERVICES
  // GET /api/services/search
  // =====================================================

  Future<List<ServiceModel>> searchServices({
    required String keyword,
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (keyword.trim().isNotEmpty)
          'keyword': keyword.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim().toLowerCase(),
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        if (radius != null) 'radius': radius,
      };

      final endpoint = _buildEndpoint(
        '$_servicesEndpoint/search',
        queryParameters,
      );

      final response = await _apiService.get(
        endpoint,
      );

      return _parseServiceList(response);
    } catch (error, stackTrace) {
      log(
        'Search Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET SERVICES BY CATEGORY
  // Uses GET /api/services?category=...
  // =====================================================

  Future<List<ServiceModel>> getServicesByCategory(
    String category,
  ) async {
    try {
      final normalizedCategory = category.trim();

      if (normalizedCategory.isEmpty) {
        return getServices();
      }

      return getServices(
        category: normalizedCategory,
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
  // Uses GET /api/services?featured=true
  // =====================================================

  Future<List<ServiceModel>> getFeaturedServices() async {
    try {
      final endpoint = _buildEndpoint(
        _servicesEndpoint,
        {
          'featured': true,
          'sort': 'newest',
          'limit': 100,
        },
      );

      final response = await _apiService.get(
        endpoint,
      );

      return _parseServiceList(response);
    } catch (error, stackTrace) {
      log(
        'Get Featured Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // GET NEARBY SERVICES
  // GET /api/services/nearby
  // =====================================================

  Future<List<ServiceModel>> getNearbyServices({
    required double latitude,
    required double longitude,
    double radius = 30000,
    String? category,
  }) async {
    try {
      final endpoint = _buildEndpoint(
        '$_servicesEndpoint/nearby',
        {
          'lat': latitude,
          'lng': longitude,
          'radius': radius,
          if (category != null &&
              category.trim().isNotEmpty)
            'category': category.trim().toLowerCase(),
        },
      );

      final response = await _apiService.get(
        endpoint,
      );

      return _parseServiceList(response);
    } catch (error, stackTrace) {
      log(
        'Get Nearby Services Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // UPLOAD SERVICE IMAGES
  //
  // No separate image-upload backend route is currently
  // defined. This updates an existing service through the
  // standard service update endpoint.
  // =====================================================

  Future<List<String>> uploadServiceImages({
    String? serviceId,
    required List<String> imageUrls,
  }) async {
    try {
      final normalizedImages = imageUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toSet()
          .toList();

      if (serviceId == null ||
          serviceId.trim().isEmpty) {
        return normalizedImages;
      }

      final service = await updateService(
        serviceId: serviceId,
        data: {
          'image': normalizedImages.isNotEmpty
              ? normalizedImages.first
              : '',
          'imageUrl': normalizedImages.isNotEmpty
              ? normalizedImages.first
              : '',
          'images': normalizedImages,
        },
      );

      return _extractImageUrls(service);
    } catch (error, stackTrace) {
      log(
        'Upload Service Images Error: $error',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  // =====================================================
  // REMOVE SERVICE IMAGE
  //
  // The backend has no dedicated remove-image route.
  // Supply remainingImages when removing one image.
  // =====================================================

  Future<bool> removeServiceImage({
    required String serviceId,
    required String imageUrl,
    List<String>? remainingImages,
  }) async {
    try {
      final normalizedImageUrl = imageUrl.trim();

      final images = (remainingImages ?? <String>[])
          .map((url) => url.trim())
          .where(
            (url) =>
                url.isNotEmpty &&
                url != normalizedImageUrl,
          )
          .toSet()
          .toList();

      await updateService(
        serviceId: serviceId,
        data: {
          'images': images,
          'image': images.isNotEmpty ? images.first : '',
          'imageUrl':
              images.isNotEmpty ? images.first : '',
        },
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Remove Service Image Error: $error',
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // =====================================================
  // UPDATE SERVICE PRICE
  //
  // Uses standard PUT /api/services/:id because the backend
  // has no dedicated /price route.
  // =====================================================

  Future<bool> updateServicePrice({
    required String serviceId,
    required double price,
    double? discountedPrice,
  }) async {
    try {
      if (price < 0) {
        throw ArgumentError(
          'Service price cannot be negative.',
        );
      }

      await updateService(
        serviceId: serviceId,
        data: {
          'price': price,
          'basePrice': price,
          if (discountedPrice != null)
            'discountedPrice': discountedPrice,
        },
      );

      return true;
    } catch (error, stackTrace) {
      log(
        'Update Service Price Error: $error',
        stackTrace: stackTrace,
      );

      return false;
    }
  }

  // =====================================================
  // GET SERVICE ANALYTICS
  //
  // A dedicated backend analytics route is not currently
  // available. Return locally derived service information
  // instead of calling a nonexistent URL.
  // =====================================================

  Future<Map<String, dynamic>> getServiceAnalytics(
    String serviceId,
  ) async {
    try {
      final service = await getServiceById(serviceId);

      final serviceJson = _serviceToJson(service);

      return {
        'success': true,
        'serviceId': serviceId,
        'rating': serviceJson['rating'] ?? 0,
        'totalReviews':
            serviceJson['totalReviews'] ?? 0,
        'isActive':
            serviceJson['isActive'] ?? false,
        'isAvailable':
            serviceJson['isAvailable'] ?? false,
        'service': serviceJson,
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
  // GET TOTAL SERVICE COUNT
  // Uses GET /api/services/my-services
  // =====================================================

  Future<int> getTotalServiceCount() async {
    try {
      final services = await getMyServices();

      return services.length;
    } catch (error, stackTrace) {
      log(
        'Get Total Service Count Error: $error',
        stackTrace: stackTrace,
      );

      return 0;
    }
  }

  // =====================================================
  // RESPONSE HELPERS
  // =====================================================

  List<ServiceModel> _parseServiceList(
    dynamic response,
  ) {
    final responseMap = _normalizeMap(response);

    final dynamic rawServices =
        responseMap['services'] ??
        responseMap['data'] ??
        response;

    if (rawServices is! List) {
      return <ServiceModel>[];
    }

    return rawServices
        .whereType<Map>()
        .map(
          (json) => ServiceModel.fromJson(
            json.map(
              (key, value) => MapEntry(
                key.toString(),
                value,
              ),
            ),
          ),
        )
        .toList();
  }

  Map<String, dynamic> _extractSingleService(
    Map<String, dynamic> response,
  ) {
    final dynamic rawService =
        response['service'] ??
        response['data'] ??
        response;

    if (rawService is Map<String, dynamic>) {
      return rawService;
    }

    if (rawService is Map) {
      return rawService.map(
        (key, value) => MapEntry(
          key.toString(),
          value,
        ),
      );
    }

    throw const FormatException(
      'The backend returned an invalid service response.',
    );
  }

  Map<String, dynamic> _normalizeMap(
    dynamic response,
  ) {
    if (response == null) {
      return <String, dynamic>{};
    }

    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return response.map(
        (key, value) => MapEntry(
          key.toString(),
          value,
        ),
      );
    }

    return <String, dynamic>{
      'data': response,
    };
  }

  // =====================================================
  // REQUEST HELPERS
  // =====================================================

  Map<String, dynamic> _normalizeServicePayload(
    Map<String, dynamic> data,
  ) {
    final payload = Map<String, dynamic>.from(data);

    final category =
        payload['category']?.toString().trim().toLowerCase();

    if (category != null && category.isNotEmpty) {
      payload['category'] = category;

      final rawCategories = payload['categories'];

      final categories = <String>{
        category,
        if (rawCategories is List)
          ...rawCategories
              .map(
                (value) => value
                    .toString()
                    .trim()
                    .toLowerCase(),
              )
              .where((value) => value.isNotEmpty),
      }.toList();

      payload['categories'] = categories;
    }

    final price = _toDouble(
      payload['price'],
    );

    final basePrice = _toDouble(
      payload['basePrice'],
    );

    final pricePerHour = _toDouble(
      payload['pricePerHour'],
    );

    final pricePerDay = _toDouble(
      payload['pricePerDay'],
    );

    final primaryPrice = price > 0
        ? price
        : basePrice > 0
            ? basePrice
            : pricePerDay > 0
                ? pricePerDay
                : pricePerHour;

    payload['price'] = primaryPrice;
    payload['basePrice'] =
        basePrice > 0 ? basePrice : primaryPrice;
    payload['pricePerHour'] = pricePerHour;
    payload['pricePerDay'] = pricePerDay;

    payload['serviceType'] =
        payload['serviceType']?.toString().trim().toLowerCase() ??
        'fixed';

    payload['currency'] =
        payload['currency']?.toString().trim().toUpperCase() ??
        'INR';

    payload['isActive'] = _toBool(
      payload['isActive'],
      fallback: true,
    );

    payload['isAvailable'] = _toBool(
      payload['isAvailable'],
      fallback: true,
    );

    payload['tags'] = _normalizeStringList(
      payload['tags'],
      lowercase: true,
    );

    payload['features'] = _normalizeStringList(
      payload['features'],
    );

    payload['images'] = _normalizeStringList(
      payload['images'],
    );

    return payload;
  }

  List<String> _normalizeStringList(
    dynamic value, {
    bool lowercase = false,
  }) {
    Iterable<dynamic> values;

    if (value is List) {
      values = value;
    } else if (value is String &&
        value.trim().isNotEmpty) {
      values = value.split(',');
    } else {
      values = const [];
    }

    return values
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .map(
          (item) =>
              lowercase ? item.toLowerCase() : item,
        )
        .toSet()
        .toList();
  }

  String _requireServiceId(String serviceId) {
    final normalizedId = serviceId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError(
        'Service ID is required.',
      );
    }

    return normalizedId;
  }

  String _buildEndpoint(
    String path,
    Map<String, dynamic> parameters,
  ) {
    final queryParameters = <String, String>{};

    parameters.forEach(
      (key, value) {
        if (value == null) {
          return;
        }

        final normalizedValue = value.toString().trim();

        if (normalizedValue.isNotEmpty) {
          queryParameters[key] = normalizedValue;
        }
      },
    );

    if (queryParameters.isEmpty) {
      return path;
    }

    final query = queryParameters.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}='
              '${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');

    return '$path?$query';
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  bool _toBool(
    dynamic value, {
    required bool fallback,
  }) {
    if (value is bool) {
      return value;
    }

    if (value == null) {
      return fallback;
    }

    final normalizedValue =
        value.toString().trim().toLowerCase();

    if (normalizedValue == 'true' ||
        normalizedValue == '1') {
      return true;
    }

    if (normalizedValue == 'false' ||
        normalizedValue == '0') {
      return false;
    }

    return fallback;
  }

  // =====================================================
  // MODEL COMPATIBILITY HELPERS
  // =====================================================

  Map<String, dynamic> _serviceToJson(
    ServiceModel service,
  ) {
    try {
      final dynamic serviceData = service;

      final dynamic json = serviceData.toJson();

      if (json is Map<String, dynamic>) {
        return json;
      }

      if (json is Map) {
        return json.map(
          (key, value) => MapEntry(
            key.toString(),
            value,
          ),
        );
      }
    } catch (_) {
      // The model may not expose toJson().
    }

    return <String, dynamic>{};
  }

  List<String> _extractImageUrls(
    ServiceModel service,
  ) {
    final json = _serviceToJson(service);

    final rawImages = json['images'];

    if (rawImages is List) {
      return rawImages
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .toList();
    }

    final imageUrl =
        json['imageUrl']?.toString().trim() ?? '';

    final image =
        json['image']?.toString().trim() ?? '';

    return <String>{
      if (imageUrl.isNotEmpty) imageUrl,
      if (image.isNotEmpty) image,
    }.toList();
  }
}