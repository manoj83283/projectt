class ServiceModel {
  final String id;

  final String providerId;
  final String providerName;

  final String categoryId;
  final String categoryName;

  final String title;
  final String description;

  final double price;
  final double discountedPrice;

  final double rating;
  final int reviewCount;

  final List<String> images;

  final String city;
  final String state;
  final String address;

  final bool isActive;
  final bool isFeatured;
  final bool isVerified;

  final int durationInHours;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.city,
    required this.state,
    required this.address,
    required this.isActive,
    required this.isFeatured,
    required this.isVerified,
    required this.durationInHours,
    this.createdAt,
    this.updatedAt,
  });

  // =============================================================
  // ✅ SAFE ALIAS GETTERS FOR EXISTING SCREENS
  // =============================================================

  /// ✅ Fixes: service.name
  String get name => title;

  /// ✅ Common backend alias
  String get serviceName => title;

  /// ✅ First image fallback
  String get imageUrl => images.isNotEmpty ? images.first : '';

  /// ✅ Category alias
  String get category => categoryName;

  /// ✅ Location alias
  String get location {
    if (address.isNotEmpty) return address;

    final parts = [
      city,
      state,
    ].where((e) => e.trim().isNotEmpty).toList();

    return parts.join(', ');
  }

  /// ✅ Availability alias
  bool get isAvailable => isActive;

  // =============================================================
  // ✅ EMPTY MODEL
  // =============================================================

  factory ServiceModel.empty() {
    return const ServiceModel(
      id: '',
      providerId: '',
      providerName: '',
      categoryId: '',
      categoryName: '',
      title: '',
      description: '',
      price: 0,
      discountedPrice: 0,
      rating: 0,
      reviewCount: 0,
      images: [],
      city: '',
      state: '',
      address: '',
      isActive: true,
      isFeatured: false,
      isVerified: false,
      durationInHours: 1,
    );
  }

  // =============================================================
  // ✅ JSON PARSER
  // =============================================================

  factory ServiceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final provider = json['provider'];

    String parsedProviderId = '';
    String parsedProviderName = '';

    if (provider is Map<String, dynamic>) {
      parsedProviderId = provider['_id']?.toString() ??
          provider['id']?.toString() ??
          '';

      parsedProviderName = provider['name']?.toString() ??
          provider['firstName']?.toString() ??
          provider['providerName']?.toString() ??
          '';
    } else {
      parsedProviderId = json['providerId']?.toString() ??
          json['provider']?.toString() ??
          '';

      parsedProviderName =
          json['providerName']?.toString() ?? '';
    }

    final dynamic rawImages = json['images'];

    List<String> parsedImages = [];

    if (rawImages is List) {
      parsedImages = rawImages
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    final imageUrl = json['imageUrl']?.toString() ??
        json['image']?.toString() ??
        '';

    if (parsedImages.isEmpty && imageUrl.isNotEmpty) {
      parsedImages = [imageUrl];
    }

    return ServiceModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      providerId: parsedProviderId,

      providerName: parsedProviderName,

      categoryId: json['categoryId']?.toString() ??
          json['category']?.toString() ??
          '',

      categoryName: json['categoryName']?.toString() ??
          json['category']?.toString() ??
          '',

      /// ✅ Supports both old title and backend name
      title: json['title']?.toString() ??
          json['name']?.toString() ??
          '',

      description:
          json['description']?.toString() ?? '',

      /// ✅ Supports price, pricePerDay, pricePerHour, basePrice
      price: _toDouble(
        json['price'] ??
            json['pricePerDay'] ??
            json['pricePerHour'] ??
            json['basePrice'],
      ),

      discountedPrice: _toDouble(
        json['discountedPrice'],
      ),

      rating: _toDouble(
        json['rating'],
      ),

      reviewCount: _toInt(
        json['reviewCount'] ??
            json['totalReviews'],
      ),

      images: parsedImages,

      city: json['city']?.toString() ?? '',

      state: json['state']?.toString() ?? '',

      address: json['address']?.toString() ??
          json['locationName']?.toString() ??
          json['location']?.toString() ??
          '',

      isActive: _toBool(
        json['isActive'] ??
            json['isAvailable'],
        defaultValue: true,
      ),

      isFeatured: _toBool(
        json['isFeatured'] ??
            json['isPopular'] ??
            json['isRecommended'],
      ),

      isVerified: _toBool(
        json['isVerified'],
      ),

      durationInHours: _toInt(
        json['durationInHours'] ??
            json['hours'] ??
            1,
      ),

      createdAt: _toDateTime(
        json['createdAt'],
      ),

      updatedAt: _toDateTime(
        json['updatedAt'],
      ),
    );
  }

  // =============================================================
  // ✅ TO JSON
  // =============================================================

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,

      'providerId': providerId,
      'providerName': providerName,

      'categoryId': categoryId,
      'categoryName': categoryName,
      'category': categoryName,

      'title': title,
      'name': title,

      'description': description,

      'price': price,
      'pricePerDay': price,
      'discountedPrice': discountedPrice,

      'rating': rating,
      'reviewCount': reviewCount,

      'images': images,
      'imageUrl': imageUrl,

      'city': city,
      'state': state,
      'address': address,
      'location': address,

      'isActive': isActive,
      'isAvailable': isActive,
      'isFeatured': isFeatured,
      'isVerified': isVerified,

      'durationInHours': durationInHours,

      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // =============================================================
  // ✅ COPY WITH
  // =============================================================

  ServiceModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? categoryId,
    String? categoryName,
    String? title,
    String? description,
    double? price,
    double? discountedPrice,
    double? rating,
    int? reviewCount,
    List<String>? images,
    String? city,
    String? state,
    String? address,
    bool? isActive,
    bool? isFeatured,
    bool? isVerified,
    int? durationInHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      discountedPrice:
          discountedPrice ?? this.discountedPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      images: images ?? this.images,
      city: city ?? this.city,
      state: state ?? this.state,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      durationInHours:
          durationInHours ?? this.durationInHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =============================================================
  // ✅ CALCULATED FIELDS
  // =============================================================

  bool get hasDiscount {
    return discountedPrice > 0 &&
        discountedPrice < price;
  }

  double get finalPrice {
    return hasDiscount ? discountedPrice : price;
  }

  double get discountPercentage {
    if (!hasDiscount || price <= 0) return 0;

    return ((price - discountedPrice) / price) * 100;
  }

  // =============================================================
  // ✅ SAFE PARSERS
  // =============================================================

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _toBool(
    dynamic value, {
    bool defaultValue = false,
  }) {
    if (value == null) return defaultValue;

    if (value is bool) return value;

    final text = value.toString().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes';
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    return DateTime.tryParse(
      value.toString(),
    );
  }

  // =============================================================
  // ✅ OVERRIDES
  // =============================================================

  @override
  String toString() {
    return 'ServiceModel(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ServiceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}