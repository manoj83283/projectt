import express from "express";

import {
  getDashboardStats,
  getAllUsers,
  getAllProviders,
  getAllServices,
  getAllBookings,
  getAllOrders,
  approveService,
  blockService,
  blockUser,
  unblockUser,
  deleteServiceByAdmin,
  deleteUserByAdmin,
  getPlatformAnalytics,
} from "../controllers/adminController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";
import { adminOnly } from "../middleware/roleMiddleware.js";

const router = express.Router();

router.use(
  protect,
  authorizeRoles("admin")
);

router.get("/dashboard",protect,adminOnly,getDashboardStats);

router.get("/users", getAllUsers);
router.get("/providers", getAllProviders);

router.get("/services", getAllServices);
router.get("/bookings", getAllBookings);
router.get("/orders", getAllOrders);

router.put(
  "/service/:id/approve",
  approveService
);

router.put(
  "/service/:id/block",
  blockService
);

router.put(
  "/user/:id/block",
  blockUser
);

router.put(
  "/user/:id/unblock",
  unblockUser
);

router.delete(
  "/service/:id",
  deleteServiceByAdmin
);

router.delete(
  "/user/:id",
  deleteUserByAdmin
);

router.get(
  "/analytics",
  getPlatformAnalytics
);

export default router;