import express from "express";

import {
  createService,
  deleteService,
  getMyServices,
  getNearbyServices,
  getServiceById,
  getServices,
  searchServices,
  updateService,
  updateServiceStatus,
} from "../controllers/serviceController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =====================================================
// PUBLIC SERVICE ROUTES
// IMPORTANT:
// All specific/static routes must appear before "/:id".
// =====================================================

// =====================================================
// SEARCH SERVICES
// GET /api/services/search
//
// Query examples:
// /api/services/search?keyword=photography
// /api/services/search?category=photographer
// /api/services/search?lat=17.385&lng=78.4867
// =====================================================

router.get(
  "/search",
  searchServices
);

// =====================================================
// NEARBY SERVICES
// GET /api/services/nearby
//
// Query example:
// /api/services/nearby?lat=17.385&lng=78.4867&radius=30000
// =====================================================

router.get(
  "/nearby",
  getNearbyServices
);

// =====================================================
// PROVIDER'S OWN SERVICES
// GET /api/services/my-services
//
// Authentication: required
// Role: provider
// =====================================================

router.get(
  "/my-services",
  protect,
  authorizeRoles("provider"),
  getMyServices
);

// =====================================================
// BACKWARD-COMPATIBLE MY SERVICES ROUTE
// GET /api/services/my
//
// Keep temporarily if the Provider Flutter app currently
// calls "/services/my".
// =====================================================

router.get(
  "/my",
  protect,
  authorizeRoles("provider"),
  getMyServices
);

// =====================================================
// GET ALL CUSTOMER-VISIBLE SERVICES
// GET /api/services
//
// Public endpoint used by the Customer application.
// Returns active, available and approved services.
// =====================================================

router.get(
  "/",
  getServices
);

// =====================================================
// CREATE SERVICE
// POST /api/services
//
// Authentication: required
// Role: provider
//
// The backend obtains the provider ID from req.user.
// The Flutter app should not manually supply provider ID.
// =====================================================

router.post(
  "/",
  protect,
  authorizeRoles("provider"),
  createService
);

// =====================================================
// SERVICE STATUS ROUTES
// These must remain before "/:id" routes where practical.
// =====================================================

// =====================================================
// UPDATE SERVICE STATUS
// PATCH /api/services/:id/status
//
// Supported request body:
// {
//   "isActive": true,
//   "isAvailable": true
// }
// =====================================================

router.patch(
  "/:id/status",
  protect,
  authorizeRoles("provider"),
  updateServiceStatus
);

// =====================================================
// AVAILABILITY COMPATIBILITY ROUTES
//
// Existing Flutter code may call:
// PUT   /api/services/:id/availability
// PATCH /api/services/:id/availability
//
// The same controller handles isAvailable safely and
// verifies that the service belongs to the provider.
// =====================================================

router.put(
  "/:id/availability",
  protect,
  authorizeRoles("provider"),
  updateServiceStatus
);

router.patch(
  "/:id/availability",
  protect,
  authorizeRoles("provider"),
  updateServiceStatus
);

// =====================================================
// ACTIVE STATUS COMPATIBILITY ROUTES
//
// Supported request body:
// {
//   "isActive": true
// }
// =====================================================

router.put(
  "/:id/active-status",
  protect,
  authorizeRoles("provider"),
  updateServiceStatus
);

router.patch(
  "/:id/active-status",
  protect,
  authorizeRoles("provider"),
  updateServiceStatus
);

// =====================================================
// GET SERVICE BY ID
// GET /api/services/:id
//
// Keep this after:
// /search
// /nearby
// /my
// /my-services
//
// Otherwise Express could interpret "search" or "my"
// as a MongoDB service ID.
// =====================================================

router.get(
  "/:id",
  getServiceById
);

// =====================================================
// UPDATE SERVICE
// PUT /api/services/:id
// PATCH /api/services/:id
//
// Authentication: required
// Role: provider
// Ownership is verified by updateService().
// =====================================================

router.put(
  "/:id",
  protect,
  authorizeRoles("provider"),
  updateService
);

router.patch(
  "/:id",
  protect,
  authorizeRoles("provider"),
  updateService
);

// =====================================================
// DELETE SERVICE
// DELETE /api/services/:id
//
// Authentication: required
// Role: provider
// The controller performs a soft delete.
// =====================================================

router.delete(
  "/:id",
  protect,
  authorizeRoles("provider"),
  deleteService
);

export default router;