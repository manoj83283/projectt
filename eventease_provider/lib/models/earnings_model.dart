class EarningsModel {
  final String id;

  final String providerId;
  final String providerName;

  final double grossEarnings;
  final double netEarnings;

  final double platformCommission;
  final double gstAmount;

  final double pendingAmount;
  final double settledAmount;
  final double availableBalance;

  final int totalBookings;
  final int completedBookings;
  final int cancelledBookings;

  final DateTime periodStart;
  final DateTime periodEnd;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EarningsModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.grossEarnings,
    required this.netEarnings,
    required this.platformCommission,
    required this.gstAmount,
    required this.pendingAmount,
    required this.settledAmount,
    required this.availableBalance,
    required this.totalBookings,
    required this.completedBookings,
    required this.cancelledBookings,
    required this.periodStart,
    required this.periodEnd,
    this.createdAt,
    this.updatedAt,
  });

  factory EarningsModel.empty() {
    return EarningsModel(
      id: '',
      providerId: '',
      providerName: '',
      grossEarnings: 0,
      netEarnings: 0,
      platformCommission: 0,
      gstAmount: 0,
      pendingAmount: 0,
      settledAmount: 0,
      availableBalance: 0,
      totalBookings: 0,
      completedBookings: 0,
      cancelledBookings: 0,
      periodStart: DateTime.now(),
      periodEnd: DateTime.now(),
    );
  }

  factory EarningsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EarningsModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      providerId:
          json['providerId']?.toString() ??
              '',
      providerName:
          json['providerName']?.toString() ??
              '',
      grossEarnings:
          (json['grossEarnings'] ?? 0)
              .toDouble(),
      netEarnings:
          (json['netEarnings'] ?? 0)
              .toDouble(),
      platformCommission:
          (json['platformCommission'] ??
                  0)
              .toDouble(),
      gstAmount:
          (json['gstAmount'] ?? 0)
              .toDouble(),
      pendingAmount:
          (json['pendingAmount'] ?? 0)
              .toDouble(),
      settledAmount:
          (json['settledAmount'] ?? 0)
              .toDouble(),
      availableBalance:
          (json['availableBalance'] ?? 0)
              .toDouble(),
      totalBookings:
          json['totalBookings'] ?? 0,
      completedBookings:
          json['completedBookings'] ?? 0,
      cancelledBookings:
          json['cancelledBookings'] ?? 0,
      periodStart:
          json['periodStart'] != null
              ? DateTime.parse(
                  json['periodStart']
                      .toString(),
                )
              : DateTime.now(),
      periodEnd:
          json['periodEnd'] != null
              ? DateTime.parse(
                  json['periodEnd']
                      .toString(),
                )
              : DateTime.now(),
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
      'providerId': providerId,
      'providerName': providerName,
      'grossEarnings': grossEarnings,
      'netEarnings': netEarnings,
      'platformCommission':
          platformCommission,
      'gstAmount': gstAmount,
      'pendingAmount':
          pendingAmount,
      'settledAmount':
          settledAmount,
      'availableBalance':
          availableBalance,
      'totalBookings':
          totalBookings,
      'completedBookings':
          completedBookings,
      'cancelledBookings':
          cancelledBookings,
      'periodStart':
          periodStart.toIso8601String(),
      'periodEnd':
          periodEnd.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  EarningsModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    double? grossEarnings,
    double? netEarnings,
    double? platformCommission,
    double? gstAmount,
    double? pendingAmount,
    double? settledAmount,
    double? availableBalance,
    int? totalBookings,
    int? completedBookings,
    int? cancelledBookings,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EarningsModel(
      id: id ?? this.id,
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ??
              this.providerName,
      grossEarnings:
          grossEarnings ??
              this.grossEarnings,
      netEarnings:
          netEarnings ??
              this.netEarnings,
      platformCommission:
          platformCommission ??
              this.platformCommission,
      gstAmount:
          gstAmount ?? this.gstAmount,
      pendingAmount:
          pendingAmount ??
              this.pendingAmount,
      settledAmount:
          settledAmount ??
              this.settledAmount,
      availableBalance:
          availableBalance ??
              this.availableBalance,
      totalBookings:
          totalBookings ??
              this.totalBookings,
      completedBookings:
          completedBookings ??
              this.completedBookings,
      cancelledBookings:
          cancelledBookings ??
              this.cancelledBookings,
      periodStart:
          periodStart ??
              this.periodStart,
      periodEnd:
          periodEnd ?? this.periodEnd,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  double get completionRate {
    if (totalBookings == 0) {
      return 0;
    }

    return (completedBookings /
            totalBookings) *
        100;
  }

  double get cancellationRate {
    if (totalBookings == 0) {
      return 0;
    }

    return (cancelledBookings /
            totalBookings) *
        100;
  }

  bool get hasPendingSettlement =>
      pendingAmount > 0;

  @override
  String toString() {
    return 'EarningsModel('
        'id: $id, '
        'netEarnings: $netEarnings'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EarningsModel &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}