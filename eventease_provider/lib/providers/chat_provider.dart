import 'package:flutter/foundation.dart';

import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository =
      ChatRepository.instance;

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;

  String? _errorMessage;

  List<dynamic> _chatRooms = [];

  List<ChatMessageModel> _messages = [];

  int _unreadCount = 0;

  Map<String, dynamic> _analytics = {};

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<dynamic> get chatRooms =>
      _chatRooms;

  List<ChatMessageModel> get messages =>
      _messages;

  int get unreadCount =>
      _unreadCount;

  Map<String, dynamic> get analytics =>
      _analytics;

  // =========================
  // HELPERS
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =========================
  // GET CHAT ROOMS
  // =========================

  Future<void> getChatRooms() async {
    try {
      _setLoading(true);

      _chatRooms =
          await _repository.getChatRooms();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET MESSAGES
  // =========================

  Future<void> getMessages(
    String chatRoomId,
  ) async {
    try {
      _setLoading(true);

      _messages =
          await _repository.getMessages(
        chatRoomId,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // LOAD MORE MESSAGES
  // =========================

  Future<List<ChatMessageModel>>
      loadMoreMessages({
    required String chatRoomId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _repository
          .getPaginatedMessages(
        chatRoomId: chatRoomId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // =========================
  // SEND TEXT MESSAGE
  // =========================

  Future<bool> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    try {
      final newMessage =
          await _repository.sendMessage(
        receiverId: receiverId,
        message: message,
      );

      _messages.add(newMessage);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // SEND IMAGE MESSAGE
  // =========================

  Future<bool> sendImageMessage({
    required String receiverId,
    required String imageUrl,
  }) async {
    try {
      final newMessage =
          await _repository
              .sendImageMessage(
        receiverId: receiverId,
        imageUrl: imageUrl,
      );

      _messages.add(newMessage);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // SEND VIDEO MESSAGE
  // =========================

  Future<bool> sendVideoMessage({
    required String receiverId,
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    try {
      final newMessage =
          await _repository
              .sendVideoMessage(
        receiverId: receiverId,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );

      _messages.add(newMessage);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // SEND FILE MESSAGE
  // =========================

  Future<bool> sendFileMessage({
    required String receiverId,
    required String fileUrl,
    required String fileName,
    required double fileSize,
  }) async {
    try {
      final newMessage =
          await _repository
              .sendFileMessage(
        receiverId: receiverId,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
      );

      _messages.add(newMessage);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // SEND LOCATION
  // =========================

  Future<bool> sendLocationMessage({
    required String receiverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final newMessage =
          await _repository
              .sendLocationMessage(
        receiverId: receiverId,
        latitude: latitude,
        longitude: longitude,
      );

      _messages.add(newMessage);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // =========================
  // ADD SOCKET MESSAGE
  // =========================

  void addIncomingMessage(
    ChatMessageModel message,
  ) {
    _messages.add(message);
    notifyListeners();
  }

  // =========================
  // MARK AS READ
  // =========================

  Future<bool> markAsRead(
    String messageId,
  ) async {
    try {
      return await _repository.markAsRead(
        messageId,
      );
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
      final success =
          await _repository
              .markRoomAsRead(roomId);

      if (success) {
        await getUnreadCount();
      }

      return success;
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
      final success =
          await _repository.deleteMessage(
        messageId,
      );

      if (success) {
        _messages.removeWhere(
          (message) =>
              message.id == messageId,
        );

        notifyListeners();
      }

      return success;
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
      return await _repository
          .searchMessages(
        roomId: roomId,
        keyword: keyword,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // =========================
  // UNREAD COUNT
  // =========================

  Future<void> getUnreadCount() async {
    try {
      _unreadCount =
          await _repository
              .getUnreadCount();

      notifyListeners();
    } catch (e) {
      _unreadCount = 0;
    }
  }

  // =========================
  // CHAT ANALYTICS
  // =========================

  Future<void> getChatAnalytics() async {
    try {
      _analytics =
          await _repository
              .getChatAnalytics();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // BLOCK USER
  // =========================

  Future<bool> blockUser(
    String userId,
  ) async {
    try {
      return await _repository.blockUser(
        userId,
      );
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
      return await _repository
          .unblockUser(userId);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // REFRESH DATA
  // =========================

  Future<void> refreshData() async {
    await Future.wait([
      getChatRooms(),
      getUnreadCount(),
      getChatAnalytics(),
    ]);
  }

  // =========================
  // RESET
  // =========================

  void reset() {
    _chatRooms = [];
    _messages = [];
    _unreadCount = 0;
    _analytics = {};
    _errorMessage = null;

    notifyListeners();
  }
}