import express from "express";
import mongoose from "mongoose";

import {
  createProvider,
  getProviderDashboard,
  getProviders,
} from "../controllers/providerController.js";

import {
  createService,
  getMyServices,
} from "../controllers/serviceController.js";

import {
  getProviderBookings,
  getProviderTodayBookings,
  getProviderUpcomingBookings,
  getProviderBookingAnalytics,
  getBookingById,
  updateBookingStatus,
} from "../controllers/bookingController.js";

import {
  protect,
} from "../middleware/authMiddleware.js";

import {
  providerOnly,
} from "../middleware/roleMiddleware.js";

import Booking from "../models/Booking.js";
import Service from "../models/service.js";
import Notification from "../models/Notification.js";

import chatRoutes from "./chatRoutes.js";

const router = express.Router();

// =====================================================
// HELPERS
// =====================================================

const getProviderId = (req) => {
  return (
    req.user?._id?.toString() ||
    req.user?.id?.toString() ||
    ""
  );
};

const isValidObjectId = (value) => {
  return mongoose.Types.ObjectId.isValid(
    value
  );
};

const getStartOfDay = (
  date = new Date()
) => {
  const result = new Date(date);

  result.setHours(
    0,
    0,
    0,
    0
  );

  return result;
};

const getEndOfDay = (
  date = new Date()
) => {
  const result = new Date(date);

  result.setHours(
    23,
    59,
    59,
    999
  );

  return result;
};

const getStartOfWeek = () => {
  const date = new Date();

  const day = date.getDay();

  const difference =
    date.getDate() -
    day +
    (day === 0 ? -6 : 1);

  date.setDate(difference);

  date.setHours(
    0,
    0,
    0,
    0
  );

  return date;
};

const getStartOfMonth = () => {
  const date = new Date();

  return new Date(
    date.getFullYear(),
    date.getMonth(),
    1
  );
};

const serializeDocument = (
  document
) => {
  if (!document) {
    return null;
  }

  const value =
    typeof document.toObject ===
    "function"
      ? document.toObject({
          virtuals: true,
        })
      : { ...document };

  return {
    ...value,

    id:
      value._id?.toString() ||
      value.id?.toString() ||
      "",

    bookingId:
      value._id?.toString() ||
      value.bookingId?.toString() ||
      "",

    amount: Number(
      value.totalAmount ||
        value.totalPrice ||
        value.subtotal ||
        0
    ),
  };
};

const calculateBookingAmount = (
  booking
) => {
  return Number(
    booking?.totalAmount ||
      booking?.totalPrice ||
      booking?.subtotal ||
      0
  );
};

const populateProviderBookingQuery = (
  query
) => {
  return query
    .populate(
      "user",
      [
        "firstName",
        "lastName",
        "name",
        "fullName",
        "email",
        "phone",
        "mobile",
        "profileImage",
        "role",
      ].join(" ")
    )
    .populate(
      "customer",
      [
        "firstName",
        "lastName",
        "name",
        "fullName",
        "email",
        "phone",
        "mobile",
        "profileImage",
        "role",
      ].join(" ")
    )
    .populate(
      "provider",
      [
        "firstName",
        "lastName",
        "name",
        "fullName",
        "email",
        "phone",
        "mobile",
        "profileImage",
        "businessName",
        "shopName",
        "role",
      ].join(" ")
    )
    .populate(
      "service",
      [
        "name",
        "title",
        "description",
        "category",
        "categories",
        "price",
        "basePrice",
        "pricePerHour",
        "pricePerDay",
        "serviceType",
        "currency",
        "location",
        "image",
        "imageUrl",
        "images",
        "providerName",
      ].join(" ")
    );
};

const handleRouteError = (
  res,
  label,
  error
) => {
  console.error(
    `Provider Route Error - ${label}:`,
    error
  );

  if (error?.name === "CastError") {
    return res.status(400).json({
      success: false,
      message: "Invalid identifier",
    });
  }

  if (
    error?.name ===
    "ValidationError"
  ) {
    const errors = Object.values(
      error.errors || {}
    ).map(
      (item) => item.message
    );

    return res.status(400).json({
      success: false,
      message:
        errors[0] ||
        "Validation failed",
      errors,
    });
  }

  return res.status(500).json({
    success: false,
    message:
      error?.message ||
      "Internal server error",
  });
};

const validateProvider = (
  req,
  res,
  next
) => {
  const providerId =
    getProviderId(req);

  if (
    !providerId ||
    !isValidObjectId(providerId)
  ) {
    return res.status(400).json({
      success: false,
      message:
        "Invalid provider identifier",
    });
  }

  next();
};

