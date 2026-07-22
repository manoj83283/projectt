import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  // ==========================================
  // GET NOTIFICATIONS
  // ==========================================

  Future<List<NotificationModel>>
      getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response =
        await ApiService.instance.get(
      '/notifications',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final List notifications =
        response.data['data'] ??
            response.data['notifications'] ??
            [];

    return notifications
        .map(
          (e) =>
              NotificationModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // GET NOTIFICATION BY ID
  // ==========================================

  Future<NotificationModel>
      getNotificationById(
    String notificationId,
  ) async {
    final response =
        await ApiService.instance.get(
      '/notifications/$notificationId',
    );

    return NotificationModel.fromMap(
      response.data['data'] ??
          response.data['notification'],
    );
  }

  // ==========================================
  // MARK AS READ
  // ==========================================

  Future<bool> markAsRead(
    String notificationId,
  ) async {
    await ApiService.instance.patch(
      '/notifications/$notificationId/read',
    );

    return true;
  }

  // ==========================================
  // MARK ALL AS READ
  // ==========================================

  Future<bool> markAllAsRead() async {
    await ApiService.instance.patch(
      '/notifications/read-all',
    );

    return true;
  }

  // ==========================================
  // DELETE NOTIFICATION
  // ==========================================

  Future<bool> deleteNotification(
    String notificationId,
  ) async {
    await ApiService.instance.delete(
      '/notifications/$notificationId',
    );

    return true;
  }

  // ==========================================
  // DELETE ALL NOTIFICATIONS
  // ==========================================

  Future<bool> clearNotifications() async {
    await ApiService.instance.delete(
      '/notifications/clear',
    );

    return true;
  }

  // ==========================================
  // UNREAD COUNT
  // ==========================================

  Future<int> getUnreadCount() async {
    final response =
        await ApiService.instance.get(
      '/notifications/unread-count',
    );

    return response.data['count'] ??
        response.data['data']
            ?['count'] ??
        0;
  }

  // ==========================================
  // GET UNREAD NOTIFICATIONS
  // ==========================================

  Future<List<NotificationModel>>
      getUnreadNotifications() async {
    final response =
        await ApiService.instance.get(
      '/notifications/unread',
    );

    final List notifications =
        response.data['data'] ??
            response.data['notifications'] ??
            [];

    return notifications
        .map(
          (e) =>
              NotificationModel.fromMap(e),
        )
        .toList();
  }

  // ==========================================
  // NOTIFICATION SETTINGS
  // ==========================================

  Future<Map<String, dynamic>>
      getNotificationSettings() async {
    final response =
        await ApiService.instance.get(
      '/notifications/settings',
    );

    return response.data['data'] ??
        response.data;
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
    await ApiService.instance.patch(
      '/notifications/settings',
      data: {
        'pushNotifications':
            pushNotifications,
        'bookingUpdates':
            bookingUpdates,
        'orderUpdates':
            orderUpdates,
        'promotions': promotions,
        'chatMessages': chatMessages,
      },
    );

    return true;
  }

  // ==========================================
  // REGISTER FCM TOKEN
  // ==========================================

  Future<bool> registerFcmToken(
    String fcmToken,
  ) async {
    await ApiService.instance.post(
      '/notifications/fcm-token',
      data: {
        'fcmToken': fcmToken,
      },
    );

    return true;
  }

  // ==========================================
  // REMOVE FCM TOKEN
  // ==========================================

  Future<bool> removeFcmToken(
    String fcmToken,
  ) async {
    await ApiService.instance.delete(
      '/notifications/fcm-token',
      data: {
        'fcmToken': fcmToken,
      },
    );

    return true;
  }

  // ==========================================
  // SEND TEST NOTIFICATION
  // ==========================================

  Future<bool> sendTestNotification()
      async {
    await ApiService.instance.post(
      '/notifications/test',
    );

    return true;
  }
}