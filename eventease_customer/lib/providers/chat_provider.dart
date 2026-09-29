import 'package:flutter/material.dart';

import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';
import '../repositories/chat_repository.dart';

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

  // =========================================================
  // GETTERS
  // =========================================================

  List<ChatRoomModel> get chatRooms =>
      _chatRooms;

  List<ChatMessageModel> get messages =>
      _messages;

  ChatRoomModel? get selectedRoom =>
      _selectedRoom;

  bool get isLoading => _isLoading;

  bool get isConnected => _isConnected;

  bool get isOtherUserTyping =>
      _isOtherUserTyping;

  String? get error => _error;

  int get unreadCount => _unreadCount;

  String? get currentRoomId =>
      _currentRoomId;

  // =========================================================
  // INTERNAL
  // =========================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // =========================================================
  // ROOMS
  // =========================================================

  Future<void> getChatRooms({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _chatRooms =
          await _repository.getChatRooms(
        page: page,
        limit: limit,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getChatRoom(
    String roomId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _selectedRoom =
          await _repository.getChatRoom(
        roomId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createChatRoom({
    required String providerId,
    required String bookingId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final room =
          await _repository.createChatRoom(
        providerId: providerId,
        bookingId: bookingId,
      );

      _chatRooms.insert(
        0,
        room,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================================================
  // LOAD BOOKING ROOM MESSAGES
  // =========================================================

  Future<void> loadRoomMessages({
    required String roomId,
    required String bookingId,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        _setLoading(true);
      }

      _setError(null);

      _messages =
          await _repository.getMessages(
        roomId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      if (showLoading) {
        _setLoading(false);
      }
    }
  }

  // =========================================================
  // LEGACY
  // =========================================================

  Future<void> getMessages(
    String roomId, {
    int page = 1,
    int limit = 50,
  }) async {
    await loadRoomMessages(
      roomId: roomId,
      bookingId: '',
    );
  }

  // =========================================================
  // SEND ROOM MESSAGE
  // =========================================================

  Future<bool> sendRoomMessage({
    required String roomId,
    required String bookingId,
    required String receiverId,
    required String message,
  }) async {
    try {
      _setError(null);

      final chatMessage =
          await _repository.sendMessage(
        roomId: roomId,
        message: message,
      );

      _messages.add(chatMessage);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());

      return false;
    }
  }

  // =========================================================
  // LEGACY SEND
  // =========================================================

  Future<bool> sendMessage({
    required String roomId,
    required String message,
  }) {
    return sendRoomMessage(
      roomId: roomId,
      bookingId: '',
      receiverId: '',
      message: message,
    );
  }

  // =========================================================
  // IMAGES
  // =========================================================

  Future<bool> sendImageMessage({
    required String roomId,
    required String imageUrl,
  }) async {
    try {
      final chatMessage =
          await _repository
              .sendImageMessage(
        roomId: roomId,
        imageUrl: imageUrl,
      );

      _messages.add(chatMessage);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());

      return false;
    }
  }

  // =========================================================
  // LOCATION
  // =========================================================

  Future<bool> sendLocationMessage({
    required String roomId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final chatMessage =
          await _repository
              .sendLocationMessage(
        roomId: roomId,
        latitude: latitude,
        longitude: longitude,
      );

      _messages.add(chatMessage);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());

      return false;
    }
  }

  // =========================================================
  // READ RECEIPTS
  // =========================================================

  Future<bool> markAsRead(
    String roomId,
  ) async {
    try {
      return await _repository.markAsRead(
        roomId,
      );
    } catch (e) {
      _setError(e.toString());

      return false;
    }
  }

  Future<void> markRoomAsRead({
    required String roomId,
    required String bookingId,
  }) async {
    try {
      await _repository.markAsRead(
        roomId,
      );
    } catch (_) {}
  }

  // =========================================================
  // SOCKET ROOM STATE
  // =========================================================

  void joinRoom({
    required String roomId,
    required String bookingId,
  }) {
    _currentRoomId = roomId;

    _isConnected = true;

    notifyListeners();
  }

  void leaveRoom(
    String roomId,
  ) {
    if (_currentRoomId == roomId) {
      _currentRoomId = null;
    }

    _isConnected = false;

    _isOtherUserTyping = false;

    notifyListeners();
  }

  // =========================================================
  // TYPING
  // =========================================================

  void startTyping({
    required String roomId,
    required String bookingId,
    required String receiverId,
  }) {
    notifyListeners();
  }

  void stopTyping({
    required String roomId,
    required String bookingId,
    required String receiverId,
  }) {
    notifyListeners();
  }

  void setOtherUserTyping(
    bool value,
  ) {
    _isOtherUserTyping = value;

    notifyListeners();
  }

  // =========================================================
  // SOCKET MESSAGE
  // =========================================================

  void addLocalMessage(
    ChatMessageModel message,
  ) {
    final exists =
        _messages.any(
      (item) => item.id == message.id,
    );

    if (!exists) {
      _messages.add(message);

      notifyListeners();
    }
  }

  // =========================================================
  // DELETE MESSAGE
  // =========================================================

  Future<bool> deleteMessage(
    String messageId,
  ) async {
    try {
      final success =
          await _repository.deleteMessage(
        messageId,
      );

      if (success) {
        _messages.removeWhere(
          (item) =>
              item.id == messageId,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());

      return false;
    }
  }

  // =========================================================
  // DELETE ROOM
  // =========================================================

  Future<bool> deleteRoom(
    String roomId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.deleteRoom(
        roomId,
      );

      if (success) {
        _chatRooms.removeWhere(
          (item) =>
              item.id == roomId,
        );

        if (_selectedRoom?.id ==
            roomId) {
          _selectedRoom = null;

          _messages.clear();
        }
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Future<List<ChatMessageModel>>
      searchMessages({
    required String roomId,
    required String keyword,
  }) async {
    try {
      return await _repository
          .searchMessages(
        roomId: roomId,
        keyword: keyword,
      );
    } catch (e) {
      _setError(e.toString());

      return [];
    }
  }

  // =========================================================
  // UNREAD
  // =========================================================

  Future<void> getUnreadCount() async {
    try {
      _unreadCount =
          await _repository.getUnreadCount();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // =========================================================
  // ROOM SELECTION
  // =========================================================

  void setSelectedRoom(
    ChatRoomModel room,
  ) {
    _selectedRoom = room;

    notifyListeners();
  }

  void clearSelectedRoom() {
    _selectedRoom = null;

    _messages.clear();

    notifyListeners();
  }

  // =========================================================
  // ERROR
  // =========================================================

  void clearError() {
    _error = null;

    notifyListeners();
  }

  // =========================================================
  // RESET
  // =========================================================

  void reset() {
    _chatRooms.clear();

    _messages.clear();

    _selectedRoom = null;

    _error = null;

    _unreadCount = 0;

    _isConnected = false;

    _isOtherUserTyping = false;

    _currentRoomId = null;

    notifyListeners();
  }
}