import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";

import connectDB from "./config/db.js";

// =====================================================
// ROUTES
// =====================================================

import authRoutes from "./routes/authRoutes.js";
import chatRoutes from "./routes/chatRoutes.js";
import serviceRoutes from "./routes/serviceRoutes.js";
import bookingRoutes from "./routes/bookingRoutes.js";
import reviewRoutes from "./routes/reviewRoutes.js";
import addressRoutes from "./routes/addressRoutes.js";
import orderRoutes from "./routes/orderRoutes.js";
import adminRoutes from "./routes/adminRoutes.js";
import cartRoutes from "./routes/cartRoutes.js";
import categoryRoutes from "./routes/categoryRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import providerRoutes from "./routes/providerRoutes.js";

// =====================================================
// ERROR MIDDLEWARE
// =====================================================

import {
  notFound,
  errorHandler,
} from "./middleware/errorMiddleware.js";

// =====================================================
// MODELS
// =====================================================

import Message from "./models/Message.js";

// =====================================================
// ENVIRONMENT
// =====================================================

dotenv.config();

// =====================================================
// EXPRESS AND HTTP SERVER
// =====================================================

const app = express();
const server = http.createServer(app);

const PORT = Number(
  process.env.PORT || 5000
);

// =====================================================
// CORS CONFIGURATION
// =====================================================

const configuredOrigins = (
  process.env.CORS_ORIGINS || ""
)
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

const developmentOriginPrefixes = [
  "http://localhost",
  "http://127.0.0.1",
  "https://localhost",
  "https://127.0.0.1",
];

const isAllowedOrigin = (origin) => {
  // Postman, mobile applications, server-to-server calls,
  // and some development tools may not send an Origin.
  if (!origin) {
    return true;
  }

  const normalizedOrigin =
    origin.toString().trim();

  if (!normalizedOrigin) {
    return true;
  }

  if (
    process.env.NODE_ENV !== "production"
  ) {
    return developmentOriginPrefixes.some(
      (prefix) =>
        normalizedOrigin.startsWith(
          prefix
        )
    );
  }

  return configuredOrigins.includes(
    normalizedOrigin
  );
};

const validateCorsOrigin = (
  origin,
  callback
) => {
  if (isAllowedOrigin(origin)) {
    callback(null, true);
    return;
  }

  callback(
    new Error(
      `CORS blocked request from origin: ${origin}`
    )
  );
};

const corsOptions = {
  origin: validateCorsOrigin,

  methods: [
    "GET",
    "POST",
    "PUT",
    "PATCH",
    "DELETE",
    "OPTIONS",
  ],

  allowedHeaders: [
    "Accept",
    "Authorization",
    "Content-Type",
    "Origin",
    "X-Requested-With",
  ],

  exposedHeaders: [
    "Content-Length",
    "Content-Type",
  ],

  credentials: true,

  optionsSuccessStatus: 204,
};

// =====================================================
// SOCKET.IO
// =====================================================

export const io = new Server(
  server,
  {
    cors: {
      origin: validateCorsOrigin,

      methods: [
        "GET",
        "POST",
        "PUT",
        "PATCH",
        "DELETE",
      ],

      allowedHeaders: [
        "Accept",
        "Authorization",
        "Content-Type",
      ],

      credentials: true,
    },

    transports: [
      "websocket",
      "polling",
    ],

    pingTimeout: 60000,
    pingInterval: 25000,
  }
);

/*
 * BookingController uses global.io after a booking is
 * successfully saved in MongoDB.
 *
 * This avoids circular imports between server.js and
 * bookingController.js.
 */
global.io = io;

// =====================================================
// GLOBAL EXPRESS MIDDLEWARE
// =====================================================

app.disable("x-powered-by");

app.use(
  cors(corsOptions)
);

app.use(
  express.json({
    limit: "10mb",
  })
);

app.use(
  express.urlencoded({
    extended: true,
    limit: "10mb",
  })
);

// =====================================================
// REQUEST LOGGER
// =====================================================

app.use(
  (req, res, next) => {
    const startedAt = Date.now();

    res.on(
      "finish",
      () => {
        const duration =
          Date.now() - startedAt;

        console.log(
          `${req.method} ${req.originalUrl} ` +
            `${res.statusCode} ${duration}ms`
        );
      }
    );

    next();
  }
);

