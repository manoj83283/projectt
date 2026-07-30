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

class PaymentModel {
  final String id;

  final String bookingId;
  final String orderId;

  final String customerId;
  final String providerId;

  final String transactionId;
  final String paymentGateway;

  final PaymentMethod paymentMethod;
  final PaymentStatus status;

  final String currency;

  final double amount;
  final double taxAmount;
  final double discountAmount;
  final double platformFee;
  final double providerAmount;

  final double refundAmount;

  final bool isRefunded;

  final String remarks;

  final DateTime paymentDate;
  final DateTime? refundDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.refundDate,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.empty() {
    return PaymentModel(
      id: '',
      bookingId: '',
      orderId: '',
      customerId: '',
      providerId: '',
      transactionId: '',
      paymentGateway: '',
      paymentMethod: PaymentMethod.upi,
      status: PaymentStatus.pending,
      currency: 'INR',
      amount: 0,
      taxAmount: 0,
      discountAmount: 0,
      platformFee: 0,
      providerAmount: 0,
      refundAmount: 0,
      isRefunded: false,
      remarks: '',
      paymentDate: DateTime.now(),
    );
  }

  factory PaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymentModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      bookingId:
          json['bookingId']?.toString() ??
          '',
      orderId:
          json['orderId']?.toString() ??
          '',
      customerId:
          json['customerId']?.toString() ??
          '',
      providerId:
          json['providerId']?.toString() ??
          '',
      transactionId:
          json['transactionId']?.toString() ??
          '',
      paymentGateway:
          json['paymentGateway']
                  ?.toString() ??
              '',
      paymentMethod:
          _parsePaymentMethod(
        json['paymentMethod'],
      ),
      status:
          _parsePaymentStatus(
        json['status'],
      ),
      currency:
          json['currency']?.toString() ??
              'INR',
      amount:
          (json['amount'] ?? 0)
              .toDouble(),
      taxAmount:
          (json['taxAmount'] ?? 0)
              .toDouble(),
      discountAmount:
          (json['discountAmount'] ?? 0)
              .toDouble(),
      platformFee:
          (json['platformFee'] ?? 0)
              .toDouble(),
      providerAmount:
          (json['providerAmount'] ?? 0)
              .toDouble(),
      refundAmount:
          (json['refundAmount'] ?? 0)
              .toDouble(),
      isRefunded:
          json['isRefunded'] ?? false,
      remarks:
          json['remarks']?.toString() ??
              '',
      paymentDate:
          json['paymentDate'] != null
              ? DateTime.parse(
                  json['paymentDate']
                      .toString(),
                )
              : DateTime.now(),
      refundDate:
          json['refundDate'] != null
              ? DateTime.tryParse(
                  json['refundDate']
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
      'bookingId': bookingId,
      'orderId': orderId,
      'customerId': customerId,
      'providerId': providerId,
      'transactionId': transactionId,
      'paymentGateway': paymentGateway,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'currency': currency,
      'amount': amount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'platformFee': platformFee,
      'providerAmount': providerAmount,
      'refundAmount': refundAmount,
      'isRefunded': isRefunded,
      'remarks': remarks,
      'paymentDate':
          paymentDate.toIso8601String(),
      'refundDate':
          refundDate?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  static PaymentMethod
      _parsePaymentMethod(
    dynamic value,
  ) {
    switch (
        value.toString().toLowerCase()) {
      case 'card':
        return PaymentMethod.card;

      case 'netbanking':
        return PaymentMethod.netBanking;

      case 'wallet':
        return PaymentMethod.wallet;

      case 'cash':
        return PaymentMethod.cash;

      case 'banktransfer':
        return PaymentMethod.bankTransfer;

      default:
        return PaymentMethod.upi;
    }
  }

  static PaymentStatus
      _parsePaymentStatus(
    dynamic value,
  ) {
    switch (
        value.toString().toLowerCase()) {
      case 'processing':
        return PaymentStatus.processing;

      case 'success':
        return PaymentStatus.success;

      case 'failed':
        return PaymentStatus.failed;

      case 'cancelled':
        return PaymentStatus.cancelled;

      case 'refunded':
        return PaymentStatus.refunded;

      case 'partiallyrefunded':
        return PaymentStatus.partiallyRefunded;

      default:
        return PaymentStatus.pending;
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
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

  String get statusText {
    switch (status) {
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

  bool get isSuccessful =>
      status == PaymentStatus.success;

  bool get isPending =>
      status == PaymentStatus.pending;

  bool get isFailed =>
      status == PaymentStatus.failed;

  bool get isCancelled =>
      status == PaymentStatus.cancelled;

  bool get isFullyRefunded =>
      status == PaymentStatus.refunded;

  bool get isPartiallyRefunded =>
      status ==
      PaymentStatus.partiallyRefunded;

  double get netRevenue =>
      amount -
      taxAmount -
      discountAmount -
      platformFee;

  PaymentModel copyWith({
    String? id,
    String? bookingId,
    String? orderId,
    String? customerId,
    String? providerId,
    String? transactionId,
    String? paymentGateway,
    PaymentMethod? paymentMethod,
    PaymentStatus? status,
    String? currency,
    double? amount,
    double? taxAmount,
    double? discountAmount,
    double? platformFee,
    double? providerAmount,
    double? refundAmount,
    bool? isRefunded,
    String? remarks,
    DateTime? paymentDate,
    DateTime? refundDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      bookingId:
          bookingId ?? this.bookingId,
      orderId: orderId ?? this.orderId,
      customerId:
          customerId ?? this.customerId,
      providerId:
          providerId ?? this.providerId,
      transactionId:
          transactionId ??
              this.transactionId,
      paymentGateway:
          paymentGateway ??
              this.paymentGateway,
      paymentMethod:
          paymentMethod ??
              this.paymentMethod,
      status: status ?? this.status,
      currency:
          currency ?? this.currency,
      amount: amount ?? this.amount,
      taxAmount:
          taxAmount ?? this.taxAmount,
      discountAmount:
          discountAmount ??
              this.discountAmount,
      platformFee:
          platformFee ??
              this.platformFee,
      providerAmount:
          providerAmount ??
              this.providerAmount,
      refundAmount:
          refundAmount ??
              this.refundAmount,
      isRefunded:
          isRefunded ?? this.isRefunded,
      remarks: remarks ?? this.remarks,
      paymentDate:
          paymentDate ?? this.paymentDate,
      refundDate:
          refundDate ?? this.refundDate,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

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
        'amount: $amount, '
        'status: ${status.name}'
        ')';
  }
}