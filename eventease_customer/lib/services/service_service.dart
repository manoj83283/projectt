import '../models/service_model.dart';
import 'api_service.dart';

class ServiceService {
  ServiceService._();

  static final ServiceService instance = ServiceService._();

  // ==========================================
  // RESPONSE HELPERS
  // ==========================================

  dynamic _responseData(dynamic response) {
    try {
      return response.data;
    } catch (_) {
      return response;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  dynamic _extractSingle(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map<String, dynamic>) {
      return data['data'] ?? data['service'] ?? data['result'] ?? data;
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      return map['data'] ?? map['service'] ?? map['result'] ?? map;
    }

    return data;
  }

  List<dynamic> _extractList(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map<String, dynamic>) {
      final dynamic list = data['data'] ??
          data['services'] ??
          data['items'] ??
          data['results'];

      if (list is List) {
        return list;
      }
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);

      final dynamic list = map['data'] ??
          map['services'] ??
          map['items'] ??
          map['results'];

      if (list is List) {
        return list;
      }
    }

    if (data is List) {
      return data;
    }

    return [];
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    final dynamic data = _responseData(response);

    if (data is Map<String, dynamic>) {
      final dynamic payload = data['data'] ?? data;

      if (payload is Map<String, dynamic>) {
        return payload;
      }

      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
    }

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final dynamic payload = map['data'] ?? map;

      if (payload is Map<String, dynamic>) {
        return payload;
      }

