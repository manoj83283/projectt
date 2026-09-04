import express from "express";

import {
  signup,
  signin,
  googleLogin,
  getProfile,
  refreshAccessToken,
  logout,
  checkEmailExists,
  checkPhoneExists,
  updateFcmToken,
} from "../controllers/authController.js";

import {
  protect,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =====================================================
// REGISTRATION
// =====================================================

// Primary endpoint.
router.post(
  "/signup",
  signup
);

// Flutter compatibility endpoint.
router.post(
  "/register",
  signup
);

// =====================================================
// SIGN IN
// =====================================================

// Primary endpoint.
router.post(
  "/signin",
  signin
);

// Compatibility endpoint.
router.post(
  "/login",
  signin
);

// =====================================================
// GOOGLE LOGIN
// =====================================================

// Primary endpoint.
router.post(
  "/google",
  googleLogin
);

// Customer Flutter compatibility endpoint.
router.post(
  "/google-login",
  googleLogin
);

// =====================================================
// REFRESH ACCESS TOKEN
// =====================================================

router.post(
  "/refresh-token",
  refreshAccessToken
);

// Compatibility alias.
router.post(
  "/refresh",
  refreshAccessToken
);

// =====================================================
// PROFILE
// =====================================================

router.get(
  "/profile",
  protect,
  getProfile
);

// =====================================================
// ACCOUNT LOOKUPS
// =====================================================

router.get(
  "/check-email",
  checkEmailExists
);

router.get(
  "/check-phone",
  checkPhoneExists
);

// =====================================================
// FCM TOKEN
// =====================================================

router.post(
  "/fcm-token",
  protect,
  updateFcmToken
);

// =====================================================
// LOGOUT
// =====================================================

router.post(
  "/logout",
  protect,
  logout
);

export default router;