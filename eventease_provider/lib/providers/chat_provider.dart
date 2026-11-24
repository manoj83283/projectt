import 'package:flutter/foundation.dart';

import '../models/chat_message_model.dart';
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
  ChatProvider({
    ChatRepository? repository,
  }) : _repository =
            repository ?? ChatRepository.instance;

  final ChatRepository _repository;

  // =====================================================
  // STATE
  // =====================================================

  bool _isLoading = false;
  bool _disposed = false;

  String? _errorMessage;

  List<dynamic> _chatRooms = <dynamic>[];

  List<ChatMessageModel> _messages =
      <ChatMessageModel>[];

  int _unreadCount = 0;

  Map<String, dynamic> _analytics =
      <String, dynamic>{};

  String? _currentRoomId;

  ChatMode _chatMode = ChatMode.none;

  String _currentBookingId = '';
  String _currentServiceId = '';
  String _currentCustomerId = '';
  String _currentTopic = '';

  bool _isConnected = false;
  bool _isOtherUserTyping = false;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading {
    return _isLoading;
  }

  String? get errorMessage {
    return _errorMessage;
  }

  String? get error {
    return _errorMessage;
  }

  List<dynamic> get chatRooms {
    return List<dynamic>.unmodifiable(
      _chatRooms,
    );
  }

  List<ChatMessageModel> get messages {
    return List<ChatMessageModel>.unmodifiable(
      _messages,
    );
  }

  int get unreadCount {
    return _unreadCount;
  }

  Map<String, dynamic> get analytics {
    return Map<String, dynamic>.unmodifiable(
      _analytics,
    );
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

  String get currentCustomerId {
    return _currentCustomerId;
  }

  String get currentTopic {
    return _currentTopic;
  }

  bool get isConnected {
    return _isConnected;
  }

  bool get isOtherUserTyping {
    return _isOtherUserTyping;
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

  String? _optionalValue(
    dynamic value,
  ) {
    final normalized =
        _normalize(
      value,
    );

    return normalized.isEmpty
        ? null
        : normalized;
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setLoading(
    bool value,
  ) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    _safeNotifyListeners();
  }

  void _setError(
    Object? error,
  ) {
    if (error == null) {
      _errorMessage = null;
    } else {
      var message =
          error.toString().trim();

      const prefixes = <String>[
        'Exception: ',
        'FormatException: ',
        'DioException: ',
        'ArgumentError: ',
        'Invalid argument(s): ',
      ];

      for (final prefix
          in prefixes) {
        if (message.startsWith(
          prefix,
        )) {
          message = message
              .substring(
                prefix.length,
              )
              .trim();
        }
      }

      _errorMessage =
          message.isEmpty
              ? 'Chat request failed.'
              : message;
    }

    _safeNotifyListeners();
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

  void _clearConversationState({
    bool clearMessages = true,
  }) {
    _currentRoomId = null;

    _currentBookingId = '';
    _currentServiceId = '';
    _currentCustomerId = '';
    _currentTopic = '';

    _chatMode =
        ChatMode.none;

    _isConnected = false;
    _isOtherUserTyping = false;

    if (clearMessages) {
      _messages =
          <ChatMessageModel>[];
    }
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    _safeNotifyListeners();
  }

  // =====================================================
  // GET CHAT ROOMS
  //
  // Returns both:
  //
  // negotiation rooms
  // booking rooms
  // =====================================================

  Future<void> getChatRooms() async {
    try {
      _setLoading(
        true,
      );

      _setError(
        null,
      );

      final rooms =
          await _repository.getChatRooms();

      _chatRooms =
          List<dynamic>.from(
        rooms,
      );

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        error,
      );
    } finally {
      _setLoading(
        false,
      );
    }
  }

  // =====================================================
  // OPEN NEGOTIATION CHAT
  //
  // No Order / Booking is required.
  // =====================================================

  Future<bool> openNegotiation({
    required String roomId,
    required String serviceId,
    required String customerId,
    String topic = 'general',
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    final normalizedServiceId =
        _normalize(
      serviceId,
    );

    final normalizedCustomerId =
        _normalize(
      customerId,
    );

    final normalizedTopic =
        _normalize(
      topic,
    );

    if (normalizedRoomId.isEmpty) {
      _setError(
        'Negotiation room is unavailable.',
      );

      return false;
    }

    if (normalizedServiceId.isEmpty) {
      _setError(
        'Service information is unavailable.',
      );

      return false;
    }

    if (normalizedCustomerId.isEmpty) {
      _setError(
        'Customer information is unavailable.',
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

      _currentRoomId =
          normalizedRoomId;

      _currentServiceId =
          normalizedServiceId;

      _currentCustomerId =
          normalizedCustomerId;

      _currentBookingId = '';

      _currentTopic =
          normalizedTopic.isEmpty
              ? 'general'
              : normalizedTopic;

      _chatMode =
          ChatMode.negotiation;

      _isConnected = true;

      _messages =
          <ChatMessageModel>[];

      await _loadMessagesInternal(
        roomId:
            normalizedRoomId,
        showLoading: false,
      );

      if (_currentRoomId !=
          normalizedRoomId) {
        return false;
      }

      try {
        await _repository.markRoomAsRead(
          normalizedRoomId,
        );
      } catch (_) {
        // Read receipt must not stop Chat.
      }

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        error,
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
  //
  // Booking room:
  //
  // booking:<bookingId>
  // =====================================================

  Future<bool> openBookingChat({
    required String bookingId,
    required String roomId,
    required String customerId,
    String? serviceId,
  }) async {
    final normalizedBookingId =
        _normalize(
      bookingId,
    );

    final normalizedCustomerId =
        _normalize(
      customerId,
    );

    final normalizedServiceId =
        _normalize(
      serviceId,
    );

    if (normalizedBookingId.isEmpty) {
      _setError(
        'Booking information is unavailable.',
      );

      return false;
    }

    if (normalizedCustomerId.isEmpty) {
      _setError(
        'Customer information is unavailable.',
      );

      return false;
    }

    /*
     * Customer and Provider must use the same
     * canonical Booking Chat room.
     */
    final normalizedRoomId =
        'booking:$normalizedBookingId';

    try {
      _setLoading(
        true,
      );

      _setError(
        null,
      );

      _currentRoomId =
          normalizedRoomId;

      _currentBookingId =
          normalizedBookingId;

      _currentCustomerId =
          normalizedCustomerId;

      _currentServiceId =
          normalizedServiceId;

      _currentTopic = '';

      _chatMode =
          ChatMode.booking;

      _isConnected = true;

      _messages =
          <ChatMessageModel>[];

      await _loadMessagesInternal(
        roomId:
            normalizedRoomId,
        showLoading: false,
      );

      if (_currentRoomId !=
          normalizedRoomId) {
        return false;
      }

      try {
        await _repository.markRoomAsRead(
          normalizedRoomId,
        );
      } catch (_) {
        // Read receipt failure must not block Chat.
      }

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        error,
      );

      return false;
    } finally {
      _setLoading(
        false,
      );
    }
  }

  // =====================================================
  // OPEN GENERIC ROOM
  // =====================================================

  Future<bool> openRoom({
    required String roomId,
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
      _setLoading(
        true,
      );

      _setError(
        null,
      );

      _currentRoomId =
          normalizedRoomId;

      _isConnected = true;

      _messages =
          <ChatMessageModel>[];

      await _loadMessagesInternal(
        roomId:
            normalizedRoomId,
        showLoading: false,
      );

      try {
        await _repository.markRoomAsRead(
          normalizedRoomId,
        );
      } catch (_) {
        // Read receipt is non-blocking.
      }

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        error,
      );

      return false;
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

      final result =
          await _repository.getMessages(
        normalizedRoomId,
      );

      /*
       * Prevent an older request from replacing
       * messages for a newly opened room.
       */
      if (_currentRoomId == null ||
          _currentRoomId ==
              normalizedRoomId) {
        _currentRoomId =
            normalizedRoomId;

        _messages =
            List<ChatMessageModel>.from(
          result,
        );

        _safeNotifyListeners();
      }
    } catch (error) {
      _setError(
        error,
      );
    } finally {
      if (showLoading) {
        _setLoading(
          false,
        );
      }
    }
  }

  Future<void> getMessages(
    String chatRoomId,
  ) {
    return _loadMessagesInternal(
      roomId:
          chatRoomId,
    );
  }

  Future<void> loadMessages({
    required String roomId,
    bool showLoading = true,
  }) {
    return _loadMessagesInternal(
      roomId:
          roomId,
      showLoading:
          showLoading,
    );
  }

  // =====================================================
  // LOAD MORE
  // =====================================================

  Future<List<ChatMessageModel>>
      loadMoreMessages({
    required String chatRoomId,
    int page = 1,
    int limit = 20,
  }) async {
    final normalizedRoomId =
        _normalize(
      chatRoomId,
    );

    if (normalizedRoomId.isEmpty) {
      return <ChatMessageModel>[];
    }

    try {
      final result =
          await _repository
              .getPaginatedMessages(
        chatRoomId:
            normalizedRoomId,
        page:
            page,
        limit:
            limit,
      );

      return List<ChatMessageModel>.from(
        result,
      );
    } catch (error) {
      _setError(
        error,
      );

      return <ChatMessageModel>[];
    }
  }

  // =====================================================
  // SEND TEXT MESSAGE
  //
  // FINAL CONTRACT
  //
  // roomId
  //     conversation / Socket.IO room
  //
  // receiverId
  //     actual Customer MongoDB ID
  //
  // bookingId
  //     optional
  //
  // serviceId
  //     optional
  //
  // negotiationMode
  //     pre-booking negotiation or Booking Chat
  // =====================================================

  Future<bool> sendMessage({
    required String roomId,
    required String receiverId,
    required String message,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    final normalizedReceiverId =
        _normalize(
      receiverId,
    );

    final normalizedMessage =
        _normalize(
      message,
    );

    final normalizedBookingId =
        _normalize(
      bookingId,
    );

    final normalizedServiceId =
        _normalize(
      serviceId,
    );

    if (normalizedRoomId.isEmpty) {
      _errorMessage =
          'Chat room is required.';

      _safeNotifyListeners();

      return false;
    }

    if (normalizedReceiverId.isEmpty) {
      _errorMessage =
          'Receiver is required.';

      _safeNotifyListeners();

      return false;
    }

    if (normalizedMessage.isEmpty) {
      return false;
    }

    try {
      _errorMessage = null;

      final newMessage =
          await _repository.sendMessage(
        roomId:
            normalizedRoomId,

        receiverId:
            normalizedReceiverId,

        message:
            normalizedMessage,

        bookingId:
            normalizedBookingId.isEmpty
                ? null
                : normalizedBookingId,

        serviceId:
            normalizedServiceId.isEmpty
                ? null
                : normalizedServiceId,

        negotiationMode:
            negotiationMode,
      );

      /*
       * Remember the current conversation metadata.
       */
      _currentRoomId =
          normalizedRoomId;

      _currentCustomerId =
          normalizedReceiverId;

      if (negotiationMode) {
        _chatMode =
            ChatMode.negotiation;

        _currentBookingId = '';

        if (normalizedServiceId.isNotEmpty) {
          _currentServiceId =
              normalizedServiceId;
        }
      } else {
        if (normalizedBookingId.isNotEmpty) {
          _currentBookingId =
              normalizedBookingId;

          _chatMode =
              ChatMode.booking;
        }

        if (normalizedServiceId.isNotEmpty) {
          _currentServiceId =
              normalizedServiceId;
        }
      }

      /*
       * Add the HTTP response immediately.
       *
       * Socket.IO may later deliver the same message.
       * _addMessageIfMissing prevents duplication.
       */
      if (_currentRoomId ==
          normalizedRoomId) {
        _addMessageIfMissing(
          newMessage,
        );
      }

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _errorMessage =
          error.toString();

      debugPrint(
        'SEND CHAT MESSAGE ERROR: $error',
      );

      _safeNotifyListeners();

      return false;
    }
  }

  // =====================================================
  // SEND USING CURRENT CONVERSATION
  //
  // Convenience method when ChatScreen already initialized
  // openNegotiation() or openBookingChat().
  // =====================================================

  Future<bool> sendCurrentMessage(
    String message,
  ) {
    final roomId =
        _currentRoomId ?? '';

    return sendMessage(
      roomId:
          roomId,
      receiverId:
          _currentCustomerId,
      message:
          message,
      bookingId:
          _optionalValue(
        _currentBookingId,
      ),
      serviceId:
          _optionalValue(
        _currentServiceId,
      ),
      negotiationMode:
          _chatMode ==
          ChatMode.negotiation,
    );
  }

  // =====================================================
  // COMPATIBILITY SEND
  //
  // Older screens can still use this method, but the
  // receiver ID must never be replaced by roomId.
  // =====================================================

  Future<bool> sendRoomMessage({
    required String roomId,
    required String receiverId,
    required String message,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) {
    return sendMessage(
      roomId:
          roomId,
      receiverId:
          receiverId,
      message:
          message,
      bookingId:
          bookingId,
      serviceId:
          serviceId,
      negotiationMode:
          negotiationMode,
    );
  }

  // =====================================================
  // SEND IMAGE
  // =====================================================

  Future<bool> sendImageMessage({
    required String roomId,
    required String receiverId,
    required String imageUrl,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    final normalizedReceiverId =
        _normalize(
      receiverId,
    );

    final normalizedImageUrl =
        _normalize(
      imageUrl,
    );

    if (normalizedRoomId.isEmpty) {
      _setError(
        'Chat room is required.',
      );

      return false;
    }

    if (normalizedReceiverId.isEmpty) {
      _setError(
        'Receiver is required.',
      );

      return false;
    }

    if (normalizedImageUrl.isEmpty) {
      _setError(
        'Image is required.',
      );

      return false;
    }

    try {
      _setError(
        null,
      );

      final newMessage =
          await _repository
              .sendImageMessage(
        roomId:
            normalizedRoomId,
        receiverId:
            normalizedReceiverId,
        imageUrl:
            normalizedImageUrl,
        bookingId:
            _optionalValue(
          bookingId,
        ),
        serviceId:
            _optionalValue(
          serviceId,
        ),
        negotiationMode:
            negotiationMode,
      );

      _addMessageIfMissing(
        newMessage,
      );

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        error,
      );

      return false;
    }
  }

  // =====================================================
  // SEND VIDEO
  // =====================================================

  Future<bool> sendVideoMessage({
    required String roomId,
    required String receiverId,
    required String videoUrl,
    String? thumbnailUrl,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    final normalizedReceiverId =
        _normalize(
      receiverId,
    );

    final normalizedVideoUrl =
        _normalize(
      videoUrl,
    );

    if (normalizedRoomId.isEmpty) {
      _setError(
        'Chat room is required.',
      );

      return false;
    }

    if (normalizedReceiverId.isEmpty) {
      _setError(
        'Receiver is required.',
      );

      return false;
    }

    if (normalizedVideoUrl.isEmpty) {
      _setError(
        'Video is required.',
      );

      return false;
    }

    try {
      _setError(
        null,
      );

      final newMessage =
          await _repository
              .sendVideoMessage(
        roomId:
            normalizedRoomId,
        receiverId:
            normalizedReceiverId,
        videoUrl:
            normalizedVideoUrl,
        thumbnailUrl:
            thumbnailUrl,
        bookingId:
            _optionalValue(
          bookingId,
        ),
        serviceId:
            _optionalValue(
          serviceId,
        ),
        negotiationMode:
            negotiationMode,
      );

      _addMessageIfMissing(
        newMessage,
      );

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        error,
      );

      return false;
    }
  }

  // =====================================================
  // SEND FILE
  // =====================================================

  Future<bool> sendFileMessage({
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
        _normalize(
      roomId,
    );

    final normalizedReceiverId =
        _normalize(
      receiverId,
    );

    final normalizedFileUrl =
        _normalize(
      fileUrl,
    );

    final normalizedFileName =
        _normalize(
      fileName,
    );

    if (normalizedRoomId.isEmpty) {
      _setError(
        'Chat room is required.',
      );

      return false;
    }

    if (normalizedReceiverId.isEmpty) {
      _setError(
        'Receiver is required.',
      );

      return false;
    }

    if (normalizedFileUrl.isEmpty ||
        normalizedFileName.isEmpty) {
      _setError(
        'File information is required.',
      );

      return false;
    }

    if (!fileSize.isFinite ||
        fileSize < 0) {
      _setError(
        'Valid file size is required.',
      );

      return false;
    }

    try {
      _setError(
        null,
      );

      final newMessage =
          await _repository
              .sendFileMessage(
        roomId:
            normalizedRoomId,
        receiverId:
            normalizedReceiverId,
        fileUrl:
            normalizedFileUrl,
        fileName:
            normalizedFileName,
        fileSize:
            fileSize,
        bookingId:
            _optionalValue(
          bookingId,
        ),
        serviceId:
            _optionalValue(
          serviceId,
        ),
        negotiationMode:
            negotiationMode,
      );

      _addMessageIfMissing(
        newMessage,
      );

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        error,
      );

      return false;
    }
  }

  // =====================================================
  // SEND LOCATION
  // =====================================================

  Future<bool> sendLocationMessage({
    required String roomId,
    required String receiverId,
    required double latitude,
    required double longitude,
    String? bookingId,
    String? serviceId,
    bool negotiationMode = false,
  }) async {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    final normalizedReceiverId =
        _normalize(
      receiverId,
    );

    if (normalizedRoomId.isEmpty) {
      _setError(
        'Chat room is required.',
      );

      return false;
    }

    if (normalizedReceiverId.isEmpty) {
      _setError(
        'Receiver is required.',
      );

      return false;
    }

    if (!latitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        !longitude.isFinite ||
        longitude < -180 ||
        longitude > 180) {
      _setError(
        'A valid location is required.',
      );

      return false;
    }

    try {
      _setError(
        null,
      );

      final newMessage =
          await _repository
              .sendLocationMessage(
        roomId:
            normalizedRoomId,
        receiverId:
            normalizedReceiverId,
        latitude:
            latitude,
        longitude:
            longitude,
        bookingId:
            _optionalValue(
          bookingId,
        ),
        serviceId:
            _optionalValue(
          serviceId,
        ),
        negotiationMode:
            negotiationMode,
      );

      _addMessageIfMissing(
        newMessage,
      );

      _safeNotifyListeners();

      return true;
    } catch (error) {
      _setError(
        error,
      );

      return false;
    }
  }

  // =====================================================
  // SOCKET MESSAGE
  // =====================================================

  void addIncomingMessage(
    ChatMessageModel message,
  ) {
    _addMessageIfMissing(
      message,
    );

    _safeNotifyListeners();
  }

  void addLocalMessage(
    ChatMessageModel message,
  ) {
    addIncomingMessage(
      message,
    );
  }

  // =====================================================
  // MARK MESSAGE AS READ
  // =====================================================

  Future<bool> markAsRead(
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
      return await _repository.markAsRead(
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
        _normalize(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return false;
    }

    try {
      final success =
          await _repository.markRoomAsRead(
        normalizedRoomId,
      );

      if (success) {
        await getUnreadCount();
      }

      return success;
    } catch (error) {
      debugPrint(
        'MARK CHAT ROOM READ ERROR: $error',
      );

      return false;
    }
  }

  // =====================================================
  // JOIN ROOM
  // =====================================================

  void joinRoom({
    required String roomId,
    String bookingId = '',
    String customerId = '',
    String serviceId = '',
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

    final normalizedBookingId =
        _normalize(
      bookingId,
    );

    final normalizedCustomerId =
        _normalize(
      customerId,
    );

    final normalizedServiceId =
        _normalize(
      serviceId,
    );

    if (normalizedBookingId.isNotEmpty) {
      _currentBookingId =
          normalizedBookingId;

      _chatMode =
          ChatMode.booking;
    }

    if (normalizedCustomerId.isNotEmpty) {
      _currentCustomerId =
          normalizedCustomerId;
    }

    if (normalizedServiceId.isNotEmpty) {
      _currentServiceId =
          normalizedServiceId;
    }

    _isConnected = true;

    _safeNotifyListeners();
  }

  // =====================================================
  // JOIN NEGOTIATION ROOM
  // =====================================================

  void joinNegotiationRoom({
    required String roomId,
    required String serviceId,
    required String customerId,
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

    _currentServiceId =
        _normalize(
      serviceId,
    );

    _currentCustomerId =
        _normalize(
      customerId,
    );

    _currentTopic =
        _normalize(
      topic,
    );

    _currentBookingId = '';

    _chatMode =
        ChatMode.negotiation;

    _isConnected = true;

    _safeNotifyListeners();
  }

  // =====================================================
  // LEAVE ROOM
  // =====================================================

  void leaveRoom(
    String roomId,
  ) {
    final normalizedRoomId =
        _normalize(
      roomId,
    );

    if (_currentRoomId !=
        normalizedRoomId) {
      return;
    }

    _clearConversationState(
      clearMessages: false,
    );

    _safeNotifyListeners();
  }

  // =====================================================
  // TYPING
  //
  // roomId and receiverId remain separate.
  //
  // bookingId is optional because negotiation does not
  // have a Booking.
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
     * Hook your Socket.IO typing event here.
     *
     * Expected metadata:
     *
     * roomId
     * receiverId
     * bookingId optional
     */

    _safeNotifyListeners();
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

    _safeNotifyListeners();
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

    _safeNotifyListeners();
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
      final success =
          await _repository.deleteMessage(
        normalizedMessageId,
      );

      if (success) {
        _messages.removeWhere(
          (message) =>
              message.id ==
              normalizedMessageId,
        );

        _safeNotifyListeners();
      }

      return success;
    } catch (error) {
      _setError(
        error,
      );

      return false;
    }
  }

  // =====================================================
  // SEARCH MESSAGES
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
      return await _repository.searchMessages(
        roomId:
            normalizedRoomId,
        keyword:
            normalizedKeyword,
      );
    } catch (error) {
      _setError(
        error,
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

      _safeNotifyListeners();
    } catch (error) {
      debugPrint(
        'GET CHAT UNREAD COUNT ERROR: $error',
      );

      _unreadCount = 0;

      _safeNotifyListeners();
    }
  }

  // =====================================================
  // CHAT ANALYTICS
  // =====================================================

  Future<void> getChatAnalytics() async {
    try {
      final result =
          await _repository.getChatAnalytics();

      _analytics =
          Map<String, dynamic>.from(
        result,
      );

      _safeNotifyListeners();
    } catch (error) {
      _setError(
        error,
      );
    }
  }

  // =====================================================
  // BLOCK USER
  // =====================================================

  Future<bool> blockUser(
    String userId,
  ) async {
    final normalizedUserId =
        _normalize(
      userId,
    );

    if (normalizedUserId.isEmpty) {
      return false;
    }

    try {
      return await _repository.blockUser(
        normalizedUserId,
      );
    } catch (error) {
      _setError(
        error,
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
        _normalize(
      userId,
    );

    if (normalizedUserId.isEmpty) {
      return false;
    }

    try {
      return await _repository.unblockUser(
        normalizedUserId,
      );
    } catch (error) {
      _setError(
        error,
      );

      return false;
    }
  }

  // =====================================================
  // REFRESH
  // =====================================================

  Future<void> refreshData() async {
    await Future.wait<void>(
      <Future<void>>[
        getChatRooms(),
        getUnreadCount(),
        getChatAnalytics(),
      ],
    );
  }

  // =====================================================
  // CLEAR CURRENT CHAT
  // =====================================================

  void clearCurrentChat() {
    _clearConversationState();

    _safeNotifyListeners();
  }

  // =====================================================
  // RESET
  // =====================================================

  void reset() {
    _chatRooms =
        <dynamic>[];

    _messages =
        <ChatMessageModel>[];

    _unreadCount = 0;

    _analytics =
        <String, dynamic>{};

    _errorMessage = null;

    _isLoading = false;

    _clearConversationState(
      clearMessages: false,
    );

    _safeNotifyListeners();
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _disposed = true;

    super.dispose();
  }
}