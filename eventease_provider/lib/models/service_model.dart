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

  factory ServiceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ServiceModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      providerId:
          json['providerId']?.toString() ??
              '',
      providerName: json['providerName']
              ?.toString() ??
          '',
      categoryId:
          json['categoryId']?.toString() ??
              '',
      categoryName: json['categoryName']
              ?.toString() ??
          '',
      title:
          json['title']?.toString() ?? '',
      description:
          json['description']?.toString() ??
              '',
      price: (json['price'] ?? 0)
          .toDouble(),
      discountedPrice:
          (json['discountedPrice'] ?? 0)
              .toDouble(),
      rating: (json['rating'] ?? 0)
          .toDouble(),
      reviewCount:
          json['reviewCount'] ?? 0,
      images:
          json['images'] != null
              ? List<String>.from(
                  json['images'],
                )
              : [],
      city:
          json['city']?.toString() ?? '',
      state:
          json['state']?.toString() ?? '',
      address:
          json['address']?.toString() ??
              '',
      isActive:
          json['isActive'] ?? true,
      isFeatured:
          json['isFeatured'] ?? false,
      isVerified:
          json['isVerified'] ?? false,
      durationInHours:
          json['durationInHours'] ?? 1,
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
      'providerId': providerId,
      'providerName': providerName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'title': title,
      'description': description,
      'price': price,
      'discountedPrice':
          discountedPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'images': images,
      'city': city,
      'state': state,
      'address': address,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isVerified': isVerified,
      'durationInHours':
          durationInHours,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

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
      providerId:
          providerId ??
              this.providerId,
      providerName:
          providerName ??
              this.providerName,
      categoryId:
          categoryId ??
              this.categoryId,
      categoryName:
          categoryName ??
              this.categoryName,
      title: title ?? this.title,
      description:
          description ??
              this.description,
      price: price ?? this.price,
      discountedPrice:
          discountedPrice ??
              this.discountedPrice,
      rating: rating ?? this.rating,
      reviewCount:
          reviewCount ??
              this.reviewCount,
      images: images ?? this.images,
      city: city ?? this.city,
      state: state ?? this.state,
      address:
          address ?? this.address,
      isActive:
          isActive ?? this.isActive,
      isFeatured:
          isFeatured ??
              this.isFeatured,
      isVerified:
          isVerified ??
              this.isVerified,
      durationInHours:
          durationInHours ??
              this.durationInHours,
      createdAt:
          createdAt ??
              this.createdAt,
      updatedAt:
          updatedAt ??
              this.updatedAt,
    );
  }

  bool get hasDiscount =>
      discountedPrice > 0 &&
      discountedPrice < price;

  double get finalPrice =>
      hasDiscount
          ? discountedPrice
          : price;

  double get discountPercentage {
    if (!hasDiscount) return 0;

    return ((price -
                discountedPrice) /
            price) *
        100;
  }

  @override
  String toString() {
    return 'ServiceModel(id: $id, title: $title)';
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