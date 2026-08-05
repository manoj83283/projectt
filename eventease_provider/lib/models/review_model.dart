enum ReviewStatus {
  pending,
  approved,
  rejected,
}

extension ReviewStatusExtension on ReviewStatus {
  String get value {
    switch (this) {
      case ReviewStatus.pending:
        return 'pending';

      case ReviewStatus.approved:
        return 'approved';

      case ReviewStatus.rejected:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case ReviewStatus.pending:
        return 'Pending';

      case ReviewStatus.approved:
        return 'Approved';

      case ReviewStatus.rejected:
        return 'Rejected';
    }
  }

  static ReviewStatus fromString(dynamic value) {
    final status = value?.toString().toLowerCase().trim() ?? '';

    switch (status) {
      case 'approved':
        return ReviewStatus.approved;

      case 'rejected':
        return ReviewStatus.rejected;

      case 'pending':
      default:
        return ReviewStatus.pending;
    }
  }
}

class ReviewModel {
  final String id;

  final String bookingId;
  final String orderId;

  final String customerId;
  final String customerName;
  final String customerImage;

  final String providerId;
  final String providerName;

  final String serviceId;
  final String serviceName;

  final double rating;

  final String title;
  final String comment;

  final List<String> images;

  final int likesCount;

  final bool isEdited;

  final bool providerReplied;

  final String providerReply;

  /// ✅ Kept as String because screens may directly display status/title
  final String status;

  /// ✅ Kept as String because your screens use:
  /// review.createdAt ?? ''
  final String reviewDate;

  final String replyDate;

  final String createdAt;
  final String updatedAt;

