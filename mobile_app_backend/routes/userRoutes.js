import express from 'express';
import { createUser, getUsers, getProfile, updateProfile } from '../controllers/userController.js';
import { protect } from "../middleware/authMiddleware.js";
import {
  authorizeRoles,
  adminOnly,
  providerOnly,
  customerOnly,
} from "../middleware/roleMiddleware.js";
import {
  createBooking,
} from "../controllers/bookingController.js";

const router = express.Router();

router.post('/', createUser);
router.get('/', getUsers);
router.post(
  "/bookings",
  protect,
  customerOnly,
  createBooking
);
router.get(
  "/profile",
  protect,
  customerOnly,
  getProfile
);

router.put(
  "/profile",
  protect,
  customerOnly,
  updateProfile
);

export default router;