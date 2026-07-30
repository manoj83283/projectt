enum OrderStatus {
  pending,
  confirmed,
  processing,
  inProgress,
  completed,
  cancelled,
  refunded,
}

class OrderModel {
  final String id;

  final String orderNumber;
  final String bookingId;

  final String customerId;
  final String customerName;
  final String customerPhone;

  final String providerId;
  final String providerName;

  final String serviceId;
  final String serviceName;

  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double platformFee;
  final double totalAmount;

  final OrderStatus status;

  final String paymentStatus;
  final String paymentMethod;
  final String transactionId;

  final String eventAddress;
  final String city;
  final String state;

  final String notes;

  final DateTime orderDate;

  final DateTime? completedDate;
  final DateTime? cancelledDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.platformFee,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionId,
    required this.eventAddress,
    required this.city,
    required this.state,
    required this.notes,
    required this.orderDate,
    this.completedDate,
    this.cancelledDate,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.empty() {
    return OrderModel(
      id: '',
      orderNumber: '',
      bookingId: '',
      customerId: '',
      customerName: '',
      customerPhone: '',
      providerId: '',
      providerName: '',
      serviceId: '',
      serviceName: '',
      subtotal: 0,
      taxAmount: 0,
      discountAmount: 0,
      platformFee: 0,
      totalAmount: 0,
      status: OrderStatus.pending,
      paymentStatus: 'Pending',
      paymentMethod: '',
      transactionId: '',
      eventAddress: '',
      city: '',
      state: '',
      notes: '',
      orderDate: DateTime.now(),
    );
  }

  factory OrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrderModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      orderNumber:
          json['orderNumber']?.toString() ?? '',
      bookingId:
          json['bookingId']?.toString() ?? '',
      customerId:
          json['customerId']?.toString() ?? '',
      customerName:
          json['customerName']?.toString() ?? '',
      customerPhone:
          json['customerPhone']?.toString() ?? '',
      providerId:
          json['providerId']?.toString() ?? '',
      providerName:
          json['providerName']?.toString() ?? '',
      serviceId:
          json['serviceId']?.toString() ?? '',
      serviceName:
          json['serviceName']?.toString() ?? '',
      subtotal:
          (json['subtotal'] ?? 0).toDouble(),
      taxAmount:
          (json['taxAmount'] ?? 0).toDouble(),
      discountAmount:
          (json['discountAmount'] ?? 0)
              .toDouble(),
      platformFee:
          (json['platformFee'] ?? 0)
              .toDouble(),
      totalAmount:
          (json['totalAmount'] ?? 0)
              .toDouble(),
      status: _parseStatus(
        json['status'],
      ),
      paymentStatus:
          json['paymentStatus']?.toString() ??
              'Pending',
      paymentMethod:
          json['paymentMethod']?.toString() ??
              '',
      transactionId:
          json['transactionId']?.toString() ??
              '',
      eventAddress:
          json['eventAddress']?.toString() ??
              '',
      city:
          json['city']?.toString() ?? '',
      state:
          json['state']?.toString() ?? '',
      notes:
          json['notes']?.toString() ?? '',
      orderDate:
          json['orderDate'] != null
              ? DateTime.parse(
                  json['orderDate'].toString(),
                )
              : DateTime.now(),
      completedDate:
          json['completedDate'] != null
              ? DateTime.tryParse(
                  json['completedDate']
                      .toString(),
                )
              : null,
      cancelledDate:
          json['cancelledDate'] != null
              ? DateTime.tryParse(
                  json['cancelledDate']
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
      'bookingId': bookingId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'providerId': providerId,
      'providerName': providerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'eventAddress': eventAddress,
      'city': city,
      'state': state,
      'notes': notes,
      'orderDate':
          orderDate.toIso8601String(),
      'completedDate':
          completedDate?.toIso8601String(),
      'cancelledDate':
          cancelledDate?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  static OrderStatus _parseStatus(
    dynamic value,
  ) {
    switch (
        value.toString().toLowerCase()) {
      case 'confirmed':
        return OrderStatus.confirmed;

      case 'processing':
        return OrderStatus.processing;

      case 'inprogress':
      case 'in_progress':
        return OrderStatus.inProgress;

      case 'completed':
        return OrderStatus.completed;

      case 'cancelled':
        return OrderStatus.cancelled;

      case 'refunded':
        return OrderStatus.refunded;

      default:
        return OrderStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  bool get isPending =>
      status == OrderStatus.pending;

  bool get isCompleted =>
      status == OrderStatus.completed;

  bool get isCancelled =>
      status == OrderStatus.cancelled;

  bool get isRefunded =>
      status == OrderStatus.refunded;

  double get netAmount =>
      totalAmount - platformFee;

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? bookingId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? providerId,
    String? providerName,
    String? serviceId,
    String? serviceName,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? platformFee,
    double? totalAmount,
    OrderStatus? status,
    String? paymentStatus,
    String? paymentMethod,
    String? transactionId,
    String? eventAddress,
    String? city,
    String? state,
    String? notes,
    DateTime? orderDate,
    DateTime? completedDate,
    DateTime? cancelledDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber:
          orderNumber ?? this.orderNumber,
      bookingId:
          bookingId ?? this.bookingId,
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
      serviceId:
          serviceId ?? this.serviceId,
      serviceName:
          serviceName ?? this.serviceName,
      subtotal:
          subtotal ?? this.subtotal,
      taxAmount:
          taxAmount ?? this.taxAmount,
      discountAmount:
          discountAmount ??
              this.discountAmount,
      platformFee:
          platformFee ?? this.platformFee,
      totalAmount:
          totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus:
          paymentStatus ?? this.paymentStatus,
      paymentMethod:
          paymentMethod ?? this.paymentMethod,
      transactionId:
          transactionId ?? this.transactionId,
      eventAddress:
          eventAddress ?? this.eventAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      notes: notes ?? this.notes,
      orderDate:
          orderDate ?? this.orderDate,
      completedDate:
          completedDate ?? this.completedDate,
      cancelledDate:
          cancelledDate ?? this.cancelledDate,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber)';
  }
}