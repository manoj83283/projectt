import 'dart:convert';

class AddressModel {
  final String id;
  final String userId;

  final String fullName;
  final String phone;

  final String addressType;

  final String houseNo;
  final String street;
  final String landmark;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  final double latitude;
  final double longitude;

  final bool isDefault;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.addressType,
    required this.houseNo,
    required this.street,
    required this.landmark,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // EMPTY
  // ==========================================

  factory AddressModel.empty() {
    return const AddressModel(
      id: '',
      userId: '',
      fullName: '',
      phone: '',
      addressType: 'home',
      houseNo: '',
      street: '',
      landmark: '',
      city: '',
      state: '',
      country: '',
      postalCode: '',
      latitude: 0,
      longitude: 0,
    );
  }

  // ==========================================
  // COPY WITH
  // ==========================================

  AddressModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? addressType,
    String? houseNo,
    String? street,
    String? landmark,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressType: addressType ?? this.addressType,
      houseNo: houseNo ?? this.houseNo,
      street: street ?? this.street,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // FROM MAP
  // ==========================================

  factory AddressModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return AddressModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      userId:
          map['userId']?.toString() ?? '',

      fullName:
          map['fullName'] ?? '',

      phone:
          map['phone'] ?? '',

      addressType:
          map['addressType'] ?? 'home',

      houseNo:
          map['houseNo'] ?? '',

      street:
          map['street'] ?? '',

      landmark:
          map['landmark'] ?? '',

      city:
          map['city'] ?? '',

      state:
          map['state'] ?? '',

      country:
          map['country'] ?? '',

      postalCode:
          map['postalCode'] ?? '',

      latitude:
          (map['latitude'] as num?)
                  ?.toDouble() ??
              0.0,

      longitude:
          (map['longitude'] as num?)
                  ?.toDouble() ??
              0.0,

      isDefault:
          map['isDefault'] ?? false,

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
      'userId': userId,
      'fullName': fullName,
      'phone': phone,
      'addressType': addressType,
      'houseNo': houseNo,
      'street': street,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // ==========================================
  // JSON
  // ==========================================

  factory AddressModel.fromJson(
    String source,
  ) {
    return AddressModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // ==========================================
  // HELPERS
  // ==========================================

  bool get isHome =>
      addressType.toLowerCase() == 'home';

  bool get isWork =>
      addressType.toLowerCase() == 'work';

  bool get isOther =>
      addressType.toLowerCase() == 'other';

  String get fullAddress {
    return [
      houseNo,
      street,
      landmark,
      city,
      state,
      postalCode,
      country,
    ]
        .where(
          (e) => e.trim().isNotEmpty,
        )
        .join(', ');
  }

  bool get hasLocation =>
      latitude != 0 && longitude != 0;

  // ==========================================
  // OVERRIDES
  // ==========================================

  @override
  String toString() {
    return 'AddressModel(id: $id, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AddressModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}