// =====================================================
// ROOT ROUTE
// =====================================================

app.get(
  "/",
  (req, res) => {
    return res.status(200).json({
      success: true,
      message:
        "EventEase Backend and Socket.IO are running",
      environment:
        process.env.NODE_ENV ||
        "development",
      timestamp:
        new Date().toISOString(),
    });
  }
);

// =====================================================
// HEALTH CHECK
// =====================================================

app.get(
  "/api/health",
  (req, res) => {
    return res.status(200).json({
      success: true,
      message:
        "EventEase API is healthy",
      uptime:
        process.uptime(),
      environment:
        process.env.NODE_ENV ||
        "development",
      timestamp:
        new Date().toISOString(),
    });
  }
);

// =====================================================
// API ROUTES
// =====================================================

app.use(
  "/api/auth",
  authRoutes
);

app.use(
  "/api/chat",
  chatRoutes
);

app.use(
  "/api/services",
  serviceRoutes
);

/*
 * Customer booking endpoints:
 *
 * POST /api/bookings
 * GET  /api/bookings/my-bookings
 * GET  /api/bookings/:id
 */
app.use(
  "/api/bookings",
  bookingRoutes
);

app.use(
  "/api/reviews",
  reviewRoutes
);

app.use(
  "/api/address",
  addressRoutes
);

app.use(
  "/api/orders",
  orderRoutes
);

app.use(
  "/api/cart",
  cartRoutes
);

app.use(
  "/api/categories",
  categoryRoutes
);

/*
 * Admin endpoints:
 *
 * GET /api/admin/bookings
 */
app.use(
  "/api/admin",
  adminRoutes
);

app.use(
  "/api/users",
  userRoutes
);

/*
 * Provider endpoints:
 *
 * GET /api/provider/bookings
 * GET /api/provider/bookings/today
 * GET /api/provider/bookings/upcoming
 * GET /api/provider/bookings/analytics
 */
app.use(
  "/api/provider",
  providerRoutes
);

/*
 * Compatibility prefix used by some older clients.
 */
app.use(
  "/api/providers",
  providerRoutes
);

// =====================================================
// SOCKET HELPERS
// =====================================================

const normalizeRoomId = (value) => {
  if (
    value === null ||
    value === undefined
  ) {
    return "";
  }

  return value.toString().trim();
};

const normalizeMessage = (value) => {
  if (
    value === null ||
    value === undefined
  ) {
    return "";
  }

  return value.toString().trim();
};

const joinSocketRoom = (
  socket,
  roomName
) => {
  const normalizedRoomName =
    normalizeRoomId(roomName);

  if (!normalizedRoomName) {
    return false;
  }

  socket.join(
    normalizedRoomName
  );

  console.log(
    `Socket ${socket.id} joined room ${normalizedRoomName}`
  );

  return true;
};

// =====================================================
// SOCKET.IO CONNECTION
// =====================================================