const injectBookingStatus = (
  status
) => {
  return (
    req,
    res,
    next
  ) => {
    req.body = {
      ...(req.body || {}),
      status,
    };

    next();
  };
};

const parseBoolean = (
  value,
  fallback = false
) => {
  if (
    value === undefined ||
    value === null
  ) {
    return fallback;
  }

  if (typeof value === "boolean") {
    return value;
  }

  if (typeof value === "number") {
    return value === 1;
  }

  return [
    "true",
    "1",
    "yes",
    "on",
  ].includes(
    value
      .toString()
      .trim()
      .toLowerCase()
  );
};

const getCompletedBookings =
  async (providerId) => {
    return Booking.find({
      provider: providerId,
      status: "completed",
      deletedAt: null,
    }).select(
      [
        "totalPrice",
        "totalAmount",
        "subtotal",
        "completedAt",
        "createdAt",
        "paymentStatus",
        "paidAt",
      ].join(" ")
    );
  };

const getActiveBookings =
  async (providerId) => {
    return Booking.find({
      provider: providerId,

      status: {
        $in: [
          "pending",
          "accepted",
          "in_progress",
        ],
      },

      deletedAt: null,
    }).select(
      "totalPrice totalAmount subtotal"
    );
  };

// =====================================================
// NOTIFICATION HELPERS
// =====================================================

const getNotificationRecipientFilter = (
  providerId
) => {
  const schemaPaths =
    Notification.schema?.paths || {};

  const conditions = [];

  if (schemaPaths.user) {
    conditions.push({
      user: providerId,
    });
  }

  if (schemaPaths.recipient) {
    conditions.push({
      recipient: providerId,
    });
  }

  if (schemaPaths.receiver) {
    conditions.push({
      receiver: providerId,
    });
  }

  if (conditions.length === 0) {
    return {
      _id: null,
    };
  }

  if (conditions.length === 1) {
    return conditions[0];
  }

  return {
    $or: conditions,
  };
};

const getUnreadNotificationFilter = () => {
  const schemaPaths =
    Notification.schema?.paths || {};

  const conditions = [];

  if (schemaPaths.isRead) {
    conditions.push({
      isRead: {
        $ne: true,
      },
    });
  }

  if (schemaPaths.read) {
    conditions.push({
      read: {
        $ne: true,
      },
    });
  }

  if (conditions.length === 0) {
    return {};
  }

  if (conditions.length === 1) {
    return conditions[0];
  }

  return {
    $and: conditions,
  };
};

// =====================================================
// PROVIDER REGISTRATION
// =====================================================

router.post(
  "/",
  createProvider
);

router.get(
  "/",
  getProviders
);

// =====================================================
// CHAT
// =====================================================

router.use(
  "/chat",
  protect,
  providerOnly,
  chatRoutes
);

// =====================================================
// PROFILE
// =====================================================

router.get(
  "/profile",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    return res.status(200).json({
      success: true,
      message:
        "Provider profile fetched successfully",
      user: req.user,
      provider: req.user,
      data: req.user,
    });
  }
);

router.put(
  "/profile",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const allowedFields = [
        "firstName",
        "lastName",
        "name",
        "fullName",
        "phone",
        "mobile",
        "profileImage",
        "businessName",
        "shopName",
        "notificationsEnabled",
        "locationEnabled",
      ];

      for (const field of allowedFields) {
        if (
          req.body[field] !==
          undefined
        ) {
          req.user[field] =
            req.body[field];
        }
      }

      await req.user.save();

      return res.status(200).json({
        success: true,
        message:
          "Provider profile updated successfully",
        provider: req.user,
        user: req.user,
        data: req.user,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Update Profile",
        error
      );
    }
  }
);

router.patch(
  "/profile",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const allowedFields = [
        "firstName",
        "lastName",
        "name",
        "fullName",
        "phone",
        "mobile",
        "profileImage",
        "businessName",
        "shopName",
        "notificationsEnabled",
        "locationEnabled",
      ];

      for (const field of allowedFields) {
        if (
          req.body[field] !==
          undefined
        ) {
          req.user[field] =
            req.body[field];
        }
      }

      await req.user.save();

      return res.status(200).json({
        success: true,
        message:
          "Provider profile updated successfully",
        provider: req.user,
        user: req.user,
        data: req.user,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Patch Profile",
        error
      );
    }
  }
);

// =====================================================
// NOTIFICATIONS
// Static routes must remain before /notifications/:id.
// =====================================================

