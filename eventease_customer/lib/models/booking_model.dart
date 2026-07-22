import 'dart:convert';

class BookingModel {
  final String id;

  final String customerId;
  final String customerName;

  final String providerId;
  final String providerName;

  final String serviceId;
  final String serviceName;

  final String bookingNumber;

  final DateTime bookingDate;
  final String bookingTime;

  final double amount;
  final double gst;
  final double serviceFee;
  final double discount;
  final double totalAmount;

  final String bookingStatus;
  final String paymentStatus;

  final String? paymentId;

  final String? notes;

  final String? address;
  final double? latitude;
  final double? longitude;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.bookingNumber,
    required this.bookingDate,
    required this.bookingTime,
    required this.amount,
    required this.totalAmount,
    this.gst = 0,
    this.serviceFee = 0,
    this.discount = 0,
    this.bookingStatus = 'pending',
    this.paymentStatus = 'pending',
    this.paymentId,
    this.notes,
    this.address,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  // =========================================
  // EMPTY
  // =========================================

  factory BookingModel.empty() {
    return BookingModel(
      id: '',
      customerId: '',
      customerName: '',
      providerId: '',
      providerName: '',
      serviceId: '',
      serviceName: '',
      bookingNumber: '',
      bookingDate: DateTime.now(),
      bookingTime: '',
      amount: 0,
      totalAmount: 0,
    );
  }

  // =========================================
  // COPY WITH
  // =========================================

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? providerId,
    String? providerName,
    String? serviceId,
    String? serviceName,
    String? bookingNumber,
    DateTime? bookingDate,
    String? bookingTime,
    double? amount,
    double? gst,
    double? serviceFee,
    double? discount,
    double? totalAmount,
    String? bookingStatus,
    String? paymentStatus,
    String? paymentId,
    String? notes,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      amount: amount ?? this.amount,
      gst: gst ?? this.gst,
      serviceFee: serviceFee ?? this.serviceFee,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      notes: notes ?? this.notes,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =========================================
  // FROM MAP
  // =========================================

  factory BookingModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return BookingModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      customerId:
          map['customerId']?.toString() ?? '',

      customerName:
          map['customerName'] ?? '',

      providerId:
          map['providerId']?.toString() ?? '',

      providerName:
          map['providerName'] ?? '',

      serviceId:
          map['serviceId']?.toString() ?? '',

      serviceName:
          map['serviceName'] ?? '',

      bookingNumber:
          map['bookingNumber'] ?? '',

      bookingDate:
          map['bookingDate'] != null
              ? DateTime.parse(
                  map['bookingDate'],
                )
              : DateTime.now(),

      bookingTime:
          map['bookingTime'] ?? '',

      amount:
          (map['amount'] as num?)
                  ?.toDouble() ??
              0,

      gst:
          (map['gst'] as num?)
                  ?.toDouble() ??
              0,

      serviceFee:
          (map['serviceFee'] as num?)
                  ?.toDouble() ??
              0,

      discount:
          (map['discount'] as num?)
                  ?.toDouble() ??
              0,

      totalAmount:
          (map['totalAmount'] as num?)
                  ?.toDouble() ??
              0,

      bookingStatus:
          map['bookingStatus'] ??
              'pending',

      paymentStatus:
          map['paymentStatus'] ??
              'pending',

      paymentId:
          map['paymentId'],

      notes:
          map['notes'],

      address:
          map['address'],

      latitude:
          (map['latitude'] as num?)
              ?.toDouble(),

      longitude:
          (map['longitude'] as num?)
              ?.toDouble(),

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

  // =========================================
  // TO MAP
  // =========================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'customerId': customerId,
      'customerName': customerName,
      'providerId': providerId,
      'providerName': providerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'bookingNumber': bookingNumber,
      'bookingDate':
          bookingDate.toIso8601String(),
      'bookingTime': bookingTime,
      'amount': amount,
      'gst': gst,
      'serviceFee': serviceFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'bookingStatus': bookingStatus,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'notes': notes,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // =========================================
  // JSON
  // =========================================

  factory BookingModel.fromJson(
    String source,
  ) {
    return BookingModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // =========================================
  // STATUS HELPERS
  // =========================================

  bool get isPending =>
      bookingStatus.toLowerCase() ==
      'pending';

  bool get isAccepted =>
      bookingStatus.toLowerCase() ==
      'accepted';

  bool get isConfirmed =>
      bookingStatus.toLowerCase() ==
      'confirmed';

  bool get isCompleted =>
      bookingStatus.toLowerCase() ==
      'completed';

  bool get isCancelled =>
      bookingStatus.toLowerCase() ==
      'cancelled';

  bool get isPaid =>
      paymentStatus.toLowerCase() ==
      'paid';

  bool get hasLocation =>
      latitude != null &&
      longitude != null;

  // =========================================
  // OVERRIDES
  // =========================================

  @override
  String toString() {
    return 'BookingModel(id: $id, bookingNumber: $bookingNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}