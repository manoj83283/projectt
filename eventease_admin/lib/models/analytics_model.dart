class AnalyticsModel {
  final int totalCustomers;
  final int totalProviders;
  final int totalServices;
  final int totalBookings;
  final int totalOrders;

  final double totalRevenue;
  final double totalCommission;
  final double totalSettlements;

  final double averageOrderValue;
  final double averageBookingValue;

  final int todayBookings;
  final int todayOrders;
  final double todayRevenue;

  final int monthlyBookings;
  final int monthlyOrders;
  final double monthlyRevenue;

  final double customerGrowthRate;
  final double providerGrowthRate;
  final double revenueGrowthRate;

  final List<AnalyticsChartPoint> revenueChart;
  final List<AnalyticsChartPoint> bookingChart;
  final List<AnalyticsChartPoint> orderChart;

  final List<TopPerformerModel> topProviders;
  final List<TopPerformerModel> topServices;
  final List<TopPerformerModel> topCategories;

  final DateTime? generatedAt;

  const AnalyticsModel({
    required this.totalCustomers,
    required this.totalProviders,
    required this.totalServices,
    required this.totalBookings,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCommission,
    required this.totalSettlements,
    required this.averageOrderValue,
    required this.averageBookingValue,
    required this.todayBookings,
    required this.todayOrders,
    required this.todayRevenue,
    required this.monthlyBookings,
    required this.monthlyOrders,
    required this.monthlyRevenue,
    required this.customerGrowthRate,
    required this.providerGrowthRate,
    required this.revenueGrowthRate,
    required this.revenueChart,
    required this.bookingChart,
    required this.orderChart,
    required this.topProviders,
    required this.topServices,
    required this.topCategories,
    this.generatedAt,
  });

  factory AnalyticsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AnalyticsModel(
      totalCustomers:
          json['totalCustomers'] ?? 0,

      totalProviders:
          json['totalProviders'] ?? 0,

      totalServices:
          json['totalServices'] ?? 0,

      totalBookings:
          json['totalBookings'] ?? 0,

      totalOrders:
          json['totalOrders'] ?? 0,

      totalRevenue:
          (json['totalRevenue'] ?? 0)
              .toDouble(),

      totalCommission:
          (json['totalCommission'] ?? 0)
              .toDouble(),

      totalSettlements:
          (json['totalSettlements'] ?? 0)
              .toDouble(),

      averageOrderValue:
          (json['averageOrderValue'] ?? 0)
              .toDouble(),

      averageBookingValue:
          (json['averageBookingValue'] ?? 0)
              .toDouble(),

      todayBookings:
          json['todayBookings'] ?? 0,

      todayOrders:
          json['todayOrders'] ?? 0,

      todayRevenue:
          (json['todayRevenue'] ?? 0)
              .toDouble(),

      monthlyBookings:
          json['monthlyBookings'] ?? 0,

      monthlyOrders:
          json['monthlyOrders'] ?? 0,

      monthlyRevenue:
          (json['monthlyRevenue'] ?? 0)
              .toDouble(),

      customerGrowthRate:
          (json['customerGrowthRate'] ?? 0)
              .toDouble(),

      providerGrowthRate:
          (json['providerGrowthRate'] ?? 0)
              .toDouble(),

      revenueGrowthRate:
          (json['revenueGrowthRate'] ?? 0)
              .toDouble(),

      revenueChart:
          (json['revenueChart'] as List?)
                  ?.map(
                    (e) =>
                        AnalyticsChartPoint
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      bookingChart:
          (json['bookingChart'] as List?)
                  ?.map(
                    (e) =>
                        AnalyticsChartPoint
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      orderChart:
          (json['orderChart'] as List?)
                  ?.map(
                    (e) =>
                        AnalyticsChartPoint
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      topProviders:
          (json['topProviders'] as List?)
                  ?.map(
                    (e) =>
                        TopPerformerModel
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      topServices:
          (json['topServices'] as List?)
                  ?.map(
                    (e) =>
                        TopPerformerModel
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      topCategories:
          (json['topCategories'] as List?)
                  ?.map(
                    (e) =>
                        TopPerformerModel
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      generatedAt:
          json['generatedAt'] != null
              ? DateTime.tryParse(
                  json['generatedAt']
                      .toString(),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers':
          totalCustomers,
      'totalProviders':
          totalProviders,
      'totalServices':
          totalServices,
      'totalBookings':
          totalBookings,
      'totalOrders':
          totalOrders,
      'totalRevenue':
          totalRevenue,
      'totalCommission':
          totalCommission,
      'totalSettlements':
          totalSettlements,
      'averageOrderValue':
          averageOrderValue,
      'averageBookingValue':
          averageBookingValue,
      'todayBookings':
          todayBookings,
      'todayOrders':
          todayOrders,
      'todayRevenue':
          todayRevenue,
      'monthlyBookings':
          monthlyBookings,
      'monthlyOrders':
          monthlyOrders,
      'monthlyRevenue':
          monthlyRevenue,
      'customerGrowthRate':
          customerGrowthRate,
      'providerGrowthRate':
          providerGrowthRate,
      'revenueGrowthRate':
          revenueGrowthRate,
      'revenueChart':
          revenueChart
              .map((e) => e.toJson())
              .toList(),
      'bookingChart':
          bookingChart
              .map((e) => e.toJson())
              .toList(),
      'orderChart':
          orderChart
              .map((e) => e.toJson())
              .toList(),
      'topProviders':
          topProviders
              .map((e) => e.toJson())
              .toList(),
      'topServices':
          topServices
              .map((e) => e.toJson())
              .toList(),
      'topCategories':
          topCategories
              .map((e) => e.toJson())
              .toList(),
      'generatedAt':
          generatedAt?.toIso8601String(),
    };
  }

  bool get hasRevenue =>
      totalRevenue > 0;

  bool get hasGrowth =>
      revenueGrowthRate > 0;

  bool get isGrowing =>
      revenueGrowthRate > 0 ||
      customerGrowthRate > 0 ||
      providerGrowthRate > 0;
}

class AnalyticsChartPoint {
  final String label;
  final double value;

  const AnalyticsChartPoint({
    required this.label,
    required this.value,
  });

  factory AnalyticsChartPoint.fromJson(
    Map<String, dynamic> json,
  ) {
    return AnalyticsChartPoint(
      label:
          json['label']?.toString() ?? '',
      value:
          (json['value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class TopPerformerModel {
  final String id;
  final String name;
  final double value;

  const TopPerformerModel({
    required this.id,
    required this.name,
    required this.value,
  });

  factory TopPerformerModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TopPerformerModel(
      id: json['id']?.toString() ?? '',
      name:
          json['name']?.toString() ?? '',
      value:
          (json['value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }
}