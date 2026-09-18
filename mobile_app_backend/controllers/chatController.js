import mongoose from "mongoose";

import Chat from "../models/chat.js";
import Message from "../models/Message.js";

// =====================================================
// HELPERS
// =====================================================

const getAuthenticatedUserId = (req) => {
  return (
    req.user?._id?.toString() ||
    req.user?.id?.toString() ||
    ""
  );
};

const normalizeString = (
  value,
  fallback = ""
) => {
  if (
    value === null ||
    value === undefined
  ) {
    return fallback;
  }

  const normalizedValue =
    value.toString().trim();

  return normalizedValue || fallback;
};

const isValidObjectId = (value) => {
  return mongoose.Types.ObjectId.isValid(
    value
  );
};

const asPlainObject = (document) => {
  if (!document) {
    return null;
  }

  if (
    typeof document.toObject ===
    "function"
  ) {
    return document.toObject({
      virtuals: true,
    });
  }

  return {
    ...document,
  };
};

const serializeDirectMessage = (
  document
) => {
  const value =
    asPlainObject(document);

  if (!value) {
    return null;
  }

  return {
    ...value,

    id:
      value._id?.toString() ||
      value.id?.toString() ||
      "",

    senderId:
      value.sender?._id?.toString() ||
      value.sender?.toString() ||
      value.senderId?.toString() ||
      "",

    receiverId:
      value.receiver?._id?.toString() ||
      value.receiver?.toString() ||
      value.receiverId?.toString() ||
      "",
  };
};

const serializeRoomMessage = (
  document
) => {
  const value =
    asPlainObject(document);

  if (!value) {
    return null;
  }

  return {
    ...value,

    id:
      value._id?.toString() ||
      value.id?.toString() ||
      "",

    roomId:
      value.roomId?.toString() ||
      "",

    senderId:
      value.senderId?._id?.toString() ||
      value.senderId?.toString() ||
      value.sender?._id?.toString() ||
      value.sender?.toString() ||
      "",

    receiverId:
      value.receiverId?._id?.toString() ||
      value.receiverId?.toString() ||
      value.receiver?._id?.toString() ||
      value.receiver?.toString() ||
      "",
  };
};

const sendError = (
  res,
  statusCode,
  message
) => {
  return res.status(statusCode).json({
    success: false,
    message,
    msg: message,
  });
};

const sendControllerError = (
  res,
  label,
  error
) => {
  console.error(
    `${label}:`,
    error
  );

  if (
    error?.name === "CastError"
  ) {
    return sendError(
      res,
      400,
      "Invalid identifier"
    );
  }

  if (
    error?.name ===
    "ValidationError"
  ) {
    const errors = Object.values(
      error.errors || {}
    ).map(
      (item) => item.message
    );

    return res.status(400).json({
      success: false,
      message:
        errors[0] ||
        "Chat validation failed",
      msg:
        errors[0] ||
        "Chat validation failed",
      errors,
    });
  }

  return sendError(
    res,
    500,
    error?.message ||
      "Internal server error"
  );
};

const emitSocketEvent = (
  roomNames,
  eventName,
  data
) => {
  const io = global.io;

  if (!io) {
    return;
  }

  const uniqueRooms = [
    ...new Set(
      roomNames
        .map(
          (room) =>
            normalizeString(room)
        )
        .filter(Boolean)
    ),
  ];

  for (const roomName of uniqueRooms) {
    io.to(roomName).emit(
      eventName,
      data
    );
  }
};

// =====================================================
// GET CHAT ROOMS
//
// GET /api/chat/rooms
// GET /api/provider/chat/rooms
// =====================================================

