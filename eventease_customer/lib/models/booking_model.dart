import 'dart:convert';

class BookingModel {
  final String id;

  final String customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;

  final String providerId;
  final String providerName;
  final String providerPhone;
  final String providerEmail;

  final String serviceId;
  final String serviceName;
  final String serviceImage;

  final String bookingNumber;

  final DateTime bookingDate;
  final String bookingTime;

  final double amount;
  final double gst;
  final double serviceFee;
  final double discount;
  final double totalAmount;

  final String currency;
  final String bookingStatus;
  final String paymentStatus;
  final String paymentMethod;

  final String? paymentId;
  final String? transactionId;

  final String notes;
  final String address;
  final String location;
  final String landmark;
  final String nearbyLocation;

  final double? latitude;
  final double? longitude;

  final String chatRoomId;

  final bool providerArrived;
  final DateTime? providerArrivedAt;
  final double? providerArrivalLatitude;
  final double? providerArrivalLongitude;
  final double? providerArrivalDistanceMeters;
  final bool providerArrivalVerified;

  final bool otpVerified;
  final DateTime? otpVerifiedAt;

  final String rejectionReason;
  final String cancellationReason;

  final String? invoiceNumber;
  final String? invoiceUrl;

  final int durationMinutes;

  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<Map<String, dynamic>> statusHistory;

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
    this.customerPhone = '',
    this.customerEmail = '',
    this.providerPhone = '',
    this.providerEmail = '',
    this.serviceImage = '',
    this.gst = 0,
    this.serviceFee = 0,
    this.discount = 0,
    this.currency = 'INR',
    this.bookingStatus = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod = 'COD',
    this.paymentId,
    this.transactionId,
    this.notes = '',
    this.address = '',
    this.location = '',
    this.landmark = '',
    this.nearbyLocation = '',
    this.latitude,
    this.longitude,
    this.chatRoomId = '',
    this.providerArrived = false,
    this.providerArrivedAt,
    this.providerArrivalLatitude,
    this.providerArrivalLongitude,
    this.providerArrivalDistanceMeters,
    this.providerArrivalVerified = false,
    this.otpVerified = false,
    this.otpVerifiedAt,
    this.rejectionReason = '',
    this.cancellationReason = '',
    this.invoiceNumber,
    this.invoiceUrl,
    this.durationMinutes = 0,
    this.acceptedAt,
    this.rejectedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.statusHistory = const <Map<String, dynamic>>[],
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

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, dynamic item) {
        return MapEntry(key.toString(), item);
      });
    }

    return <String, dynamic>{};
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    if (value is String) {
      final normalized = value.trim();

      return normalized.isEmpty ? fallback : normalized;
    }

    if (value is num || value is bool) {
      final normalized = value.toString().trim();

      return normalized.isEmpty ? fallback : normalized;
    }

    if (value is Map) {
      final map = _asMap(value);

      final candidates = <dynamic>[
        map['businessName'],
        map['shopName'],
        map['fullName'],
        map['name'],
        map['title'],
        map['value'],
        map['label'],
      ];

      for (final candidate in candidates) {
        final normalized = _asString(candidate);

        if (normalized.isNotEmpty) {
          return normalized;
        }
      }

      return fallback;
    }

    if (value is List) {
      final values =
          value
              .map((item) => _asString(item))
              .where((item) => item.isNotEmpty)
              .toList();

      return values.isEmpty ? fallback : values.join(', ');
    }

    final normalized = value.toString().trim();

    return normalized.isEmpty ? fallback : normalized;
  }

  static String? _asNullableString(dynamic value) {
    final normalized = _asString(value);

    return normalized.isEmpty ? null : normalized;
  }

  static double _asDouble(dynamic value, {double fallback = 0}) {
    if (value == null) {
      return fallback;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().trim()) ?? fallback;
  }

  static double? _asNullableDouble(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().trim());
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString().trim()) ?? fallback;
  }

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value == null) {
      return fallback;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value.toString().trim().toLowerCase();

    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }

    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }

    return fallback;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    final normalized = value.toString().trim();

    if (normalized.isEmpty) {
      return null;
    }

    return DateTime.tryParse(normalized);
  }

  static String _extractId(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    final map = _asMap(value);

    return _asString(
      map['_id'] ??
          map['id'] ??
          map['userId'] ??
          map['providerId'] ??
          map['serviceId'],
    );
  }

  static String _extractName(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    final map = _asMap(value);

    final firstName = _asString(map['firstName']);

    final lastName = _asString(map['lastName']);

    final combinedName =
        <String>[
          firstName,
          lastName,
        ].where((item) => item.isNotEmpty).join(' ').trim();

    final candidates = <dynamic>[
      map['businessName'],
      map['shopName'],
      map['fullName'],
      map['name'],
      map['title'],
    ];

    for (final candidate in candidates) {
      final normalized = _asString(candidate);

      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    return combinedName;
  }

  static String _extractPhone(dynamic value) {
    final map = _asMap(value);

    return _asString(map['phone'] ?? map['mobile'] ?? map['contactNumber']);
  }

  static String _extractEmail(dynamic value) {
    final map = _asMap(value);

    return _asString(map['email']);
  }

  static String _extractImage(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    final map = _asMap(value);

    final directCandidates = <dynamic>[
      map['imageUrl'],
      map['image'],
      map['profileImage'],
      map['url'],
    ];

    for (final candidate in directCandidates) {
      final normalized = _asString(candidate);

      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    final images = map['images'];

    if (images is List && images.isNotEmpty) {
      final firstImage = images.first;

      if (firstImage is String) {
        return firstImage.trim();
      }

      final imageMap = _asMap(firstImage);

      return _asString(
        imageMap['url'] ?? imageMap['imageUrl'] ?? imageMap['image'],
      );
    }

    return '';
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    final result = <Map<String, dynamic>>[];

    for (final item in value) {
      final map = _asMap(item);

      if (map.isNotEmpty) {
        result.add(map);
      }
    }

    return result;
  }

  static List<dynamic> _extractCoordinates(dynamic value) {
    final map = _asMap(value);

    final coordinates = map['coordinates'];

    if (coordinates is List && coordinates.length >= 2) {
      return List<dynamic>.from(coordinates);
    }

    return <dynamic>[];
  }

  static String _normalizeBookingStatus(dynamic value) {
    final status = _asString(
      value,
      fallback: 'pending',
    ).toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');

    switch (status) {
      case 'confirmed':
      case 'confirm':
        return 'accepted';

      case 'otpverified':
      case 'otp_verified_success':
        return 'otp_verified';

      case 'inprogress':
      case 'processing':
      case 'started':
        return 'in_progress';

      case 'complete':
        return 'completed';

      case 'canceled':
        return 'cancelled';

      default:
        return status;
    }
  }

  static String _normalizePaymentStatus(dynamic value) {
    final status = _asString(
      value,
      fallback: 'pending',
    ).toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');

    switch (status) {
      case 'success':
      case 'successful':
      case 'completed':
        return 'paid';

      case 'failed':
      case 'failure':
        return 'failed';

      case 'refunded':
      case 'refund':
        return 'refunded';

      default:
        return status;
    }
  }

  factory BookingModel.fromMap(Map<String, dynamic> source) {
    final sourceMap = _asMap(source);

    final dynamic possibleWrapper = sourceMap['booking'] ?? sourceMap['data'];

    final map =
        possibleWrapper is Map &&
                !sourceMap.containsKey('_id') &&
                !sourceMap.containsKey('bookingId') &&
                !sourceMap.containsKey('bookingNumber')
            ? _asMap(possibleWrapper)
            : sourceMap;

    final customer = _asMap(map['customer'] ?? map['user']);

    final provider = _asMap(map['provider']);

    final service = _asMap(map['service']);

    final locationCoordinates = _extractCoordinates(map['locationPoint']);

    final providerArrivalCoordinates = _extractCoordinates(
      map['providerArrivalLocation'],
    );

    final bookingId = _asString(map['_id'] ?? map['id'] ?? map['bookingId']);

    final customerId = _asString(
      map['customerId'],
      fallback: _extractId(customer),
    );

    final providerId = _asString(
      map['providerId'],
      fallback: _extractId(provider),
    );

    final serviceId = _asString(
      map['serviceId'],
      fallback: _extractId(service),
    );

    final customerName = _asString(
      map['customerName'],
      fallback: _extractName(customer),
    );

    final providerName = _asString(
      map['providerName'],
      fallback: _extractName(provider),
    );

    final serviceName = _asString(
      map['serviceName'],
      fallback: _extractName(service),
    );

    final bookingDate =
        _parseDate(map['bookingDate']) ??
        _parseDate(map['date']) ??
        DateTime.now();

    final amount = _asDouble(
      map['amount'] ??
          map['subtotal'] ??
          map['totalAmount'] ??
          map['totalPrice'],
    );

    final totalAmount = _asDouble(
      map['totalAmount'] ??
          map['totalPrice'] ??
          map['amount'] ??
          map['subtotal'],
    );

    final bookingStatus = _normalizeBookingStatus(
      map['bookingStatus'] ?? map['status'],
    );

    final otpVerified = _asBool(
      map['otpVerified'],
      fallback: bookingStatus == 'otp_verified',
    );

    final providerArrived = _asBool(
      map['providerArrived'],
      fallback: map['providerArrivedAt'] != null,
    );

    return BookingModel(
      id: bookingId,

      customerId: customerId,

      customerName: customerName,

      customerPhone: _asString(
        map['customerPhone'] ??
            map['contactNumber'] ??
            map['phone'] ??
            map['mobile'],
        fallback: _extractPhone(customer),
      ),

      customerEmail: _asString(
        map['customerEmail'],
        fallback: _extractEmail(customer),
      ),

      providerId: providerId,

      providerName: providerName,

      providerPhone: _asString(
        map['providerPhone'],
        fallback: _extractPhone(provider),
      ),

      providerEmail: _asString(
        map['providerEmail'],
        fallback: _extractEmail(provider),
      ),

      serviceId: serviceId,

      serviceName: serviceName,

      serviceImage: _asString(
        map['serviceImage'],
        fallback: _extractImage(service),
      ),

      bookingNumber: _asString(
        map['bookingNumber'],
        fallback:
            bookingId.isEmpty
                ? ''
                : 'EB-${bookingId.length > 8 ? bookingId.substring(bookingId.length - 8).toUpperCase() : bookingId.toUpperCase()}',
      ),

      bookingDate: bookingDate,

      bookingTime: _asString(map['bookingTime'] ?? map['time']),

      amount: amount,

      gst: _asDouble(map['gst'] ?? map['taxAmount']),

      serviceFee: _asDouble(map['serviceFee'] ?? map['platformFee']),

      discount: _asDouble(map['discount'] ?? map['discountAmount']),

      totalAmount: totalAmount,

      currency: _asString(map['currency'], fallback: 'INR').toUpperCase(),

      bookingStatus: bookingStatus,

      paymentStatus: _normalizePaymentStatus(map['paymentStatus']),

      paymentMethod:
          _asString(map['paymentMethod'], fallback: 'COD').toUpperCase(),

      paymentId: _asNullableString(map['paymentId']),

      transactionId: _asNullableString(map['transactionId']),

      notes: _asString(map['notes'] ?? map['specialInstructions']),

      address: _asString(map['address'], fallback: _asString(map['location'])),

      location: _asString(map['location'], fallback: _asString(map['address'])),

      landmark: _asString(map['landmark']),

      nearbyLocation: _asString(map['nearbyLocation']),

      longitude:
          locationCoordinates.length >= 2
              ? _asNullableDouble(locationCoordinates[0])
              : _asNullableDouble(map['longitude'] ?? map['lng']),

      latitude:
          locationCoordinates.length >= 2
              ? _asNullableDouble(locationCoordinates[1])
              : _asNullableDouble(map['latitude'] ?? map['lat']),

      chatRoomId: _asString(
        map['chatRoomId'],
        fallback: bookingId.isNotEmpty ? 'booking:$bookingId' : '',
      ),

      providerArrived: providerArrived,

      providerArrivedAt: _parseDate(map['providerArrivedAt']),

      providerArrivalLongitude:
          providerArrivalCoordinates.length >= 2
              ? _asNullableDouble(providerArrivalCoordinates[0])
              : null,

      providerArrivalLatitude:
          providerArrivalCoordinates.length >= 2
              ? _asNullableDouble(providerArrivalCoordinates[1])
              : null,

      providerArrivalDistanceMeters: _asNullableDouble(
        map['providerArrivalDistanceMeters'],
      ),

      providerArrivalVerified: _asBool(map['providerArrivalVerified']),

      otpVerified: otpVerified,

      otpVerifiedAt: _parseDate(map['otpVerifiedAt']),

      rejectionReason: _asString(map['rejectionReason']),

      cancellationReason: _asString(map['cancellationReason']),

      invoiceNumber: _asNullableString(map['invoiceNumber']),

      invoiceUrl: _asNullableString(map['invoiceUrl']),

      durationMinutes: _asInt(
        map['durationMinutes'] ?? map['serviceDurationMinutes'],
      ),

      acceptedAt: _parseDate(map['acceptedAt']),

      rejectedAt: _parseDate(map['rejectedAt']),

      startedAt: _parseDate(map['startedAt']),

      completedAt: _parseDate(map['completedAt']),

      cancelledAt: _parseDate(map['cancelledAt']),

      createdAt: _parseDate(map['createdAt']),

      updatedAt: _parseDate(map['updatedAt']),

      statusHistory: _asMapList(map['statusHistory']),
    );
  }

  factory BookingModel.fromJson(String source) {
    final decoded = jsonDecode(source);

    if (decoded is! Map) {
      throw const FormatException('Invalid booking JSON.');
    }

    return BookingModel.fromMap(_asMap(decoded));
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id,
      'id': id,
      'bookingId': id,

      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,

      'providerId': providerId,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'providerEmail': providerEmail,

      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceImage': serviceImage,

      'bookingNumber': bookingNumber,

      'bookingDate': bookingDate.toIso8601String(),

      'date': bookingDate.toIso8601String(),

      'bookingTime': bookingTime,

      'amount': amount,
      'gst': gst,
      'taxAmount': gst,

      'serviceFee': serviceFee,

      'platformFee': serviceFee,

      'discount': discount,

      'discountAmount': discount,

      'totalAmount': totalAmount,

      'totalPrice': totalAmount,

      'currency': currency,

      'bookingStatus': bookingStatus,

      'status': bookingStatus,

      'paymentStatus': paymentStatus,

      'paymentMethod': paymentMethod,

      'paymentId': paymentId,

      'transactionId': transactionId,

      'notes': notes,
      'address': address,
      'location': location,
      'landmark': landmark,

      'nearbyLocation': nearbyLocation,

      'latitude': latitude,

      'longitude': longitude,

      'locationPoint': <String, dynamic>{
        'type': 'Point',
        'coordinates': <double>[longitude ?? 0, latitude ?? 0],
      },

      'chatRoomId': effectiveChatRoomId,

      'providerArrived': providerArrived,

      'providerArrivedAt': providerArrivedAt?.toIso8601String(),

      'providerArrivalLocation': <String, dynamic>{
        'type': 'Point',
        'coordinates': <double>[
          providerArrivalLongitude ?? 0,
          providerArrivalLatitude ?? 0,
        ],
      },

      'providerArrivalDistanceMeters': providerArrivalDistanceMeters,

      'providerArrivalVerified': providerArrivalVerified,

      'otpVerified': otpVerified,

      'otpVerifiedAt': otpVerifiedAt?.toIso8601String(),

      'rejectionReason': rejectionReason,

      'cancellationReason': cancellationReason,

      'invoiceNumber': invoiceNumber,

      'invoiceUrl': invoiceUrl,

      'durationMinutes': durationMinutes,

      'acceptedAt': acceptedAt?.toIso8601String(),

      'rejectedAt': rejectedAt?.toIso8601String(),

      'startedAt': startedAt?.toIso8601String(),

      'completedAt': completedAt?.toIso8601String(),

      'cancelledAt': cancelledAt?.toIso8601String(),

      'createdAt': createdAt?.toIso8601String(),

      'updatedAt': updatedAt?.toIso8601String(),

      'statusHistory': statusHistory,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? providerId,
    String? providerName,
    String? providerPhone,
    String? providerEmail,
    String? serviceId,
    String? serviceName,
    String? serviceImage,
    String? bookingNumber,
    DateTime? bookingDate,
    String? bookingTime,
    double? amount,
    double? gst,
    double? serviceFee,
    double? discount,
    double? totalAmount,
    String? currency,
    String? bookingStatus,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentId,
    String? transactionId,
    String? notes,
    String? address,
    String? location,
    String? landmark,
    String? nearbyLocation,
    double? latitude,
    double? longitude,
    String? chatRoomId,
    bool? providerArrived,
    DateTime? providerArrivedAt,
    double? providerArrivalLatitude,
    double? providerArrivalLongitude,
    double? providerArrivalDistanceMeters,
    bool? providerArrivalVerified,
    bool? otpVerified,
    DateTime? otpVerifiedAt,
    String? rejectionReason,
    String? cancellationReason,
    String? invoiceNumber,
    String? invoiceUrl,
    int? durationMinutes,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? statusHistory,
  }) {
    return BookingModel(
      id: id ?? this.id,

      customerId: customerId ?? this.customerId,

      customerName: customerName ?? this.customerName,

      customerPhone: customerPhone ?? this.customerPhone,

      customerEmail: customerEmail ?? this.customerEmail,

      providerId: providerId ?? this.providerId,

      providerName: providerName ?? this.providerName,

      providerPhone: providerPhone ?? this.providerPhone,

      providerEmail: providerEmail ?? this.providerEmail,

      serviceId: serviceId ?? this.serviceId,

      serviceName: serviceName ?? this.serviceName,

      serviceImage: serviceImage ?? this.serviceImage,

      bookingNumber: bookingNumber ?? this.bookingNumber,

      bookingDate: bookingDate ?? this.bookingDate,

      bookingTime: bookingTime ?? this.bookingTime,

      amount: amount ?? this.amount,

      gst: gst ?? this.gst,

      serviceFee: serviceFee ?? this.serviceFee,

      discount: discount ?? this.discount,

      totalAmount: totalAmount ?? this.totalAmount,

      currency: currency ?? this.currency,

      bookingStatus: bookingStatus ?? this.bookingStatus,

      paymentStatus: paymentStatus ?? this.paymentStatus,

      paymentMethod: paymentMethod ?? this.paymentMethod,

      paymentId: paymentId ?? this.paymentId,

      transactionId: transactionId ?? this.transactionId,

      notes: notes ?? this.notes,

      address: address ?? this.address,

      location: location ?? this.location,

      landmark: landmark ?? this.landmark,

      nearbyLocation: nearbyLocation ?? this.nearbyLocation,

      latitude: latitude ?? this.latitude,

      longitude: longitude ?? this.longitude,

      chatRoomId: chatRoomId ?? this.chatRoomId,

      providerArrived: providerArrived ?? this.providerArrived,

      providerArrivedAt: providerArrivedAt ?? this.providerArrivedAt,

      providerArrivalLatitude:
          providerArrivalLatitude ?? this.providerArrivalLatitude,

      providerArrivalLongitude:
          providerArrivalLongitude ?? this.providerArrivalLongitude,

      providerArrivalDistanceMeters:
          providerArrivalDistanceMeters ?? this.providerArrivalDistanceMeters,

      providerArrivalVerified:
          providerArrivalVerified ?? this.providerArrivalVerified,

      otpVerified: otpVerified ?? this.otpVerified,

      otpVerifiedAt: otpVerifiedAt ?? this.otpVerifiedAt,

      rejectionReason: rejectionReason ?? this.rejectionReason,

      cancellationReason: cancellationReason ?? this.cancellationReason,

      invoiceNumber: invoiceNumber ?? this.invoiceNumber,

      invoiceUrl: invoiceUrl ?? this.invoiceUrl,

      durationMinutes: durationMinutes ?? this.durationMinutes,

      acceptedAt: acceptedAt ?? this.acceptedAt,

      rejectedAt: rejectedAt ?? this.rejectedAt,

      startedAt: startedAt ?? this.startedAt,

      completedAt: completedAt ?? this.completedAt,

      cancelledAt: cancelledAt ?? this.cancelledAt,

      createdAt: createdAt ?? this.createdAt,

      updatedAt: updatedAt ?? this.updatedAt,

      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  String get status {
    return normalizedStatus;
  }

  String get normalizedStatus {
    return _normalizeBookingStatus(bookingStatus);
  }

  bool get isPending {
    return normalizedStatus == 'pending';
  }

  bool get isAccepted {
    return normalizedStatus == 'accepted';
  }

  bool get isOtpVerified {
    return normalizedStatus == 'otp_verified' || otpVerified;
  }

  bool get isInProgress {
    return normalizedStatus == 'in_progress';
  }

  bool get isCompleted {
    return normalizedStatus == 'completed';
  }

  bool get isCancelled {
    return normalizedStatus == 'cancelled';
  }

  bool get isRejected {
    return normalizedStatus == 'rejected';
  }

  bool get isTerminal {
    return isCompleted || isCancelled || isRejected;
  }

  bool get isActive {
    return isPending || isAccepted || isOtpVerified || isInProgress;
  }

  bool get isPaid {
    return paymentStatus.trim().toLowerCase() == 'paid';
  }

  bool get canCustomerCancel {
    return isPending || isAccepted;
  }

  bool get canDisplayServiceOtp {
    return isAccepted && !otpVerified;
  }

  bool get shouldFetchServiceOtp {
    return isAccepted && !otpVerified;
  }

  bool get shouldShowProviderArrival {
    return isAccepted && providerArrived;
  }

  bool get shouldShowWaitingForProvider {
    return isAccepted && !providerArrived;
  }

  bool get shouldShowServiceInProgress {
    return isInProgress;
  }

  bool get canRate {
    return isCompleted;
  }

  bool get canViewInvoice {
    return isCompleted;
  }

  bool get canProviderAccept {
    return isPending;
  }

  bool get canProviderReject {
    return isPending;
  }

  bool get canProviderMarkArrived {
    return isAccepted && !providerArrived;
  }

  bool get canVerifyOtp {
    return isAccepted && providerArrived && !otpVerified;
  }

  bool get canStart {
    return normalizedStatus == 'otp_verified' && providerArrived && otpVerified;
  }

  bool get canComplete {
    return isInProgress;
  }

  bool get hasLocation {
    return latitude != null &&
        longitude != null &&
        !(latitude == 0 && longitude == 0);
  }

  bool get hasProviderArrivalLocation {
    return providerArrivalLatitude != null &&
        providerArrivalLongitude != null &&
        !(providerArrivalLatitude == 0 && providerArrivalLongitude == 0);
  }

  bool get hasInvoice {
    return (invoiceNumber != null && invoiceNumber!.trim().isNotEmpty) ||
        (invoiceUrl != null && invoiceUrl!.trim().isNotEmpty);
  }

  bool get hasChatRoom {
    return effectiveChatRoomId.isNotEmpty;
  }

  String get effectiveChatRoomId {
    final roomId = chatRoomId.trim();

    if (roomId.isNotEmpty) {
      if (roomId.startsWith('booking:')) {
        return roomId;
      }

      if (roomId == id) {
        return 'booking:$roomId';
      }

      return roomId;
    }

    final bookingId = id.trim();

    if (bookingId.isNotEmpty) {
      return 'booking:$bookingId';
    }

    return '';
  }

  String get displayBookingNumber {
    final number = bookingNumber.trim();

    if (number.isNotEmpty) {
      return number;
    }

    final bookingId = id.trim();

    if (bookingId.isEmpty) {
      return '';
    }

    if (bookingId.length <= 8) {
      return bookingId.toUpperCase();
    }

    return 'EB-${bookingId.substring(bookingId.length - 8).toUpperCase()}';
  }

  String get displayProviderName {
    final name = providerName.trim();

    return name.isEmpty ? 'Service Provider' : name;
  }

  String get displayServiceName {
    final name = serviceName.trim();

    return name.isEmpty ? 'Service' : name;
  }

  String get statusText {
    switch (normalizedStatus) {
      case 'pending':
        return 'Waiting for Provider';

      case 'accepted':
        return providerArrived ? 'Provider Arrived' : 'Provider Accepted';

      case 'otp_verified':
        return 'OTP Verified';

      case 'in_progress':
        return 'Service In Progress';

      case 'completed':
        return 'Service Completed';

      case 'rejected':
        return 'Booking Rejected';

      case 'cancelled':
        return 'Booking Cancelled';

      default:
        final text = normalizedStatus.replaceAll('_', ' ').trim();

        return text.isEmpty ? 'Booking Status' : text;
    }
  }

  String get statusDescription {
    if (isPending) {
      return 'Waiting for the Provider to accept or reject your booking.';
    }

    if (isAccepted && !providerArrived) {
      return 'The Provider accepted your booking. '
          'Your service OTP is available, but share it only after the Provider arrives.';
    }

    if (isAccepted && providerArrived) {
      return 'The Provider has arrived. '
          'Confirm the Provider identity and share the service OTP.';
    }

    if (isOtpVerified) {
      return 'The service OTP was verified. '
          'Waiting for the Provider to start the work.';
    }

    if (isInProgress) {
      return 'The service is currently in progress.';
    }

    if (isCompleted) {
      return 'The service was completed. '
          'You can view the invoice and rate the service.';
    }

    if (isRejected) {
      final reason = rejectionReason.trim();

      return reason.isNotEmpty
          ? 'The Provider rejected this booking: $reason'
          : 'The Provider rejected this booking.';
    }

    if (isCancelled) {
      final reason = cancellationReason.trim();

      return reason.isNotEmpty
          ? 'This booking was cancelled: $reason'
          : 'This booking was cancelled.';
    }

    return statusText;
  }

  DateTime get lastActivityAt {
    return updatedAt ??
        completedAt ??
        startedAt ??
        otpVerifiedAt ??
        providerArrivedAt ??
        acceptedAt ??
        rejectedAt ??
        cancelledAt ??
        createdAt ??
        bookingDate;
  }

  @override
  String toString() {
    return 'BookingModel('
        'id: $id, '
        'bookingNumber: $bookingNumber, '
        'status: $bookingStatus, '
        'providerArrived: $providerArrived, '
        'otpVerified: $otpVerified'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is BookingModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
