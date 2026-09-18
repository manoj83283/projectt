import express from "express";

import {
  createBooking,
  getMyBookings,
  getProviderBookings,
  getProviderTodayBookings,
  getProviderUpcomingBookings,
  getProviderBookingAnalytics,
  getBookingById,
  updateBookingStatus,
  cancelBooking,
  rateBooking,
} from "../controllers/bookingController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";

const router = express.Router();

const customerOnly = authorizeRoles(
  "user",
  "customer"
);

const providerOnly = authorizeRoles(
  "provider"
);

const providerOrAdmin = authorizeRoles(
  "provider",
  "admin"
);

const customerOrAdmin = authorizeRoles(
  "user",
  "customer",
  "admin"
);

const injectBookingStatus = (status) => {
  return (req, res, next) => {
    req.body = {
      ...(req.body || {}),
      status,
    };

    return next();
  };
};

// =====================================================
// CUSTOMER BOOKING ROUTES
// =====================================================

// POST /api/bookings
router.post(
  "/",
  protect,
  customerOnly,
  createBooking
);

// GET /api/bookings
router.get(
  "/",
  protect,
  customerOnly,
  getMyBookings
);

// GET /api/bookings/my-bookings
router.get(
  "/my-bookings",
  protect,
  customerOnly,
  getMyBookings
);

// GET /api/bookings/my
router.get(
  "/my",
  protect,
  customerOnly,
  getMyBookings
);

// GET /api/bookings/history
router.get(
  "/history",
  protect,
  customerOnly,
  getMyBookings
);

// =====================================================
// PROVIDER BOOKING ROUTES
// These routes must remain above /:id.
// =====================================================

// GET /api/bookings/provider
router.get(
  "/provider",
  protect,
  providerOnly,
  getProviderBookings
);

// GET /api/bookings/provider/bookings
router.get(
  "/provider/bookings",
  protect,
  providerOnly,
  getProviderBookings
);

// GET /api/bookings/provider/today
router.get(
  "/provider/today",
  protect,
  providerOnly,
  getProviderTodayBookings
);

// GET /api/bookings/provider/bookings/today
router.get(
  "/provider/bookings/today",
  protect,
  providerOnly,
  getProviderTodayBookings
);

// GET /api/bookings/provider/upcoming
router.get(
  "/provider/upcoming",
  protect,
  providerOnly,
  getProviderUpcomingBookings
);

// GET /api/bookings/provider/bookings/upcoming
router.get(
  "/provider/bookings/upcoming",
  protect,
  providerOnly,
  getProviderUpcomingBookings
);

// GET /api/bookings/provider/analytics
router.get(
  "/provider/analytics",
  protect,
  providerOrAdmin,
  getProviderBookingAnalytics
);

// GET /api/bookings/provider/bookings/analytics
router.get(
  "/provider/bookings/analytics",
  protect,
  providerOrAdmin,
  getProviderBookingAnalytics
);

// =====================================================
// BOOKING STATUS ROUTES
// =====================================================

// PATCH /api/bookings/:id/status
router.patch(
  "/:id/status",
  protect,
  providerOrAdmin,
  updateBookingStatus
);

// PUT /api/bookings/:id/status
router.put(
  "/:id/status",
  protect,
  providerOrAdmin,
  updateBookingStatus
);

// PATCH /api/bookings/:id/accept
router.patch(
  "/:id/accept",
  protect,
  providerOrAdmin,
  injectBookingStatus("accepted"),
  updateBookingStatus
);

// PATCH /api/bookings/:id/confirm
router.patch(
  "/:id/confirm",
  protect,
  providerOrAdmin,
  injectBookingStatus("accepted"),
  updateBookingStatus
);

// PATCH /api/bookings/:id/start
router.patch(
  "/:id/start",
  protect,
  providerOrAdmin,
  injectBookingStatus("in_progress"),
  updateBookingStatus
);

// PATCH /api/bookings/:id/complete
router.patch(
  "/:id/complete",
  protect,
  providerOrAdmin,
  injectBookingStatus("completed"),
  updateBookingStatus
);

// PATCH /api/bookings/:id/reject
router.patch(
  "/:id/reject",
  protect,
  providerOrAdmin,
  injectBookingStatus("rejected"),
  updateBookingStatus
);

// =====================================================
// CUSTOMER BOOKING ACTIONS
// =====================================================

// PATCH /api/bookings/:id/cancel
router.patch(
  "/:id/cancel",
  protect,
  customerOrAdmin,
  cancelBooking
);

// PUT /api/bookings/:id/cancel
router.put(
  "/:id/cancel",
  protect,
  customerOrAdmin,
  cancelBooking
);

// =====================================================
// BOOKING RATING ROUTES
// =====================================================

// POST /api/bookings/:id/rating
router.post(
  "/:id/rating",
  protect,
  customerOnly,
  rateBooking
);

// PUT /api/bookings/:id/rating
router.put(
  "/:id/rating",
  protect,
  customerOnly,
  rateBooking
);

// PUT /api/bookings/:id/rate
router.put(
  "/:id/rate",
  protect,
  customerOnly,
  rateBooking
);

// =====================================================
// GET SINGLE BOOKING
// Keep this route last.
// =====================================================

// GET /api/bookings/:id
router.get(
  "/:id",
  protect,
  getBookingById
);

export default router;