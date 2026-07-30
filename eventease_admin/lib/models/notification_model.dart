class NotificationModel {
  final String id;

  final String title;
  final String message;

  final String notificationType;

  final String? imageUrl;

  final String? receiverId;
  final String? receiverType;

  final String? topic;

  final String? actionType;
  final String? actionId;

  final bool isRead;
  final bool isSent;
  final bool isDelivered;

  final int totalRecipients;
  final int deliveredCount;
  final int openedCount;

  final DateTime? scheduledAt;
  final DateTime? sentAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    this.imageUrl,
    this.receiverId,
    this.receiverType,
    this.topic,
    this.actionType,
    this.actionId,
    required this.isRead,
    required this.isSent,
    required this.isDelivered,
    required this.totalRecipients,
    required this.deliveredCount,
    required this.openedCount,
    this.scheduledAt,
    this.sentAt,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      title:
          json['title']?.toString() ?? '',

      message:
          json['message']?.toString() ??
              '',

      notificationType:
          json['notificationType']
                  ?.toString() ??
              'general',

      imageUrl:
          json['imageUrl']?.toString(),

      receiverId:
          json['receiverId']
              ?.toString(),

      receiverType:
          json['receiverType']
              ?.toString(),

      topic:
          json['topic']?.toString(),

      actionType:
          json['actionType']
              ?.toString(),

      actionId:
          json['actionId']
              ?.toString(),

      isRead:
          json['isRead'] ?? false,

      isSent:
          json['isSent'] ?? false,

      isDelivered:
          json['isDelivered'] ?? false,

      totalRecipients:
          json['totalRecipients'] ?? 0,

      deliveredCount:
          json['deliveredCount'] ?? 0,

      openedCount:
          json['openedCount'] ?? 0,

      scheduledAt:
          json['scheduledAt'] != null
              ? DateTime.tryParse(
                  json['scheduledAt']
                      .toString(),
                )
              : null,

      sentAt:
          json['sentAt'] != null
              ? DateTime.tryParse(
                  json['sentAt']
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
      'title': title,
      'message': message,
      'notificationType':
          notificationType,
      'imageUrl': imageUrl,
      'receiverId': receiverId,
      'receiverType': receiverType,
      'topic': topic,
      'actionType': actionType,
      'actionId': actionId,
      'isRead': isRead,
      'isSent': isSent,
      'isDelivered': isDelivered,
      'totalRecipients':
          totalRecipients,
      'deliveredCount':
          deliveredCount,
      'openedCount': openedCount,
      'scheduledAt':
          scheduledAt
              ?.toIso8601String(),
      'sentAt':
          sentAt?.toIso8601String(),
      'createdAt':
          createdAt
              ?.toIso8601String(),
      'updatedAt':
          updatedAt
              ?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? notificationType,
    String? imageUrl,
    String? receiverId,
    String? receiverType,
    String? topic,
    String? actionType,
    String? actionId,
    bool? isRead,
    bool? isSent,
    bool? isDelivered,
    int? totalRecipients,
    int? deliveredCount,
    int? openedCount,
    DateTime? scheduledAt,
    DateTime? sentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType:
          notificationType ??
              this.notificationType,
      imageUrl:
          imageUrl ?? this.imageUrl,
      receiverId:
          receiverId ?? this.receiverId,
      receiverType:
          receiverType ??
              this.receiverType,
      topic: topic ?? this.topic,
      actionType:
          actionType ?? this.actionType,
      actionId:
          actionId ?? this.actionId,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      isDelivered:
          isDelivered ??
              this.isDelivered,
      totalRecipients:
          totalRecipients ??
              this.totalRecipients,
      deliveredCount:
          deliveredCount ??
              this.deliveredCount,
      openedCount:
          openedCount ??
              this.openedCount,
      scheduledAt:
          scheduledAt ??
              this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isBroadcast =>
      topic != null &&
      topic!.isNotEmpty;

  bool get isScheduled =>
      scheduledAt != null &&
      scheduledAt!.isAfter(
        DateTime.now(),
      );

  bool get isOpened =>
      openedCount > 0;

  bool get isPending =>
      !isSent;

  double get deliveryRate {
    if (totalRecipients == 0) {
      return 0;
    }

    return (deliveredCount /
            totalRecipients) *
        100;
  }

  double get openRate {
    if (deliveredCount == 0) {
      return 0;
    }

    return (openedCount /
            deliveredCount) *
        100;
  }

  @override
  bool operator ==(
    Object other,
  ) {
    if (identical(this, other)) {
      return true;
    }

    return other is NotificationModel &&
        other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode;

  @override
  String toString() {
    return 'NotificationModel('
        'id: $id, '
        'title: $title, '
        'type: $notificationType'
        ')';
  }
}