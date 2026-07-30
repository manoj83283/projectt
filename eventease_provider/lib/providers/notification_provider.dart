import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository =
      NotificationRepository.instance;

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;

  String? _errorMessage;

  List<NotificationModel> _notifications = [];

  List<NotificationModel>
      _unreadNotifications = [];

  int _unreadCount = 0;

  int _todayNotificationCount = 0;

  Map<String, dynamic> _analytics = {};

  NotificationModel? _selectedNotification;

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<NotificationModel>
      get notifications => _notifications;

  List<NotificationModel>
      get unreadNotifications =>
          _unreadNotifications;

  int get unreadCount => _unreadCount;

  int get todayNotificationCount =>
      _todayNotificationCount;

  Map<String, dynamic> get analytics =>
      _analytics;

  NotificationModel?
      get selectedNotification =>
          _selectedNotification;

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
  // GET ALL NOTIFICATIONS
  // =========================

  Future<void> getNotifications() async {
    try {
      _setLoading(true);

      _notifications =
          await _repository
              .getNotifications();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET NOTIFICATION
  // =========================

  Future<NotificationModel?>
      getNotificationById(
    String notificationId,
  ) async {
    try {
      _setLoading(true);

      _selectedNotification =
          await _repository
              .getNotificationById(
        notificationId,
      );

      notifyListeners();

      return _selectedNotification;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // PAGINATION
  // =========================

  Future<List<NotificationModel>>
      getPaginatedNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _repository
          .getPaginatedNotifications(
        page: page,
        limit: limit,
      );
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // =========================
  // GET UNREAD
  // =========================

  Future<void>
      getUnreadNotifications() async {
    try {
      _unreadNotifications =
          await _repository
              .getUnreadNotifications();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // MARK AS READ
  // =========================

  Future<bool> markAsRead(
    String notificationId,
  ) async {
    try {
      final success =
          await _repository.markAsRead(
        notificationId,
      );

      if (success) {
        await refreshCounts();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // MARK ALL AS READ
  // =========================

  Future<bool> markAllAsRead() async {
    try {
      final success =
          await _repository
              .markAllAsRead();

      if (success) {
        await refreshData();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // DELETE NOTIFICATION
  // =========================

  Future<bool> deleteNotification(
    String notificationId,
  ) async {
    try {
      final success =
          await _repository
              .deleteNotification(
        notificationId,
      );

      if (success) {
        _notifications.removeWhere(
          (notification) =>
              notification.id ==
              notificationId,
        );

        _unreadNotifications
            .removeWhere(
          (notification) =>
              notification.id ==
              notificationId,
        );

        notifyListeners();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // DELETE ALL
  // =========================

  Future<bool>
      deleteAllNotifications() async {
    try {
      final success =
          await _repository
              .deleteAllNotifications();

      if (success) {
        _notifications.clear();
        _unreadNotifications.clear();
        _unreadCount = 0;

        notifyListeners();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // GET BY TYPE
  // =========================

  Future<List<NotificationModel>>
      getNotificationsByType(
    String type,
  ) async {
    try {
      return await _repository
          .getNotificationsByType(type);
    } catch (e) {
      _errorMessage = e.toString();
      return [];
    }
  }

  // =========================
  // SEARCH
  // =========================

  Future<List<NotificationModel>>
      searchNotifications(
    String keyword,
  ) async {
    try {
      return await _repository
          .searchNotifications(
        keyword,
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
  // TODAY COUNT
  // =========================

  Future<void>
      getTodayNotificationCount() async {
    try {
      _todayNotificationCount =
          await _repository
              .getTodayNotificationCount();

      notifyListeners();
    } catch (e) {
      _todayNotificationCount = 0;
    }
  }

  // =========================
  // FCM TOKEN
  // =========================

  Future<bool> saveFcmToken(
    String token,
  ) async {
    try {
      return await _repository
          .saveFcmToken(token);
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFcmToken(
    String token,
  ) async {
    try {
      return await _repository
          .removeFcmToken(token);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // ANALYTICS
  // =========================

  Future<void>
      getNotificationAnalytics() async {
    try {
      _analytics =
          await _repository
              .getNotificationAnalytics();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  // =========================
  // REALTIME ADD
  // =========================

  void addNotification(
    NotificationModel notification,
  ) {
    _notifications.insert(
      0,
      notification,
    );

    _unreadCount++;

    notifyListeners();
  }

  // =========================
  // COUNTS REFRESH
  // =========================

  Future<void> refreshCounts() async {
    await Future.wait([
      getUnreadCount(),
      getTodayNotificationCount(),
      getUnreadNotifications(),
    ]);
  }

  // =========================
  // FULL REFRESH
  // =========================

  Future<void> refreshData() async {
    await Future.wait([
      getNotifications(),
      getUnreadNotifications(),
      getUnreadCount(),
      getTodayNotificationCount(),
      getNotificationAnalytics(),
    ]);
  }

  // =========================
  // RESET
  // =========================

  void reset() {
    _notifications = [];
    _unreadNotifications = [];
    _selectedNotification = null;

    _unreadCount = 0;
    _todayNotificationCount = 0;

    _analytics = {};

    _errorMessage = null;

    notifyListeners();
  }
}