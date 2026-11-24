import express from "express";

import {
  getMessages,
  getRoomMessages,
  getUnreadMessageCount,
  getUserRooms,
  markMessageAsRead,
  markRoomMessagesAsRead,
  sendMessage,
  sendRoomMessage,
} from "../controllers/chatController.js";

import {
  protect,
} from "../middleware/authMiddleware.js";

const router = express.Router();

// =====================================================
// CHAT ROOMS
// =====================================================

// GET /api/chat/rooms
// GET /api/provider/chat/rooms
router.get(
  "/rooms",
  protect,
  getUserRooms
);

// GET /api/chat/unread-count
// GET /api/provider/chat/unread-count
router.get(
  "/unread-count",
  protect,
  getUnreadMessageCount
);

// =====================================================
// BOOKING ROOM MESSAGES
// =====================================================

// POST /api/chat/room
// POST /api/provider/chat/room
router.post(
  "/room",
  protect,
  sendRoomMessage
);

// GET /api/chat/room/:roomId
// GET /api/provider/chat/room/:roomId
router.get(
  "/room/:roomId",
  protect,
  getRoomMessages
);

// GET /api/chat/:roomId/messages
// GET /api/provider/chat/:roomId/messages
//
// Compatibility route used by the Flutter applications.
router.get(
  "/:roomId/messages",
  protect,
  getRoomMessages
);

// POST /api/chat/:roomId/messages
// POST /api/provider/chat/:roomId/messages
//
// Insert the URL room ID into the request body because
// sendRoomMessage reads roomId from req.body.
router.post(
  "/:roomId/messages",
  protect,
  (req, res, next) => {
    req.body = {
      ...(req.body || {}),

      roomId:
        req.params.roomId,

      chatRoomId:
        req.params.roomId,
    };

    return next();
  },
  sendRoomMessage
);

// =====================================================
// MESSAGE READ RECEIPTS
// =====================================================

// PATCH /api/chat/read/:messageId
// PATCH /api/provider/chat/read/:messageId
router.patch(
  "/read/:messageId",
  protect,
  markMessageAsRead
);

// PUT /api/chat/read/:messageId
// PUT /api/provider/chat/read/:messageId
router.put(
  "/read/:messageId",
  protect,
  markMessageAsRead
);

// PATCH /api/chat/room/:roomId/read
// PATCH /api/provider/chat/room/:roomId/read
router.patch(
  "/room/:roomId/read",
  protect,
  markRoomMessagesAsRead
);

// PUT /api/chat/room/:roomId/read
// PUT /api/provider/chat/room/:roomId/read
router.put(
  "/room/:roomId/read",
  protect,
  markRoomMessagesAsRead
);

// PATCH /api/chat/:roomId/read
// PATCH /api/provider/chat/:roomId/read
//
// Compatibility route used by the Flutter applications.
router.patch(
  "/:roomId/read",
  protect,
  markRoomMessagesAsRead
);

// PUT /api/chat/:roomId/read
// PUT /api/provider/chat/:roomId/read
router.put(
  "/:roomId/read",
  protect,
  markRoomMessagesAsRead
);

// =====================================================
// DIRECT USER-TO-USER CHAT
//
// Keep generic routes last so they do not intercept
// /rooms, /unread-count, /room/:roomId, or room-message
// compatibility routes.
// =====================================================

// POST /api/chat
// POST /api/provider/chat
router.post(
  "/",
  protect,
  sendMessage
);

// GET /api/chat/:userId
// GET /api/provider/chat/:userId
router.get(
  "/:userId",
  protect,
  getMessages
);

export default router;