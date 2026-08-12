import 'dart:convert';

class ServiceModel {
  final String id;
  final String name;
  final String description;

  final String categoryId;
  final String categoryName;
  final List<String> categories;

  final String providerId;
  final String providerName;
  final Map<String, dynamic>? provider;

  final String? thumbnail;
  final List<String> gallery;

  final double price;
  final double basePrice;
  final double pricePerHour;
  final double pricePerDay;
  final double? discountedPrice;

  final String currency;
  final String serviceType;

  final double rating;
  final int reviewsCount;

  final bool isFeatured;
  final bool isPopular;
  final bool isRecommended;
  final bool isAvailable;
  final bool isActive;

  final String approvalStatus;

  final String? address;
  final double? latitude;
  final double? longitude;
  final double? distance;

  final List<String> tags;
  final List<String> features;

  final int bookingCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.providerId,
    required this.providerName,
    required this.price,
    this.categories = const [],
    this.provider,
    this.thumbnail,
    this.gallery = const [],
    this.basePrice = 0,
    this.pricePerHour = 0,
    this.pricePerDay = 0,
    this.discountedPrice,
    this.currency = 'INR',
    this.serviceType = 'fixed',
    this.rating = 0,
    this.reviewsCount = 0,
    this.isFeatured = false,
    this.isPopular = false,
    this.isRecommended = false,
    this.isAvailable = true,
    this.isActive = true,
    this.approvalStatus = 'approved',
    this.address,
    this.latitude,
    this.longitude,
    this.distance,
    this.tags = const [],
    this.features = const [],
    this.bookingCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // =====================================================
  // EMPTY
  // =====================================================

  factory ServiceModel.empty() {
    return const ServiceModel(
      id: '',
      name: '',
      description: '',
      categoryId: '',
      categoryName: '',
      providerId: '',
      providerName: '',
      price: 0,
    );
  }

  // =====================================================
  // FROM JSON/MAP
  // =====================================================

