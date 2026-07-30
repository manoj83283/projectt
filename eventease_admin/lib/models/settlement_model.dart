class SettlementModel {
  final String id;

  final String settlementNumber;

  final String providerId;
  final String providerName;

  final String? bookingId;
  final String? orderId;

  final double grossAmount;
  final double platformCommission;
  final double gstAmount;
  final double tdsAmount;

  final double netAmount;

  final String status;

  final String paymentMethod;
  final String? transactionId;

  final String bankAccountNumber;
  final String bankName;
  final String accountHolderName;
  final String ifscCode;

  final String? remarks;
  final String? rejectionReason;

  final DateTime settlementPeriodStart;
  final DateTime settlementPeriodEnd;

  final DateTime? paidAt;
  final DateTime? approvedAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SettlementModel({
    required this.id,
    required this.settlementNumber,
    required this.providerId,
    required this.providerName,
    this.bookingId,
    this.orderId,
    required this.grossAmount,
    required this.platformCommission,
    required this.gstAmount,
    required this.tdsAmount,
    required this.netAmount,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.bankAccountNumber,
    required this.bankName,
    required this.accountHolderName,
    required this.ifscCode,
    this.remarks,
    this.rejectionReason,
    required this.settlementPeriodStart,
    required this.settlementPeriodEnd,
    this.paidAt,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SettlementModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SettlementModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      settlementNumber:
          json['settlementNumber']
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

      bookingId:
          json['bookingId']?.toString(),

      orderId:
          json['orderId']?.toString(),

      grossAmount:
          (json['grossAmount'] ?? 0)
              .toDouble(),

      platformCommission:
          (json['platformCommission'] ??
                  0)
              .toDouble(),

      gstAmount:
          (json['gstAmount'] ?? 0)
              .toDouble(),

      tdsAmount:
          (json['tdsAmount'] ?? 0)
              .toDouble(),

      netAmount:
          (json['netAmount'] ?? 0)
              .toDouble(),

      status:
          json['status']
                  ?.toString() ??
              'pending',

      paymentMethod:
          json['paymentMethod']
                  ?.toString() ??
              'bank_transfer',

      transactionId:
          json['transactionId']
              ?.toString(),

      bankAccountNumber:
          json['bankAccountNumber']
                  ?.toString() ??
              '',

      bankName:
          json['bankName']
                  ?.toString() ??
              '',

      accountHolderName:
          json['accountHolderName']
                  ?.toString() ??
              '',

      ifscCode:
          json['ifscCode']
                  ?.toString() ??
              '',

      remarks:
          json['remarks']?.toString(),

      rejectionReason:
          json['rejectionReason']
              ?.toString(),

      settlementPeriodStart:
          DateTime.tryParse(
                json[
                        'settlementPeriodStart']
                    ?.toString() ??
                    '',
              ) ??
              DateTime.now(),

      settlementPeriodEnd:
          DateTime.tryParse(
                json[
                        'settlementPeriodEnd']
                    ?.toString() ??
                    '',
              ) ??
              DateTime.now(),

      paidAt:
          json['paidAt'] != null
              ? DateTime.tryParse(
                  json['paidAt']
                      .toString(),
                )
              : null,

      approvedAt:
          json['approvedAt'] != null
              ? DateTime.tryParse(
                  json['approvedAt']
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
      'settlementNumber':
          settlementNumber,
      'providerId': providerId,
      'providerName': providerName,
      'bookingId': bookingId,
      'orderId': orderId,
      'grossAmount': grossAmount,
      'platformCommission':
          platformCommission,
      'gstAmount': gstAmount,
      'tdsAmount': tdsAmount,
      'netAmount': netAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'bankAccountNumber':
          bankAccountNumber,
      'bankName': bankName,
      'accountHolderName':
          accountHolderName,
      'ifscCode': ifscCode,
      'remarks': remarks,
      'rejectionReason':
          rejectionReason,
      'settlementPeriodStart':
          settlementPeriodStart
              .toIso8601String(),
      'settlementPeriodEnd':
          settlementPeriodEnd
              .toIso8601String(),
      'paidAt':
          paidAt?.toIso8601String(),
      'approvedAt':
          approvedAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  SettlementModel copyWith({
    String? id,
    String? settlementNumber,
    String? providerId,
    String? providerName,
    String? bookingId,
    String? orderId,
    double? grossAmount,
    double? platformCommission,
    double? gstAmount,
    double? tdsAmount,
    double? netAmount,
    String? status,
    String? paymentMethod,
    String? transactionId,
    String? bankAccountNumber,
    String? bankName,
    String? accountHolderName,
    String? ifscCode,
    String? remarks,
    String? rejectionReason,
    DateTime? settlementPeriodStart,
    DateTime? settlementPeriodEnd,
    DateTime? paidAt,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettlementModel(
      id: id ?? this.id,
      settlementNumber:
          settlementNumber ??
              this.settlementNumber,
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ??
              this.providerName,
      bookingId:
          bookingId ?? this.bookingId,
      orderId: orderId ?? this.orderId,
      grossAmount:
          grossAmount ?? this.grossAmount,
      platformCommission:
          platformCommission ??
              this.platformCommission,
      gstAmount:
          gstAmount ?? this.gstAmount,
      tdsAmount:
          tdsAmount ?? this.tdsAmount,
      netAmount:
          netAmount ?? this.netAmount,
      status: status ?? this.status,
      paymentMethod:
          paymentMethod ??
              this.paymentMethod,
      transactionId:
          transactionId ??
              this.transactionId,
      bankAccountNumber:
          bankAccountNumber ??
              this.bankAccountNumber,
      bankName:
          bankName ?? this.bankName,
      accountHolderName:
          accountHolderName ??
              this.accountHolderName,
      ifscCode:
          ifscCode ?? this.ifscCode,
      remarks: remarks ?? this.remarks,
      rejectionReason:
          rejectionReason ??
              this.rejectionReason,
      settlementPeriodStart:
          settlementPeriodStart ??
              this.settlementPeriodStart,
      settlementPeriodEnd:
          settlementPeriodEnd ??
              this.settlementPeriodEnd,
      paidAt: paidAt ?? this.paidAt,
      approvedAt:
          approvedAt ?? this.approvedAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending =>
      status.toLowerCase() ==
      'pending';

  bool get isApproved =>
      status.toLowerCase() ==
      'approved';

  bool get isPaid =>
      status.toLowerCase() == 'paid';

  bool get isRejected =>
      status.toLowerCase() ==
      'rejected';

  double get totalDeductions =>
      platformCommission +
      gstAmount +
      tdsAmount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SettlementModel('
        'id: $id, '
        'settlementNumber: $settlementNumber, '
        'netAmount: $netAmount'
        ')';
  }
}