router.get(
  "/notifications",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const notifications =
        await Notification.find(
          getNotificationRecipientFilter(
            providerId
          )
        )
          .sort({
            createdAt: -1,
          })
          .limit(100);

      return res.status(200).json({
        success: true,
        message:
          "Provider notifications fetched successfully",
        notifications,
        data: notifications,
        count:
          notifications.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Notifications",
        error
      );
    }
  }
);

router.get(
  "/notifications/unread",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const notifications =
        await Notification.find({
          $and: [
            getNotificationRecipientFilter(
              providerId
            ),
            getUnreadNotificationFilter(),
          ],
        })
          .sort({
            createdAt: -1,
          })
          .limit(100);

      return res.status(200).json({
        success: true,
        message:
          "Unread notifications fetched successfully",
        notifications,
        data: notifications,
        count:
          notifications.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Unread Notifications",
        error
      );
    }
  }
);

router.get(
  "/notifications/unread-count",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const count =
        await Notification.countDocuments({
          $and: [
            getNotificationRecipientFilter(
              providerId
            ),
            getUnreadNotificationFilter(),
          ],
        });

      return res.status(200).json({
        success: true,
        count,
        unreadCount: count,
        data: {
          count,
          unreadCount: count,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Unread Notification Count",
        error
      );
    }
  }
);

router.get(
  "/notifications/today-count",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const count =
        await Notification.countDocuments({
          $and: [
            getNotificationRecipientFilter(
              providerId
            ),
            {
              createdAt: {
                $gte:
                  getStartOfDay(),
                $lte:
                  getEndOfDay(),
              },
            },
          ],
        });

      return res.status(200).json({
        success: true,
        count,
        todayCount: count,
        data: {
          count,
          todayCount: count,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Today Notification Count",
        error
      );
    }
  }
);

router.get(
  "/notifications/analytics",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const recipientFilter =
        getNotificationRecipientFilter(
          providerId
        );

      const unreadFilter =
        getUnreadNotificationFilter();

      const [
        totalNotifications,
        unreadNotifications,
        todayNotifications,
      ] = await Promise.all([
        Notification.countDocuments(
          recipientFilter
        ),

        Notification.countDocuments({
          $and: [
            recipientFilter,
            unreadFilter,
          ],
        }),

        Notification.countDocuments({
          $and: [
            recipientFilter,
            {
              createdAt: {
                $gte:
                  getStartOfDay(),
                $lte:
                  getEndOfDay(),
              },
            },
          ],
        }),
      ]);

      const analytics = {
        totalNotifications,
        unreadNotifications,

        readNotifications:
          Math.max(
            0,
            totalNotifications -
              unreadNotifications
          ),

        todayNotifications,
      };

      return res.status(200).json({
        success: true,
        message:
          "Notification analytics fetched successfully",
        analytics,
        data: analytics,
        ...analytics,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Notification Analytics",
        error
      );
    }
  }
);

// =====================================================
// DASHBOARD
// =====================================================

router.get(
  "/dashboard",
  protect,
  providerOnly,
  validateProvider,
  getProviderDashboard
);

// =====================================================
// SERVICES
// =====================================================

router.post(
  "/services",
  protect,
  providerOnly,
  validateProvider,
  createService
);

router.get(
  "/services",
  protect,
  providerOnly,
  validateProvider,
  getMyServices
);

// =====================================================
// BOOKINGS
// Static routes must remain before /bookings/:id.
// =====================================================

router.get(
  "/bookings",
  protect,
  providerOnly,
  validateProvider,
  getProviderBookings
);

router.get(
  "/bookings/today",
  protect,
  providerOnly,
  validateProvider,
  getProviderTodayBookings
);

router.get(
  "/bookings/upcoming",
  protect,
  providerOnly,
  validateProvider,
  getProviderUpcomingBookings
);

router.get(
  "/bookings/analytics",
  protect,
  providerOnly,
  validateProvider,
  getProviderBookingAnalytics
);

router.get(
  "/bookings/:id",
  protect,
  providerOnly,
  getBookingById
);

router.patch(
  "/bookings/:id/status",
  protect,
  providerOnly,
  updateBookingStatus
);

router.patch(
  "/bookings/:id/confirm",
  protect,
  providerOnly,
  injectBookingStatus("accepted"),
  updateBookingStatus
);

router.patch(
  "/bookings/:id/accept",
  protect,
  providerOnly,
  injectBookingStatus("accepted"),
  updateBookingStatus
);

router.patch(
  "/bookings/:id/start",
  protect,
  providerOnly,
  injectBookingStatus(
    "in_progress"
  ),
  updateBookingStatus
);

