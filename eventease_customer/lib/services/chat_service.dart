import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import 'api_service.dart';

class ChatService {
  ChatService._();

  static final ChatService instance =
      ChatService._();

  // =====================================================
  // ROOMS
  // =====================================================

  Future<List<ChatRoomModel>> getChatRooms({
    int page = 1,
    int limit = 20,
  }) async {
    final response =
        await ApiService.instance.get(
      '/chat/rooms',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final dynamic responseData =
        response.data;

    final List rooms =
        responseData['rooms'] ??
            responseData['data'] ??
            [];

    return rooms
        .whereType<Map>()
        .map(
          (item) => ChatRoomModel.fromMap(
            item.map(
              (key, value) =>
                  MapEntry(
                key.toString(),
                value,
              ),
            ),
          ),
        )
        .toList();
  }

  Future<ChatRoomModel> getChatRoom(
    String roomId,
  ) async {
    final rooms =
        await getChatRooms();

    return rooms.firstWhere(
      (room) => room.roomId == roomId,
      orElse: () => throw Exception(
        'Chat room not found',
      ),
    );
  }

  // =====================================================
  // CREATE ROOM
  // =====================================================

  Future<ChatRoomModel> createChatRoom({
    required String providerId,
    required String bookingId,
  }) async {
    final normalizedProviderId =
        providerId.trim();

    final normalizedBookingId =
        bookingId.trim();

    final roomId =
        'booking:$normalizedBookingId';

    return ChatRoomModel(
      id: roomId,
      roomId: roomId,

      bookingId:
          normalizedBookingId,

      bookingNumber: '',

      customerId: '',
      customerName: '',
      customerPhone: '',

      providerId:
          normalizedProviderId,
      providerName: '',
      providerPhone: '',

      participantId:
          normalizedProviderId,
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

  // =====================================================
  // ROOM MESSAGES
  // =====================================================

  Future<List<ChatMessageModel>>
      getMessages(
    String roomId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response =
        await ApiService.instance.get(
      '/chat/room/${Uri.encodeComponent(roomId)}',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final dynamic responseData =
        response.data;

    final List items =
        responseData['messages'] ??
            responseData['data'] ??
            [];

    return items
        .whereType<Map>()
        .map(
          (item) =>
              ChatMessageModel.fromMap(
            item.map(
              (key, value) =>
                  MapEntry(
                key.toString(),
                value,
              ),
            ),
          ),
        )
        .toList();
  }

  // =====================================================
  // SEND ROOM MESSAGE
  // =====================================================

  Future<ChatMessageModel>
      sendRoomMessage({
    required String roomId,
    required String bookingId,
    required String receiverId,
    required String message,
  }) async {
    final response =
        await ApiService.instance.post(
      '/chat/room',
      data: {
        'roomId': roomId,
        'bookingId': bookingId,
        'receiverId': receiverId,
        'message': message,
      },
    );

    return ChatMessageModel.fromMap(
      response.data['chatMessage'] ??
          response.data['data'] ??
          <String, dynamic>{},
    );
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================

  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String message,
  }) async {
    final response =
        await ApiService.instance.post(
      '/chat/room',
      data: {
        'roomId': roomId,
        'message': message,
      },
    );

    return ChatMessageModel.fromMap(
      response.data['chatMessage'] ??
          response.data['data'] ??
          <String, dynamic>{},
    );
  }

  // =====================================================
  // IMAGE MESSAGE
  // =====================================================

  Future<ChatMessageModel>
      sendImageMessage({
    required String roomId,
    required String imageUrl,
  }) async {
    return sendMessage(
      roomId: roomId,
      message: imageUrl,
    );
  }

  // =====================================================
  // LOCATION MESSAGE
  // =====================================================

  Future<ChatMessageModel>
      sendLocationMessage({
    required String roomId,
    required double latitude,
    required double longitude,
  }) async {
    return sendMessage(
      roomId: roomId,
      message:
          '$latitude,$longitude',
    );
  }

  // =====================================================
  // READ RECEIPTS
  // =====================================================

  Future<bool> markAsRead(
    String roomId,
  ) async {
    await ApiService.instance.patch(
      '/chat/room/${Uri.encodeComponent(roomId)}/read',
    );

    return true;
  }

  Future<bool> markRoomAsRead({
    required String roomId,
    required String bookingId,
  }) async {
    await ApiService.instance.patch(
      '/chat/room/${Uri.encodeComponent(roomId)}/read',
      data: {
        'bookingId': bookingId,
      },
    );

    return true;
  }

  // =====================================================
  // SOCKET PLACEHOLDERS
  // =====================================================

  Future<void> joinRoom({
    required String roomId,
    required String bookingId,
  }) async {}

  Future<void> leaveRoom(
    String roomId,
  ) async {}

  Future<void> startTyping({
    required String roomId,
    required String bookingId,
    required String receiverId,
  }) async {}

  Future<void> stopTyping({
    required String roomId,
    required String bookingId,
    required String receiverId,
  }) async {}

  // =====================================================
  // DELETE
  // =====================================================

  Future<bool> deleteMessage(
    String messageId,
  ) async {
    return true;
  }

  Future<bool> deleteRoom(
    String roomId,
  ) async {
    return true;
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<List<ChatMessageModel>>
      searchMessages({
    required String roomId,
    required String keyword,
  }) async {
    final messages =
        await getMessages(
      roomId,
    );

    return messages.where(
      (item) {
        return item.message
            .toLowerCase()
            .contains(
              keyword.toLowerCase(),
            );
      },
    ).toList();
  }

  // =====================================================
  // UNREAD COUNT
  // =====================================================

  Future<int> getUnreadCount() async {
    final response =
        await ApiService.instance.get(
      '/chat/unread-count',
    );

    return response.data['count'] ??
        response.data['unreadCount'] ??
        response.data['data']
                ?['count'] ??
        0;
  }
}