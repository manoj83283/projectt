import 'dart:convert';

class ServiceModel {
  final String id;
  final String name;
  final String description;

  final String categoryId;
  final String categoryName;

  final String providerId;
  final String providerName;

  final String? thumbnail;
  final List<String> gallery;

  final double price;
  final double? discountedPrice;

  final double rating;
  final int reviewsCount;

  final bool isFeatured;
  final bool isAvailable;
  final bool isActive;

  final String? address;
  final double? latitude;
  final double? longitude;

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
    this.discountedPrice,
    this.thumbnail,
    this.gallery = const [],
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.isFeatured = false,
    this.isAvailable = true,
    this.isActive = true,
    this.address,
    this.latitude,
    this.longitude,
    this.bookingCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // EMPTY
  // ==========================================

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

  // ==========================================
  // COPY WITH
  // ==========================================

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    String? providerId,
    String? providerName,
    String? thumbnail,
    List<String>? gallery,
    double? price,
    double? discountedPrice,
    double? rating,
    int? reviewsCount,
    bool? isFeatured,
    bool? isAvailable,
    bool? isActive,
    String? address,
    double? latitude,
    double? longitude,
    int? bookingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      thumbnail: thumbnail ?? this.thumbnail,
      gallery: gallery ?? this.gallery,
      price: price ?? this.price,
      discountedPrice:
          discountedPrice ?? this.discountedPrice,
      rating: rating ?? this.rating,
      reviewsCount:
          reviewsCount ?? this.reviewsCount,
      isFeatured:
          isFeatured ?? this.isFeatured,
      isAvailable:
          isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bookingCount:
          bookingCount ?? this.bookingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // FROM MAP
  // ==========================================

  factory ServiceModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ServiceModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      name: map['name'] ?? '',

      description:
          map['description'] ?? '',

      categoryId:
          map['categoryId']?.toString() ?? '',

      categoryName:
          map['categoryName'] ?? '',

      providerId:
          map['providerId']?.toString() ?? '',

      providerName:
          map['providerName'] ?? '',

      thumbnail:
          map['thumbnail'] ?? map['image'],

      gallery: map['gallery'] != null
          ? List<String>.from(map['gallery'])
          : [],

      price:
          (map['price'] as num?)
                  ?.toDouble() ??
              0.0,

      discountedPrice:
          (map['discountedPrice'] as num?)
              ?.toDouble(),

      rating:
          (map['rating'] as num?)
                  ?.toDouble() ??
              0.0,

      reviewsCount:
          map['reviewsCount'] ?? 0,

      isFeatured:
          map['isFeatured'] ?? false,

      isAvailable:
          map['isAvailable'] ?? true,

      isActive:
          map['isActive'] ?? true,

      address: map['address'],

      latitude:
          (map['latitude'] as num?)
              ?.toDouble(),

      longitude:
          (map['longitude'] as num?)
              ?.toDouble(),

      bookingCount:
          map['bookingCount'] ?? 0,

      createdAt:
          map['createdAt'] != null
              ? DateTime.tryParse(
                  map['createdAt'],
                )
              : null,

      updatedAt:
          map['updatedAt'] != null
              ? DateTime.tryParse(
                  map['updatedAt'],
                )
              : null,
    );
  }

  // ==========================================
  // TO MAP
  // ==========================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'providerId': providerId,
      'providerName': providerName,
      'thumbnail': thumbnail,
      'gallery': gallery,
      'price': price,
      'discountedPrice': discountedPrice,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'bookingCount': bookingCount,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // ==========================================
  // JSON
  // ==========================================

  factory ServiceModel.fromJson(
    String source,
  ) {
    return ServiceModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // ==========================================
  // GETTERS
  // ==========================================

  bool get hasDiscount =>
      discountedPrice != null &&
      discountedPrice! < price;

  double get finalPrice =>
      discountedPrice ?? price;

  double get discountAmount =>
      price - finalPrice;

  int get discountPercentage {
    if (!hasDiscount) return 0;

    return (((price - finalPrice) / price) *
            100)
        .round();
  }

  String get imageUrl =>
      thumbnail ?? '';

  bool get hasImage =>
      thumbnail != null &&
      thumbnail!.isNotEmpty;

  // ==========================================
  // OVERRIDE
  // ==========================================

  @override
  String toString() {
    return 'ServiceModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;
}