router.patch(
  "/bookings/:id/complete",
  protect,
  providerOnly,
  injectBookingStatus(
    "completed"
  ),
  updateBookingStatus
);

router.patch(
  "/bookings/:id/reject",
  protect,
  providerOnly,
  injectBookingStatus(
    "rejected"
  ),
  updateBookingStatus
);

router.patch(
  "/bookings/:id/cancel",
  protect,
  providerOnly,
  injectBookingStatus(
    "cancelled"
  ),
  updateBookingStatus
);

// =====================================================
// ORDERS
// Orders and bookings use the same Booking collection.
// Static routes must remain before /orders/:id.
// =====================================================

router.get(
  "/orders",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const filter = {
        provider: providerId,

        isProviderDeleted: {
          $ne: true,
        },

        deletedAt: null,
      };

      const requestedStatus =
        req.query.status
          ?.toString()
          .trim()
          .toLowerCase()
          .replaceAll("-", "_")
          .replaceAll(" ", "_");

      if (requestedStatus) {
        filter.status =
          requestedStatus;
      }

      const documents =
        await populateProviderBookingQuery(
          Booking.find(filter).sort({
            createdAt: -1,
          })
        );

      const orders =
        documents
          .map(serializeDocument)
          .filter(Boolean);

      return res.status(200).json({
        success: true,
        message:
          "Provider orders fetched successfully",
        orders,
        bookings: orders,
        data: orders,
        count: orders.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Orders",
        error
      );
    }
  }
);

router.get(
  "/orders/today",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const documents =
        await populateProviderBookingQuery(
          Booking.find({
            provider: providerId,

            bookingDate: {
              $gte:
                getStartOfDay(),
              $lte:
                getEndOfDay(),
            },

            isProviderDeleted: {
              $ne: true,
            },

            deletedAt: null,
          }).sort({
            bookingDate: 1,
            bookingTime: 1,
          })
        );

      const orders =
        documents
          .map(serializeDocument)
          .filter(Boolean);

      return res.status(200).json({
        success: true,
        message:
          "Today's Provider orders fetched successfully",
        orders,
        bookings: orders,
        data: orders,
        count: orders.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Today Orders",
        error
      );
    }
  }
);

router.get(
  "/orders/recent",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const documents =
        await populateProviderBookingQuery(
          Booking.find({
            provider: providerId,

            isProviderDeleted: {
              $ne: true,
            },

            deletedAt: null,
          })
            .sort({
              createdAt: -1,
            })
            .limit(10)
        );

      const orders =
        documents
          .map(serializeDocument)
          .filter(Boolean);

      return res.status(200).json({
        success: true,
        message:
          "Recent Provider orders fetched successfully",
        orders,
        bookings: orders,
        data: orders,
        count: orders.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Recent Orders",
        error
      );
    }
  }
);

router.get(
  "/orders/analytics",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const [
        totalOrders,
        pendingOrders,
        acceptedOrders,
        inProgressOrders,
        completedOrders,
        cancelledOrders,
        rejectedOrders,
      ] = await Promise.all([
        Booking.countDocuments({
          provider: providerId,
          deletedAt: null,
        }),

        Booking.countDocuments({
          provider: providerId,
          status: "pending",
          deletedAt: null,
        }),

        Booking.countDocuments({
          provider: providerId,
          status: "accepted",
          deletedAt: null,
        }),

        Booking.countDocuments({
          provider: providerId,
          status: "in_progress",
          deletedAt: null,
        }),

        Booking.countDocuments({
          provider: providerId,
          status: "completed",
          deletedAt: null,
        }),

        Booking.countDocuments({
          provider: providerId,
          status: "cancelled",
          deletedAt: null,
        }),

        Booking.countDocuments({
          provider: providerId,
          status: "rejected",
          deletedAt: null,
        }),
      ]);

      const analytics = {
        totalOrders,
        totalBookings:
          totalOrders,

        pendingOrders,
        pendingBookings:
          pendingOrders,

        acceptedOrders,
        acceptedBookings:
          acceptedOrders,

        inProgressOrders,
        inProgressBookings:
          inProgressOrders,

        completedOrders,
        completedBookings:
          completedOrders,

        cancelledOrders,
        cancelledBookings:
          cancelledOrders,

        rejectedOrders,
        rejectedBookings:
          rejectedOrders,
      };

      return res.status(200).json({
        success: true,
        message:
          "Provider order analytics fetched successfully",
        analytics,
        data: analytics,
        ...analytics,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Order Analytics",
        error
      );
    }
  }
);

