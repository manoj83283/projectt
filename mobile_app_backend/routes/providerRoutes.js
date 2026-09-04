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
} from "../controllers/bookingController.js";

import {
  protect,
} from "../middleware/authMiddleware.js";

import {
  providerOnly,
} from "../middleware/roleMiddleware.js";

import Booking from "../models/Booking.js";
import Service from "../models/service.js";

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

  if (
    typeof document.toObject ===
    "function"
  ) {
    return document.toObject({
      virtuals: true,
    });
  }

  return {
    ...document,
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
      "firstName lastName email phone profileImage"
    )
    .populate(
      "customer",
      "firstName lastName email phone profileImage"
    )
    .populate(
      "provider",
      [
        "firstName",
        "lastName",
        "email",
        "phone",
        "profileImage",
        "businessName",
        "shopName",
      ].join(" ")
    )
    .populate(
      "service",
      [
        "name",
        "description",
        "category",
        "categories",
        "price",
        "basePrice",
        "pricePerHour",
        "pricePerDay",
        "serviceType",
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

  return res.status(500).json({
    success: false,
    message:
      error?.message ||
      "Internal server error",
  });
};

const getProviderCompletedBookings =
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

const getProviderPendingBookings =
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
// PROVIDER REGISTRATION AND DIRECTORY
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
// SHARED CHAT ROUTES
// =====================================================
//
// Supports the existing Provider application URLs:
//
// GET  /api/provider/chat/rooms
// POST /api/provider/chat/rooms
//
// The standard shared chat endpoint may also remain mounted
// as /api/chat in server.js.
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
  async (req, res) => {
    try {
      return res.status(200).json({
        success: true,
        message:
          "Provider profile update request received",
        data: req.body,
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

router.delete(
  "/profile",
  protect,
  providerOnly,
  async (req, res) => {
    return res.status(501).json({
      success: false,
      message:
        "Provider account deletion is not implemented",
    });
  }
);

// =====================================================
// DASHBOARD
// =====================================================

router.get(
  "/dashboard",
  protect,
  providerOnly,
  async (req, res, next) => {
    try {
      if (
        typeof getProviderDashboard ===
        "function"
      ) {
        return getProviderDashboard(
          req,
          res,
          next
        );
      }

      const providerId =
        getProviderId(req);

      const [
        totalServices,
        totalBookings,
        pendingBookings,
        acceptedBookings,
        inProgressBookings,
        completedBookings,
        cancelledBookings,
        todayBookings,
      ] = await Promise.all([
        Service.countDocuments({
          provider: providerId,
          deletedAt: null,
        }),

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

          bookingDate: {
            $gte: getStartOfDay(),
            $lte: getEndOfDay(),
          },

          deletedAt: null,
        }),
      ]);

      const completed =
        await getProviderCompletedBookings(
          providerId
        );

      const totalEarnings =
        completed.reduce(
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

      const dashboard = {
        totalServices,
        totalBookings,

        // Backward-compatible Provider UI field.
        totalOrders:
          totalBookings,

        totalEarnings,
        todayBookings,
        pendingBookings,
        acceptedBookings,
        inProgressBookings,
        completedBookings,
        cancelledBookings,
      };

      return res.status(200).json({
        success: true,
        message:
          "Provider dashboard fetched successfully",
        dashboard,
        data: dashboard,
        ...dashboard,
      });
    } catch (error) {
      next(error);
    }
  }
);

// =====================================================
// SERVICES
// =====================================================
//
// Compatibility endpoints:
//
// POST /api/provider/services
// GET  /api/provider/services
//
// Standard endpoints:
//
// POST /api/services
// GET  /api/services/my-services
// =====================================================

router.post(
  "/services",
  protect,
  providerOnly,
  createService
);

router.get(
  "/services",
  protect,
  providerOnly,
  getMyServices
);

// =====================================================
// BOOKINGS
// =====================================================
//
// These routes use real MongoDB queries through the booking
// controller. They no longer return hardcoded empty arrays.
// =====================================================

router.get(
  "/bookings",
  protect,
  providerOnly,
  getProviderBookings
);

router.get(
  "/bookings/today",
  protect,
  providerOnly,
  getProviderTodayBookings
);

router.get(
  "/bookings/upcoming",
  protect,
  providerOnly,
  getProviderUpcomingBookings
);

router.get(
  "/bookings/analytics",
  protect,
  providerOnly,
  getProviderBookingAnalytics
);

// =====================================================
// ORDERS
// =====================================================
//
// Event service purchases are currently represented by Booking
// documents. The Provider UI calls them orders in some screens.
// These endpoints return the same Provider booking records using
// an `orders` response key for compatibility.
// =====================================================

router.get(
  "/orders",
  protect,
  providerOnly,
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
          }).sort({
            createdAt: -1,
          })
        );

      const orders =
        documents.map(
          serializeDocument
        );

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
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const documents =
        await populateProviderBookingQuery(
          Booking.find({
            provider: providerId,

            createdAt: {
              $gte: getStartOfDay(),
              $lte: getEndOfDay(),
            },

            isProviderDeleted: {
              $ne: true,
            },

            deletedAt: null,
          }).sort({
            createdAt: -1,
          })
        );

      const orders =
        documents.map(
          serializeDocument
        );

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
        "Get Today Orders",
        error
      );
    }
  }
);

router.get(
  "/orders/recent",
  protect,
  providerOnly,
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
        documents.map(
          serializeDocument
        );

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
        "Get Recent Orders",
        error
      );
    }
  }
);

