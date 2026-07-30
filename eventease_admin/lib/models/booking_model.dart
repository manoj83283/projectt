class BookingModel {
  final String id;

  final String bookingNumber;

  final String customerId;
  final String customerName;
  final String customerPhone;

  final String providerId;
  final String providerName;

  final String serviceId;
  final String serviceName;

  final DateTime bookingDate;
  final String bookingTime;

  final String eventAddress;
  final String? city;
  final String? state;
  final String? pincode;

  final double amount;
  final double tax;
  final double discount;
  final double totalAmount;

  final String status;

  final String paymentStatus;
  final String paymentMethod;

  final String? notes;
  final String? cancellationReason;

  final bool isRated;

  final DateTime? completedAt;
  final DateTime? cancelledAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.bookingDate,
    required this.bookingTime,
    required this.eventAddress,
    this.city,
    this.state,
    this.pincode,
    required this.amount,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.notes,
    this.cancellationReason,
    required this.isRated,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      bookingNumber:
          json['bookingNumber']
                  ?.toString() ??
              '',

      customerId:
          json['customerId']
                  ?.toString() ??
              '',

      customerName:
          json['customerName']
                  ?.toString() ??
              '',

      customerPhone:
          json['customerPhone']
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

      serviceId:
          json['serviceId']
                  ?.toString() ??
              '',

      serviceName:
          json['serviceName']
                  ?.toString() ??
              '',

      bookingDate:
          DateTime.tryParse(
                json['bookingDate']
                        ?.toString() ??
                    '',
              ) ??
              DateTime.now(),

      bookingTime:
          json['bookingTime']
                  ?.toString() ??
              '',

      eventAddress:
          json['eventAddress']
                  ?.toString() ??
              '',

      city:
          json['city']?.toString(),

      state:
          json['state']?.toString(),

      pincode:
          json['pincode']?.toString(),

      amount:
          (json['amount'] ?? 0)
              .toDouble(),

      tax:
          (json['tax'] ?? 0)
              .toDouble(),

      discount:
          (json['discount'] ?? 0)
              .toDouble(),

      totalAmount:
          (json['totalAmount'] ?? 0)
              .toDouble(),

      status:
          json['status']
                  ?.toString() ??
              'pending',

      paymentStatus:
          json['paymentStatus']
                  ?.toString() ??
              'pending',

      paymentMethod:
          json['paymentMethod']
                  ?.toString() ??
              'online',

      notes:
          json['notes']?.toString(),

      cancellationReason:
          json['cancellationReason']
              ?.toString(),

      isRated:
          json['isRated'] ?? false,

      completedAt:
          json['completedAt'] != null
              ? DateTime.tryParse(
                  json['completedAt']
                      .toString(),
                )
              : null,

      cancelledAt:
          json['cancelledAt'] != null
              ? DateTime.tryParse(
                  json['cancelledAt']
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
      'bookingNumber': bookingNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'providerId': providerId,
      'providerName': providerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'bookingDate':
          bookingDate.toIso8601String(),
      'bookingTime': bookingTime,
      'eventAddress': eventAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'amount': amount,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'cancellationReason':
          cancellationReason,
      'isRated': isRated,
      'completedAt':
          completedAt?.toIso8601String(),
      'cancelledAt':
          cancelledAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? bookingNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? providerId,
    String? providerName,
    String? serviceId,
    String? serviceName,
    DateTime? bookingDate,
    String? bookingTime,
    String? eventAddress,
    String? city,
    String? state,
    String? pincode,
    double? amount,
    double? tax,
    double? discount,
    double? totalAmount,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? notes,
    String? cancellationReason,
    bool? isRated,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingNumber:
          bookingNumber ??
              this.bookingNumber,
      customerId:
          customerId ?? this.customerId,
      customerName:
          customerName ??
              this.customerName,
      customerPhone:
          customerPhone ??
              this.customerPhone,
      providerId:
          providerId ?? this.providerId,
      providerName:
          providerName ??
              this.providerName,
      serviceId:
          serviceId ?? this.serviceId,
      serviceName:
          serviceName ??
              this.serviceName,
      bookingDate:
          bookingDate ??
              this.bookingDate,
      bookingTime:
          bookingTime ??
              this.bookingTime,
      eventAddress:
          eventAddress ??
              this.eventAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode:
          pincode ?? this.pincode,
      amount: amount ?? this.amount,
      tax: tax ?? this.tax,
      discount:
          discount ?? this.discount,
      totalAmount:
          totalAmount ??
              this.totalAmount,
      status: status ?? this.status,
      paymentStatus:
          paymentStatus ??
              this.paymentStatus,
      paymentMethod:
          paymentMethod ??
              this.paymentMethod,
      notes: notes ?? this.notes,
      cancellationReason:
          cancellationReason ??
              this.cancellationReason,
      isRated:
          isRated ?? this.isRated,
      completedAt:
          completedAt ??
              this.completedAt,
      cancelledAt:
          cancelledAt ??
              this.cancelledAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending =>
      status.toLowerCase() ==
      'pending';

  bool get isConfirmed =>
      status.toLowerCase() ==
      'confirmed';

  bool get isCompleted =>
      status.toLowerCase() ==
      'completed';

  bool get isCancelled =>
      status.toLowerCase() ==
      'cancelled';

  bool get isPaid =>
      paymentStatus.toLowerCase() ==
      'paid';

  bool get isUnpaid =>
      paymentStatus.toLowerCase() !=
      'paid';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BookingModel('
        'id: $id, '
        'bookingNumber: $bookingNumber, '
        'status: $status'
        ')';
  }
}