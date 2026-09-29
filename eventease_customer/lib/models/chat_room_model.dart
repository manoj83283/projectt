import 'dart:convert';

class ChatRoomModel {
  final String id;
  final String roomId;
  final String bookingId;
  final String bookingNumber;

  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? customerImage;

  final String providerId;
  final String providerName;
  final String providerPhone;
  final String? providerImage;

  final String participantId;
  final String participantName;
  final String? participantImage;

  final String serviceId;
  final String serviceName;
  final String? serviceImage;

  final String chatType;
  final String bookingStatus;

  final String? referenceId;

  final String lastMessage;
  final String lastMessageSenderId;

  final int unreadCount;

  final bool isOnline;
  final bool isTyping;
  final bool chatEnabled;

  final DateTime? lastMessageTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatRoomModel({
    required this.id,
    required this.roomId,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.providerId,
    required this.providerName,
    this.bookingNumber = '',
    this.customerPhone = '',
    this.customerImage,
    this.providerPhone = '',
    this.providerImage,
    this.participantId = '',
    this.participantName = '',
    this.participantImage,
    this.serviceId = '',
    this.serviceName = '',
    this.serviceImage,
    this.chatType = 'booking',
    this.bookingStatus = 'pending',
    this.referenceId,
    this.lastMessage = '',
    this.lastMessageSenderId = '',
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
    this.chatEnabled = true,
    this.lastMessageTime,
    this.createdAt,
    this.updatedAt,
  });

  // =====================================================
  // EMPTY MODEL
  // =====================================================
  Future<ChatRoomModel> createChatRoom({
    required String providerId,
    required String bookingId,
  }) async {
    final normalizedProviderId = providerId.trim();

    final normalizedBookingId = bookingId.trim();

    final roomId = 'booking:$normalizedBookingId';

    return ChatRoomModel(
      id: roomId,
      roomId: roomId,

      bookingId: normalizedBookingId,

      customerId: '',
      customerName: '',

      providerId: normalizedProviderId,
      providerName: '',

      bookingNumber: '',

      customerPhone: '',
      providerPhone: '',

      participantId: normalizedProviderId,
      participantName: '',

      serviceId: '',
      serviceName: '',

      chatType: 'booking',
      bookingStatus: 'pending',

      lastMessage: '',
      lastMessageSenderId: '',

      unreadCount: 0,

      isOnline: false,
      isTyping: false,
      chatEnabled: true,
    );
  }

  factory ChatRoomModel.empty() {
    return const ChatRoomModel(
      id: '',
      roomId: '',
      bookingId: '',
      customerId: '',
      customerName: '',
      providerId: '',
      providerName: '',
    );
  }

