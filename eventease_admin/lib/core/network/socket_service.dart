import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart'
    as io;

import '../constants/api_constants.dart';

class SocketService {
  SocketService._();

  static final SocketService _instance =
      SocketService._();

  factory SocketService() => _instance;

  io.Socket? _socket;

  bool _isConnected = false;

  bool get isConnected =>
      _isConnected;

  io.Socket? get socket => _socket;

  // =====================================================
  // CONNECT
  // =====================================================

  Future<void> connect({
    required String token,
  }) async {
    try {
      if (_socket != null &&
          _socket!.connected) {
        return;
      }

      _socket = io.io(
        ApiConstants.baseUrl.replaceAll(
          '/api',
          '',
        ),
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({
              'token': token,
            })
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .build(),
      );

      _registerCoreListeners();

      _socket?.connect();
    } catch (e) {
      log(
        'Socket Connection Error: $e',
      );
    }
  }

  // =====================================================
  // CORE LISTENERS
  // =====================================================

  void _registerCoreListeners() {
    _socket?.onConnect((_) {
      _isConnected = true;

      log(
        'Socket Connected',
      );
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;

      log(
        'Socket Disconnected',
      );
    });

    _socket?.onConnectError((data) {
      log(
        'Socket Connect Error: $data',
      );
    });

    _socket?.onError((data) {
      log(
        'Socket Error: $data',
      );
    });

    _socket?.onReconnect((_) {
      _isConnected = true;

      log(
        'Socket Reconnected',
      );
    });

    _socket?.onReconnectError(
      (data) {
        log(
          'Reconnect Error: $data',
        );
      },
    );
  }

  // =====================================================
  // LISTEN EVENT
  // =====================================================

  void on(
    String event,
    Function(dynamic data) listener,
  ) {
    _socket?.on(
      event,
      listener,
    );
  }

  // =====================================================
  // REMOVE EVENT
  // =====================================================

  void off(String event) {
    _socket?.off(event);
  }

  // =====================================================
  // EMIT EVENT
  // =====================================================

  void emit(
    String event, [
    dynamic data,
  ]) {
    if (_socket == null) return;

    _socket?.emit(
      event,
      data,
    );
  }

  // =====================================================
  // EMIT WITH ACK
  // =====================================================

  void emitWithAck(
    String event,
    dynamic data,
    Function(dynamic response) ack,
  ) {
    _socket?.emitWithAck(
      event,
      data,
      ack: ack,
    );
  }

  // =====================================================
  // JOIN ROOM
  // =====================================================

  void joinRoom(
    String roomId,
  ) {
    emit(
      'join-room',
      {
        'roomId': roomId,
      },
    );
  }

  // =====================================================
  // LEAVE ROOM
  // =====================================================

  void leaveRoom(
    String roomId,
  ) {
    emit(
      'leave-room',
      {
        'roomId': roomId,
      },
    );
  }

  // =====================================================
  // USER ONLINE
  // =====================================================

  void markOnline(
    String userId,
  ) {
    emit(
      'user-online',
      {
        'userId': userId,
      },
    );
  }

  // =====================================================
  // USER OFFLINE
  // =====================================================

  void markOffline(
    String userId,
  ) {
    emit(
      'user-offline',
      {
        'userId': userId,
      },
    );
  }

  // =====================================================
  // BOOKING EVENTS
  // =====================================================

  void subscribeBookings(
    Function(dynamic data) callback,
  ) {
    on(
      'booking-updated',
      callback,
    );
  }

  // =====================================================
  // ORDER EVENTS
  // =====================================================

  void subscribeOrders(
    Function(dynamic data) callback,
  ) {
    on(
      'order-updated',
      callback,
    );
  }

  // =====================================================
  // PAYMENT EVENTS
  // =====================================================

  void subscribePayments(
    Function(dynamic data) callback,
  ) {
    on(
      'payment-updated',
      callback,
    );
  }

  // =====================================================
  // SETTLEMENT EVENTS
  // =====================================================

  void subscribeSettlements(
    Function(dynamic data) callback,
  ) {
    on(
      'settlement-updated',
      callback,
    );
  }

  // =====================================================
  // NOTIFICATION EVENTS
  // =====================================================

  void subscribeNotifications(
    Function(dynamic data) callback,
  ) {
    on(
      'notification',
      callback,
    );
  }

  // =====================================================
  // SUPPORT EVENTS
  // =====================================================

  void subscribeTickets(
    Function(dynamic data) callback,
  ) {
    on(
      'ticket-updated',
      callback,
    );
  }

  // =====================================================
  // DASHBOARD LIVE EVENTS
  // =====================================================

  void subscribeDashboard(
    Function(dynamic data) callback,
  ) {
    on(
      'dashboard-update',
      callback,
    );
  }

  // =====================================================
  // REMOVE ALL LISTENERS
  // =====================================================

  void clearListeners() {
    _socket?.clearListeners();
  }

  // =====================================================
  // DISCONNECT
  // =====================================================

  void disconnect() {
    _isConnected = false;

    _socket?.disconnect();

    _socket?.dispose();

    _socket = null;
  }
}