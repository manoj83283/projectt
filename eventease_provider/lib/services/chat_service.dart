import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/chat_message_model.dart';

class ChatService {
  ChatService._();

  static final ChatService _instance =
      ChatService._();

  static ChatService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // GET CHAT ROOMS
  // =========================

  Future<List<dynamic>> getChatRooms() async {
    try {
      final response = await _apiService.get(
        '/provider/chat/rooms',
      );

      return response['data'] ?? [];
    } catch (e) {
      log('Get Chat Rooms Error: $e');
      rethrow;
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
      final response = await _apiService.get(
        '/provider/chat/$chatRoomId/messages',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) =>
                ChatMessageModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Get Messages Error: $e');
      rethrow;
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
      final response = await _apiService.get(
        '/provider/chat/$chatRoomId/messages?page=$page&limit=$limit',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) =>
                ChatMessageModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Pagination Error: $e');
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
      final response = await _apiService.post(
        '/provider/chat/send',
        body: {
          'receiverId': receiverId,
          'message': message,
          'messageType': 'text',
        },
      );

      return ChatMessageModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Send Message Error: $e');
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
      final response = await _apiService.post(
        '/provider/chat/send',
        body: {
          'receiverId': receiverId,
          'mediaUrl': imageUrl,
          'messageType': 'image',
        },
      );

      return ChatMessageModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Send Image Error: $e');
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
      final response = await _apiService.post(
        '/provider/chat/send',
        body: {
          'receiverId': receiverId,
          'mediaUrl': videoUrl,
          'thumbnailUrl': thumbnailUrl,
          'messageType': 'video',
        },
      );

      return ChatMessageModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Send Video Error: $e');
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
      final response = await _apiService.post(
        '/provider/chat/send',
        body: {
          'receiverId': receiverId,
          'mediaUrl': fileUrl,
          'fileName': fileName,
          'fileSize': fileSize,
          'messageType': 'file',
        },
      );

      return ChatMessageModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Send File Error: $e');
      rethrow;
    }
  }

  // =========================
  // SEND LOCATION
  // =========================

  Future<ChatMessageModel>
      sendLocationMessage({
    required String receiverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiService.post(
        '/provider/chat/send',
        body: {
          'receiverId': receiverId,
          'latitude': latitude,
          'longitude': longitude,
          'messageType': 'location',
        },
      );

      return ChatMessageModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log('Send Location Error: $e');
      rethrow;
    }
  }

  // =========================
  // MARK MESSAGE AS READ
  // =========================

  Future<bool> markAsRead(
    String messageId,
  ) async {
    try {
      await _apiService.patch(
        '/provider/chat/message/$messageId/read',
      );

      return true;
    } catch (e) {
      log('Read Message Error: $e');
      return false;
    }
  }

  // =========================
  // MARK CHAT ROOM READ
  // =========================

  Future<bool> markRoomAsRead(
    String roomId,
  ) async {
    try {
      await _apiService.patch(
        '/provider/chat/room/$roomId/read',
      );

      return true;
    } catch (e) {
      log('Read Room Error: $e');
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
      await _apiService.delete(
        '/provider/chat/message/$messageId',
      );

      return true;
    } catch (e) {
      log('Delete Message Error: $e');
      return false;
    }
  }

  // =========================
  // SEARCH CHAT
  // =========================

  Future<List<ChatMessageModel>>
      searchMessages({
    required String roomId,
    required String keyword,
  }) async {
    try {
      final response = await _apiService.get(
        '/provider/chat/$roomId/search?keyword=$keyword',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) =>
                ChatMessageModel.fromJson(e),
          )
          .toList();
    } catch (e) {
      log('Search Chat Error: $e');
      return [];
    }
  }

  // =========================
  // UNREAD COUNT
  // =========================

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        '/provider/chat/unread-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      log('Unread Count Error: $e');
      return 0;
    }
  }

  // =========================
  // CHAT ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getChatAnalytics() async {
    try {
      return await _apiService.get(
        '/provider/chat/analytics',
      );
    } catch (e) {
      log('Chat Analytics Error: $e');
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
      await _apiService.post(
        '/provider/chat/block-user',
        body: {
          'userId': userId,
        },
      );

      return true;
    } catch (e) {
      log('Block User Error: $e');
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
      await _apiService.post(
        '/provider/chat/unblock-user',
        body: {
          'userId': userId,
        },
      );

      return true;
    } catch (e) {
      log('Unblock User Error: $e');
      return false;
    }
  }
}