enum NotificationType {
  booking,
  order,
  payment,
  review,
  chat,
  system,
  promotion,
  support,
}

class NotificationModel {
  final String id;

  final String userId;

  final String title;
  final String message;

  final NotificationType type;

  final String imageUrl;

  final String referenceId;

  final String route;

  final bool isRead;

  final bool isDeleted;

  final Map<String, dynamic>? data;

  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.imageUrl,
    required this.referenceId,
    required this.route,
    required this.isRead,
    required this.isDeleted,
    this.data,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.empty() {
    return NotificationModel(
      id: '',
      userId: '',
      title: '',
      message: '',
      type: NotificationType.system,
      imageUrl: '',
      referenceId: '',
      route: '',
      isRead: false,
      isDeleted: false,
      data: const {},
      createdAt: DateTime.now(),
    );
  }

  factory NotificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      userId:
          json['userId']?.toString() ?? '',
      title:
          json['title']?.toString() ?? '',
      message:
          json['message']?.toString() ?? '',
      type: _parseType(
        json['type'],
      ),
      imageUrl:
          json['imageUrl']?.toString() ?? '',
      referenceId:
          json['referenceId']?.toString() ??
              '',
      route:
          json['route']?.toString() ?? '',
      isRead:
          json['isRead'] ?? false,
      isDeleted:
          json['isDeleted'] ?? false,
      data:
          json['data'] != null
              ? Map<String, dynamic>.from(
                  json['data'],
                )
              : {},
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(
                  json['createdAt']
                      .toString(),
                )
              : DateTime.now(),
      readAt:
          json['readAt'] != null
              ? DateTime.tryParse(
                  json['readAt']
                      .toString(),
                )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'imageUrl': imageUrl,
      'referenceId': referenceId,
      'route': route,
      'isRead': isRead,
      'isDeleted': isDeleted,
      'data': data,
      'createdAt':
          createdAt.toIso8601String(),
      'readAt':
          readAt?.toIso8601String(),
    };
  }

  static NotificationType _parseType(
    dynamic value,
  ) {
    switch (
        value.toString().toLowerCase()) {
      case 'booking':
        return NotificationType.booking;

      case 'order':
        return NotificationType.order;

      case 'payment':
        return NotificationType.payment;

      case 'review':
        return NotificationType.review;

      case 'chat':
        return NotificationType.chat;

      case 'promotion':
        return NotificationType.promotion;

      case 'support':
        return NotificationType.support;

      default:
        return NotificationType.system;
    }
  }

  String get typeText {
    switch (type) {
      case NotificationType.booking:
        return 'Booking';

      case NotificationType.order:
        return 'Order';

      case NotificationType.payment:
        return 'Payment';

      case NotificationType.review:
        return 'Review';

      case NotificationType.chat:
        return 'Chat';

      case NotificationType.system:
        return 'System';

      case NotificationType.promotion:
        return 'Promotion';

      case NotificationType.support:
        return 'Support';
    }
  }

  bool get isBookingNotification =>
      type == NotificationType.booking;

  bool get isOrderNotification =>
      type == NotificationType.order;

  bool get isPaymentNotification =>
      type == NotificationType.payment;

  bool get isReviewNotification =>
      type == NotificationType.review;

  bool get isChatNotification =>
      type == NotificationType.chat;

  bool get isPromotionNotification =>
      type == NotificationType.promotion;

  bool get isSupportNotification =>
      type == NotificationType.support;

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    String? imageUrl,
    String? referenceId,
    String? route,
    bool? isRead,
    bool? isDeleted,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      referenceId:
          referenceId ?? this.referenceId,
      route: route ?? this.route,
      isRead: isRead ?? this.isRead,
      isDeleted:
          isDeleted ?? this.isDeleted,
      data: data ?? this.data,
      createdAt:
          createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel('
        'id: $id, '
        'title: $title'
        ')';
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