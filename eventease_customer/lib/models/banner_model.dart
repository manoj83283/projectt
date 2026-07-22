import 'dart:convert';

class BannerModel {
  final String id;

  final String title;
  final String? subtitle;
  final String? description;

  final String image;

  final String? redirectType;
  final String? redirectId;
  final String? redirectUrl;

  final bool isActive;
  final bool isFeatured;

  final int displayOrder;

  final DateTime? startDate;
  final DateTime? endDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.subtitle,
    this.description,
    this.redirectType,
    this.redirectId,
    this.redirectUrl,
    this.isActive = true,
    this.isFeatured = false,
    this.displayOrder = 0,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // EMPTY
  // ==========================================

  factory BannerModel.empty() {
    return const BannerModel(
      id: '',
      title: '',
      image: '',
    );
  }

  // ==========================================
  // COPY WITH
  // ==========================================

  BannerModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? image,
    String? redirectType,
    String? redirectId,
    String? redirectUrl,
    bool? isActive,
    bool? isFeatured,
    int? displayOrder,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      image: image ?? this.image,
      redirectType: redirectType ?? this.redirectType,
      redirectId: redirectId ?? this.redirectId,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      displayOrder: displayOrder ?? this.displayOrder,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // FROM MAP
  // ==========================================

  factory BannerModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return BannerModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      title: map['title'] ?? '',

      subtitle: map['subtitle'],

      description: map['description'],

      image: map['image'] ?? '',

      redirectType: map['redirectType'],

      redirectId:
          map['redirectId']?.toString(),

      redirectUrl: map['redirectUrl'],

      isActive: map['isActive'] ?? true,

      isFeatured:
          map['isFeatured'] ?? false,

      displayOrder:
          map['displayOrder'] ?? 0,

      startDate:
          map['startDate'] != null
              ? DateTime.tryParse(
                  map['startDate'],
                )
              : null,

      endDate: map['endDate'] != null
          ? DateTime.tryParse(
              map['endDate'],
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

  // ==========================================
  // TO MAP
  // ==========================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'image': image,
      'redirectType': redirectType,
      'redirectId': redirectId,
      'redirectUrl': redirectUrl,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'displayOrder': displayOrder,
      'startDate':
          startDate?.toIso8601String(),
      'endDate':
          endDate?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // ==========================================
  // JSON
  // ==========================================

  factory BannerModel.fromJson(
    String source,
  ) {
    return BannerModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // ==========================================
  // GETTERS
  // ==========================================

  bool get isServiceBanner =>
      redirectType == 'service';

  bool get isCategoryBanner =>
      redirectType == 'category';

  bool get isProviderBanner =>
      redirectType == 'provider';

  bool get hasRedirectUrl =>
      redirectUrl != null &&
      redirectUrl!.isNotEmpty;

  bool get isExpired {
    if (endDate == null) return false;

    return DateTime.now()
        .isAfter(endDate!);
  }

  bool get isUpcoming {
    if (startDate == null) return false;

    return DateTime.now()
        .isBefore(startDate!);
  }

  bool get isLive =>
      isActive &&
      !isExpired &&
      !isUpcoming;

  // ==========================================
  // OVERRIDES
  // ==========================================

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BannerModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}