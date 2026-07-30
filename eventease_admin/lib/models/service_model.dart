class ServiceModel {
  final String id;

  final String name;
  final String description;

  final String categoryId;
  final String categoryName;

  final String providerId;
  final String providerName;

  final double price;
  final double? discountPrice;

  final int duration;

  final List<String> images;

  final double rating;
  final int totalReviews;

  final int totalBookings;
  final int completedBookings;

  final bool isActive;
  final bool isApproved;
  final bool isFeatured;

  final String status;

  final List<String> tags;

  final String? location;
  final double? latitude;
  final double? longitude;

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
    this.discountPrice,
    required this.duration,
    required this.images,
    required this.rating,
    required this.totalReviews,
    required this.totalBookings,
    required this.completedBookings,
    required this.isActive,
    required this.isApproved,
    required this.isFeatured,
    required this.status,
    required this.tags,
    this.location,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      name:
          json['name']?.toString() ?? '',

      description:
          json['description']
                  ?.toString() ??
              '',

      categoryId:
          json['categoryId']
                  ?.toString() ??
              '',

      categoryName:
          json['categoryName']
                  ?.toString() ??
              '',

      providerId:
          json['providerId']
                  ?.toString() ??
              '',

      providerName:
          json['providerName']
                  ?.toString() ??
              '',

      price:
          (json['price'] ?? 0)
              .toDouble(),

      discountPrice:
          json['discountPrice'] != null
              ? (json['discountPrice'])
                  .toDouble()
              : null,

      duration:
          json['duration'] ?? 0,

      images:
          (json['images'] as List?)
                  ?.map(
                    (e) => e.toString(),
                  )
                  .toList() ??
              [],

      rating:
          (json['rating'] ?? 0)
              .toDouble(),

      totalReviews:
          json['totalReviews'] ?? 0,

      totalBookings:
          json['totalBookings'] ?? 0,

      completedBookings:
          json['completedBookings'] ?? 0,

      isActive:
          json['isActive'] ?? true,

      isApproved:
          json['isApproved'] ?? false,

      isFeatured:
          json['isFeatured'] ?? false,

      status:
          json['status']
                  ?.toString() ??
              'pending',

      tags:
          (json['tags'] as List?)
                  ?.map(
                    (e) => e.toString(),
                  )
                  .toList() ??
              [],

      location:
          json['location']
              ?.toString(),

      latitude:
          json['latitude'] != null
              ? double.tryParse(
                  json['latitude']
                      .toString(),
                )
              : null,

      longitude:
          json['longitude'] != null
              ? double.tryParse(
                  json['longitude']
                      .toString(),
                )
              : null,

      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(
                  json['createdAt']
                      .toString(),
                )
              : null,

      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(
                  json['updatedAt']
                      .toString(),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'providerId': providerId,
      'providerName': providerName,
      'price': price,
      'discountPrice': discountPrice,
      'duration': duration,
      'images': images,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalBookings': totalBookings,
      'completedBookings':
          completedBookings,
      'isActive': isActive,
      'isApproved': isApproved,
      'isFeatured': isFeatured,
      'status': status,
      'tags': tags,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    String? providerId,
    String? providerName,
    double? price,
    double? discountPrice,
    int? duration,
    List<String>? images,
    double? rating,
    int? totalReviews,
    int? totalBookings,
    int? completedBookings,
    bool? isActive,
    bool? isApproved,
    bool? isFeatured,
    String? status,
    List<String>? tags,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
          description ??
              this.description,
      categoryId:
          categoryId ?? this.categoryId,
      categoryName:
          categoryName ??
              this.categoryName,
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ??
              this.providerName,
      price: price ?? this.price,
      discountPrice:
          discountPrice ??
              this.discountPrice,
      duration:
          duration ?? this.duration,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      totalReviews:
          totalReviews ??
              this.totalReviews,
      totalBookings:
          totalBookings ??
              this.totalBookings,
      completedBookings:
          completedBookings ??
              this.completedBookings,
      isActive:
          isActive ?? this.isActive,
      isApproved:
          isApproved ??
              this.isApproved,
      isFeatured:
          isFeatured ??
              this.isFeatured,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      location:
          location ?? this.location,
      latitude:
          latitude ?? this.latitude,
      longitude:
          longitude ?? this.longitude,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  double get effectivePrice =>
      discountPrice != null &&
              discountPrice! > 0
          ? discountPrice!
          : price;

  bool get hasDiscount =>
      discountPrice != null &&
      discountPrice! < price;

  double get discountPercentage {
    if (!hasDiscount) return 0;

    return ((price -
                discountPrice!) /
            price) *
        100;
  }

  bool get isPending =>
      status.toLowerCase() ==
      'pending';

  bool get isRejected =>
      status.toLowerCase() ==
      'rejected';

  bool get hasLocation =>
      latitude != null &&
      longitude != null;

  bool get isTopRated =>
      rating >= 4.5;

  @override
  bool operator ==(
    Object other,
  ) {
    if (identical(this, other)) {
      return true;
    }

    return other is ServiceModel &&
        other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode;

  @override
  String toString() {
    return 'ServiceModel('
        'id: $id, '
        'name: $name, '
        'price: $price'
        ')';
  }
}