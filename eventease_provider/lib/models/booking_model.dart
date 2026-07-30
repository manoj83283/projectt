enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  refunded,
}

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

  final String categoryId;
  final String categoryName;

  final DateTime bookingDate;
  final String bookingTime;

  final String eventAddress;
  final String city;
  final String state;

  final double amount;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;

  final BookingStatus status;

  final String paymentStatus;

  final String notes;

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
    required this.categoryId,
    required this.categoryName,
    required this.bookingDate,
    required this.bookingTime,
    required this.eventAddress,
    required this.city,
    required this.state,
    required this.amount,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.empty() {
    return BookingModel(
      id: '',
      bookingNumber: '',
      customerId: '',
      customerName: '',
      customerPhone: '',
      providerId: '',
      providerName: '',
      serviceId: '',
      serviceName: '',
      categoryId: '',
      categoryName: '',
      bookingDate: DateTime.now(),
      bookingTime: '',
      eventAddress: '',
      city: '',
      state: '',
      amount: 0,
      taxAmount: 0,
      discountAmount: 0,
      totalAmount: 0,
      status: BookingStatus.pending,
      paymentStatus: 'Pending',
      notes: '',
    );
  }

  factory BookingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      bookingNumber:
          json['bookingNumber']?.toString() ??
              '',
      customerId:
          json['customerId']?.toString() ??
              '',
      customerName:
          json['customerName']?.toString() ??
              '',
      customerPhone:
          json['customerPhone']?.toString() ??
              '',
      providerId:
          json['providerId']?.toString() ??
              '',
      providerName:
          json['providerName']?.toString() ??
              '',
      serviceId:
          json['serviceId']?.toString() ??
              '',
      serviceName:
          json['serviceName']?.toString() ??
              '',
      categoryId:
          json['categoryId']?.toString() ??
              '',
      categoryName:
          json['categoryName']?.toString() ??
              '',
      bookingDate:
          json['bookingDate'] != null
              ? DateTime.parse(
                  json['bookingDate']
                      .toString(),
                )
              : DateTime.now(),
      bookingTime:
          json['bookingTime']?.toString() ??
              '',
      eventAddress:
          json['eventAddress']?.toString() ??
              '',
      city:
          json['city']?.toString() ?? '',
      state:
          json['state']?.toString() ?? '',
      amount:
          (json['amount'] ?? 0).toDouble(),
      taxAmount:
          (json['taxAmount'] ?? 0)
              .toDouble(),
      discountAmount:
          (json['discountAmount'] ?? 0)
              .toDouble(),
      totalAmount:
          (json['totalAmount'] ?? 0)
              .toDouble(),
      status: _parseStatus(
        json['status'],
      ),
      paymentStatus:
          json['paymentStatus']
                  ?.toString() ??
              'Pending',
      notes:
          json['notes']?.toString() ?? '',
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
      'categoryId': categoryId,
      'categoryName': categoryName,
      'bookingDate':
          bookingDate.toIso8601String(),
      'bookingTime': bookingTime,
      'eventAddress': eventAddress,
      'city': city,
      'state': state,
      'amount': amount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  static BookingStatus _parseStatus(
    dynamic value,
  ) {
    switch (
        value.toString().toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;

      case 'inprogress':
      case 'in_progress':
        return BookingStatus.inProgress;

      case 'completed':
        return BookingStatus.completed;

      case 'cancelled':
        return BookingStatus.cancelled;

      case 'refunded':
        return BookingStatus.refunded;

      default:
        return BookingStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';

      case BookingStatus.confirmed:
        return 'Confirmed';

      case BookingStatus.inProgress:
        return 'In Progress';

      case BookingStatus.completed:
        return 'Completed';

      case BookingStatus.cancelled:
        return 'Cancelled';

      case BookingStatus.refunded:
        return 'Refunded';
    }
  }

  bool get isPending =>
      status == BookingStatus.pending;

  bool get isConfirmed =>
      status == BookingStatus.confirmed;

  bool get isCompleted =>
      status == BookingStatus.completed;

  bool get isCancelled =>
      status == BookingStatus.cancelled;

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
    String? categoryId,
    String? categoryName,
    DateTime? bookingDate,
    String? bookingTime,
    String? eventAddress,
    String? city,
    String? state,
    double? amount,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    BookingStatus? status,
    String? paymentStatus,
    String? notes,
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
      categoryId:
          categoryId ??
              this.categoryId,
      categoryName:
          categoryName ??
              this.categoryName,
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
      amount: amount ?? this.amount,
      taxAmount:
          taxAmount ?? this.taxAmount,
      discountAmount:
          discountAmount ??
              this.discountAmount,
      totalAmount:
          totalAmount ??
              this.totalAmount,
      status: status ?? this.status,
      paymentStatus:
          paymentStatus ??
              this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BookingModel(id: $id, bookingNumber: $bookingNumber)';
  }
}