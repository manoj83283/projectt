import 'dart:convert';

class ChatMessageModel {
  final String id;

  final String bookingId;

  final String roomId;
  final String chatRoomId;

  final String senderId;
  final String senderName;

  final String receiverId;

  final String messageType;
  final String message;

  final String? mediaUrl;

  final bool isRead;
  final bool delivered;

  final DateTime? readAt;

  final double? latitude;
  final double? longitude;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.messageType,
    required this.message,

    this.bookingId = '',

    this.mediaUrl,

    this.isRead = false,
    this.delivered = false,

    this.readAt,

    this.latitude,
    this.longitude,

    this.createdAt,
    this.updatedAt,
  });

  factory ChatMessageModel.empty() {
    return const ChatMessageModel(
      id: '',
      bookingId: '',
      roomId: '',
      chatRoomId: '',
      senderId: '',
      senderName: '',
      receiverId: '',
      messageType: 'text',
      message: '',
    );
  }

  static String _string(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static bool _bool(
    dynamic value,
  ) {
    if (value == null) {
      return false;
    }

    if (value is bool) {
      return value;
    }

    return value.toString().toLowerCase() ==
        'true';
  }

  static double? _double(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static DateTime? _date(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static String _extractUserName(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value;
    }

    if (value is Map) {
      return value['fullName']
              ?.toString() ??
          value['name']
              ?.toString() ??
          value['firstName']
              ?.toString() ??
          value['businessName']
              ?.toString() ??
          '';
    }

    return '';
  }

  static String _extractUserId(
    dynamic value,
  ) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value;
    }

    if (value is Map) {
      return value['_id']
              ?.toString() ??
          value['id']
              ?.toString() ??
          '';
    }

    return '';
  }

  factory ChatMessageModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final sender =
        map['sender'] ??
            map['senderId'];

    final receiver =
        map['receiver'] ??
            map['receiverId'];

    return ChatMessageModel(
      id: _string(
        map['_id'] ?? map['id'],
      ),

      bookingId: _string(
        map['bookingId'],
      ),

      roomId: _string(
        map['roomId'],
      ),

      chatRoomId: _string(
        map['chatRoomId'] ??
            map['roomId'],
      ),

      senderId:
          _extractUserId(sender),

      senderName:
          _extractUserName(sender),

      receiverId:
          _extractUserId(receiver),

      messageType: _string(
        map['messageType'].toString().isEmpty
            ? 'text'
            : map['messageType'],
      ),

      message: _string(
        map['message'],
      ),

      mediaUrl:
          map['mediaUrl']?.toString(),

      isRead:
          _bool(map['isRead']) ||
              _bool(map['read']),

      delivered:
          _bool(
                map['delivered'],
              ) ||
              map['deliveredAt'] != null,

      readAt: _date(
        map['readAt'],
      ),

      latitude: _double(
        map['latitude'],
      ),

      longitude: _double(
        map['longitude'],
      ),

      createdAt: _date(
        map['createdAt'],
      ),

      updatedAt: _date(
        map['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'bookingId': bookingId,
      'roomId': roomId,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'messageType': messageType,
      'message': message,
      'mediaUrl': mediaUrl,
      'isRead': isRead,
      'delivered': delivered,
      'readAt':
          readAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  factory ChatMessageModel.fromJson(
    String source,
  ) {
    return ChatMessageModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(
      toMap(),
    );
  }

  // =====================================================
  // HELPERS
  // =====================================================

  bool get isTextMessage =>
      messageType.toLowerCase() ==
      'text';

  bool get isImageMessage =>
      messageType.toLowerCase() ==
      'image';

  bool get isFileMessage =>
      messageType.toLowerCase() ==
      'file';

  bool get isLocationMessage =>
      messageType.toLowerCase() ==
      'location';

  bool get hasMedia =>
      mediaUrl != null &&
      mediaUrl!.isNotEmpty;

  bool get hasLocation =>
      latitude != null &&
      longitude != null;

  bool get isMine {
    return senderId.isNotEmpty;
  }

  String get createdAtText {
    if (createdAt == null) {
      return '';
    }

    final date =
        createdAt!.toLocal();

    final hour =
        date.hour > 12
            ? date.hour - 12
            : date.hour == 0
                ? 12
                : date.hour;

    final minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    final suffix =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$hour:$minute $suffix';
  }

  ChatMessageModel copyWith({
    String? id,
    String? bookingId,
    String? roomId,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? messageType,
    String? message,
    String? mediaUrl,
    bool? isRead,
    bool? delivered,
    DateTime? readAt,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      bookingId:
          bookingId ?? this.bookingId,
      roomId: roomId ?? this.roomId,
      chatRoomId:
          chatRoomId ?? this.chatRoomId,
      senderId:
          senderId ?? this.senderId,
      senderName:
          senderName ?? this.senderName,
      receiverId:
          receiverId ?? this.receiverId,
      messageType:
          messageType ?? this.messageType,
      message:
          message ?? this.message,
      mediaUrl:
          mediaUrl ?? this.mediaUrl,
      isRead:
          isRead ?? this.isRead,
      delivered:
          delivered ?? this.delivered,
      readAt: readAt ?? this.readAt,
      latitude:
          latitude ?? this.latitude,
      longitude:
          longitude ?? this.longitude,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, roomId: $roomId, message: $message)';
  }

  @override
  bool operator ==(
    Object other,
  ) {
    return identical(
          this,
          other,
        ) ||
        other is ChatMessageModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}