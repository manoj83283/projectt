import 'dart:convert';

class CouponModel {
  final String id;

  final String code;
  final String title;
  final String? description;

  /// percentage | flat
  final String discountType;

  final double discountValue;
  final double minimumOrderAmount;
  final double maximumDiscountAmount;

  final int usageLimit;
  final int usedCount;

  final bool isActive;

  final DateTime? startDate;
  final DateTime? expiryDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    this.description,
    this.minimumOrderAmount = 0,
    this.maximumDiscountAmount = 0,
    this.usageLimit = 0,
    this.usedCount = 0,
    this.isActive = true,
    this.startDate,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
  });

  // =====================================================
  // EMPTY
  // =====================================================

  factory CouponModel.empty() {
    return const CouponModel(
      id: '',
      code: '',
      title: '',
      discountType: 'percentage',
      discountValue: 0,
    );
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  CouponModel copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? discountType,
    double? discountValue,
    double? minimumOrderAmount,
    double? maximumDiscountAmount,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
    DateTime? startDate,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minimumOrderAmount:
          minimumOrderAmount ?? this.minimumOrderAmount,
      maximumDiscountAmount:
          maximumDiscountAmount ??
              this.maximumDiscountAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =====================================================
  // FROM MAP
  // =====================================================

  factory CouponModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return CouponModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      code: map['code'] ?? '',

      title: map['title'] ?? '',

      description: map['description'],

      discountType:
          map['discountType'] ?? 'percentage',

      discountValue:
          (map['discountValue'] as num?)
                  ?.toDouble() ??
              0,

      minimumOrderAmount:
          (map['minimumOrderAmount'] as num?)
                  ?.toDouble() ??
              0,

      maximumDiscountAmount:
          (map['maximumDiscountAmount'] as num?)
                  ?.toDouble() ??
              0,

      usageLimit:
          map['usageLimit'] ?? 0,

      usedCount:
          map['usedCount'] ?? 0,

      isActive:
          map['isActive'] ?? true,

      startDate:
          map['startDate'] != null
              ? DateTime.tryParse(
                  map['startDate'],
                )
              : null,

      expiryDate:
          map['expiryDate'] != null
              ? DateTime.tryParse(
                  map['expiryDate'],
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

  // =====================================================
  // TO MAP
  // =====================================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'code': code,
      'title': title,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minimumOrderAmount': minimumOrderAmount,
      'maximumDiscountAmount': maximumDiscountAmount,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'isActive': isActive,
      'startDate':
          startDate?.toIso8601String(),
      'expiryDate':
          expiryDate?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // =====================================================
  // JSON
  // =====================================================

  factory CouponModel.fromJson(
    String source,
  ) {
    return CouponModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // =====================================================
  // HELPERS
  // =====================================================

  bool get isPercentageCoupon =>
      discountType.toLowerCase() ==
      'percentage';

  bool get isFlatCoupon =>
      discountType.toLowerCase() ==
      'flat';

  bool get isExpired {
    if (expiryDate == null) {
      return false;
    }

    return DateTime.now()
        .isAfter(expiryDate!);
  }

  bool get isUsageLimitReached {
    if (usageLimit == 0) {
      return false;
    }

    return usedCount >= usageLimit;
  }

  bool get isValid {
    return isActive &&
        !isExpired &&
        !isUsageLimitReached;
  }

  double calculateDiscount(
    double orderAmount,
  ) {
    if (!isValid) {
      return 0;
    }

    if (orderAmount <
        minimumOrderAmount) {
      return 0;
    }

    double discount;

    if (isPercentageCoupon) {
      discount =
          (orderAmount * discountValue) /
              100;

      if (maximumDiscountAmount > 0) {
        discount = discount >
                maximumDiscountAmount
            ? maximumDiscountAmount
            : discount;
      }
    } else {
      discount = discountValue;
    }

    return discount;
  }

  // =====================================================
  // OVERRIDES
  // =====================================================

  @override
  String toString() {
    return 'CouponModel(code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CouponModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}