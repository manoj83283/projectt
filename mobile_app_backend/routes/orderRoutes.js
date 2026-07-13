import express from "express";

import {
  createOrder,
  getMyOrders,
  getProviderOrders,
  getOrderById,
  updateOrderStatus,
  acceptOrder,
  rejectOrder,
  completeOrder,
  cancelOrder,
  deleteOrder,
  getAllOrders,
  getOrderAnalytics,
} from "../controllers/orderController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =====================================================
// CUSTOMER ROUTES
// =====================================================

// Create Order
router.post(
  "/",
  protect,
  authorizeRoles("user"),
  createOrder
);

router.get(
  "/provider-orders",
  protect,
  authorizeRoles(
    "provider",
    "admin"
  ),
  getProviderOrders
);

// My Orders
router.get(
  "/my",
  protect,
  authorizeRoles("user"),
  getMyOrders
);

// Cancel Order
router.put(
  "/:id/cancel",
  protect,
  authorizeRoles("user"),
  cancelOrder
);

// =====================================================
// PROVIDER ROUTES
// =====================================================

// All Orders Assigned To Provider
router.get(
  "/provider",
  protect,
  authorizeRoles("provider"),
  getProviderOrders
);

// Accept Order
router.put(
  "/:id/accept",
  protect,
  authorizeRoles("provider"),
  acceptOrder
);

// Reject Order
router.put(
  "/:id/reject",
  protect,
  authorizeRoles("provider"),
  rejectOrder
);

// Complete Order
router.put(
  "/:id/complete",
  protect,
  authorizeRoles("provider"),
  completeOrder
);

// Generic Status Update
router.put(
  "/:id/status",
  protect,
  authorizeRoles("provider"),
  updateOrderStatus
);

// =====================================================
// COMMON ROUTE
// =====================================================

// Order Details
router.get(
  "/:id",
  protect,
  getOrderById
);

// =====================================================
// ADMIN ROUTES
// =====================================================

// All Orders
router.get(
  "/admin/all",
  protect,
  authorizeRoles("admin"),
  getAllOrders
);

// Analytics
router.get(
  "/admin/analytics",
  protect,
  authorizeRoles("admin"),
  getOrderAnalytics
);

// Delete Order
router.delete(
  "/admin/:id",
  protect,
  authorizeRoles("admin"),
  deleteOrder
);

export default router;