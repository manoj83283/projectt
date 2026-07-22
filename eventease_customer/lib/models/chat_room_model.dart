import 'dart:convert';

class ChatRoomModel {
  final String id;

  final String customerId;
  final String customerName;
  final String? customerImage;

  final String providerId;
  final String providerName;
  final String? providerImage;

  /// booking | order | support | general
  final String chatType;

  final String? referenceId;

  final String lastMessage;
  final String lastMessageSenderId;

  final int unreadCount;

  final bool isOnline;
  final bool isTyping;

  final DateTime? lastMessageTime;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatRoomModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.providerName,
    required this.chatType,
    required this.lastMessage,
    required this.lastMessageSenderId,
    this.customerImage,
    this.providerImage,
    this.referenceId,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
    this.lastMessageTime,
    this.createdAt,
    this.updatedAt,
  });

  // =========================================
  // EMPTY
  // =========================================

  factory ChatRoomModel.empty() {
    return const ChatRoomModel(
      id: '',
      customerId: '',
      customerName: '',
      providerId: '',
      providerName: '',
      chatType: 'general',
      lastMessage: '',
      lastMessageSenderId: '',
    );
  }

  // =========================================
  // COPY WITH
  // =========================================

  ChatRoomModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerImage,
    String? providerId,
    String? providerName,
    String? providerImage,
    String? chatType,
    String? referenceId,
    String? lastMessage,
    String? lastMessageSenderId,
    int? unreadCount,
    bool? isOnline,
    bool? isTyping,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerImage: customerImage ?? this.customerImage,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerImage: providerImage ?? this.providerImage,
      chatType: chatType ?? this.chatType,
      referenceId: referenceId ?? this.referenceId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId:
          lastMessageSenderId ??
              this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isTyping: isTyping ?? this.isTyping,
      lastMessageTime:
          lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =========================================
  // FROM MAP
  // =========================================

  factory ChatRoomModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return ChatRoomModel(
      id: map['_id']?.toString() ??
          map['id']?.toString() ??
          '',

      customerId:
          map['customerId']?.toString() ?? '',

      customerName:
          map['customerName'] ?? '',

      customerImage:
          map['customerImage'],

      providerId:
          map['providerId']?.toString() ?? '',

      providerName:
          map['providerName'] ?? '',

      providerImage:
          map['providerImage'],

      chatType:
          map['chatType'] ?? 'general',

      referenceId:
          map['referenceId']?.toString(),

      lastMessage:
          map['lastMessage'] ?? '',

      lastMessageSenderId:
          map['lastMessageSenderId'] ?? '',

      unreadCount:
          map['unreadCount'] ?? 0,

      isOnline:
          map['isOnline'] ?? false,

      isTyping:
          map['isTyping'] ?? false,

      lastMessageTime:
          map['lastMessageTime'] != null
              ? DateTime.tryParse(
                  map['lastMessageTime'],
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

  // =========================================
  // TO MAP
  // =========================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerImage': customerImage,
      'providerId': providerId,
      'providerName': providerName,
      'providerImage': providerImage,
      'chatType': chatType,
      'referenceId': referenceId,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isTyping': isTyping,
      'lastMessageTime':
          lastMessageTime?.toIso8601String(),
      'createdAt':
          createdAt?.toIso8601String(),
      'updatedAt':
          updatedAt?.toIso8601String(),
    };
  }

  // =========================================
  // JSON
  // =========================================

  factory ChatRoomModel.fromJson(
    String source,
  ) {
    return ChatRoomModel.fromMap(
      jsonDecode(source),
    );
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // =========================================
  // HELPERS
  // =========================================

  bool get isBookingChat =>
      chatType.toLowerCase() == 'booking';

  bool get isOrderChat =>
      chatType.toLowerCase() == 'order';

  bool get isSupportChat =>
      chatType.toLowerCase() == 'support';

  bool get hasUnreadMessages =>
      unreadCount > 0;

  bool get hasCustomerImage =>
      customerImage != null &&
      customerImage!.isNotEmpty;

  bool get hasProviderImage =>
      providerImage != null &&
      providerImage!.isNotEmpty;

  // =========================================
  // OVERRIDES
  // =========================================

  @override
  String toString() {
    return 'ChatRoomModel(id: $id, providerName: $providerName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatRoomModel &&
            other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}