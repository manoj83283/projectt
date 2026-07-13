import express from "express";
import Service from "../models/service.js";

import {
  createService,
  getServices,
  getMyServices,
  getNearbyServices,
  updateService,
  deleteService,
  searchServices,
  getServiceById, // ✅ ADDED
} from "../controllers/serviceController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =====================================================
// ✅ CREATE SERVICE (PROVIDER ONLY)
// =====================================================
router.post(
  "/",
  protect,
  authorizeRoles("provider"),
  createService
);

// =====================================================
// ✅ SEARCH / LOCATION ROUTES
// IMPORTANT: MUST BE ABOVE "/:id"
// =====================================================
router.get("/search", searchServices);
router.get("/nearby", getNearbyServices);

// =====================================================
// ✅ GET ALL SERVICES
// =====================================================
router.get("/", getServices);

// =====================================================
// ✅ GET MY SERVICES (PROVIDER DASHBOARD)
// =====================================================
router.get(
  "/my",
  protect,
  authorizeRoles("provider"),
  getMyServices
);

// =====================================================
// ✅ GET SERVICE BY ID
// =====================================================
router.get("/:id", getServiceById);

// =====================================================
// ✅ UPDATE SERVICE
// =====================================================
router.put(
  "/:id",
  protect,
  authorizeRoles("provider"),
  updateService
);

// =====================================================
// ✅ DELETE SERVICE
// =====================================================
router.delete(
  "/:id",
  protect,
  authorizeRoles("provider"),
  deleteService
);

// =====================================================
// ✅ TOGGLE AVAILABILITY
// =====================================================
router.put(
  "/:id/availability",
  protect,
  authorizeRoles("provider"),
  async (req, res) => {
    try {
      const service = await Service.findByIdAndUpdate(
        req.params.id,
        {
          isAvailable: req.body.isAvailable,
        },
        {
          new: true,
        }
      );

      if (!service) {
        return res.status(404).json({
          message: "Service not found",
        });
      }

      // ✅ REAL-TIME UPDATE
      if (global.io) {
        global.io.emit("refreshServices");
      }

      res.json({
        message: "Availability updated",
        service,
      });
    } catch (err) {
      res.status(500).json({
        message: err.message,
      });
    }
  }
);

export default router;