import express from "express";
import { signup, signin, getProfile, googleLogin } from "../controllers/authController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

router.post("/signup", signup);
router.post("/signin", signin);
router.get("/profile", protect, getProfile);
router.post("/google", googleLogin); // ✅ ADD THIS

export default router;