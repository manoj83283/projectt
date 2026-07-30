class ProviderModel {
  final String id;

  final String fullName;
  final String email;
  final String phone;

  final String profileImage;

  final String businessName;
  final String businessType;

  final String categoryId;
  final String categoryName;

  final String address;
  final String city;
  final String state;
  final String pincode;

  final double latitude;
  final double longitude;

  final double rating;
  final int totalReviews;

  final int totalBookings;
  final int completedBookings;

  final double totalEarnings;

  final bool isVerified;
  final bool isActive;
  final bool isOnline;

  final String kycStatus;

  final String aadhaarNumber;
  final String panNumber;

  final List<String> portfolioImages;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProviderModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.businessName,
    required this.businessType,
    required this.categoryId,
    required this.categoryName,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.totalReviews,
    required this.totalBookings,
    required this.completedBookings,
    required this.totalEarnings,
    required this.isVerified,
    required this.isActive,
    required this.isOnline,
    required this.kycStatus,
    required this.aadhaarNumber,
    required this.panNumber,
    required this.portfolioImages,
    this.createdAt,
    this.updatedAt,
  });

  factory ProviderModel.empty() {
    return const ProviderModel(
      id: '',
      fullName: '',
      email: '',
      phone: '',
      profileImage: '',
      businessName: '',
      businessType: '',
      categoryId: '',
      categoryName: '',
      address: '',
      city: '',
      state: '',
      pincode: '',
      latitude: 0,
      longitude: 0,
      rating: 0,
      totalReviews: 0,
      totalBookings: 0,
      completedBookings: 0,
      totalEarnings: 0,
      isVerified: false,
      isActive: true,
      isOnline: false,
      kycStatus: 'Pending',
      aadhaarNumber: '',
      panNumber: '',
      portfolioImages: [],
    );
  }

  factory ProviderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProviderModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      fullName:
          json['fullName']?.toString() ??
              '',
      email:
          json['email']?.toString() ?? '',
      phone:
          json['phone']?.toString() ?? '',
      profileImage:
          json['profileImage']
                  ?.toString() ??
              '',
      businessName:
          json['businessName']
                  ?.toString() ??
              '',
      businessType:
          json['businessType']
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
      address:
          json['address']?.toString() ??
              '',
      city:
          json['city']?.toString() ?? '',
      state:
          json['state']?.toString() ?? '',
      pincode:
          json['pincode']?.toString() ??
              '',
      latitude:
          (json['latitude'] ?? 0)
              .toDouble(),
      longitude:
          (json['longitude'] ?? 0)
              .toDouble(),
      rating:
          (json['rating'] ?? 0)
              .toDouble(),
      totalReviews:
          json['totalReviews'] ?? 0,
      totalBookings:
          json['totalBookings'] ?? 0,
      completedBookings:
          json['completedBookings'] ??
              0,
      totalEarnings:
          (json['totalEarnings'] ?? 0)
              .toDouble(),
      isVerified:
          json['isVerified'] ?? false,
      isActive:
          json['isActive'] ?? true,
      isOnline:
          json['isOnline'] ?? false,
      kycStatus:
          json['kycStatus']
                  ?.toString() ??
              'Pending',
      aadhaarNumber:
          json['aadhaarNumber']
                  ?.toString() ??
              '',
      panNumber:
          json['panNumber']
                  ?.toString() ??
              '',
      portfolioImages:
          json['portfolioImages'] !=
                  null
              ? List<String>.from(
                  json[
                      'portfolioImages'],
                )
              : [],
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
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'businessName': businessName,
      'businessType': businessType,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalBookings': totalBookings,
      'completedBookings':
          completedBookings,
      'totalEarnings': totalEarnings,
      'isVerified': isVerified,
      'isActive': isActive,
      'isOnline': isOnline,
      'kycStatus': kycStatus,
      'aadhaarNumber':
          aadhaarNumber,
      'panNumber': panNumber,
      'portfolioImages':
          portfolioImages,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  ProviderModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? businessName,
    String? businessType,
    String? categoryId,
    String? categoryName,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    double? rating,
    int? totalReviews,
    int? totalBookings,
    int? completedBookings,
    double? totalEarnings,
    bool? isVerified,
    bool? isActive,
    bool? isOnline,
    String? kycStatus,
    String? aadhaarNumber,
    String? panNumber,
    List<String>? portfolioImages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      fullName:
          fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage:
          profileImage ??
              this.profileImage,
      businessName:
          businessName ??
              this.businessName,
      businessType:
          businessType ??
              this.businessType,
      categoryId:
          categoryId ??
              this.categoryId,
      categoryName:
          categoryName ??
              this.categoryName,
      address:
          address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode:
          pincode ?? this.pincode,
      latitude:
          latitude ?? this.latitude,
      longitude:
          longitude ??
              this.longitude,
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
      totalEarnings:
          totalEarnings ??
              this.totalEarnings,
      isVerified:
          isVerified ??
              this.isVerified,
      isActive:
          isActive ?? this.isActive,
      isOnline:
          isOnline ?? this.isOnline,
      kycStatus:
          kycStatus ?? this.kycStatus,
      aadhaarNumber:
          aadhaarNumber ??
              this.aadhaarNumber,
      panNumber:
          panNumber ?? this.panNumber,
      portfolioImages:
          portfolioImages ??
              this.portfolioImages,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isKycApproved =>
      kycStatus.toLowerCase() ==
      'approved';

  double get completionRate {
    if (totalBookings == 0) {
      return 0;
    }

    return (completedBookings /
            totalBookings) *
        100;
  }

  @override
  String toString() {
    return 'ProviderModel(id: $id, businessName: $businessName)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderModel &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}