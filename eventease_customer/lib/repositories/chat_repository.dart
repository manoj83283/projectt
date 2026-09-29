import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  ChatRepository._();

  static final ChatRepository instance =
      ChatRepository._();

  final ChatService _chatService =
      ChatService.instance;

  // =====================================================
  // CHAT ROOMS
  // =====================================================

  Future<List<ChatRoomModel>> getChatRooms({
    int page = 1,
    int limit = 20,
  }) async {
    return _chatService.getChatRooms(
      page: page,
      limit: limit,
    );
  }

  Future<ChatRoomModel> getChatRoom(
    String roomId,
  ) async {
    return _chatService.getChatRoom(
      roomId,
    );
  }

  Future<ChatRoomModel> createChatRoom({
    required String providerId,
    required String bookingId,
  }) async {
    return _chatService.createChatRoom(
      providerId: providerId,
      bookingId: bookingId,
    );
  }

  // =====================================================
  // BOOKING ROOM MESSAGES
  // =====================================================

  Future<List<ChatMessageModel>>
      getMessages(
    String roomId, {
    int page = 1,
    int limit = 50,
  }) async {
    return _chatService.getMessages(
      roomId,
      page: page,
      limit: limit,
    );
  }

  Future<List<ChatMessageModel>>
      loadRoomMessages({
    required String roomId,
    String? bookingId,
    int page = 1,
    int limit = 50,
  }) async {
    return _chatService.getMessages(
      roomId,
      page: page,
      limit: limit,
    );
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================

  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String message,
  }) async {
    return _chatService.sendMessage(
      roomId: roomId,
      message: message,
    );
  }

  Future<ChatMessageModel> sendRoomMessage({
    required String roomId,
    required String bookingId,
    required String receiverId,
    required String message,
  }) async {
    return _chatService.sendRoomMessage(
      roomId: roomId,
      bookingId: bookingId,
      receiverId: receiverId,
      message: message,
    );
  }

  // =====================================================
  // IMAGE
  // =====================================================

  Future<ChatMessageModel>
      sendImageMessage({
    required String roomId,
    required String imageUrl,
  }) async {
    return _chatService.sendImageMessage(
      roomId: roomId,
      imageUrl: imageUrl,
    );
  }

  // =====================================================
  // LOCATION
  // =====================================================

  Future<ChatMessageModel>
      sendLocationMessage({
    required String roomId,
    required double latitude,
    required double longitude,
  }) async {
    return _chatService.sendLocationMessage(
      roomId: roomId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // =====================================================
  // READ RECEIPTS
  // =====================================================

  Future<bool> markAsRead(
    String roomId,
  ) async {
    return _chatService.markAsRead(
      roomId,
    );
  }

  Future<bool> markRoomAsRead({
    required String roomId,
    required String bookingId,
  }) async {
    return _chatService.markRoomAsRead(
      roomId: roomId,
      bookingId: bookingId,
    );
  }

  // =====================================================
  // SOCKET METHODS
  // =====================================================

  Future<void> joinRoom({
    required String roomId,
    required String bookingId,
  }) async {
    await _chatService.joinRoom(
      roomId: roomId,
      bookingId: bookingId,
    );
  }

  Future<void> leaveRoom(
    String roomId,
  ) async {
    await _chatService.leaveRoom(
      roomId,
    );
  }

  Future<void> startTyping({
    required String roomId,
    required String bookingId,
    required String receiverId,
  }) async {
    await _chatService.startTyping(
      roomId: roomId,
      bookingId: bookingId,
      receiverId: receiverId,
    );
  }

  Future<void> stopTyping({
    required String roomId,
    required String bookingId,
    required String receiverId,
  }) async {
    await _chatService.stopTyping(
      roomId: roomId,
      bookingId: bookingId,
      receiverId: receiverId,
    );
  }

  // =====================================================
  // DELETE MESSAGE
  // =====================================================

  Future<bool> deleteMessage(
    String messageId,
  ) async {
    return _chatService.deleteMessage(
      messageId,
    );
  }

  // =====================================================
  // DELETE ROOM
  // =====================================================

  Future<bool> deleteRoom(
    String roomId,
  ) async {
    return _chatService.deleteRoom(
      roomId,
    );
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<List<ChatMessageModel>>
      searchMessages({
    required String roomId,
    required String keyword,
  }) async {
    return _chatService.searchMessages(
      roomId: roomId,
      keyword: keyword,
    );
  }

  // =====================================================
  // UNREAD
  // =====================================================

  Future<int> getUnreadCount() async {
    return _chatService.getUnreadCount();
  }
}