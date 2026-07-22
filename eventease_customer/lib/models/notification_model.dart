import 'dart:convert';

class NotificationModel {
  final String id;

  final String userId;

  final String title;
  final String message;

  /// booking | order | payment | chat | system | promotion
  final String type;

  final String? referenceId;

  final String? image;

  final bool isRead;

  /// route path for navigation
  final String? redirectScreen;

  final Map<String, dynamic>? metadata;

  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    this.image,
    this.isRead = false,
    this.redirectScreen,
    this.metadata,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // EMPTY
  // ==========================================

  factory NotificationModel.empty() {
    return const NotificationModel(
      id: '',
      userId: '',
      title: '',
      message: '',
      type: 'system',
    );
  }

  // ==========================================
  // COPY WITH
  // ==========================================

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? referenceId,
    String? image,
    bool? isRead,
    String? redirectScreen,
    Map<String, dynamic>? metadata,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      image: image ?? this.image,
      isRead: isRead ?? this.isRead,
      redirectScreen:
          redirectScreen ?? this.redirectScreen,
      metadata: metadata ?? this.metadata,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // FROM MAP
  // ==========================================

  factory NotificationModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return NotificationModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      userId:
          map['userId']?.toString() ?? '',

      title:
          map['title'] ?? '',

      message:
          map['message'] ?? '',

      type:
          map['type'] ?? 'system',

      referenceId:
          map['referenceId']?.toString(),

      image:
          map['image'],

      isRead:
          map['isRead'] ?? false,

      redirectScreen:
          map['redirectScreen'],

      metadata:
          map['metadata'] != null
              ? Map<String, dynamic>.from(
                  map['metadata'],
                )
              : null,

      readAt:
          map['readAt'] != null
              ? DateTime.tryParse(
                  map['readAt'],
                )
              : null,

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
      'title': title,
      'message': message,
      'type': type,
      'referenceId': referenceId,
      'image': image,
      'isRead': isRead,
      'redirectScreen': redirectScreen,
      'metadata': metadata,
      'readAt': readAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // ==========================================
  // JSON
  // ==========================================

  factory NotificationModel.fromJson(
    String source,
  ) {
    return NotificationModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // ==========================================
  // HELPERS
  // ==========================================

  bool get isBookingNotification =>
      type.toLowerCase() == 'booking';

  bool get isOrderNotification =>
      type.toLowerCase() == 'order';

  bool get isPaymentNotification =>
      type.toLowerCase() == 'payment';

  bool get isChatNotification =>
      type.toLowerCase() == 'chat';

  bool get isPromotionNotification =>
      type.toLowerCase() == 'promotion';

  bool get isSystemNotification =>
      type.toLowerCase() == 'system';

  bool get hasImage =>
      image != null &&
      image!.isNotEmpty;

  bool get hasRedirect =>
      redirectScreen != null &&
      redirectScreen!.isNotEmpty;

  // ==========================================
  // OVERRIDES
  // ==========================================

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NotificationModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
