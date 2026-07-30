enum ReviewStatus {
  pending,
  approved,
  rejected,
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

  final ReviewStatus status;

  final DateTime reviewDate;

  final DateTime? replyDate;

  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.replyDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.empty() {
    return ReviewModel(
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
      images: const [],
      likesCount: 0,
      isEdited: false,
      providerReplied: false,
      providerReply: '',
      status: ReviewStatus.pending,
      reviewDate: DateTime.now(),
    );
  }

  factory ReviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReviewModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      bookingId:
          json['bookingId']?.toString() ??
              '',
      orderId:
          json['orderId']?.toString() ??
              '',
      customerId:
          json['customerId']?.toString() ??
              '',
      customerName:
          json['customerName']?.toString() ??
              '',
      customerImage:
          json['customerImage']?.toString() ??
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
      rating:
          (json['rating'] ?? 0).toDouble(),
      title:
          json['title']?.toString() ?? '',
      comment:
          json['comment']?.toString() ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      likesCount:
          json['likesCount'] ?? 0,
      isEdited:
          json['isEdited'] ?? false,
      providerReplied:
          json['providerReplied'] ?? false,
      providerReply:
          json['providerReply']?.toString() ??
              '',
      status: _parseStatus(
        json['status'],
      ),
      reviewDate:
          json['reviewDate'] != null
              ? DateTime.parse(
                  json['reviewDate']
                      .toString(),
                )
              : DateTime.now(),
      replyDate:
          json['replyDate'] != null
              ? DateTime.tryParse(
                  json['replyDate']
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
      'images': images,
      'likesCount': likesCount,
      'isEdited': isEdited,
      'providerReplied': providerReplied,
      'providerReply': providerReply,
      'status': status.name,
      'reviewDate':
          reviewDate.toIso8601String(),
      'replyDate':
          replyDate?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  static ReviewStatus _parseStatus(
    dynamic value,
  ) {
    switch (
        value.toString().toLowerCase()) {
      case 'approved':
        return ReviewStatus.approved;

      case 'rejected':
        return ReviewStatus.rejected;

      default:
        return ReviewStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case ReviewStatus.pending:
        return 'Pending';

      case ReviewStatus.approved:
        return 'Approved';

      case ReviewStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isApproved =>
      status == ReviewStatus.approved;

  bool get isRejected =>
      status == ReviewStatus.rejected;

  bool get isPending =>
      status == ReviewStatus.pending;

  bool get isFiveStar => rating >= 5;

  bool get hasImages =>
      images.isNotEmpty;

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
    ReviewStatus? status,
    DateTime? reviewDate,
    DateTime? replyDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      bookingId:
          bookingId ?? this.bookingId,
      orderId:
          orderId ?? this.orderId,
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
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment:
          comment ?? this.comment,
      images: images ?? this.images,
      likesCount:
          likesCount ?? this.likesCount,
      isEdited:
          isEdited ?? this.isEdited,
      providerReplied:
          providerReplied ??
              this.providerReplied,
      providerReply:
          providerReply ??
              this.providerReply,
      status: status ?? this.status,
      reviewDate:
          reviewDate ?? this.reviewDate,
      replyDate:
          replyDate ?? this.replyDate,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReviewModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating)';
  }
}