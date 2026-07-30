import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart'
    as io;

import '../core/storage/storage_helper.dart';

class SocketService {
  SocketService._();

  static final SocketService _instance =
      SocketService._();

  static SocketService get instance =>
      _instance;

  io.Socket? _socket;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  io.Socket? get socket => _socket;

  // =========================
  // CONNECT SOCKET
  // =========================

  Future<void> connect() async {
    try {
      final token =
          await StorageHelper.getToken();

      if (token == null ||
          token.isEmpty) {
        log('Socket Token Missing');
        return;
      }

      _socket = io.io(
        'https://your-api-domain.com',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(3000)
            .setAuth({
              'token': token,
            })
            .build(),
      );

      _registerCoreListeners();

      _socket?.connect();
    } catch (e) {
      log('Socket Connect Error: $e');
    }
  }

  // =========================
  // CORE LISTENERS
  // =========================

  void _registerCoreListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;

      log('Socket Connected');

      final providerId =
          StorageHelper.getString(
        'provider_id',
      );

      if (providerId != null) {
        joinProviderRoom(providerId);
      }
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;

      log('Socket Disconnected');
    });

    _socket?.onReconnect((_) {
      log('Socket Reconnected');
    });

    _socket?.onReconnectAttempt((_) {
      log('Socket Reconnecting...');
    });

    _socket?.onConnectError((error) {
      log(
        'Socket Connect Error: $error',
      );
    });

    _socket?.onError((error) {
      log('Socket Error: $error');
    });
  }

  // =========================
  // JOIN PROVIDER ROOM
  // =========================

  void joinProviderRoom(
    String providerId,
  ) {
    _socket?.emit(
      'join_provider',
      {
        'providerId': providerId,
      },
    );
  }

  // =========================
  // JOIN CHAT ROOM
  // =========================

  void joinChatRoom(
    String roomId,
  ) {
    _socket?.emit(
      'join_chat_room',
      {
        'roomId': roomId,
      },
    );
  }

  // =========================
  // LEAVE CHAT ROOM
  // =========================

  void leaveChatRoom(
    String roomId,
  ) {
    _socket?.emit(
      'leave_chat_room',
      {
        'roomId': roomId,
      },
    );
  }

  // =========================
  // SEND MESSAGE
  // =========================

  void sendMessage({
    required String roomId,
    required String senderId,
    required String receiverId,
    required String message,
    String messageType = 'text',
  }) {
    _socket?.emit(
      'send_message',
      {
        'roomId': roomId,
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'messageType': messageType,
      },
    );
  }

  // =========================
  // SEND TYPING
  // =========================

  void sendTyping({
    required String roomId,
    required String userId,
  }) {
    _socket?.emit(
      'typing',
      {
        'roomId': roomId,
        'userId': userId,
      },
    );
  }

  // =========================
  // STOP TYPING
  // =========================

  void stopTyping({
    required String roomId,
    required String userId,
  }) {
    _socket?.emit(
      'stop_typing',
      {
        'roomId': roomId,
        'userId': userId,
      },
    );
  }

  // =========================
  // MESSAGE READ
  // =========================

  void markMessageRead({
    required String messageId,
    required String roomId,
  }) {
    _socket?.emit(
      'message_read',
      {
        'messageId': messageId,
        'roomId': roomId,
      },
    );
  }

  // =========================
  // PROVIDER ONLINE
  // =========================

  void updateOnlineStatus(
    bool isOnline,
  ) {
    _socket?.emit(
      'provider_online_status',
      {
        'isOnline': isOnline,
      },
    );
  }

  // =========================
  // LOCATION UPDATE
  // =========================

  void updateLocation({
    required double latitude,
    required double longitude,
  }) {
    _socket?.emit(
      'provider_location',
      {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // =========================
  // BOOKING ACCEPTED
  // =========================

  void bookingAccepted(
    String bookingId,
  ) {
    _socket?.emit(
      'booking_accepted',
      {
        'bookingId': bookingId,
      },
    );
  }

  // =========================
  // BOOKING STARTED
  // =========================

  void bookingStarted(
    String bookingId,
  ) {
    _socket?.emit(
      'booking_started',
      {
        'bookingId': bookingId,
      },
    );
  }

  // =========================
  // BOOKING COMPLETED
  // =========================

  void bookingCompleted(
    String bookingId,
  ) {
    _socket?.emit(
      'booking_completed',
      {
        'bookingId': bookingId,
      },
    );
  }

  // =========================
  // LISTEN NEW MESSAGE
  // =========================

  void onNewMessage(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'new_message',
      callback,
    );
  }

  // =========================
  // LISTEN TYPING
  // =========================

  void onTyping(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'typing',
      callback,
    );
  }

  // =========================
  // LISTEN STOP TYPING
  // =========================

  void onStopTyping(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'stop_typing',
      callback,
    );
  }

  // =========================
  // LISTEN NOTIFICATIONS
  // =========================

  void onNotification(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'notification',
      callback,
    );
  }

  // =========================
  // LISTEN BOOKING EVENTS
  // =========================

  void onBookingUpdate(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'booking_update',
      callback,
    );
  }

  // =========================
  // LISTEN PAYMENT EVENTS
  // =========================

  void onPaymentUpdate(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'payment_update',
      callback,
    );
  }

  // =========================
  // LISTEN ORDER EVENTS
  // =========================

  void onOrderUpdate(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'order_update',
      callback,
    );
  }

  // =========================
  // REMOVE LISTENER
  // =========================

  void off(String event) {
    _socket?.off(event);
  }

  // =========================
  // REMOVE ALL LISTENERS
  // =========================

  void removeAllListeners() {
    _socket?.clearListeners();
  }

  // =========================
  // DISCONNECT
  // =========================

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();

    _socket = null;
    _isConnected = false;

    log('Socket Closed');
  }
}