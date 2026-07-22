import 'dart:convert';

class PaymentModel {
  final String id;

  final String userId;

  /// booking | order
  final String paymentFor;

  final String referenceId;

  final String paymentId;
  final String? orderId;

  final double amount;

  /// pending | paid | failed | refunded
  final String paymentStatus;

  /// razorpay | upi | card | wallet | cash
  final String paymentMethod;

  final String? transactionId;
  final String? currency;

  final double refundedAmount;

  final String? failureReason;

  final DateTime? paidAt;
  final DateTime? refundedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.paymentFor,
    required this.referenceId,
    required this.paymentId,
    required this.amount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.orderId,
    this.transactionId,
    this.currency = 'INR',
    this.refundedAmount = 0,
    this.failureReason,
    this.paidAt,
    this.refundedAt,
    this.createdAt,
    this.updatedAt,
  });

  // =====================================
  // EMPTY
  // =====================================

  factory PaymentModel.empty() {
    return const PaymentModel(
      id: '',
      userId: '',
      paymentFor: 'booking',
      referenceId: '',
      paymentId: '',
      amount: 0,
      paymentStatus: 'pending',
      paymentMethod: '',
    );
  }

  // =====================================
  // COPY WITH
  // =====================================

  PaymentModel copyWith({
    String? id,
    String? userId,
    String? paymentFor,
    String? referenceId,
    String? paymentId,
    String? orderId,
    double? amount,
    String? paymentStatus,
    String? paymentMethod,
    String? transactionId,
    String? currency,
    double? refundedAmount,
    String? failureReason,
    DateTime? paidAt,
    DateTime? refundedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      paymentFor: paymentFor ?? this.paymentFor,
      referenceId: referenceId ?? this.referenceId,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      paymentStatus:
          paymentStatus ?? this.paymentStatus,
      paymentMethod:
          paymentMethod ?? this.paymentMethod,
      transactionId:
          transactionId ?? this.transactionId,
      currency: currency ?? this.currency,
      refundedAmount:
          refundedAmount ?? this.refundedAmount,
      failureReason:
          failureReason ?? this.failureReason,
      paidAt: paidAt ?? this.paidAt,
      refundedAt: refundedAt ?? this.refundedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =====================================
  // FROM MAP
  // =====================================

  factory PaymentModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return PaymentModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      userId:
          map['userId']?.toString() ?? '',

      paymentFor:
          map['paymentFor'] ?? 'booking',

      referenceId:
          map['referenceId']?.toString() ?? '',

      paymentId:
          map['paymentId']?.toString() ?? '',

      orderId:
          map['orderId']?.toString(),

      amount:
          (map['amount'] as num?)
                  ?.toDouble() ??
              0,

      paymentStatus:
          map['paymentStatus'] ?? 'pending',

      paymentMethod:
          map['paymentMethod'] ?? '',

      transactionId:
          map['transactionId'],

      currency:
          map['currency'] ?? 'INR',

      refundedAmount:
          (map['refundedAmount'] as num?)
                  ?.toDouble() ??
              0,

      failureReason:
          map['failureReason'],

      paidAt:
          map['paidAt'] != null
              ? DateTime.tryParse(
                  map['paidAt'],
                )
              : null,

      refundedAt:
          map['refundedAt'] != null
              ? DateTime.tryParse(
                  map['refundedAt'],
                )
              : null,

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

  // =====================================
  // TO MAP
  // =====================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'paymentFor': paymentFor,
      'referenceId': referenceId,
      'paymentId': paymentId,
      'orderId': orderId,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'currency': currency,
      'refundedAmount': refundedAmount,
      'failureReason': failureReason,
      'paidAt': paidAt?.toIso8601String(),
      'refundedAt':
          refundedAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // =====================================
  // JSON
  // =====================================

  factory PaymentModel.fromJson(
    String source,
  ) {
    return PaymentModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // =====================================
  // HELPERS
  // =====================================

  bool get isPending =>
      paymentStatus.toLowerCase() ==
      'pending';

  bool get isPaid =>
      paymentStatus.toLowerCase() ==
      'paid';

  bool get isFailed =>
      paymentStatus.toLowerCase() ==
      'failed';

  bool get isRefunded =>
      paymentStatus.toLowerCase() ==
      'refunded';

  bool get isBookingPayment =>
      paymentFor.toLowerCase() ==
      'booking';

  bool get isOrderPayment =>
      paymentFor.toLowerCase() ==
      'order';

  bool get isRazorpay =>
      paymentMethod.toLowerCase() ==
      'razorpay';

  bool get isUpi =>
      paymentMethod.toLowerCase() ==
      'upi';

  bool get isWallet =>
      paymentMethod.toLowerCase() ==
      'wallet';

  bool get isCash =>
      paymentMethod.toLowerCase() ==
      'cash';

  bool get hasRefund =>
      refundedAmount > 0;

  // =====================================
  // OVERRIDES
  // =====================================

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PaymentModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}