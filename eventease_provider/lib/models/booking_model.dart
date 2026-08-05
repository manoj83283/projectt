enum BookingStatus {
  pending,
  confirmed,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled,
  refunded,
}

extension BookingStatusExtension on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';

      case BookingStatus.confirmed:
        return 'confirmed';

      case BookingStatus.accepted:
        return 'accepted';

      case BookingStatus.rejected:
        return 'rejected';

      case BookingStatus.inProgress:
        return 'in_progress';

      case BookingStatus.completed:
        return 'completed';

      case BookingStatus.cancelled:
        return 'cancelled';

      case BookingStatus.refunded:
        return 'refunded';
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';

      case BookingStatus.confirmed:
        return 'Confirmed';

      case BookingStatus.accepted:
        return 'Accepted';

      case BookingStatus.rejected:
        return 'Rejected';

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

  static BookingStatus fromString(dynamic value) {
    final status = value?.toString().toLowerCase().trim() ?? '';

    switch (status) {
      case 'confirmed':
        return BookingStatus.confirmed;

      case 'accepted':
        return BookingStatus.accepted;

      case 'rejected':
        return BookingStatus.rejected;

      case 'inprogress':
      case 'in_progress':
        return BookingStatus.inProgress;

      case 'completed':
        return BookingStatus.completed;

      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;

      case 'refunded':
        return BookingStatus.refunded;

      case 'pending':
      default:
        return BookingStatus.pending;
    }
  }
}

class BookingModel {
  final String id;

  final String bookingNumber;

  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  final String providerId;
  final String providerName;

  final String serviceId;
  final String serviceName;

  final String categoryId;
  final String categoryName;

  /// ✅ Kept as String because your screens use:
  /// booking.bookingDate ?? ''
  final String bookingDate;

  final String bookingTime;

  final String eventAddress;
  final String city;
  final String state;

  /// ✅ Extra backend-compatible location fields
  final String address;
  final String location;

  final double amount;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;

  /// ✅ Kept as String because your screens use:
  /// booking.status.toLowerCase()
  /// booking.status.toUpperCase()
  /// _statusColor(booking.status)
  final String status;

  final String paymentStatus;
  final String paymentMethod;

  final String notes;

  final int hoursBooked;
  final double pricePerHour;

  final String chatRoomId;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  final Map<String, dynamic>? rawUser;
  final Map<String, dynamic>? rawService;
  final Map<String, dynamic>? rawProvider;

