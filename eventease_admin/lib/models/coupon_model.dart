class CouponModel {
  final String id;

  final String code;
  final String title;
  final String description;

  final String discountType;

  final double discountValue;
  final double? maximumDiscountAmount;
  final double? minimumOrderAmount;

  final int usageLimit;
  final int usedCount;

  final bool isActive;

  final DateTime startDate;
  final DateTime endDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.maximumDiscountAmount,
    this.minimumOrderAmount,
    required this.usageLimit,
    required this.usedCount,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory CouponModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CouponModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      code:
          json['code']?.toString() ?? '',

      title:
          json['title']?.toString() ?? '',

      description:
          json['description']
                  ?.toString() ??
              '',

      discountType:
          json['discountType']
                  ?.toString() ??
              'percentage',

      discountValue:
          (json['discountValue'] ?? 0)
              .toDouble(),

      maximumDiscountAmount:
          json['maximumDiscountAmount'] !=
                  null
              ? (json[
                      'maximumDiscountAmount']
                  as num)
                  .toDouble()
              : null,

      minimumOrderAmount:
          json['minimumOrderAmount'] !=
                  null
              ? (json[
                      'minimumOrderAmount']
                  as num)
                  .toDouble()
              : null,

      usageLimit:
          json['usageLimit'] ?? 0,

      usedCount:
          json['usedCount'] ?? 0,

      isActive:
          json['isActive'] ?? true,

      startDate:
          DateTime.tryParse(
                json['startDate']
                        ?.toString() ??
                    '',
              ) ??
              DateTime.now(),

      endDate:
          DateTime.tryParse(
                json['endDate']
                        ?.toString() ??
                    '',
              ) ??
              DateTime.now(),

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
      'code': code,
      'title': title,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'maximumDiscountAmount':
          maximumDiscountAmount,
      'minimumOrderAmount':
          minimumOrderAmount,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'isActive': isActive,
      'startDate':
          startDate.toIso8601String(),
      'endDate':
          endDate.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  CouponModel copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    String? discountType,
    double? discountValue,
    double? maximumDiscountAmount,
    double? minimumOrderAmount,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description:
          description ?? this.description,
      discountType:
          discountType ?? this.discountType,
      discountValue:
          discountValue ??
              this.discountValue,
      maximumDiscountAmount:
          maximumDiscountAmount ??
              this.maximumDiscountAmount,
      minimumOrderAmount:
          minimumOrderAmount ??
              this.minimumOrderAmount,
      usageLimit:
          usageLimit ?? this.usageLimit,
      usedCount:
          usedCount ?? this.usedCount,
      isActive:
          isActive ?? this.isActive,
      startDate:
          startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isPercentage =>
      discountType.toLowerCase() ==
      'percentage';

  bool get isFlat =>
      discountType.toLowerCase() ==
          'flat' ||
      discountType.toLowerCase() ==
          'fixed';

  bool get isExpired =>
      DateTime.now().isAfter(endDate);

  bool get isUpcoming =>
      DateTime.now().isBefore(startDate);

  bool get isValid =>
      isActive &&
      !isExpired &&
      !isUpcoming;

  bool get usageLimitReached =>
      usageLimit > 0 &&
      usedCount >= usageLimit;

  int get remainingUsages =>
      usageLimit > usedCount
          ? usageLimit - usedCount
          : 0;

  double get usagePercentage {
    if (usageLimit == 0) return 0;

    return (usedCount / usageLimit) *
        100;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CouponModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CouponModel('
        'id: $id, '
        'code: $code, '
        'discountType: $discountType'
        ')';
  }
}