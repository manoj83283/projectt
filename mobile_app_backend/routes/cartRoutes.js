import express from "express";

import {
  sendMessage,
  getMessages,
  sendRoomMessage,
  getRoomMessages,
  getUserRooms,
  markMessageAsRead,
  markRoomMessagesAsRead,
  getUnreadMessageCount,
} from "../controllers/chatController.js";

import {
  protect,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =======================================================
// ROOM CHAT ROUTES
// KEEP ABOVE "/:userId"
// =======================================================

// =======================================================
// CHAT ROOMS
// =======================================================

// GET /api/chat/rooms
router.get(
  "/rooms",
  protect,
  getUserRooms
);

// =======================================================
// UNREAD COUNT
// =======================================================

// GET /api/chat/unread-count
router.get(
  "/unread-count",
  protect,
  getUnreadMessageCount
);

// =======================================================
// SEND MESSAGE TO BOOKING ROOM
// =======================================================

// POST /api/chat/room
router.post(
  "/room",
  protect,
  sendRoomMessage
);

// =======================================================
// GET BOOKING ROOM MESSAGES
// =======================================================

// GET /api/chat/room/:roomId
router.get(
  "/room/:roomId",
  protect,
  getRoomMessages
);

// =======================================================
// READ RECEIPTS
// =======================================================

// PATCH /api/chat/read/:messageId
router.patch(
  "/read/:messageId",
  protect,
  markMessageAsRead
);

// PUT /api/chat/read/:messageId
router.put(
  "/read/:messageId",
  protect,
  markMessageAsRead
);

// =======================================================
// MARK ENTIRE ROOM READ
// =======================================================

// PATCH /api/chat/room/:roomId/read
router.patch(
  "/room/:roomId/read",
  protect,
  markRoomMessagesAsRead
);

// PUT /api/chat/room/:roomId/read
router.put(
  "/room/:roomId/read",
  protect,
  markRoomMessagesAsRead
);

// =======================================================
// USER TO USER CHAT
// MUST REMAIN LAST
// =======================================================

// POST /api/chat
router.post(
  "/",
  protect,
  sendMessage
);

// GET /api/chat/:userId
router.get(
  "/:userId",
  protect,
  getMessages
);

export default router;