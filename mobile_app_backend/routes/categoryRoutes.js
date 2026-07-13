import express from "express";
import {
  createCategory,
  getAllCategories,
  getActiveCategories,
  getFeaturedCategories,
  getCategoriesByType,
  getCategoryById,
  getCategoryBySlug,
  updateCategory,
  toggleCategoryStatus,
  toggleFeaturedCategory,
  activateCategory,
  deactivateCategory,
  deleteCategory,
  getCategoryAnalytics,
} from "../controllers/categoryController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =====================================================
// PUBLIC ROUTES
// =====================================================

// Get All Categories
router.get("/", getAllCategories);

// Featured Categories
router.get("/featured", getFeaturedCategories);

// Categories By Type
router.get("/type/:type", getCategoriesByType);

// Category By Slug
router.get("/slug/:slug", getCategoryBySlug);

// Category By ID
router.get("/:id", getCategoryById);

router.get("/", getAllCategories);

// =====================================================
// ADMIN ROUTES
// =====================================================

// Create Category
router.post(
  "/",
  protect,
  authorizeRoles("admin"),
  createCategory
);

// Update Category
router.put(
  "/:id",
  protect,
  authorizeRoles("admin"),
  updateCategory
);

// Activate Category
/*router.put(
  "/:id/activate",
  protect,
  authorizeRoles("admin"),
  activateCategory
);

// Deactivate Category
router.put(
  "/:id/deactivate",
  protect,
  authorizeRoles("admin"),
  deactivateCategory
); */

// Toggle Featured
router.put(
  "/:id/featured",
  protect,
  authorizeRoles("admin"),
  toggleFeaturedCategory
);

// Analytics
router.get(
  "/admin/analytics",
  protect,
  authorizeRoles("admin"),
  getCategoryAnalytics
);

// Delete Category
router.delete(
  "/:id",
  protect,
  authorizeRoles("admin"),
  deleteCategory
);

export default router;