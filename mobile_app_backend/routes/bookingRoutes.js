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

// =====================================================
// ROLE MIDDLEWARE
// =====================================================

const customerOnly = authorizeRoles(
  "user",
  "customer"
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

// =====================================================
// STATUS INJECTION MIDDLEWARE
// =====================================================

const injectBookingStatus = (status) => {
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

// =====================================================
// CUSTOMER BOOKING ROUTES
// =====================================================

// -----------------------------------------------------
// CREATE BOOKING
//
// POST /api/bookings
//
// Required:
// Authorization: Bearer CUSTOMER_TOKEN
//
// The backend obtains:
// - customer from req.user
// - provider from Service.provider
// - booking ID from MongoDB
// - booking number from the Booking model/controller
// -----------------------------------------------------

router.post(
  "/",
  protect,
  customerOnly,
  createBooking
);

// -----------------------------------------------------
// GET LOGGED-IN CUSTOMER BOOKINGS
//
// GET /api/bookings
//
// Compatibility endpoint.
// -----------------------------------------------------

router.get(
  "/",
  protect,
  customerOnly,
  getMyBookings
);

// -----------------------------------------------------
// GET LOGGED-IN CUSTOMER BOOKINGS
//
// GET /api/bookings/my-bookings
//
// Recommended Customer endpoint.
// -----------------------------------------------------

router.get(
  "/my-bookings",
  protect,
  customerOnly,
  getMyBookings
);

// -----------------------------------------------------
// GET LOGGED-IN CUSTOMER BOOKINGS
//
// GET /api/bookings/my
//
// Compatibility endpoint.
// -----------------------------------------------------

router.get(
  "/my",
  protect,
  customerOnly,
  getMyBookings
);

// -----------------------------------------------------
// GET CUSTOMER BOOKING HISTORY
//
// GET /api/bookings/history
//
// Compatibility endpoint used by BookingService.
// -----------------------------------------------------

router.get(
  "/history",
  protect,
  customerOnly,
  getMyBookings
);

// =====================================================
// PROVIDER BOOKING ROUTES
// =====================================================
//
// All Provider routes must remain above the dynamic
// "/:id" route.
//
// Otherwise Express could interpret values such as
// "provider", "today", or "analytics" as booking IDs.
// =====================================================

// -----------------------------------------------------
// GET ALL BOOKINGS FOR LOGGED-IN PROVIDER
//
// GET /api/bookings/provider
//
// Optional query parameters:
// page
// limit
// status
// -----------------------------------------------------

router.get(
  "/provider",
  protect,
  providerOrAdmin,
  getProviderBookings
);

// -----------------------------------------------------
// GET ALL BOOKINGS FOR LOGGED-IN PROVIDER
//
// GET /api/bookings/provider/bookings
//
// Compatibility endpoint.
// -----------------------------------------------------

router.get(
  "/provider/bookings",
  protect,
  providerOrAdmin,
  getProviderBookings
);

// -----------------------------------------------------
// GET TODAY'S PROVIDER BOOKINGS
//
// GET /api/bookings/provider/today
// -----------------------------------------------------

router.get(
  "/provider/today",
  protect,
  providerOrAdmin,
  getProviderTodayBookings
);

// -----------------------------------------------------
// GET TODAY'S PROVIDER BOOKINGS
//
// GET /api/bookings/provider/bookings/today
//
// Compatibility endpoint.
// -----------------------------------------------------

router.get(
  "/provider/bookings/today",
  protect,
  providerOrAdmin,
  getProviderTodayBookings
);

// -----------------------------------------------------
// GET UPCOMING PROVIDER BOOKINGS
//
// GET /api/bookings/provider/upcoming
// -----------------------------------------------------

router.get(
  "/provider/upcoming",
  protect,
  providerOrAdmin,
  getProviderUpcomingBookings
);

// -----------------------------------------------------
// GET UPCOMING PROVIDER BOOKINGS
//
// GET /api/bookings/provider/bookings/upcoming
//
// Compatibility endpoint.
// -----------------------------------------------------

router.get(
  "/provider/bookings/upcoming",
  protect,
  providerOrAdmin,
  getProviderUpcomingBookings
);

// -----------------------------------------------------
// GET PROVIDER BOOKING ANALYTICS
//
// GET /api/bookings/provider/analytics
// -----------------------------------------------------

router.get(
  "/provider/analytics",
  protect,
  providerOrAdmin,
  getProviderBookingAnalytics
);

// -----------------------------------------------------
// GET PROVIDER BOOKING ANALYTICS
//
// GET /api/bookings/provider/bookings/analytics
//
// Compatibility endpoint.
// -----------------------------------------------------

router.get(
  "/provider/bookings/analytics",
  protect,
  providerOrAdmin,
  getProviderBookingAnalytics
);

// =====================================================
// BOOKING STATUS ROUTES
// =====================================================

// -----------------------------------------------------
// UPDATE BOOKING STATUS
//
// PATCH /api/bookings/:id/status
//
// Body:
// {
//   "status": "accepted",
//   "reason": "optional",
//   "note": "optional"
// }
//
// Provider or Admin only.
// -----------------------------------------------------

router.patch(
  "/:id/status",
  protect,
  providerOrAdmin,
  updateBookingStatus
);

// -----------------------------------------------------
// UPDATE BOOKING STATUS
//
// PUT /api/bookings/:id/status
//
// Compatibility endpoint.
// -----------------------------------------------------

router.put(
  "/:id/status",
  protect,
  providerOrAdmin,
  updateBookingStatus
);

// -----------------------------------------------------
// ACCEPT BOOKING
//
// PATCH /api/bookings/:id/accept
//
// Internally maps to:
// status = accepted
// -----------------------------------------------------

router.patch(
  "/:id/accept",
  protect,
  providerOrAdmin,
  injectBookingStatus("accepted"),
  updateBookingStatus
);

// -----------------------------------------------------
// CONFIRM BOOKING
//
// PATCH /api/bookings/:id/confirm
//
// The backend uses "accepted" as the Provider-confirmed
// booking status.
// -----------------------------------------------------

router.patch(
  "/:id/confirm",
  protect,
  providerOrAdmin,
  injectBookingStatus("accepted"),
  updateBookingStatus
);

// -----------------------------------------------------
// START BOOKING
//
// PATCH /api/bookings/:id/start
//
// Internally maps to:
// status = in_progress
// -----------------------------------------------------

router.patch(
  "/:id/start",
  protect,
  providerOrAdmin,
  injectBookingStatus("in_progress"),
  updateBookingStatus
);

// -----------------------------------------------------
// COMPLETE BOOKING
//
// PATCH /api/bookings/:id/complete
//
// Internally maps to:
// status = completed
// -----------------------------------------------------

router.patch(
  "/:id/complete",
  protect,
  providerOrAdmin,
  injectBookingStatus("completed"),
  updateBookingStatus
);

// -----------------------------------------------------
// REJECT BOOKING
//
// PATCH /api/bookings/:id/reject
//
// Optional body:
// {
//   "reason": "Reason for rejection"
// }
// -----------------------------------------------------

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

// -----------------------------------------------------
// CANCEL BOOKING
//
// PATCH /api/bookings/:id/cancel
//
// Body:
// {
//   "reason": "Optional cancellation reason"
// }
//
// Customer or Admin only.
// -----------------------------------------------------

router.patch(
  "/:id/cancel",
  protect,
  customerOrAdmin,
  cancelBooking
);

// -----------------------------------------------------
// CANCEL BOOKING
//
// PUT /api/bookings/:id/cancel
//
// Compatibility endpoint.
// -----------------------------------------------------

router.put(
  "/:id/cancel",
  protect,
  customerOrAdmin,
  cancelBooking
);

// =====================================================
// BOOKING RATING ROUTES
// =====================================================

// -----------------------------------------------------
// RATE COMPLETED BOOKING
//
// POST /api/bookings/:id/rating
//
// Body:
// {
//   "rating": 5,
//   "review": "Excellent service"
// }
// -----------------------------------------------------

router.post(
  "/:id/rating",
  protect,
  customerOnly,
  rateBooking
);

// -----------------------------------------------------
// RATE COMPLETED BOOKING
//
// PUT /api/bookings/:id/rating
//
// Compatibility endpoint.
// -----------------------------------------------------

router.put(
  "/:id/rating",
  protect,
  customerOnly,
  rateBooking
);

// -----------------------------------------------------
// RATE COMPLETED BOOKING
//
// PUT /api/bookings/:id/rate
//
// Older Flutter compatibility endpoint.
// -----------------------------------------------------

router.put(
  "/:id/rate",
  protect,
  customerOnly,
  rateBooking
);

// =====================================================
// GET SINGLE BOOKING
// =====================================================
//
// This route must always remain last because "/:id" is
// a dynamic route.
//
// The controller verifies whether the authenticated user
// is:
//
// - the booking Customer;
// - the booking Provider; or
// - an Admin.
// =====================================================

router.get(
  "/:id",
  protect,
  getBookingById
);

export default router;