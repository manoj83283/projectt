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
    final Map<String, dynamic> normalizedMap =
        Map<String, dynamic>.from(map);

    final dynamic customer = normalizedMap['customer'];
    final dynamic user = normalizedMap['user'];

    final String resolvedCustomerId =
        normalizedMap['customerId']?.toString() ??
            normalizedMap['userId']?.toString() ??
            (customer is Map ? customer['_id']?.toString() : null) ??
            (customer is Map ? customer['id']?.toString() : null) ??
            (user is Map ? user['_id']?.toString() : null) ??
            (user is Map ? user['id']?.toString() : null) ??
            '';

    final String resolvedCustomerName =
        normalizedMap['customerName']?.toString() ??
            (customer is Map ? customer['name']?.toString() : null) ??
            (customer is Map ? customer['fullName']?.toString() : null) ??
            (user is Map ? user['name']?.toString() : null) ??
            (user is Map ? user['fullName']?.toString() : null) ??
            '';

    final String resolvedCustomerPhone =
        normalizedMap['customerPhone']?.toString() ??
            normalizedMap['phone']?.toString() ??
            normalizedMap['mobile']?.toString() ??
            (customer is Map ? customer['phone']?.toString() : null) ??
            (customer is Map ? customer['mobile']?.toString() : null) ??
            (user is Map ? user['phone']?.toString() : null) ??
            (user is Map ? user['mobile']?.toString() : null) ??
            '';

    final dynamic rawItems =
        normalizedMap['items'] ??
            normalizedMap['orderItems'] ??
            normalizedMap['products'] ??
            [];

    return OrderModel(
      id: normalizedMap['_id']?.toString() ??
          normalizedMap['id']?.toString() ??
          '',
      orderNumber: normalizedMap['orderNumber']?.toString() ??
          normalizedMap['orderNo']?.toString() ??
          normalizedMap['invoiceNumber']?.toString() ??
          '',
      customerId: resolvedCustomerId,
      customerName: resolvedCustomerName,
      customerPhone: resolvedCustomerPhone,
      items: rawItems is List
          ? rawItems
              .map(
                (e) => OrderItem.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
          : [],
      subtotal: _toDouble(
        normalizedMap['subtotal'] ??
            normalizedMap['subTotal'] ??
            normalizedMap['itemsTotal'],
      ),
      gst: _toDouble(
        normalizedMap['gst'] ??
            normalizedMap['tax'] ??
            normalizedMap['taxAmount'],
      ),
      deliveryFee: _toDouble(
        normalizedMap['deliveryFee'] ??
            normalizedMap['deliveryCharge'] ??
            normalizedMap['shippingFee'],
      ),
      discount: _toDouble(
        normalizedMap['discount'] ??
            normalizedMap['discountAmount'],
      ),
      totalAmount: _toDouble(
        normalizedMap['totalAmount'] ??
            normalizedMap['amount'] ??
            normalizedMap['grandTotal'] ??
            normalizedMap['total'],
      ),
      orderStatus: normalizedMap['orderStatus']?.toString() ??
          normalizedMap['status']?.toString() ??
          'pending',
      paymentStatus: normalizedMap['paymentStatus']?.toString() ??
          normalizedMap['payment']?.toString() ??
          'pending',
      paymentMethod:
          normalizedMap['paymentMethod']?.toString() ?? '',
      paymentId: normalizedMap['paymentId']?.toString() ??
          normalizedMap['transactionId']?.toString(),
      address: normalizedMap['address']?.toString() ??
          normalizedMap['deliveryAddress']?.toString(),
      latitude: _toNullableDouble(
        normalizedMap['latitude'] ??
            normalizedMap['lat'],
      ),
      longitude: _toNullableDouble(
        normalizedMap['longitude'] ??
            normalizedMap['lng'] ??
            normalizedMap['long'],
      ),
      notes: normalizedMap['notes']?.toString() ??
          normalizedMap['remarks']?.toString(),
      createdAt: _toDateTime(
        normalizedMap['createdAt'],
      ),
      updatedAt: _toDateTime(
        normalizedMap['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'gst': gst,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'status': orderStatus,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(
    String source,
  ) {
    return OrderModel.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  String toJson() {
    return jsonEncode(
      toMap(),
    );
  }

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
    String? status,
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
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      gst: gst ?? this.gst,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? status ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // COMPATIBILITY GETTERS
  // ==========================================

  String get status => orderStatus;

  String get displayStatus => orderStatus;

  String get displayPaymentStatus => paymentStatus;

  bool get isPending => orderStatus == 'pending';

  bool get isAccepted =>
      orderStatus == 'accepted' ||
      orderStatus == 'confirmed';

  bool get isPreparing =>
      orderStatus == 'preparing' ||
      orderStatus == 'processing';

  bool get isProcessing =>
      orderStatus == 'processing' ||
      orderStatus == 'preparing';

  bool get isOutForDelivery =>
      orderStatus == 'out_for_delivery' ||
      orderStatus == 'shipped';

  bool get isShipped =>
      orderStatus == 'shipped' ||
      orderStatus == 'out_for_delivery';

  bool get isDelivered =>
      orderStatus == 'delivered' ||
      orderStatus == 'completed';

  bool get isCompleted =>
      orderStatus == 'completed' ||
      orderStatus == 'delivered';

  bool get isCancelled => orderStatus == 'cancelled';

  bool get isRejected => orderStatus == 'rejected';

  bool get isPaid =>
      paymentStatus == 'paid' ||
      paymentStatus == 'success' ||
      paymentStatus == 'completed';

  bool get isPaymentPending =>
      paymentStatus == 'pending';

  bool get isPaymentFailed =>
      paymentStatus == 'failed';

  bool get isRefunded =>
      paymentStatus == 'refunded';

  int get totalItems {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  bool get hasItems => items.isNotEmpty;

  bool get hasAddress =>
      address != null && address!.trim().isNotEmpty;

  bool get hasLocation =>
      latitude != null && longitude != null;

  static double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _toNullableDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  @override
  bool operator ==(
    Object other,
  ) {
    return identical(this, other) ||
        other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber, status: $orderStatus)';
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

  factory OrderItem.empty() {
    return const OrderItem(
      id: '',
      name: '',
      quantity: 0,
      price: 0,
      totalPrice: 0,
    );
  }

  factory OrderItem.fromMap(
    Map<String, dynamic> map,
  ) {
    return OrderItem(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          map['productId']?.toString() ??
          map['serviceId']?.toString() ??
          '',
      name: map['name']?.toString() ??
          map['title']?.toString() ??
          map['productName']?.toString() ??
          map['serviceName']?.toString() ??
          '',
      image: map['image']?.toString() ??
          map['imageUrl']?.toString() ??
          map['thumbnail']?.toString(),
      quantity: _toInt(
        map['quantity'],
      ),
      price: _toDouble(
        map['price'] ??
            map['unitPrice'] ??
            map['amount'],
      ),
      totalPrice: _toDouble(
        map['totalPrice'] ??
            map['total'] ??
            map['subtotal'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'image': image,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  factory OrderItem.fromJson(
    String source,
  ) {
    return OrderItem.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  String toJson() {
    return jsonEncode(
      toMap(),
    );
  }

  OrderItem copyWith({
    String? id,
    String? name,
    String? image,
    int? quantity,
    double? price,
    double? totalPrice,
  }) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  static int _toInt(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  @override
  bool operator ==(
    Object other,
  ) {
    return identical(this, other) ||
        other is OrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderItem(id: $id, name: $name, quantity: $quantity)';
  }
}