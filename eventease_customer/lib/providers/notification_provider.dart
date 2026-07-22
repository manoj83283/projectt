import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider
    extends ChangeNotifier {
  NotificationProvider();

  final NotificationRepository _repository =
      NotificationRepository.instance;

  List<NotificationModel> _notifications = [];
  List<NotificationModel>
      _unreadNotifications = [];

  NotificationModel? _selectedNotification;

  bool _isLoading = false;
  String? _error;

  int _unreadCount = 0;

  // ==========================================
  // GETTERS
  // ==========================================

  List<NotificationModel>
      get notifications => _notifications;

  List<NotificationModel>
      get unreadNotifications =>
          _unreadNotifications;

  NotificationModel?
      get selectedNotification =>
          _selectedNotification;

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
  // GET NOTIFICATIONS
  // ==========================================

  Future<void> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _notifications =
          await _repository.getNotifications(
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
  // GET UNREAD NOTIFICATIONS
  // ==========================================

  Future<void>
      getUnreadNotifications() async {
    try {
      _setLoading(true);
      _setError(null);

      _unreadNotifications =
          await _repository
              .getUnreadNotifications();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // GET NOTIFICATION BY ID
  // ==========================================

  Future<void> getNotificationById(
    String notificationId,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      _selectedNotification =
          await _repository
              .getNotificationById(
        notificationId,
      );

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // MARK AS READ
  // ==========================================

  Future<bool> markAsRead(
    String notificationId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository.markAsRead(
        notificationId,
      );

      if (success) {
        final index =
            _notifications.indexWhere(
          (e) =>
              e.id ==
              notificationId,
        );

        if (index != -1) {
          _notifications[index] =
              _notifications[index]
                  .copyWith(
            isRead: true,
          );
        }

        await getUnreadCount();
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
  // MARK ALL AS READ
  // ==========================================

  Future<bool> markAllAsRead() async {
    try {
      _setLoading(true);

      final success =
          await _repository.markAllAsRead();

      if (success) {
        _unreadCount = 0;

        _notifications =
            _notifications
                .map(
                  (e) => e.copyWith(
                    isRead: true,
                  ),
                )
                .toList();

        _unreadNotifications.clear();
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
  // DELETE NOTIFICATION
  // ==========================================

  Future<bool> deleteNotification(
    String notificationId,
  ) async {
    try {
      _setLoading(true);

      final success =
          await _repository
              .deleteNotification(
        notificationId,
      );

      if (success) {
        _notifications.removeWhere(
          (e) =>
              e.id ==
              notificationId,
        );

        _unreadNotifications
            .removeWhere(
          (e) =>
              e.id ==
              notificationId,
        );
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
  // CLEAR NOTIFICATIONS
  // ==========================================

  Future<bool>
      clearNotifications() async {
    try {
      _setLoading(true);

      final success =
          await _repository
              .clearNotifications();

      if (success) {
        _notifications.clear();
        _unreadNotifications.clear();

        _selectedNotification =
            null;

        _unreadCount = 0;
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
  // GET UNREAD COUNT
  // ==========================================

  Future<void> getUnreadCount() async {
    try {
      _unreadCount =
          await _repository
              .getUnreadCount();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ==========================================
  // GET SETTINGS
  // ==========================================

  Future<Map<String, dynamic>>
      getNotificationSettings() async {
    try {
      return await _repository
          .getNotificationSettings();
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // ==========================================
  // UPDATE SETTINGS
  // ==========================================

  Future<bool> updateSettings({
    required bool pushNotifications,
    required bool bookingUpdates,
    required bool orderUpdates,
    required bool promotions,
    required bool chatMessages,
  }) async {
    try {
      _setLoading(true);

      return await _repository
          .updateSettings(
        pushNotifications:
            pushNotifications,
        bookingUpdates:
            bookingUpdates,
        orderUpdates:
            orderUpdates,
        promotions: promotions,
        chatMessages:
            chatMessages,
      );
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // REGISTER FCM TOKEN
  // ==========================================

  Future<bool> registerFcmToken(
    String token,
  ) async {
    try {
      return await _repository
          .registerFcmToken(token);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // REMOVE FCM TOKEN
  // ==========================================

  Future<bool> removeFcmToken(
    String token,
  ) async {
    try {
      return await _repository
          .removeFcmToken(token);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // SEND TEST NOTIFICATION
  // ==========================================

  Future<bool>
      sendTestNotification() async {
    try {
      return await _repository
          .sendTestNotification();
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ==========================================
  // SELECT NOTIFICATION
  // ==========================================

  void setSelectedNotification(
    NotificationModel notification,
  ) {
    _selectedNotification =
        notification;

    notifyListeners();
  }

  // ==========================================
  // CLEAR SELECTED NOTIFICATION
  // ==========================================

  void clearSelectedNotification() {
    _selectedNotification = null;

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
    _notifications.clear();
    _unreadNotifications.clear();

    _selectedNotification = null;

    _error = null;
    _unreadCount = 0;

    notifyListeners();
  }
}