import 'dart:convert';

class WishlistModel {
  final String id;

  final String userId;

  final String itemId;
  final String itemName;

  final String itemType;

  final String? image;

  final double price;
  final double rating;

  final String? providerId;
  final String? providerName;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WishlistModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemName,
    required this.itemType,
    this.image,
    this.price = 0,
    this.rating = 0,
    this.providerId,
    this.providerName,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // EMPTY
  // ==========================================

  factory WishlistModel.empty() {
    return const WishlistModel(
      id: '',
      userId: '',
      itemId: '',
      itemName: '',
      itemType: 'service',
    );
  }

  // ==========================================
  // COPY WITH
  // ==========================================

  WishlistModel copyWith({
    String? id,
    String? userId,
    String? itemId,
    String? itemName,
    String? itemType,
    String? image,
    double? price,
    double? rating,
    String? providerId,
    String? providerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishlistModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemType: itemType ?? this.itemType,
      image: image ?? this.image,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // FROM MAP
  // ==========================================

  factory WishlistModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return WishlistModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      userId:
          map['userId']?.toString() ?? '',

      itemId:
          map['itemId']?.toString() ?? '',

      itemName:
          map['itemName'] ?? '',

      itemType:
          map['itemType'] ?? 'service',

      image:
          map['image'],

      price:
          (map['price'] as num?)
                  ?.toDouble() ??
              0,

      rating:
          (map['rating'] as num?)
                  ?.toDouble() ??
              0,

      providerId:
          map['providerId']?.toString(),

      providerName:
          map['providerName'],

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
      'itemId': itemId,
      'itemName': itemName,
      'itemType': itemType,
      'image': image,
      'price': price,
      'rating': rating,
      'providerId': providerId,
      'providerName': providerName,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // ==========================================
  // JSON
  // ==========================================

  factory WishlistModel.fromJson(
    String source,
  ) {
    return WishlistModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // ==========================================
  // GETTERS
  // ==========================================

  bool get isService =>
      itemType.toLowerCase() ==
      'service';

  bool get isProvider =>
      itemType.toLowerCase() ==
      'provider';

  bool get isProduct =>
      itemType.toLowerCase() ==
      'product';

  bool get hasImage =>
      image != null &&
      image!.isNotEmpty;

  String get imageUrl =>
      image ?? '';

  // ==========================================
  // OVERRIDES
  // ==========================================

  @override
  String toString() {
    return 'WishlistModel(id: $id, itemName: $itemName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WishlistModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}