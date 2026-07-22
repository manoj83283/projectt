import 'dart:convert';

class ReviewModel {
  final String id;

  final String userId;
  final String userName;
  final String? userImage;

  final String serviceId;
  final String serviceName;

  final String providerId;
  final String providerName;

  final String comment;

  final double rating;

  final List<String> images;

  final bool isVerifiedBooking;

  final String? adminReply;
  final DateTime? adminReplyDate;

  final int likesCount;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.serviceId,
    required this.serviceName,
    required this.providerId,
    required this.providerName,
    required this.comment,
    required this.rating,
    this.userImage,
    this.images = const [],
    this.isVerifiedBooking = false,
    this.adminReply,
    this.adminReplyDate,
    this.likesCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // EMPTY
  // ==========================================

  factory ReviewModel.empty() {
    return const ReviewModel(
      id: '',
      userId: '',
      userName: '',
      serviceId: '',
      serviceName: '',
      providerId: '',
      providerName: '',
      comment: '',
      rating: 0,
    );
  }

  // ==========================================
  // COPY WITH
  // ==========================================

  ReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImage,
    String? serviceId,
    String? serviceName,
    String? providerId,
    String? providerName,
    String? comment,
    double? rating,
    List<String>? images,
    bool? isVerifiedBooking,
    String? adminReply,
    DateTime? adminReplyDate,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      images: images ?? this.images,
      isVerifiedBooking:
          isVerifiedBooking ?? this.isVerifiedBooking,
      adminReply: adminReply ?? this.adminReply,
      adminReplyDate:
          adminReplyDate ?? this.adminReplyDate,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // FROM MAP
  // ==========================================

  factory ReviewModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ReviewModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      userId:
          map['userId']?.toString() ?? '',

      userName:
          map['userName'] ?? '',

      userImage:
          map['userImage'],

      serviceId:
          map['serviceId']?.toString() ?? '',

      serviceName:
          map['serviceName'] ?? '',

      providerId:
          map['providerId']?.toString() ?? '',

      providerName:
          map['providerName'] ?? '',

      comment:
          map['comment'] ?? '',

      rating:
          (map['rating'] as num?)
                  ?.toDouble() ??
              0.0,

      images: map['images'] != null
          ? List<String>.from(map['images'])
          : [],

      isVerifiedBooking:
          map['isVerifiedBooking'] ?? false,

      adminReply:
          map['adminReply'],

      adminReplyDate:
          map['adminReplyDate'] != null
              ? DateTime.tryParse(
                  map['adminReplyDate'],
                )
              : null,

      likesCount:
          map['likesCount'] ?? 0,

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

  // ==========================================
  // TO MAP
  // ==========================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'providerId': providerId,
      'providerName': providerName,
      'comment': comment,
      'rating': rating,
      'images': images,
      'isVerifiedBooking': isVerifiedBooking,
      'adminReply': adminReply,
      'adminReplyDate':
          adminReplyDate?.toIso8601String(),
      'likesCount': likesCount,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // ==========================================
  // JSON
  // ==========================================

  factory ReviewModel.fromJson(
    String source,
  ) {
    return ReviewModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // ==========================================
  // GETTERS
  // ==========================================

  bool get hasImages =>
      images.isNotEmpty;

  bool get hasAdminReply =>
      adminReply != null &&
      adminReply!.isNotEmpty;

  bool get isFiveStar =>
      rating == 5;

  bool get isFourStarOrAbove =>
      rating >= 4;

  bool get hasUserImage =>
      userImage != null &&
      userImage!.isNotEmpty;

  String get ratingText =>
      rating.toStringAsFixed(1);

  // ==========================================
  // OVERRIDES
  // ==========================================

  @override
  String toString() {
    return 'ReviewModel(id: $id, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReviewModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}