  factory ServiceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceModel.fromMap(json);
  }

  factory ServiceModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final providerMap = _normalizeProvider(
      map['provider'],
    );

    final category = _readString(
      map['category'],
      fallback: _readString(
        map['categoryName'],
      ),
    );

    final categories = _readStringList(
      map['categories'],
    );

    final resolvedCategories = <String>{
      if (category.isNotEmpty) category,
      ...categories,
    }.toList();

    final providerId = providerMap != null
        ? _readString(
            providerMap['_id'] ?? providerMap['id'],
          )
        : _readString(
            map['providerId'] ?? map['provider'],
          );

    final providerName = _resolveProviderName(
      map,
      providerMap,
    );

    final images = _resolveImages(map);

    final thumbnail = _resolveThumbnail(
      map,
      images,
    );

    final coordinates = _resolveCoordinates(map);

    final price = _resolvePrice(map);

    final basePrice = _readDouble(
      map['basePrice'],
      fallback: price,
    );

    final discountedPrice = _readNullableDouble(
      map['discountedPrice'],
    );

    return ServiceModel(
      id: _readString(
        map['_id'] ?? map['id'],
      ),
      name: _readString(
        map['name'],
      ),
      description: _readString(
        map['description'],
      ),
      categoryId: _readString(
        map['categoryId'],
        fallback: category,
      ),
      categoryName: _readString(
        map['categoryName'],
        fallback: category,
      ),
      categories: resolvedCategories,
      providerId: providerId,
      providerName: providerName,
      provider: providerMap,
      thumbnail: thumbnail,
      gallery: images,
      price: price,
      basePrice: basePrice,
      pricePerHour: _readDouble(
        map['pricePerHour'],
      ),
      pricePerDay: _readDouble(
        map['pricePerDay'],
      ),
      discountedPrice: discountedPrice,
      currency: _readString(
        map['currency'],
        fallback: 'INR',
      ).toUpperCase(),
      serviceType: _readString(
        map['serviceType'],
        fallback: 'fixed',
      ).toLowerCase(),
      rating: _readDouble(
        map['rating'],
      ),
      reviewsCount: _readInt(
        map['totalReviews'] ??
            map['reviewsCount'] ??
            map['reviewCount'],
      ),
      isFeatured: _readBool(
        map['isFeatured'],
      ),
      isPopular: _readBool(
        map['isPopular'],
      ),
      isRecommended: _readBool(
        map['isRecommended'],
      ),
      isAvailable: _readBool(
        map['isAvailable'],
        fallback: true,
      ),
      isActive: _readBool(
        map['isActive'],
        fallback: true,
      ),
      approvalStatus: _readString(
        map['approvalStatus'],
        fallback: 'approved',
      ).toLowerCase(),
      address: _nullableString(
        map['location'] ?? map['address'],
      ),
      longitude: coordinates.$1,
      latitude: coordinates.$2,
      distance: _readNullableDouble(
        map['distance'],
      ),
      tags: _readStringList(
        map['tags'],
      ),
      features: _readStringList(
        map['features'],
      ),
      bookingCount: _readInt(
        map['bookingCount'] ??
            map['totalBookings'],
      ),
      createdAt: _readDateTime(
        map['createdAt'],
      ),
      updatedAt: _readDateTime(
        map['updatedAt'],
      ),
    );
  }

  // =====================================================
  // FROM JSON STRING
  // =====================================================

  factory ServiceModel.fromJsonString(
    String source,
  ) {
    final decoded = jsonDecode(source);

    if (decoded is! Map) {
      throw const FormatException(
        'Service JSON must contain an object.',
      );
    }

    return ServiceModel.fromMap(
      decoded.map(
        (key, value) => MapEntry(
          key.toString(),
          value,
        ),
      ),
    );
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    List<String>? categories,
    String? providerId,
    String? providerName,
    Map<String, dynamic>? provider,
    String? thumbnail,
    List<String>? gallery,
    double? price,
    double? basePrice,
    double? pricePerHour,
    double? pricePerDay,
    double? discountedPrice,
    bool clearDiscountedPrice = false,
    String? currency,
    String? serviceType,
    double? rating,
    int? reviewsCount,
    bool? isFeatured,
    bool? isPopular,
    bool? isRecommended,
    bool? isAvailable,
    bool? isActive,
    String? approvalStatus,
    String? address,
    double? latitude,
    double? longitude,
    double? distance,
    List<String>? tags,
    List<String>? features,
    int? bookingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
          description ?? this.description,
      categoryId:
          categoryId ?? this.categoryId,
      categoryName:
          categoryName ?? this.categoryName,
      categories:
          categories ?? this.categories,
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ?? this.providerName,
      provider: provider ?? this.provider,
      thumbnail:
          thumbnail ?? this.thumbnail,
      gallery: gallery ?? this.gallery,
      price: price ?? this.price,
      basePrice:
          basePrice ?? this.basePrice,
      pricePerHour:
          pricePerHour ?? this.pricePerHour,
      pricePerDay:
          pricePerDay ?? this.pricePerDay,
      discountedPrice: clearDiscountedPrice
          ? null
          : discountedPrice ??
              this.discountedPrice,
      currency:
          currency ?? this.currency,
      serviceType:
          serviceType ?? this.serviceType,
      rating: rating ?? this.rating,
      reviewsCount:
          reviewsCount ?? this.reviewsCount,
      isFeatured:
          isFeatured ?? this.isFeatured,
      isPopular:
          isPopular ?? this.isPopular,
      isRecommended:
          isRecommended ??
              this.isRecommended,
      isAvailable:
          isAvailable ?? this.isAvailable,
      isActive:
          isActive ?? this.isActive,
      approvalStatus:
          approvalStatus ??
              this.approvalStatus,
      address: address ?? this.address,
      latitude:
          latitude ?? this.latitude,
      longitude:
          longitude ?? this.longitude,
      distance:
          distance ?? this.distance,
      tags: tags ?? this.tags,
      features:
          features ?? this.features,
      bookingCount:
          bookingCount ?? this.bookingCount,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  // =====================================================
  // TO MAP / JSON
  // =====================================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'description': description,
      'category': categoryName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categories': categories,
      'provider': provider ?? providerId,
      'providerId': providerId,
      'providerName': providerName,
      'thumbnail': thumbnail,
      'image': thumbnail,
      'imageUrl': thumbnail,
      'images': gallery,
      'gallery': gallery,
      'price': price,
      'basePrice': basePrice,
      'pricePerHour': pricePerHour,
      'pricePerDay': pricePerDay,
      'discountedPrice': discountedPrice,
      'currency': currency,
      'serviceType': serviceType,
      'rating': rating,
      'totalReviews': reviewsCount,
      'reviewsCount': reviewsCount,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'isRecommended': isRecommended,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'approvalStatus': approvalStatus,
      'location': address,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      if (latitude != null &&
          longitude != null)
        'locationPoint': {
          'type': 'Point',
          'coordinates': [
            longitude,
            latitude,
          ],
        },
      'distance': distance,
      'tags': tags,
      'features': features,
      'bookingCount': bookingCount,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  String toJsonString() {
    return jsonEncode(toMap());
  }

  // =====================================================
  // GETTERS
  // =====================================================

  bool get hasDiscount {
    return discountedPrice != null &&
        discountedPrice! >= 0 &&
        discountedPrice! < price;
  }

  double get finalPrice {
    return hasDiscount
        ? discountedPrice!
        : price;
  }

  double get discountAmount {
    if (!hasDiscount) {
      return 0;
    }

    return price - finalPrice;
  }

  int get discountPercentage {
    if (!hasDiscount || price <= 0) {
      return 0;
    }

    return ((discountAmount / price) * 100)
        .round();
  }

  String get imageUrl {
    return thumbnail ?? '';
  }

  bool get hasImage {
    return imageUrl.trim().isNotEmpty;
  }

  bool get hasGallery {
    return gallery.isNotEmpty;
  }

  bool get hasLocation {
    return address != null &&
        address!.trim().isNotEmpty;
  }

  bool get hasCoordinates {
    return latitude != null &&
        longitude != null &&
        !(latitude == 0 && longitude == 0);
  }

  bool get isCustomerVisible {
    return isActive &&
        isAvailable &&
        approvalStatus == 'approved';
  }

  String get formattedPrice {
    return '₹${finalPrice.toStringAsFixed(0)}';
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  String get displayCategory {
    if (categoryName.trim().isNotEmpty) {
      return categoryName;
    }

    if (categories.isNotEmpty) {
      return categories.first;
    }

    return 'Service';
  }

  String get displayProviderName {
    return providerName.trim().isEmpty
        ? 'Provider'
        : providerName;
  }

  // =====================================================
  // PARSING HELPERS
  // =====================================================

  static Map<String, dynamic>?
      _normalizeProvider(dynamic value) {
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

    return null;
  }

  static String _resolveProviderName(
    Map<String, dynamic> service,
    Map<String, dynamic>? provider,
  ) {
    final directName = _readString(
      service['providerName'],
    );

    if (directName.isNotEmpty) {
      return directName;
    }

    if (provider == null) {
      return 'Provider';
    }

    final businessName = _readString(
      provider['businessName'] ??
          provider['shopName'],
    );

    if (businessName.isNotEmpty) {
      return businessName;
    }

    final firstName = _readString(
      provider['firstName'],
    );

    final lastName = _readString(
      provider['lastName'],
    );

    final fullName = [
      firstName,
      lastName,
    ].where(
      (value) => value.isNotEmpty,
    ).join(' ').trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    return _readString(
      provider['name'],
      fallback: 'Provider',
    );
  }

  static List<String> _resolveImages(
    Map<String, dynamic> map,
  ) {
    final images = <String>{
      ..._readStringList(
        map['images'],
      ),
      ..._readStringList(
        map['gallery'],
      ),
    };

    final image = _readString(
      map['image'],
    );

    final imageUrl = _readString(
      map['imageUrl'],
    );

    final thumbnail = _readString(
      map['thumbnail'],
    );

    if (image.isNotEmpty) {
      images.add(image);
    }

    if (imageUrl.isNotEmpty) {
      images.add(imageUrl);
    }

    if (thumbnail.isNotEmpty) {
      images.add(thumbnail);
    }

    return images.toList();
  }

  static String? _resolveThumbnail(
    Map<String, dynamic> map,
    List<String> images,
  ) {
    final thumbnail = _nullableString(
      map['thumbnail'] ??
          map['imageUrl'] ??
          map['image'],
    );

    if (thumbnail != null) {
      return thumbnail;
    }

    return images.isNotEmpty
        ? images.first
        : null;
  }

  static (double?, double?)
      _resolveCoordinates(
    Map<String, dynamic> map,
  ) {
    double? longitude = _readNullableDouble(
      map['longitude'],
    );

    double? latitude = _readNullableDouble(
      map['latitude'],
    );

    final geoFields = [
      map['locationPoint'],
      map['locationGeo'],
      map['geoLocation'],
    ];

    for (final geoField in geoFields) {
      if (longitude != null &&
          latitude != null) {
        break;
      }

      if (geoField is! Map) {
        continue;
      }

      final coordinates =
          geoField['coordinates'];

      if (coordinates is List &&
          coordinates.length >= 2) {
        longitude ??=
            _readNullableDouble(
          coordinates[0],
        );

        latitude ??=
            _readNullableDouble(
          coordinates[1],
        );
      }
    }

    return (
      longitude,
      latitude,
    );
  }

  static double _resolvePrice(
    Map<String, dynamic> map,
  ) {
    final values = [
      map['displayPrice'],
      map['price'],
      map['basePrice'],
      map['pricePerDay'],
      map['pricePerHour'],
    ];

    for (final value in values) {
      final parsed =
          _readNullableDouble(value);

      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }

    return 0;
  }

  static String _readString(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final result =
        value.toString().trim();

    return result.isEmpty
        ? fallback
        : result;
  }

  static String? _nullableString(
    dynamic value,
  ) {
    final result = _readString(value);

    return result.isEmpty ? null : result;
  }

  static List<String> _readStringList(
    dynamic value,
  ) {
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
        .map(
          (item) => item.toString().trim(),
        )
        .where(
          (item) => item.isNotEmpty,
        )
        .toSet()
        .toList();
  }

  static double _readDouble(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  static double? _readNullableDouble(
    dynamic value,
  ) {
    if (value == null || value == '') {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static int _readInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  static bool _readBool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) {
      return value;
    }

    if (value == null) {
      return fallback;
    }

    final normalized =
        value.toString().trim().toLowerCase();

    if (normalized == 'true' ||
        normalized == '1') {
      return true;
    }

    if (normalized == 'false' ||
        normalized == '0') {
      return false;
    }

    return fallback;
  }

  static DateTime? _readDateTime(
    dynamic value,
  ) {
    if (value is DateTime) {
      return value;
    }

    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  // =====================================================
  // OVERRIDES
  // =====================================================

  @override
  String toString() {
    return 'ServiceModel('
        'id: $id, '
        'name: $name, '
        'providerName: $providerName, '
        'price: $price'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ServiceModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}