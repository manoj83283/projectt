import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../repositories/chat_repository.dart';

// =====================================================
// CHAT MODE
// =====================================================

enum ChatMode {
  none,
  negotiation,
  booking,
}

// =====================================================
// CHAT PROVIDER
// =====================================================

class ChatProvider extends ChangeNotifier {
  ChatProvider();

  final ChatRepository _repository =
      ChatRepository.instance;

  List<ChatRoomModel> _chatRooms = [];

  List<ChatMessageModel> _messages = [];

  ChatRoomModel? _selectedRoom;

  bool _isLoading = false;
  bool _isConnected = false;
  bool _isOtherUserTyping = false;

  String? _error;

  int _unreadCount = 0;

  String? _currentRoomId;

  ChatMode _chatMode = ChatMode.none;

  String _currentBookingId = '';
  String _currentServiceId = '';
  String _currentProviderId = '';
  String _currentTopic = '';
  String _currentBookingDate = '';
  String _currentBookingTime = '';

  // =====================================================
  // GETTERS
  // =====================================================

  List<ChatRoomModel> get chatRooms {
    return List.unmodifiable(
      _chatRooms,
    );
  }

  List<ChatMessageModel> get messages {
    return List.unmodifiable(
      _messages,
    );
  }

  ChatRoomModel? get selectedRoom {
    return _selectedRoom;
  }

  bool get isLoading {
    return _isLoading;
  }

  bool get isConnected {
    return _isConnected;
  }

  bool get isOtherUserTyping {
    return _isOtherUserTyping;
  }

  String? get error {
    return _error;
  }

  int get unreadCount {
    return _unreadCount;
  }

  String? get currentRoomId {
    return _currentRoomId;
  }

  ChatMode get chatMode {
    return _chatMode;
  }

  bool get isNegotiationChat {
    return _chatMode ==
        ChatMode.negotiation;
  }

  bool get isBookingChat {
    return _chatMode ==
        ChatMode.booking;
  }

  String get currentBookingId {
    return _currentBookingId;
  }

  String get currentServiceId {
    return _currentServiceId;
  }

  String get currentProviderId {
    return _currentProviderId;
  }

  String get currentTopic {
    return _currentTopic;
  }

  String get currentBookingDate {
    return _currentBookingDate;
  }

  String get currentBookingTime {
    return _currentBookingTime;
  }

  // =====================================================
  // INTERNAL HELPERS
  // =====================================================

  String _normalize(
    dynamic value,
  ) {
    return value
            ?.toString()
            .trim() ??
        '';
  }

