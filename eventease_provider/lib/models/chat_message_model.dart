enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ChatMessageModel {
  final String id;

  final String chatRoomId;

  final String senderId;
  final String senderName;

  final String receiverId;
  final String receiverName;

  final String message;

  final MessageType messageType;
  final MessageStatus status;

  final String mediaUrl;
  final String thumbnailUrl;

  final String fileName;
  final double fileSize;

  final double latitude;
  final double longitude;

  final bool isDeleted;

  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.messageType,
    required this.status,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.fileName,
    required this.fileSize,
    required this.latitude,
    required this.longitude,
    required this.isDeleted,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatMessageModel.empty() {
    return ChatMessageModel(
      id: '',
      chatRoomId: '',
      senderId: '',
      senderName: '',
      receiverId: '',
      receiverName: '',
      message: '',
      messageType: MessageType.text,
      status: MessageStatus.sending,
      mediaUrl: '',
      thumbnailUrl: '',
      fileName: '',
      fileSize: 0,
      latitude: 0,
      longitude: 0,
      isDeleted: false,
      sentAt: DateTime.now(),
    );
  }

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatMessageModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      chatRoomId:
          json['chatRoomId']?.toString() ??
              '',
      senderId:
          json['senderId']?.toString() ??
              '',
      senderName:
          json['senderName']?.toString() ??
              '',
      receiverId:
          json['receiverId']?.toString() ??
              '',
      receiverName:
          json['receiverName']?.toString() ??
              '',
      message:
          json['message']?.toString() ?? '',
      messageType: _parseMessageType(
        json['messageType'],
      ),
      status: _parseStatus(
        json['status'],
      ),
      mediaUrl:
          json['mediaUrl']?.toString() ??
              '',
      thumbnailUrl:
          json['thumbnailUrl']
                  ?.toString() ??
              '',
      fileName:
          json['fileName']?.toString() ??
              '',
      fileSize:
          (json['fileSize'] ?? 0)
              .toDouble(),
      latitude:
          (json['latitude'] ?? 0)
              .toDouble(),
      longitude:
          (json['longitude'] ?? 0)
              .toDouble(),
      isDeleted:
          json['isDeleted'] ?? false,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(
              json['sentAt'].toString(),
            )
          : DateTime.now(),
      deliveredAt:
          json['deliveredAt'] != null
              ? DateTime.tryParse(
                  json['deliveredAt']
                      .toString(),
                )
              : null,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(
              json['readAt']
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
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'message': message,
      'messageType': messageType.name,
      'status': status.name,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'latitude': latitude,
      'longitude': longitude,
      'isDeleted': isDeleted,
      'sentAt': sentAt.toIso8601String(),
      'deliveredAt':
          deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  static MessageType _parseMessageType(
    dynamic value,
  ) {
    switch (
        value.toString().toLowerCase()) {
      case 'image':
        return MessageType.image;

      case 'video':
        return MessageType.video;

      case 'audio':
        return MessageType.audio;

      case 'file':
        return MessageType.file;

      case 'location':
        return MessageType.location;

      case 'system':
        return MessageType.system;

      default:
        return MessageType.text;
    }
  }

  static MessageStatus _parseStatus(
    dynamic value,
  ) {
    switch (
        value.toString().toLowerCase()) {
      case 'sent':
        return MessageStatus.sent;

      case 'delivered':
        return MessageStatus.delivered;

      case 'read':
        return MessageStatus.read;

      case 'failed':
        return MessageStatus.failed;

      default:
        return MessageStatus.sending;
    }
  }

  bool get isText =>
      messageType == MessageType.text;

  bool get isImage =>
      messageType == MessageType.image;

  bool get isVideo =>
      messageType == MessageType.video;

  bool get isAudio =>
      messageType == MessageType.audio;

  bool get isFile =>
      messageType == MessageType.file;

  bool get isLocation =>
      messageType == MessageType.location;

  bool get isRead =>
      status == MessageStatus.read;

  bool get isDelivered =>
      status == MessageStatus.delivered;

  bool get isFailed =>
      status == MessageStatus.failed;

  ChatMessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? message,
    MessageType? messageType,
    MessageStatus? status,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    double? fileSize,
    double? latitude,
    double? longitude,
    bool? isDeleted,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatRoomId:
          chatRoomId ?? this.chatRoomId,
      senderId:
          senderId ?? this.senderId,
      senderName:
          senderName ?? this.senderName,
      receiverId:
          receiverId ?? this.receiverId,
      receiverName:
          receiverName ??
              this.receiverName,
      message: message ?? this.message,
      messageType:
          messageType ?? this.messageType,
      status: status ?? this.status,
      mediaUrl:
          mediaUrl ?? this.mediaUrl,
      thumbnailUrl:
          thumbnailUrl ??
              this.thumbnailUrl,
      fileName:
          fileName ?? this.fileName,
      fileSize:
          fileSize ?? this.fileSize,
      latitude:
          latitude ?? this.latitude,
      longitude:
          longitude ?? this.longitude,
      isDeleted:
          isDeleted ?? this.isDeleted,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt:
          deliveredAt ??
              this.deliveredAt,
      readAt: readAt ?? this.readAt,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageModel &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, message: $message)';
  }
}