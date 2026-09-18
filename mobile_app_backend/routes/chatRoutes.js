import express from "express";

import {
  sendMessage,
  getMessages,
  sendRoomMessage,
  getRoomMessages,
  getUserRooms,
} from "../controllers/chatController.js";

import {
  protect,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =======================================================
// ROOM CHAT ROUTES
// MUST COME BEFORE "/:userId"
// =======================================================

// Get provider/customer rooms
router.get(
  "/rooms",
  protect,
  getUserRooms
);

// Send room message
router.post(
  "/room",
  protect,
  sendRoomMessage
);

// Get messages for a room
router.get(
  "/room/:roomId",
  protect,
  getRoomMessages
);

// =======================================================
// USER TO USER CHAT
// MUST BE LAST
// =======================================================

router.post(
  "/",
  protect,
  sendMessage
);

router.get(
  "/:userId",
  protect,
  getMessages
);

export default router;