  final Map<String, dynamic>? rawUser;
  final Map<String, dynamic>? rawCustomer;
  final Map<String, dynamic>? rawProvider;
  final Map<String, dynamic>? rawService;
  final Map<String, dynamic>? rawBooking;
  final Map<String, dynamic>? rawOrder;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.customerImage,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.rating,
    required this.title,
    required this.comment,
    required this.images,
    required this.likesCount,
    required this.isEdited,
    required this.providerReplied,
    required this.providerReply,
    required this.status,
    required this.reviewDate,
    required this.replyDate,
    required this.createdAt,
    required this.updatedAt,
    this.rawUser,
    this.rawCustomer,
    this.rawProvider,
    this.rawService,
    this.rawBooking,
    this.rawOrder,
  });

  factory ReviewModel.empty() {
    return const ReviewModel(
      id: '',
      bookingId: '',
      orderId: '',
      customerId: '',
      customerName: '',
      customerImage: '',
      providerId: '',
      providerName: '',
      serviceId: '',
      serviceName: '',
      rating: 0,
      title: '',
      comment: '',
      images: [],
      likesCount: 0,
      isEdited: false,
      providerReplied: false,
      providerReply: '',
      status: 'pending',
      reviewDate: '',
      replyDate: '',
      createdAt: '',
      updatedAt: '',
    );
  }

  factory ReviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final user = _asMap(json['user']);

    final customer = _asMap(json['customer']) ?? user;

    final provider = _asMap(json['provider']);

    final service = _asMap(json['service']);

    final booking = _asMap(json['booking']);

    final order = _asMap(json['order']);

    final customerFirstName = customer?['firstName']?.toString() ?? '';
    final customerLastName = customer?['lastName']?.toString() ?? '';
    final customerFullName = customer?['name']?.toString() ?? '';

    final parsedCustomerName = customerFullName.isNotEmpty
        ? customerFullName
        : '$customerFirstName $customerLastName'.trim();

    final parsedBookingId = booking?['_id']?.toString() ??
        booking?['id']?.toString() ??
        json['bookingId']?.toString() ??
        json['booking']?.toString() ??
        '';

    final parsedOrderId = order?['_id']?.toString() ??
        order?['id']?.toString() ??
        json['orderId']?.toString() ??
        json['order']?.toString() ??
        '';

    final parsedCustomerId = customer?['_id']?.toString() ??
        customer?['id']?.toString() ??
        json['customerId']?.toString() ??
        json['userId']?.toString() ??
        json['customer']?.toString() ??
        json['user']?.toString() ??
        '';

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

    final dynamic rawImages = json['images'];

    List<String> parsedImages = [];

    if (rawImages is List) {
      parsedImages = rawImages
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    final parsedComment = json['comment']?.toString() ??
        json['review']?.toString() ??
        json['message']?.toString() ??
        '';

    final parsedReply = json['providerReply']?.toString() ??
        json['reply']?.toString() ??
        json['response']?.toString() ??
        '';

    return ReviewModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      bookingId: parsedBookingId,

      orderId: parsedOrderId,

      customerId: parsedCustomerId,

      customerName: json['customerName']?.toString() ??
          parsedCustomerName,

      customerImage: json['customerImage']?.toString() ??
          customer?['image']?.toString() ??
          customer?['profileImage']?.toString() ??
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

      rating: _toDouble(
        json['rating'],
      ),

      title: json['title']?.toString() ?? '',

      comment: parsedComment,

      images: parsedImages,

      likesCount: _toInt(
        json['likesCount'] ??
            json['likes'] ??
            0,
      ),

      isEdited: _toBool(
        json['isEdited'],
      ),

      providerReplied: _toBool(
        json['providerReplied'] ??
            (parsedReply.isNotEmpty),
      ),

      providerReply: parsedReply,

      status: json['status']?.toString().toLowerCase().trim() ??
          'pending',

      reviewDate: json['reviewDate']?.toString() ??
          json['createdAt']?.toString() ??
          '',

      replyDate: json['replyDate']?.toString() ??
          json['repliedAt']?.toString() ??
          '',

      createdAt: json['createdAt']?.toString() ?? '',

      updatedAt: json['updatedAt']?.toString() ?? '',

      rawUser: user,
      rawCustomer: customer,
      rawProvider: provider,
      rawService: service,
      rawBooking: booking,
      rawOrder: order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,

      'bookingId': bookingId,
      'orderId': orderId,

      'customerId': customerId,
      'customerName': customerName,
      'customerImage': customerImage,

      'providerId': providerId,
      'providerName': providerName,

      'serviceId': serviceId,
      'serviceName': serviceName,

      'rating': rating,

      'title': title,
      'comment': comment,
      'review': comment,

      'images': images,

      'likesCount': likesCount,

      'isEdited': isEdited,

      'providerReplied': providerReplied,
      'providerReply': providerReply,
      'reply': providerReply,

      'status': status,

      'reviewDate': reviewDate,
      'replyDate': replyDate,

      'createdAt': createdAt,
      'updatedAt': updatedAt,

      'user': rawUser,
      'customer': rawCustomer,
      'provider': rawProvider,
      'service': rawService,
      'booking': rawBooking,
      'order': rawOrder,
    };
  }

  static ReviewStatus _parseStatus(
    dynamic value,
  ) {
    return ReviewStatusExtension.fromString(value);
  }

  ReviewStatus get statusEnum {
    return _parseStatus(status);
  }

  String get statusText {
    return statusEnum.label;
  }

  /// ✅ Fixes: review.reply
  String get reply {
    return providerReply;
  }

  /// ✅ Optional alias for UI
  String get review {
    return comment;
  }

  DateTime? get reviewDateTime {
    return _toDateTime(reviewDate);
  }

  DateTime? get replyDateTime {
    return _toDateTime(replyDate);
  }

  DateTime? get createdAtDateTime {
    return _toDateTime(createdAt);
  }

  DateTime? get updatedAtDateTime {
    return _toDateTime(updatedAt);
  }

  bool get isApproved {
    return status.toLowerCase() == 'approved';
  }

  bool get isRejected {
    return status.toLowerCase() == 'rejected';
  }

  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  bool get isFiveStar {
    return rating >= 5;
  }

  bool get hasImages {
    return images.isNotEmpty;
  }

  bool get hasReply {
    return providerReply.trim().isNotEmpty;
  }

  ReviewModel copyWith({
    String? id,
    String? bookingId,
    String? orderId,
    String? customerId,
    String? customerName,
    String? customerImage,
    String? providerId,
    String? providerName,
    String? serviceId,
    String? serviceName,
    double? rating,
    String? title,
    String? comment,
    List<String>? images,
    int? likesCount,
    bool? isEdited,
    bool? providerReplied,
    String? providerReply,
    String? status,
    String? reviewDate,
    String? replyDate,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? rawUser,
    Map<String, dynamic>? rawCustomer,
    Map<String, dynamic>? rawProvider,
    Map<String, dynamic>? rawService,
    Map<String, dynamic>? rawBooking,
    Map<String, dynamic>? rawOrder,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerImage: customerImage ?? this.customerImage,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      likesCount: likesCount ?? this.likesCount,
      isEdited: isEdited ?? this.isEdited,
      providerReplied:
          providerReplied ?? this.providerReplied,
      providerReply:
          providerReply ?? this.providerReply,
      status: status ?? this.status,
      reviewDate: reviewDate ?? this.reviewDate,
      replyDate: replyDate ?? this.replyDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rawUser: rawUser ?? this.rawUser,
      rawCustomer: rawCustomer ?? this.rawCustomer,
      rawProvider: rawProvider ?? this.rawProvider,
      rawService: rawService ?? this.rawService,
      rawBooking: rawBooking ?? this.rawBooking,
      rawOrder: rawOrder ?? this.rawOrder,
    );
  }

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

  static bool _toBool(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    final text = value.toString().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes';
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
        other is ReviewModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating, status: $status)';
  }
}