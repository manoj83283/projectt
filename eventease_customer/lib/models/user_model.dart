import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  final String role;

  final bool isVerified;
  final bool isActive;

  final String? gender;
  final DateTime? dateOfBirth;

  final double? latitude;
  final double? longitude;
  final String? address;

  final String? fcmToken;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.gender,
    this.dateOfBirth,
    this.latitude,
    this.longitude,
    this.address,
    this.fcmToken,
    this.isVerified = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // =====================================================
  // EMPTY USER
  // =====================================================

  factory UserModel.empty() {
    return const UserModel(
      id: '',
      name: '',
      email: '',
      phone: '',
      role: 'customer',
    );
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? role,
    bool? isVerified,
    bool? isActive,
    String? gender,
    DateTime? dateOfBirth,
    double? latitude,
    double? longitude,
    String? address,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage:
          profileImage ?? this.profileImage,
      role: role ?? this.role,
      isVerified:
          isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      gender: gender ?? this.gender,
      dateOfBirth:
          dateOfBirth ?? this.dateOfBirth,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =====================================================
  // FROM MAP
  // =====================================================

  factory UserModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      name: map['name'] ?? '',

      email: map['email'] ?? '',

      phone: map['phone'] ?? '',

      profileImage:
          map['profileImage'] ??
              map['profile_image'],

      role: map['role'] ?? 'customer',

      isVerified:
          map['isVerified'] ?? false,

      isActive:
          map['isActive'] ?? true,

      gender: map['gender'],

      address: map['address'],

      latitude:
          (map['latitude'] as num?)
              ?.toDouble(),

      longitude:
          (map['longitude'] as num?)
              ?.toDouble(),

      fcmToken: map['fcmToken'],

      dateOfBirth:
          map['dateOfBirth'] != null
              ? DateTime.tryParse(
                  map['dateOfBirth'],
                )
              : null,

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
      'profileImage': profileImage,
      'role': role,
      'isVerified': isVerified,
      'isActive': isActive,
      'gender': gender,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'fcmToken': fcmToken,
      'dateOfBirth':
          dateOfBirth?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // =====================================================
  // FROM JSON
  // =====================================================

  factory UserModel.fromJson(
    String source,
  ) {
    return UserModel.fromMap(
      jsonDecode(source),
    );
  }

  // =====================================================
  // TO JSON
  // =====================================================

  String toJson() {
    return jsonEncode(toMap());
  }

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isCustomer =>
      role.toLowerCase() == 'customer';

  bool get isProvider =>
      role.toLowerCase() == 'provider';

  bool get isAdmin =>
      role.toLowerCase() == 'admin';

  String get displayImage {
    return profileImage ?? '';
  }

  String get initials {
    if (name.trim().isEmpty) {
      return '';
    }

    final parts = name.trim().split(' ');

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  // =====================================================
  // OVERRIDES
  // =====================================================

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}