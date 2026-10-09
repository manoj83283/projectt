import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart'
    as io;

import '../config/api_config.dart';

typedef SocketEventCallback = FutureOr<void> Function(
  dynamic data,
);

class SocketService {
  SocketService._();

  static final SocketService instance =
      SocketService._();

  io.Socket? _socket;

  String _token = '';
  String _customerId = '';

  bool _manuallyDisconnected = false;
  bool _bookingListenersRegistered = false;

  SocketEventCallback? _bookingCallback;
  SocketEventCallback? _notificationCallback;

  io.Socket? get socket {
    return _socket;
  }

  bool get isConnected {
    return _socket?.connected ?? false;
  }

  String get customerId {
    return _customerId;
  }

  static const List<String> bookingEvents =
      <String>[
    'newBooking',
    'bookingUpdate',
    'bookingUpdated',
    'bookingAccepted',
    'bookingRejected',
    'providerArrived',
    'bookingOtpVerified',
    'bookingStarted',
    'bookingCompleted',
    'bookingCancelled',
    'bookingRated',
    'refreshBookings',
    'refreshCustomerBookings',
  ];

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
        (key, dynamic item) {
          return MapEntry(
            key.toString(),
            item,
          );
        },
      );
    }

    return <String, dynamic>{};
  }

  String _normalizedRoomId(
    String value,
  ) {
    return value.trim();
  }

  String _normalizedBookingRoomId(
    String value,
  ) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      return '';
    }

    if (normalized.startsWith('booking:')) {
      return normalized;
    }

    return 'booking:$normalized';
  }

  void _debug(
    String message,
  ) {
    if (kDebugMode) {
      debugPrint(
        'SOCKET SERVICE: $message',
      );
    }
  }

  Future<void> _invokeCallback(
    SocketEventCallback? callback,
    dynamic data,
  ) async {
    if (callback == null) {
      return;
    }

    try {
      await callback(data);
    } catch (
      error,
      stackTrace
    ) {
      _debug(
        'Listener callback failed: $error',
      );

      if (kDebugMode) {
        debugPrint(
          '$stackTrace',
        );
      }
    }
  }

  // =====================================================
  // CONNECT
  // =====================================================

  Future<void> connect({
    required String token,
    String? customerId,
  }) async {
    final normalizedToken =
        token.trim();

    final normalizedCustomerId =
        customerId?.trim() ?? '';

    if (normalizedToken.isEmpty) {
      throw ArgumentError(
        'Socket authentication token is required.',
      );
    }

    _token = normalizedToken;

    if (normalizedCustomerId.isNotEmpty) {
      _customerId =
          normalizedCustomerId;
    }

    _manuallyDisconnected = false;

    if (_socket != null) {
      if (_socket!.connected) {
        _joinCustomerRooms();

        if (_bookingCallback != null) {
          _registerBookingListeners();
        }

        return;
      }

      _disposeSocket();
    }

    final socket = io.io(
      ApiConfig.socketUrl,
      <String, dynamic>{
        'transports': <String>[
          'websocket',
          'polling',
        ],
        'autoConnect': false,
        'forceNew': true,
        'reconnection': true,
        'reconnectionAttempts': 10,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'timeout': 20000,
        'auth': <String, dynamic>{
          'token': normalizedToken,
        },
        'query': <String, dynamic>{
          'token': normalizedToken,
          if (_customerId.isNotEmpty)
            'userId': _customerId,
        },
        'extraHeaders': <String, dynamic>{
          'Authorization':
              'Bearer $normalizedToken',
        },
      },
    );

    _socket = socket;

    _registerConnectionListeners();

    if (_bookingCallback != null) {
      _registerBookingListeners();
    }

    if (_notificationCallback != null) {
      _registerNotificationListeners();
    }

    socket.connect();
  }

  // =====================================================
  // CONNECTION LISTENERS
  // =====================================================

  void _registerConnectionListeners() {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    socket.off('connect');
    socket.off('disconnect');
    socket.off('connect_error');
    socket.off('error');
    socket.off('reconnect');
    socket.off('reconnect_attempt');

    socket.on(
      'connect',
      (_) {
        _debug(
          'Connected with ID ${socket.id}',
        );

        _joinCustomerRooms();

        if (_bookingCallback != null) {
          _registerBookingListeners();
        }

        if (_notificationCallback != null) {
          _registerNotificationListeners();
        }
      },
    );

    socket.on(
      'disconnect',
      (dynamic reason) {
        _debug(
          'Disconnected: $reason',
        );
      },
    );

    socket.on(
      'connect_error',
      (dynamic error) {
        _debug(
          'Connection error: $error',
        );
      },
    );

    socket.on(
      'error',
      (dynamic error) {
        _debug(
          'Socket error: $error',
        );
      },
    );

    socket.on(
      'reconnect',
      (dynamic attempt) {
        _debug(
          'Reconnected after attempt $attempt',
        );

        _joinCustomerRooms();
      },
    );

    socket.on(
      'reconnect_attempt',
      (dynamic attempt) {
        _debug(
          'Reconnect attempt $attempt',
        );
      },
    );
  }

  // =====================================================
  // CUSTOMER ROOM
  // =====================================================

  void setCustomerId(
    String customerId,
  ) {
    final normalized =
        customerId.trim();

    if (normalized.isEmpty) {
      return;
    }

    _customerId = normalized;

    if (isConnected) {
      _joinCustomerRooms();
    }
  }

  void _joinCustomerRooms() {
    if (!isConnected ||
        _customerId.isEmpty) {
      return;
    }

    final payload =
        <String, dynamic>{
      'userId': _customerId,
      'customerId': _customerId,
      'roomId': 'user:$_customerId',
    };

    /*
     * These aliases allow compatibility with common backend
     * registration handlers. Unknown events are harmless.
     */
    _socket?.emit(
      'join_user',
      payload,
    );

    _socket?.emit(
      'joinUser',
      payload,
    );

    _socket?.emit(
      'register_user',
      payload,
    );

    _socket?.emit(
      'registerUser',
      payload,
    );

    _socket?.emit(
      'join_room',
      <String, dynamic>{
        'roomId':
            'user:$_customerId',
      },
    );

    _debug(
      'Joined customer room user:$_customerId',
    );
  }

  void joinCustomerRoom(
    String customerId,
  ) {
    setCustomerId(
      customerId,
    );
  }

  // =====================================================
  // DISCONNECT
  // =====================================================

  void disconnect() {
    _manuallyDisconnected = true;

    if (_customerId.isNotEmpty) {
      _socket?.emit(
        'leave_room',
        <String, dynamic>{
          'roomId':
              'user:$_customerId',
        },
      );
    }

    _disposeSocket();

    _token = '';
    _customerId = '';
  }

  void _disposeSocket() {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    socket.clearListeners();
    socket.disconnect();
    socket.dispose();

    _socket = null;
    _bookingListenersRegistered = false;
  }

  // =====================================================
  // RECONNECT
  // =====================================================

  Future<void> reconnect() async {
    if (_manuallyDisconnected ||
        _token.isEmpty) {
      return;
    }

    await connect(
      token: _token,
      customerId: _customerId,
    );
  }

  // =====================================================
  // GENERAL ROOM
  // =====================================================

  void joinRoom(
    String roomId,
  ) {
    final normalizedRoomId =
        _normalizedRoomId(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    _socket?.emit(
      'join_room',
      <String, dynamic>{
        'roomId':
            normalizedRoomId,
      },
    );

    _socket?.emit(
      'joinRoom',
      <String, dynamic>{
        'roomId':
            normalizedRoomId,
      },
    );
  }

  void leaveRoom(
    String roomId,
  ) {
    final normalizedRoomId =
        _normalizedRoomId(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    _socket?.emit(
      'leave_room',
      <String, dynamic>{
        'roomId':
            normalizedRoomId,
      },
    );

    _socket?.emit(
      'leaveRoom',
      <String, dynamic>{
        'roomId':
            normalizedRoomId,
      },
    );
  }

  // =====================================================
  // BOOKING ROOM
  // =====================================================

  void joinBookingRoom(
    String bookingId,
  ) {
    final roomId =
        _normalizedBookingRoomId(
      bookingId,
    );

    if (roomId.isEmpty) {
      return;
    }

    joinRoom(
      roomId,
    );

    _socket?.emit(
      'track_booking',
      <String, dynamic>{
        'bookingId':
            bookingId
                .replaceFirst(
              'booking:',
              '',
            ),
        'roomId':
            roomId,
      },
    );

    _socket?.emit(
      'trackBooking',
      <String, dynamic>{
        'bookingId':
            bookingId
                .replaceFirst(
              'booking:',
              '',
            ),
        'roomId':
            roomId,
      },
    );
  }

  void leaveBookingRoom(
    String bookingId,
  ) {
    final roomId =
        _normalizedBookingRoomId(
      bookingId,
    );

    if (roomId.isEmpty) {
      return;
    }

    leaveRoom(
      roomId,
    );
  }

  void trackBooking(
    String bookingId,
  ) {
    joinBookingRoom(
      bookingId,
    );
  }

  // =====================================================
  // BOOKING LIFECYCLE LISTENERS
  // =====================================================

  void registerCustomerBookingListeners(
    SocketEventCallback callback,
  ) {
    _bookingCallback = callback;

    _registerBookingListeners();
  }

  void _registerBookingListeners() {
    final socket = _socket;
    final callback =
        _bookingCallback;

    if (socket == null ||
        callback == null) {
      return;
    }

    for (final event in bookingEvents) {
      socket.off(event);

      socket.on(
        event,
        (dynamic data) {
          _debug(
            'Received $event',
          );

          _invokeCallback(
            callback,
            data,
          );
        },
      );
    }

    /*
     * Legacy aliases retained for older backend handlers.
     */
    const legacyEvents =
        <String>[
      'booking_updated',
      'booking_update',
      'booking_accepted',
      'booking_rejected',
      'provider_arrived',
      'booking_otp_verified',
      'booking_started',
      'booking_completed',
      'booking_cancelled',
      'refresh_customer_bookings',
    ];

    for (final event in legacyEvents) {
      socket.off(event);

      socket.on(
        event,
        (dynamic data) {
          _debug(
            'Received legacy event $event',
          );

          _invokeCallback(
            callback,
            data,
          );
        },
      );
    }

    _bookingListenersRegistered = true;

    _debug(
      'Customer booking listeners registered',
    );
  }

  void removeCustomerBookingListeners() {
    final socket = _socket;

    if (socket == null) {
      return;
    }

    for (final event in bookingEvents) {
      socket.off(event);
    }

    const legacyEvents =
        <String>[
      'booking_updated',
      'booking_update',
      'booking_accepted',
      'booking_rejected',
      'provider_arrived',
      'booking_otp_verified',
      'booking_started',
      'booking_completed',
      'booking_cancelled',
      'refresh_customer_bookings',
    ];

    for (final event in legacyEvents) {
      socket.off(event);
    }

    _bookingCallback = null;
    _bookingListenersRegistered = false;
  }

  void onBookingUpdate(
    SocketEventCallback callback,
  ) {
    registerCustomerBookingListeners(
      callback,
    );
  }

  // =====================================================
  // CHAT SEND
  // =====================================================

  void sendMessage({
    required String roomId,
    required String message,
    String type = 'text',
    String? bookingId,
    String? receiverId,
  }) {
    final normalizedRoomId =
        _normalizedRoomId(
      roomId,
    );

    final normalizedMessage =
        message.trim();

    if (normalizedRoomId.isEmpty ||
        normalizedMessage.isEmpty) {
      return;
    }

    final payload =
        <String, dynamic>{
      'roomId':
          normalizedRoomId,
      'message':
          normalizedMessage,
      'type':
          type.trim().isEmpty
              ? 'text'
              : type.trim(),
      if (bookingId != null &&
          bookingId.trim().isNotEmpty)
        'bookingId':
            bookingId.trim(),
      if (receiverId != null &&
          receiverId.trim().isNotEmpty)
        'receiverId':
            receiverId.trim(),
    };

    _socket?.emit(
      'send_message',
      payload,
    );

    _socket?.emit(
      'sendMessage',
      payload,
    );
  }

  void sendImage({
    required String roomId,
    required String imageUrl,
    String? bookingId,
    String? receiverId,
  }) {
    sendMessage(
      roomId: roomId,
      message: imageUrl,
      type: 'image',
      bookingId: bookingId,
      receiverId: receiverId,
    );
  }

  void sendLocation({
    required String roomId,
    required double latitude,
    required double longitude,
    String? bookingId,
    String? receiverId,
  }) {
    final normalizedRoomId =
        _normalizedRoomId(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    final payload =
        <String, dynamic>{
      'roomId':
          normalizedRoomId,
      'type':
          'location',
      'message':
          '$latitude,$longitude',
      'latitude':
          latitude,
      'longitude':
          longitude,
      if (bookingId != null &&
          bookingId.trim().isNotEmpty)
        'bookingId':
            bookingId.trim(),
      if (receiverId != null &&
          receiverId.trim().isNotEmpty)
        'receiverId':
            receiverId.trim(),
    };

    _socket?.emit(
      'send_message',
      payload,
    );

    _socket?.emit(
      'sendMessage',
      payload,
    );
  }

  // =====================================================
  // CHAT LISTENERS
  // =====================================================

  void onMessage(
    SocketEventCallback callback,
  ) {
    const events =
        <String>[
      'new_message',
      'newMessage',
      'messageReceived',
      'receive_message',
    ];

    for (final event in events) {
      _socket?.off(event);

      _socket?.on(
        event,
        (dynamic data) {
          _invokeCallback(
            callback,
            data,
          );
        },
      );
    }
  }

  // =====================================================
  // TYPING
  // =====================================================

  void startTyping(
    String roomId, {
    String? bookingId,
    String? receiverId,
  }) {
    final normalizedRoomId =
        _normalizedRoomId(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    final payload =
        <String, dynamic>{
      'roomId':
          normalizedRoomId,
      if (bookingId != null &&
          bookingId.trim().isNotEmpty)
        'bookingId':
            bookingId.trim(),
      if (receiverId != null &&
          receiverId.trim().isNotEmpty)
        'receiverId':
            receiverId.trim(),
    };

    _socket?.emit(
      'typing',
      payload,
    );
  }

  void stopTyping(
    String roomId, {
    String? bookingId,
    String? receiverId,
  }) {
    final normalizedRoomId =
        _normalizedRoomId(
      roomId,
    );

    if (normalizedRoomId.isEmpty) {
      return;
    }

    final payload =
        <String, dynamic>{
      'roomId':
          normalizedRoomId,
      if (bookingId != null &&
          bookingId.trim().isNotEmpty)
        'bookingId':
            bookingId.trim(),
      if (receiverId != null &&
          receiverId.trim().isNotEmpty)
        'receiverId':
            receiverId.trim(),
    };

    _socket?.emit(
      'stop_typing',
      payload,
    );

    _socket?.emit(
      'stopTyping',
      payload,
    );
  }

  void onTyping(
    SocketEventCallback callback,
  ) {
    _socket?.off('typing');

    _socket?.on(
      'typing',
      (dynamic data) {
        _invokeCallback(
          callback,
          data,
        );
      },
    );
  }

  void onStopTyping(
    SocketEventCallback callback,
  ) {
    const events =
        <String>[
      'stop_typing',
      'stopTyping',
    ];

    for (final event in events) {
      _socket?.off(event);

      _socket?.on(
        event,
        (dynamic data) {
          _invokeCallback(
            callback,
            data,
          );
        },
      );
    }
  }

  // =====================================================
  // READ RECEIPTS
  // =====================================================

  void markMessageRead({
    required String roomId,
    required String messageId,
  }) {
    final normalizedRoomId =
        roomId.trim();

    final normalizedMessageId =
        messageId.trim();

    if (normalizedRoomId.isEmpty ||
        normalizedMessageId.isEmpty) {
      return;
    }

    final payload =
        <String, dynamic>{
      'roomId':
          normalizedRoomId,
      'messageId':
          normalizedMessageId,
    };

    _socket?.emit(
      'message_read',
      payload,
    );

    _socket?.emit(
      'messageRead',
      payload,
    );
  }

  void onMessageRead(
    SocketEventCallback callback,
  ) {
    const events =
        <String>[
      'message_read',
      'messageRead',
    ];

    for (final event in events) {
      _socket?.off(event);

      _socket?.on(
        event,
        (dynamic data) {
          _invokeCallback(
            callback,
            data,
          );
        },
      );
    }
  }

  // =====================================================
  // ORDER TRACKING
  // =====================================================

  void trackOrder(
    String orderId,
  ) {
    final normalizedOrderId =
        orderId.trim();

    if (normalizedOrderId.isEmpty) {
      return;
    }

    _socket?.emit(
      'track_order',
      <String, dynamic>{
        'orderId':
            normalizedOrderId,
      },
    );

    _socket?.emit(
      'trackOrder',
      <String, dynamic>{
        'orderId':
            normalizedOrderId,
      },
    );
  }

  void onOrderUpdate(
    SocketEventCallback callback,
  ) {
    const events =
        <String>[
      'order_updated',
      'orderUpdated',
      'orderUpdate',
    ];

    for (final event in events) {
      _socket?.off(event);

      _socket?.on(
        event,
        (dynamic data) {
          _invokeCallback(
            callback,
            data,
          );
        },
      );
    }
  }

  // =====================================================
  // PROVIDER LOCATION
  // =====================================================

  void updateProviderLocation({
    required double latitude,
    required double longitude,
    String? bookingId,
  }) {
    final payload =
        <String, dynamic>{
      'latitude':
          latitude,
      'longitude':
          longitude,
      if (bookingId != null &&
          bookingId.trim().isNotEmpty)
        'bookingId':
            bookingId.trim(),
    };

    _socket?.emit(
      'provider_location',
      payload,
    );

    _socket?.emit(
      'providerLocation',
      payload,
    );
  }

  void onLocationUpdate(
    SocketEventCallback callback,
  ) {
    const events =
        <String>[
      'location_updated',
      'locationUpdated',
      'providerLocationUpdated',
      'provider_location',
    ];

    for (final event in events) {
      _socket?.off(event);

      _socket?.on(
        event,
        (dynamic data) {
          _invokeCallback(
            callback,
            data,
          );
        },
      );
    }
  }

  // =====================================================
  // NOTIFICATIONS
  // =====================================================

  void onNotification(
    SocketEventCallback callback,
  ) {
    _notificationCallback =
        callback;

    _registerNotificationListeners();
  }

  void _registerNotificationListeners() {
    final callback =
        _notificationCallback;

    if (_socket == null ||
        callback == null) {
      return;
    }

    const events =
        <String>[
      'notification',
      'newNotification',
    ];

    for (final event in events) {
      _socket?.off(event);

      _socket?.on(
        event,
        (dynamic data) {
          _invokeCallback(
            callback,
            data,
          );
        },
      );
    }
  }

  // =====================================================
  // CONNECTION EVENT REGISTRATION
  // =====================================================

  void onConnect(
    VoidCallback callback,
  ) {
    _socket?.off(
      'connect',
    );

    _socket?.on(
      'connect',
      (_) {
        _joinCustomerRooms();
        callback();
      },
    );
  }

  void onDisconnect(
    VoidCallback callback,
  ) {
    _socket?.off(
      'disconnect',
    );

    _socket?.on(
      'disconnect',
      (_) {
        callback();
      },
    );
  }

  void onConnectError(
    SocketEventCallback callback,
  ) {
    _socket?.off(
      'connect_error',
    );

    _socket?.on(
      'connect_error',
      (dynamic data) {
        _invokeCallback(
          callback,
          data,
        );
      },
    );
  }

  // =====================================================
  // GENERIC EVENTS
  // =====================================================

  void on(
    String event,
    SocketEventCallback callback,
  ) {
    final normalizedEvent =
        event.trim();

    if (normalizedEvent.isEmpty) {
      return;
    }

    _socket?.off(
      normalizedEvent,
    );

    _socket?.on(
      normalizedEvent,
      (dynamic data) {
        _invokeCallback(
          callback,
          data,
        );
      },
    );
  }

  void emit(
    String event,
    dynamic data,
  ) {
    final normalizedEvent =
        event.trim();

    if (normalizedEvent.isEmpty) {
      return;
    }

    _socket?.emit(
      normalizedEvent,
      data,
    );
  }

  void removeListener(
    String event,
  ) {
    final normalizedEvent =
        event.trim();

    if (normalizedEvent.isEmpty) {
      return;
    }

    _socket?.off(
      normalizedEvent,
    );
  }

  void clearListeners() {
    _socket?.clearListeners();

    _bookingListenersRegistered = false;
  }
}