import 'dart:convert';

class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? icon;

  final bool isActive;
  final bool isFeatured;

  final int displayOrder;
  final int serviceCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.icon,
    this.isActive = true,
    this.isFeatured = false,
    this.displayOrder = 0,
    this.serviceCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // =====================================================
  // EMPTY
  // =====================================================

  factory CategoryModel.empty() {
    return const CategoryModel(
      id: '',
      name: '',
    );
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? icon,
    bool? isActive,
    bool? isFeatured,
    int? displayOrder,
    int? serviceCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      displayOrder: displayOrder ?? this.displayOrder,
      serviceCount: serviceCount ?? this.serviceCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =====================================================
  // FROM MAP
  // =====================================================

  factory CategoryModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CategoryModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      name: map['name'] ?? '',

      description: map['description'],

      image: map['image'],

      icon: map['icon'],

      isActive: map['isActive'] ?? true,

      isFeatured: map['isFeatured'] ?? false,

      displayOrder:
          map['displayOrder'] ?? 0,

      serviceCount:
          map['serviceCount'] ?? 0,

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
      'description': description,
      'image': image,
      'icon': icon,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'displayOrder': displayOrder,
      'serviceCount': serviceCount,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // =====================================================
  // FROM JSON
  // =====================================================

  factory CategoryModel.fromJson(
    String source,
  ) {
    return CategoryModel.fromMap(
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

  String get imageUrl {
    return image ?? '';
  }

  String get iconUrl {
    return icon ?? '';
  }

  bool get hasImage {
    return image != null &&
        image!.isNotEmpty;
  }

  bool get hasIcon {
    return icon != null &&
        icon!.isNotEmpty;
  }

  // =====================================================
  // OVERRIDES
  // =====================================================

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CategoryModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}