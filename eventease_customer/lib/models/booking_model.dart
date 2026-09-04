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

  final String? chatRoomId;

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
    this.chatRoomId,
    this.createdAt,
    this.updatedAt,
  });

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

  static String _extractId(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value;
    }

    if (value is Map) {
      return value['_id']?.toString() ??
          value['id']?.toString() ??
          '';
    }

    return '';
  }

  static String _extractName(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value;
    }

    if (value is Map) {
      return value['name']?.toString() ??
          value['firstName']?.toString() ??
          value['businessName']?.toString() ??
          '';
    }

    return '';
  }

  static double _asDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  factory BookingModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final customer =
        map['customer'] ??
            map['user'];

    final provider =
        map['provider'];

    final service =
        map['service'];

    return BookingModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      customerId:
          map['customerId']?.toString() ??
              _extractId(customer),

      customerName:
          map['customerName']?.toString() ??
              _extractName(customer),

      providerId:
          map['providerId']?.toString() ??
              _extractId(provider),

      providerName:
          map['providerName']?.toString() ??
              _extractName(provider),

      serviceId:
          map['serviceId']?.toString() ??
              _extractId(service),

      serviceName:
          map['serviceName']?.toString() ??
              _extractName(service),

      bookingNumber:
          map['bookingNumber']
                  ?.toString() ??
              '',

      bookingDate:
          map['bookingDate'] != null
              ? DateTime.tryParse(
                    map['bookingDate']
                        .toString(),
                  ) ??
                  DateTime.now()
              : map['date'] != null
                  ? DateTime.tryParse(
                        map['date']
                            .toString(),
                      ) ??
                      DateTime.now()
                  : DateTime.now(),

      bookingTime:
          map['bookingTime']
                  ?.toString() ??
              '',

      amount: _asDouble(
        map['amount'] ??
            map['totalAmount'] ??
            map['totalPrice'],
      ),

      totalAmount: _asDouble(
        map['totalAmount'] ??
            map['totalPrice'] ??
            map['amount'],
      ),

      gst: _asDouble(
        map['gst'] ??
            map['taxAmount'],
      ),

      serviceFee: _asDouble(
        map['serviceFee'] ??
            map['platformFee'],
      ),

      discount: _asDouble(
        map['discount'] ??
            map['discountAmount'],
      ),

      bookingStatus:
          map['bookingStatus']
                  ?.toString() ??
              map['status']
                  ?.toString() ??
              'pending',

      paymentStatus:
          map['paymentStatus']
                  ?.toString() ??
              'pending',

      paymentId:
          map['paymentId']
              ?.toString(),

      notes:
          map['notes']
              ?.toString(),

      address:
          map['address']
              ?.toString(),

      latitude: map['latitude'] == null
          ? null
          : _asDouble(
              map['latitude'],
            ),

      longitude:
          map['longitude'] == null
              ? null
              : _asDouble(
                  map['longitude'],
                ),

      chatRoomId:
          map['chatRoomId']
              ?.toString(),

      createdAt:
          map['createdAt'] != null
              ? DateTime.tryParse(
                  map['createdAt']
                      .toString(),
                )
              : null,

      updatedAt:
          map['updatedAt'] != null
              ? DateTime.tryParse(
                  map['updatedAt']
                      .toString(),
                )
              : null,
    );
  }

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
      'chatRoomId': chatRoomId,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

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

  bool get isPending =>
      bookingStatus.toLowerCase() ==
      'pending';

  bool get isAccepted =>
      bookingStatus.toLowerCase() ==
      'accepted';

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

  @override
  String toString() {
    return 'BookingModel(id: $id, bookingNumber: $bookingNumber)';
  }

  @override
  bool operator ==(
    Object other,
  ) {
    return identical(this, other) ||
        other is BookingModel &&
            other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode;
}