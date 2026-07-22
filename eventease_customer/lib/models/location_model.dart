import 'dart:convert';

class LocationModel {
  final String id;

  final String name;
  final String address;

  final String? landmark;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  final double latitude;
  final double longitude;

  final bool isDefault;
  final bool isCurrentLocation;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.landmark,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.isDefault = false,
    this.isCurrentLocation = false,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // EMPTY
  // ==========================================

  factory LocationModel.empty() {
    return const LocationModel(
      id: '',
      name: '',
      address: '',
      latitude: 0.0,
      longitude: 0.0,
    );
  }

  // ==========================================
  // COPY WITH
  // ==========================================

  LocationModel copyWith({
    String? id,
    String? name,
    String? address,
    String? landmark,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
    bool? isCurrentLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      isCurrentLocation:
          isCurrentLocation ?? this.isCurrentLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // FROM MAP
  // ==========================================

  factory LocationModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return LocationModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      name: map['name'] ?? '',

      address: map['address'] ?? '',

      landmark: map['landmark'],

      city: map['city'],

      state: map['state'],

      country: map['country'],

      postalCode: map['postalCode'],

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

      isCurrentLocation:
          map['isCurrentLocation'] ?? false,

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
      'name': name,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'isCurrentLocation': isCurrentLocation,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // ==========================================
  // JSON
  // ==========================================

  factory LocationModel.fromJson(
    String source,
  ) {
    return LocationModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // ==========================================
  // HELPERS
  // ==========================================

  bool get hasValidCoordinates =>
      latitude != 0.0 &&
      longitude != 0.0;

  String get coordinates =>
      '$latitude,$longitude';

  String get fullAddress {
    return [
      address,
      landmark,
      city,
      state,
      postalCode,
      country,
    ]
        .where(
          (e) =>
              e != null &&
              e.toString().trim().isNotEmpty,
        )
        .join(', ');
  }

  // ==========================================
  // OVERRIDES
  // ==========================================

  @override
  String toString() {
    return 'LocationModel(id: $id, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LocationModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}