import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import 'api_service.dart';

class ChatService {
  ChatService._();

  static final ChatService instance =
      ChatService._();

  // ==========================================
  // GET CHAT ROOMS
  // ==========================================

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

    final List rooms =
        response.data['data'] ??
            response.data['rooms'] ??
            [];

    return rooms
        .map(
          (e) => ChatRoomModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET CHAT ROOM
  // ==========================================

  Future<ChatRoomModel> getChatRoom(
    String roomId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/chat/rooms/$roomId',
    );

    return ChatRoomModel.fromMap(
      response.data['data'] ??
          response.data['room'],
    );
  }

  // ==========================================
  // CREATE CHAT ROOM
  // ==========================================

  Future<ChatRoomModel> createChatRoom({
    required String providerId,
    required String bookingId,
  }) async {
    final response =
        await ApiService.instance.post(
      '/chat/rooms',
      data: {
        'providerId': providerId,
        'bookingId': bookingId,
      },
    );

    return ChatRoomModel.fromMap(
      response.data['data'] ??
          response.data['room'],
    );
  }

  // ==========================================
  // GET MESSAGES
  // ==========================================

  Future<List<ChatMessageModel>>
      getMessages(
    String roomId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response =
        await ApiService.instance.get(
      '/chat/rooms/$roomId/messages',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List messages =
        response.data['data'] ??
            response.data['messages'] ??
            [];

    return messages
        .map(
          (e) => ChatMessageModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // SEND TEXT MESSAGE
  // ==========================================

  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String message,
  }) async {
    final response =
        await ApiService.instance.post(
      '/chat/messages',
      data: {
        'roomId': roomId,
        'message': message,
        'type': 'text',
      },
    );

    return ChatMessageModel.fromMap(
      response.data['data'] ??
          response.data['message'],
    );
  }

  // ==========================================
  // SEND IMAGE MESSAGE
  // ==========================================

  Future<ChatMessageModel>
      sendImageMessage({
    required String roomId,
    required String imageUrl,
  }) async {
    final response =
        await ApiService.instance.post(
      '/chat/messages',
      data: {
        'roomId': roomId,
        'message': imageUrl,
        'type': 'image',
      },
    );

    return ChatMessageModel.fromMap(
      response.data['data'] ??
          response.data['message'],
    );
  }

  // ==========================================
  // SEND LOCATION MESSAGE
  // ==========================================

  Future<ChatMessageModel>
      sendLocationMessage({
    required String roomId,
    required double latitude,
    required double longitude,
  }) async {
    final response =
        await ApiService.instance.post(
      '/chat/messages',
      data: {
        'roomId': roomId,
        'type': 'location',
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return ChatMessageModel.fromMap(
      response.data['data'] ??
          response.data['message'],
    );
  }

  // ==========================================
  // MARK AS READ
  // ==========================================

  Future<bool> markAsRead(
    String roomId,
  ) async {
    await ApiService.instance.patch(
      '/chat/rooms/$roomId/read',
    );

    return true;
  }

  // ==========================================
  // DELETE MESSAGE
  // ==========================================

  Future<bool> deleteMessage(
    String messageId,
  ) async {
    await ApiService.instance.delete(
      '/chat/messages/$messageId',
    );

    return true;
  }

  // ==========================================
  // DELETE CHAT ROOM
  // ==========================================

  Future<bool> deleteRoom(
    String roomId,
  ) async {
    await ApiService.instance.delete(
      '/chat/rooms/$roomId',
    );

    return true;
  }

  // ==========================================
  // SEARCH CHAT
  // ==========================================

  Future<List<ChatMessageModel>>
      searchMessages({
    required String roomId,
    required String keyword,
  }) async {
    final response =
        await ApiService.instance.get(
      '/chat/search',
      queryParameters: {
        'roomId': roomId,
        'keyword': keyword,
      },
    );

    final List messages =
        response.data['data'] ??
            response.data['messages'] ??
            [];

    return messages
        .map(
          (e) => ChatMessageModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // UNREAD COUNT
  // ==========================================

  Future<int> getUnreadCount() async {
    final response =
        await ApiService.instance.get(
      '/chat/unread-count',
    );

    return response.data['count'] ??
        response.data['data']
            ?['count'] ??
        0;
  }
}