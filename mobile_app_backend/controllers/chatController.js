import Chat from "../models/chat.js";
import Message from "../models/Message.js";
import { sendNotification } from "../utils/notification.js";
//import Message from "../models/messageModel.js"; //  NEW MODEL


/// =======================================================
/// ✅ ✅ ✅ NEW: ROOM-BASED MESSAGE (WITH BOOKING SUPPORT)
/// =======================================================
export const sendRoomMessage = async (req, res) => {
  try {
    const { roomId, senderId, receiverId, message } = req.body;

    if (!roomId || !senderId || !receiverId || !message) {
      return res.status(400).json({
        message: "Missing fields",
      });
    }

    const msg = await Message.create({
      roomId,
      senderId,
      receiverId,
      message,
    });

    res.status(201).json(msg);

  } catch (err) {
    console.error("❌ Room Message Error:", err);
    res.status(500).json({ message: err.message });
  }
};


/// =======================================================
/// ✅ ✅ ✅ NEW: GET ROOM MESSAGES
/// =======================================================
export const getRoomMessages = async (req, res) => {
  try {
    const messages = await Message.find({
      roomId: req.params.roomId,
    }).sort({ createdAt: 1 });

    res.json(messages);

  } catch (err) {
    console.error("❌ Get Room Messages Error:", err);
    res.status(500).json({ message: err.message });
  }
};


/// =======================================================
/// ✅ EXISTING: SEND MESSAGE (USER ↔ USER)
/// =======================================================
export const sendMessage = async (req, res) => {
  try {
    const { receiverId, message } = req.body;

    if (!receiverId || !message) {
      return res.status(400).json({
        message: "Missing fields",
      });
    }

    const chat = await Chat.create({
      sender: req.user.id,
      receiver: receiverId,
      message,
    });

    res.status(201).json(chat);

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};


/// =======================================================
/// ✅ EXISTING: GET CHAT BETWEEN TWO USERS
/// =======================================================
export const getMessages = async (req, res) => {
  try {
    const { userId } = req.params;

    const chats = await Chat.find({
      $or: [
        { sender: req.user.id, receiver: userId },
        { sender: userId, receiver: req.user.id },
      ],
    }).sort({ createdAt: 1 });

    res.json(chats);

  } catch (err) {
    res.status(500).json({
      message: err.message,
    });
  }
};