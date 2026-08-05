enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
}

enum PaymentMethod {
  upi,
  card,
  netBanking,
  wallet,
  cash,
  bankTransfer,
}

extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';

      case PaymentStatus.processing:
        return 'processing';

      case PaymentStatus.success:
        return 'success';

      case PaymentStatus.failed:
        return 'failed';

      case PaymentStatus.cancelled:
        return 'cancelled';

      case PaymentStatus.refunded:
        return 'refunded';

      case PaymentStatus.partiallyRefunded:
        return 'partially_refunded';
    }
  }

  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';

      case PaymentStatus.processing:
        return 'Processing';

      case PaymentStatus.success:
        return 'Success';

      case PaymentStatus.failed:
        return 'Failed';

      case PaymentStatus.cancelled:
        return 'Cancelled';

      case PaymentStatus.refunded:
        return 'Refunded';

      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }

  static PaymentStatus fromString(dynamic value) {
    final status = value?.toString().toLowerCase().trim() ?? '';

    switch (status) {
      case 'processing':
        return PaymentStatus.processing;

      case 'success':
      case 'paid':
      case 'completed':
        return PaymentStatus.success;

      case 'failed':
        return PaymentStatus.failed;

      case 'cancelled':
      case 'canceled':
        return PaymentStatus.cancelled;

      case 'refunded':
        return PaymentStatus.refunded;

      case 'partiallyrefunded':
      case 'partially_refunded':
      case 'partial_refund':
        return PaymentStatus.partiallyRefunded;

      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.upi:
        return 'upi';

      case PaymentMethod.card:
        return 'card';

      case PaymentMethod.netBanking:
        return 'net_banking';

      case PaymentMethod.wallet:
        return 'wallet';

      case PaymentMethod.cash:
        return 'cash';

      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.upi:
        return 'UPI';

      case PaymentMethod.card:
        return 'Card';

      case PaymentMethod.netBanking:
        return 'Net Banking';

      case PaymentMethod.wallet:
        return 'Wallet';

      case PaymentMethod.cash:
        return 'Cash';

      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }

  static PaymentMethod fromString(dynamic value) {
    final method = value?.toString().toLowerCase().trim() ?? '';

    switch (method) {
      case 'card':
      case 'credit_card':
      case 'debit_card':
        return PaymentMethod.card;

      case 'netbanking':
      case 'net_banking':
      case 'net banking':
        return PaymentMethod.netBanking;

      case 'wallet':
        return PaymentMethod.wallet;

      case 'cash':
      case 'cod':
        return PaymentMethod.cash;

      case 'banktransfer':
      case 'bank_transfer':
      case 'bank transfer':
        return PaymentMethod.bankTransfer;

      case 'upi':
      default:
        return PaymentMethod.upi;
    }
  }
}

class PaymentModel {
  final String id;

  final String bookingId;
  final String orderId;

  final String customerId;
  final String providerId;

  final String transactionId;
  final String paymentGateway;

  /// ✅ Kept as String because your screens use:
  /// payment.paymentMethod ?? ''
  final String paymentMethod;

  /// ✅ Kept as String because your screens use:
  /// payment.status
  /// payment.status.toUpperCase()
  /// _statusColor(payment.status)
  final String status;

  final String currency;

  final double amount;
  final double taxAmount;
  final double discountAmount;
  final double platformFee;
  final double providerAmount;

  final double refundAmount;

  final bool isRefunded;

  final String remarks;

  /// ✅ Kept as String for UI compatibility
  final String paymentDate;

  final String refundDate;

  /// ✅ Kept as String because your screens use:
  /// payment.createdAt ?? ''
  final String createdAt;

  final String updatedAt;

