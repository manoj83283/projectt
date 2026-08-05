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

extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';

      case MessageType.image:
        return 'image';

      case MessageType.video:
        return 'video';

      case MessageType.audio:
        return 'audio';

      case MessageType.file:
        return 'file';

      case MessageType.location:
        return 'location';

      case MessageType.system:
        return 'system';
    }
  }

  static MessageType fromString(dynamic value) {
    final type = value?.toString().toLowerCase().trim() ?? '';

    switch (type) {
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

      case 'text':
      default:
        return MessageType.text;
    }
  }
}

extension MessageStatusExtension on MessageStatus {
  String get value {
    switch (this) {
      case MessageStatus.sending:
        return 'sending';

      case MessageStatus.sent:
        return 'sent';

      case MessageStatus.delivered:
        return 'delivered';

      case MessageStatus.read:
        return 'read';

      case MessageStatus.failed:
        return 'failed';
    }
  }

  static MessageStatus fromString(dynamic value) {
    final status = value?.toString().toLowerCase().trim() ?? '';

    switch (status) {
      case 'sent':
        return MessageStatus.sent;

      case 'delivered':
        return MessageStatus.delivered;

      case 'read':
        return MessageStatus.read;

      case 'failed':
        return MessageStatus.failed;

      case 'sending':
      default:
        return MessageStatus.sending;
    }
  }
}

class ChatMessageModel {
  final String id;

  final String chatRoomId;

  final String senderId;
  final String senderName;

  final String receiverId;
  final String receiverName;

  final String message;

  /// ✅ Kept as String for UI/API compatibility
  final String messageType;

  /// ✅ Kept as String for UI/API compatibility
  final String status;

  final String mediaUrl;
  final String thumbnailUrl;

  final String fileName;
  final double fileSize;

  final double latitude;
  final double longitude;

  final bool isDeleted;

  /// ✅ Added for chat_screen.dart compatibility:
  /// message.isMine ?? false
  final bool? isMine;

  /// ✅ Kept as String because your screen uses:
  /// message.createdAt ?? ''
  final String sentAt;

  final String deliveredAt;
  final String readAt;

  final String createdAt;
  final String updatedAt;

