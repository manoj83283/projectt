import 'dart:convert';

class ProviderModel {
  final String id;
  final String name;
  final String email;
  final String phone;

  final String? profileImage;
  final String? coverImage;

  final String businessName;
  final String? businessDescription;

  final bool isVerified;
  final bool isAvailable;
  final bool isActive;

  final double rating;
  final int reviewsCount;
  final int servicesCount;
  final int bookingsCount;

  final int experienceYears;

  final double totalEarnings;

  final String? address;
  final double? latitude;
  final double? longitude;

  final List<String> serviceCategories;

  final String? fcmToken;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.businessName,
    this.profileImage,
    this.coverImage,
    this.businessDescription,
    this.isVerified = false,
    this.isAvailable = true,
    this.isActive = true,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.servicesCount = 0,
    this.bookingsCount = 0,
    this.experienceYears = 0,
    this.totalEarnings = 0,
    this.address,
    this.latitude,
    this.longitude,
    this.serviceCategories = const [],
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  // =====================================================
  // EMPTY
  // =====================================================

  factory ProviderModel.empty() {
    return const ProviderModel(
      id: '',
      name: '',
      email: '',
      phone: '',
      businessName: '',
    );
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  ProviderModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? coverImage,
    String? businessName,
    String? businessDescription,
    bool? isVerified,
    bool? isAvailable,
    bool? isActive,
    double? rating,
    int? reviewsCount,
    int? servicesCount,
    int? bookingsCount,
    int? experienceYears,
    double? totalEarnings,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? serviceCategories,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      businessName: businessName ?? this.businessName,
      businessDescription:
          businessDescription ?? this.businessDescription,
      isVerified: isVerified ?? this.isVerified,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      servicesCount: servicesCount ?? this.servicesCount,
      bookingsCount: bookingsCount ?? this.bookingsCount,
      experienceYears:
          experienceYears ?? this.experienceYears,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      serviceCategories:
          serviceCategories ?? this.serviceCategories,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =====================================================
  // FROM MAP
  // =====================================================

  factory ProviderModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ProviderModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      name: map['name'] ?? '',

      email: map['email'] ?? '',

      phone: map['phone'] ?? '',

      businessName:
          map['businessName'] ??
          map['business_name'] ??
          '',

      businessDescription:
          map['businessDescription'],

      profileImage:
          map['profileImage'] ??
          map['profile_image'],

      coverImage:
          map['coverImage'] ??
          map['cover_image'],

      isVerified:
          map['isVerified'] ?? false,

      isAvailable:
          map['isAvailable'] ?? true,

      isActive:
          map['isActive'] ?? true,

      rating:
          (map['rating'] as num?)
                  ?.toDouble() ??
              0.0,

      reviewsCount:
          map['reviewsCount'] ?? 0,

      servicesCount:
          map['servicesCount'] ?? 0,

      bookingsCount:
          map['bookingsCount'] ?? 0,

      experienceYears:
          map['experienceYears'] ?? 0,

      totalEarnings:
          (map['totalEarnings'] as num?)
                  ?.toDouble() ??
              0.0,

      address: map['address'],

      latitude:
          (map['latitude'] as num?)
              ?.toDouble(),

      longitude:
          (map['longitude'] as num?)
              ?.toDouble(),

      serviceCategories:
          map['serviceCategories'] != null
              ? List<String>.from(
                  map['serviceCategories'],
                )
              : [],

      fcmToken: map['fcmToken'],

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

  // =====================================================
  // TO MAP
  // =====================================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'businessName': businessName,
      'businessDescription': businessDescription,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'isVerified': isVerified,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'servicesCount': servicesCount,
      'bookingsCount': bookingsCount,
      'experienceYears': experienceYears,
      'totalEarnings': totalEarnings,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'serviceCategories': serviceCategories,
      'fcmToken': fcmToken,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // =====================================================
  // JSON
  // =====================================================

  factory ProviderModel.fromJson(
    String source,
  ) {
    return ProviderModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // =====================================================
  // GETTERS
  // =====================================================

  bool get hasProfileImage =>
      profileImage != null &&
      profileImage!.isNotEmpty;

  bool get hasCoverImage =>
      coverImage != null &&
      coverImage!.isNotEmpty;

  String get imageUrl =>
      profileImage ?? '';

  String get displayName =>
      businessName.isNotEmpty
          ? businessName
          : name;

  String get initials {
    if (name.trim().isEmpty) {
      return '';
    }

    final parts = name.split(' ');

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  bool get hasLocation =>
      latitude != null &&
      longitude != null;

  // =====================================================
  // OVERRIDES
  // =====================================================

  @override
  String toString() {
    return 'ProviderModel(id: $id, businessName: $businessName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProviderModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}