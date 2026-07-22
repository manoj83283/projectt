import 'dart:convert';

class OrderModel {
  final String id;
  final String orderNumber;

  final String customerId;
  final String customerName;
  final String customerPhone;

  final List<OrderItem> items;

  final double subtotal;
  final double gst;
  final double deliveryFee;
  final double discount;
  final double totalAmount;

  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String? paymentId;

  final String? address;
  final double? latitude;
  final double? longitude;

  final String? notes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.totalAmount,
    this.gst = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.orderStatus = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod = '',
    this.paymentId,
    this.address,
    this.latitude,
    this.longitude,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.empty() {
    return const OrderModel(
      id: '',
      orderNumber: '',
      customerId: '',
      customerName: '',
      customerPhone: '',
      items: [],
      subtotal: 0,
      totalAmount: 0,
    );
  }

  factory OrderModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return OrderModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      orderNumber:
          map['orderNumber'] ?? '',

      customerId:
          map['customerId']?.toString() ?? '',

      customerName:
          map['customerName'] ?? '',

      customerPhone:
          map['customerPhone'] ?? '',

      items: map['items'] != null
          ? List<OrderItem>.from(
              (map['items'] as List).map(
                (e) => OrderItem.fromMap(e),
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

      orderStatus:
          map['orderStatus'] ??
              'pending',

      paymentStatus:
          map['paymentStatus'] ??
              'pending',

      paymentMethod:
          map['paymentMethod'] ?? '',

      paymentId:
          map['paymentId'],

      address:
          map['address'],

      latitude:
          (map['latitude'] as num?)
              ?.toDouble(),

      longitude:
          (map['longitude'] as num?)
              ?.toDouble(),

      notes:
          map['notes'],

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
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items':
          items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'gst': gst,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(
    String source,
  ) =>
      OrderModel.fromMap(
        jsonDecode(source),
      );

  String toJson() =>
      jsonEncode(toMap());

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? gst,
    double? deliveryFee,
    double? discount,
    double? totalAmount,
    String? orderStatus,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentId,
    String? address,
    double? latitude,
    double? longitude,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber:
          orderNumber ?? this.orderNumber,
      customerId:
          customerId ?? this.customerId,
      customerName:
          customerName ?? this.customerName,
      customerPhone:
          customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      gst: gst ?? this.gst,
      deliveryFee:
          deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      totalAmount:
          totalAmount ?? this.totalAmount,
      orderStatus:
          orderStatus ?? this.orderStatus,
      paymentStatus:
          paymentStatus ??
              this.paymentStatus,
      paymentMethod:
          paymentMethod ??
              this.paymentMethod,
      paymentId:
          paymentId ?? this.paymentId,
      address: address ?? this.address,
      latitude:
          latitude ?? this.latitude,
      longitude:
          longitude ?? this.longitude,
      notes: notes ?? this.notes,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending =>
      orderStatus == 'pending';

  bool get isAccepted =>
      orderStatus == 'accepted';

  bool get isPreparing =>
      orderStatus == 'preparing';

  bool get isOutForDelivery =>
      orderStatus == 'out_for_delivery';

  bool get isDelivered =>
      orderStatus == 'delivered';

  bool get isCancelled =>
      orderStatus == 'cancelled';

  bool get isPaid =>
      paymentStatus == 'paid';

  int get totalItems =>
      items.fold(
        0,
        (sum, item) =>
            sum + item.quantity,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber)';
  }
}

class OrderItem {
  final String id;
  final String name;
  final String? image;

  final int quantity;
  final double price;
  final double totalPrice;

  const OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.image,
  });

  factory OrderItem.fromMap(
    Map<String, dynamic> map,
  ) {
    return OrderItem(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      image: map['image'],
      quantity: map['quantity'] ?? 0,
      price:
          (map['price'] as num?)
                  ?.toDouble() ??
              0,
      totalPrice:
          (map['totalPrice'] as num?)
                  ?.toDouble() ??
              0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }
}