  // =====================================================
  // VALUE HELPERS
  // =====================================================

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map((key, item) {
        return MapEntry(key.toString(), item);
      });
    }

    return <String, dynamic>{};
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    final result = value.toString().trim();

    return result.isEmpty ? fallback : result;
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? fallback;
  }

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value == null) {
      return fallback;
    }

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalizedValue = value.toString().trim().toLowerCase();

    if (normalizedValue == 'true' ||
        normalizedValue == '1' ||
        normalizedValue == 'yes') {
      return true;
    }

    if (normalizedValue == 'false' ||
        normalizedValue == '0' ||
        normalizedValue == 'no') {
      return false;
    }

    return fallback;
  }

  static DateTime? _asDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }

  static String _extractId(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    final map = _asMap(value);

    return _asString(map['_id'] ?? map['id']);
  }

  static String _extractName(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    final map = _asMap(value);

    final firstName = _asString(map['firstName']);

    final lastName = _asString(map['lastName']);

    final combinedName =
        [firstName, lastName].where((item) => item.isNotEmpty).join(' ').trim();

    return _asString(
      map['businessName'] ?? map['shopName'] ?? map['fullName'] ?? map['name'],
      fallback: combinedName,
    );
  }

  static String _extractPhone(dynamic value) {
    if (value == null) {
      return '';
    }

    final map = _asMap(value);

    return _asString(map['phone'] ?? map['mobile']);
  }

  static String? _extractImage(dynamic value) {
    if (value == null) {
      return null;
    }

    final map = _asMap(value);

    final image = _asString(
      map['profileImage'] ?? map['imageUrl'] ?? map['image'],
    );

    return image.isEmpty ? null : image;
  }

  static String _extractServiceName(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    final map = _asMap(value);

    return _asString(map['name'] ?? map['title']);
  }

  static String? _extractServiceImage(dynamic value) {
    if (value == null) {
      return null;
    }

    final map = _asMap(value);

    final directImage = _asString(map['imageUrl'] ?? map['image']);

    if (directImage.isNotEmpty) {
      return directImage;
    }

    final images = map['images'];

    if (images is List && images.isNotEmpty) {
      final firstImage = images.first;

      if (firstImage is String) {
        final value = firstImage.trim();

        return value.isEmpty ? null : value;
      }

      final imageMap = _asMap(firstImage);

      final value = _asString(
        imageMap['url'] ?? imageMap['imageUrl'] ?? imageMap['image'],
      );

      return value.isEmpty ? null : value;
    }

    return null;
  }

  // =====================================================
  // FROM MAP
  // =====================================================

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    final customer = map['customer'] ?? map['user'];

    final provider = map['provider'];

    final participant = map['participant'];

    final service = map['service'];

    final latestMessage = _asMap(map['latestMessage']);

    final resolvedBookingId = _asString(
      map['bookingId'] ?? map['referenceId'] ?? latestMessage['bookingId'],
    );

    final suppliedRoomId = _asString(
      map['roomId'] ?? map['chatRoomId'] ?? map['_id'] ?? map['id'],
    );

    final resolvedRoomId =
        suppliedRoomId.isNotEmpty
            ? suppliedRoomId
            : resolvedBookingId.isNotEmpty
            ? 'booking:$resolvedBookingId'
            : '';

    final resolvedId = _asString(
      map['_id'] ?? map['id'],
      fallback: resolvedRoomId,
    );

    final customerId = _asString(
      map['customerId'],
      fallback: _extractId(customer),
    );

    final providerId = _asString(
      map['providerId'],
      fallback: _extractId(provider),
    );

    final participantId = _asString(
      map['participantId'],
      fallback: _extractId(participant),
    );

    final customerName = _asString(
      map['customerName'],
      fallback: _extractName(customer),
    );

    final providerName = _asString(
      map['providerName'],
      fallback: _extractName(provider),
    );

    final participantName = _asString(
      map['participantName'],
      fallback: _extractName(participant),
    );

    final lastMessageValue = map['lastMessage'];

    String resolvedLastMessage = '';

    if (lastMessageValue is Map) {
      resolvedLastMessage = _asString(
        lastMessageValue['message'] ??
            lastMessageValue['text'] ??
            lastMessageValue['content'],
      );
    } else {
      resolvedLastMessage = _asString(
        lastMessageValue,
        fallback: _asString(
          latestMessage['message'] ??
              latestMessage['text'] ??
              latestMessage['content'],
        ),
      );
    }

    final lastMessageSenderId = _asString(
      map['lastMessageSenderId'],
      fallback: _extractId(
        latestMessage['senderId'] ?? latestMessage['sender'],
      ),
    );

    final lastMessageTime = _asDate(
      map['lastMessageAt'] ??
          map['lastMessageTime'] ??
          latestMessage['createdAt'] ??
          latestMessage['updatedAt'],
    );

    final serviceId = _asString(
      map['serviceId'],
      fallback: _extractId(service),
    );

    final serviceName = _asString(
      map['serviceName'],
      fallback: _extractServiceName(service),
    );

    final customerImageValue = _asString(map['customerImage']);

    final providerImageValue = _asString(map['providerImage']);

    final participantImageValue = _asString(map['participantImage']);

    final serviceImageValue = _asString(map['serviceImage']);

    return ChatRoomModel(
      id: resolvedId,

      roomId: resolvedRoomId,

      bookingId: resolvedBookingId,

      bookingNumber: _asString(map['bookingNumber']),

      customerId: customerId,

      customerName: customerName,

      customerPhone: _asString(
        map['customerPhone'],
        fallback: _extractPhone(customer),
      ),

      customerImage:
          customerImageValue.isNotEmpty
              ? customerImageValue
              : _extractImage(customer),

      providerId: providerId,

      providerName: providerName,

      providerPhone: _asString(
        map['providerPhone'],
        fallback: _extractPhone(provider),
      ),

      providerImage:
          providerImageValue.isNotEmpty
              ? providerImageValue
              : _extractImage(provider),

      participantId: participantId,

      participantName: participantName,

      participantImage:
          participantImageValue.isNotEmpty
              ? participantImageValue
              : _extractImage(participant),

      serviceId: serviceId,

      serviceName: serviceName,

      serviceImage:
          serviceImageValue.isNotEmpty
              ? serviceImageValue
              : _extractServiceImage(service),

      chatType: _asString(map['chatType'] ?? map['type'], fallback: 'booking'),

      bookingStatus: _asString(
        map['bookingStatus'] ?? map['status'],
        fallback: 'pending',
      ),

      referenceId:
          _asString(map['referenceId']).isEmpty
              ? null
              : _asString(map['referenceId']),

      lastMessage: resolvedLastMessage,

      lastMessageSenderId: lastMessageSenderId,

      unreadCount: _asInt(map['unreadCount']),

      isOnline: _asBool(map['isOnline'] ?? _asMap(participant)['isOnline']),

      isTyping: _asBool(map['isTyping']),

      chatEnabled: _asBool(map['chatEnabled'], fallback: true),

      lastMessageTime: lastMessageTime,

      createdAt: _asDate(map['createdAt']),

      updatedAt: _asDate(map['updatedAt']),
    );
  }

  // =====================================================
  // TO MAP
  // =====================================================

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'id': id,
      'roomId': roomId,
      'chatRoomId': roomId,
      'bookingId': bookingId,
      'bookingNumber': bookingNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerImage': customerImage,
      'providerId': providerId,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'providerImage': providerImage,
      'participantId': participantId,
      'participantName': participantName,
      'participantImage': participantImage,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceImage': serviceImage,
      'chatType': chatType,
      'type': chatType,
      'bookingStatus': bookingStatus,
      'status': bookingStatus,
      'referenceId': referenceId,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'isTyping': isTyping,
      'chatEnabled': chatEnabled,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'lastMessageAt': lastMessageTime?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // =====================================================
  // JSON
  // =====================================================

  factory ChatRoomModel.fromJson(String source) {
    final decoded = jsonDecode(source);

    if (decoded is Map) {
      return ChatRoomModel.fromMap(
        decoded.map((key, value) {
          return MapEntry(key.toString(), value);
        }),
      );
    }

    throw const FormatException('Invalid chat room JSON.');
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // =====================================================
  // COPY WITH
  // =====================================================

  ChatRoomModel copyWith({
    String? id,
    String? roomId,
    String? bookingId,
    String? bookingNumber,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerImage,
    String? providerId,
    String? providerName,
    String? providerPhone,
    String? providerImage,
    String? participantId,
    String? participantName,
    String? participantImage,
    String? serviceId,
    String? serviceName,
    String? serviceImage,
    String? chatType,
    String? bookingStatus,
    String? referenceId,
    String? lastMessage,
    String? lastMessageSenderId,
    int? unreadCount,
    bool? isOnline,
    bool? isTyping,
    bool? chatEnabled,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,

      roomId: roomId ?? this.roomId,

      bookingId: bookingId ?? this.bookingId,

      bookingNumber: bookingNumber ?? this.bookingNumber,

      customerId: customerId ?? this.customerId,

      customerName: customerName ?? this.customerName,

      customerPhone: customerPhone ?? this.customerPhone,

      customerImage: customerImage ?? this.customerImage,

      providerId: providerId ?? this.providerId,

      providerName: providerName ?? this.providerName,

      providerPhone: providerPhone ?? this.providerPhone,

      providerImage: providerImage ?? this.providerImage,

      participantId: participantId ?? this.participantId,

      participantName: participantName ?? this.participantName,

      participantImage: participantImage ?? this.participantImage,

      serviceId: serviceId ?? this.serviceId,

      serviceName: serviceName ?? this.serviceName,

      serviceImage: serviceImage ?? this.serviceImage,

      chatType: chatType ?? this.chatType,

      bookingStatus: bookingStatus ?? this.bookingStatus,

      referenceId: referenceId ?? this.referenceId,

      lastMessage: lastMessage ?? this.lastMessage,

      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,

      unreadCount: unreadCount ?? this.unreadCount,

      isOnline: isOnline ?? this.isOnline,

      isTyping: isTyping ?? this.isTyping,

      chatEnabled: chatEnabled ?? this.chatEnabled,

      lastMessageTime: lastMessageTime ?? this.lastMessageTime,

      createdAt: createdAt ?? this.createdAt,

      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // =====================================================
  // STATUS HELPERS
  // =====================================================

  String get normalizedBookingStatus {
    final status = bookingStatus
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (status) {
      case 'confirmed':
      case 'confirm':
        return 'accepted';

      case 'inprogress':
      case 'processing':
        return 'in_progress';

      case 'canceled':
        return 'cancelled';

      default:
        return status;
    }
  }

  // =====================================================
  // GENERAL HELPERS
  // =====================================================

  bool get isBookingChat {
    return chatType.toLowerCase() == 'booking';
  }

  bool get isOrderChat {
    return chatType.toLowerCase() == 'order';
  }

  bool get isSupportChat {
    return chatType.toLowerCase() == 'support';
  }

  bool get hasUnreadMessages {
    return unreadCount > 0;
  }

  bool get hasCustomerImage {
    return customerImage != null && customerImage!.trim().isNotEmpty;
  }

  bool get hasProviderImage {
    return providerImage != null && providerImage!.trim().isNotEmpty;
  }

  bool get hasParticipantImage {
    return participantImage != null && participantImage!.trim().isNotEmpty;
  }

  bool get hasServiceImage {
    return serviceImage != null && serviceImage!.trim().isNotEmpty;
  }

  bool get hasLastMessage {
    return lastMessage.trim().isNotEmpty;
  }

  bool get isPending {
    return normalizedBookingStatus == 'pending';
  }

  bool get isAccepted {
    return normalizedBookingStatus == 'accepted';
  }

  bool get isOtpVerified {
    return normalizedBookingStatus == 'otp_verified';
  }

  bool get isInProgress {
    return normalizedBookingStatus == 'in_progress';
  }

  bool get isCompleted {
    return normalizedBookingStatus == 'completed';
  }

  bool get isCancelled {
    return normalizedBookingStatus == 'cancelled';
  }

  bool get isRejected {
    return normalizedBookingStatus == 'rejected';
  }

  bool get isActiveBooking {
    return isAccepted || isOtpVerified || isInProgress;
  }

  String get displayName {
    if (participantName.trim().isNotEmpty) {
      return participantName.trim();
    }

    if (providerName.trim().isNotEmpty) {
      return providerName.trim();
    }

    if (customerName.trim().isNotEmpty) {
      return customerName.trim();
    }

    return 'Chat';
  }

  String get displayImage {
    if (participantImage != null && participantImage!.trim().isNotEmpty) {
      return participantImage!.trim();
    }

    if (providerImage != null && providerImage!.trim().isNotEmpty) {
      return providerImage!.trim();
    }

    if (customerImage != null && customerImage!.trim().isNotEmpty) {
      return customerImage!.trim();
    }

    return '';
  }

  String get effectiveRoomId {
    if (roomId.trim().isNotEmpty) {
      return roomId.trim();
    }

    if (bookingId.trim().isNotEmpty) {
      return 'booking:${bookingId.trim()}';
    }

    return id.trim();
  }

  // =====================================================
  // OVERRIDES
  // =====================================================

  @override
  String toString() {
    return 'ChatRoomModel(id: $id, roomId: $roomId, bookingId: $bookingId, providerName: $providerName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatRoomModel && other.id == id && other.roomId == roomId;
  }

  @override
  int get hashCode {
    return Object.hash(id, roomId);
  }
}
