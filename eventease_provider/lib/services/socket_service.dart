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

  // =====================================================
  // CONNECT
  // =====================================================

  Future<void> connect() async {
    try {
      final token =
          await StorageHelper.getToken();

      if (token == null ||
          token.trim().isEmpty) {
        log('Socket token missing');
        return;
      }

      disconnect();

      _socket = io.io(
        // CHANGE TO YOUR BACKEND URL
        'http://10.0.2.2:5000',
        io.OptionBuilder()
            .setTransports([
              'websocket',
            ])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(20)
            .setReconnectionDelay(2000)
            .setAuth({
              'token': token,
            })
            .build(),
      );

      _registerCoreListeners();

      _socket?.connect();
    } catch (e) {
      log(
        'Socket Connect Error: $e',
      );
    }
  }

  // =====================================================
  // CORE LISTENERS
  // =====================================================

  void _registerCoreListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;

      log('Socket Connected');

      final providerId =
          StorageHelper.getString(
        'provider_id',
      );

      if (providerId != null &&
          providerId.isNotEmpty) {
        joinProviderRoom(
          providerId,
        );
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
      log(
        'Socket Error: $error',
      );
    });
  }

  // =====================================================
  // PROVIDER ROOM
  // =====================================================

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

  // =====================================================
  // CHAT ROOM
  // =====================================================

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

  // =====================================================
  // CHAT
  // =====================================================

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

  void markMessageRead({
    required String roomId,
    required String messageId,
  }) {
    _socket?.emit(
      'message_read',
      {
        'roomId': roomId,
        'messageId': messageId,
      },
    );
  }

  // =====================================================
  // BOOKING EVENTS
  // =====================================================

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

  void otpVerified(
    String bookingId,
  ) {
    _socket?.emit(
      'booking_otp_verified',
      {
        'bookingId': bookingId,
      },
    );
  }

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

  void bookingCancelled(
    String bookingId,
  ) {
    _socket?.emit(
      'booking_cancelled',
      {
        'bookingId': bookingId,
      },
    );
  }

  void bookingRejected(
    String bookingId,
  ) {
    _socket?.emit(
      'booking_rejected',
      {
        'bookingId': bookingId,
      },
    );
  }

  // =====================================================
  // PROVIDER STATUS
  // =====================================================

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

  // =====================================================
  // LISTENERS
  // =====================================================

  void onNewMessage(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'new_message',
      callback,
    );
  }

  void onTyping(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'typing',
      callback,
    );
  }

  void onStopTyping(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'stop_typing',
      callback,
    );
  }

  void onNotification(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'notification',
      callback,
    );
  }

  void onBookingUpdate(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'booking_update',
      callback,
    );
  }

  void onOrderUpdate(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'order_update',
      callback,
    );
  }

  void onDashboardRefresh(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'refreshProviderDashboard',
      callback,
    );

    _socket?.on(
      'refreshBookings',
      callback,
    );
  }

  void onPaymentUpdate(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'payment_update',
      callback,
    );
  }

  // =====================================================
  // REMOVE LISTENERS
  // =====================================================

  void off(
    String event,
  ) {
    _socket?.off(event);
  }

  void removeAllListeners() {
    _socket?.clearListeners();
  }

  // =====================================================
  // DISCONNECT
  // =====================================================

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();

    _socket = null;

    _isConnected = false;

    log('Socket Closed');
  }
}