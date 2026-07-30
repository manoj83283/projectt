class ProviderModel {
  final String id;
  final String fullName;
  final String businessName;
  final String email;
  final String phone;

  final String? profileImage;
  final String? coverImage;

  final String categoryId;
  final String categoryName;

  final bool isActive;
  final bool isVerified;
  final bool isBlocked;

  final String verificationStatus;

  final double rating;
  final int totalReviews;

  final int totalBookings;
  final int completedBookings;

  final double totalEarnings;
  final double walletBalance;

  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;

  final double? latitude;
  final double? longitude;

  final bool kycVerified;

  final String? aadhaarNumber;
  final String? panNumber;
  final String? gstNumber;

  final List<String> serviceIds;

  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProviderModel({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.email,
    required this.phone,
    this.profileImage,
    this.coverImage,
    required this.categoryId,
    required this.categoryName,
    required this.isActive,
    required this.isVerified,
    required this.isBlocked,
    required this.verificationStatus,
    required this.rating,
    required this.totalReviews,
    required this.totalBookings,
    required this.completedBookings,
    required this.totalEarnings,
    required this.walletBalance,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.latitude,
    this.longitude,
    required this.kycVerified,
    this.aadhaarNumber,
    this.panNumber,
    this.gstNumber,
    required this.serviceIds,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ProviderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProviderModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      fullName:
          json['fullName']?.toString() ?? '',

      businessName:
          json['businessName']
                  ?.toString() ??
              '',

      email:
          json['email']?.toString() ?? '',

      phone:
          json['phone']?.toString() ?? '',

      profileImage:
          json['profileImage']
              ?.toString(),

      coverImage:
          json['coverImage']
              ?.toString(),

      categoryId:
          json['categoryId']
                  ?.toString() ??
              '',

      categoryName:
          json['categoryName']
                  ?.toString() ??
              '',

      isActive:
          json['isActive'] ?? true,

      isVerified:
          json['isVerified'] ?? false,

      isBlocked:
          json['isBlocked'] ?? false,

      verificationStatus:
          json['verificationStatus']
                  ?.toString() ??
              'pending',

      rating:
          (json['rating'] ?? 0)
              .toDouble(),

      totalReviews:
          json['totalReviews'] ?? 0,

      totalBookings:
          json['totalBookings'] ?? 0,

      completedBookings:
          json['completedBookings'] ?? 0,

      totalEarnings:
          (json['totalEarnings'] ?? 0)
              .toDouble(),

      walletBalance:
          (json['walletBalance'] ?? 0)
              .toDouble(),

      address:
          json['address']?.toString(),

      city:
          json['city']?.toString(),

      state:
          json['state']?.toString(),

      country:
          json['country']?.toString(),

      pincode:
          json['pincode']?.toString(),

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

      kycVerified:
          json['kycVerified'] ?? false,

      aadhaarNumber:
          json['aadhaarNumber']
              ?.toString(),

      panNumber:
          json['panNumber']
              ?.toString(),

      gstNumber:
          json['gstNumber']
              ?.toString(),

      serviceIds:
          (json['serviceIds'] as List?)
                  ?.map(
                    (e) => e.toString(),
                  )
                  .toList() ??
              [],

      lastLoginAt:
          json['lastLoginAt'] != null
              ? DateTime.tryParse(
                  json['lastLoginAt']
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
      'fullName': fullName,
      'businessName': businessName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'isActive': isActive,
      'isVerified': isVerified,
      'isBlocked': isBlocked,
      'verificationStatus':
          verificationStatus,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalBookings': totalBookings,
      'completedBookings':
          completedBookings,
      'totalEarnings': totalEarnings,
      'walletBalance': walletBalance,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'kycVerified': kycVerified,
      'aadhaarNumber':
          aadhaarNumber,
      'panNumber': panNumber,
      'gstNumber': gstNumber,
      'serviceIds': serviceIds,
      'lastLoginAt':
          lastLoginAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  ProviderModel copyWith({
    String? id,
    String? fullName,
    String? businessName,
    String? email,
    String? phone,
    String? profileImage,
    String? coverImage,
    String? categoryId,
    String? categoryName,
    bool? isActive,
    bool? isVerified,
    bool? isBlocked,
    String? verificationStatus,
    double? rating,
    int? totalReviews,
    int? totalBookings,
    int? completedBookings,
    double? totalEarnings,
    double? walletBalance,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    double? latitude,
    double? longitude,
    bool? kycVerified,
    String? aadhaarNumber,
    String? panNumber,
    String? gstNumber,
    List<String>? serviceIds,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      businessName:
          businessName ?? this.businessName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage:
          profileImage ?? this.profileImage,
      coverImage:
          coverImage ?? this.coverImage,
      categoryId:
          categoryId ?? this.categoryId,
      categoryName:
          categoryName ?? this.categoryName,
      isActive: isActive ?? this.isActive,
      isVerified:
          isVerified ?? this.isVerified,
      isBlocked:
          isBlocked ?? this.isBlocked,
      verificationStatus:
          verificationStatus ??
              this.verificationStatus,
      rating: rating ?? this.rating,
      totalReviews:
          totalReviews ?? this.totalReviews,
      totalBookings:
          totalBookings ??
              this.totalBookings,
      completedBookings:
          completedBookings ??
              this.completedBookings,
      totalEarnings:
          totalEarnings ??
              this.totalEarnings,
      walletBalance:
          walletBalance ??
              this.walletBalance,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude:
          longitude ?? this.longitude,
      kycVerified:
          kycVerified ?? this.kycVerified,
      aadhaarNumber:
          aadhaarNumber ??
              this.aadhaarNumber,
      panNumber:
          panNumber ?? this.panNumber,
      gstNumber:
          gstNumber ?? this.gstNumber,
      serviceIds:
          serviceIds ?? this.serviceIds,
      lastLoginAt:
          lastLoginAt ?? this.lastLoginAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isPendingVerification =>
      verificationStatus.toLowerCase() ==
      'pending';

  bool get isApproved =>
      verificationStatus.toLowerCase() ==
      'approved';

  bool get isRejected =>
      verificationStatus.toLowerCase() ==
      'rejected';

  bool get hasLocation =>
      latitude != null &&
      longitude != null;

  bool get isTopRated =>
      rating >= 4.5;

  String get displayName =>
      businessName.isNotEmpty
          ? businessName
          : fullName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ProviderModel &&
        other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProviderModel('
        'id: $id, '
        'businessName: $businessName, '
        'email: $email'
        ')';
  }
}