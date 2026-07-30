import 'package:socket_io_client/socket_io_client.dart'
    as io;

import '../config/api_config.dart';
import 'api_service.dart';

class SocketService {
  SocketService._();

  static final SocketService instance =
      SocketService._();

  io.Socket? _socket;

  io.Socket? get socket => _socket;

  bool get isConnected =>
      _socket?.connected ?? false;

  // ==========================================
  // CONNECT SOCKET
  // ==========================================

  Future<void> connect({
    required String token,
  }) async {
    if (_socket != null &&
        _socket!.connected) {
      return;
    }

    _socket = io.io(
      ApiConfig.socketUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'forceNew': true,
        'auth': {
          'token': token,
        },
      },
    );

    _socket!.connect();
  }

  // ==========================================
  // DISCONNECT
  // ==========================================

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ==========================================
  // JOIN ROOM
  // ==========================================

  void joinRoom(String roomId) {
    _socket?.emit(
      'join_room',
      {
        'roomId': roomId,
      },
    );
  }

  // ==========================================
  // LEAVE ROOM
  // ==========================================

  void leaveRoom(String roomId) {
    _socket?.emit(
      'leave_room',
      {
        'roomId': roomId,
      },
    );
  }

  // ==========================================
  // SEND MESSAGE
  // ==========================================

  void sendMessage({
    required String roomId,
    required String message,
    required String type,
  }) {
    _socket?.emit(
      'send_message',
      {
        'roomId': roomId,
        'message': message,
        'type': type,
      },
    );
  }

  // ==========================================
  // SEND IMAGE MESSAGE
  // ==========================================

  void sendImage({
    required String roomId,
    required String imageUrl,
  }) {
    _socket?.emit(
      'send_message',
      {
        'roomId': roomId,
        'message': imageUrl,
        'type': 'image',
      },
    );
  }

  // ==========================================
  // SEND LOCATION
  // ==========================================

  void sendLocation({
    required String roomId,
    required double latitude,
    required double longitude,
  }) {
    _socket?.emit(
      'send_message',
      {
        'roomId': roomId,
        'type': 'location',
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // ==========================================
  // TYPING START
  // ==========================================

  void startTyping(
    String roomId,
  ) {
    _socket?.emit(
      'typing',
      {
        'roomId': roomId,
      },
    );
  }

  // ==========================================
  // TYPING STOP
  // ==========================================

  void stopTyping(
    String roomId,
  ) {
    _socket?.emit(
      'stop_typing',
      {
        'roomId': roomId,
      },
    );
  }

  // ==========================================
  // READ RECEIPT
  // ==========================================

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

  // ==========================================
  // BOOKING TRACKING
  // ==========================================

  void trackBooking(
    String bookingId,
  ) {
    _socket?.emit(
      'track_booking',
      {
        'bookingId': bookingId,
      },
    );
  }

  // ==========================================
  // ORDER TRACKING
  // ==========================================

  void trackOrder(
    String orderId,
  ) {
    _socket?.emit(
      'track_order',
      {
        'orderId': orderId,
      },
    );
  }

  // ==========================================
  // PROVIDER LIVE LOCATION
  // ==========================================

  void updateProviderLocation({
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

  // ==========================================
  // CONNECTION EVENTS
  // ==========================================

  void onConnect(
    Function() callback,
  ) {
    _socket?.on(
      'connect',
      (_) => callback(),
    );
  }

  void onDisconnect(
    Function() callback,
  ) {
    _socket?.on(
      'disconnect',
      (_) => callback(),
    );
  }

  // ==========================================
  // NEW MESSAGE
  // ==========================================

  void onMessage(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'new_message',
      callback,
    );
  }

  // ==========================================
  // TYPING INDICATOR
  // ==========================================

  void onTyping(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'typing',
      callback,
    );
  }

  // ==========================================
  // STOP TYPING
  // ==========================================

  void onStopTyping(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'stop_typing',
      callback,
    );
  }

  // ==========================================
  // MESSAGE READ
  // ==========================================

  void onMessageRead(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'message_read',
      callback,
    );
  }

  // ==========================================
  // BOOKING STATUS UPDATE
  // ==========================================

  void onBookingUpdate(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'booking_updated',
      callback,
    );
  }

  // ==========================================
  // ORDER STATUS UPDATE
  // ==========================================

  void onOrderUpdate(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'order_updated',
      callback,
    );
  }

  // ==========================================
  // LIVE LOCATION UPDATE
  // ==========================================

  void onLocationUpdate(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'location_updated',
      callback,
    );
  }

  // ==========================================
  // GENERAL NOTIFICATIONS
  // ==========================================

  void onNotification(
    Function(dynamic data) callback,
  ) {
    _socket?.on(
      'notification',
      callback,
    );
  }

  // ==========================================
  // REMOVE EVENT
  // ==========================================

  void removeListener(
    String event,
  ) {
    _socket?.off(event);
  }

  // ==========================================
  // REMOVE ALL EVENTS
  // ==========================================

  void clearListeners() {
    _socket?.clearListeners();
  }
}