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

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.booking:
        return 'booking';

      case NotificationType.order:
        return 'order';

      case NotificationType.payment:
        return 'payment';

      case NotificationType.review:
        return 'review';

      case NotificationType.chat:
        return 'chat';

      case NotificationType.system:
        return 'system';

      case NotificationType.promotion:
        return 'promotion';

      case NotificationType.support:
        return 'support';
    }
  }

  String get label {
    switch (this) {
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

  static NotificationType fromString(dynamic value) {
    final type = value?.toString().toLowerCase().trim() ?? '';

    switch (type) {
      case 'booking':
        return NotificationType.booking;

      case 'order':
        return NotificationType.order;

      case 'payment':
        return NotificationType.payment;

      case 'review':
        return NotificationType.review;

      case 'chat':
      case 'message':
        return NotificationType.chat;

      case 'promotion':
      case 'promo':
        return NotificationType.promotion;

      case 'support':
      case 'help':
        return NotificationType.support;

      case 'system':
      default:
        return NotificationType.system;
    }
  }
}

class NotificationModel {
  final String id;

  final String userId;

  final String title;
  final String message;

  /// ✅ Kept as String because your screens use:
  /// notification.type
  /// _typeColor(notification.type)
  /// _typeIcon(notification.type)
  final String type;

  final String imageUrl;

  final String referenceId;

  final String route;

  final bool isRead;

  final bool isDeleted;

  final Map<String, dynamic>? data;

  /// ✅ Kept as String because your screens use:
  /// notification.createdAt ?? ''
  final String createdAt;

  final String readAt;

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
    required this.readAt,
  });

  factory NotificationModel.empty() {
    return const NotificationModel(
      id: '',
      userId: '',
      title: '',
      message: '',
      type: 'system',
      imageUrl: '',
      referenceId: '',
      route: '',
      isRead: false,
      isDeleted: false,
      data: {},
      createdAt: '',
      readAt: '',
    );
  }

  factory NotificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final parsedData = _asMap(json['data']);

    return NotificationModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      userId: json['userId']?.toString() ??
          json['user']?.toString() ??
          json['receiverId']?.toString() ??
          '',

      title: json['title']?.toString() ?? '',

      message: json['message']?.toString() ??
          json['body']?.toString() ??
          json['description']?.toString() ??
          '',

      type: json['type']?.toString().toLowerCase().trim() ??
          'system',

      imageUrl: json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          '',

      referenceId: json['referenceId']?.toString() ??
          json['refId']?.toString() ??
          json['bookingId']?.toString() ??
          json['orderId']?.toString() ??
          '',

      route: json['route']?.toString() ??
          json['screen']?.toString() ??
          '',

      isRead: _toBool(
        json['isRead'] ??
            json['read'],
      ),

      isDeleted: _toBool(
        json['isDeleted'] ??
            json['deleted'],
      ),

      data: parsedData ?? {},

      createdAt: json['createdAt']?.toString() ??
          json['date']?.toString() ??
          '',

      readAt: json['readAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,

      'userId': userId,

      'title': title,
      'message': message,

      'type': type,

      'imageUrl': imageUrl,

      'referenceId': referenceId,

      'route': route,

      'isRead': isRead,
      'isDeleted': isDeleted,

      'data': data,

      'createdAt': createdAt,
      'readAt': readAt,
    };
  }

  static NotificationType _parseType(
    dynamic value,
  ) {
    return NotificationTypeExtension.fromString(value);
  }

  /// ✅ Enum support preserved
  NotificationType get typeEnum {
    return _parseType(type);
  }

  String get typeText {
    return typeEnum.label;
  }

  DateTime? get createdAtDateTime {
    return _toDateTime(createdAt);
  }

  DateTime? get readAtDateTime {
    return _toDateTime(readAt);
  }

  bool get isBookingNotification {
    return type.toLowerCase() == 'booking';
  }

  bool get isOrderNotification {
    return type.toLowerCase() == 'order';
  }

  bool get isPaymentNotification {
    return type.toLowerCase() == 'payment';
  }

  bool get isReviewNotification {
    return type.toLowerCase() == 'review';
  }

  bool get isChatNotification {
    return type.toLowerCase() == 'chat' ||
        type.toLowerCase() == 'message';
  }

  bool get isPromotionNotification {
    return type.toLowerCase() == 'promotion' ||
        type.toLowerCase() == 'promo';
  }

  bool get isSupportNotification {
    return type.toLowerCase() == 'support' ||
        type.toLowerCase() == 'help';
  }

  bool get isSystemNotification {
    return type.toLowerCase() == 'system';
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? imageUrl,
    String? referenceId,
    String? route,
    bool? isRead,
    bool? isDeleted,
    Map<String, dynamic>? data,
    String? createdAt,
    String? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      referenceId: referenceId ?? this.referenceId,
      route: route ?? this.route,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
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
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}