router.get(
  "/orders/:id",
  protect,
  providerOnly,
  getBookingById
);

router.patch(
  "/orders/:id/status",
  protect,
  providerOnly,
  updateBookingStatus
);

router.patch(
  "/orders/:id/confirm",
  protect,
  providerOnly,
  injectBookingStatus("accepted"),
  updateBookingStatus
);

router.patch(
  "/orders/:id/accept",
  protect,
  providerOnly,
  injectBookingStatus("accepted"),
  updateBookingStatus
);

router.patch(
  "/orders/:id/start",
  protect,
  providerOnly,
  injectBookingStatus(
    "in_progress"
  ),
  updateBookingStatus
);

router.patch(
  "/orders/:id/complete",
  protect,
  providerOnly,
  injectBookingStatus(
    "completed"
  ),
  updateBookingStatus
);

router.patch(
  "/orders/:id/reject",
  protect,
  providerOnly,
  injectBookingStatus(
    "rejected"
  ),
  updateBookingStatus
);

router.patch(
  "/orders/:id/cancel",
  protect,
  providerOnly,
  injectBookingStatus(
    "cancelled"
  ),
  updateBookingStatus
);

// =====================================================
// EARNINGS
// =====================================================

router.get(
  "/earnings",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const completedBookings =
        await getCompletedBookings(
          providerId
        );

      const activeBookings =
        await getActiveBookings(
          providerId
        );

      const now = new Date();

      const startOfToday =
        getStartOfDay();

      const startOfWeek =
        getStartOfWeek();

      const startOfMonth =
        getStartOfMonth();

      let totalEarnings = 0;
      let monthlyEarnings = 0;
      let weeklyEarnings = 0;
      let todayEarnings = 0;

      const transactions =
        completedBookings.map(
          (booking) => {
            const amount =
              calculateBookingAmount(
                booking
              );

            const transactionDate =
              booking.completedAt ||
              booking.paidAt ||
              booking.createdAt ||
              now;

            totalEarnings += amount;

            if (
              transactionDate >=
              startOfMonth
            ) {
              monthlyEarnings +=
                amount;
            }

            if (
              transactionDate >=
              startOfWeek
            ) {
              weeklyEarnings +=
                amount;
            }

            if (
              transactionDate >=
              startOfToday
            ) {
              todayEarnings +=
                amount;
            }

            return {
              id:
                booking._id.toString(),

              bookingId:
                booking._id.toString(),

              amount,

              paymentStatus:
                booking.paymentStatus,

              date:
                transactionDate,
            };
          }
        );

      const pendingEarnings =
        activeBookings.reduce(
          (sum, booking) => {
            return (
              sum +
              calculateBookingAmount(
                booking
              )
            );
          },
          0
        );

      const data = {
        totalEarnings,
        monthlyEarnings,
        weeklyEarnings,
        todayEarnings,
        pendingEarnings,
        availableBalance:
          totalEarnings,
      };

      return res.status(200).json({
        success: true,
        message:
          "Provider earnings fetched successfully",
        transactions,
        data,
        ...data,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Earnings",
        error
      );
    }
  }
);

// =====================================================
// PAYMENTS
// =====================================================

router.get(
  "/payments",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const documents =
        await populateProviderBookingQuery(
          Booking.find({
            provider: providerId,
            deletedAt: null,
          }).sort({
            updatedAt: -1,
          })
        );

      const payments =
        documents.map(
          (booking) => {
            const value =
              serializeDocument(
                booking
              );

            return {
              ...value,

              amount:
                calculateBookingAmount(
                  value
                ),
            };
          }
        );

      return res.status(200).json({
        success: true,
        message:
          "Provider payments fetched successfully",
        payments,
        data: payments,
        count: payments.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Payments",
        error
      );
    }
  }
);

router.get(
  "/payments/today",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const paidBookings =
        await Booking.find({
          provider: providerId,
          paymentStatus: "paid",

          $or: [
            {
              paidAt: {
                $gte:
                  getStartOfDay(),
                $lte:
                  getEndOfDay(),
              },
            },
            {
              completedAt: {
                $gte:
                  getStartOfDay(),
                $lte:
                  getEndOfDay(),
              },
            },
          ],

          deletedAt: null,
        }).select(
          "totalPrice totalAmount subtotal"
        );

      const amount =
        paidBookings.reduce(
          (sum, booking) => {
            return (
              sum +
              calculateBookingAmount(
                booking
              )
            );
          },
          0
        );

      const data = {
        amount,
        todayPayments: amount,
        count: paidBookings.length,
      };

      return res.status(200).json({
        success: true,
        message:
          "Today's payments fetched successfully",
        data,
        ...data,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Today Payments",
        error
      );
    }
  }
);

