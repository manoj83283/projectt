class CustomerModel {
  final String id;

  final String fullName;
  final String email;
  final String phone;

  final String profileImage;

  final String address;
  final String city;
  final String state;
  final String pincode;

  final double latitude;
  final double longitude;

  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;

  final double totalSpent;

  final bool isActive;
  final bool isBlocked;
  final bool isVerified;

  final DateTime? lastLogin;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.totalSpent,
    required this.isActive,
    required this.isBlocked,
    required this.isVerified,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.empty() {
    return const CustomerModel(
      id: '',
      fullName: '',
      email: '',
      phone: '',
      profileImage: '',
      address: '',
      city: '',
      state: '',
      pincode: '',
      latitude: 0,
      longitude: 0,
      totalBookings: 0,
      completedBookings: 0,
      cancelledBookings: 0,
      totalSpent: 0,
      isActive: true,
      isBlocked: false,
      isVerified: false,
    );
  }

  factory CustomerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerModel(
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
      totalBookings:
          json['totalBookings'] ?? 0,
      completedBookings:
          json['completedBookings'] ??
              0,
      cancelledBookings:
          json['cancelledBookings'] ??
              0,
      totalSpent:
          (json['totalSpent'] ?? 0)
              .toDouble(),
      isActive:
          json['isActive'] ?? true,
      isBlocked:
          json['isBlocked'] ?? false,
      isVerified:
          json['isVerified'] ?? false,
      lastLogin:
          json['lastLogin'] != null
              ? DateTime.tryParse(
                  json['lastLogin']
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
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'totalBookings': totalBookings,
      'completedBookings':
          completedBookings,
      'cancelledBookings':
          cancelledBookings,
      'totalSpent': totalSpent,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'isVerified': isVerified,
      'lastLogin':
          lastLogin?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? address,
    String? city,
    String? state,
    String? pincode,
    double? latitude,
    double? longitude,
    int? totalBookings,
    int? completedBookings,
    int? cancelledBookings,
    double? totalSpent,
    bool? isActive,
    bool? isBlocked,
    bool? isVerified,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      fullName:
          fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage:
          profileImage ??
              this.profileImage,
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
      totalBookings:
          totalBookings ??
              this.totalBookings,
      completedBookings:
          completedBookings ??
              this.completedBookings,
      cancelledBookings:
          cancelledBookings ??
              this.cancelledBookings,
      totalSpent:
          totalSpent ??
              this.totalSpent,
      isActive:
          isActive ?? this.isActive,
      isBlocked:
          isBlocked ?? this.isBlocked,
      isVerified:
          isVerified ??
              this.isVerified,
      lastLogin:
          lastLogin ?? this.lastLogin,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  double get completionRate {
    if (totalBookings == 0) {
      return 0;
    }

    return (completedBookings /
            totalBookings) *
        100;
  }

  bool get hasBookings =>
      totalBookings > 0;

  bool get isPremiumCustomer =>
      totalSpent >= 50000;

  @override
  String toString() {
    return 'CustomerModel(id: $id, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CustomerModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}