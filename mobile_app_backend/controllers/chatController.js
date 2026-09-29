import mongoose from "mongoose";

import Booking from "../models/Booking.js";
import Chat from "../models/chat.js";
import Message from "../models/Message.js";

// =====================================================
// COMMON HELPERS
// =====================================================

const getAuthenticatedUserId = (req) => {
  return (
    req.user?._id?.toString() ||
    req.user?.id?.toString() ||
    ""
  );
};

const getAuthenticatedUserRole = (req) => {
  return (
    req.user?.role
      ?.toString()
      .trim()
      .toLowerCase() ||
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

const normalizeNumber = (
  value,
  fallback = 0
) => {
  if (
    value === null ||
    value === undefined ||
    value === ""
  ) {
    return fallback;
  }

  const parsedValue = Number(value);

  return Number.isFinite(parsedValue)
    ? parsedValue
    : fallback;
};

const isValidObjectId = (value) => {
  return mongoose.Types.ObjectId.isValid(
    value
  );
};

const getDocumentId = (value) => {
  if (!value) {
    return "";
  }

  if (typeof value === "string") {
    return value.trim();
  }

  if (value._id) {
    return value._id.toString();
  }

  if (value.id) {
    return value.id.toString();
  }

  return value.toString();
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

const normalizeRoomId = (
  value
) => {
  const roomId =
    normalizeString(value);

  if (!roomId) {
    return "";
  }

  if (
    roomId.startsWith(
      "booking:"
    )
  ) {
    return roomId;
  }

  if (
    isValidObjectId(roomId)
  ) {
    return `booking:${roomId}`;
  }

  return roomId;
};

const extractBookingId = (
  roomId,
  bookingId
) => {
  const normalizedBookingId =
    normalizeString(bookingId);

  if (
    normalizedBookingId &&
    isValidObjectId(
      normalizedBookingId
    )
  ) {
    return normalizedBookingId;
  }

  const normalizedRoomId =
    normalizeString(roomId);

  if (
    normalizedRoomId.startsWith(
      "booking:"
    )
  ) {
    const value =
      normalizedRoomId
        .substring(
          "booking:".length
        )
        .trim();

    if (isValidObjectId(value)) {
      return value;
    }
  }

  if (
    isValidObjectId(
      normalizedRoomId
    )
  ) {
    return normalizedRoomId;
  }

  return "";
};

const getPagination = (req) => {
  const page = Math.max(
    1,
    Math.floor(
      normalizeNumber(
        req.query.page,
        1
      )
    )
  );

  const requestedLimit =
    Math.max(
      1,
      Math.floor(
        normalizeNumber(
          req.query.limit,
          50
        )
      )
    );

  const limit = Math.min(
    requestedLimit,
    100
  );

  return {
    page,
    limit,
    skip:
      (page - 1) * limit,
  };
};

const sendError = (
  res,
  statusCode,
  message,
  extra = {}
) => {
  return res
    .status(statusCode)
    .json({
      success: false,
      message,
      msg: message,
      ...extra,
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
    error?.name ===
    "CastError"
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
    const errors =
      Object.values(
        error.errors || {}
      ).map(
        (item) =>
          item.message
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

// =====================================================
// SERIALIZATION
// =====================================================

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
      getDocumentId(
        value.sender ||
        value.senderId
      ),

    receiverId:
      getDocumentId(
        value.receiver ||
        value.receiverId
      ),

    message:
      value.message ||
      value.text ||
      value.content ||
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

  const bookingId =
    getDocumentId(
      value.bookingId
    );

  const roomId =
    normalizeString(
      value.roomId,
      bookingId
        ? `booking:${bookingId}`
        : ""
    );

  return {
    ...value,

    id:
      value._id?.toString() ||
      value.id?.toString() ||
      "",

    bookingId,

    roomId,

    senderId:
      getDocumentId(
        value.senderId ||
        value.sender
      ),

    receiverId:
      getDocumentId(
        value.receiverId ||
        value.receiver
      ),

    message:
      value.message ||
      value.text ||
      value.content ||
      "",

    isRead:
      value.isRead === true ||
      value.read === true,

    delivered:
      value.delivered === true,
  };
};

// =====================================================
// SOCKET HELPERS
// =====================================================

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

  for (
    const roomName of
    uniqueRooms
  ) {
    io.to(roomName).emit(
      eventName,
      data
    );
  }
};

const emitMessageCreated = (
  message
) => {
  if (!message) {
    return;
  }

  const rooms = [
    message.roomId,

    message.bookingId
      ? `booking:${message.bookingId}`
      : "",

    message.bookingId,

    message.senderId
      ? `user:${message.senderId}`
      : "",

    message.senderId
      ? `provider:${message.senderId}`
      : "",

    message.receiverId
      ? `user:${message.receiverId}`
      : "",

    message.receiverId
      ? `provider:${message.receiverId}`
      : "",
  ];

  emitSocketEvent(
    rooms,
    "newMessage",
    message
  );

  emitSocketEvent(
    rooms,
    "receiveMessage",
    message
  );

  emitSocketEvent(
    rooms,
    "newRoomMessage",
    message
  );

  if (message.receiverId) {
    emitSocketEvent(
      [
        `user:${message.receiverId}`,
        `provider:${message.receiverId}`,
      ],
      "newMessageNotification",
      message
    );
  }
};

const emitReadReceipt = (
  message
) => {
  if (!message) {
    return;
  }

  const rooms = [
    message.roomId,

    message.bookingId
      ? `booking:${message.bookingId}`
      : "",

    message.senderId
      ? `user:${message.senderId}`
      : "",

    message.senderId
      ? `provider:${message.senderId}`
      : "",

    message.receiverId
      ? `user:${message.receiverId}`
      : "",

    message.receiverId
      ? `provider:${message.receiverId}`
      : "",
  ];

  emitSocketEvent(
    rooms,
    "messageRead",
    message
  );
};

// =====================================================
// BOOKING ACCESS HELPERS
// =====================================================

const getBookingForChat =
  async (bookingId) => {
    if (
      !bookingId ||
      !isValidObjectId(
        bookingId
      )
    ) {
      return null;
    }

    return Booking.findById(
      bookingId
    )
      .populate(
        "user",
        "firstName lastName name fullName email phone mobile profileImage role isOnline"
      )
      .populate(
        "customer",
        "firstName lastName name fullName email phone mobile profileImage role isOnline"
      )
      .populate(
        "provider",
        "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
      )
      .populate(
        "service",
        "name title image imageUrl images"
      );
  };

const getBookingParticipantData = (
  booking,
  currentUserId
) => {
  const customer =
    booking?.customer ||
    booking?.user;

  const provider =
    booking?.provider;

  const customerId =
    getDocumentId(customer);

  const providerId =
    getDocumentId(provider);

  const isCustomer =
    customerId ===
    currentUserId;

  const isProvider =
    providerId ===
    currentUserId;

  return {
    customer,
    provider,
    customerId,
    providerId,
    isCustomer,
    isProvider,
    hasAccess:
      isCustomer ||
      isProvider,
    otherUser:
      isCustomer
        ? provider
        : customer,
    otherUserId:
      isCustomer
        ? providerId
        : customerId,
  };
};

const validateBookingChatAccess =
  async ({
    bookingId,
    currentUserId,
    role,
  }) => {
    const booking =
      await getBookingForChat(
        bookingId
      );

    if (!booking) {
      return {
        success: false,
        statusCode: 404,
        message:
          "Booking not found",
      };
    }

    const participantData =
      getBookingParticipantData(
        booking,
        currentUserId
      );

    const isAdmin =
      role === "admin";

    if (
      !participantData.hasAccess &&
      !isAdmin
    ) {
      return {
        success: false,
        statusCode: 403,
        message:
          "You do not have access to this booking chat",
      };
    }

    if (
      booking.chatEnabled ===
      false
    ) {
      return {
        success: false,
        statusCode: 403,
        message:
          "Chat is disabled for this booking",
      };
    }

    return {
      success: true,
      booking,
      participantData,
    };
  };

// =====================================================
// MESSAGE QUERY HELPERS
// =====================================================

const populateRoomMessageQuery = (
  query
) => {
  return query
    .populate(
      "bookingId",
      "bookingNumber status chatRoomId chatEnabled"
    )
    .populate(
      "senderId",
      "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
    )
    .populate(
      "receiverId",
      "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
    )
    .populate(
      "sender",
      "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
    )
    .populate(
      "receiver",
      "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
    );
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

    const bookings =
      await Booking.find({
        $or: [
          {
            user: userId,
          },
          {
            customer: userId,
          },
          {
            provider: userId,
          },
        ],

        chatEnabled: {
          $ne: false,
        },

        deletedAt: null,
      })
        .populate(
          "user",
          "firstName lastName name fullName email phone mobile profileImage role isOnline"
        )
        .populate(
          "customer",
          "firstName lastName name fullName email phone mobile profileImage role isOnline"
        )
        .populate(
          "provider",
          "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
        )
        .populate(
          "service",
          "name title image imageUrl images"
        )
        .sort({
          updatedAt: -1,
        });

    const rooms = [];

    for (
      const booking of
      bookings
    ) {
      const participantData =
        getBookingParticipantData(
          booking,
          userId
        );

      const bookingId =
        booking._id.toString();

      const roomId =
        normalizeRoomId(
          booking.chatRoomId ||
          bookingId
        );

      const latestMessageDocument =
        await populateRoomMessageQuery(
          Message.findOne({
            bookingId:
              booking._id,

            $or: [
              {
                senderId:
                  userId,
              },
              {
                receiverId:
                  userId,
              },
            ],

            deletedAt: null,
          }).sort({
            createdAt: -1,
          })
        );

      const latestMessage =
        serializeRoomMessage(
          latestMessageDocument
        );

      const unreadCount =
        await Message.countDocuments({
          bookingId:
            booking._id,

          receiverId:
            userId,

          isRead: {
            $ne: true,
          },

          read: {
            $ne: true,
          },

          deletedForReceiver: {
            $ne: true,
          },

          deletedAt: null,
        });

      const bookingValue =
        asPlainObject(booking);

      rooms.push({
        id: roomId,
        roomId,
        bookingId,

        bookingNumber:
          booking.bookingNumber ||
          "",

        type: "booking",

        status:
          booking.status,

        chatEnabled:
          booking.chatEnabled !==
          false,

        participantId:
          participantData
            .otherUserId,

        participant:
          participantData
            .otherUser,

        user:
          participantData
            .otherUser,

        customer:
          bookingValue.customer ||
          bookingValue.user,

        provider:
          bookingValue.provider,

        service:
          bookingValue.service,

        lastMessage:
          latestMessage?.message ||
          "",

        lastMessageAt:
          latestMessage?.createdAt ||
          booking.updatedAt ||
          booking.createdAt,

        unreadCount,

        latestMessage,
      });
    }

    rooms.sort(
      (
        firstRoom,
        secondRoom
      ) => {
        const firstDate =
          new Date(
            firstRoom
              .lastMessageAt ||
            0
          ).getTime();

        const secondDate =
          new Date(
            secondRoom
              .lastMessageAt ||
            0
          ).getTime();

        return (
          secondDate -
          firstDate
        );
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
// SEND BOOKING ROOM MESSAGE
//
// POST /api/chat/room
// POST /api/provider/chat/room
// =====================================================

export const sendRoomMessage = async (
  req,
  res
) => {
  try {
    const senderId =
      getAuthenticatedUserId(req);

    const senderRole =
      getAuthenticatedUserRole(
        req
      );

    if (
      !senderId ||
      !isValidObjectId(
        senderId
      )
    ) {
      return sendError(
        res,
        401,
        "Authentication required"
      );
    }

    const requestedRoomId =
      normalizeString(
        req.body.roomId ||
        req.body.chatRoomId
      );

    const bookingId =
      extractBookingId(
        requestedRoomId,
        req.body.bookingId
      );

    if (
      !bookingId ||
      !isValidObjectId(
        bookingId
      )
    ) {
      return sendError(
        res,
        400,
        "A valid booking ID is required"
      );
    }

    const access =
      await validateBookingChatAccess({
        bookingId,
        currentUserId:
          senderId,
        role:
          senderRole,
      });

    if (!access.success) {
      return sendError(
        res,
        access.statusCode,
        access.message
      );
    }

    const message =
      normalizeString(
        req.body.message ||
        req.body.text ||
        req.body.content
      );

    if (!message) {
      return sendError(
        res,
        400,
        "Message is required"
      );
    }

    if (
      message.length > 5000
    ) {
      return sendError(
        res,
        400,
        "Message cannot exceed 5000 characters"
      );
    }

    const requestedReceiverId =
      normalizeString(
        req.body.receiverId ||
        req.body.receiver
      );

    const receiverId =
      requestedReceiverId ||
      access.participantData
        .otherUserId;

    if (
      !receiverId ||
      !isValidObjectId(
        receiverId
      )
    ) {
      return sendError(
        res,
        400,
        "A valid receiver ID is required"
      );
    }

    if (
      receiverId ===
      senderId
    ) {
      return sendError(
        res,
        400,
        "You cannot send a message to yourself"
      );
    }

    const allowedReceiverIds = [
      access.participantData
        .customerId,
      access.participantData
        .providerId,
    ];

    if (
      senderRole !== "admin" &&
      !allowedReceiverIds.includes(
        receiverId
      )
    ) {
      return sendError(
        res,
        403,
        "Receiver is not a participant in this booking"
      );
    }

    const roomId =
      normalizeRoomId(
        access.booking.chatRoomId ||
        requestedRoomId ||
        bookingId
      );

    const messageType =
      normalizeString(
        req.body.messageType,
        "text"
      ).toLowerCase();

    const createdMessage =
      await Message.create({
        bookingId,
        roomId,
        senderId,
        receiverId,

        sender:
          senderId,

        receiver:
          receiverId,

        message,
        text: message,
        content: message,

        messageType,

        senderRole:
          senderRole === "user"
            ? "customer"
            : senderRole,

        isRead: false,
        read: false,

        delivered: true,
        deliveredAt:
          new Date(),
      });

    const populatedMessage =
      await populateRoomMessageQuery(
        Message.findById(
          createdMessage._id
        )
      );

    const data =
      serializeRoomMessage(
        populatedMessage ||
        createdMessage
      );

    emitMessageCreated(data);

    return res.status(201).json({
      success: true,
      message:
        "Room message sent successfully",
      chatMessage: data,
      savedMessage: data,
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
// GET BOOKING ROOM MESSAGES
//
// GET /api/chat/room/:roomId
// GET /api/provider/chat/room/:roomId
// =====================================================

export const getRoomMessages = async (
  req,
  res
) => {
  try {
    const currentUserId =
      getAuthenticatedUserId(req);

    const currentRole =
      getAuthenticatedUserRole(
        req
      );

    if (
      !currentUserId ||
      !isValidObjectId(
        currentUserId
      )
    ) {
      return sendError(
        res,
        401,
        "Authentication required"
      );
    }

    const requestedRoomId =
      normalizeString(
        req.params.roomId
      );

    const bookingId =
      extractBookingId(
        requestedRoomId,
        req.query.bookingId
      );

    if (
      !bookingId ||
      !isValidObjectId(
        bookingId
      )
    ) {
      return sendError(
        res,
        400,
        "A valid booking room is required"
      );
    }

    const access =
      await validateBookingChatAccess({
        bookingId,
        currentUserId,
        role:
          currentRole,
      });

    if (!access.success) {
      return sendError(
        res,
        access.statusCode,
        access.message
      );
    }

    const {
      page,
      limit,
      skip,
    } = getPagination(req);

    const roomId =
      normalizeRoomId(
        access.booking.chatRoomId ||
        requestedRoomId ||
        bookingId
      );

    const accessFilter =
      currentRole === "admin"
        ? {}
        : {
            $or: [
              {
                senderId:
                  currentUserId,
              },
              {
                receiverId:
                  currentUserId,
              },
            ],
          };

    const filter = {
      bookingId,

      deletedAt: null,

      ...accessFilter,
    };

    const [
      total,
      messages,
    ] = await Promise.all([
      Message.countDocuments(
        filter
      ),

      populateRoomMessageQuery(
        Message.find(filter)
          .sort({
            createdAt: -1,
          })
          .skip(skip)
          .limit(limit)
      ),
    ]);

    const data =
      messages
        .reverse()
        .map(
          serializeRoomMessage
        )
        .filter(Boolean);

    return res.status(200).json({
      success: true,
      message:
        "Room messages fetched successfully",
      roomId,
      bookingId,
      messages: data,
      data,
      count: data.length,

      pagination: {
        page,
        limit,
        total,

        totalPages:
          Math.ceil(
            total / limit
          ),

        hasNextPage:
          page * limit <
          total,

        hasPreviousPage:
          page > 1,
      },
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
// MARK ONE MESSAGE AS READ
//
// PATCH /api/chat/read/:messageId
// PUT /api/chat/read/:messageId
// =====================================================

export const markMessageAsRead =
  async (req, res) => {
    try {
      const userId =
        getAuthenticatedUserId(req);

      const messageId =
        normalizeString(
          req.params.messageId
        );

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

      if (
        !messageId ||
        !isValidObjectId(
          messageId
        )
      ) {
        return sendError(
          res,
          400,
          "A valid message ID is required"
        );
      }

      let message =
        await Message.findById(
          messageId
        );

      if (!message) {
        return sendError(
          res,
          404,
          "Message not found"
        );
      }

      const receiverId =
        getDocumentId(
          message.receiverId ||
          message.receiver
        );

      if (
        receiverId !== userId
      ) {
        return sendError(
          res,
          403,
          "Only the receiver can mark this message as read"
        );
      }

      const now = new Date();

      message.isRead = true;
      message.read = true;
      message.readAt =
        message.readAt || now;

      message.delivered = true;
      message.deliveredAt =
        message.deliveredAt ||
        now;

      await message.save();

      message =
        await populateRoomMessageQuery(
          Message.findById(
            message._id
          )
        );

      const data =
        serializeRoomMessage(
          message
        );

      emitReadReceipt(data);

      return res.status(200).json({
        success: true,
        message:
          "Message marked as read",
        chatMessage: data,
        data,
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Mark Message Read Error",
        error
      );
    }
  };

// =====================================================
// MARK ALL ROOM MESSAGES AS READ
//
// PATCH /api/chat/room/:roomId/read
// PUT /api/chat/room/:roomId/read
// =====================================================

export const markRoomMessagesAsRead =
  async (req, res) => {
    try {
      const userId =
        getAuthenticatedUserId(req);

      const role =
        getAuthenticatedUserRole(
          req
        );

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

      const requestedRoomId =
        normalizeString(
          req.params.roomId
        );

      const bookingId =
        extractBookingId(
          requestedRoomId,
          req.body.bookingId ||
          req.query.bookingId
        );

      if (
        !bookingId ||
        !isValidObjectId(
          bookingId
        )
      ) {
        return sendError(
          res,
          400,
          "A valid booking room is required"
        );
      }

      const access =
        await validateBookingChatAccess({
          bookingId,
          currentUserId:
            userId,
          role,
        });

      if (!access.success) {
        return sendError(
          res,
          access.statusCode,
          access.message
        );
      }

      const now = new Date();

      const result =
        await Message.updateMany(
          {
            bookingId,

            receiverId:
              userId,

            isRead: {
              $ne: true,
            },

            deletedAt: null,
          },
          {
            $set: {
              isRead: true,
              read: true,
              readAt: now,
              delivered: true,
              deliveredAt: now,
            },
          }
        );

      const roomId =
        normalizeRoomId(
          access.booking
            .chatRoomId ||
          requestedRoomId ||
          bookingId
        );

      const receipt = {
        roomId,
        bookingId,
        receiverId:
          userId,
        readAt: now,

        modifiedCount:
          result.modifiedCount ||
          0,
      };

      emitSocketEvent(
        [
          roomId,
          `booking:${bookingId}`,

          `user:${
            access.participantData
              .otherUserId
          }`,

          `provider:${
            access.participantData
              .otherUserId
          }`,
        ],
        "roomMessagesRead",
        receipt
      );

      return res.status(200).json({
        success: true,
        message:
          "Room messages marked as read",

        roomId,
        bookingId,

        modifiedCount:
          result.modifiedCount ||
          0,

        data: receipt,
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Mark Room Read Error",
        error
      );
    }
  };

// =====================================================
// GET UNREAD MESSAGE COUNT
//
// GET /api/chat/unread-count
// =====================================================

export const getUnreadMessageCount =
  async (req, res) => {
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

      const bookingId =
        normalizeString(
          req.query.bookingId
        );

      const filter = {
        receiverId:
          userId,

        isRead: {
          $ne: true,
        },

        read: {
          $ne: true,
        },

        deletedForReceiver: {
          $ne: true,
        },

        deletedAt: null,
      };

      if (bookingId) {
        if (
          !isValidObjectId(
            bookingId
          )
        ) {
          return sendError(
            res,
            400,
            "Invalid booking identifier"
          );
        }

        filter.bookingId =
          bookingId;
      }

      const count =
        await Message.countDocuments(
          filter
        );

      return res.status(200).json({
        success: true,
        message:
          "Unread message count fetched successfully",
        count,
        unreadCount: count,

        data: {
          count,
          unreadCount: count,
        },
      });
    } catch (error) {
      return sendControllerError(
        res,
        "Unread Message Count Error",
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
      !isValidObjectId(
        receiverId
      )
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
      message.length > 5000
    ) {
      return sendError(
        res,
        400,
        "Message cannot exceed 5000 characters"
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
          "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
        )
        .populate(
          "receiver",
          "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
        );

    const data =
      serializeDirectMessage(
        populatedChat ||
        chat
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
      chat: data,
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

    const {
      page,
      limit,
      skip,
    } = getPagination(req);

    const filter = {
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
    };

    const [
      total,
      chats,
    ] = await Promise.all([
      Chat.countDocuments(
        filter
      ),

      Chat.find(filter)
        .populate(
          "sender",
          "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
        )
        .populate(
          "receiver",
          "firstName lastName name fullName email phone mobile profileImage role businessName shopName isOnline"
        )
        .sort({
          createdAt: -1,
        })
        .skip(skip)
        .limit(limit),
    ]);

    const data =
      chats
        .reverse()
        .map(
          serializeDirectMessage
        )
        .filter(Boolean);

    return res.status(200).json({
      success: true,
      message:
        "Messages fetched successfully",
      messages: data,
      chats: data,
      data,
      count: data.length,

      pagination: {
        page,
        limit,
        total,

        totalPages:
          Math.ceil(
            total / limit
          ),

        hasNextPage:
          page * limit <
          total,

        hasPreviousPage:
          page > 1,
      },
    });
  } catch (error) {
    return sendControllerError(
      res,
      "Get Messages Error",
      error
    );
  }
};