router.get(
  "/payments/history",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const documents =
        await populateProviderBookingQuery(
          Booking.find({
            provider: providerId,
            paymentStatus: "paid",
            deletedAt: null,
          }).sort({
            paidAt: -1,
            completedAt: -1,
            updatedAt: -1,
          })
        );

      const payments =
        documents.map(
          serializeDocument
        );

      return res.status(200).json({
        success: true,
        message:
          "Payment history fetched successfully",
        payments,
        data: payments,
        count: payments.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Payment History",
        error
      );
    }
  }
);

router.get(
  "/payments/analytics",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const bookings =
        await Booking.find({
          provider: providerId,
          deletedAt: null,
        }).select(
          [
            "paymentStatus",
            "totalPrice",
            "totalAmount",
            "subtotal",
          ].join(" ")
        );

      const analytics = {
        totalTransactions:
          bookings.length,

        paidTransactions: 0,
        pendingTransactions: 0,
        failedTransactions: 0,
        refundedTransactions: 0,

        totalPaidAmount: 0,
        totalPendingAmount: 0,
      };

      for (const booking of bookings) {
        const amount =
          calculateBookingAmount(
            booking
          );

        switch (
          booking.paymentStatus
        ) {
          case "paid":
            analytics
              .paidTransactions += 1;

            analytics
              .totalPaidAmount +=
              amount;
            break;

          case "failed":
            analytics
              .failedTransactions += 1;
            break;

          case "refunded":
            analytics
              .refundedTransactions += 1;
            break;

          default:
            analytics
              .pendingTransactions += 1;

            analytics
              .totalPendingAmount +=
              amount;
            break;
        }
      }

      return res.status(200).json({
        success: true,
        message:
          "Payment analytics fetched successfully",
        analytics,
        data: analytics,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Payment Analytics",
        error
      );
    }
  }
);

router.get(
  "/payments/total-earnings",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const bookings =
        await getCompletedBookings(
          getProviderId(req)
        );

      const totalEarnings =
        bookings.reduce(
          (sum, booking) => {
            return (
              sum +
              calculateBookingAmount(
                booking
              )
            );
          },
          0
        );

      return res.status(200).json({
        success: true,
        totalEarnings,
        data: {
          totalEarnings,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Total Earnings",
        error
      );
    }
  }
);

router.get(
  "/payments/available-balance",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const bookings =
        await Booking.find({
          provider:
            getProviderId(req),
          status: "completed",
          paymentStatus: "paid",
          deletedAt: null,
        }).select(
          "totalPrice totalAmount subtotal"
        );

      const availableBalance =
        bookings.reduce(
          (sum, booking) => {
            return (
              sum +
              calculateBookingAmount(
                booking
              )
            );
          },
          0
        );

      return res.status(200).json({
        success: true,
        availableBalance,
        data: {
          availableBalance,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Available Balance",
        error
      );
    }
  }
);

router.get(
  "/payments/pending-settlement",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const bookings =
        await getActiveBookings(
          getProviderId(req)
        );

      const pendingSettlement =
        bookings.reduce(
          (sum, booking) => {
            return (
              sum +
              calculateBookingAmount(
                booking
              )
            );
          },
          0
        );

      return res.status(200).json({
        success: true,
        pendingSettlement,
        data: {
          pendingSettlement,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Pending Settlement",
        error
      );
    }
  }
);

// =====================================================
// SETTLEMENTS
// =====================================================

router.get(
  "/settlements",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const bookings =
        await Booking.find({
          provider:
            getProviderId(req),
          status: "completed",
          paymentStatus: "paid",
          deletedAt: null,
        }).sort({
          paidAt: -1,
          completedAt: -1,
        });

      const settlements =
        bookings.map(
          (booking) => {
            const value =
              serializeDocument(
                booking
              );

            return {
              id: value.id,

              bookingId:
                value.bookingId,

              amount:
                calculateBookingAmount(
                  value
                ),

              status: "completed",

              settledAt:
                value.paidAt ||
                value.completedAt ||
                value.updatedAt,
            };
          }
        );

      return res.status(200).json({
        success: true,
        message:
          "Provider settlements fetched successfully",
        settlements,
        data: settlements,
        count: settlements.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Settlements",
        error
      );
    }
  }
);

// =====================================================
// REVIEWS
// Static routes must remain before future /reviews/:id.
// =====================================================

