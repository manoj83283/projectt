class PaymentModel {
  final String id;

  final String transactionId;
  final String paymentGatewayOrderId;
  final String paymentGatewayPaymentId;

  final String bookingId;
  final String? orderId;

  final String customerId;
  final String customerName;

  final String providerId;
  final String providerName;

  final double amount;
  final double taxAmount;
  final double discountAmount;

  final double finalAmount;

  final String currency;

  final String paymentMethod;
  final String paymentGateway;

  final String paymentStatus;

  final String? refundId;
  final double refundedAmount;

  final bool isRefunded;

  final String? failureReason;
  final String? notes;

  final DateTime? paidAt;
  final DateTime? refundedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentModel({
    required this.id,
    required this.transactionId,
    required this.paymentGatewayOrderId,
    required this.paymentGatewayPaymentId,
    required this.bookingId,
    this.orderId,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.providerName,
    required this.amount,
    required this.taxAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentGateway,
    required this.paymentStatus,
    this.refundId,
    required this.refundedAmount,
    required this.isRefunded,
    this.failureReason,
    this.notes,
    this.paidAt,
    this.refundedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymentModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      transactionId:
          json['transactionId']
                  ?.toString() ??
              '',

      paymentGatewayOrderId:
          json['paymentGatewayOrderId']
                  ?.toString() ??
              '',

      paymentGatewayPaymentId:
          json['paymentGatewayPaymentId']
                  ?.toString() ??
              '',

      bookingId:
          json['bookingId']
                  ?.toString() ??
              '',

      orderId:
          json['orderId']?.toString(),

      customerId:
          json['customerId']
                  ?.toString() ??
              '',

      customerName:
          json['customerName']
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

      amount:
          (json['amount'] ?? 0)
              .toDouble(),

      taxAmount:
          (json['taxAmount'] ?? 0)
              .toDouble(),

      discountAmount:
          (json['discountAmount'] ?? 0)
              .toDouble(),

      finalAmount:
          (json['finalAmount'] ?? 0)
              .toDouble(),

      currency:
          json['currency']
                  ?.toString() ??
              'INR',

      paymentMethod:
          json['paymentMethod']
                  ?.toString() ??
              'online',

      paymentGateway:
          json['paymentGateway']
                  ?.toString() ??
              'razorpay',

      paymentStatus:
          json['paymentStatus']
                  ?.toString() ??
              'pending',

      refundId:
          json['refundId']?.toString(),

      refundedAmount:
          (json['refundedAmount'] ?? 0)
              .toDouble(),

      isRefunded:
          json['isRefunded'] ?? false,

      failureReason:
          json['failureReason']
              ?.toString(),

      notes:
          json['notes']?.toString(),

      paidAt: json['paidAt'] != null
          ? DateTime.tryParse(
              json['paidAt'].toString(),
            )
          : null,

      refundedAt:
          json['refundedAt'] != null
              ? DateTime.tryParse(
                  json['refundedAt']
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
      'transactionId': transactionId,
      'paymentGatewayOrderId':
          paymentGatewayOrderId,
      'paymentGatewayPaymentId':
          paymentGatewayPaymentId,
      'bookingId': bookingId,
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'providerId': providerId,
      'providerName': providerName,
      'amount': amount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentGateway': paymentGateway,
      'paymentStatus': paymentStatus,
      'refundId': refundId,
      'refundedAmount': refundedAmount,
      'isRefunded': isRefunded,
      'failureReason': failureReason,
      'notes': notes,
      'paidAt': paidAt?.toIso8601String(),
      'refundedAt':
          refundedAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? transactionId,
    String? paymentGatewayOrderId,
    String? paymentGatewayPaymentId,
    String? bookingId,
    String? orderId,
    String? customerId,
    String? customerName,
    String? providerId,
    String? providerName,
    double? amount,
    double? taxAmount,
    double? discountAmount,
    double? finalAmount,
    String? currency,
    String? paymentMethod,
    String? paymentGateway,
    String? paymentStatus,
    String? refundId,
    double? refundedAmount,
    bool? isRefunded,
    String? failureReason,
    String? notes,
    DateTime? paidAt,
    DateTime? refundedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      transactionId:
          transactionId ??
              this.transactionId,
      paymentGatewayOrderId:
          paymentGatewayOrderId ??
              this.paymentGatewayOrderId,
      paymentGatewayPaymentId:
          paymentGatewayPaymentId ??
              this.paymentGatewayPaymentId,
      bookingId:
          bookingId ?? this.bookingId,
      orderId: orderId ?? this.orderId,
      customerId:
          customerId ?? this.customerId,
      customerName:
          customerName ??
              this.customerName,
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ??
              this.providerName,
      amount: amount ?? this.amount,
      taxAmount:
          taxAmount ?? this.taxAmount,
      discountAmount:
          discountAmount ??
              this.discountAmount,
      finalAmount:
          finalAmount ?? this.finalAmount,
      currency:
          currency ?? this.currency,
      paymentMethod:
          paymentMethod ??
              this.paymentMethod,
      paymentGateway:
          paymentGateway ??
              this.paymentGateway,
      paymentStatus:
          paymentStatus ??
              this.paymentStatus,
      refundId:
          refundId ?? this.refundId,
      refundedAmount:
          refundedAmount ??
              this.refundedAmount,
      isRefunded:
          isRefunded ?? this.isRefunded,
      failureReason:
          failureReason ??
              this.failureReason,
      notes: notes ?? this.notes,
      paidAt: paidAt ?? this.paidAt,
      refundedAt:
          refundedAt ?? this.refundedAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending =>
      paymentStatus.toLowerCase() ==
      'pending';

  bool get isSuccess =>
      paymentStatus.toLowerCase() ==
      'success';

  bool get isFailed =>
      paymentStatus.toLowerCase() ==
      'failed';

  bool get isPartiallyRefunded =>
      refundedAmount > 0 &&
      refundedAmount < finalAmount;

  bool get isFullyRefunded =>
      refundedAmount >= finalAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PaymentModel('
        'id: $id, '
        'transactionId: $transactionId, '
        'amount: $finalAmount'
        ')';
  }
}