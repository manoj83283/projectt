enum OrderStatus {
  pending,
  accepted,
  otpVerified,
  inProgress,
  completed,
  cancelled,
  rejected,
}

extension OrderStatusExtension on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';

      case OrderStatus.accepted:
        return 'accepted';

      case OrderStatus.otpVerified:
        return 'otp_verified';

      case OrderStatus.inProgress:
        return 'in_progress';

      case OrderStatus.completed:
        return 'completed';

      case OrderStatus.cancelled:
        return 'cancelled';

      case OrderStatus.rejected:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';

      case OrderStatus.accepted:
        return 'Accepted';

      case OrderStatus.otpVerified:
        return 'OTP Verified';

      case OrderStatus.inProgress:
        return 'In Progress';

      case OrderStatus.completed:
        return 'Completed';

      case OrderStatus.cancelled:
        return 'Cancelled';

      case OrderStatus.rejected:
        return 'Rejected';
    }
  }

  static OrderStatus fromString(
    dynamic value,
  ) {
    final status = (value ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (status) {
      case 'confirm':
      case 'confirmed':
      case 'accepted':
        return OrderStatus.accepted;

      case 'otpverified':
      case 'otp_verified':
        return OrderStatus.otpVerified;

      case 'processing':
      case 'inprogress':
      case 'in_progress':
        return OrderStatus.inProgress;

      case 'completed':
      case 'delivered':
        return OrderStatus.completed;

      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;

      case 'rejected':
        return OrderStatus.rejected;

      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderModel {
  final String id;

  final String orderNumber;
  final String bookingId;
  final String bookingNumber;

  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerImage;

  final String providerId;
  final String providerName;
  final String providerEmail;
  final String providerPhone;
  final String providerImage;

  final String serviceId;
  final String serviceName;
  final String serviceImage;

  final double basePrice;
  final double pricePerHour;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double platformFee;
  final double totalAmount;

  final String currency;

  final String status;

  final String paymentStatus;
  final String paymentMethod;
  final String paymentId;
  final String transactionId;

  final String eventAddress;
  final String city;
  final String state;
  final String location;
  final String landmark;
  final String nearbyLocation;

  final double? latitude;
  final double? longitude;

  final String notes;
  final String specialInstructions;

  final String orderDate;
  final String eventDate;
  final String bookingTime;

  final bool otpVerified;
  final DateTime? otpVerifiedAt;

  final String chatRoomId;
  final bool chatEnabled;

  final String invoiceNumber;
  final String invoiceUrl;
  final DateTime? invoiceGeneratedAt;

  final int durationMinutes;

  final String rejectionReason;
  final String cancellationReason;

  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? startedAt;
  final DateTime? completedDate;
  final DateTime? cancelledDate;
  final DateTime? paidAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic>? rawUser;
  final Map<String, dynamic>? rawService;
  final Map<String, dynamic>? rawProvider;
  final Map<String, dynamic>? rawBooking;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.platformFee,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionId,
    required this.eventAddress,
    required this.city,
    required this.state,
    required this.location,
    required this.notes,
    required this.orderDate,
    required this.eventDate,
    this.bookingNumber = '',
    this.customerImage = '',
    this.providerEmail = '',
    this.providerPhone = '',
    this.providerImage = '',
    this.serviceImage = '',
    this.basePrice = 0,
    this.pricePerHour = 0,
    this.currency = 'INR',
    this.paymentId = '',
    this.landmark = '',
    this.nearbyLocation = '',
    this.latitude,
    this.longitude,
    this.specialInstructions = '',
    this.bookingTime = '',
    this.otpVerified = false,
    this.otpVerifiedAt,
    this.chatRoomId = '',
    this.chatEnabled = true,
    this.invoiceNumber = '',
    this.invoiceUrl = '',
    this.invoiceGeneratedAt,
    this.durationMinutes = 0,
    this.rejectionReason = '',
    this.cancellationReason = '',
    this.acceptedAt,
    this.rejectedAt,
    this.startedAt,
    this.completedDate,
    this.cancelledDate,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
    this.rawUser,
    this.rawService,
    this.rawProvider,
    this.rawBooking,
  });

  factory OrderModel.empty() {
    return const OrderModel(
      id: '',
      orderNumber: '',
      bookingId: '',
      customerId: '',
      customerName: '',
      customerEmail: '',
      customerPhone: '',
      providerId: '',
      providerName: '',
      serviceId: '',
      serviceName: '',
      subtotal: 0,
      taxAmount: 0,
      discountAmount: 0,
      platformFee: 0,
      totalAmount: 0,
      status: 'pending',
      paymentStatus: 'pending',
      paymentMethod: '',
      transactionId: '',
      eventAddress: '',
      city: '',
      state: '',
      location: '',
      notes: '',
      orderDate: '',
      eventDate: '',
    );
  }

  factory OrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrderModel.fromMap(json);
  }

  factory OrderModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final user = _asMap(
      map['customer'] ?? map['user'],
    );

    final service = _asMap(
      map['service'],
    );

    final provider = _asMap(
      map['provider'],
    );

    final booking = _asMap(
      map['booking'],
    );

    final customerFirstName =
        _asString(user?['firstName']);

    final customerLastName =
        _asString(user?['lastName']);

    final generatedCustomerName = [
      customerFirstName,
      customerLastName,
    ].where(
      (value) => value.isNotEmpty,
    ).join(' ').trim();

    final providerFirstName =
        _asString(provider?['firstName']);

    final providerLastName =
        _asString(provider?['lastName']);

    final generatedProviderName = [
      providerFirstName,
      providerLastName,
    ].where(
      (value) => value.isNotEmpty,
    ).join(' ').trim();

    final parsedBookingId = _extractId(
      booking ??
          map['bookingId'] ??
          map['booking'],
    );

    final parsedId = _asString(
      map['_id'] ?? map['id'],
      fallback: parsedBookingId,
    );

    final parsedCustomerId = _asString(
      map['customerId'] ?? map['userId'],
      fallback: _extractId(
        user ??
            map['customer'] ??
            map['user'],
      ),
    );

    final parsedProviderId = _asString(
      map['providerId'],
      fallback: _extractId(
        provider ??
            map['provider'] ??
            service?['provider'],
      ),
    );

    final parsedServiceId = _asString(
      map['serviceId'],
      fallback: _extractId(
        service ?? map['service'],
      ),
    );

    final parsedOrderDate = _asString(
      map['orderDate'] ??
          map['date'] ??
          booking?['date'] ??
          map['createdAt'],
    );

    final parsedEventDate = _asString(
      map['eventDate'] ??
          map['bookingDate'] ??
          booking?['bookingDate'] ??
          booking?['date'],
      fallback: parsedOrderDate,
    );

    final parsedAddress = _asString(
      map['eventAddress'] ??
          map['address'] ??
          map['location'] ??
          booking?['address'] ??
          booking?['location'],
    );

    final parsedSubtotal = _toDouble(
      map['subtotal'] ??
          map['amount'] ??
          map['price'] ??
          booking?['subtotal'] ??
          booking?['totalPrice'],
    );

    final parsedTotal = _toDouble(
      map['totalAmount'] ??
          map['totalPrice'] ??
          map['amount'] ??
          booking?['totalAmount'] ??
          booking?['totalPrice'],
      fallback: parsedSubtotal,
    );

    final parsedStatus = _normalizeStatus(
      map['status'] ??
          map['bookingStatus'] ??
          booking?['status'] ??
          booking?['bookingStatus'],
    );

    final locationPoint = _asMap(
      map['locationPoint'] ??
          booking?['locationPoint'],
    );

    final coordinates =
        locationPoint?['coordinates'];

    double? latitude;
    double? longitude;

    if (
      coordinates is List &&
      coordinates.length >= 2
    ) {
      longitude = _toNullableDouble(
        coordinates[0],
      );

      latitude = _toNullableDouble(
        coordinates[1],
      );
    }

    latitude ??= _toNullableDouble(
      map['latitude'] ??
          booking?['latitude'],
    );

    longitude ??= _toNullableDouble(
      map['longitude'] ??
          booking?['longitude'],
    );

    final resolvedBookingNumber = _asString(
      map['bookingNumber'] ??
          booking?['bookingNumber'],
    );

    final resolvedOrderNumber = _asString(
      map['orderNumber'] ??
          map['orderNo'],
      fallback: resolvedBookingNumber,
    );

    return OrderModel(
      id: parsedId,

      orderNumber:
          resolvedOrderNumber,

      bookingId:
          parsedBookingId.isNotEmpty
          ? parsedBookingId
          : parsedId,

      bookingNumber:
          resolvedBookingNumber,

      customerId:
          parsedCustomerId,

      customerName: _asString(
        map['customerName'],
        fallback: _asString(
          user?['fullName'] ??
              user?['name'],
          fallback:
              generatedCustomerName,
        ),
      ),

      customerEmail: _asString(
        map['customerEmail'] ??
            user?['email'],
      ),

      customerPhone: _asString(
        map['customerPhone'] ??
            user?['phone'] ??
            user?['mobile'] ??
            booking?['contactNumber'],
      ),

      customerImage: _asString(
        map['customerImage'] ??
            user?['profileImage'],
      ),

      providerId:
          parsedProviderId,

      providerName: _asString(
        map['providerName'],
        fallback: _asString(
          provider?['businessName'] ??
              provider?['shopName'] ??
              provider?['fullName'] ??
              provider?['name'],
          fallback:
              generatedProviderName,
        ),
      ),

      providerEmail: _asString(
        map['providerEmail'] ??
            provider?['email'],
      ),

      providerPhone: _asString(
        map['providerPhone'] ??
            provider?['phone'] ??
            provider?['mobile'],
      ),

      providerImage: _asString(
        map['providerImage'] ??
            provider?['profileImage'],
      ),

      serviceId:
          parsedServiceId,

      serviceName: _asString(
        map['serviceName'] ??
            service?['name'] ??
            service?['title'],
        fallback: 'Service',
      ),

      serviceImage: _extractServiceImage(
        map,
        service,
      ),

      basePrice: _toDouble(
        map['basePrice'] ??
            booking?['basePrice'] ??
            service?['basePrice'],
      ),

      pricePerHour: _toDouble(
        map['pricePerHour'] ??
            booking?['pricePerHour'] ??
            service?['pricePerHour'],
      ),

      subtotal:
          parsedSubtotal,

      taxAmount: _toDouble(
        map['taxAmount'] ??
            map['gst'] ??
            booking?['taxAmount'],
      ),

      discountAmount: _toDouble(
        map['discountAmount'] ??
            map['discount'] ??
            booking?['discountAmount'],
      ),

      platformFee: _toDouble(
        map['platformFee'] ??
            map['serviceFee'] ??
            booking?['platformFee'],
      ),

      totalAmount:
          parsedTotal,

      currency: _asString(
        map['currency'] ??
            booking?['currency'],
        fallback: 'INR',
      ).toUpperCase(),

      status:
          parsedStatus,

      paymentStatus: _asString(
        map['paymentStatus'] ??
            booking?['paymentStatus'],
        fallback: 'pending',
      ).toLowerCase(),

      paymentMethod: _asString(
        map['paymentMethod'] ??
            booking?['paymentMethod'],
      ).toUpperCase(),

      paymentId: _asString(
        map['paymentId'] ??
            booking?['paymentId'],
      ),

      transactionId: _asString(
        map['transactionId'] ??
            map['paymentId'] ??
            booking?['transactionId'] ??
            booking?['paymentId'],
      ),

      eventAddress:
          parsedAddress,

      city: _asString(
        map['city'] ??
            booking?['city'],
      ),

      state: _asString(
        map['state'] ??
            booking?['state'],
      ),

      location: _asString(
        map['location'] ??
            booking?['location'],
        fallback: parsedAddress,
      ),

      landmark: _asString(
        map['landmark'] ??
            booking?['landmark'],
      ),

      nearbyLocation: _asString(
        map['nearbyLocation'] ??
            booking?['nearbyLocation'],
      ),

      latitude: latitude,

      longitude: longitude,

      notes: _asString(
        map['notes'] ??
            booking?['notes'],
      ),

      specialInstructions: _asString(
        map['specialInstructions'] ??
            booking?['specialInstructions'],
      ),

      orderDate:
          parsedOrderDate,

      eventDate:
          parsedEventDate,

      bookingTime: _asString(
        map['bookingTime'] ??
            booking?['bookingTime'],
      ),

      otpVerified: _asBool(
        map['otpVerified'] ??
            booking?['otpVerified'],
      ),

      otpVerifiedAt: _toDateTime(
        map['otpVerifiedAt'] ??
            booking?['otpVerifiedAt'],
      ),

      chatRoomId: _asString(
        map['chatRoomId'] ??
            booking?['chatRoomId'],
        fallback:
            parsedBookingId.isNotEmpty
            ? 'booking:$parsedBookingId'
            : '',
      ),

      chatEnabled: _asBool(
        map['chatEnabled'] ??
            booking?['chatEnabled'],
        fallback: true,
      ),

      invoiceNumber: _asString(
        map['invoiceNumber'] ??
            booking?['invoiceNumber'],
      ),

      invoiceUrl: _asString(
        map['invoiceUrl'] ??
            booking?['invoiceUrl'],
      ),

      invoiceGeneratedAt: _toDateTime(
        map['invoiceGeneratedAt'] ??
            booking?['invoiceGeneratedAt'],
      ),

      durationMinutes: _toInt(
        map['durationMinutes'] ??
            map['serviceDurationMinutes'] ??
            booking?['durationMinutes'],
      ),

      rejectionReason: _asString(
        map['rejectionReason'] ??
            booking?['rejectionReason'],
      ),

      cancellationReason: _asString(
        map['cancellationReason'] ??
            booking?['cancellationReason'],
      ),

      acceptedAt: _toDateTime(
        map['acceptedAt'] ??
            booking?['acceptedAt'],
      ),

      rejectedAt: _toDateTime(
        map['rejectedAt'] ??
            booking?['rejectedAt'],
      ),

      startedAt: _toDateTime(
        map['startedAt'] ??
            booking?['startedAt'],
      ),

      completedDate: _toDateTime(
        map['completedDate'] ??
            map['completedAt'] ??
            booking?['completedAt'],
      ),

      cancelledDate: _toDateTime(
        map['cancelledDate'] ??
            map['cancelledAt'] ??
            booking?['cancelledAt'],
      ),

      paidAt: _toDateTime(
        map['paidAt'] ??
            booking?['paidAt'],
      ),

      createdAt: _toDateTime(
        map['createdAt'] ??
            booking?['createdAt'],
      ),

      updatedAt: _toDateTime(
        map['updatedAt'] ??
            booking?['updatedAt'],
      ),

      rawUser: user,
      rawService: service,
      rawProvider: provider,
      rawBooking: booking,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'orderNumber': orderNumber,
      'bookingId': bookingId,
      'bookingNumber': bookingNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerImage': customerImage,
      'providerId': providerId,
      'providerName': providerName,
      'providerEmail': providerEmail,
      'providerPhone': providerPhone,
      'providerImage': providerImage,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceImage': serviceImage,
      'basePrice': basePrice,
      'pricePerHour': pricePerHour,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
      'totalPrice': totalAmount,
      'currency': currency,
      'status': status,
      'bookingStatus': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'transactionId': transactionId,
      'eventAddress': eventAddress,
      'address': eventAddress,
      'city': city,
      'state': state,
      'location': location,
      'landmark': landmark,
      'nearbyLocation': nearbyLocation,
      'latitude': latitude,
      'longitude': longitude,
      'locationPoint': {
        'type': 'Point',
        'coordinates': [
          longitude ?? 0,
          latitude ?? 0,
        ],
      },
      'notes': notes,
      'specialInstructions':
          specialInstructions,
      'orderDate': orderDate,
      'eventDate': eventDate,
      'bookingDate': eventDate,
      'bookingTime': bookingTime,
      'otpVerified': otpVerified,
      'otpVerifiedAt':
          otpVerifiedAt?.toIso8601String(),
      'chatRoomId': chatRoomId,
      'chatEnabled': chatEnabled,
      'invoiceNumber': invoiceNumber,
      'invoiceUrl': invoiceUrl,
      'invoiceGeneratedAt':
          invoiceGeneratedAt
              ?.toIso8601String(),
      'durationMinutes':
          durationMinutes,
      'rejectionReason':
          rejectionReason,
      'cancellationReason':
          cancellationReason,
      'acceptedAt':
          acceptedAt?.toIso8601String(),
      'rejectedAt':
          rejectedAt?.toIso8601String(),
      'startedAt':
          startedAt?.toIso8601String(),
      'completedDate':
          completedDate?.toIso8601String(),
      'completedAt':
          completedDate?.toIso8601String(),
      'cancelledDate':
          cancelledDate?.toIso8601String(),
      'cancelledAt':
          cancelledDate?.toIso8601String(),
      'paidAt':
          paidAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
      'user': rawUser,
      'service': rawService,
      'provider': rawProvider,
      'booking': rawBooking,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  static OrderStatus _parseStatus(
    dynamic value,
  ) {
    return OrderStatusExtension.fromString(
      value,
    );
  }

  OrderStatus get statusEnum {
    return _parseStatus(status);
  }

  String get statusText {
    return statusEnum.label;
  }

  String get normalizedStatus {
    return statusEnum.value;
  }

  DateTime? get orderDateTime {
    return _toDateTime(orderDate);
  }

  DateTime? get eventDateTime {
    return _toDateTime(eventDate);
  }

  bool get isPending {
    return normalizedStatus == 'pending';
  }

  bool get isAccepted {
    return normalizedStatus == 'accepted';
  }

  bool get isConfirmed {
    return isAccepted;
  }

  bool get isOtpVerified {
    return normalizedStatus ==
            'otp_verified' ||
        otpVerified;
  }

  bool get isInProgress {
    return normalizedStatus ==
        'in_progress';
  }

  bool get isProcessing {
    return isInProgress;
  }

  bool get isCompleted {
    return normalizedStatus ==
        'completed';
  }

  bool get isCancelled {
    return normalizedStatus ==
        'cancelled';
  }

  bool get isRejected {
    return normalizedStatus ==
        'rejected';
  }

  bool get isPaid {
    return paymentStatus
            .trim()
            .toLowerCase() ==
        'paid';
  }

  bool get isTerminal {
    return isCompleted ||
        isCancelled ||
        isRejected;
  }

  bool get canAccept {
    return isPending;
  }

  bool get canReject {
    return isPending;
  }

  bool get canVerifyOtp {
    return isAccepted &&
        !otpVerified;
  }

  bool get canStart {
    return isOtpVerified;
  }

  bool get canComplete {
    return isInProgress;
  }

  bool get canCancel {
    return isAccepted ||
        isOtpVerified ||
        isInProgress;
  }

  bool get canChat {
    return chatEnabled &&
        (
          isAccepted ||
          isOtpVerified ||
          isInProgress ||
          isCompleted
        );
  }

  bool get canCall {
    return customerPhone
            .trim()
            .isNotEmpty &&
        (
          isAccepted ||
          isOtpVerified ||
          isInProgress
        );
  }

  bool get canOpenMaps {
    return hasCoordinates ||
        eventAddress
            .trim()
            .isNotEmpty ||
        location.trim().isNotEmpty;
  }

  bool get hasCoordinates {
    return latitude != null &&
        longitude != null &&
        latitude != 0 &&
        longitude != 0;
  }

  bool get hasInvoice {
    return isCompleted &&
        invoiceNumber
            .trim()
            .isNotEmpty;
  }

  bool get hasChatRoom {
    return effectiveChatRoomId
        .isNotEmpty;
  }

  String get effectiveChatRoomId {
    if (chatRoomId.trim().isNotEmpty) {
      if (
        chatRoomId.startsWith(
          'booking:',
        )
      ) {
        return chatRoomId.trim();
      }

      return 'booking:${chatRoomId.trim()}';
    }

    final resolvedBookingId =
        bookingId.trim().isNotEmpty
        ? bookingId.trim()
        : id.trim();

    if (resolvedBookingId.isEmpty) {
      return '';
    }

    return 'booking:$resolvedBookingId';
  }

  String get effectiveAddress {
    if (eventAddress
        .trim()
        .isNotEmpty) {
      return eventAddress.trim();
    }

    return location.trim();
  }

  String get formattedDuration {
    if (durationMinutes <= 0) {
      return 'Not available';
    }

    final hours =
        durationMinutes ~/ 60;

    final minutes =
        durationMinutes % 60;

    if (hours == 0) {
      return '$minutes minutes';
    }

    if (minutes == 0) {
      return hours == 1
          ? '1 hour'
          : '$hours hours';
    }

    return '$hours hr $minutes min';
  }

  double get netAmount {
    return totalAmount -
        platformFee;
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? bookingId,
    String? bookingNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerImage,
    String? providerId,
    String? providerName,
    String? providerEmail,
    String? providerPhone,
    String? providerImage,
    String? serviceId,
    String? serviceName,
    String? serviceImage,
    double? basePrice,
    double? pricePerHour,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? platformFee,
    double? totalAmount,
    String? currency,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentId,
    String? transactionId,
    String? eventAddress,
    String? city,
    String? state,
    String? location,
    String? landmark,
    String? nearbyLocation,
    double? latitude,
    double? longitude,
    String? notes,
    String? specialInstructions,
    String? orderDate,
    String? eventDate,
    String? bookingTime,
    bool? otpVerified,
    DateTime? otpVerifiedAt,
    String? chatRoomId,
    bool? chatEnabled,
    String? invoiceNumber,
    String? invoiceUrl,
    DateTime? invoiceGeneratedAt,
    int? durationMinutes,
    String? rejectionReason,
    String? cancellationReason,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? startedAt,
    DateTime? completedDate,
    DateTime? cancelledDate,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? rawUser,
    Map<String, dynamic>? rawService,
    Map<String, dynamic>? rawProvider,
    Map<String, dynamic>? rawBooking,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber:
          orderNumber ??
          this.orderNumber,
      bookingId:
          bookingId ??
          this.bookingId,
      bookingNumber:
          bookingNumber ??
          this.bookingNumber,
      customerId:
          customerId ??
          this.customerId,
      customerName:
          customerName ??
          this.customerName,
      customerEmail:
          customerEmail ??
          this.customerEmail,
      customerPhone:
          customerPhone ??
          this.customerPhone,
      customerImage:
          customerImage ??
          this.customerImage,
      providerId:
          providerId ??
          this.providerId,
      providerName:
          providerName ??
          this.providerName,
      providerEmail:
          providerEmail ??
          this.providerEmail,
      providerPhone:
          providerPhone ??
          this.providerPhone,
      providerImage:
          providerImage ??
          this.providerImage,
      serviceId:
          serviceId ??
          this.serviceId,
      serviceName:
          serviceName ??
          this.serviceName,
      serviceImage:
          serviceImage ??
          this.serviceImage,
      basePrice:
          basePrice ??
          this.basePrice,
      pricePerHour:
          pricePerHour ??
          this.pricePerHour,
      subtotal:
          subtotal ??
          this.subtotal,
      taxAmount:
          taxAmount ??
          this.taxAmount,
      discountAmount:
          discountAmount ??
          this.discountAmount,
      platformFee:
          platformFee ??
          this.platformFee,
      totalAmount:
          totalAmount ??
          this.totalAmount,
      currency:
          currency ??
          this.currency,
      status:
          status ??
          this.status,
      paymentStatus:
          paymentStatus ??
          this.paymentStatus,
      paymentMethod:
          paymentMethod ??
          this.paymentMethod,
      paymentId:
          paymentId ??
          this.paymentId,
      transactionId:
          transactionId ??
          this.transactionId,
      eventAddress:
          eventAddress ??
          this.eventAddress,
      city:
          city ??
          this.city,
      state:
          state ??
          this.state,
      location:
          location ??
          this.location,
      landmark:
          landmark ??
          this.landmark,
      nearbyLocation:
          nearbyLocation ??
          this.nearbyLocation,
      latitude:
          latitude ??
          this.latitude,
      longitude:
          longitude ??
          this.longitude,
      notes:
          notes ??
          this.notes,
      specialInstructions:
          specialInstructions ??
          this.specialInstructions,
      orderDate:
          orderDate ??
          this.orderDate,
      eventDate:
          eventDate ??
          this.eventDate,
      bookingTime:
          bookingTime ??
          this.bookingTime,
      otpVerified:
          otpVerified ??
          this.otpVerified,
      otpVerifiedAt:
          otpVerifiedAt ??
          this.otpVerifiedAt,
      chatRoomId:
          chatRoomId ??
          this.chatRoomId,
      chatEnabled:
          chatEnabled ??
          this.chatEnabled,
      invoiceNumber:
          invoiceNumber ??
          this.invoiceNumber,
      invoiceUrl:
          invoiceUrl ??
          this.invoiceUrl,
      invoiceGeneratedAt:
          invoiceGeneratedAt ??
          this.invoiceGeneratedAt,
      durationMinutes:
          durationMinutes ??
          this.durationMinutes,
      rejectionReason:
          rejectionReason ??
          this.rejectionReason,
      cancellationReason:
          cancellationReason ??
          this.cancellationReason,
      acceptedAt:
          acceptedAt ??
          this.acceptedAt,
      rejectedAt:
          rejectedAt ??
          this.rejectedAt,
      startedAt:
          startedAt ??
          this.startedAt,
      completedDate:
          completedDate ??
          this.completedDate,
      cancelledDate:
          cancelledDate ??
          this.cancelledDate,
      paidAt:
          paidAt ??
          this.paidAt,
      createdAt:
          createdAt ??
          this.createdAt,
      updatedAt:
          updatedAt ??
          this.updatedAt,
      rawUser:
          rawUser ??
          this.rawUser,
      rawService:
          rawService ??
          this.rawService,
      rawProvider:
          rawProvider ??
          this.rawProvider,
      rawBooking:
          rawBooking ??
          this.rawBooking,
    );
  }

  static String _normalizeStatus(
    dynamic value,
  ) {
    return OrderStatusExtension
        .fromString(value)
        .value;
  }

  static String _asString(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final normalized =
        value.toString().trim();

    return normalized.isEmpty
        ? fallback
        : normalized;
  }

  static String _extractId(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    final map = _asMap(value);

    if (map == null) {
      return '';
    }

    return _asString(
      map['_id'] ?? map['id'],
    );
  }

  static Map<String, dynamic>? _asMap(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, item) {
          return MapEntry(
            key.toString(),
            item,
          );
        },
      );
    }

    return null;
  }

  static double _toDouble(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        fallback;
  }

  static double? _toNullableDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        fallback;
  }

  static bool _asBool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized =
        value.toString().trim().toLowerCase();

    if (
      normalized == 'true' ||
      normalized == '1' ||
      normalized == 'yes'
    ) {
      return true;
    }

    if (
      normalized == 'false' ||
      normalized == '0' ||
      normalized == 'no'
    ) {
      return false;
    }

    return fallback;
  }

  static DateTime? _toDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static String _extractServiceImage(
    Map<String, dynamic> map,
    Map<String, dynamic>? service,
  ) {
    final directImage = _asString(
      map['serviceImage'] ??
          service?['imageUrl'] ??
          service?['image'],
    );

    if (directImage.isNotEmpty) {
      return directImage;
    }

    final images =
        service?['images'] ??
        map['images'];

    if (
      images is List &&
      images.isNotEmpty
    ) {
      final firstImage =
          images.first;

      if (firstImage is String) {
        return firstImage.trim();
      }

      final imageMap =
          _asMap(firstImage);

      return _asString(
        imageMap?['url'] ??
            imageMap?['imageUrl'] ??
            imageMap?['image'],
      );
    }

    return '';
  }

  @override
  bool operator ==(
    Object other,
  ) {
    return identical(
          this,
          other,
        ) ||
        other is OrderModel &&
            other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, bookingNumber: $bookingNumber, status: $status)';
  }
}