router.get(
  "/reviews",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const bookings =
        await populateProviderBookingQuery(
          Booking.find({
            provider:
              getProviderId(req),

            rating: {
              $gte: 1,
              $lte: 5,
            },

            deletedAt: null,
          }).sort({
            reviewedAt: -1,
            updatedAt: -1,
          })
        );

      const reviews =
        bookings.map(
          (booking) => {
            const value =
              serializeDocument(
                booking
              );

            return {
              id: value.id,

              bookingId:
                value.bookingId,

              rating:
                value.rating,

              review:
                value.review || "",

              reviewedAt:
                value.reviewedAt,

              customer:
                value.customer ||
                value.user,

              service:
                value.service,
            };
          }
        );

      return res.status(200).json({
        success: true,
        message:
          "Provider reviews fetched successfully",
        reviews,
        data: reviews,
        count: reviews.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Reviews",
        error
      );
    }
  }
);

router.get(
  "/reviews/analytics",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const bookings =
        await Booking.find({
          provider:
            getProviderId(req),

          rating: {
            $gte: 1,
            $lte: 5,
          },

          deletedAt: null,
        }).select("rating");

      const distribution = {
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0,
      };

      let totalRating = 0;

      for (const booking of bookings) {
        const rating =
          Number(booking.rating);

        if (
          rating >= 1 &&
          rating <= 5
        ) {
          distribution[rating] += 1;
          totalRating += rating;
        }
      }

      const totalReviews =
        bookings.length;

      const averageRating =
        totalReviews === 0
          ? 0
          : totalRating /
            totalReviews;

      const analytics = {
        totalReviews,
        averageRating,
        distribution,
      };

      return res.status(200).json({
        success: true,
        message:
          "Review analytics fetched successfully",
        analytics,
        data: analytics,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Review Analytics",
        error
      );
    }
  }
);

router.get(
  "/reviews/average-rating",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const result =
        await Booking.aggregate([
          {
            $match: {
              provider:
                new mongoose.Types.ObjectId(
                  providerId
                ),

              rating: {
                $gte: 1,
                $lte: 5,
              },

              deletedAt: null,
            },
          },
          {
            $group: {
              _id: null,

              averageRating: {
                $avg: "$rating",
              },

              count: {
                $sum: 1,
              },
            },
          },
        ]);

      const averageRating =
        Number(
          result[0]?.averageRating ||
            0
        );

      const count =
        Number(
          result[0]?.count || 0
        );

      return res.status(200).json({
        success: true,
        averageRating,
        count,
        data: {
          averageRating,
          count,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Average Rating",
        error
      );
    }
  }
);