  void _setLoading(
    bool value,
  ) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }

  void _setError(
    String? value,
  ) {
    final normalized =
        value?.trim();

    _error =
        normalized == null ||
                normalized.isEmpty
            ? null
            : normalized;

    notifyListeners();
  }

  void _clearCurrentConversation({
    bool clearMessages = true,
  }) {
    _currentRoomId = null;

    _currentBookingId = '';
    _currentServiceId = '';
    _currentProviderId = '';
    _currentTopic = '';
    _currentBookingDate = '';
    _currentBookingTime = '';

    _chatMode =
        ChatMode.none;

    _selectedRoom = null;

    _isConnected = false;

    _isOtherUserTyping = false;

    if (clearMessages) {
      _messages = [];
    }
  }

  void _addMessageIfMissing(
    ChatMessageModel message,
  ) {
    final exists =
        _messages.any(
      (item) =>
          item.id == message.id,
    );

    if (!exists) {
      _messages.add(
        message,
      );
    }
  }

  // =====================================================
  // CHAT ROOMS
  // =====================================================

  Future<void> getChatRooms({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(
        true,
      );

      _setError(
        null,
      );

      _chatRooms =
          await _repository.getChatRooms(
        page: page,
        limit: limit,
      );

      notifyListeners();
    } catch (error) {
      _setError(
        error.toString(),
      );
    } finally {
      _setLoading(
        false,
      );
    }
  }

  Future<void> getChatRoom(
    String roomId,
  ) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      _setError(
        'Chat room is unavailable.',
      );

      return;
    }

    try {
      _setLoading(
        true,
      );

      _setError(
        null,
      );

      _selectedRoom =
          await _repository.getChatRoom(
        normalizedRoomId,
      );

      _currentRoomId =
          normalizedRoomId;

      notifyListeners();
    } catch (error) {
      _setError(
        error.toString(),
      );
    } finally {
      _setLoading(
        false,
      );
    }
  }

  // =====================================================
  // LEGACY BOOKING ROOM CREATION
  // =====================================================

  Future<bool> createChatRoom({
    required String providerId,
    required String bookingId,
  }) async {
    final normalizedProviderId =
        _normalize(
      providerId,
    );

    final normalizedBookingId =
        _normalize(
      bookingId,
    );

    if (normalizedProviderId.isEmpty ||
        normalizedBookingId.isEmpty) {
      _setError(
        'Provider and booking information are required.',
      );

      return false;
    }

    try {
      _setLoading(
        true,
      );

      _setError(
        null,
      );

      final room =
          await _repository.createChatRoom(
        providerId:
            normalizedProviderId,
        bookingId:
            normalizedBookingId,
      );

      _chatRooms.removeWhere(
        (item) =>
            item.id == room.id,
      );

      _chatRooms.insert(
        0,
        room,
      );

      _selectedRoom =
          room;

      _currentBookingId =
          normalizedBookingId;

      _currentProviderId =
          normalizedProviderId;

      _currentRoomId =
          'booking:$normalizedBookingId';

      _chatMode =
          ChatMode.booking;

      notifyListeners();

      return true;
    } catch (error) {
      _setError(
        error.toString(),
      );

      return false;
    } finally {
      _setLoading(
        false,
      );
    }
  }

  // =====================================================
  // OPEN NEGOTIATION CHAT
  // =====================================================

  Future<bool> openNegotiation({
    required String serviceId,
    required String providerId,
    required String topic,
    String? bookingDate,
    String? bookingTime,
  }) async {
    final normalizedServiceId =
        _normalize(
      serviceId,
    );

    final normalizedProviderId =
        _normalize(
      providerId,
    );

    final normalizedTopic =
        _normalize(
      topic,
    ).toLowerCase();

    final normalizedBookingDate =
        _normalize(
      bookingDate,
    );

    final normalizedBookingTime =
        _normalize(
      bookingTime,
    );

    if (normalizedServiceId.isEmpty) {
      _setError(
        'Service information is required to start negotiation.',
      );

      return false;
    }

    if (normalizedProviderId.isEmpty) {
      _setError(
        'Provider information is required to start negotiation.',
      );

      return false;
    }

    try {
      _setLoading(
        true,
      );

      _setError(
        null,
      );

      /*
       * Negotiation happens BEFORE booking.
       *
       * ChatRepository must provide a negotiation-room API
       * that accepts serviceId/providerId/topic without a
       * bookingId.
       */
      final room =
          await _repository.openNegotiation(
        serviceId:
            normalizedServiceId,
        providerId:
            normalizedProviderId,
        topic:
            normalizedTopic.isEmpty
                ? 'general'
                : normalizedTopic,
        bookingDate:
            normalizedBookingDate.isEmpty
                ? null
                : normalizedBookingDate,
        bookingTime:
            normalizedBookingTime.isEmpty
                ? null
                : normalizedBookingTime,
      );

      final resolvedRoomId =
          _normalize(
        room.id,
      );

      if (resolvedRoomId.isEmpty) {
        _setError(
          'Negotiation room could not be created.',
        );

        return false;
      }

      _chatRooms.removeWhere(
        (item) =>
            item.id ==
            resolvedRoomId,
      );

      _chatRooms.insert(
        0,
        room,
      );

      _selectedRoom =
          room;

      _currentRoomId =
          resolvedRoomId;

      _currentBookingId = '';

      _currentServiceId =
          normalizedServiceId;

      _currentProviderId =
          normalizedProviderId;

      _currentTopic =
          normalizedTopic.isEmpty
              ? 'general'
              : normalizedTopic;

      _currentBookingDate =
          normalizedBookingDate;

      _currentBookingTime =
          normalizedBookingTime;

      _chatMode =
          ChatMode.negotiation;

      _messages = [];

      _isConnected = true;

      await _loadMessagesInternal(
        roomId:
            resolvedRoomId,
        showLoading: false,
      );

      if (_currentRoomId !=
          resolvedRoomId) {
        return false;
      }

      try {
        await _repository.markAsRead(
          resolvedRoomId,
        );
      } catch (_) {
        // Read receipts must not prevent negotiation.
      }

      notifyListeners();

      return true;
    } catch (error) {
      _setError(
        error.toString(),
      );

      return false;
    } finally {
      _setLoading(
        false,
      );
    }
  }

  // =====================================================
  // OPEN BOOKING CHAT
  // =====================================================

  Future<void> openBookingChat({
    required String bookingId,
    required String roomId,
  }) async {
    final normalizedBookingId =
        _normalize(
      bookingId,
    );

    var normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking information is unavailable.',
      );

      return;
    }

    if (normalizedRoomId.isEmpty) {
      normalizedRoomId =
          'booking:$normalizedBookingId';
    }

    /*
     * One canonical room is shared between the Customer
     * and Provider application.
     */
    if (!normalizedRoomId.startsWith(
      'booking:',
    )) {
      normalizedRoomId =
          'booking:$normalizedBookingId';
    }

    try {
      _setLoading(
        true,
      );

      _setError(
        null,
      );

      _currentBookingId =
          normalizedBookingId;

      _currentServiceId = '';
      _currentTopic = '';
      _currentBookingDate = '';
      _currentBookingTime = '';

      _currentRoomId =
          normalizedRoomId;

      _chatMode =
          ChatMode.booking;

      _messages = [];

      _isConnected = true;

      await _loadMessagesInternal(
        roomId:
            normalizedRoomId,
        showLoading: false,
      );

      if (_currentRoomId !=
          normalizedRoomId) {
        return;
      }

      try {
        await _repository.markAsRead(
          normalizedRoomId,
        );
      } catch (_) {
        // Existing messages remain usable if read receipt fails.
      }

      notifyListeners();
    } catch (error) {
      _setError(
        error.toString(),
      );
    } finally {
      _setLoading(
        false,
      );
    }
  }

  // =====================================================
  // LOAD MESSAGES
  // =====================================================

  Future<void> _loadMessagesInternal({
    required String roomId,
    bool showLoading = true,
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      _setError(
        'Chat room is unavailable.',
      );

      return;
    }

    try {
      if (showLoading) {
        _setLoading(
          true,
        );
      }

      _setError(
        null,
      );

      final loadedMessages =
          await _repository.getMessages(
        normalizedRoomId,
      );

      /*
       * Avoid replacing messages if the user navigated to
       * another room before this async request completed.
       */
      if (_currentRoomId == null ||
          _currentRoomId ==
              normalizedRoomId) {
        _currentRoomId =
            normalizedRoomId;

        _messages =
            loadedMessages;

        notifyListeners();
      }
    } catch (error) {
      _setError(
        error.toString(),
      );
    } finally {
      if (showLoading) {
        _setLoading(
          false,
        );
      }
    }
  }

  Future<void> loadMessages({
    required String roomId,
    bool showLoading = true,
  }) async {
    await _loadMessagesInternal(
      roomId:
          roomId,
      showLoading:
          showLoading,
    );
  }

  // =====================================================
  // COMPATIBILITY: EXISTING BOOKING CHAT SCREEN
  // =====================================================

  Future<void> loadRoomMessages({
    required String roomId,
    String bookingId = '',
    bool showLoading = true,
  }) async {
    final normalizedBookingId =
        _normalize(
      bookingId,
    );

    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedBookingId.isNotEmpty) {
      _currentBookingId =
          normalizedBookingId;

      _chatMode =
          ChatMode.booking;
    }

    _currentRoomId =
        normalizedRoomId;

    await _loadMessagesInternal(
      roomId:
          normalizedRoomId,
      showLoading:
          showLoading,
    );
  }

  // =====================================================
  // LEGACY GET MESSAGES
  // =====================================================

  Future<void> getMessages(
    String roomId, {
    int page = 1,
    int limit = 50,
  }) async {
    await loadMessages(
      roomId:
          roomId,
    );
  }

  // =====================================================
  // SEND MESSAGE
  // =====================================================

  Future<bool> sendMessage({
    required String roomId,
    required String message,
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    final normalizedMessage =
        _normalize(
      message,
    );

    if (normalizedRoomId.isEmpty) {
      _setError(
        'Chat room is unavailable.',
      );

      return false;
    }

    if (normalizedMessage.isEmpty) {
      return false;
    }

    try {
      _setError(
        null,
      );

      final chatMessage =
          await _repository.sendMessage(
        roomId:
            normalizedRoomId,
        message:
            normalizedMessage,
      );

      /*
       * Add only if the response still belongs to the
       * room currently displayed.
       */
      if (_currentRoomId ==
              normalizedRoomId ||
          _currentRoomId == null) {
        _currentRoomId =
            normalizedRoomId;

        _addMessageIfMissing(
          chatMessage,
        );

        notifyListeners();
      }

      return true;
    } catch (error) {
      _setError(
        error.toString(),
      );

      return false;
    }
  }

  // =====================================================
  // COMPATIBILITY: EXISTING SEND ROOM MESSAGE
  // =====================================================

  Future<bool> sendRoomMessage({
    required String roomId,
    String bookingId = '',
    String receiverId = '',
    required String message,
  }) async {
    final normalizedBookingId =
        _normalize(
      bookingId,
    );

    final normalizedReceiverId =
        _normalize(
      receiverId,
    );

    if (normalizedBookingId.isNotEmpty) {
      _currentBookingId =
          normalizedBookingId;

      _chatMode =
          ChatMode.booking;
    }

    if (normalizedReceiverId.isNotEmpty) {
      _currentProviderId =
          normalizedReceiverId;
    }

    return sendMessage(
      roomId:
          roomId,
      message:
          message,
    );
  }

  // =====================================================
  // IMAGE MESSAGE
  // =====================================================

  Future<bool> sendImageMessage({
    required String roomId,
    required String imageUrl,
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    final normalizedImageUrl =
        _normalize(
      imageUrl,
    );

    if (normalizedRoomId.isEmpty ||
        normalizedImageUrl.isEmpty) {
      _setError(
        'Chat room and image are required.',
      );

      return false;
    }

    try {
      _setError(
        null,
      );

      final chatMessage =
          await _repository.sendImageMessage(
        roomId:
            normalizedRoomId,
        imageUrl:
            normalizedImageUrl,
      );

      if (_currentRoomId ==
              normalizedRoomId ||
          _currentRoomId == null) {
        _currentRoomId =
            normalizedRoomId;

        _addMessageIfMissing(
          chatMessage,
        );

        notifyListeners();
      }

      return true;
    } catch (error) {
      _setError(
        error.toString(),
      );

      return false;
    }
  }

  // =====================================================
  // LOCATION MESSAGE
  // =====================================================

  Future<bool> sendLocationMessage({
    required String roomId,
    required double latitude,
    required double longitude,
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      _setError(
        'Chat room is unavailable.',
      );

      return false;
    }

    try {
      _setError(
        null,
      );

      final chatMessage =
          await _repository.sendLocationMessage(
        roomId:
            normalizedRoomId,
        latitude:
            latitude,
        longitude:
            longitude,
      );

      if (_currentRoomId ==
              normalizedRoomId ||
          _currentRoomId == null) {
        _currentRoomId =
            normalizedRoomId;

        _addMessageIfMissing(
          chatMessage,
        );

        notifyListeners();
      }

      return true;
    } catch (error) {
      _setError(
        error.toString(),
      );

      return false;
    }
  }

  // =====================================================
  // READ RECEIPTS
  // =====================================================

  Future<bool> markAsRead(
    String roomId,
  ) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return false;
    }

    try {
      return await _repository.markAsRead(
        normalizedRoomId,
      );
    } catch (error) {
      _setError(
        error.toString(),
      );

      return false;
    }
  }

  Future<void> markRoomAsRead({
    required String roomId,
    String bookingId = '',
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    try {
      await _repository.markAsRead(
        normalizedRoomId,
      );
    } catch (_) {
      // A read-receipt failure must not break Chat.
    }
  }

  // =====================================================
  // SOCKET ROOM STATE
  // =====================================================

  void joinRoom({
    required String roomId,
    String bookingId = '',
  }) {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    final normalizedBookingId =
        _normalize(
      bookingId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    _currentRoomId =
        normalizedRoomId;

    if (normalizedBookingId.isNotEmpty) {
      _currentBookingId =
          normalizedBookingId;

      _chatMode =
          ChatMode.booking;
    }

    _isConnected =
        true;

    notifyListeners();
  }

  void joinNegotiationRoom({
    required String roomId,
    required String serviceId,
    required String providerId,
    String topic = 'general',
  }) {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    _currentRoomId =
        normalizedRoomId;

    _currentBookingId = '';

    _currentServiceId =
        _normalize(
      serviceId,
    );

    _currentProviderId =
        _normalize(
      providerId,
    );

    _currentTopic =
        _normalize(
      topic,
    );

    _chatMode =
        ChatMode.negotiation;

    _isConnected =
        true;

    notifyListeners();
  }

  void leaveRoom(
    String roomId,
  ) {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (_currentRoomId ==
        normalizedRoomId) {
      _currentRoomId =
          null;

      _isConnected =
          false;

      _isOtherUserTyping =
          false;
    }

    notifyListeners();
  }

  // =====================================================
  // TYPING
  // =====================================================

  void startTyping({
    required String roomId,
    String bookingId = '',
    String receiverId = '',
  }) {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    /*
     * Room ID is authoritative.
     * bookingId is optional because negotiation happens
     * before a Booking exists.
     *
     * SocketService integration can be added here if your
     * existing service exposes typing events.
     */

    notifyListeners();
  }

  void stopTyping({
    required String roomId,
    String bookingId = '',
    String receiverId = '',
  }) {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    notifyListeners();
  }

  void setOtherUserTyping(
    bool value,
  ) {
    if (_isOtherUserTyping ==
        value) {
      return;
    }

    _isOtherUserTyping =
        value;

    notifyListeners();
  }

  // =====================================================
  // SOCKET MESSAGE
  // =====================================================

  void addLocalMessage(
    ChatMessageModel message,
  ) {
    _addMessageIfMissing(
      message,
    );

    notifyListeners();
  }

  // =====================================================
  // DELETE MESSAGE
  // =====================================================

  Future<bool> deleteMessage(
    String messageId,
  ) async {
    final normalizedMessageId =
        _normalize(
      messageId,
    );

    if (normalizedMessageId.isEmpty) {
      return false;
    }

    try {
      _setError(
        null,
      );

      final success =
          await _repository.deleteMessage(
        normalizedMessageId,
      );

      if (success) {
        _messages.removeWhere(
          (item) =>
              item.id ==
              normalizedMessageId,
        );

        notifyListeners();
      }

      return success;
    } catch (error) {
      _setError(
        error.toString(),
      );

      return false;
    }
  }

  // =====================================================
  // DELETE ROOM
  // =====================================================

  Future<bool> deleteRoom(
    String roomId,
  ) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return false;
    }

    try {
      _setLoading(
        true,
      );

      _setError(
        null,
      );

      final success =
          await _repository.deleteRoom(
        normalizedRoomId,
      );

      if (success) {
        _chatRooms.removeWhere(
          (item) =>
              item.id ==
              normalizedRoomId,
        );

        if (_selectedRoom?.id ==
            normalizedRoomId) {
          _selectedRoom =
              null;
        }

        if (_currentRoomId ==
            normalizedRoomId) {
          _clearCurrentConversation();
        }

        notifyListeners();
      }

      return success;
    } catch (error) {
      _setError(
        error.toString(),
      );

      return false;
    } finally {
      _setLoading(
        false,
      );
    }
  }

  // =====================================================
  // SEARCH
  // =====================================================

  Future<List<ChatMessageModel>>
      searchMessages({
    required String roomId,
    required String keyword,
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    final normalizedKeyword =
        _normalize(
      keyword,
    );

    if (normalizedRoomId.isEmpty ||
        normalizedKeyword.isEmpty) {
      return <ChatMessageModel>[];
    }

    try {
      _setError(
        null,
      );

      return await _repository.searchMessages(
        roomId:
            normalizedRoomId,
        keyword:
            normalizedKeyword,
      );
    } catch (error) {
      _setError(
        error.toString(),
      );

      return <ChatMessageModel>[];
    }
  }

  // =====================================================
  // UNREAD COUNT
  // =====================================================

  Future<void> getUnreadCount() async {
    try {
      _unreadCount =
          await _repository.getUnreadCount();

      notifyListeners();
    } catch (error) {
      _setError(
        error.toString(),
      );
    }
  }

  // =====================================================
  // ROOM SELECTION
  // =====================================================

  void setSelectedRoom(
    ChatRoomModel room,
  ) {
    _selectedRoom =
        room;

    _currentRoomId =
        room.id;

    notifyListeners();
  }

  void clearSelectedRoom() {
    _selectedRoom =
        null;

    _messages = [];

    notifyListeners();
  }

  // =====================================================
  // ERROR
  // =====================================================

  void clearError() {
    if (_error == null) {
      return;
    }

    _error = null;

    notifyListeners();
  }

  // =====================================================
  // RESET CURRENT CHAT
  // =====================================================

  void clearCurrentChat() {
    _clearCurrentConversation();

    notifyListeners();
  }

  // =====================================================
  // RESET PROVIDER
  // =====================================================

  void reset() {
    _chatRooms = [];

    _messages = [];

    _selectedRoom = null;

    _error = null;

    _unreadCount = 0;

    _isLoading = false;

    _isConnected = false;

    _isOtherUserTyping = false;

    _currentRoomId = null;

    _currentBookingId = '';
    _currentServiceId = '';
    _currentProviderId = '';
    _currentTopic = '';
    _currentBookingDate = '';
    _currentBookingTime = '';

    _chatMode =
        ChatMode.none;

    notifyListeners();
  }
}