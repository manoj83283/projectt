class OrderModel {
  final String id;

  final String orderNumber;

  final String customerId;
  final String customerName;
  final String customerPhone;

  final String providerId;
  final String providerName;

  final List<OrderItemModel> items;

  final double subTotal;
  final double taxAmount;
  final double deliveryCharge;
  final double discountAmount;
  final double totalAmount;

  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;

  final String? couponCode;

  final String deliveryAddress;
  final String? city;
  final String? state;
  final String? pincode;

  final String? notes;
  final String? cancellationReason;

  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.providerId,
    required this.providerName,
    required this.items,
    required this.subTotal,
    required this.taxAmount,
    required this.deliveryCharge,
    required this.discountAmount,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    this.couponCode,
    required this.deliveryAddress,
    this.city,
    this.state,
    this.pincode,
    this.notes,
    this.cancellationReason,
    this.deliveredAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrderModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      orderNumber:
          json['orderNumber']
                  ?.toString() ??
              '',

      customerId:
          json['customerId']
                  ?.toString() ??
              '',

      customerName:
          json['customerName']
                  ?.toString() ??
              '',

      customerPhone:
          json['customerPhone']
                  ?.toString() ??
              '',

      providerId:
          json['providerId']
                  ?.toString() ??
              '',

      providerName:
          json['providerName']
                  ?.toString() ??
              '',

      items:
          (json['items'] as List?)
                  ?.map(
                    (e) =>
                        OrderItemModel.fromJson(
                      e,
                    ),
                  )
                  .toList() ??
              [],

      subTotal:
          (json['subTotal'] ?? 0)
              .toDouble(),

      taxAmount:
          (json['taxAmount'] ?? 0)
              .toDouble(),

      deliveryCharge:
          (json['deliveryCharge'] ?? 0)
              .toDouble(),

      discountAmount:
          (json['discountAmount'] ?? 0)
              .toDouble(),

      totalAmount:
          (json['totalAmount'] ?? 0)
              .toDouble(),

      orderStatus:
          json['orderStatus']
                  ?.toString() ??
              'pending',

      paymentStatus:
          json['paymentStatus']
                  ?.toString() ??
              'pending',

      paymentMethod:
          json['paymentMethod']
                  ?.toString() ??
              'online',

      couponCode:
          json['couponCode']
              ?.toString(),

      deliveryAddress:
          json['deliveryAddress']
                  ?.toString() ??
              '',

      city:
          json['city']?.toString(),

      state:
          json['state']?.toString(),

      pincode:
          json['pincode']?.toString(),

      notes:
          json['notes']?.toString(),

      cancellationReason:
          json['cancellationReason']
              ?.toString(),

      deliveredAt:
          json['deliveredAt'] != null
              ? DateTime.tryParse(
                  json['deliveredAt']
                      .toString(),
                )
              : null,

      cancelledAt:
          json['cancelledAt'] != null
              ? DateTime.tryParse(
                  json['cancelledAt']
                      .toString(),
                )
              : null,

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
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'providerId': providerId,
      'providerName': providerName,
      'items':
          items.map((e) => e.toJson()).toList(),
      'subTotal': subTotal,
      'taxAmount': taxAmount,
      'deliveryCharge': deliveryCharge,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'couponCode': couponCode,
      'deliveryAddress': deliveryAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'notes': notes,
      'cancellationReason':
          cancellationReason,
      'deliveredAt':
          deliveredAt?.toIso8601String(),
      'cancelledAt':
          cancelledAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? providerId,
    String? providerName,
    List<OrderItemModel>? items,
    double? subTotal,
    double? taxAmount,
    double? deliveryCharge,
    double? discountAmount,
    double? totalAmount,
    String? orderStatus,
    String? paymentStatus,
    String? paymentMethod,
    String? couponCode,
    String? deliveryAddress,
    String? city,
    String? state,
    String? pincode,
    String? notes,
    String? cancellationReason,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
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
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ?? this.providerName,
      items: items ?? this.items,
      subTotal: subTotal ?? this.subTotal,
      taxAmount:
          taxAmount ?? this.taxAmount,
      deliveryCharge:
          deliveryCharge ??
              this.deliveryCharge,
      discountAmount:
          discountAmount ??
              this.discountAmount,
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
      couponCode:
          couponCode ?? this.couponCode,
      deliveryAddress:
          deliveryAddress ??
              this.deliveryAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      notes: notes ?? this.notes,
      cancellationReason:
          cancellationReason ??
              this.cancellationReason,
      deliveredAt:
          deliveredAt ?? this.deliveredAt,
      cancelledAt:
          cancelledAt ?? this.cancelledAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending =>
      orderStatus.toLowerCase() ==
      'pending';

  bool get isProcessing =>
      orderStatus.toLowerCase() ==
      'processing';

  bool get isDelivered =>
      orderStatus.toLowerCase() ==
      'delivered';

  bool get isCancelled =>
      orderStatus.toLowerCase() ==
      'cancelled';

  bool get isPaid =>
      paymentStatus.toLowerCase() ==
      'paid';

  int get totalItems => items.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class OrderItemModel {
  final String productId;
  final String productName;

  final String? image;

  final int quantity;
  final double price;
  final double totalPrice;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    this.image,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrderItemModel(
      productId:
          json['productId']?.toString() ??
              '',
      productName:
          json['productName']
                  ?.toString() ??
              '',
      image: json['image']?.toString(),
      quantity: json['quantity'] ?? 0,
      price:
          (json['price'] ?? 0).toDouble(),
      totalPrice:
          (json['totalPrice'] ?? 0)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'image': image,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }
}