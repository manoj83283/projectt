import 'dart:developer';

import '../core/network/api_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService _instance =
      NotificationService._();

  static NotificationService get instance =>
      _instance;

  final ApiService _apiService =
      ApiService.instance;

  // =========================
  // GET ALL NOTIFICATIONS
  // =========================

  Future<List<NotificationModel>>
      getNotifications() async {
    try {
      final response = await _apiService.get(
        '/provider/notifications',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) =>
                NotificationModel.fromJson(
                  e,
                ),
          )
          .toList();
    } catch (e) {
      log('Get Notifications Error: $e');
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
      final response = await _apiService.get(
        '/provider/notifications/$notificationId',
      );

      return NotificationModel.fromJson(
        response['data'] ?? response,
      );
    } catch (e) {
      log(
        'Get Notification Error: $e',
      );
      rethrow;
    }
  }

  // =========================
  // GET PAGINATED NOTIFICATIONS
  // =========================

  Future<List<NotificationModel>>
      getPaginatedNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/provider/notifications?page=$page&limit=$limit',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) =>
                NotificationModel.fromJson(
                  e,
                ),
          )
          .toList();
    } catch (e) {
      log(
        'Get Paginated Notifications Error: $e',
      );
      return [];
    }
  }

  // =========================
  // GET UNREAD NOTIFICATIONS
  // =========================

  Future<List<NotificationModel>>
      getUnreadNotifications() async {
    try {
      final response = await _apiService.get(
        '/provider/notifications/unread',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) =>
                NotificationModel.fromJson(
                  e,
                ),
          )
          .toList();
    } catch (e) {
      log(
        'Get Unread Notifications Error: $e',
      );
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
      await _apiService.patch(
        '/provider/notifications/$notificationId/read',
      );

      return true;
    } catch (e) {
      log('Mark Read Error: $e');
      return false;
    }
  }

  // =========================
  // MARK ALL AS READ
  // =========================

  Future<bool> markAllAsRead() async {
    try {
      await _apiService.patch(
        '/provider/notifications/read-all',
      );

      return true;
    } catch (e) {
      log('Read All Error: $e');
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
      await _apiService.delete(
        '/provider/notifications/$notificationId',
      );

      return true;
    } catch (e) {
      log(
        'Delete Notification Error: $e',
      );
      return false;
    }
  }

  // =========================
  // DELETE ALL NOTIFICATIONS
  // =========================

  Future<bool>
      deleteAllNotifications() async {
    try {
      await _apiService.delete(
        '/provider/notifications',
      );

      return true;
    } catch (e) {
      log(
        'Delete All Notifications Error: $e',
      );
      return false;
    }
  }

  // =========================
  // GET NOTIFICATIONS BY TYPE
  // =========================

  Future<List<NotificationModel>>
      getNotificationsByType(
    String type,
  ) async {
    try {
      final response = await _apiService.get(
        '/provider/notifications/type/$type',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) =>
                NotificationModel.fromJson(
                  e,
                ),
          )
          .toList();
    } catch (e) {
      log(
        'Notifications By Type Error: $e',
      );
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
      final response = await _apiService.get(
        '/provider/notifications/search?keyword=$keyword',
      );

      final List<dynamic> data =
          response['data'] ?? [];

      return data
          .map(
            (e) =>
                NotificationModel.fromJson(
                  e,
                ),
          )
          .toList();
    } catch (e) {
      log(
        'Search Notifications Error: $e',
      );
      return [];
    }
  }

  // =========================
  // GET UNREAD COUNT
  // =========================

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiService.get(
        '/provider/notifications/unread-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      log(
        'Unread Count Error: $e',
      );
      return 0;
    }
  }

  // =========================
  // GET TODAY COUNT
  // =========================

  Future<int>
      getTodayNotificationCount() async {
    try {
      final response = await _apiService.get(
        '/provider/notifications/today-count',
      );

      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // SUBSCRIBE FCM TOKEN
  // =========================

  Future<bool> saveFcmToken(
    String token,
  ) async {
    try {
      await _apiService.post(
        '/provider/notifications/fcm-token',
        body: {
          'token': token,
        },
      );

      return true;
    } catch (e) {
      log(
        'Save FCM Token Error: $e',
      );
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
      await _apiService.delete(
        '/provider/notifications/fcm-token',
        body: {
          'token': token,
        },
      );

      return true;
    } catch (e) {
      log(
        'Remove FCM Token Error: $e',
      );
      return false;
    }
  }

  // =========================
  // NOTIFICATION ANALYTICS
  // =========================

  Future<Map<String, dynamic>>
      getNotificationAnalytics() async {
    try {
      return await _apiService.get(
        '/provider/notifications/analytics',
      );
    } catch (e) {
      log(
        'Notification Analytics Error: $e',
      );
      rethrow;
    }
  }
}