io.on(
  "connection",
  (socket) => {
    console.log(
      "Socket connected:",
      socket.id
    );

    // =================================================
    // CUSTOMER ROOM
    // =================================================

    socket.on(
      "joinUserRoom",
      (userId) => {
        const normalizedUserId =
          normalizeRoomId(userId);

        if (!normalizedUserId) {
          return;
        }

        joinSocketRoom(
          socket,
          `user:${normalizedUserId}`
        );
      }
    );

    // =================================================
    // PROVIDER ROOM
    // =================================================

    socket.on(
      "joinProviderRoom",
      (providerId) => {
        const normalizedProviderId =
          normalizeRoomId(providerId);

        if (!normalizedProviderId) {
          return;
        }

        joinSocketRoom(
          socket,
          `provider:${normalizedProviderId}`
        );
      }
    );

    // =================================================
    // ADMIN ROOM
    // =================================================

    socket.on(
      "joinAdminRoom",
      () => {
        joinSocketRoom(
          socket,
          "admin"
        );
      }
    );

    // =================================================
    // GENERIC CHAT ROOM
    // =================================================

    socket.on(
      "joinRoom",
      (roomId) => {
        joinSocketRoom(
          socket,
          roomId
        );
      }
    );

    // =================================================
    // BOOKING-SPECIFIC ROOM
    // =================================================

    socket.on(
      "joinBookingRoom",
      (bookingId) => {
        const normalizedBookingId =
          normalizeRoomId(bookingId);

        if (!normalizedBookingId) {
          return;
        }

        joinSocketRoom(
          socket,
          normalizedBookingId
        );
      }
    );

    // =================================================
    // LEAVE ROOM
    // =================================================

    socket.on(
      "leaveRoom",
      (roomId) => {
        const normalizedRoomId =
          normalizeRoomId(roomId);

        if (!normalizedRoomId) {
          return;
        }

        socket.leave(
          normalizedRoomId
        );

        console.log(
          `Socket ${socket.id} left room ${normalizedRoomId}`
        );
      }
    );

    // =================================================
    // PROVIDER STATUS
    // =================================================

    socket.on(
      "providerStatusChange",
      (data) => {
        io.emit(
          "providerStatusChanged",
          data
        );

        io.emit(
          "refreshServices",
          data
        );
      }
    );

    // =================================================
    // CHAT MESSAGE
    // =================================================

    socket.on(
      "sendMessage",
      async (
        data,
        acknowledgement
      ) => {
        try {
          const roomId =
            normalizeRoomId(
              data?.roomId ||
                data?.chatRoomId ||
                data?.bookingId
            );

          const message =
            normalizeMessage(
              data?.message ||
                data?.text
            );

          const senderId =
            normalizeRoomId(
              data?.senderId
            );

          const receiverId =
            normalizeRoomId(
              data?.receiverId
            );

          const bookingId =
            normalizeRoomId(
              data?.bookingId
            );

          if (!roomId) {
            const errorResponse = {
              success: false,
              message:
                "Chat room ID is required",
            };

            if (
              typeof acknowledgement ===
              "function"
            ) {
              acknowledgement(
                errorResponse
              );
            }

            socket.emit(
              "messageError",
              errorResponse
            );

            return;
          }

          if (!message) {
            const errorResponse = {
              success: false,
              message:
                "Message cannot be empty",
            };

            if (
              typeof acknowledgement ===
              "function"
            ) {
              acknowledgement(
                errorResponse
              );
            }

            socket.emit(
              "messageError",
              errorResponse
            );

            return;
          }

          const messagePayload = {
            roomId,
            message,
            senderId,
          };

          const schemaPaths =
            Message.schema?.paths || {};

          if (
            schemaPaths.text
          ) {
            messagePayload.text =
              message;
          }

          if (
            bookingId &&
            schemaPaths.bookingId
          ) {
            messagePayload.bookingId =
              bookingId;
          }

          if (
            receiverId &&
            schemaPaths.receiverId
          ) {
            messagePayload.receiverId =
              receiverId;
          }

          if (
            data?.senderRole &&
            schemaPaths.senderRole
          ) {
            messagePayload.senderRole =
              data.senderRole;
          }

          const savedMessage =
            await Message.create(
              messagePayload
            );

          io.to(roomId).emit(
            "receiveMessage",
            savedMessage
          );

          io.to(roomId).emit(
            "newMessage",
            savedMessage
          );

          if (receiverId) {
            io.to(
              `user:${receiverId}`
            ).emit(
              "newMessageNotification",
              savedMessage
            );

            io.to(
              `provider:${receiverId}`
            ).emit(
              "newMessageNotification",
              savedMessage
            );
          }

          if (
            typeof acknowledgement ===
            "function"
          ) {
            acknowledgement({
              success: true,
              message:
                "Message sent successfully",
              data:
                savedMessage,
            });
          }
        } catch (error) {
          console.error(
            "Socket message error:",
            error
          );

          const errorResponse = {
            success: false,
            message:
              error?.message ||
              "Unable to send message",
          };

          if (
            typeof acknowledgement ===
            "function"
          ) {
            acknowledgement(
              errorResponse
            );
          }

          socket.emit(
            "messageError",
            errorResponse
          );
        }
      }
    );

    // =================================================
    // LIVE LOCATION
    // =================================================

    socket.on(
      "updateLocation",
      (data) => {
        const roomId =
          normalizeRoomId(
            data?.roomId ||
              data?.chatRoomId ||
              data?.bookingId
          );

        if (!roomId) {
          return;
        }

        io.to(roomId).emit(
          "liveLocation",
          data
        );

        io.to(roomId).emit(
          "locationUpdated",
          data
        );
      }
    );

    // =================================================
    // CLIENT REFRESH REQUEST
    // =================================================

    socket.on(
      "requestBookingRefresh",
      (data) => {
        io.emit(
          "refreshBookings",
          data || {}
        );
      }
    );

    socket.on(
      "requestServiceRefresh",
      (data) => {
        io.emit(
          "refreshServices",
          data || {}
        );
      }
    );

    // =================================================
    // BOOKING EVENT COMPATIBILITY
    // =================================================
    //
    // Database booking creation must happen through:
    //
    // POST /api/bookings
    //
    // BookingController emits "newBooking" after saving
    // the MongoDB booking. Client-emitted events cannot
    // create bookings.
    // =================================================

    socket.on(
      "bookingStatusChanged",
      (booking) => {
        const bookingId =
          normalizeRoomId(
            booking?._id ||
              booking?.id ||
              booking?.bookingId
          );

        const providerId =
          normalizeRoomId(
            booking?.providerId ||
              booking?.provider?._id ||
              booking?.provider
          );

        const customerId =
          normalizeRoomId(
            booking?.customerId ||
              booking?.customer?._id ||
              booking?.user?._id ||
              booking?.user
          );

        const status =
          normalizeRoomId(
            booking?.status ||
              booking?.bookingStatus
          );

        io.emit(
          "bookingUpdate",
          booking
        );

        io.emit(
          "bookingUpdated",
          booking
        );

        io.emit(
          "refreshBookings",
          {
            bookingId,
            providerId,
            customerId,
            status,
          }
        );

        if (providerId) {
          io.to(
            `provider:${providerId}`
          ).emit(
            "bookingUpdated",
            booking
          );
        }

        if (customerId) {
          io.to(
            `user:${customerId}`
          ).emit(
            "bookingUpdated",
            booking
          );
        }

        io.to("admin").emit(
          "refreshAdminBookings",
          {
            bookingId,
            providerId,
            customerId,
            status,
          }
        );

        if (bookingId) {
          io.to(bookingId).emit(
            "bookingUpdate",
            booking
          );
        }
      }
    );

    // =================================================
    // SOCKET ERROR
    // =================================================

    socket.on(
      "error",
      (error) => {
        console.error(
          `Socket error for ${socket.id}:`,
          error
        );
      }
    );

    // =================================================
    // DISCONNECT
    // =================================================

    socket.on(
      "disconnect",
      (reason) => {
        console.log(
          `Socket disconnected: ${socket.id}; reason: ${reason}`
        );
      }
    );
  }
);

// =====================================================
// EXPRESS ERROR HANDLERS
// =====================================================
//
// These must remain after every API route.
// =====================================================

app.use(notFound);
app.use(errorHandler);

// =====================================================
// PROCESS ERROR LOGGING
// =====================================================

process.on(
  "unhandledRejection",
  (reason) => {
    console.error(
      "Unhandled Promise Rejection:",
      reason
    );
  }
);

process.on(
  "uncaughtException",
  (error) => {
    console.error(
      "Uncaught Exception:",
      error
    );
  }
);

// =====================================================
// START SERVER
// =====================================================

const startServer = async () => {
  try {
    await connectDB();

    server.listen(
      PORT,
      () => {
        console.log(
          "MongoDB connection established"
        );

        console.log(
          `EventEase server running on port ${PORT}`
        );

        console.log(
          `API URL: http://localhost:${PORT}/api`
        );

        console.log(
          `Health: http://localhost:${PORT}/api/health`
        );

        console.log(
          `Environment: ${
            process.env.NODE_ENV ||
            "development"
          }`
        );
      }
    );
  } catch (error) {
    console.error(
      "Unable to start EventEase server:",
      error
    );

    process.exit(1);
  }
};

startServer();

export {
  app,
  server,
};