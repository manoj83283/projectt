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

  /// ✅ Added for availability screen compatibility
  final bool isAvailable;

  final String kycStatus;

  final String aadhaarNumber;
  final String panNumber;

  /// ✅ Added for profile/edit profile compatibility
  final String bio;

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
    required this.isAvailable,
    required this.kycStatus,
    required this.aadhaarNumber,
    required this.panNumber,
    required this.bio,
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
      isAvailable: true,
      kycStatus: 'Pending',
      aadhaarNumber: '',
      panNumber: '',
      bio: '',
      portfolioImages: [],
    );
  }

  factory ProviderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final locationMap = _asMap(json['location']);

    final coordinates = locationMap?['coordinates'];

    double parsedLongitude = _toDouble(
      json['longitude'],
    );

    double parsedLatitude = _toDouble(
      json['latitude'],
    );

    if (coordinates is List && coordinates.length >= 2) {
      parsedLongitude = _toDouble(coordinates[0]);
      parsedLatitude = _toDouble(coordinates[1]);
    }

    final firstName = json['firstName']?.toString() ?? '';
    final lastName = json['lastName']?.toString() ?? '';

    final parsedFullName =
        json['fullName']?.toString().trim().isNotEmpty == true
            ? json['fullName'].toString()
            : json['name']?.toString().trim().isNotEmpty == true
                ? json['name'].toString()
                : '$firstName $lastName'.trim();

    final dynamic rawPortfolioImages = json['portfolioImages'];

    List<String> parsedPortfolioImages = [];

    if (rawPortfolioImages is List) {
      parsedPortfolioImages = rawPortfolioImages
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    final profileImg = json['profileImage']?.toString() ??
        json['image']?.toString() ??
        json['avatar']?.toString() ??
        '';

    return ProviderModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      fullName: parsedFullName,

      email: json['email']?.toString() ?? '',

      phone: json['phone']?.toString() ?? '',

      profileImage: profileImg,

      businessName: json['businessName']?.toString() ??
          json['shopName']?.toString() ??
          json['providerName']?.toString() ??
          '',

      businessType: json['businessType']?.toString() ??
          json['role']?.toString() ??
          '',

      categoryId: json['categoryId']?.toString() ?? '',

      categoryName: json['categoryName']?.toString() ??
          json['category']?.toString() ??
          '',

      address: json['address']?.toString() ??
          json['locationName']?.toString() ??
          _locationToString(json['location']) ??
          '',

      city: json['city']?.toString() ?? '',

      state: json['state']?.toString() ?? '',

      pincode: json['pincode']?.toString() ??
          json['pinCode']?.toString() ??
          '',

      latitude: parsedLatitude,

      longitude: parsedLongitude,

      rating: _toDouble(
        json['rating'],
      ),

      totalReviews: _toInt(
        json['totalReviews'] ??
            json['reviewCount'],
      ),

      totalBookings: _toInt(
        json['totalBookings'] ??
            json['bookingCount'],
      ),

      completedBookings: _toInt(
        json['completedBookings'],
      ),

      totalEarnings: _toDouble(
        json['totalEarnings'] ??
            json['earnings'],
      ),

      isVerified: _toBool(
        json['isVerified'],
      ),

      isActive: _toBool(
        json['isActive'],
        defaultValue: true,
      ),

      isOnline: _toBool(
        json['isOnline'] ??
            json['online'],
      ),

      isAvailable: _toBool(
        json['isAvailable'] ??
            json['available'],
        defaultValue: true,
      ),

      kycStatus: json['kycStatus']?.toString() ??
          json['kyc']?.toString() ??
          'Pending',

      aadhaarNumber: json['aadhaarNumber']?.toString() ??
          json['aadharNumber']?.toString() ??
          '',

      panNumber: json['panNumber']?.toString() ?? '',

      bio: json['bio']?.toString() ??
          json['about']?.toString() ??
          json['description']?.toString() ??
          '',

      portfolioImages: parsedPortfolioImages,

      createdAt: _toDateTime(
        json['createdAt'],
      ),

      updatedAt: _toDateTime(
        json['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,

      'fullName': fullName,
      'name': fullName,

      'email': email,
      'phone': phone,

      'profileImage': profileImage,
      'image': profileImage,

      'businessName': businessName,
      'shopName': businessName,

      'businessType': businessType,

      'categoryId': categoryId,
      'categoryName': categoryName,

      'address': address,
      'locationName': address,

      'city': city,
      'state': state,
      'pincode': pincode,

      'latitude': latitude,
      'longitude': longitude,

      'location': {
        'type': 'Point',
        'coordinates': [
          longitude,
          latitude,
        ],
      },

      'rating': rating,
      'totalReviews': totalReviews,

      'totalBookings': totalBookings,
      'completedBookings': completedBookings,

      'totalEarnings': totalEarnings,

      'isVerified': isVerified,
      'isActive': isActive,
      'isOnline': isOnline,
      'isAvailable': isAvailable,

      'kycStatus': kycStatus,

      'aadhaarNumber': aadhaarNumber,
      'panNumber': panNumber,

      'bio': bio,

      'portfolioImages': portfolioImages,

      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
    bool? isAvailable,
    String? kycStatus,
    String? aadhaarNumber,
    String? panNumber,
    String? bio,
    List<String>? portfolioImages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      isAvailable: isAvailable ?? this.isAvailable,
      kycStatus: kycStatus ?? this.kycStatus,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      bio: bio ?? this.bio,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =============================================================
  // ✅ BACKWARD-COMPATIBLE GETTERS
  // =============================================================

  String get name => fullName;

  String get imageUrl => profileImage;

  String get location {
    if (address.trim().isNotEmpty) return address;

    final parts = [
      city,
      state,
      pincode,
    ].where((item) => item.trim().isNotEmpty).toList();

    return parts.join(', ');
  }

  bool get available => isAvailable;

  bool get isKycApproved {
    return kycStatus.toLowerCase() == 'approved';
  }

  double get completionRate {
    if (totalBookings == 0) {
      return 0;
    }

    return (completedBookings / totalBookings) * 100;
  }

  // =============================================================
  // ✅ SAFE PARSERS
  // =============================================================

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(
          key.toString(),
          val,
        ),
      );
    }

    return null;
  }

  static String? _locationToString(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return value;
    }

    if (value is Map) {
      return value['address']?.toString() ??
          value['name']?.toString() ??
          value['locationName']?.toString();
    }

    return value.toString();
  }

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

  @override
  String toString() {
    return 'ProviderModel(id: $id, businessName: $businessName, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProviderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}