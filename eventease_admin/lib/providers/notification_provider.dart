import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService =
      NotificationService();

  bool _isLoading = false;

  String? _errorMessage;

  List<NotificationModel> _notifications = [];

  NotificationModel? _selectedNotification;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalNotifications = 0;

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isLoading => _isLoading;

  String? get errorMessage =>
      _errorMessage;

  List<NotificationModel> get notifications =>
      _notifications;

  NotificationModel? get selectedNotification =>
      _selectedNotification;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  int get totalNotifications =>
      _totalNotifications;

  bool get hasNotifications =>
      _notifications.isNotEmpty;

  List<NotificationModel> get sentNotifications =>
      _notifications
          .where(
            (notification) =>
                notification.isSent,
          )
          .toList();

  List<NotificationModel>
      get pendingNotifications =>
          _notifications
              .where(
                (notification) =>
                    !notification.isSent,
              )
              .toList();

  // =====================================================
  // GET NOTIFICATIONS
  // =====================================================

  Future<void> getNotifications({
    int page = 1,
    int limit = 20,
    String? search,
    String? notificationType,
  }) async {
    try {
      _setLoading(true);
      clearError();

      final response =
          await _notificationService
              .getNotifications(
        page: page,
        limit: limit,
        search: search,
        notificationType:
            notificationType,
      );

      _notifications =
          (response['notifications']
                      as List? ??
                  [])
              .map(
                (e) =>
                    NotificationModel
                        .fromJson(e),
              )
              .toList();

      _currentPage =
          response['currentPage'] ?? 1;

      _totalPages =
          response['totalPages'] ?? 1;

      _totalNotifications =
          response['totalNotifications'] ??
              _notifications.length;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // GET NOTIFICATION DETAILS
  // =====================================================

  Future<void> getNotificationDetails(
    String notificationId,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _notificationService
              .getNotificationDetails(
        notificationId,
      );

      _selectedNotification =
          NotificationModel.fromJson(
        response,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEND BROADCAST NOTIFICATION
  // =====================================================

  Future<bool> sendBroadcastNotification({
    required String title,
    required String message,
    String? imageUrl,
    String? topic,
    String? actionType,
    String? actionId,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _notificationService
              .sendBroadcastNotification(
        title: title,
        message: message,
        imageUrl: imageUrl,
        topic: topic,
        actionType: actionType,
        actionId: actionId,
      );

      final notification =
          NotificationModel.fromJson(
        response,
      );

      _notifications.insert(
        0,
        notification,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEND SINGLE NOTIFICATION
  // =====================================================

  Future<bool> sendNotification({
    required String receiverId,
    required String receiverType,
    required String title,
    required String message,
    String? imageUrl,
    String? actionType,
    String? actionId,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _notificationService
              .sendNotification(
        receiverId: receiverId,
        receiverType: receiverType,
        title: title,
        message: message,
        imageUrl: imageUrl,
        actionType: actionType,
        actionId: actionId,
      );

      final notification =
          NotificationModel.fromJson(
        response,
      );

      _notifications.insert(
        0,
        notification,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SCHEDULE NOTIFICATION
  // =====================================================

  Future<bool> scheduleNotification({
    required String title,
    required String message,
    required DateTime scheduledAt,
    String? imageUrl,
    String? topic,
  }) async {
    try {
      _setLoading(true);

      final response =
          await _notificationService
              .scheduleNotification(
        title: title,
        message: message,
        scheduledAt: scheduledAt,
        imageUrl: imageUrl,
        topic: topic,
      );

      final notification =
          NotificationModel.fromJson(
        response,
      );

      _notifications.insert(
        0,
        notification,
      );

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // DELETE NOTIFICATION
  // =====================================================

  Future<bool> deleteNotification(
    String notificationId,
  ) async {
    try {
      _setLoading(true);

      await _notificationService
          .deleteNotification(
        notificationId,
      );

      _notifications.removeWhere(
        (e) => e.id == notificationId,
      );

      if (_selectedNotification?.id ==
          notificationId) {
        _selectedNotification = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // SEARCH NOTIFICATIONS
  // =====================================================

  Future<void> searchNotifications(
    String keyword,
  ) async {
    try {
      _setLoading(true);

      final response =
          await _notificationService
              .searchNotifications(
        keyword,
      );

      _notifications =
          (response as List)
              .map(
                (e) =>
                    NotificationModel
                        .fromJson(e),
              )
              .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =====================================================
  // REFRESH NOTIFICATIONS
  // =====================================================

  Future<void> refreshNotifications() async {
    await getNotifications(
      page: _currentPage,
    );
  }

  // =====================================================
  // CLEAR SELECTED NOTIFICATION
  // =====================================================

  void clearSelectedNotification() {
    _selectedNotification = null;
    notifyListeners();
  }

  // =====================================================
  // CLEAR ERROR
  // =====================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // =====================================================
  // SET LOADING
  // =====================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}