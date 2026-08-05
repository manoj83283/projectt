import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository.instance;

  // =========================
  // STATE
  // =========================

  bool _isLoading = false;

  String? _errorMessage;

  List<NotificationModel> _notifications = [];

  List<NotificationModel> _unreadNotifications = [];

  int _unreadCount = 0;

  int _todayNotificationCount = 0;

  Map<String, dynamic> _analytics = {};

  NotificationModel? _selectedNotification;

  // =========================
  // SETTINGS STATE
  // =========================

  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  bool _inAppNotificationsEnabled = true;

  bool _bookingNotificationsEnabled = true;
  bool _orderNotificationsEnabled = true;
  bool _paymentNotificationsEnabled = true;
  bool _reviewNotificationsEnabled = true;
  bool _chatNotificationsEnabled = true;
  bool _promotionNotificationsEnabled = false;
  bool _supportNotificationsEnabled = true;
  bool _systemNotificationsEnabled = true;

  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // =========================
  // GETTERS
  // =========================

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<NotificationModel> get notifications => _notifications;

  List<NotificationModel> get unreadNotifications => _unreadNotifications;

  int get unreadCount => _unreadCount;

  int get todayNotificationCount => _todayNotificationCount;

  Map<String, dynamic> get analytics => _analytics;

  NotificationModel? get selectedNotification => _selectedNotification;

  // =========================
  // SETTINGS GETTERS
  // =========================

  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  bool get emailNotificationsEnabled => _emailNotificationsEnabled;

  bool get smsNotificationsEnabled => _smsNotificationsEnabled;

  bool get inAppNotificationsEnabled => _inAppNotificationsEnabled;

  bool get bookingNotificationsEnabled => _bookingNotificationsEnabled;

  bool get orderNotificationsEnabled => _orderNotificationsEnabled;

  bool get paymentNotificationsEnabled => _paymentNotificationsEnabled;

  bool get reviewNotificationsEnabled => _reviewNotificationsEnabled;

  bool get chatNotificationsEnabled => _chatNotificationsEnabled;

  bool get promotionNotificationsEnabled => _promotionNotificationsEnabled;

  bool get supportNotificationsEnabled => _supportNotificationsEnabled;

  bool get systemNotificationsEnabled => _systemNotificationsEnabled;

  bool get soundEnabled => _soundEnabled;

  bool get vibrationEnabled => _vibrationEnabled;

  bool get hasUnreadNotifications => _unreadCount > 0;

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

  void _setError(Object e) {
    _errorMessage = e.toString();
    notifyListeners();
  }

  // =========================
  // LOAD SETTINGS
  // =========================

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _pushNotificationsEnabled =
          prefs.getBool('pushNotificationsEnabled') ?? true;

      _emailNotificationsEnabled =
          prefs.getBool('emailNotificationsEnabled') ?? true;

      _smsNotificationsEnabled =
          prefs.getBool('smsNotificationsEnabled') ?? false;

      _inAppNotificationsEnabled =
          prefs.getBool('inAppNotificationsEnabled') ?? true;

      _bookingNotificationsEnabled =
          prefs.getBool('bookingNotificationsEnabled') ?? true;

      _orderNotificationsEnabled =
          prefs.getBool('orderNotificationsEnabled') ?? true;

      _paymentNotificationsEnabled =
          prefs.getBool('paymentNotificationsEnabled') ?? true;

      _reviewNotificationsEnabled =
          prefs.getBool('reviewNotificationsEnabled') ?? true;

      _chatNotificationsEnabled =
          prefs.getBool('chatNotificationsEnabled') ?? true;

      _promotionNotificationsEnabled =
          prefs.getBool('promotionNotificationsEnabled') ?? false;

      _supportNotificationsEnabled =
          prefs.getBool('supportNotificationsEnabled') ?? true;

      _systemNotificationsEnabled =
          prefs.getBool('systemNotificationsEnabled') ?? true;

      _soundEnabled = prefs.getBool('soundEnabled') ?? true;

      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;

      notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // =========================
  // SAVE SETTINGS
  // =========================

  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
        'pushNotificationsEnabled',
        _pushNotificationsEnabled,
      );

      await prefs.setBool(
        'emailNotificationsEnabled',
        _emailNotificationsEnabled,
      );

      await prefs.setBool(
        'smsNotificationsEnabled',
        _smsNotificationsEnabled,
      );

      await prefs.setBool(
        'inAppNotificationsEnabled',
        _inAppNotificationsEnabled,
      );

      await prefs.setBool(
        'bookingNotificationsEnabled',
        _bookingNotificationsEnabled,
      );

      await prefs.setBool(
        'orderNotificationsEnabled',
        _orderNotificationsEnabled,
      );

      await prefs.setBool(
        'paymentNotificationsEnabled',
        _paymentNotificationsEnabled,
      );

      await prefs.setBool(
        'reviewNotificationsEnabled',
        _reviewNotificationsEnabled,
      );

      await prefs.setBool(
        'chatNotificationsEnabled',
        _chatNotificationsEnabled,
      );

      await prefs.setBool(
        'promotionNotificationsEnabled',
        _promotionNotificationsEnabled,
      );

      await prefs.setBool(
        'supportNotificationsEnabled',
        _supportNotificationsEnabled,
      );

      await prefs.setBool(
        'systemNotificationsEnabled',
        _systemNotificationsEnabled,
      );

      await prefs.setBool(
        'soundEnabled',
        _soundEnabled,
      );

      await prefs.setBool(
        'vibrationEnabled',
        _vibrationEnabled,
      );

      notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // =========================
  // SETTINGS UPDATE METHODS
  // =========================

  Future<void> updatePushNotifications(bool value) async {
    _pushNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateEmailNotifications(bool value) async {
    _emailNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateSmsNotifications(bool value) async {
    _smsNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateInAppNotifications(bool value) async {
    _inAppNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateBookingNotifications(bool value) async {
    _bookingNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateOrderNotifications(bool value) async {
    _orderNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updatePaymentNotifications(bool value) async {
    _paymentNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateReviewNotifications(bool value) async {
    _reviewNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateChatNotifications(bool value) async {
    _chatNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updatePromotionNotifications(bool value) async {
    _promotionNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateSupportNotifications(bool value) async {
    _supportNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateSystemNotifications(bool value) async {
    _systemNotificationsEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateSound(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  Future<void> updateVibration(bool value) async {
    _vibrationEnabled = value;
    notifyListeners();
    await saveSettings();
  }

  // =========================
  // GENERIC SETTINGS UPDATE
  // =========================

  Future<void> updateSetting(
    String key,
    bool value,
  ) async {
    switch (key) {
      case 'push':
      case 'pushNotificationsEnabled':
        await updatePushNotifications(value);
        break;

      case 'email':
      case 'emailNotificationsEnabled':
        await updateEmailNotifications(value);
        break;

      case 'sms':
      case 'smsNotificationsEnabled':
        await updateSmsNotifications(value);
        break;

      case 'inApp':
      case 'inAppNotificationsEnabled':
        await updateInAppNotifications(value);
        break;

      case 'booking':
      case 'bookingNotificationsEnabled':
        await updateBookingNotifications(value);
        break;

      case 'order':
      case 'orderNotificationsEnabled':
        await updateOrderNotifications(value);
        break;

      case 'payment':
      case 'paymentNotificationsEnabled':
        await updatePaymentNotifications(value);
        break;

      case 'review':
      case 'reviewNotificationsEnabled':
        await updateReviewNotifications(value);
        break;

      case 'chat':
      case 'chatNotificationsEnabled':
        await updateChatNotifications(value);
        break;

      case 'promotion':
      case 'promotionNotificationsEnabled':
        await updatePromotionNotifications(value);
        break;

      case 'support':
      case 'supportNotificationsEnabled':
        await updateSupportNotifications(value);
        break;

      case 'system':
      case 'systemNotificationsEnabled':
        await updateSystemNotifications(value);
        break;

      case 'sound':
      case 'soundEnabled':
        await updateSound(value);
        break;

      case 'vibration':
      case 'vibrationEnabled':
        await updateVibration(value);
        break;

      default:
        break;
    }
  }

  // =========================
  // GET ALL NOTIFICATIONS
  // =========================

  Future<void> getNotifications() async {
    try {
      _setLoading(true);

      _notifications = await _repository.getNotifications();

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // GET NOTIFICATION
  // =========================

  Future<NotificationModel?> getNotificationById(
    String notificationId,
  ) async {
    try {
      _setLoading(true);

      _selectedNotification = await _repository.getNotificationById(
        notificationId,
      );

      notifyListeners();

      return _selectedNotification;
    } catch (e) {
      _setError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // PAGINATION
  // =========================

  Future<List<NotificationModel>> getPaginatedNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return await _repository.getPaginatedNotifications(
        page: page,
        limit: limit,
      );
    } catch (e) {
      _setError(e);
      return [];
    }
  }

  // =========================
  // GET UNREAD
  // =========================

  Future<void> getUnreadNotifications() async {
    try {
      _unreadNotifications = await _repository.getUnreadNotifications();

      notifyListeners();
    } catch (e) {
      _setError(e);
    }
  }

  // =========================
  // MARK AS READ
  // =========================

  Future<bool> markAsRead(
    String notificationId,
  ) async {
    try {
      final success = await _repository.markAsRead(
        notificationId,
      );

      if (success) {
        _notifications = _notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }

          return notification;
        }).toList();

        _unreadNotifications.removeWhere(
          (notification) => notification.id == notificationId,
        );

        await refreshCounts();
      }

      notifyListeners();

      return success;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // =========================
  // MARK ALL AS READ
  // =========================

  Future<bool> markAllAsRead() async {
    try {
      final success = await _repository.markAllAsRead();

      if (success) {
        await refreshData();
      }

      return success;
    } catch (e) {
      _setError(e);
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
      final success = await _repository.deleteNotification(
        notificationId,
      );

      if (success) {
        _notifications.removeWhere(
          (notification) => notification.id == notificationId,
        );

        _unreadNotifications.removeWhere(
          (notification) => notification.id == notificationId,
        );

        await refreshCounts();

        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // =========================
  // DELETE ALL
  // =========================

  Future<bool> deleteAllNotifications() async {
    try {
      final success = await _repository.deleteAllNotifications();

      if (success) {
        _notifications.clear();
        _unreadNotifications.clear();
        _unreadCount = 0;
        _todayNotificationCount = 0;

        notifyListeners();
      }

      return success;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // =========================
  // GET BY TYPE
  // =========================

  Future<List<NotificationModel>> getNotificationsByType(
    String type,
  ) async {
    try {
      return await _repository.getNotificationsByType(type);
    } catch (e) {
      _setError(e);
      return [];
    }
  }

  // =========================
  // SEARCH
  // =========================

  Future<List<NotificationModel>> searchNotifications(
    String keyword,
  ) async {
    try {
      return await _repository.searchNotifications(
        keyword,
      );
    } catch (e) {
      _setError(e);
      return [];
    }
  }

  // =========================
  // UNREAD COUNT
  // =========================

  Future<void> getUnreadCount() async {
    try {
      _unreadCount = await _repository.getUnreadCount();

      notifyListeners();
    } catch (e) {
      _unreadCount = 0;
      _setError(e);
    }
  }

  // =========================
  // TODAY COUNT
  // =========================

  Future<void> getTodayNotificationCount() async {
    try {
      _todayNotificationCount =
          await _repository.getTodayNotificationCount();

      notifyListeners();
    } catch (e) {
      _todayNotificationCount = 0;
      _setError(e);
    }
  }

  // =========================
  // FCM TOKEN
  // =========================

  Future<bool> saveFcmToken(
    String token,
  ) async {
    try {
      return await _repository.saveFcmToken(token);
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> removeFcmToken(
    String token,
  ) async {
    try {
      return await _repository.removeFcmToken(token);
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // =========================
  // ANALYTICS
  // =========================

  Future<void> getNotificationAnalytics() async {
    try {
      _analytics = await _repository.getNotificationAnalytics();

      notifyListeners();
    } catch (e) {
      _setError(e);
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

    if (!notification.isRead) {
      _unreadNotifications.insert(
        0,
        notification,
      );

      _unreadCount++;
    }

    _todayNotificationCount++;

    notifyListeners();
  }

  // =========================
  // UPDATE LOCAL NOTIFICATION
  // =========================

  void updateLocalNotification(
    NotificationModel notification,
  ) {
    final index = _notifications.indexWhere(
      (item) => item.id == notification.id,
    );

    if (index != -1) {
      _notifications[index] = notification;
    }

    final unreadIndex = _unreadNotifications.indexWhere(
      (item) => item.id == notification.id,
    );

    if (notification.isRead && unreadIndex != -1) {
      _unreadNotifications.removeAt(unreadIndex);
    } else if (!notification.isRead && unreadIndex == -1) {
      _unreadNotifications.insert(0, notification);
    }

    _unreadCount = _unreadNotifications.length;

    notifyListeners();
  }

  // =========================
  // REMOVE LOCAL NOTIFICATION
  // =========================

  void removeLocalNotification(
    String notificationId,
  ) {
    _notifications.removeWhere(
      (notification) => notification.id == notificationId,
    );

    _unreadNotifications.removeWhere(
      (notification) => notification.id == notificationId,
    );

    _unreadCount = _unreadNotifications.length;

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
  // INIT
  // =========================

  Future<void> init() async {
    await Future.wait([
      loadSettings(),
      refreshData(),
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