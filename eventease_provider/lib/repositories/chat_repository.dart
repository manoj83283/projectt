import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

class ChatRepository {
  ChatRepository._();

  static final ChatRepository _instance =
      ChatRepository._();

  static ChatRepository get instance =>
      _instance;

  final ChatService _chatService =
      ChatService.instance;

  // =========================
  // GET CHAT ROOMS
  // =========================

  Future<List<dynamic>> getChatRooms() async {
    try {
      return await _chatService
          .getChatRooms();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET CHAT MESSAGES
  // =========================

  Future<List<ChatMessageModel>>
      getMessages(
    String chatRoomId,
  ) async {
    try {
      return await _chatService
          .getMessages(chatRoomId);
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET PAGINATED MESSAGES
  // =========================

  Future<List<ChatMessageModel>>
      getPaginatedMessages({
    required String chatRoomId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _chatService
          .getPaginatedMessages(
        chatRoomId: chatRoomId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // SEND TEXT MESSAGE
  // =========================

  Future<ChatMessageModel> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      return await _chatService
          .sendMessage(
        receiverId: receiverId,
        message: message,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // SEND IMAGE MESSAGE
  // =========================

  Future<ChatMessageModel>
      sendImageMessage({
    required String receiverId,
    required String imageUrl,
  }) async {
    try {
      return await _chatService
          .sendImageMessage(
        receiverId: receiverId,
        imageUrl: imageUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // SEND VIDEO MESSAGE
  // =========================

  Future<ChatMessageModel>
      sendVideoMessage({
    required String receiverId,
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    try {
      return await _chatService
          .sendVideoMessage(
        receiverId: receiverId,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // SEND FILE MESSAGE
  // =========================

  Future<ChatMessageModel>
      sendFileMessage({
    required String receiverId,
    required String fileUrl,
    required String fileName,
    required double fileSize,
  }) async {
    try {
      return await _chatService
          .sendFileMessage(
        receiverId: receiverId,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // SEND LOCATION MESSAGE
  // =========================

  Future<ChatMessageModel>
      sendLocationMessage({
    required String receiverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _chatService
          .sendLocationMessage(
        receiverId: receiverId,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // MARK AS READ
  // =========================

  Future<bool> markAsRead(
    String messageId,
  ) async {
    try {
      return await _chatService
          .markAsRead(messageId);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // MARK ROOM AS READ
  // =========================

  Future<bool> markRoomAsRead(
    String roomId,
  ) async {
    try {
      return await _chatService
          .markRoomAsRead(roomId);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // DELETE MESSAGE
  // =========================

  Future<bool> deleteMessage(
    String messageId,
  ) async {
    try {
      return await _chatService
          .deleteMessage(messageId);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // SEARCH MESSAGES
  // =========================

  Future<List<ChatMessageModel>>
      searchMessages({
    required String roomId,
    required String keyword,
  }) async {
    try {
      return await _chatService
          .searchMessages(
        roomId: roomId,
        keyword: keyword,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET UNREAD COUNT
  // =========================

  Future<int> getUnreadCount() async {
    try {
      return await _chatService
          .getUnreadCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // CHAT ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getChatAnalytics() async {
    try {
      return await _chatService
          .getChatAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // BLOCK USER
  // =========================

  Future<bool> blockUser(
    String userId,
  ) async {
    try {
      return await _chatService
          .blockUser(userId);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // UNBLOCK USER
  // =========================

  Future<bool> unblockUser(
    String userId,
  ) async {
    try {
      return await _chatService
          .unblockUser(userId);
    } catch (e) {
      return false;
    }
  }
}