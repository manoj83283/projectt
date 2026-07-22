import 'dart:convert';

class ChatMessageModel {
  final String id;

  final String chatRoomId;

  final String senderId;
  final String senderName;

  final String receiverId;

  /// text | image | file | location
  final String messageType;

  final String message;

  final String? mediaUrl;

  final bool isRead;
  final bool isDelivered;

  final DateTime? readAt;

  final double? latitude;
  final double? longitude;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.messageType,
    required this.message,
    this.mediaUrl,
    this.isRead = false,
    this.isDelivered = false,
    this.readAt,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // EMPTY
  // ==========================================

  factory ChatMessageModel.empty() {
    return const ChatMessageModel(
      id: '',
      chatRoomId: '',
      senderId: '',
      senderName: '',
      receiverId: '',
      messageType: 'text',
      message: '',
    );
  }

  // ==========================================
  // COPY WITH
  // ==========================================

  ChatMessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? messageType,
    String? message,
    String? mediaUrl,
    bool? isRead,
    bool? isDelivered,
    DateTime? readAt,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      messageType: messageType ?? this.messageType,
      message: message ?? this.message,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      readAt: readAt ?? this.readAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================
  // FROM MAP
  // ==========================================

  factory ChatMessageModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ChatMessageModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      chatRoomId:
          map['chatRoomId']?.toString() ?? '',

      senderId:
          map['senderId']?.toString() ?? '',

      senderName:
          map['senderName'] ?? '',

      receiverId:
          map['receiverId']?.toString() ?? '',

      messageType:
          map['messageType'] ?? 'text',

      message:
          map['message'] ?? '',

      mediaUrl:
          map['mediaUrl'],

      isRead:
          map['isRead'] ?? false,

      isDelivered:
          map['isDelivered'] ?? false,

      readAt:
          map['readAt'] != null
              ? DateTime.tryParse(
                  map['readAt'],
                )
              : null,

      latitude:
          (map['latitude'] as num?)
              ?.toDouble(),

      longitude:
          (map['longitude'] as num?)
              ?.toDouble(),

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
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'messageType': messageType,
      'message': message,
      'mediaUrl': mediaUrl,
      'isRead': isRead,
      'isDelivered': isDelivered,
      'readAt': readAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // ==========================================
  // JSON
  // ==========================================

  factory ChatMessageModel.fromJson(
    String source,
  ) {
    return ChatMessageModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // ==========================================
  // HELPERS
  // ==========================================

  bool get isTextMessage =>
      messageType.toLowerCase() == 'text';

  bool get isImageMessage =>
      messageType.toLowerCase() == 'image';

  bool get isFileMessage =>
      messageType.toLowerCase() == 'file';

  bool get isLocationMessage =>
      messageType.toLowerCase() == 'location';

  bool get hasMedia =>
      mediaUrl != null &&
      mediaUrl!.isNotEmpty;

  bool get hasLocation =>
      latitude != null &&
      longitude != null;

  // ==========================================
  // OVERRIDES
  // ==========================================

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatMessageModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}