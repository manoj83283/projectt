class CategoryModel {
  final String id;

  final String name;
  final String description;

  final String? image;
  final String? icon;

  final bool isActive;
  final bool isFeatured;

  final int sortOrder;

  final int totalServices;
  final int totalProviders;
  final int totalBookings;

  final double totalRevenue;

  final String? seoTitle;
  final String? seoDescription;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.icon,
    required this.isActive,
    required this.isFeatured,
    required this.sortOrder,
    required this.totalServices,
    required this.totalProviders,
    required this.totalBookings,
    required this.totalRevenue,
    this.seoTitle,
    this.seoDescription,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoryModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      name:
          json['name']?.toString() ?? '',

      description:
          json['description']
                  ?.toString() ??
              '',

      image:
          json['image']?.toString(),

      icon:
          json['icon']?.toString(),

      isActive:
          json['isActive'] ?? true,

      isFeatured:
          json['isFeatured'] ?? false,

      sortOrder:
          json['sortOrder'] ?? 0,

      totalServices:
          json['totalServices'] ?? 0,

      totalProviders:
          json['totalProviders'] ?? 0,

      totalBookings:
          json['totalBookings'] ?? 0,

      totalRevenue:
          (json['totalRevenue'] ?? 0)
              .toDouble(),

      seoTitle:
          json['seoTitle']
              ?.toString(),

      seoDescription:
          json['seoDescription']
              ?.toString(),

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
      'name': name,
      'description': description,
      'image': image,
      'icon': icon,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'sortOrder': sortOrder,
      'totalServices': totalServices,
      'totalProviders': totalProviders,
      'totalBookings': totalBookings,
      'totalRevenue': totalRevenue,
      'seoTitle': seoTitle,
      'seoDescription': seoDescription,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? icon,
    bool? isActive,
    bool? isFeatured,
    int? sortOrder,
    int? totalServices,
    int? totalProviders,
    int? totalBookings,
    double? totalRevenue,
    String? seoTitle,
    String? seoDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description:
          description ??
              this.description,
      image: image ?? this.image,
      icon: icon ?? this.icon,
      isActive:
          isActive ?? this.isActive,
      isFeatured:
          isFeatured ??
              this.isFeatured,
      sortOrder:
          sortOrder ?? this.sortOrder,
      totalServices:
          totalServices ??
              this.totalServices,
      totalProviders:
          totalProviders ??
              this.totalProviders,
      totalBookings:
          totalBookings ??
              this.totalBookings,
      totalRevenue:
          totalRevenue ??
              this.totalRevenue,
      seoTitle:
          seoTitle ?? this.seoTitle,
      seoDescription:
          seoDescription ??
              this.seoDescription,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get hasImage =>
      image != null &&
      image!.isNotEmpty;

  bool get hasIcon =>
      icon != null &&
      icon!.isNotEmpty;

  bool get hasServices =>
      totalServices > 0;

  bool get hasProviders =>
      totalProviders > 0;

  bool get isPopular =>
      totalBookings >= 100;

  bool get isRevenueGenerating =>
      totalRevenue > 0;

  String get displayName =>
      name.trim();

  @override
  String toString() {
    return 'CategoryModel('
        'id: $id, '
        'name: $name, '
        'services: $totalServices'
        ')';
  }

  @override
  bool operator ==(
    Object other,
  ) {
    if (identical(this, other)) {
      return true;
    }

    return other is CategoryModel &&
        other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode;
}