router.get(
  "/orders/analytics",
  protect,
  providerOnly,
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
        pendingOrders,
        acceptedOrders,
        inProgressOrders,
        completedOrders,
        cancelledOrders,
        rejectedOrders,
      };

      return res.status(200).json({
        success: true,
        message:
          "Provider order analytics fetched successfully",
        ...analytics,
        analytics,
        data: analytics,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Order Analytics",
        error
      );
    }
  }
);

// =====================================================
// EARNINGS
// =====================================================

router.get(
  "/earnings",
  protect,
  providerOnly,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const completedBookings =
        await getProviderCompletedBookings(
          providerId
        );

      const pendingBookings =
        await getProviderPendingBookings(
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
        pendingBookings.reduce(
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

      const availableBalance =
        totalEarnings;

      const data = {
        totalEarnings,
        monthlyEarnings,
        weeklyEarnings,
        todayEarnings,
        pendingEarnings,
        availableBalance,
      };

      return res.status(200).json({
        success: true,
        message:
          "Provider earnings fetched successfully",
        ...data,
        transactions,
        data,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Earnings",
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

              bookingId:
                value._id?.toString(),

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
        "Get Payments",
        error
      );
    }
  }
);

router.get(
  "/payments/today",
  protect,
  providerOnly,
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
          "Today's Provider payments fetched successfully",
        ...data,
        data,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Today Payments",
        error
      );
    }
  }
);

router.get(
  "/payments/history",
  protect,
  providerOnly,
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
          (booking) => {
            const value =
              serializeDocument(
                booking
              );

            return {
              ...value,

              bookingId:
                value._id?.toString(),

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
          "Provider payment history fetched successfully",
        payments,
        data: payments,
        count: payments.length,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Payment History",
        error
      );
    }
  }
);

router.get(
  "/payments/analytics",
  protect,
  providerOnly,
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

          case "pending":
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
          "Provider payment analytics fetched successfully",
        analytics,
        data: analytics,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Payment Analytics",
        error
      );
    }
  }
);

router.get(
  "/payments/total-earnings",
  protect,
  providerOnly,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const bookings =
        await getProviderCompletedBookings(
          providerId
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
        "Get Total Earnings",
        error
      );
    }
  }
);

router.get(
  "/payments/available-balance",
  protect,
  providerOnly,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const bookings =
        await Booking.find({
          provider: providerId,
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
        "Get Available Balance",
        error
      );
    }
  }
);

router.get(
  "/payments/pending-settlement",
  protect,
  providerOnly,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const bookings =
        await getProviderPendingBookings(
          providerId
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
        "Get Pending Settlement",
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
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const bookings =
        await Booking.find({
          provider: providerId,
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
              id:
                value._id.toString(),

              bookingId:
                value._id.toString(),

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
        "Get Settlements",
        error
      );
    }
  }
);

// =====================================================
// REVIEWS
// =====================================================

router.get(
  "/reviews",
  protect,
  providerOnly,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const bookings =
        await populateProviderBookingQuery(
          Booking.find({
            provider: providerId,

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
              id:
                value._id.toString(),

              bookingId:
                value._id.toString(),

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
        "Get Reviews",
        error
      );
    }
  }
);

router.get(
  "/reviews/analytics",
  protect,
  providerOnly,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const bookings =
        await Booking.find({
          provider: providerId,

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
          "Provider review analytics fetched successfully",
        analytics,
        data: analytics,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Review Analytics",
        error
      );
    }
  }
);

router.get(
  "/reviews/average-rating",
  protect,
  providerOnly,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      if (
        !mongoose.Types.ObjectId.isValid(
          providerId
        )
      ) {
        return res.status(400).json({
          success: false,
          message:
            "Invalid provider identifier",
        });
      }

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
        "Get Average Rating",
        error
      );
    }
  }
);

router.get(
  "/reviews/count",
  protect,
  providerOnly,
  async (req, res) => {
    try {
      const providerId =
        getProviderId(req);

      const count =
        await Booking.countDocuments({
          provider: providerId,

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
        "Get Review Count",
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
      const providerId =
        getProviderId(req);

      const count =
        await Booking.countDocuments({
          provider: providerId,
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
        `Get ${rating}-Star Count`,
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
    try {
      const status =
        req.user?.kycStatus ||
        "pending";

      const normalizedStatus =
        status
          .toString()
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
        ...data,
        data,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get KYC Status",
        error
      );
    }
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
    try {
      const items =
        req.user?.portfolio ||
        req.user
          ?.portfolioImages ||
        [];

      return res.status(200).json({
        success: true,
        items,
        portfolioImages: items,
        data: items,
      });
    } catch (error) {
      return handleRouteError(
        res,
        "Get Portfolio",
        error
      );
    }
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
// AVAILABILITY / ONLINE STATUS / LOCATION
// =====================================================

router.put(
  "/availability",
  protect,
  providerOnly,
  async (req, res) => {
    return res.status(200).json({
      success: true,
      message:
        "Availability update received",
      data: req.body,
    });
  }
);

router.put(
  "/online-status",
  protect,
  providerOnly,
  async (req, res) => {
    return res.status(200).json({
      success: true,
      message:
        "Online status update received",
      data: req.body,
    });
  }
);

router.put(
  "/location",
  protect,
  providerOnly,
  async (req, res) => {
    return res.status(200).json({
      success: true,
      message:
        "Provider location update received",
      data: req.body,
    });
  }
);

export default router;