export const getUserRooms = async (
  req,
  res
) => {
  try {
    const userId =
      getAuthenticatedUserId(req);

    if (
      !userId ||
      !isValidObjectId(userId)
    ) {
      return sendError(
        res,
        401,
        "Authentication required"
      );
    }

    const directChats =
      await Chat.find({
        $or: [
          {
            sender: userId,
          },
          {
            receiver: userId,
          },
        ],
      })
        .populate(
          "sender",
          [
            "firstName",
            "lastName",
            "name",
            "fullName",
            "email",
            "phone",
            "mobile",
            "profileImage",
            "role",
            "businessName",
            "shopName",
            "isOnline",
          ].join(" ")
        )
        .populate(
          "receiver",
          [
            "firstName",
            "lastName",
            "name",
            "fullName",
            "email",
            "phone",
            "mobile",
            "profileImage",
            "role",
            "businessName",
            "shopName",
            "isOnline",
          ].join(" ")
        )
        .sort({
          createdAt: -1,
        });

    const directRoomMap =
      new Map();

    for (
      const chatDocument of
      directChats
    ) {
      const chat =
        serializeDirectMessage(
          chatDocument
        );

      if (!chat) {
        continue;
      }

      const senderId =
        chat.senderId;

      const receiverId =
        chat.receiverId;

      const otherUser =
        senderId === userId
          ? chat.receiver
          : chat.sender;

      const otherUserId =
        senderId === userId
          ? receiverId
          : senderId;

      if (!otherUserId) {
        continue;
      }

      if (
        directRoomMap.has(
          otherUserId
        )
      ) {
        continue;
      }

      directRoomMap.set(
        otherUserId,
        {
          id:
            `direct:$otherUserId`,

          roomId:
            `direct:$otherUserId`,

          type:
            "direct",

          participantId:
            otherUserId,

          user:
            otherUser,

          participant:
            otherUser,

          lastMessage:
            chat.message || "",

          lastMessageAt:
            chat.createdAt ||
            chat.updatedAt,

          unreadCount: 0,

          latestMessage:
            chat,
        }
      );
    }

    let roomMessages = [];

    try {
      roomMessages =
        await Message.find({
          $or: [
            {
              senderId: userId,
            },
            {
              receiverId: userId,
            },
          ],
        })
          .populate(
            "senderId",
            [
              "firstName",
              "lastName",
              "name",
              "fullName",
              "email",
              "phone",
              "mobile",
              "profileImage",
              "role",
              "businessName",
              "shopName",
              "isOnline",
            ].join(" ")
          )
          .populate(
            "receiverId",
            [
              "firstName",
              "lastName",
              "name",
              "fullName",
              "email",
              "phone",
              "mobile",
              "profileImage",
              "role",
              "businessName",
              "shopName",
              "isOnline",
            ].join(" ")
          )
          .sort({
            createdAt: -1,
          });
    } catch (roomError) {
      console.error(
        "Room message lookup error:",
        roomError.message
      );

      roomMessages = [];
    }

    const bookingRoomMap =
      new Map();

    for (
      const messageDocument of
      roomMessages
    ) {
      const message =
        serializeRoomMessage(
          messageDocument
        );

      if (
        !message ||
        !message.roomId
      ) {
        continue;
      }

      if (
        bookingRoomMap.has(
          message.roomId
        )
      ) {
        continue;
      }

      const senderId =
        message.senderId;

      const receiverId =
        message.receiverId;

      const otherUser =
        senderId === userId
          ? message.receiverId
          : message.senderId;

      const otherUserId =
        senderId === userId
          ? receiverId
          : senderId;

      bookingRoomMap.set(
        message.roomId,
        {
          id:
            message.roomId,

          roomId:
            message.roomId,

          bookingId:
            message.roomId,

          type:
            "booking",

          participantId:
            otherUserId,

          user:
            otherUser,

          participant:
            otherUser,

          lastMessage:
            message.message || "",

          lastMessageAt:
            message.createdAt ||
            message.updatedAt,

          unreadCount: 0,

          latestMessage:
            message,
        }
      );
    }

    const rooms = [
      ...bookingRoomMap.values(),
      ...directRoomMap.values(),
    ].sort(
      (first, second) => {
        const firstDate =
          new Date(
            first.lastMessageAt || 0
          ).getTime();

        const secondDate =
          new Date(
            second.lastMessageAt || 0
          ).getTime();

        return secondDate -
            firstDate;
      }
    );

    return res.status(200).json({
      success: true,
      message:
        "Chat rooms fetched successfully",
      rooms,
      conversations: rooms,
      data: rooms,
      count: rooms.length,
    });
  } catch (error) {
    return sendControllerError(
      res,
      "Get Chat Rooms Error",
      error
    );
  }
};

