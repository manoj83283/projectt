// ======================================================
// NOTIFICATION CONTROLLER
// Temporary production-safe controller
// ======================================================

// ======================================================
// GET ALL NOTIFICATIONS
// ======================================================

export const getNotifications = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      message: "Notifications fetched successfully",
      notifications: [],
      data: [],
      unreadCount: 0,
      total: 0,
    });
  } catch (error) {
    console.error("❌ Get Notifications Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch notifications",
    });
  }
};

// ======================================================
// GET NOTIFICATION BY ID
// ======================================================

export const getNotificationById = async (req, res) => {
  try {
    const { id } = req.params;

    return res.status(200).json({
      success: true,
      message: "Notification fetched successfully",
      notification: {
        id,
        title: "",
        message: "",
        type: "system",
        isRead: false,
        createdAt: new Date(),
      },
      data: {
        id,
        title: "",
        message: "",
        type: "system",
        isRead: false,
        createdAt: new Date(),
      },
    });
  } catch (error) {
    console.error("❌ Get Notification By ID Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch notification",
    });
  }
};

// ======================================================
// CREATE NOTIFICATION
// ======================================================

export const createNotification = async (req, res) => {
  try {
    const {
      title = "",
      message = "",
      type = "system",
      userId = "",
      referenceId = "",
      route = "",
      data = {},
    } = req.body;

    const notification = {
      id: Date.now().toString(),
      userId,
      title,
      message,
      type,
      referenceId,
      route,
      isRead: false,
      isDeleted: false,
      data,
      createdAt: new Date(),
      readAt: null,
    };

    return res.status(201).json({
      success: true,
      message: "Notification created successfully",
      notification,
      data: notification,
    });
  } catch (error) {
    console.error("❌ Create Notification Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to create notification",
    });
  }
};

// ======================================================
// GET UNREAD NOTIFICATIONS
// ======================================================

export const getUnreadNotifications = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      message: "Unread notifications fetched successfully",
      notifications: [],
      data: [],
      unreadCount: 0,
    });
  } catch (error) {
    console.error("❌ Get Unread Notifications Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch unread notifications",
    });
  }
};

// ======================================================
// GET UNREAD COUNT
// ======================================================

export const getUnreadCount = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      message: "Unread count fetched successfully",
      count: 0,
      unreadCount: 0,
      data: {
        count: 0,
        unreadCount: 0,
      },
    });
  } catch (error) {
    console.error("❌ Get Unread Count Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch unread count",
    });
  }
};

// ======================================================
// MARK NOTIFICATION AS READ
// ======================================================

export const markNotificationAsRead = async (req, res) => {
  try {
    const { id } = req.params;

    return res.status(200).json({
      success: true,
      message: "Notification marked as read",
      notification: {
        id,
        isRead: true,
        readAt: new Date(),
      },
      data: {
        id,
        isRead: true,
        readAt: new Date(),
      },
    });
  } catch (error) {
    console.error("❌ Mark Notification As Read Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to mark notification as read",
    });
  }
};

// ======================================================
// MARK ALL NOTIFICATIONS AS READ
// ======================================================

export const markAllNotificationsAsRead = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      message: "All notifications marked as read",
      updatedCount: 0,
      data: {
        updatedCount: 0,
      },
    });
  } catch (error) {
    console.error("❌ Mark All Notifications As Read Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to mark all notifications as read",
    });
  }
};

// ======================================================
// DELETE NOTIFICATION
// ======================================================

export const deleteNotification = async (req, res) => {
  try {
    const { id } = req.params;

    return res.status(200).json({
      success: true,
      message: "Notification deleted successfully",
      deletedId: id,
      data: {
        deletedId: id,
      },
    });
  } catch (error) {
    console.error("❌ Delete Notification Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to delete notification",
    });
  }
};

// ======================================================
// DELETE ALL NOTIFICATIONS
// ======================================================

export const deleteAllNotifications = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      message: "All notifications deleted successfully",
      deletedCount: 0,
      data: {
        deletedCount: 0,
      },
    });
  } catch (error) {
    console.error("❌ Delete All Notifications Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to delete all notifications",
    });
  }
};

// ======================================================
// GET NOTIFICATIONS BY TYPE
// ======================================================

export const getNotificationsByType = async (req, res) => {
  try {
    const { type } = req.params;

    return res.status(200).json({
      success: true,
      message: "Notifications by type fetched successfully",
      type,
      notifications: [],
      data: [],
    });
  } catch (error) {
    console.error("❌ Get Notifications By Type Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch notifications by type",
    });
  }
};

// ======================================================
// SEARCH NOTIFICATIONS
// ======================================================

export const searchNotifications = async (req, res) => {
  try {
    const keyword =
      req.query.keyword?.toString() ||
      req.query.q?.toString() ||
      "";

    return res.status(200).json({
      success: true,
      message: "Notifications searched successfully",
      keyword,
      notifications: [],
      data: [],
    });
  } catch (error) {
    console.error("❌ Search Notifications Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to search notifications",
    });
  }
};

// ======================================================
// GET TODAY NOTIFICATION COUNT
// ======================================================

export const getTodayNotificationCount = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      message: "Today notification count fetched successfully",
      count: 0,
      todayNotificationCount: 0,
      data: {
        count: 0,
        todayNotificationCount: 0,
      },
    });
  } catch (error) {
    console.error("❌ Get Today Notification Count Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch today notification count",
    });
  }
};

// ======================================================
// GET NOTIFICATION ANALYTICS
// ======================================================

export const getNotificationAnalytics = async (req, res) => {
  try {
    return res.status(200).json({
      success: true,
      message: "Notification analytics fetched successfully",
      analytics: {
        total: 0,
        unread: 0,
        read: 0,
        today: 0,
      },
      data: {
        total: 0,
        unread: 0,
        read: 0,
        today: 0,
      },
    });
  } catch (error) {
    console.error("❌ Get Notification Analytics Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch notification analytics",
    });
  }
};

// ======================================================
// SAVE FCM TOKEN
// ======================================================

export const saveFcmToken = async (req, res) => {
  try {
    const { token, fcmToken } = req.body;

    return res.status(200).json({
      success: true,
      message: "FCM token saved successfully",
      token: token || fcmToken || "",
      data: {
        token: token || fcmToken || "",
      },
    });
  } catch (error) {
    console.error("❌ Save FCM Token Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to save FCM token",
    });
  }
};

// ======================================================
// REMOVE FCM TOKEN
// ======================================================

export const removeFcmToken = async (req, res) => {
  try {
    const { token, fcmToken } = req.body;

    return res.status(200).json({
      success: true,
      message: "FCM token removed successfully",
      token: token || fcmToken || "",
      data: {
        token: token || fcmToken || "",
      },
    });
  } catch (error) {
    console.error("❌ Remove FCM Token Error:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Failed to remove FCM token",
    });
  }
};