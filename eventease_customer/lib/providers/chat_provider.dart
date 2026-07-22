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
  String? _error;

  int _unreadCount = 0;

  // ==========================================
  // GETTERS
  // ==========================================

  List<ChatRoomModel> get chatRooms =>
      _chatRooms;

  List<ChatMessageModel> get messages =>
      _messages;

  ChatRoomModel? get selectedRoom =>
      _selectedRoom;

  bool get isLoading => _isLoading;

  String? get error => _error;

  int get unreadCount => _unreadCount;

  // ==========================================
  // SET LOADING
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ==========================================
  // SET ERROR
  // ==========================================

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // ==========================================
  // GET CHAT ROOMS
  // ==========================================

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

  // ==========================================
  // GET CHAT ROOM
  // ==========================================

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

  // ==========================================
  // CREATE CHAT ROOM
  // ==========================================

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

      _chatRooms.insert(0, room);

      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GET MESSAGES
  // ==========================================

  Future<void> getMessages(
    String roomId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _messages =
          await _repository.getMessages(
        roomId,
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

  // ==========================================
  // SEND MESSAGE
  // ==========================================

  Future<bool> sendMessage({
    required String roomId,
    required String message,
  }) async {
    try {
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

  // ==========================================
  // SEND IMAGE MESSAGE
  // ==========================================

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

  // ==========================================
  // SEND LOCATION MESSAGE
  // ==========================================

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

  // ==========================================
  // MARK AS READ
  // ==========================================

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

  // ==========================================
  // DELETE MESSAGE
  // ==========================================

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
          (e) => e.id == messageId,
        );
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // DELETE CHAT ROOM
  // ==========================================

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
          (e) => e.id == roomId,
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

  // ==========================================
  // SEARCH MESSAGES
  // ==========================================

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

  // ==========================================
  // GET UNREAD COUNT
  // ==========================================

  Future<void> getUnreadCount() async {
    try {
      _unreadCount =
          await _repository.getUnreadCount();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ==========================================
  // ADD LOCAL MESSAGE
  // SOCKET SUPPORT
  // ==========================================

  void addLocalMessage(
    ChatMessageModel message,
  ) {
    _messages.add(message);

    notifyListeners();
  }

  // ==========================================
  // SET CHAT ROOM
  // ==========================================

  void setSelectedRoom(
    ChatRoomModel room,
  ) {
    _selectedRoom = room;

    notifyListeners();
  }

  // ==========================================
  // CLEAR CHAT ROOM
  // ==========================================

  void clearSelectedRoom() {
    _selectedRoom = null;
    _messages.clear();

    notifyListeners();
  }

  // ==========================================
  // CLEAR ERROR
  // ==========================================

  void clearError() {
    _error = null;

    notifyListeners();
  }

  // ==========================================
  // RESET
  // ==========================================

  void reset() {
    _chatRooms.clear();
    _messages.clear();

    _selectedRoom = null;

    _error = null;
    _unreadCount = 0;

    notifyListeners();
  }
}