      if (payload is Map) {
        return Map<String, dynamic>.from(payload);
      }
    }

    return <String, dynamic>{};
  }

  ServiceModel _serviceFromResponse(dynamic response) {
    return ServiceModel.fromMap(
      _asMap(
        _extractSingle(response),
      ),
    );
  }

  List<ServiceModel> _servicesFromResponse(dynamic response) {
    return _extractList(response)
        .map(
          (item) => ServiceModel.fromMap(
            _asMap(item),
          ),
        )
        .toList();
  }

  // ==========================================
  // GET ALL SERVICES
  // Supports keyword and search
  // ==========================================

  Future<List<ServiceModel>> getServices({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? keyword,
    String? search,
    String? location,
    double? minPrice,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? radius,
    String? sortBy,
    String? sortOrder,
  }) async {
    final String? searchValue = search ?? keyword;

    final dynamic response = await ApiService.instance.get(
      '/services',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (categoryId != null && categoryId.trim().isNotEmpty)
          'categoryId': categoryId.trim(),
        if (searchValue != null && searchValue.trim().isNotEmpty)
          'search': searchValue.trim(),
        if (searchValue != null && searchValue.trim().isNotEmpty)
          'keyword': searchValue.trim(),
        if (location != null && location.trim().isNotEmpty)
          'location': location.trim(),
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
        if (sortBy != null && sortBy.trim().isNotEmpty)
          'sortBy': sortBy.trim(),
        if (sortOrder != null && sortOrder.trim().isNotEmpty)
          'sortOrder': sortOrder.trim(),
      },
    );

    return _servicesFromResponse(response);
  }

  // ==========================================
  // GET SERVICE BY ID
  // ==========================================

  Future<ServiceModel> getServiceById(
    String serviceId,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/services/$serviceId',
    );

    return _serviceFromResponse(response);
  }

  // ==========================================
  // FEATURED SERVICES
  // ==========================================

  Future<List<ServiceModel>> getFeaturedServices() async {
    final dynamic response = await ApiService.instance.get(
      '/services/featured',
    );

    return _servicesFromResponse(response);
  }

  // ==========================================
  // POPULAR SERVICES
  // ==========================================

  Future<List<ServiceModel>> getPopularServices() async {
    final dynamic response = await ApiService.instance.get(
      '/services/popular',
    );

    return _servicesFromResponse(response);
  }

  // ==========================================
  // SEARCH SERVICES
  // ==========================================

  Future<List<ServiceModel>> searchServices(
    String keyword,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/services/search',
      queryParameters: {
        'keyword': keyword.trim(),
        'search': keyword.trim(),
      },
    );

    return _servicesFromResponse(response);
  }

  // ==========================================
  // CATEGORY SERVICES
  // ==========================================

  Future<List<ServiceModel>> getServicesByCategory(
    String categoryId,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/services/category/$categoryId',
    );

    return _servicesFromResponse(response);
  }

  // ==========================================
  // NEARBY SERVICES
  // ==========================================

  Future<List<ServiceModel>> getNearbyServices({
    required double latitude,
    required double longitude,
    double radius = 20,
  }) async {
    final dynamic response = await ApiService.instance.get(
      '/services/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );

    return _servicesFromResponse(response);
  }

  // ==========================================
  // PROVIDER SERVICES
  // Supports:
  // getProviderServices(providerId)
  // ==========================================

  Future<List<ServiceModel>> getProviderServices(
    String providerId, {
    int page = 1,
    int limit = 20,
  }) async {
    final dynamic response = await ApiService.instance.get(
      '/providers/$providerId/services',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return _servicesFromResponse(response);
  }

  // ==========================================
  // CHECK AVAILABILITY
  // Supports bookingDate as DateTime or String
  // ==========================================

  Future<Map<String, dynamic>> checkAvailability({
    required String serviceId,
    DateTime? date,
    dynamic bookingDate,
    String? time,
    String? bookingTime,
  }) async {
    String? resolvedBookingDate;

    if (bookingDate is DateTime) {
      resolvedBookingDate = bookingDate.toIso8601String();
    } else if (bookingDate != null) {
      resolvedBookingDate = bookingDate.toString();
    }

    final dynamic response = await ApiService.instance.get(
      '/services/$serviceId/availability',
      queryParameters: {
        if (date != null) 'date': date.toIso8601String(),
        if (resolvedBookingDate != null &&
            resolvedBookingDate.trim().isNotEmpty)
          'bookingDate': resolvedBookingDate.trim(),
        if (time != null && time.trim().isNotEmpty) 'time': time.trim(),
        if (bookingTime != null && bookingTime.trim().isNotEmpty)
          'bookingTime': bookingTime.trim(),
      },
    );

    return _extractMap(response);
  }

  // ==========================================
  // CREATE SERVICE
  // Supports:
  // name, title, gallery, images, data
  // ==========================================

  Future<ServiceModel> createService({
    String? name,
    String? title,
    String? description,
    String? categoryId,
    double? price,
    List<String>? gallery,
    List<String>? images,
    bool isFeatured = false,
    Map<String, dynamic>? data,
  }) async {
    final String resolvedName = (name ?? title ?? '').trim();

    final List<String> resolvedImages = images ?? gallery ?? <String>[];

    final dynamic response = await ApiService.instance.post(
      '/services',
      data: {
        ...?data,
        if (resolvedName.isNotEmpty) 'name': resolvedName,
        if (resolvedName.isNotEmpty) 'title': resolvedName,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (categoryId != null && categoryId.trim().isNotEmpty)
          'categoryId': categoryId.trim(),
        if (price != null) 'price': price,
        'gallery': resolvedImages,
        'images': resolvedImages,
        'isFeatured': isFeatured,
      },
    );

    return _serviceFromResponse(response);
  }

  // ==========================================
  // UPDATE SERVICE
  // Supports:
  // name, title, gallery, images, data
  // ==========================================

  Future<ServiceModel> updateService({
    required String serviceId,
    String? name,
    String? title,
    String? description,
    double? price,
    bool? isAvailable,
    bool? isFeatured,
    String? categoryId,
    List<String>? gallery,
    List<String>? images,
    Map<String, dynamic>? data,
  }) async {
    final String? resolvedName = name ?? title;

    final List<String>? resolvedImages =
        images != null && images.isNotEmpty ? images : gallery;

    final dynamic response = await ApiService.instance.put(
      '/services/$serviceId',
      data: {
        ...?data,
        if (resolvedName != null && resolvedName.trim().isNotEmpty)
          'name': resolvedName.trim(),
        if (resolvedName != null && resolvedName.trim().isNotEmpty)
          'title': resolvedName.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (categoryId != null && categoryId.trim().isNotEmpty)
          'categoryId': categoryId.trim(),
        if (price != null) 'price': price,
        if (isAvailable != null) 'isAvailable': isAvailable,
        if (isFeatured != null) 'isFeatured': isFeatured,
        if (resolvedImages != null) 'gallery': resolvedImages,
        if (resolvedImages != null) 'images': resolvedImages,
      },
    );

    return _serviceFromResponse(response);
  }

  // ==========================================
  // DELETE SERVICE
  // ==========================================

  Future<bool> deleteService(
    String serviceId,
  ) async {
    await ApiService.instance.delete(
      '/services/$serviceId',
    );

    return true;
  }

  // ==========================================
  // HOME SERVICES
  // ==========================================

  Future<List<ServiceModel>> getHomeServices() async {
    final dynamic response = await ApiService.instance.get(
      '/services/home',
    );

    return _servicesFromResponse(response);
  }

  // ==========================================
  // SERVICE REVIEWS
  // ==========================================

  Future<dynamic> getServiceReviews(
    String serviceId,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/services/$serviceId/reviews',
    );

    return _responseData(response);
  }

  // ==========================================
  // SERVICE ANALYTICS
  // Supports:
  // getServiceAnalytics(serviceId)
  // ==========================================

  Future<Map<String, dynamic>> getServiceAnalytics(
    String serviceId,
  ) async {
    final dynamic response = await ApiService.instance.get(
      '/services/$serviceId/analytics',
    );

    return _extractMap(response);
  }
}