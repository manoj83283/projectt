class DashboardModel {
  final DashboardSummary summary;

  final List<DashboardRevenuePoint> revenueChart;
  final List<DashboardRevenuePoint> bookingChart;

  final List<DashboardTopProvider> topProviders;
  final List<DashboardTopService> topServices;

  final List<RecentBookingModel> recentBookings;
  final List<RecentOrderModel> recentOrders;

  final DateTime? generatedAt;

  const DashboardModel({
    required this.summary,
    required this.revenueChart,
    required this.bookingChart,
    required this.topProviders,
    required this.topServices,
    required this.recentBookings,
    required this.recentOrders,
    this.generatedAt,
  });

  factory DashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardModel(
      summary: DashboardSummary.fromJson(
        json['summary'] ?? {},
      ),

      revenueChart:
          (json['revenueChart'] as List?)
                  ?.map(
                    (e) =>
                        DashboardRevenuePoint
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      bookingChart:
          (json['bookingChart'] as List?)
                  ?.map(
                    (e) =>
                        DashboardRevenuePoint
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      topProviders:
          (json['topProviders'] as List?)
                  ?.map(
                    (e) =>
                        DashboardTopProvider
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      topServices:
          (json['topServices'] as List?)
                  ?.map(
                    (e) =>
                        DashboardTopService
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      recentBookings:
          (json['recentBookings']
                      as List?)
                  ?.map(
                    (e) =>
                        RecentBookingModel
                            .fromJson(e),
                  )
                  .toList() ??
              [],

      recentOrders:
          (json['recentOrders']
                      as List?)
                  ?.map(
                    (e) =>
                        RecentOrderModel
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
      'summary': summary.toJson(),
      'revenueChart': revenueChart
          .map((e) => e.toJson())
          .toList(),
      'bookingChart': bookingChart
          .map((e) => e.toJson())
          .toList(),
      'topProviders': topProviders
          .map((e) => e.toJson())
          .toList(),
      'topServices': topServices
          .map((e) => e.toJson())
          .toList(),
      'recentBookings': recentBookings
          .map((e) => e.toJson())
          .toList(),
      'recentOrders': recentOrders
          .map((e) => e.toJson())
          .toList(),
      'generatedAt':
          generatedAt?.toIso8601String(),
    };
  }
}

class DashboardSummary {
  final int totalCustomers;
  final int totalProviders;
  final int totalServices;

  final int totalBookings;
  final int totalOrders;

  final int pendingBookings;
  final int pendingKyc;

  final double totalRevenue;
  final double totalCommission;

  final double monthlyRevenue;
  final double todayRevenue;

  final int activeProviders;
  final int activeCustomers;

  const DashboardSummary({
    required this.totalCustomers,
    required this.totalProviders,
    required this.totalServices,
    required this.totalBookings,
    required this.totalOrders,
    required this.pendingBookings,
    required this.pendingKyc,
    required this.totalRevenue,
    required this.totalCommission,
    required this.monthlyRevenue,
    required this.todayRevenue,
    required this.activeProviders,
    required this.activeCustomers,
  });

  factory DashboardSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardSummary(
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
      pendingBookings:
          json['pendingBookings'] ?? 0,
      pendingKyc:
          json['pendingKyc'] ?? 0,
      totalRevenue:
          (json['totalRevenue'] ?? 0)
              .toDouble(),
      totalCommission:
          (json['totalCommission'] ?? 0)
              .toDouble(),
      monthlyRevenue:
          (json['monthlyRevenue'] ?? 0)
              .toDouble(),
      todayRevenue:
          (json['todayRevenue'] ?? 0)
              .toDouble(),
      activeProviders:
          json['activeProviders'] ?? 0,
      activeCustomers:
          json['activeCustomers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers': totalCustomers,
      'totalProviders': totalProviders,
      'totalServices': totalServices,
      'totalBookings': totalBookings,
      'totalOrders': totalOrders,
      'pendingBookings':
          pendingBookings,
      'pendingKyc': pendingKyc,
      'totalRevenue': totalRevenue,
      'totalCommission':
          totalCommission,
      'monthlyRevenue':
          monthlyRevenue,
      'todayRevenue': todayRevenue,
      'activeProviders':
          activeProviders,
      'activeCustomers':
          activeCustomers,
    };
  }
}

class DashboardRevenuePoint {
  final String label;
  final double value;

  const DashboardRevenuePoint({
    required this.label,
    required this.value,
  });

  factory DashboardRevenuePoint.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardRevenuePoint(
      label:
          json['label']?.toString() ?? '',
      value:
          (json['value'] ?? 0)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }
}

class DashboardTopProvider {
  final String id;
  final String name;

  final double rating;
  final int bookings;

  final double earnings;

  const DashboardTopProvider({
    required this.id,
    required this.name,
    required this.rating,
    required this.bookings,
    required this.earnings,
  });

  factory DashboardTopProvider.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardTopProvider(
      id:
          json['id']?.toString() ?? '',
      name:
          json['name']?.toString() ?? '',
      rating:
          (json['rating'] ?? 0)
              .toDouble(),
      bookings:
          json['bookings'] ?? 0,
      earnings:
          (json['earnings'] ?? 0)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'bookings': bookings,
      'earnings': earnings,
    };
  }
}

class DashboardTopService {
  final String id;
  final String name;

  final int bookings;

  final double revenue;

  const DashboardTopService({
    required this.id,
    required this.name,
    required this.bookings,
    required this.revenue,
  });

  factory DashboardTopService.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardTopService(
      id:
          json['id']?.toString() ?? '',
      name:
          json['name']?.toString() ?? '',
      bookings:
          json['bookings'] ?? 0,
      revenue:
          (json['revenue'] ?? 0)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bookings': bookings,
      'revenue': revenue,
    };
  }
}

class RecentBookingModel {
  final String bookingId;
  final String bookingNumber;

  final String customerName;
  final String serviceName;

  final double amount;
  final String status;

  const RecentBookingModel({
    required this.bookingId,
    required this.bookingNumber,
    required this.customerName,
    required this.serviceName,
    required this.amount,
    required this.status,
  });

  factory RecentBookingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecentBookingModel(
      bookingId:
          json['bookingId']
                  ?.toString() ??
              '',
      bookingNumber:
          json['bookingNumber']
                  ?.toString() ??
              '',
      customerName:
          json['customerName']
                  ?.toString() ??
              '',
      serviceName:
          json['serviceName']
                  ?.toString() ??
              '',
      amount:
          (json['amount'] ?? 0)
              .toDouble(),
      status:
          json['status']
                  ?.toString() ??
              'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'bookingNumber': bookingNumber,
      'customerName': customerName,
      'serviceName': serviceName,
      'amount': amount,
      'status': status,
    };
  }
}

class RecentOrderModel {
  final String orderId;
  final String orderNumber;

  final String customerName;

  final double amount;
  final String status;

  const RecentOrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.amount,
    required this.status,
  });

  factory RecentOrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecentOrderModel(
      orderId:
          json['orderId']
                  ?.toString() ??
              '',
      orderNumber:
          json['orderNumber']
                  ?.toString() ??
              '',
      customerName:
          json['customerName']
                  ?.toString() ??
              '',
      amount:
          (json['amount'] ?? 0)
              .toDouble(),
      status:
          json['status']
                  ?.toString() ??
              'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'customerName': customerName,
      'amount': amount,
      'status': status,
    };
  }
}