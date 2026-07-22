import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  ChatRepository._();

  static final ChatRepository instance =
      ChatRepository._();

  final ChatService _chatService =
      ChatService.instance;

  // ==========================================
  // GET CHAT ROOMS
  // ==========================================

  Future<List<ChatRoomModel>> getChatRooms({
    int page = 1,
    int limit = 20,
  }) async {
    return await _chatService.getChatRooms(
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // GET CHAT ROOM
  // ==========================================

  Future<ChatRoomModel> getChatRoom(
    String roomId,
  ) async {
    return await _chatService.getChatRoom(
      roomId,
    );
  }

  // ==========================================
  // CREATE CHAT ROOM
  // ==========================================

  Future<ChatRoomModel> createChatRoom({
    required String providerId,
    required String bookingId,
  }) async {
    return await _chatService.createChatRoom(
      providerId: providerId,
      bookingId: bookingId,
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
    return await _chatService.getMessages(
      roomId,
      page: page,
      limit: limit,
    );
  }

  // ==========================================
  // SEND TEXT MESSAGE
  // ==========================================

  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String message,
  }) async {
    return await _chatService.sendMessage(
      roomId: roomId,
      message: message,
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
    return await _chatService
        .sendImageMessage(
      roomId: roomId,
      imageUrl: imageUrl,
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
    return await _chatService
        .sendLocationMessage(
      roomId: roomId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // ==========================================
  // MARK AS READ
  // ==========================================

  Future<bool> markAsRead(
    String roomId,
  ) async {
    return await _chatService.markAsRead(
      roomId,
    );
  }

  // ==========================================
  // DELETE MESSAGE
  // ==========================================

  Future<bool> deleteMessage(
    String messageId,
  ) async {
    return await _chatService.deleteMessage(
      messageId,
    );
  }

  // ==========================================
  // DELETE ROOM
  // ==========================================

  Future<bool> deleteRoom(
    String roomId,
  ) async {
    return await _chatService.deleteRoom(
      roomId,
    );
  }

  // ==========================================
  // SEARCH MESSAGES
  // ==========================================

  Future<List<ChatMessageModel>>
      searchMessages({
    required String roomId,
    required String keyword,
  }) async {
    return await _chatService.searchMessages(
      roomId: roomId,
      keyword: keyword,
    );
  }

  // ==========================================
  // UNREAD COUNT
  // ==========================================

  Future<int> getUnreadCount() async {
    return await _chatService.getUnreadCount();
  }
}