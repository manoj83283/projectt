import 'package:flutter/foundation.dart';

import '../core/network/api_service.dart';
import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

// =====================================================
// CHAT REPOSITORY
// =====================================================

class ChatRepository {
  ChatRepository._();

  static final ChatRepository _instance =
      ChatRepository._();

  static ChatRepository get instance {
    return _instance;
  }

  final ChatService _chatService =
      ChatService.instance;

  final ApiService _apiService =
      ApiService.instance;

  // =====================================================
  // VALUE HELPERS
  // =====================================================

  Map<String, dynamic> _asMap(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (
          key,
          dynamic item,
        ) {
          return MapEntry(
            key.toString(),
            item,
          );
        },
      );
    }

    return <String, dynamic>{};
  }

  String _normalizeRequiredString(
    String value,
    String fieldName,
  ) {
    final normalizedValue =
        value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError(
        '$fieldName is required.',
      );
    }

    return normalizedValue;
  }

  String _normalizeOptionalString(
    String? value,
  ) {
    return value?.trim() ?? '';
  }

  ChatMessageModel _parseMessageResponse(
    dynamic responseData,
  ) {
    if (responseData is ChatMessageModel) {
      return responseData;
    }

    final data = _asMap(
      responseData,
    );

    if (data.isEmpty) {
      throw const FormatException(
        'Invalid chat message response.',
      );
    }

    dynamic messageData =
        data['chatMessage'] ??
        data['messageData'] ??
        data['data'] ??
        data['message'];

    if (messageData is Map) {
      final nestedData =
          _asMap(
        messageData,
      );

      if (nestedData['message'] is Map) {
        messageData =
            nestedData['message'];
      } else if (
          nestedData['chatMessage'] is Map) {
        messageData =
            nestedData['chatMessage'];
      }
    }

    if (messageData is! Map) {
      final looksLikeMessage =
          data['_id'] != null ||
          data['id'] != null ||
          data['roomId'] != null ||
          data['chatRoomId'] != null ||
          data['senderId'] != null ||
          data['sender'] != null;

      if (looksLikeMessage) {
        messageData = data;
      }
    }

    if (messageData is! Map) {
      throw FormatException(
        data['message']?.toString() ??
            'Chat message was not returned by the server.',
      );
    }

    return ChatMessageModel.fromJson(
      Map<String, dynamic>.from(
        messageData,
      ),
    );
  }

  // =====================================================
  // GET CHAT ROOMS
  // =====================================================

  Future<List<dynamic>> getChatRooms() async {
    try {
      final result =
          await _chatService.getChatRooms();

      return List<dynamic>.from(
        result,
      );
    } catch (error) {
      debugPrint(
        'GET CHAT ROOMS ERROR: $error',
      );

      return <dynamic>[];
    }
  }

  // =====================================================
  // GET CHAT MESSAGES
  // =====================================================

  Future<List<ChatMessageModel>> getMessages(
    String chatRoomId,
  ) async {
    final normalizedRoomId =
        chatRoomId.trim();

    if (normalizedRoomId.isEmpty) {
      return <ChatMessageModel>[];
    }

    try {
      final result =
          await _chatService.getMessages(
        normalizedRoomId,
      );

      return List<ChatMessageModel>.from(
        result,
      );
    } catch (error) {
      debugPrint(
        'GET CHAT MESSAGES ERROR: $error',
      );

      return <ChatMessageModel>[];
    }
  }

  // =====================================================
  // GET PAGINATED MESSAGES
  // =====================================================

  Future<List<ChatMessageModel>>
      getPaginatedMessages({
    required String chatRoomId,
    int page = 1,
    int limit = 20,
  }) async {
    final normalizedRoomId =
        chatRoomId.trim();

    if (normalizedRoomId.isEmpty) {
      return <ChatMessageModel>[];
    }

    final normalizedPage =
        page < 1 ? 1 : page;

    final normalizedLimit =
        limit < 1
            ? 20
            : limit > 100
                ? 100
                : limit;

    try {
      final result =
          await _chatService
              .getPaginatedMessages(
        chatRoomId:
            normalizedRoomId,
        page:
            normalizedPage,
        limit:
            normalizedLimit,
      );

      return List<ChatMessageModel>.from(
        result,
      );
    } catch (error) {
      debugPrint(
        'GET PAGINATED CHAT MESSAGES ERROR: $error',
      );

      return <ChatMessageModel>[];
    }
  }

  // =====================================================
  // SEND TEXT MESSAGE
  //
  // Common endpoint:
  // POST /api/chat/send
  //
  // roomId      = conversation / socket room
  // receiverId  = actual receiving user MongoDB ID
  // bookingId   = optional booking
  // serviceId   = optional service
  // =====================================================

  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String receiverId,
    required String message,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) async {
    final normalizedRoomId =
        _normalizeRequiredString(
      roomId,
      'Chat room ID',
    );

    final normalizedReceiverId =
        _normalizeRequiredString(
      receiverId,
      'Receiver ID',
    );

    final normalizedMessage =
        _normalizeRequiredString(
      message,
      'Message',
    );

    final normalizedBookingId =
        _normalizeOptionalString(
      bookingId,
    );

    final normalizedServiceId =
        _normalizeOptionalString(
      serviceId,
    );

    try {
      final response =
          await _apiService.post(
        '/chat/send',
        data: <String, dynamic>{
          'roomId':
              normalizedRoomId,

          'receiverId':
              normalizedReceiverId,

          'message':
              normalizedMessage,

          'messageType':
              'text',

          if (normalizedBookingId.isNotEmpty)
            'bookingId':
                normalizedBookingId,

          if (normalizedServiceId.isNotEmpty)
            'serviceId':
                normalizedServiceId,

          'negotiationMode':
              negotiationMode,
        },
      );

      return _parseMessageResponse(
        response.data,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SEND CHAT MESSAGE ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      rethrow;
    }
  }

  // =====================================================
  // SEND IMAGE
  // =====================================================

  Future<ChatMessageModel> sendImageMessage({
    required String roomId,
    required String receiverId,
    required String imageUrl,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) async {
    final normalizedRoomId =
        _normalizeRequiredString(
      roomId,
      'Chat room ID',
    );

    final normalizedReceiverId =
        _normalizeRequiredString(
      receiverId,
      'Receiver ID',
    );

    final normalizedImageUrl =
        _normalizeRequiredString(
      imageUrl,
      'Image URL',
    );

    final normalizedBookingId =
        _normalizeOptionalString(
      bookingId,
    );

    final normalizedServiceId =
        _normalizeOptionalString(
      serviceId,
    );

    try {
      final response =
          await _apiService.post(
        '/chat/send',
        data: <String, dynamic>{
          'roomId':
              normalizedRoomId,

          'receiverId':
              normalizedReceiverId,

          'messageType':
              'image',

          'imageUrl':
              normalizedImageUrl,

          if (normalizedBookingId.isNotEmpty)
            'bookingId':
                normalizedBookingId,

          if (normalizedServiceId.isNotEmpty)
            'serviceId':
                normalizedServiceId,

          'negotiationMode':
              negotiationMode,
        },
      );

      return _parseMessageResponse(
        response.data,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SEND CHAT IMAGE ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      rethrow;
    }
  }

  // =====================================================
  // SEND VIDEO
  // =====================================================

  Future<ChatMessageModel> sendVideoMessage({
    required String roomId,
    required String receiverId,
    required String videoUrl,
    String? thumbnailUrl,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) async {
    final normalizedRoomId =
        _normalizeRequiredString(
      roomId,
      'Chat room ID',
    );

    final normalizedReceiverId =
        _normalizeRequiredString(
      receiverId,
      'Receiver ID',
    );

    final normalizedVideoUrl =
        _normalizeRequiredString(
      videoUrl,
      'Video URL',
    );

    final normalizedThumbnail =
        _normalizeOptionalString(
      thumbnailUrl,
    );

    final normalizedBookingId =
        _normalizeOptionalString(
      bookingId,
    );

    final normalizedServiceId =
        _normalizeOptionalString(
      serviceId,
    );

    try {
      final response =
          await _apiService.post(
        '/chat/send',
        data: <String, dynamic>{
          'roomId':
              normalizedRoomId,

          'receiverId':
              normalizedReceiverId,

          'messageType':
              'video',

          'videoUrl':
              normalizedVideoUrl,

          if (normalizedThumbnail.isNotEmpty)
            'thumbnailUrl':
                normalizedThumbnail,

          if (normalizedBookingId.isNotEmpty)
            'bookingId':
                normalizedBookingId,

          if (normalizedServiceId.isNotEmpty)
            'serviceId':
                normalizedServiceId,

          'negotiationMode':
              negotiationMode,
        },
      );

      return _parseMessageResponse(
        response.data,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SEND CHAT VIDEO ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      rethrow;
    }
  }

  // =====================================================
  // SEND FILE
  // =====================================================

  Future<ChatMessageModel> sendFileMessage({
    required String roomId,
    required String receiverId,
    required String fileUrl,
    required String fileName,
    required double fileSize,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) async {
    final normalizedRoomId =
        _normalizeRequiredString(
      roomId,
      'Chat room ID',
    );

    final normalizedReceiverId =
        _normalizeRequiredString(
      receiverId,
      'Receiver ID',
    );

    final normalizedFileUrl =
        _normalizeRequiredString(
      fileUrl,
      'File URL',
    );

    final normalizedFileName =
        _normalizeRequiredString(
      fileName,
      'File name',
    );

    final normalizedBookingId =
        _normalizeOptionalString(
      bookingId,
    );

    final normalizedServiceId =
        _normalizeOptionalString(
      serviceId,
    );

    if (!fileSize.isFinite ||
        fileSize < 0) {
      throw ArgumentError(
        'A valid file size is required.',
      );
    }

    try {
      final response =
          await _apiService.post(
        '/chat/send',
        data: <String, dynamic>{
          'roomId':
              normalizedRoomId,

          'receiverId':
              normalizedReceiverId,

          'messageType':
              'file',

          'fileUrl':
              normalizedFileUrl,

          'fileName':
              normalizedFileName,

          'fileSize':
              fileSize,

          if (normalizedBookingId.isNotEmpty)
            'bookingId':
                normalizedBookingId,

          if (normalizedServiceId.isNotEmpty)
            'serviceId':
                normalizedServiceId,

          'negotiationMode':
              negotiationMode,
        },
      );

      return _parseMessageResponse(
        response.data,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SEND CHAT FILE ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      rethrow;
    }
  }

  // =====================================================
  // SEND LOCATION
  // =====================================================

  Future<ChatMessageModel> sendLocationMessage({
    required String roomId,
    required String receiverId,
    required double latitude,
    required double longitude,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) async {
    final normalizedRoomId =
        _normalizeRequiredString(
      roomId,
      'Chat room ID',
    );

    final normalizedReceiverId =
        _normalizeRequiredString(
      receiverId,
      'Receiver ID',
    );

    final normalizedBookingId =
        _normalizeOptionalString(
      bookingId,
    );

    final normalizedServiceId =
        _normalizeOptionalString(
      serviceId,
    );

    if (!latitude.isFinite ||
        latitude < -90 ||
        latitude > 90) {
      throw ArgumentError(
        'A valid latitude is required.',
      );
    }

    if (!longitude.isFinite ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError(
        'A valid longitude is required.',
      );
    }

    try {
      final response =
          await _apiService.post(
        '/chat/send',
        data: <String, dynamic>{
          'roomId':
              normalizedRoomId,

          'receiverId':
              normalizedReceiverId,

          'messageType':
              'location',

          'latitude':
              latitude,

          'longitude':
              longitude,

          if (normalizedBookingId.isNotEmpty)
            'bookingId':
                normalizedBookingId,

          if (normalizedServiceId.isNotEmpty)
            'serviceId':
                normalizedServiceId,

          'negotiationMode':
              negotiationMode,
        },
      );

      return _parseMessageResponse(
        response.data,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'SEND CHAT LOCATION ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      rethrow;
    }
  }

  // =====================================================
  // MARK MESSAGE AS READ
  // =====================================================

  Future<bool> markAsRead(
    String messageId,
  ) async {
    final normalizedMessageId =
        messageId.trim();

    if (normalizedMessageId.isEmpty) {
      return false;
    }

    try {
      return await _chatService.markAsRead(
        normalizedMessageId,
      );
    } catch (error) {
      debugPrint(
        'MARK CHAT MESSAGE READ ERROR: $error',
      );

      return false;
    }
  }

  // =====================================================
  // MARK ROOM AS READ
  // =====================================================

  Future<bool> markRoomAsRead(
    String roomId,
  ) async {
    final normalizedRoomId =
        roomId.trim();

    if (normalizedRoomId.isEmpty) {
      return false;
    }

    try {
      return await _chatService.markRoomAsRead(
        normalizedRoomId,
      );
    } catch (error) {
      debugPrint(
        'MARK CHAT ROOM READ ERROR: $error',
      );

      return false;
    }
  }

  // =====================================================
  // DELETE MESSAGE
  // =====================================================

  Future<bool> deleteMessage(
    String messageId,
  ) async {
    final normalizedMessageId =
        messageId.trim();

    if (normalizedMessageId.isEmpty) {
      return false;
    }

    try {
      return await _chatService.deleteMessage(
        normalizedMessageId,
      );
    } catch (error) {
      debugPrint(
        'DELETE CHAT MESSAGE ERROR: $error',
      );

      return false;
    }
  }

  // =====================================================
  // SEARCH MESSAGES
  // =====================================================

  Future<List<ChatMessageModel>> searchMessages({
    required String roomId,
    required String keyword,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    final normalizedKeyword =
        keyword.trim();

    if (normalizedRoomId.isEmpty ||
        normalizedKeyword.isEmpty) {
      return <ChatMessageModel>[];
    }

    try {
      final result =
          await _chatService.searchMessages(
        roomId:
            normalizedRoomId,
        keyword:
            normalizedKeyword,
      );

      return List<ChatMessageModel>.from(
        result,
      );
    } catch (error) {
      debugPrint(
        'SEARCH CHAT MESSAGES ERROR: $error',
      );

      return <ChatMessageModel>[];
    }
  }

  // =====================================================
  // UNREAD COUNT
  // =====================================================

  Future<int> getUnreadCount() async {
    try {
      return await _chatService
          .getUnreadCount();
    } catch (error) {
      debugPrint(
        'GET CHAT UNREAD COUNT ERROR: $error',
      );

      return 0;
    }
  }

  // =====================================================
  // CHAT ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getChatAnalytics() async {
    try {
      final result =
          await _chatService
              .getChatAnalytics();

      return Map<String, dynamic>.from(
        result,
      );
    } catch (error) {
      debugPrint(
        'GET CHAT ANALYTICS ERROR: $error',
      );

      rethrow;
    }
  }

  // =====================================================
  // BLOCK USER
  // =====================================================

  Future<bool> blockUser(
    String userId,
  ) async {
    final normalizedUserId =
        userId.trim();

    if (normalizedUserId.isEmpty) {
      return false;
    }

    try {
      return await _chatService.blockUser(
        normalizedUserId,
      );
    } catch (error) {
      debugPrint(
        'BLOCK CHAT USER ERROR: $error',
      );

      return false;
    }
  }

  // =====================================================
  // UNBLOCK USER
  // =====================================================

  Future<bool> unblockUser(
    String userId,
  ) async {
    final normalizedUserId =
        userId.trim();

    if (normalizedUserId.isEmpty) {
      return false;
    }

    try {
      return await _chatService.unblockUser(
        normalizedUserId,
      );
    } catch (error) {
      debugPrint(
        'UNBLOCK CHAT USER ERROR: $error',
      );

      return false;
    }
  }
}