router.get(
  "/reviews/count",
  protect,
  providerOnly,
  validateProvider,
  async (req, res) => {
    try {
      const count =
        await Booking.countDocuments({
          provider:
            getProviderId(req),

          rating: {
            $gte: 1,
            $lte: 5,
          },

          deletedAt: null,
        });

      return res.status(200).json({
        success: true,
        count,
        data: {
          count,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Review Count",
        error
      );
    }
  }
);

const createRatingCountHandler = (
  rating
) => {
  return async (req, res) => {
    try {
      const count =
        await Booking.countDocuments({
          provider:
            getProviderId(req),
          rating,
          deletedAt: null,
        });

      return res.status(200).json({
        success: true,
        rating,
        count,
        data: {
          rating,
          count,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        `${rating}-Star Count`,
        error
      );
    }
  };
};

router.get(
  "/reviews/five-star-count",
  protect,
  providerOnly,
  createRatingCountHandler(5)
);

router.get(
  "/reviews/four-star-count",
  protect,
  providerOnly,
  createRatingCountHandler(4)
);

router.get(
  "/reviews/three-star-count",
  protect,
  providerOnly,
  createRatingCountHandler(3)
);

router.get(
  "/reviews/two-star-count",
  protect,
  providerOnly,
  createRatingCountHandler(2)
);

router.get(
  "/reviews/one-star-count",
  protect,
  providerOnly,
  createRatingCountHandler(1)
);

// =====================================================
// KYC
// =====================================================

router.get(
  "/kyc-status",
  protect,
  providerOnly,
  async (req, res) => {
    const normalizedStatus =
      (
        req.user?.kycStatus ||
        "pending"
      )
        .toString()
        .trim()
        .toLowerCase();

    const isVerified =
      normalizedStatus ===
        "approved" ||
      req.user?.isVerified ===
        true;

    const data = {
      status:
        normalizedStatus,
      kycStatus:
        normalizedStatus,
      isVerified,
    };

    return res.status(200).json({
      success: true,
      data,
      ...data,
    });
  }
);

// =====================================================
// PORTFOLIO
// =====================================================

router.get(
  "/portfolio",
  protect,
  providerOnly,
  async (req, res) => {
    const items =
      req.user?.portfolio ||
      req.user?.portfolioImages ||
      [];

    return res.status(200).json({
      success: true,
      items,
      portfolioImages: items,
      data: items,
    });
  }
);

router.post(
  "/portfolio",
  protect,
  providerOnly,
  async (req, res) => {
    return res.status(501).json({
      success: false,
      message:
        "Portfolio persistence is not implemented",
      data: req.body,
    });
  }
);

router.delete(
  "/portfolio",
  protect,
  providerOnly,
  async (req, res) => {
    return res.status(501).json({
      success: false,
      message:
        "Portfolio deletion is not implemented",
    });
  }
);

// =====================================================
// AVAILABILITY
// Supports PUT and PATCH.
// =====================================================

const updateProviderAvailability =
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const isAvailable =
        parseBoolean(
          req.body.isAvailable ??
            req.body.available,
          true
        );

      if (
        req.user.schema?.path(
          "isAvailable"
        )
      ) {
        req.user.isAvailable =
          isAvailable;
      }

      if (
        req.user.schema?.path(
          "isOnline"
        )
      ) {
        req.user.isOnline =
          isAvailable;
      }

      await req.user.save();

      await Service.updateMany(
        {
          provider: providerId,
          deletedAt: null,
        },
        {
          $set: {
            isAvailable,
          },
        }
      );

      if (global.io) {
        global.io.emit(
          "providerStatusChanged",
          {
            providerId,
            isAvailable,
          }
        );

        global.io.emit(
          "refreshServices",
          {
            providerId,
            isAvailable,
          }
        );
      }

      return res.status(200).json({
        success: true,
        message:
          "Provider availability updated successfully",
        isAvailable,
        available: isAvailable,
        data: {
          isAvailable,
          available: isAvailable,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Update Availability",
        error
      );
    }
  };

router.put(
  "/availability",
  protect,
  providerOnly,
  validateProvider,
  updateProviderAvailability
);

router.patch(
  "/availability",
  protect,
  providerOnly,
  validateProvider,
  updateProviderAvailability
);

// =====================================================
// ONLINE STATUS
// =====================================================

const updateProviderOnlineStatus =
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const isOnline =
        parseBoolean(
          req.body.isOnline ??
            req.body.online,
          false
        );

      if (
        req.user.schema?.path(
          "isOnline"
        )
      ) {
        req.user.isOnline =
          isOnline;

        await req.user.save();
      }

      if (global.io) {
        global.io.emit(
          "providerStatusChanged",
          {
            providerId,
            isOnline,
          }
        );
      }

      return res.status(200).json({
        success: true,
        message:
          "Provider online status updated successfully",
        isOnline,
        online: isOnline,
        data: {
          isOnline,
          online: isOnline,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Online Status",
        error
      );
    }
  };

router.put(
  "/online-status",
  protect,
  providerOnly,
  validateProvider,
  updateProviderOnlineStatus
);

router.patch(
  "/online-status",
  protect,
  providerOnly,
  validateProvider,
  updateProviderOnlineStatus
);

// =====================================================
// LOCATION
// =====================================================

const updateProviderLocation =
  async (req, res) => {
    try {
      const longitude =
        Number(
          req.body.longitude ??
            req.body.lng ??
            req.body.coordinates?.[0]
        );

      const latitude =
        Number(
          req.body.latitude ??
            req.body.lat ??
            req.body.coordinates?.[1]
        );

      if (
        !Number.isFinite(longitude) ||
        !Number.isFinite(latitude) ||
        longitude < -180 ||
        longitude > 180 ||
        latitude < -90 ||
        latitude > 90
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Valid latitude and longitude are required",
        });
      }

      const location = {
        type: "Point",
        coordinates: [
          longitude,
          latitude,
        ],
      };

      if (
        req.user.schema?.path(
          "location"
        )
      ) {
        req.user.location =
          location;
      }

      if (
        req.user.schema?.path(
          "locationEnabled"
        )
      ) {
        req.user.locationEnabled =
          true;
      }

      await req.user.save();

      return res.status(200).json({
        success: true,
        message:
          "Provider location updated successfully",
        location,
        data: {
          location,
        },
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Update Location",
        error
      );
    }
  };

router.put(
  "/location",
  protect,
  providerOnly,
  validateProvider,
  updateProviderLocation
);

router.patch(
  "/location",
  protect,
  providerOnly,
  validateProvider,
  updateProviderLocation
);

export default router;