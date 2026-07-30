import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository({
    NotificationService? notificationService,
  }) : _notificationService =
            notificationService ??
                NotificationService();

  // =====================================================
  // GET NOTIFICATIONS
  // =====================================================

  Future<Map<String, dynamic>>
      getNotifications({
    int page = 1,
    int limit = 20,
    String? search,
    String? notificationType,
    String? status,
  }) async {
    try {
      return await _notificationService
          .getNotifications(
        page: page,
        limit: limit,
        search: search,
        notificationType:
            notificationType,
        status: status,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // GET NOTIFICATION DETAILS
  // =====================================================

  Future<Map<String, dynamic>>
      getNotificationDetails(
    String notificationId,
  ) async {
    try {
      return await _notificationService
          .getNotificationDetails(
        notificationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEARCH NOTIFICATIONS
  // =====================================================

  Future<List<dynamic>>
      searchNotifications(
    String keyword,
  ) async {
    try {
      return await _notificationService
          .searchNotifications(
        keyword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEND NOTIFICATION
  // =====================================================

  Future<Map<String, dynamic>>
      sendNotification({
    required String receiverId,
    required String receiverType,
    required String title,
    required String message,
    String? imageUrl,
    String? actionType,
    String? actionId,
  }) async {
    try {
      return await _notificationService
          .sendNotification(
        receiverId: receiverId,
        receiverType: receiverType,
        title: title,
        message: message,
        imageUrl: imageUrl,
        actionType: actionType,
        actionId: actionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEND BROADCAST NOTIFICATION
  // =====================================================

  Future<Map<String, dynamic>>
      sendBroadcastNotification({
    required String title,
    required String message,
    String? imageUrl,
    String? topic,
    String? actionType,
    String? actionId,
  }) async {
    try {
      return await _notificationService
          .sendBroadcastNotification(
        title: title,
        message: message,
        imageUrl: imageUrl,
        topic: topic,
        actionType: actionType,
        actionId: actionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SEND TOPIC NOTIFICATION
  // =====================================================

  Future<Map<String, dynamic>>
      sendTopicNotification({
    required String topic,
    required String title,
    required String message,
    String? imageUrl,
  }) async {
    try {
      return await _notificationService
          .sendTopicNotification(
        topic: topic,
        title: title,
        message: message,
        imageUrl: imageUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // SCHEDULE NOTIFICATION
  // =====================================================

  Future<Map<String, dynamic>>
      scheduleNotification({
    required String title,
    required String message,
    required DateTime scheduledAt,
    String? imageUrl,
    String? topic,
  }) async {
    try {
      return await _notificationService
          .scheduleNotification(
        title: title,
        message: message,
        scheduledAt: scheduledAt,
        imageUrl: imageUrl,
        topic: topic,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CANCEL SCHEDULED NOTIFICATION
  // =====================================================

  Future<Map<String, dynamic>>
      cancelScheduledNotification(
    String notificationId,
  ) async {
    try {
      return await _notificationService
          .cancelScheduledNotification(
        notificationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // MARK AS SENT
  // =====================================================

  Future<Map<String, dynamic>>
      markAsSent(
    String notificationId,
  ) async {
    try {
      return await _notificationService
          .markAsSent(
        notificationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // NOTIFICATION ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getNotificationAnalytics() async {
    try {
      return await _notificationService
          .getNotificationAnalytics();
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELIVERY REPORT
  // =====================================================

  Future<Map<String, dynamic>>
      getDeliveryReport(
    String notificationId,
  ) async {
    try {
      return await _notificationService
          .getDeliveryReport(
        notificationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // CLICK ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getNotificationClickAnalytics(
    String notificationId,
  ) async {
    try {
      return await _notificationService
          .getNotificationClickAnalytics(
        notificationId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // =====================================================
  // DELETE NOTIFICATION
  // =====================================================

  Future<void> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _notificationService
          .deleteNotification(
        notificationId,
      );
    } catch (e) {
      rethrow;
    }
  }
}