  final Map<String, dynamic>? rawBooking;
  final Map<String, dynamic>? rawOrder;
  final Map<String, dynamic>? rawCustomer;
  final Map<String, dynamic>? rawProvider;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.orderId,
    required this.customerId,
    required this.providerId,
    required this.transactionId,
    required this.paymentGateway,
    required this.paymentMethod,
    required this.status,
    required this.currency,
    required this.amount,
    required this.taxAmount,
    required this.discountAmount,
    required this.platformFee,
    required this.providerAmount,
    required this.refundAmount,
    required this.isRefunded,
    required this.remarks,
    required this.paymentDate,
    required this.refundDate,
    required this.createdAt,
    required this.updatedAt,
    this.rawBooking,
    this.rawOrder,
    this.rawCustomer,
    this.rawProvider,
  });

  factory PaymentModel.empty() {
    return const PaymentModel(
      id: '',
      bookingId: '',
      orderId: '',
      customerId: '',
      providerId: '',
      transactionId: '',
      paymentGateway: '',
      paymentMethod: 'upi',
      status: 'pending',
      currency: 'INR',
      amount: 0,
      taxAmount: 0,
      discountAmount: 0,
      platformFee: 0,
      providerAmount: 0,
      refundAmount: 0,
      isRefunded: false,
      remarks: '',
      paymentDate: '',
      refundDate: '',
      createdAt: '',
      updatedAt: '',
    );
  }

  factory PaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final booking = _asMap(json['booking']);

    final order = _asMap(json['order']);

    final customer = _asMap(json['customer']) ??
        _asMap(json['user']);

    final provider = _asMap(json['provider']);

    final parsedBookingId = booking?['_id']?.toString() ??
        booking?['id']?.toString() ??
        json['bookingId']?.toString() ??
        json['booking']?.toString() ??
        '';

    final parsedOrderId = order?['_id']?.toString() ??
        order?['id']?.toString() ??
        json['orderId']?.toString() ??
        json['order']?.toString() ??
        '';

    final parsedCustomerId = customer?['_id']?.toString() ??
        customer?['id']?.toString() ??
        json['customerId']?.toString() ??
        json['userId']?.toString() ??
        json['customer']?.toString() ??
        json['user']?.toString() ??
        '';

    final parsedProviderId = provider?['_id']?.toString() ??
        provider?['id']?.toString() ??
        json['providerId']?.toString() ??
        json['provider']?.toString() ??
        '';

    final parsedStatus = json['status']?.toString() ??
        json['paymentStatus']?.toString() ??
        'pending';

    final parsedPaymentMethod = json['paymentMethod']?.toString() ??
        json['method']?.toString() ??
        '';

    final parsedAmount = _toDouble(
      json['amount'] ??
          json['totalAmount'] ??
          json['totalPrice'] ??
          order?['totalAmount'] ??
          booking?['totalPrice'],
    );

    final parsedPlatformFee = _toDouble(
      json['platformFee'],
    );

    final parsedProviderAmount = _toDouble(
      json['providerAmount'] ??
          (parsedAmount - parsedPlatformFee),
    );

    return PaymentModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      bookingId: parsedBookingId,

      orderId: parsedOrderId,

      customerId: parsedCustomerId,

      providerId: parsedProviderId,

      transactionId: json['transactionId']?.toString() ??
          json['paymentId']?.toString() ??
          json['razorpayPaymentId']?.toString() ??
          '',

      paymentGateway: json['paymentGateway']?.toString() ??
          json['gateway']?.toString() ??
          '',

      paymentMethod: parsedPaymentMethod.isNotEmpty
          ? parsedPaymentMethod
          : PaymentMethod.upi.value,

      status: parsedStatus.toLowerCase().trim(),

      currency: json['currency']?.toString() ?? 'INR',

      amount: parsedAmount,

      taxAmount: _toDouble(
        json['taxAmount'],
      ),

      discountAmount: _toDouble(
        json['discountAmount'],
      ),

      platformFee: parsedPlatformFee,

      providerAmount: parsedProviderAmount,

      refundAmount: _toDouble(
        json['refundAmount'],
      ),

      isRefunded: _toBool(
        json['isRefunded'],
      ),

      remarks: json['remarks']?.toString() ??
          json['notes']?.toString() ??
          '',

      paymentDate: json['paymentDate']?.toString() ??
          json['paidAt']?.toString() ??
          json['createdAt']?.toString() ??
          '',

      refundDate: json['refundDate']?.toString() ??
          json['refundedAt']?.toString() ??
          '',

      createdAt: json['createdAt']?.toString() ?? '',

      updatedAt: json['updatedAt']?.toString() ?? '',

      rawBooking: booking,
      rawOrder: order,
      rawCustomer: customer,
      rawProvider: provider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,

      'bookingId': bookingId,
      'orderId': orderId,

      'customerId': customerId,
      'providerId': providerId,

      'transactionId': transactionId,
      'paymentGateway': paymentGateway,

      'paymentMethod': paymentMethod,
      'status': status,
      'paymentStatus': status,

      'currency': currency,

      'amount': amount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'platformFee': platformFee,
      'providerAmount': providerAmount,
      'refundAmount': refundAmount,

      'isRefunded': isRefunded,
      'remarks': remarks,

      'paymentDate': paymentDate,
      'refundDate': refundDate,

      'createdAt': createdAt,
      'updatedAt': updatedAt,

      'booking': rawBooking,
      'order': rawOrder,
      'customer': rawCustomer,
      'provider': rawProvider,
    };
  }

  static PaymentMethod _parsePaymentMethod(
    dynamic value,
  ) {
    return PaymentMethodExtension.fromString(value);
  }

  static PaymentStatus _parsePaymentStatus(
    dynamic value,
  ) {
    return PaymentStatusExtension.fromString(value);
  }

  PaymentMethod get paymentMethodEnum {
    return _parsePaymentMethod(paymentMethod);
  }

  PaymentStatus get statusEnum {
    return _parsePaymentStatus(status);
  }

  String get paymentMethodText {
    return paymentMethodEnum.label;
  }

  String get statusText {
    return statusEnum.label;
  }

  DateTime? get paymentDateTime {
    return _toDateTime(paymentDate);
  }

  DateTime? get refundDateTime {
    return _toDateTime(refundDate);
  }

  DateTime? get createdAtDateTime {
    return _toDateTime(createdAt);
  }

  DateTime? get updatedAtDateTime {
    return _toDateTime(updatedAt);
  }

  bool get isSuccessful {
    return status.toLowerCase() == 'success' ||
        status.toLowerCase() == 'paid' ||
        status.toLowerCase() == 'completed';
  }

  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  bool get isProcessing {
    return status.toLowerCase() == 'processing';
  }

  bool get isFailed {
    return status.toLowerCase() == 'failed';
  }

  bool get isCancelled {
    return status.toLowerCase() == 'cancelled' ||
        status.toLowerCase() == 'canceled';
  }

  bool get isFullyRefunded {
    return status.toLowerCase() == 'refunded';
  }

  bool get isPartiallyRefunded {
    return status.toLowerCase() == 'partially_refunded' ||
        status.toLowerCase() == 'partiallyrefunded';
  }

  double get netRevenue {
    return amount -
        taxAmount -
        discountAmount -
        platformFee;
  }

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? orderId,
    String? customerId,
    String? providerId,
    String? transactionId,
    String? paymentGateway,
    String? paymentMethod,
    String? status,
    String? currency,
    double? amount,
    double? taxAmount,
    double? discountAmount,
    double? platformFee,
    double? providerAmount,
    double? refundAmount,
    bool? isRefunded,
    String? remarks,
    String? paymentDate,
    String? refundDate,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? rawBooking,
    Map<String, dynamic>? rawOrder,
    Map<String, dynamic>? rawCustomer,
    Map<String, dynamic>? rawProvider,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      transactionId: transactionId ?? this.transactionId,
      paymentGateway:
          paymentGateway ?? this.paymentGateway,
      paymentMethod:
          paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount:
          discountAmount ?? this.discountAmount,
      platformFee: platformFee ?? this.platformFee,
      providerAmount:
          providerAmount ?? this.providerAmount,
      refundAmount: refundAmount ?? this.refundAmount,
      isRefunded: isRefunded ?? this.isRefunded,
      remarks: remarks ?? this.remarks,
      paymentDate: paymentDate ?? this.paymentDate,
      refundDate: refundDate ?? this.refundDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rawBooking: rawBooking ?? this.rawBooking,
      rawOrder: rawOrder ?? this.rawOrder,
      rawCustomer: rawCustomer ?? this.rawCustomer,
      rawProvider: rawProvider ?? this.rawProvider,
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

  static bool _toBool(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    final text = value.toString().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes';
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
        other is PaymentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentModel(id: $id, transactionId: $transactionId, amount: $amount, status: $status)';
  }
}