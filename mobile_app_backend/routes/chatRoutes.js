import express from "express";
import {
  sendMessage,
  getMessages,
  sendRoomMessage,     //  NEW
  getRoomMessages,     //  NEW
} from "../controllers/chatController.js";

import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

/// =======================================================
/// ✅ EXISTING USER ↔ USER CHAT (PRESERVED ✅)
/// =======================================================
router.post("/", protect, sendMessage);
router.get("/:userId", protect, getMessages);


/// =======================================================
/// ✅ ✅ ✅ NEW: ROOM-BASED CHAT (BOOKING CHAT 🔥)
/// =======================================================

// ✅ SEND MESSAGE TO ROOM
router.post("/room", protect, sendRoomMessage);

// ✅ GET ROOM MESSAGES
router.get("/room/:roomId", protect, getRoomMessages);

export default router;