  const BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
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
    required this.address,
    required this.location,
    required this.amount,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.notes,
    required this.hoursBooked,
    required this.pricePerHour,
    required this.chatRoomId,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.rawUser,
    this.rawService,
    this.rawProvider,
  });

  factory BookingModel.empty() {
    return const BookingModel(
      id: '',
      bookingNumber: '',
      customerId: '',
      customerName: '',
      customerEmail: '',
      customerPhone: '',
      providerId: '',
      providerName: '',
      serviceId: '',
      serviceName: '',
      categoryId: '',
      categoryName: '',
      bookingDate: '',
      bookingTime: '',
      eventAddress: '',
      city: '',
      state: '',
      address: '',
      location: '',
      amount: 0,
      taxAmount: 0,
      discountAmount: 0,
      totalAmount: 0,
      status: 'pending',
      paymentStatus: 'pending',
      paymentMethod: 'COD',
      notes: '',
      hoursBooked: 1,
      pricePerHour: 0,
      chatRoomId: '',
    );
  }

  factory BookingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final user = _asMap(json['user']);
    final service = _asMap(json['service']);
    final provider = _asMap(json['provider']);

    final userFirstName = user?['firstName']?.toString() ?? '';
    final userLastName = user?['lastName']?.toString() ?? '';
    final userFullName = user?['name']?.toString() ?? '';

    final parsedCustomerName = userFullName.isNotEmpty
        ? userFullName
        : '$userFirstName $userLastName'.trim();

    final parsedBookingDate = json['bookingDate']?.toString() ??
        json['date']?.toString() ??
        json['createdAt']?.toString() ??
        '';

    final parsedAddress = json['eventAddress']?.toString() ??
        json['address']?.toString() ??
        json['location']?.toString() ??
        '';

    final parsedStatus =
        json['status']?.toString().toLowerCase().trim() ?? 'pending';

    final parsedProviderId = provider?['_id']?.toString() ??
        provider?['id']?.toString() ??
        service?['provider']?.toString() ??
        json['providerId']?.toString() ??
        json['provider']?.toString() ??
        '';

    final parsedServiceId = service?['_id']?.toString() ??
        service?['id']?.toString() ??
        json['serviceId']?.toString() ??
        json['service']?.toString() ??
        '';

    final parsedCustomerId = user?['_id']?.toString() ??
        user?['id']?.toString() ??
        json['customerId']?.toString() ??
        json['userId']?.toString() ??
        json['user']?.toString() ??
        '';

    return BookingModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      bookingNumber: json['bookingNumber']?.toString() ??
          json['bookingNo']?.toString() ??
          '',

      customerId: parsedCustomerId,

      customerName: json['customerName']?.toString() ??
          parsedCustomerName,

      customerEmail: json['customerEmail']?.toString() ??
          user?['email']?.toString() ??
          '',

      customerPhone: json['customerPhone']?.toString() ??
          user?['phone']?.toString() ??
          '',

      providerId: parsedProviderId,

      providerName: json['providerName']?.toString() ??
          provider?['name']?.toString() ??
          provider?['firstName']?.toString() ??
          '',

      serviceId: parsedServiceId,

      serviceName: json['serviceName']?.toString() ??
          service?['name']?.toString() ??
          service?['title']?.toString() ??
          'Service',

      categoryId: json['categoryId']?.toString() ??
          service?['categoryId']?.toString() ??
          service?['category']?.toString() ??
          '',

      categoryName: json['categoryName']?.toString() ??
          service?['categoryName']?.toString() ??
          service?['category']?.toString() ??
          '',

      bookingDate: parsedBookingDate,

      bookingTime: json['bookingTime']?.toString() ??
          json['time']?.toString() ??
          '',

      eventAddress: json['eventAddress']?.toString() ??
          parsedAddress,

      city: json['city']?.toString() ?? '',

      state: json['state']?.toString() ?? '',

      address: json['address']?.toString() ??
          parsedAddress,

      location: json['location']?.toString() ??
          parsedAddress,

      amount: _toDouble(
        json['amount'] ??
            json['price'] ??
            json['pricePerHour'],
      ),

      taxAmount: _toDouble(
        json['taxAmount'],
      ),

      discountAmount: _toDouble(
        json['discountAmount'],
      ),

      totalAmount: _toDouble(
        json['totalAmount'] ??
            json['totalPrice'] ??
            json['amount'] ??
            json['price'],
      ),

      status: parsedStatus,

      paymentStatus: json['paymentStatus']?.toString() ??
          'pending',

      paymentMethod: json['paymentMethod']?.toString() ??
          'COD',

      notes: json['notes']?.toString() ?? '',

      hoursBooked: _toInt(
        json['hoursBooked'] ??
            json['hours'] ??
            1,
      ),

      pricePerHour: _toDouble(
        json['pricePerHour'] ??
            json['price'] ??
            service?['price'] ??
            service?['pricePerHour'],
      ),

      chatRoomId: json['chatRoomId']?.toString() ?? '',

      createdAt: _toDateTime(
        json['createdAt'],
      ),

      updatedAt: _toDateTime(
        json['updatedAt'],
      ),

      acceptedAt: _toDateTime(
        json['acceptedAt'],
      ),

      startedAt: _toDateTime(
        json['startedAt'],
      ),

      completedAt: _toDateTime(
        json['completedAt'],
      ),

      cancelledAt: _toDateTime(
        json['cancelledAt'],
      ),

      rawUser: user,
      rawService: service,
      rawProvider: provider,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'bookingNumber': bookingNumber,

      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,

      'providerId': providerId,
      'providerName': providerName,

      'serviceId': serviceId,
      'serviceName': serviceName,

      'categoryId': categoryId,
      'categoryName': categoryName,

      'bookingDate': bookingDate,
      'date': bookingDate,
      'bookingTime': bookingTime,

      'eventAddress': eventAddress,
      'address': address,
      'location': location,
      'city': city,
      'state': state,

      'amount': amount,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'totalPrice': totalAmount,

      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,

      'notes': notes,
      'hoursBooked': hoursBooked,
      'pricePerHour': pricePerHour,
      'chatRoomId': chatRoomId,

      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),

      'user': rawUser,
      'service': rawService,
      'provider': rawProvider,
    };
  }

  BookingModel copyWith({
    String? id,
    String? bookingNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? providerId,
    String? providerName,
    String? serviceId,
    String? serviceName,
    String? categoryId,
    String? categoryName,
    String? bookingDate,
    String? bookingTime,
    String? eventAddress,
    String? city,
    String? state,
    String? address,
    String? location,
    double? amount,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? notes,
    int? hoursBooked,
    double? pricePerHour,
    String? chatRoomId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? rawUser,
    Map<String, dynamic>? rawService,
    Map<String, dynamic>? rawProvider,
  }) {
    return BookingModel(
      id: id ?? this.id,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      eventAddress: eventAddress ?? this.eventAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      address: address ?? this.address,
      location: location ?? this.location,
      amount: amount ?? this.amount,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      hoursBooked: hoursBooked ?? this.hoursBooked,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      rawUser: rawUser ?? this.rawUser,
      rawService: rawService ?? this.rawService,
      rawProvider: rawProvider ?? this.rawProvider,
    );
  }

  // =============================================================
  // ✅ BACKWARD-COMPATIBLE GETTERS
  // =============================================================

  BookingStatus get statusEnum {
    return BookingStatusExtension.fromString(status);
  }

  String get statusText {
    return statusEnum.label;
  }

  DateTime? get bookingDateTime {
    return _toDateTime(bookingDate);
  }

  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  bool get isConfirmed {
    return status.toLowerCase() == 'confirmed' ||
        status.toLowerCase() == 'accepted';
  }

  bool get isAccepted {
    return status.toLowerCase() == 'accepted';
  }

  bool get isInProgress {
    return status.toLowerCase() == 'in_progress' ||
        status.toLowerCase() == 'inprogress';
  }

  bool get isCompleted {
    return status.toLowerCase() == 'completed';
  }

  bool get isCancelled {
    return status.toLowerCase() == 'cancelled' ||
        status.toLowerCase() == 'canceled';
  }

  bool get isRejected {
    return status.toLowerCase() == 'rejected';
  }

  bool get isRefunded {
    return status.toLowerCase() == 'refunded';
  }

  // =============================================================
  // ✅ SAFE HELPERS
  // =============================================================

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, val) => MapEntry(
          key.toString(),
          val,
        ),
      );
    }

    return null;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString()) ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    return DateTime.tryParse(
      value.toString(),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingModel &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BookingModel(id: $id, bookingNumber: $bookingNumber, status: $status)';
  }
}