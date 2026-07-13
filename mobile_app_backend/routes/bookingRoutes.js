import express from "express";
import Booking from "../models/Booking.js"; // ✅ REQUIRED

import {
  createBooking,
  getMyBookings,
  getProviderBookings,
  updateBookingStatus,
  cancelBooking,
  rateBooking, // ✅ make sure exists OR remove below route
} from "../controllers/bookingController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =======================================================
// ✅ CREATE BOOKING (CUSTOMER)
// =======================================================
router.post(
  "/",
  protect,
  authorizeRoles("user", "provider"),
  createBooking
);

// =======================================================
// ✅ GET CUSTOMER BOOKINGS
// =======================================================
router.get(
  "/",
  protect,
  getMyBookings
);

// =======================================================
// ✅ GET PROVIDER BOOKINGS
// =======================================================
router.get(
  "/provider",
  protect,
  authorizeRoles("provider"),
  getProviderBookings
);

// =======================================================
// ✅ UPDATE STATUS (PROVIDER)
// =======================================================
router.put(
  "/:id/status",
  protect,
  authorizeRoles("provider"),
  updateBookingStatus
);

// =======================================================
// ✅ CANCEL BOOKING (USER)
// =======================================================
router.put(
  "/:id/cancel",
  protect,
  cancelBooking
);

// =======================================================
// ✅ RATE BOOKING (MAKE SURE FUNCTION EXISTS)
// =======================================================
router.put(
  "/:id/rate",
  protect,
  rateBooking // ⚠️ REMOVE if not implemented in controller
);

// =======================================================
// ✅ GET SINGLE BOOKING
// =======================================================
router.get(
  "/:id",
  protect,
  async (req, res) => {
    try {
      const booking = await Booking.findById(req.params.id)
        .populate("user", "firstName lastName email")
        .populate("service")
        .populate("provider", "firstName lastName email");

      if (!booking) {
        return res.status(404).json({
          message: "Booking not found",
        });
      }

      res.json(booking);

    } catch (err) {
      res.status(500).json({
        message: err.message,
      });
    }
  }
);

export default router;