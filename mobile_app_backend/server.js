import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";

import connectDB from "./config/db.js";

// ROUTES
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

// OPTIONAL (only if files exist)
import userRoutes from "./routes/userRoutes.js";
import providerRoutes from "./routes/providerRoutes.js";

// MIDDLEWARE
import {
  notFound,
  errorHandler,
} from "./middleware/errorMiddleware.js";

// MODELS
import Message from "./models/Message.js";

dotenv.config();

connectDB();

const app = express();
const server = http.createServer(app);

// =====================================================
// SOCKET.IO
// =====================================================

export const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"],
  },
});

global.io = io;

// =====================================================
// MIDDLEWARE
// =====================================================

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// =====================================================
// ROOT
// =====================================================

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Backend + Socket.IO Running",
  });
});

// =====================================================
// ROUTES
// =====================================================

app.use("/api/auth", authRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/services", serviceRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/reviews", reviewRoutes);
app.use("/api/address", addressRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/admin", adminRoutes);

// Optional routes
app.use("/api/users", userRoutes);
app.use("/api/provider", providerRoutes);
app.use("/api/providers", providerRoutes);

// =====================================================
// SOCKET EVENTS
// =====================================================

io.on("connection", (socket) => {
  console.log("✅ User connected:", socket.id);

  socket.on("joinRoom", (roomId) => {
    socket.join(roomId);
    console.log("📦 Joined room:", roomId);
  });

  socket.on("providerStatusChange", () => {
    io.emit("refreshServices");
  });

  socket.on("sendMessage", async (data) => {
    try {
      const { roomId, message, senderId } = data;

      if (!roomId || !message) return;

      const savedMessage =
        await Message.create({
          roomId,
          message,
          senderId,
        });

      io.to(roomId).emit(
        "receiveMessage",
        savedMessage
      );
    } catch (error) {
      console.error(
        "Message Error:",
        error.message
      );
    }
  });

  socket.on("updateLocation", (data) => {
    io.to(data.roomId).emit(
      "liveLocation",
      data
    );
  });

  socket.on("newBooking", (booking) => {
    io.emit("bookingUpdate", booking);
    io.emit("refreshServices");
  });

  socket.on(
    "bookingStatusChanged",
    (booking) => {
      io.emit("bookingUpdate", booking);

      if (booking?.chatRoomId) {
        io.to(
          booking.chatRoomId
        ).emit(
          "bookingUpdate",
          booking
        );
      }

      io.emit("refreshServices");
    }
  );

  socket.on("disconnect", () => {
    console.log(
      "❌ User disconnected:",
      socket.id
    );
  });
});

// =====================================================
// ERROR HANDLERS
// =====================================================

app.use(notFound);
app.use(errorHandler);

// =====================================================
// START SERVER
// =====================================================

const PORT =
  process.env.PORT || 5000;

server.listen(PORT, () => {
  console.log(
    `🚀 Server running on port ${PORT}`
  );
});