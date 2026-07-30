import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  NotificationRepository._();

  static final NotificationRepository
      _instance = NotificationRepository._();

  static NotificationRepository get instance =>
      _instance;

  final NotificationService
      _notificationService =
      NotificationService.instance;

  // =========================
  // GET ALL NOTIFICATIONS
  // =========================

  Future<List<NotificationModel>>
      getNotifications() async {
    try {
      return await _notificationService
          .getNotifications();
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET NOTIFICATION BY ID
  // =========================

  Future<NotificationModel>
      getNotificationById(
    String notificationId,
  ) async {
    try {
      return await _notificationService
          .getNotificationById(
        notificationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =========================
  // GET PAGINATED
  // =========================

  Future<List<NotificationModel>>
      getPaginatedNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _notificationService
          .getPaginatedNotifications(
        page: page,
        limit: limit,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET UNREAD
  // =========================

  Future<List<NotificationModel>>
      getUnreadNotifications() async {
    try {
      return await _notificationService
          .getUnreadNotifications();
    } catch (e) {
      return [];
    }
  }

  // =========================
  // MARK AS READ
  // =========================

  Future<bool> markAsRead(
    String notificationId,
  ) async {
    try {
      return await _notificationService
          .markAsRead(notificationId);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // MARK ALL AS READ
  // =========================

  Future<bool> markAllAsRead() async {
    try {
      return await _notificationService
          .markAllAsRead();
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
      return await _notificationService
          .deleteNotification(
        notificationId,
      );
    } catch (e) {
      return false;
    }
  }

  // =========================
  // DELETE ALL NOTIFICATIONS
  // =========================

  Future<bool>
      deleteAllNotifications() async {
    try {
      return await _notificationService
          .deleteAllNotifications();
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
      return await _notificationService
          .getNotificationsByType(
        type,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // SEARCH NOTIFICATIONS
  // =========================

  Future<List<NotificationModel>>
      searchNotifications(
    String keyword,
  ) async {
    try {
      return await _notificationService
          .searchNotifications(
        keyword,
      );
    } catch (e) {
      return [];
    }
  }

  // =========================
  // UNREAD COUNT
  // =========================

  Future<int> getUnreadCount() async {
    try {
      return await _notificationService
          .getUnreadCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // TODAY COUNT
  // =========================

  Future<int>
      getTodayNotificationCount() async {
    try {
      return await _notificationService
          .getTodayNotificationCount();
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // SAVE FCM TOKEN
  // =========================

  Future<bool> saveFcmToken(
    String token,
  ) async {
    try {
      return await _notificationService
          .saveFcmToken(token);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // REMOVE FCM TOKEN
  // =========================

  Future<bool> removeFcmToken(
    String token,
  ) async {
    try {
      return await _notificationService
          .removeFcmToken(token);
    } catch (e) {
      return false;
    }
  }

  // =========================
  // ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getNotificationAnalytics() async {
    try {
      return await _notificationService
          .getNotificationAnalytics();
    } catch (e) {
      rethrow;
    }
  }
}