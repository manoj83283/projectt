enum OrderStatus {
  pending,
  confirmed,
  processing,
  inProgress,
  completed,
  cancelled,
  refunded,
  rejected,
}

extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';

      case OrderStatus.confirmed:
        return 'confirmed';

      case OrderStatus.processing:
        return 'processing';

      case OrderStatus.inProgress:
        return 'in_progress';

      case OrderStatus.completed:
        return 'completed';

      case OrderStatus.cancelled:
        return 'cancelled';

      case OrderStatus.refunded:
        return 'refunded';

      case OrderStatus.rejected:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
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

      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  static OrderStatus fromString(dynamic value) {
    final status = value?.toString().toLowerCase().trim() ?? '';

    switch (status) {
      case 'confirmed':
      case 'accepted':
        return OrderStatus.confirmed;

      case 'processing':
        return OrderStatus.processing;

      case 'inprogress':
      case 'in_progress':
        return OrderStatus.inProgress;

      case 'completed':
        return OrderStatus.completed;

      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;

      case 'refunded':
        return OrderStatus.refunded;

      case 'rejected':
        return OrderStatus.rejected;

      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel {
  final String id;

  final String orderNumber;
  final String bookingId;

  final String customerId;
  final String customerName;
  final String customerEmail;
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

  /// ✅ Kept as String because your screens use:
  /// order.status.toLowerCase()
  /// order.status.toUpperCase()
  /// _statusColor(order.status)
  final String status;

  final String paymentStatus;
  final String paymentMethod;
  final String transactionId;

  final String eventAddress;
  final String city;
  final String state;

  /// ✅ Added for existing screens
  final String location;

  final String notes;

  /// ✅ Kept as String because your screens use:
  /// order.orderDate ?? ''
  final String orderDate;

  /// ✅ Added for existing screens
  final String eventDate;

  final DateTime? completedDate;
  final DateTime? cancelledDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic>? rawUser;
  final Map<String, dynamic>? rawService;
  final Map<String, dynamic>? rawProvider;
  final Map<String, dynamic>? rawBooking;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
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
    required this.location,
    required this.notes,
    required this.orderDate,
    required this.eventDate,
    this.completedDate,
    this.cancelledDate,
    this.createdAt,
    this.updatedAt,
    this.rawUser,
    this.rawService,
    this.rawProvider,
    this.rawBooking,
  });

  factory OrderModel.empty() {
    return const OrderModel(
      id: '',
      orderNumber: '',
      bookingId: '',
      customerId: '',
      customerName: '',
      customerEmail: '',
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
      status: 'pending',
      paymentStatus: 'pending',
      paymentMethod: '',
      transactionId: '',
      eventAddress: '',
      city: '',
      state: '',
      location: '',
      notes: '',
      orderDate: '',
      eventDate: '',
    );
  }

  factory OrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final user = _asMap(json['user']) ??
        _asMap(json['customer']);

    final service = _asMap(json['service']);

    final provider = _asMap(json['provider']);

    final booking = _asMap(json['booking']);

    final userFirstName = user?['firstName']?.toString() ?? '';
    final userLastName = user?['lastName']?.toString() ?? '';
    final userFullName = user?['name']?.toString() ?? '';

    final parsedCustomerName = userFullName.isNotEmpty
        ? userFullName
        : '$userFirstName $userLastName'.trim();

    final parsedBookingId = booking?['_id']?.toString() ??
        booking?['id']?.toString() ??
        json['bookingId']?.toString() ??
        json['booking']?.toString() ??
        '';

    final parsedCustomerId = user?['_id']?.toString() ??
        user?['id']?.toString() ??
        json['customerId']?.toString() ??
        json['userId']?.toString() ??
        json['customer']?.toString() ??
        json['user']?.toString() ??
        '';

    final parsedProviderId = provider?['_id']?.toString() ??
        provider?['id']?.toString() ??
        service?['provider']?.toString() ??
        json['providerId']?.toString() ??
        json['provider']?.toString() ??
        '';

    final parsedServiceId = service?['_id']?.toString() ??
        service?['id']?.toString() ??
        json['serviceId']?.toString() ??
        json['service']?.toString() ??
        '';

    final parsedOrderDate = json['orderDate']?.toString() ??
        json['date']?.toString() ??
        booking?['date']?.toString() ??
        json['createdAt']?.toString() ??
        '';

    final parsedEventDate = json['eventDate']?.toString() ??
        json['bookingDate']?.toString() ??
        booking?['bookingDate']?.toString() ??
        booking?['date']?.toString() ??
        parsedOrderDate;

    final parsedAddress = json['eventAddress']?.toString() ??
        json['address']?.toString() ??
        json['location']?.toString() ??
        booking?['address']?.toString() ??
        booking?['location']?.toString() ??
        '';

    final parsedSubtotal = _toDouble(
      json['subtotal'] ??
          json['amount'] ??
          json['price'] ??
          json['totalPrice'] ??
          booking?['totalPrice'],
    );

    final parsedTotal = _toDouble(
      json['totalAmount'] ??
          json['totalPrice'] ??
          json['amount'] ??
          json['price'] ??
          booking?['totalPrice'] ??
          parsedSubtotal,
    );

    final parsedStatus =
        json['status']?.toString().toLowerCase().trim() ?? 'pending';

    return OrderModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      orderNumber: json['orderNumber']?.toString() ??
          json['orderNo']?.toString() ??
          json['bookingNumber']?.toString() ??
          '',

      bookingId: parsedBookingId,

      customerId: parsedCustomerId,

      customerName: json['customerName']?.toString() ??
          parsedCustomerName,

      customerEmail: json['customerEmail']?.toString() ??
          user?['email']?.toString() ??
          '',

      customerPhone: json['customerPhone']?.toString() ??
          user?['phone']?.toString() ??
          '',

      providerId: parsedProviderId,

      providerName: json['providerName']?.toString() ??
          provider?['name']?.toString() ??
          provider?['firstName']?.toString() ??
          '',

      serviceId: parsedServiceId,

      serviceName: json['serviceName']?.toString() ??
          service?['name']?.toString() ??
          service?['title']?.toString() ??
          'Service',

      subtotal: parsedSubtotal,

      taxAmount: _toDouble(
        json['taxAmount'],
      ),

      discountAmount: _toDouble(
        json['discountAmount'],
      ),

      platformFee: _toDouble(
        json['platformFee'],
      ),

      totalAmount: parsedTotal,

      status: parsedStatus,

      paymentStatus: json['paymentStatus']?.toString() ??
          booking?['paymentStatus']?.toString() ??
          'pending',

      paymentMethod: json['paymentMethod']?.toString() ??
          booking?['paymentMethod']?.toString() ??
          '',

      transactionId: json['transactionId']?.toString() ??
          json['paymentId']?.toString() ??
          '',

      eventAddress: parsedAddress,

      city: json['city']?.toString() ?? '',

      state: json['state']?.toString() ?? '',

      location: json['location']?.toString() ??
          parsedAddress,

      notes: json['notes']?.toString() ??
          booking?['notes']?.toString() ??
          '',

      orderDate: parsedOrderDate,

      eventDate: parsedEventDate,

      completedDate: _toDateTime(
        json['completedDate'] ??
            json['completedAt'],
      ),

      cancelledDate: _toDateTime(
        json['cancelledDate'] ??
            json['cancelledAt'],
      ),

      createdAt: _toDateTime(
        json['createdAt'],
      ),

      updatedAt: _toDateTime(
        json['updatedAt'],
      ),

      rawUser: user,
      rawService: service,
      rawProvider: provider,
      rawBooking: booking,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,

      'orderNumber': orderNumber,
      'bookingId': bookingId,

      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
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
      'totalPrice': totalAmount,

      'status': status,

      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,

      'eventAddress': eventAddress,
      'address': eventAddress,
      'location': location,
      'city': city,
      'state': state,

      'notes': notes,

      'orderDate': orderDate,
      'eventDate': eventDate,

      'completedDate': completedDate?.toIso8601String(),
      'cancelledDate': cancelledDate?.toIso8601String(),

      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),

      'user': rawUser,
      'service': rawService,
      'provider': rawProvider,
      'booking': rawBooking,
    };
  }

  static OrderStatus _parseStatus(
    dynamic value,
  ) {
    return OrderStatusExtension.fromString(value);
  }

  String get statusText {
    return statusEnum.label;
  }

  OrderStatus get statusEnum {
    return _parseStatus(status);
  }

  DateTime? get orderDateTime {
    return _toDateTime(orderDate);
  }

  DateTime? get eventDateTime {
    return _toDateTime(eventDate);
  }

  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  bool get isConfirmed {
    return status.toLowerCase() == 'confirmed' ||
        status.toLowerCase() == 'accepted';
  }

  bool get isProcessing {
    return status.toLowerCase() == 'processing';
  }

  bool get isInProgress {
    return status.toLowerCase() == 'in_progress' ||
        status.toLowerCase() == 'inprogress';
  }

  bool get isCompleted {
    return status.toLowerCase() == 'completed';
  }

  bool get isCancelled {
    return status.toLowerCase() == 'cancelled' ||
        status.toLowerCase() == 'canceled';
  }

  bool get isRefunded {
    return status.toLowerCase() == 'refunded';
  }

  bool get isRejected {
    return status.toLowerCase() == 'rejected';
  }

  double get netAmount {
    return totalAmount - platformFee;
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? bookingId,
    String? customerId,
    String? customerName,
    String? customerEmail,
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
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? transactionId,
    String? eventAddress,
    String? city,
    String? state,
    String? location,
    String? notes,
    String? orderDate,
    String? eventDate,
    DateTime? completedDate,
    DateTime? cancelledDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? rawUser,
    Map<String, dynamic>? rawService,
    Map<String, dynamic>? rawProvider,
    Map<String, dynamic>? rawBooking,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      platformFee: platformFee ?? this.platformFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      eventAddress: eventAddress ?? this.eventAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      orderDate: orderDate ?? this.orderDate,
      eventDate: eventDate ?? this.eventDate,
      completedDate: completedDate ?? this.completedDate,
      cancelledDate: cancelledDate ?? this.cancelledDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rawUser: rawUser ?? this.rawUser,
      rawService: rawService ?? this.rawService,
      rawProvider: rawProvider ?? this.rawProvider,
      rawBooking: rawBooking ?? this.rawBooking,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(
          key.toString(),
          val,
        ),
      );
    }

    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    return DateTime.tryParse(
      value.toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OrderModel && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderModel(id: $id, orderNumber: $orderNumber, status: $status)';
  }
}