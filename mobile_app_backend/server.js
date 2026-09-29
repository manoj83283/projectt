import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";

import connectDB from "./config/db.js";

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

import {
  notFound,
  errorHandler,
} from "./middleware/errorMiddleware.js";

import Message from "./models/Message.js";

dotenv.config();

const app = express();
const server = http.createServer(app);

const PORT = Number(
  process.env.PORT || 5000
);

const NODE_ENV =
  process.env.NODE_ENV || "development";

// =====================================================
// CORS
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
  if (!origin) {
    return true;
  }

  const normalizedOrigin =
    origin.toString().trim();

  if (!normalizedOrigin) {
    return true;
  }

  if (NODE_ENV !== "production") {
    return developmentOriginPrefixes.some(
      (prefix) =>
        normalizedOrigin.startsWith(prefix)
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
    "Cache-Control",
    "Pragma",
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
        "Cache-Control",
        "Pragma",
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

global.io = io;

// =====================================================
// EXPRESS CONFIGURATION
// =====================================================

app.disable("x-powered-by");
app.disable("etag");

app.use(
  cors(corsOptions)
);

app.options(
  /.*/,
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
// DISABLE API CACHING
// =====================================================

app.use(
  "/api",
  (req, res, next) => {
    res.setHeader(
      "Cache-Control",
      "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0"
    );

    res.setHeader(
      "Pragma",
      "no-cache"
    );

    res.setHeader(
      "Expires",
      "0"
    );

    res.setHeader(
      "Surrogate-Control",
      "no-store"
    );

    res.removeHeader("ETag");

    next();
  }
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
          `${req.method} ${req.originalUrl} ${res.statusCode} ${duration}ms`
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
      environment: NODE_ENV,
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
      environment: NODE_ENV,
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
  "/api/admin",
  adminRoutes
);

app.use(
  "/api/cart",
  cartRoutes
);

app.use(
  "/api/categories",
  categoryRoutes
);

app.use(
  "/api/users",
  userRoutes
);

app.use(
  "/api/provider",
  providerRoutes
);

app.use(
  "/api/providers",
  providerRoutes
);
const validateEnvironment = () => {
  const requiredVariables = [
    "MONGO_URI",
    "JWT_SECRET",
    "OTP_SECRET",
  ];

  const missingVariables =
    requiredVariables.filter(
      (key) =>
        !process.env[key]?.trim()
    );

  if (missingVariables.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missingVariables.join(", ")}`
    );
  }

  if (
    process.env.NODE_ENV ===
      "production" &&
    process.env.OTP_SECRET.length < 32
  ) {
    throw new Error(
      "OTP_SECRET must contain at least 32 characters in production"
    );
  }
};
// =====================================================
// SOCKET HELPERS
// =====================================================

const normalizeValue = (value) => {
  if (
    value === null ||
    value === undefined
  ) {
    return "";
  }

  return value.toString().trim();
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

const joinRoom = (
  socket,
  roomName
) => {
  const normalizedRoom =
    normalizeValue(roomName);

  if (!normalizedRoom) {
    return false;
  }

  socket.join(normalizedRoom);

  console.log(
    `Socket ${socket.id} joined room ${normalizedRoom}`
  );

  return true;
};

const leaveRoom = (
  socket,
  roomName
) => {
  const normalizedRoom =
    normalizeValue(roomName);

  if (!normalizedRoom) {
    return false;
  }

  socket.leave(normalizedRoom);

  console.log(
    `Socket ${socket.id} left room ${normalizedRoom}`
  );

  return true;
};

const sendAcknowledgement = (
  acknowledgement,
  response
) => {
  if (
    typeof acknowledgement ===
    "function"
  ) {
    acknowledgement(response);
  }
};

const getBookingSocketData = (
  booking
) => {
  const bookingId =
    getDocumentId(
      booking?._id ||
      booking?.id ||
      booking?.bookingId
    );

  const providerId =
    getDocumentId(
      booking?.providerId ||
      booking?.provider
    );

  const customerId =
    getDocumentId(
      booking?.customerId ||
      booking?.customer ||
      booking?.user
    );

  const status =
    normalizeValue(
      booking?.status ||
      booking?.bookingStatus
    );

  return {
    bookingId,
    providerId,
    customerId,
    status,
    otpVerified:
      booking?.otpVerified === true,
    updatedAt:
      booking?.updatedAt ||
      new Date().toISOString(),
  };
};

const emitBookingRefresh = (
  booking
) => {
  if (!booking) {
    return;
  }

  const refreshPayload =
    getBookingSocketData(booking);

  const {
    bookingId,
    providerId,
    customerId,
  } = refreshPayload;

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
    refreshPayload
  );

  if (providerId) {
    const providerRoom =
      `provider:${providerId}`;

    io.to(providerRoom).emit(
      "bookingUpdated",
      booking
    );

    io.to(providerRoom).emit(
      "refreshProviderBookings",
      refreshPayload
    );

    io.to(providerRoom).emit(
      "refreshProviderOrders",
      refreshPayload
    );

    io.to(providerRoom).emit(
      "refreshProviderDashboard",
      refreshPayload
    );

    io.to(providerRoom).emit(
      "refreshProviderEarnings",
      refreshPayload
    );
  }

  if (customerId) {
    const customerRoom =
      `user:${customerId}`;

    io.to(customerRoom).emit(
      "bookingUpdate",
      booking
    );

    io.to(customerRoom).emit(
      "bookingUpdated",
      booking
    );

    io.to(customerRoom).emit(
      "refreshCustomerBookings",
      refreshPayload
    );
  }

  io.to("admin").emit(
    "bookingUpdated",
    booking
  );

  io.to("admin").emit(
    "refreshAdminBookings",
    refreshPayload
  );

  io.to("admin").emit(
    "refreshAdminDashboard",
    refreshPayload
  );

  if (bookingId) {
    io.to(bookingId).emit(
      "bookingUpdate",
      booking
    );

    io.to(
      `booking:${bookingId}`
    ).emit(
      "bookingUpdate",
      booking
    );

    io.to(
      `booking:${bookingId}`
    ).emit(
      "bookingUpdated",
      booking
    );
  }

  const chatRoomId =
    normalizeValue(
      booking.chatRoomId
    );

  if (
    chatRoomId &&
    chatRoomId !== bookingId
  ) {
    io.to(chatRoomId).emit(
      "bookingUpdate",
      booking
    );
  }
};

// =====================================================
// SOCKET CONNECTION
// =====================================================

io.on(
  "connection",
  (socket) => {
    console.log(
      "Socket connected:",
      socket.id
    );

    socket.on(
      "registerUser",
      (userId) => {
        const normalizedUserId =
          normalizeValue(userId);

        if (!normalizedUserId) {
          return;
        }

        socket.data.userId =
          normalizedUserId;

        joinRoom(
          socket,
          `user:${normalizedUserId}`
        );
      }
    );

    socket.on(
      "joinUserRoom",
      (userId) => {
        const normalizedUserId =
          normalizeValue(userId);

        if (!normalizedUserId) {
          return;
        }

        socket.data.userId =
          normalizedUserId;

        joinRoom(
          socket,
          `user:${normalizedUserId}`
        );
      }
    );

    socket.on(
      "registerProvider",
      (providerId) => {
        const normalizedProviderId =
          normalizeValue(providerId);

        if (!normalizedProviderId) {
          return;
        }

        socket.data.providerId =
          normalizedProviderId;

        joinRoom(
          socket,
          `provider:${normalizedProviderId}`
        );
      }
    );

    socket.on(
      "joinProviderRoom",
      (providerId) => {
        const normalizedProviderId =
          normalizeValue(providerId);

        if (!normalizedProviderId) {
          return;
        }

        socket.data.providerId =
          normalizedProviderId;

        joinRoom(
          socket,
          `provider:${normalizedProviderId}`
        );
      }
    );

    socket.on(
      "joinAdminRoom",
      () => {
        socket.data.isAdmin = true;

        joinRoom(
          socket,
          "admin"
        );
      }
    );

    socket.on(
      "joinRoom",
      (roomId) => {
        joinRoom(
          socket,
          roomId
        );
      }
    );

    socket.on(
      "joinBookingRoom",
      (bookingId) => {
        const normalizedBookingId =
          normalizeValue(bookingId);

        if (!normalizedBookingId) {
          return;
        }

        joinRoom(
          socket,
          normalizedBookingId
        );

        joinRoom(
          socket,
          `booking:${normalizedBookingId}`
        );
      }
    );

    socket.on(
      "leaveRoom",
      (roomId) => {
        leaveRoom(
          socket,
          roomId
        );
      }
    );

    socket.on(
      "leaveBookingRoom",
      (bookingId) => {
        const normalizedBookingId =
          normalizeValue(bookingId);

        if (!normalizedBookingId) {
          return;
        }

        leaveRoom(
          socket,
          normalizedBookingId
        );

        leaveRoom(
          socket,
          `booking:${normalizedBookingId}`
        );
      }
    );

    // =================================================
    // PROVIDER AVAILABILITY
    // =================================================

    socket.on(
      "providerStatusChange",
      (data) => {
        const providerId =
          getDocumentId(
            data?.providerId ||
            data?.provider
          );

        if (providerId) {
          io.to(
            `provider:${providerId}`
          ).emit(
            "providerStatusChanged",
            data
          );
        }

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
          const bookingId =
            normalizeValue(
              data?.bookingId
            );

          const roomId =
            normalizeValue(
              data?.roomId ||
              data?.chatRoomId ||
              (
                bookingId
                  ? `booking:${bookingId}`
                  : ""
              )
            );

          const message =
            normalizeValue(
              data?.message ||
              data?.text ||
              data?.content
            );

          const senderId =
            normalizeValue(
              data?.senderId
            );

          const receiverId =
            normalizeValue(
              data?.receiverId
            );

          if (!roomId) {
            const response = {
              success: false,
              message:
                "Chat room ID is required",
            };

            sendAcknowledgement(
              acknowledgement,
              response
            );

            socket.emit(
              "messageError",
              response
            );

            return;
          }

          if (!message) {
            const response = {
              success: false,
              message:
                "Message cannot be empty",
            };

            sendAcknowledgement(
              acknowledgement,
              response
            );

            socket.emit(
              "messageError",
              response
            );

            return;
          }

          if (!senderId) {
            const response = {
              success: false,
              message:
                "Message sender ID is required",
            };

            sendAcknowledgement(
              acknowledgement,
              response
            );

            socket.emit(
              "messageError",
              response
            );

            return;
          }

          const schemaPaths =
            Message.schema?.paths || {};

          const candidatePayload = {
            roomId,
            bookingId,
            senderId,
            receiverId,
            sender: senderId,
            receiver: receiverId,
            message,
            text: message,
            content: message,
            senderRole:
              data?.senderRole,
            messageType:
              data?.messageType ||
              "text",
            isRead: false,
            read: false,
          };

          const messagePayload = {};

          for (
            const [
              key,
              value,
            ] of Object.entries(
              candidatePayload
            )
          ) {
            if (
              schemaPaths[key] &&
              value !== undefined &&
              value !== null &&
              value !== ""
            ) {
              messagePayload[key] =
                value;
            }
          }

          if (
            Object.keys(
              messagePayload
            ).length === 0
          ) {
            throw new Error(
              "Message model has no compatible fields"
            );
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

          if (bookingId) {
            io.to(
              `booking:${bookingId}`
            ).emit(
              "newMessage",
              savedMessage
            );
          }

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

          sendAcknowledgement(
            acknowledgement,
            {
              success: true,
              message:
                "Message sent successfully",
              data:
                savedMessage,
            }
          );
        } catch (error) {
          console.error(
            "Socket message error:",
            error
          );

          const response = {
            success: false,
            message:
              error?.message ||
              "Unable to send message",
          };

          sendAcknowledgement(
            acknowledgement,
            response
          );

          socket.emit(
            "messageError",
            response
          );
        }
      }
    );

    // =================================================
    // MESSAGE READ STATUS
    // =================================================

    socket.on(
      "messageRead",
      (data) => {
        const roomId =
          normalizeValue(
            data?.roomId ||
            data?.chatRoomId ||
            (
              data?.bookingId
                ? `booking:${data.bookingId}`
                : ""
            )
          );

        if (!roomId) {
          return;
        }

        socket.to(roomId).emit(
          "messageRead",
          data
        );
      }
    );

    // =================================================
    // TYPING EVENTS
    // =================================================

    socket.on(
      "typingStarted",
      (data) => {
        const roomId =
          normalizeValue(
            data?.roomId ||
            data?.chatRoomId ||
            (
              data?.bookingId
                ? `booking:${data.bookingId}`
                : ""
            )
          );

        if (!roomId) {
          return;
        }

        socket.to(roomId).emit(
          "typingStarted",
          data
        );
      }
    );

    socket.on(
      "typingStopped",
      (data) => {
        const roomId =
          normalizeValue(
            data?.roomId ||
            data?.chatRoomId ||
            (
              data?.bookingId
                ? `booking:${data.bookingId}`
                : ""
            )
          );

        if (!roomId) {
          return;
        }

        socket.to(roomId).emit(
          "typingStopped",
          data
        );
      }
    );

    // =================================================
    // LIVE LOCATION
    // =================================================

    socket.on(
      "updateLocation",
      (data) => {
        const bookingId =
          normalizeValue(
            data?.bookingId
          );

        const roomId =
          normalizeValue(
            data?.roomId ||
            data?.chatRoomId ||
            (
              bookingId
                ? `booking:${bookingId}`
                : ""
            )
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
    // CLIENT REFRESH REQUESTS
    // =================================================

    socket.on(
      "requestBookingRefresh",
      (data) => {
        const providerId =
          getDocumentId(
            data?.providerId ||
            data?.provider
          );

        const customerId =
          getDocumentId(
            data?.customerId ||
            data?.customer ||
            data?.user
          );

        if (providerId) {
          const providerRoom =
            `provider:${providerId}`;

          io.to(providerRoom).emit(
            "refreshProviderBookings",
            data || {}
          );

          io.to(providerRoom).emit(
            "refreshProviderOrders",
            data || {}
          );

          io.to(providerRoom).emit(
            "refreshProviderDashboard",
            data || {}
          );

          io.to(providerRoom).emit(
            "refreshProviderEarnings",
            data || {}
          );
        }

        if (customerId) {
          io.to(
            `user:${customerId}`
          ).emit(
            "refreshCustomerBookings",
            data || {}
          );
        }

        io.to("admin").emit(
          "refreshAdminBookings",
          data || {}
        );

        io.to("admin").emit(
          "refreshAdminDashboard",
          data || {}
        );
      }
    );

    socket.on(
      "requestDashboardRefresh",
      (data) => {
        const providerId =
          getDocumentId(
            data?.providerId ||
            data?.provider
          );

        if (providerId) {
          io.to(
            `provider:${providerId}`
          ).emit(
            "refreshProviderDashboard",
            data || {}
          );
        }

        io.to("admin").emit(
          "refreshAdminDashboard",
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
    //
    // These events only refresh clients.
    // Booking status must be changed through REST APIs.
    // =================================================

    socket.on(
      "bookingStatusChanged",
      (booking) => {
        emitBookingRefresh(
          booking
        );
      }
    );

    socket.on(
      "bookingChanged",
      (booking) => {
        emitBookingRefresh(
          booking
        );
      }
    );

    // =================================================
    // SOCKET ERROR AND DISCONNECT
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
// ERROR HANDLERS
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
// GRACEFUL SHUTDOWN
// =====================================================

let isShuttingDown = false;

const shutdownServer = (
  signal
) => {
  if (isShuttingDown) {
    return;
  }

  isShuttingDown = true;

  console.log(
    `${signal} received. Shutting down EventEase server.`
  );

  io.close();

  server.close(
    () => {
      console.log(
        "EventEase server stopped"
      );

      process.exit(0);
    }
  );

  setTimeout(
    () => {
      console.error(
        "Forced shutdown after timeout"
      );

      process.exit(1);
    },
    10000
  ).unref();
};

process.on(
  "SIGINT",
  () => shutdownServer("SIGINT")
);

process.on(
  "SIGTERM",
  () => shutdownServer("SIGTERM")
);

// =====================================================
// START SERVER
// =====================================================

const startServer = async () => {
  try {
    validateEnvironment();
    await connectDB();

    server.on(
      "error",
      (error) => {
        if (
          error?.code === "EADDRINUSE"
        ) {
          console.error(
            `Port ${PORT} is already in use`
          );

          process.exit(1);
        }

        console.error(
          "HTTP server error:",
          error
        );
      }
    );

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
          `Environment: ${NODE_ENV}`
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