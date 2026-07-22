import 'dart:convert';

class CartModel {
  final String id;
  final String userId;

  final List<CartItem> items;

  final double subtotal;
  final double gst;
  final double deliveryFee;
  final double discount;
  final double totalAmount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.totalAmount,
    this.gst = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory CartModel.empty() {
    return const CartModel(
      id: '',
      userId: '',
      items: [],
      subtotal: 0,
      totalAmount: 0,
    );
  }

  factory CartModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CartModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      userId:
          map['userId']?.toString() ?? '',

      items: map['items'] != null
          ? List<CartItem>.from(
              (map['items'] as List).map(
                (x) => CartItem.fromMap(x),
              ),
            )
          : [],

      subtotal:
          (map['subtotal'] as num?)
                  ?.toDouble() ??
              0,

      gst:
          (map['gst'] as num?)
                  ?.toDouble() ??
              0,

      deliveryFee:
          (map['deliveryFee'] as num?)
                  ?.toDouble() ??
              0,

      discount:
          (map['discount'] as num?)
                  ?.toDouble() ??
              0,

      totalAmount:
          (map['totalAmount'] as num?)
                  ?.toDouble() ??
              0,

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

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'items':
          items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'gst': gst,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  factory CartModel.fromJson(
    String source,
  ) {
    return CartModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  CartModel copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    double? subtotal,
    double? gst,
    double? deliveryFee,
    double? discount,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      gst: gst ?? this.gst,
      deliveryFee:
          deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      totalAmount:
          totalAmount ?? this.totalAmount,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  int get totalItems {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() {
    return 'CartModel(id: $id, items: ${items.length})';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CartModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class CartItem {
  final String id;

  final String itemId;
  final String itemName;

  /// service | product
  final String itemType;

  final String? image;

  final String? providerId;
  final String? providerName;

  final int quantity;

  final double price;
  final double totalPrice;

  final double? rating;

  const CartItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.image,
    this.providerId,
    this.providerName,
    this.rating,
  });

  factory CartItem.fromMap(
    Map<String, dynamic> map,
  ) {
    return CartItem(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      itemId:
          map['itemId']?.toString() ?? '',

      itemName:
          map['itemName'] ?? '',

      itemType:
          map['itemType'] ?? 'service',

      image:
          map['image'],

      providerId:
          map['providerId']?.toString(),

      providerName:
          map['providerName'],

      quantity:
          map['quantity'] ?? 1,

      price:
          (map['price'] as num?)
                  ?.toDouble() ??
              0,

      totalPrice:
          (map['totalPrice'] as num?)
                  ?.toDouble() ??
              0,

      rating:
          (map['rating'] as num?)
              ?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'itemId': itemId,
      'itemName': itemName,
      'itemType': itemType,
      'image': image,
      'providerId': providerId,
      'providerName': providerName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
      'rating': rating,
    };
  }

  CartItem copyWith({
    String? id,
    String? itemId,
    String? itemName,
    String? itemType,
    String? image,
    String? providerId,
    String? providerName,
    int? quantity,
    double? price,
    double? totalPrice,
    double? rating,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemType: itemType ?? this.itemType,
      image: image ?? this.image,
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ?? this.providerName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice:
          totalPrice ?? this.totalPrice,
      rating: rating ?? this.rating,
    );
  }

  bool get isService =>
      itemType.toLowerCase() == 'service';

  bool get isProduct =>
      itemType.toLowerCase() == 'product';

  bool get hasImage =>
      image != null && image!.isNotEmpty;

  @override
  String toString() {
    return 'CartItem(itemName: $itemName)';
  }
}