// =====================================================
// SEND ROOM MESSAGE
//
// POST /api/chat/room
// POST /api/provider/chat/room
// =====================================================

export const sendRoomMessage = async (
  req,
  res
) => {
  try {
    const authenticatedUserId =
      getAuthenticatedUserId(req);

    if (
      !authenticatedUserId ||
      !isValidObjectId(
        authenticatedUserId
      )
    ) {
      return sendError(
        res,
        401,
        "Authentication required"
      );
    }

    const roomId =
      normalizeString(
        req.body.roomId
      );

    const receiverId =
      normalizeString(
        req.body.receiverId
      );

    const message =
      normalizeString(
        req.body.message ||
          req.body.text ||
          req.body.content
      );

    if (!roomId) {
      return sendError(
        res,
        400,
        "Room ID is required"
      );
    }

    if (
      !receiverId ||
      !isValidObjectId(receiverId)
    ) {
      return sendError(
        res,
        400,
        "A valid receiver ID is required"
      );
    }

    if (!message) {
      return sendError(
        res,
        400,
        "Message is required"
      );
    }

    if (
      receiverId ===
      authenticatedUserId
    ) {
      return sendError(
        res,
        400,
        "You cannot send a message to yourself"
      );
    }

    const messageData = {
      roomId,

      senderId:
        authenticatedUserId,

      receiverId,

      message,
    };

    const schemaPaths =
      Message.schema?.paths || {};

    if (
      schemaPaths.sender &&
      !schemaPaths.senderId
    ) {
      messageData.sender =
        authenticatedUserId;

      delete messageData.senderId;
    }

    if (
      schemaPaths.receiver &&
      !schemaPaths.receiverId
    ) {
      messageData.receiver =
        receiverId;

      delete messageData.receiverId;
    }

    if (
      schemaPaths.text &&
      !schemaPaths.message
    ) {
      messageData.text =
        message;

      delete messageData.message;
    }

    if (
      schemaPaths.content &&
      !schemaPaths.message &&
      !schemaPaths.text
    ) {
      messageData.content =
        message;

      delete messageData.message;
    }

    const createdMessage =
      await Message.create(
        messageData
      );

    let populatedMessage =
      createdMessage;

    try {
      populatedMessage =
        await Message.findById(
          createdMessage._id
        )
          .populate(
            "senderId",
            "firstName lastName name fullName email phone profileImage role"
          )
          .populate(
            "receiverId",
            "firstName lastName name fullName email phone profileImage role"
          );
    } catch (populateError) {
      console.error(
        "Room message population error:",
        populateError.message
      );
    }

    const data =
      serializeRoomMessage(
        populatedMessage ||
          createdMessage
      );

    emitSocketEvent(
      [
        roomId,
        `room:${roomId}`,
        `user:${authenticatedUserId}`,
        `user:${receiverId}`,
        `provider:${authenticatedUserId}`,
        `provider:${receiverId}`,
      ],
      "newRoomMessage",
      data
    );

    emitSocketEvent(
      [
        roomId,
        `room:${roomId}`,
      ],
      "newMessage",
      data
    );

    return res.status(201).json({
      success: true,
      message:
        "Room message sent successfully",
      chatMessage:
        data,
      data,
    });
  } catch (error) {
    return sendControllerError(
      res,
      "Send Room Message Error",
      error
    );
  }
};

// =====================================================
// GET ROOM MESSAGES
//
// GET /api/chat/room/:roomId
// GET /api/provider/chat/room/:roomId
// =====================================================

