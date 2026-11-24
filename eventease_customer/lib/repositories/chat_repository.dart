import 'package:flutter/foundation.dart';

import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../services/api_service.dart';
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
    final normalizedRoomId =
        roomId.trim();

    if (normalizedRoomId.isEmpty) {
      throw ArgumentError(
        'Room ID is required.',
      );
    }

    return _chatService.getChatRoom(
      normalizedRoomId,
    );
  }

  // =====================================================
  // CREATE BOOKING CHAT ROOM
  // =====================================================

  Future<ChatRoomModel> createChatRoom({
    required String providerId,
    required String bookingId,
  }) async {
    final normalizedProviderId =
        providerId.trim();

    final normalizedBookingId =
        bookingId.trim();

    if (normalizedProviderId.isEmpty) {
      throw ArgumentError(
        'Provider ID is required.',
      );
    }

    if (normalizedBookingId.isEmpty) {
      throw ArgumentError(
        'Booking ID is required.',
      );
    }

    return _chatService.createChatRoom(
      providerId: normalizedProviderId,
      bookingId: normalizedBookingId,
    );
  }

  // =====================================================
  // OPEN PRE-BOOKING NEGOTIATION
  //
  // POST /api/chat/negotiation
  //
  // Negotiation does NOT require:
  //
  // bookingId
  // accepted booking
  // provider arrival
  // OTP verification
  // =====================================================

  Future<ChatRoomModel> openNegotiation({
    required String serviceId,
    required String providerId,
    required String topic,
    String? bookingDate,
    String? bookingTime,
  }) async {
    final normalizedServiceId =
        serviceId.trim();

    final normalizedProviderId =
        providerId.trim();

    final normalizedTopic =
        topic.trim();

    if (normalizedServiceId.isEmpty) {
      throw ArgumentError(
        'Service ID is required.',
      );
    }

    if (normalizedProviderId.isEmpty) {
      throw ArgumentError(
        'Provider ID is required.',
      );
    }

    if (normalizedTopic.isEmpty) {
      throw ArgumentError(
        'Negotiation topic is required.',
      );
    }

    try {
      final response =
          await ApiService.instance.post(
        '/chat/negotiation',
        data: <String, dynamic>{
          'serviceId':
              normalizedServiceId,

          'providerId':
              normalizedProviderId,

          'topic':
              normalizedTopic,

          if (bookingDate != null &&
              bookingDate.trim().isNotEmpty)
            'bookingDate':
                bookingDate.trim(),

          if (bookingTime != null &&
              bookingTime.trim().isNotEmpty)
            'bookingTime':
                bookingTime.trim(),
        },
      );

      // =================================================
      // IMPORTANT
      //
      // ApiService.post() returns Response<dynamic>.
      //
      // Parse response.data, NOT response.
      // =================================================

      final dynamic responseData =
          response.data;

      if (responseData is! Map) {
        throw const FormatException(
          'Invalid negotiation chat response.',
        );
      }

      final data =
          Map<String, dynamic>.from(
        responseData,
      );

      /*
       * Support common backend response shapes:
       *
       * {
       *   "chatRoom": {...}
       * }
       *
       * {
       *   "room": {...}
       * }
       *
       * {
       *   "conversation": {...}
       * }
       *
       * {
       *   "negotiation": {...}
       * }
       *
       * {
       *   "data": {...}
       * }
       *
       * or the room object directly.
       */

      dynamic roomData =
          data['chatRoom'] ??
              data['room'] ??
              data['conversation'] ??
              data['negotiation'] ??
              data['data'];

      // =================================================
      // NESTED WRAPPER:
      //
      // {
      //   "data": {
      //     "chatRoom": {...}
      //   }
      // }
      // =================================================

      if (roomData is Map &&
          roomData['chatRoom'] is Map) {
        roomData =
            roomData['chatRoom'];
      }

      // =================================================
      // NESTED WRAPPER:
      //
      // {
      //   "data": {
      //     "room": {...}
      //   }
      // }
      // =================================================

      if (roomData is Map &&
          roomData['room'] is Map) {
        roomData =
            roomData['room'];
      }

      // =================================================
      // NESTED CONVERSATION
      // =================================================

      if (roomData is Map &&
          roomData['conversation'] is Map) {
        roomData =
            roomData['conversation'];
      }

      // =================================================
      // DIRECT ROOM RESPONSE
      //
      // {
      //   "_id": "...",
      //   "roomId": "negotiation:...",
      //   ...
      // }
      // =================================================

      if (roomData is! Map) {
        final hasRoomIdentity =
            data['_id'] != null ||
                data['id'] != null ||
                data['roomId'] != null ||
                data['chatRoomId'] != null;

        if (hasRoomIdentity) {
          roomData =
              data;
        } else {
          throw FormatException(
            data['message']?.toString() ??
                'Negotiation chat room was not returned by the server.',
          );
        }
      }

      final roomMap =
          Map<String, dynamic>.from(
        roomData,
      );

      return ChatRoomModel.fromMap(
        roomMap,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'OPEN NEGOTIATION ERROR: $error',
      );

      debugPrint(
        '$stackTrace',
      );

      rethrow;
    }
  }

  // =====================================================
  // GET ROOM MESSAGES
  //
  // Works for:
  //
  // negotiation:<roomId>
  //
  // booking:<bookingId>
  // =====================================================

  Future<List<ChatMessageModel>> getMessages(
    String roomId, {
    int page = 1,
    int limit = 50,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    if (normalizedRoomId.isEmpty) {
      throw ArgumentError(
        'Room ID is required.',
      );
    }

    return _chatService.getMessages(
      normalizedRoomId,
      page: page,
      limit: limit,
    );
  }

  // =====================================================
  // COMPATIBILITY MESSAGE LOADER
  //
  // bookingId is optional because negotiation rooms
  // exist before Booking creation.
  // =====================================================

  Future<List<ChatMessageModel>> loadRoomMessages({
    required String roomId,
    String? bookingId,
    int page = 1,
    int limit = 50,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    if (normalizedRoomId.isEmpty) {
      throw ArgumentError(
        'Room ID is required.',
      );
    }

    return _chatService.getMessages(
      normalizedRoomId,
      page: page,
      limit: limit,
    );
  }

  // =====================================================
  // SEND TEXT MESSAGE
  //
  // Common room-based sending.
  //
  // Negotiation:
  // negotiation:<id>
  //
  // Booking:
  // booking:<bookingId>
  // =====================================================

  Future<ChatMessageModel> sendMessage({
    required String roomId,
    required String message,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    final normalizedMessage =
        message.trim();

    if (normalizedRoomId.isEmpty) {
      throw ArgumentError(
        'Room ID is required.',
      );
    }

    if (normalizedMessage.isEmpty) {
      throw ArgumentError(
        'Message cannot be empty.',
      );
    }

    return _chatService.sendMessage(
      roomId: normalizedRoomId,
      message: normalizedMessage,
    );
  }

  // =====================================================
  // LEGACY BOOKING SEND
  //
  // Keep temporarily for old Booking Chat screens.
  //
  // New code should prefer:
  //
  // sendMessage(
  //   roomId: roomId,
  //   message: message,
  // )
  // =====================================================

  Future<ChatMessageModel> sendRoomMessage({
    required String roomId,
    required String bookingId,
    required String receiverId,
    required String message,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    final normalizedBookingId =
        bookingId.trim();

    final normalizedReceiverId =
        receiverId.trim();

    final normalizedMessage =
        message.trim();

    if (normalizedRoomId.isEmpty) {
      throw ArgumentError(
        'Room ID is required.',
      );
    }

    if (normalizedBookingId.isEmpty) {
      throw ArgumentError(
        'Booking ID is required.',
      );
    }

    if (normalizedReceiverId.isEmpty) {
      throw ArgumentError(
        'Receiver ID is required.',
      );
    }

    if (normalizedMessage.isEmpty) {
      throw ArgumentError(
        'Message cannot be empty.',
      );
    }

    return _chatService.sendRoomMessage(
      roomId: normalizedRoomId,
      bookingId: normalizedBookingId,
      receiverId: normalizedReceiverId,
      message: normalizedMessage,
    );
  }

  // =====================================================
  // IMAGE
  // =====================================================

  Future<ChatMessageModel> sendImageMessage({
    required String roomId,
    required String imageUrl,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    final normalizedImageUrl =
        imageUrl.trim();

    if (normalizedRoomId.isEmpty) {
      throw ArgumentError(
        'Room ID is required.',
      );
    }

    if (normalizedImageUrl.isEmpty) {
      throw ArgumentError(
        'Image URL is required.',
      );
    }

    return _chatService.sendImageMessage(
      roomId: normalizedRoomId,
      imageUrl: normalizedImageUrl,
    );
  }

  // =====================================================
  // LOCATION
  // =====================================================

  Future<ChatMessageModel> sendLocationMessage({
    required String roomId,
    required double latitude,
    required double longitude,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    if (normalizedRoomId.isEmpty) {
      throw ArgumentError(
        'Room ID is required.',
      );
    }

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

    return _chatService.sendLocationMessage(
      roomId: normalizedRoomId,
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
    final normalizedRoomId =
        roomId.trim();

    if (normalizedRoomId.isEmpty) {
      return false;
    }

    return _chatService.markAsRead(
      normalizedRoomId,
    );
  }

  // =====================================================
  // BOOKING ROOM READ RECEIPT
  //
  // Compatibility method for existing Booking Chat.
  // =====================================================

  Future<bool> markRoomAsRead({
    required String roomId,
    required String bookingId,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    final normalizedBookingId =
        bookingId.trim();

    if (normalizedRoomId.isEmpty) {
      return false;
    }

    if (normalizedBookingId.isEmpty) {
      return false;
    }

    return _chatService.markRoomAsRead(
      roomId: normalizedRoomId,
      bookingId: normalizedBookingId,
    );
  }

  // =====================================================
  // JOIN BOOKING ROOM
  // =====================================================

  Future<void> joinRoom({
    required String roomId,
    required String bookingId,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    final normalizedBookingId =
        bookingId.trim();

    if (normalizedRoomId.isEmpty ||
        normalizedBookingId.isEmpty) {
      return;
    }

    await _chatService.joinRoom(
      roomId: normalizedRoomId,
      bookingId: normalizedBookingId,
    );
  }

  // =====================================================
  // LEAVE ROOM
  // =====================================================

  Future<void> leaveRoom(
    String roomId,
  ) async {
    final normalizedRoomId =
        roomId.trim();

    if (normalizedRoomId.isEmpty) {
      return;
    }

    await _chatService.leaveRoom(
      normalizedRoomId,
    );
  }

  // =====================================================
  // START TYPING
  //
  // Legacy Booking Chat socket method.
  // =====================================================

  Future<void> startTyping({
    required String roomId,
    required String bookingId,
    required String receiverId,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    final normalizedBookingId =
        bookingId.trim();

    final normalizedReceiverId =
        receiverId.trim();

    if (normalizedRoomId.isEmpty ||
        normalizedBookingId.isEmpty ||
        normalizedReceiverId.isEmpty) {
      return;
    }

    await _chatService.startTyping(
      roomId: normalizedRoomId,
      bookingId: normalizedBookingId,
      receiverId: normalizedReceiverId,
    );
  }

  // =====================================================
  // STOP TYPING
  // =====================================================

  Future<void> stopTyping({
    required String roomId,
    required String bookingId,
    required String receiverId,
  }) async {
    final normalizedRoomId =
        roomId.trim();

    final normalizedBookingId =
        bookingId.trim();

    final normalizedReceiverId =
        receiverId.trim();

    if (normalizedRoomId.isEmpty ||
        normalizedBookingId.isEmpty ||
        normalizedReceiverId.isEmpty) {
      return;
    }

    await _chatService.stopTyping(
      roomId: normalizedRoomId,
      bookingId: normalizedBookingId,
      receiverId: normalizedReceiverId,
    );
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

    return _chatService.deleteMessage(
      normalizedMessageId,
    );
  }

  // =====================================================
  // DELETE ROOM
  // =====================================================

  Future<bool> deleteRoom(
    String roomId,
  ) async {
    final normalizedRoomId =
        roomId.trim();

    if (normalizedRoomId.isEmpty) {
      return false;
    }

    return _chatService.deleteRoom(
      normalizedRoomId,
    );
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

    return _chatService.searchMessages(
      roomId: normalizedRoomId,
      keyword: normalizedKeyword,
    );
  }

  // =====================================================
  // UNREAD
  // =====================================================

  Future<int> getUnreadCount() async {
    return _chatService.getUnreadCount();
  }
}