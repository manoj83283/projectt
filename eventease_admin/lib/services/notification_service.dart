import 'package:dio/dio.dart';

import '../core/network/api_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService _instance =
      NotificationService._();

  factory NotificationService() => _instance;

  final ApiService _api = ApiService();

  // =====================================================
  // GET ALL NOTIFICATIONS
  // =====================================================

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  }) async {
    try {
      final response = await _api.get(
        '/admin/notifications',
        query: {
          'page': page,
          'limit': limit,
          'type': ?type,
          'status': ?status,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/notifications/$notificationId',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND TO ALL USERS
  // =====================================================

  Future<bool> sendToAllUsers({
    required String title,
    required String message,
    String? image,
  }) async {
    try {
      await _api.post(
        '/admin/notifications/all-users',
        data: {
          'title': title,
          'message': message,
          'image': image,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND TO ALL PROVIDERS
  // =====================================================

  Future<bool> sendToAllProviders({
    required String title,
    required String message,
    String? image,
  }) async {
    try {
      await _api.post(
        '/admin/notifications/all-providers',
        data: {
          'title': title,
          'message': message,
          'image': image,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND TO SPECIFIC USER
  // =====================================================

  Future<bool> sendToUser({
    required String userId,
    required String title,
    required String message,
    String? image,
  }) async {
    try {
      await _api.post(
        '/admin/notifications/user',
        data: {
          'userId': userId,
          'title': title,
          'message': message,
          'image': image,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND TO SPECIFIC PROVIDER
  // =====================================================

  Future<bool> sendToProvider({
    required String providerId,
    required String title,
    required String message,
    String? image,
  }) async {
    try {
      await _api.post(
        '/admin/notifications/provider',
        data: {
          'providerId': providerId,
          'title': title,
          'message': message,
          'image': image,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND BULK NOTIFICATIONS
  // =====================================================

  Future<bool> sendBulkNotification({
    required List<String> userIds,
    required String title,
    required String message,
  }) async {
    try {
      await _api.post(
        '/admin/notifications/bulk',
        data: {
          'userIds': userIds,
          'title': title,
          'message': message,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // SEND TOPIC NOTIFICATION
  // =====================================================

  Future<bool> sendTopicNotification({
    required String topic,
    required String title,
    required String message,
  }) async {
    try {
      await _api.post(
        '/admin/notifications/topic',
        data: {
          'topic': topic,
          'title': title,
          'message': message,
        },
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // CREATE ANNOUNCEMENT
  // =====================================================

  Future<Map<String, dynamic>>
      createAnnouncement({
    required String title,
    required String message,
    DateTime? expiryDate,
    bool isActive = true,
  }) async {
    try {
      final response = await _api.post(
        '/admin/notifications/announcements',
        data: {
          'title': title,
          'message': message,
          'expiryDate':
              expiryDate?.toIso8601String(),
          'isActive': isActive,
        },
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // GET ANNOUNCEMENTS
  // =====================================================

  Future<List<dynamic>>
      getAnnouncements() async {
    try {
      final response = await _api.get(
        '/admin/notifications/announcements',
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE ANNOUNCEMENT
  // =====================================================

  Future<bool> deleteAnnouncement(
    String announcementId,
  ) async {
    try {
      await _api.delete(
        '/admin/notifications/announcements/$announcementId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // NOTIFICATION ANALYTICS
  // =====================================================

  Future<Map<String, dynamic>>
      getNotificationAnalytics() async {
    try {
      final response = await _api.get(
        '/admin/notifications/analytics',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/notifications/$notificationId/report',
      );

      return response.data['data']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // RESEND NOTIFICATION
  // =====================================================

  Future<bool> resendNotification(
    String notificationId,
  ) async {
    try {
      await _api.post(
        '/admin/notifications/$notificationId/resend',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
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
      final response = await _api.get(
        '/admin/notifications/search',
        query: {
          'keyword': keyword,
        },
      );

      return response.data['data']
          as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // EXPORT NOTIFICATIONS
  // =====================================================

  Future<Response<dynamic>>
      exportNotifications({
    String format = 'excel',
  }) async {
    try {
      return await _api.get(
        '/admin/notifications/export',
        query: {
          'format': format,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // DELETE NOTIFICATION
  // =====================================================

  Future<bool> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _api.delete(
        '/admin/notifications/$notificationId',
      );

      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // =====================================================
  // ERROR PARSER
  // =====================================================

  String _parseError(
    DioException e,
  ) {
    return e.response?.data?['message']
            ?.toString() ??
        e.message ??
        'Something went wrong';
  }
}