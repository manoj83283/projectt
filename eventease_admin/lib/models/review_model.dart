class ReviewModel {
  final String id;

  final String customerId;
  final String customerName;
  final String? customerImage;

  final String providerId;
  final String providerName;

  final String serviceId;
  final String serviceName;

  final String bookingId;

  final double rating;

  final String review;

  final List<String> images;

  final bool isApproved;
  final bool isHidden;

  final int likesCount;

  final String? adminReply;
  final DateTime? adminReplyAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerImage,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
    required this.bookingId,
    required this.rating,
    required this.review,
    required this.images,
    required this.isApproved,
    required this.isHidden,
    required this.likesCount,
    this.adminReply,
    this.adminReplyAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReviewModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      customerId:
          json['customerId']?.toString() ??
              '',

      customerName:
          json['customerName']
                  ?.toString() ??
              '',

      customerImage:
          json['customerImage']
              ?.toString(),

      providerId:
          json['providerId']?.toString() ??
              '',

      providerName:
          json['providerName']
                  ?.toString() ??
              '',

      serviceId:
          json['serviceId']?.toString() ??
              '',

      serviceName:
          json['serviceName']
                  ?.toString() ??
              '',

      bookingId:
          json['bookingId']?.toString() ??
              '',

      rating:
          (json['rating'] ?? 0)
              .toDouble(),

      review:
          json['review']?.toString() ??
              '',

      images:
          (json['images'] as List?)
                  ?.map(
                    (e) => e.toString(),
                  )
                  .toList() ??
              [],

      isApproved:
          json['isApproved'] ?? false,

      isHidden:
          json['isHidden'] ?? false,

      likesCount:
          json['likesCount'] ?? 0,

      adminReply:
          json['adminReply']
              ?.toString(),

      adminReplyAt:
          json['adminReplyAt'] != null
              ? DateTime.tryParse(
                  json['adminReplyAt']
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
      'customerId': customerId,
      'customerName': customerName,
      'customerImage': customerImage,
      'providerId': providerId,
      'providerName': providerName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'bookingId': bookingId,
      'rating': rating,
      'review': review,
      'images': images,
      'isApproved': isApproved,
      'isHidden': isHidden,
      'likesCount': likesCount,
      'adminReply': adminReply,
      'adminReplyAt':
          adminReplyAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerImage,
    String? providerId,
    String? providerName,
    String? serviceId,
    String? serviceName,
    String? bookingId,
    double? rating,
    String? review,
    List<String>? images,
    bool? isApproved,
    bool? isHidden,
    int? likesCount,
    String? adminReply,
    DateTime? adminReplyAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      customerId:
          customerId ?? this.customerId,
      customerName:
          customerName ??
              this.customerName,
      customerImage:
          customerImage ??
              this.customerImage,
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
      bookingId:
          bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      images: images ?? this.images,
      isApproved:
          isApproved ?? this.isApproved,
      isHidden:
          isHidden ?? this.isHidden,
      likesCount:
          likesCount ?? this.likesCount,
      adminReply:
          adminReply ?? this.adminReply,
      adminReplyAt:
          adminReplyAt ??
              this.adminReplyAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isFiveStar => rating == 5;

  bool get isFourStarOrAbove =>
      rating >= 4;

  bool get hasImages =>
      images.isNotEmpty;

  bool get hasAdminReply =>
      adminReply != null &&
      adminReply!.isNotEmpty;

  bool get isVisible =>
      !isHidden && isApproved;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReviewModel('
        'id: $id, '
        'rating: $rating, '
        'serviceName: $serviceName'
        ')';
  }
}