export const getRoomMessages = async (
  req,
  res
) => {
  try {
    const authenticatedUserId =
      getAuthenticatedUserId(req);

    if (
      !authenticatedUserId ||
      !isValidObjectId(
        authenticatedUserId
      )
    ) {
      return sendError(
        res,
        401,
        "Authentication required"
      );
    }

    const roomId =
      normalizeString(
        req.params.roomId
      );

    if (!roomId) {
      return sendError(
        res,
        400,
        "Room ID is required"
      );
    }

    const participantFilter = {
      $or: [
        {
          senderId:
            authenticatedUserId,
        },
        {
          receiverId:
            authenticatedUserId,
        },
      ],
    };

    const query = {
      roomId,
      ...participantFilter,
    };

    const messages =
      await Message.find(query)
        .populate(
          "senderId",
          "firstName lastName name fullName email phone profileImage role"
        )
        .populate(
          "receiverId",
          "firstName lastName name fullName email phone profileImage role"
        )
        .sort({
          createdAt: 1,
        });

    const data = messages
      .map(
        serializeRoomMessage
      )
      .filter(Boolean);

    return res.status(200).json({
      success: true,
      message:
        "Room messages fetched successfully",
      roomId,
      messages:
        data,
      data,
      count:
        data.length,
    });
  } catch (error) {
    return sendControllerError(
      res,
      "Get Room Messages Error",
      error
    );
  }
};

// =====================================================
// SEND DIRECT MESSAGE
//
// POST /api/chat
// POST /api/provider/chat
// =====================================================

export const sendMessage = async (
  req,
  res
) => {
  try {
    const senderId =
      getAuthenticatedUserId(req);

    if (
      !senderId ||
      !isValidObjectId(senderId)
    ) {
      return sendError(
        res,
        401,
        "Authentication required"
      );
    }

    const receiverId =
      normalizeString(
        req.body.receiverId ||
          req.body.receiver
      );

    const message =
      normalizeString(
        req.body.message ||
          req.body.text ||
          req.body.content
      );

    if (
      !receiverId ||
      !isValidObjectId(receiverId)
    ) {
      return sendError(
        res,
        400,
        "A valid receiver ID is required"
      );
    }

    if (!message) {
      return sendError(
        res,
        400,
        "Message is required"
      );
    }

    if (
      receiverId === senderId
    ) {
      return sendError(
        res,
        400,
        "You cannot send a message to yourself"
      );
    }

    const chat =
      await Chat.create({
        sender:
          senderId,

        receiver:
          receiverId,

        message,
      });

    const populatedChat =
      await Chat.findById(
        chat._id
      )
        .populate(
          "sender",
          "firstName lastName name fullName email phone profileImage role"
        )
        .populate(
          "receiver",
          "firstName lastName name fullName email phone profileImage role"
        );

    const data =
      serializeDirectMessage(
        populatedChat || chat
      );

    emitSocketEvent(
      [
        `user:${senderId}`,
        `user:${receiverId}`,
        `provider:${senderId}`,
        `provider:${receiverId}`,
      ],
      "newMessage",
      data
    );

    return res.status(201).json({
      success: true,
      message:
        "Message sent successfully",
      chat:
        data,
      data,
    });
  } catch (error) {
    return sendControllerError(
      res,
      "Send Message Error",
      error
    );
  }
};

// =====================================================
// GET DIRECT MESSAGES
//
// GET /api/chat/:userId
// GET /api/provider/chat/:userId
// =====================================================

export const getMessages = async (
  req,
  res
) => {
  try {
    const authenticatedUserId =
      getAuthenticatedUserId(req);

    if (
      !authenticatedUserId ||
      !isValidObjectId(
        authenticatedUserId
      )
    ) {
      return sendError(
        res,
        401,
        "Authentication required"
      );
    }

    const userId =
      normalizeString(
        req.params.userId
      );

    if (
      !userId ||
      !isValidObjectId(userId)
    ) {
      return sendError(
        res,
        400,
        "A valid user ID is required"
      );
    }

    const chats =
      await Chat.find({
        $or: [
          {
            sender:
              authenticatedUserId,

            receiver:
              userId,
          },
          {
            sender:
              userId,

            receiver:
              authenticatedUserId,
          },
        ],
      })
        .populate(
          "sender",
          "firstName lastName name fullName email phone profileImage role"
        )
        .populate(
          "receiver",
          "firstName lastName name fullName email phone profileImage role"
        )
        .sort({
          createdAt: 1,
        });

    const data = chats
      .map(
        serializeDirectMessage
      )
      .filter(Boolean);

    return res.status(200).json({
      success: true,
      message:
        "Messages fetched successfully",
      messages:
        data,
      chats:
        data,
      data,
      count:
        data.length,
    });
  } catch (error) {
    return sendControllerError(
      res,
      "Get Messages Error",
      error
    );
  }
};