  final Map<String, dynamic>? rawSender;
  final Map<String, dynamic>? rawReceiver;

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
    required this.isMine,
    required this.sentAt,
    required this.deliveredAt,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
    this.rawSender,
    this.rawReceiver,
  });

  factory ChatMessageModel.empty() {
    return const ChatMessageModel(
      id: '',
      chatRoomId: '',
      senderId: '',
      senderName: '',
      receiverId: '',
      receiverName: '',
      message: '',
      messageType: 'text',
      status: 'sending',
      mediaUrl: '',
      thumbnailUrl: '',
      fileName: '',
      fileSize: 0,
      latitude: 0,
      longitude: 0,
      isDeleted: false,
      isMine: false,
      sentAt: '',
      deliveredAt: '',
      readAt: '',
      createdAt: '',
      updatedAt: '',
    );
  }

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final sender = _asMap(json['sender']);
    final receiver = _asMap(json['receiver']);

    final parsedSenderId = sender?['_id']?.toString() ??
        sender?['id']?.toString() ??
        json['senderId']?.toString() ??
        json['sender']?.toString() ??
        '';

    final parsedReceiverId = receiver?['_id']?.toString() ??
        receiver?['id']?.toString() ??
        json['receiverId']?.toString() ??
        json['receiver']?.toString() ??
        '';

    final senderFirstName = sender?['firstName']?.toString() ?? '';
    final senderLastName = sender?['lastName']?.toString() ?? '';
    final senderFullName = sender?['name']?.toString() ?? '';

    final parsedSenderName = json['senderName']?.toString() ??
        (senderFullName.isNotEmpty
            ? senderFullName
            : '$senderFirstName $senderLastName'.trim());

    final receiverFirstName = receiver?['firstName']?.toString() ?? '';
    final receiverLastName = receiver?['lastName']?.toString() ?? '';
    final receiverFullName = receiver?['name']?.toString() ?? '';

    final parsedReceiverName = json['receiverName']?.toString() ??
        (receiverFullName.isNotEmpty
            ? receiverFullName
            : '$receiverFirstName $receiverLastName'.trim());

    final parsedMessageType = json['messageType']?.toString() ??
        json['type']?.toString() ??
        'text';

    final parsedStatus = json['status']?.toString() ?? 'sending';

    final parsedCreatedAt = json['createdAt']?.toString() ??
        json['sentAt']?.toString() ??
        json['time']?.toString() ??
        '';

    final parsedIsMine = currentUserId == null
        ? _toBoolNullable(json['isMine'])
        : parsedSenderId == currentUserId;

    return ChatMessageModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',

      chatRoomId: json['chatRoomId']?.toString() ??
          json['roomId']?.toString() ??
          json['room']?.toString() ??
          '',

      senderId: parsedSenderId,

      senderName: parsedSenderName,

      receiverId: parsedReceiverId,

      receiverName: parsedReceiverName,

      message: json['message']?.toString() ??
          json['text']?.toString() ??
          '',

      messageType: parsedMessageType.toLowerCase().trim(),

      status: parsedStatus.toLowerCase().trim(),

      mediaUrl: json['mediaUrl']?.toString() ??
          json['fileUrl']?.toString() ??
          json['imageUrl']?.toString() ??
          '',

      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',

      fileName: json['fileName']?.toString() ?? '',

      fileSize: _toDouble(
        json['fileSize'],
      ),

      latitude: _toDouble(
        json['latitude'] ??
            json['lat'],
      ),

      longitude: _toDouble(
        json['longitude'] ??
            json['lng'],
      ),

      isDeleted: _toBool(
        json['isDeleted'] ??
            json['deleted'],
      ),

      isMine: parsedIsMine,

      sentAt: json['sentAt']?.toString() ??
          parsedCreatedAt,

      deliveredAt: json['deliveredAt']?.toString() ?? '',

      readAt: json['readAt']?.toString() ?? '',

      createdAt: parsedCreatedAt,

      updatedAt: json['updatedAt']?.toString() ?? '',

      rawSender: sender,
      rawReceiver: receiver,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,

      'chatRoomId': chatRoomId,
      'roomId': chatRoomId,

      'senderId': senderId,
      'senderName': senderName,

      'receiverId': receiverId,
      'receiverName': receiverName,

      'message': message,
      'text': message,

      'messageType': messageType,
      'type': messageType,

      'status': status,

      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,

      'fileName': fileName,
      'fileSize': fileSize,

      'latitude': latitude,
      'longitude': longitude,

      'isDeleted': isDeleted,
      'isMine': isMine,

      'sentAt': sentAt,
      'deliveredAt': deliveredAt,
      'readAt': readAt,

      'createdAt': createdAt,
      'updatedAt': updatedAt,

      'sender': rawSender,
      'receiver': rawReceiver,
    };
  }

  static MessageType _parseMessageType(
    dynamic value,
  ) {
    return MessageTypeExtension.fromString(value);
  }

  static MessageStatus _parseStatus(
    dynamic value,
  ) {
    return MessageStatusExtension.fromString(value);
  }

  MessageType get messageTypeEnum {
    return _parseMessageType(messageType);
  }

  MessageStatus get statusEnum {
    return _parseStatus(status);
  }

  bool get isText {
    return messageType.toLowerCase() == 'text';
  }

  bool get isImage {
    return messageType.toLowerCase() == 'image';
  }

  bool get isVideo {
    return messageType.toLowerCase() == 'video';
  }

  bool get isAudio {
    return messageType.toLowerCase() == 'audio';
  }

  bool get isFile {
    return messageType.toLowerCase() == 'file';
  }

  bool get isLocation {
    return messageType.toLowerCase() == 'location';
  }

  bool get isSystem {
    return messageType.toLowerCase() == 'system';
  }

  bool get isRead {
    return status.toLowerCase() == 'read';
  }

  bool get isDelivered {
    return status.toLowerCase() == 'delivered';
  }

  bool get isSent {
    return status.toLowerCase() == 'sent';
  }

  bool get isSending {
    return status.toLowerCase() == 'sending';
  }

  bool get isFailed {
    return status.toLowerCase() == 'failed';
  }

  DateTime? get sentAtDateTime {
    return _toDateTime(sentAt);
  }

  DateTime? get deliveredAtDateTime {
    return _toDateTime(deliveredAt);
  }

  DateTime? get readAtDateTime {
    return _toDateTime(readAt);
  }

  DateTime? get createdAtDateTime {
    return _toDateTime(createdAt);
  }

  DateTime? get updatedAtDateTime {
    return _toDateTime(updatedAt);
  }

  ChatMessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? message,
    String? messageType,
    String? status,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    double? fileSize,
    double? latitude,
    double? longitude,
    bool? isDeleted,
    bool? isMine,
    String? sentAt,
    String? deliveredAt,
    String? readAt,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? rawSender,
    Map<String, dynamic>? rawReceiver,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDeleted: isDeleted ?? this.isDeleted,
      isMine: isMine ?? this.isMine,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rawSender: rawSender ?? this.rawSender,
      rawReceiver: rawReceiver ?? this.rawReceiver,
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

  static bool _toBool(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    final text = value.toString().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes';
  }

  static bool? _toBoolNullable(dynamic value) {
    if (value == null) return null;

    if (value is bool) return value;

    final text = value.toString().toLowerCase();

    if (text == 'true' || text == '1' || text == 'yes') {
      return true;
    }

    if (text == 'false' || text == '0' || text == 'no') {
      return false;
    }

    return null;
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
        other is ChatMessageModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, message: $message, status: $status)';
  }
}