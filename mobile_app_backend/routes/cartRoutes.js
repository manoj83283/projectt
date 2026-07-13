import express from "express";

import {
  addToCart,
  getMyCart,
  updateCartItem,
  removeCartItem,
  clearCart,
  getCartSummary,
} from "../controllers/cartController.js";

import {
  protect,
  authorizeRoles,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =====================================================
// CUSTOMER ONLY
// =====================================================

router.use(
  protect,
  authorizeRoles("user")
);

// =====================================================
// GET CART
// =====================================================

router.get(
  "/",
  getMyCart
);

// =====================================================
// CART SUMMARY
// =====================================================

router.get(
  "/summary",
  getCartSummary
);

// =====================================================
// ADD ITEM TO CART
// =====================================================

router.post(
  "/add",
  addToCart
);

// =====================================================
// UPDATE CART ITEM
// =====================================================

router.put(
  "/item/:itemId",
  updateCartItem
);

// =====================================================
// REMOVE CART ITEM
// =====================================================

router.delete(
  "/item/:itemId",
  removeCartItem
);

// =====================================================
// CLEAR WHOLE CART
// =====================================================

router.delete(
  "/clear",
  clearCart
);

export default router;