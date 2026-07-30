class CustomerModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImage;

  final bool isActive;
  final bool isVerified;
  final bool isBlocked;

  final String? referralCode;
  final String? referredBy;

  final int totalBookings;
  final int totalOrders;

  final double totalSpent;

  final String? deviceToken;

  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.isActive,
    required this.isVerified,
    required this.isBlocked,
    this.referralCode,
    this.referredBy,
    required this.totalBookings,
    required this.totalOrders,
    required this.totalSpent,
    this.deviceToken,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

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
          json['email']?.toString() ??
              '',

      phone:
          json['phone']?.toString() ??
              '',

      profileImage:
          json['profileImage']
              ?.toString(),

      isActive:
          json['isActive'] ?? true,

      isVerified:
          json['isVerified'] ?? false,

      isBlocked:
          json['isBlocked'] ?? false,

      referralCode:
          json['referralCode']
              ?.toString(),

      referredBy:
          json['referredBy']
              ?.toString(),

      totalBookings:
          json['totalBookings'] ?? 0,

      totalOrders:
          json['totalOrders'] ?? 0,

      totalSpent:
          (json['totalSpent'] ?? 0)
              .toDouble(),

      deviceToken:
          json['deviceToken']
              ?.toString(),

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
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'isActive': isActive,
      'isVerified': isVerified,
      'isBlocked': isBlocked,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'totalBookings': totalBookings,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'deviceToken': deviceToken,
      'lastLoginAt':
          lastLoginAt?.toIso8601String(),
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
    bool? isActive,
    bool? isVerified,
    bool? isBlocked,
    String? referralCode,
    String? referredBy,
    int? totalBookings,
    int? totalOrders,
    double? totalSpent,
    String? deviceToken,
    DateTime? lastLoginAt,
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
      isActive:
          isActive ?? this.isActive,
      isVerified:
          isVerified ??
              this.isVerified,
      isBlocked:
          isBlocked ?? this.isBlocked,
      referralCode:
          referralCode ??
              this.referralCode,
      referredBy:
          referredBy ??
              this.referredBy,
      totalBookings:
          totalBookings ??
              this.totalBookings,
      totalOrders:
          totalOrders ??
              this.totalOrders,
      totalSpent:
          totalSpent ??
              this.totalSpent,
      deviceToken:
          deviceToken ??
              this.deviceToken,
      lastLoginAt:
          lastLoginAt ??
              this.lastLoginAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  String get displayName =>
      fullName.trim().isEmpty
          ? email
          : fullName;

  bool get hasProfileImage =>
      profileImage != null &&
      profileImage!.isNotEmpty;

  bool get hasBookings =>
      totalBookings > 0;

  bool get hasOrders =>
      totalOrders > 0;

  bool get isPremiumCustomer =>
      totalSpent >= 100000;

  @override
  String toString() {
    return 'CustomerModel('
        'id: $id, '
        'fullName: $fullName, '
        'email: $email, '
        'phone: $phone'
        ')';
  }

  @override
  bool operator ==(
    Object other,
  ) {
    if (identical(this, other)) {
      return true;
    }

    return other is CustomerModel &&
        other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode;
}