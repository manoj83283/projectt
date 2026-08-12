import Booking from "../models/Booking.js";
import Service from "../models/service.js";
import { io } from "../server.js";
import { sendNotification } from "../utils/notification.js";
import Notification from "../models/Notification.js";

// =======================================================
// ✅ CREATE BOOKING
// =======================================================
export const createBooking = async (req, res) => {
  try {
    const {
      serviceId,
      date,
      notes,
      address,
      location,
      hoursBooked = 1,
      paymentMethod = "COD",
    } = req.body;

    const service = await Service.findById(serviceId).populate("provider");

    if (!service || !service.isActive) {
      return res.status(400).json({
        message: "Service provider not available",
      });
    }

    const pricePerHour = service.price || 0;
    const totalPrice = pricePerHour * hoursBooked;

    const chatRoomId = `${req.user.id}_${service.provider._id}`;

    const booking = await Booking.create({
      user: req.user.id,
      service: serviceId,
      provider: service.provider._id,
      date,
      notes,
      address,
      location,
      hoursBooked,
      pricePerHour,
      totalPrice,
      paymentMethod,
      paymentStatus: "pending",
      status: "pending",
      chatRoomId,
    });

    /// ✅ NEW BOOKING NOTIFICATION
    try {
      const provider = service.provider;

      if (provider?.fcmToken) {
        await sendNotification(
          provider.fcmToken,
          "New Order 📦",
          "You received a new booking!"
        );
      }
    } catch (err) {
      console.log("❌ Notification error:", err.message);
    }

    global.io.emit("refreshServices");

    const populatedBooking = await Booking.findById(booking._id)
      .populate("user")
      .populate({
        path: "service",
        populate: { path: "provider" },
      });

    io.emit("newBooking", populatedBooking);
    io.emit("refreshBookings", {
      bookingId: populatedBooking._id,
    });
    io.emit("refreshServices");
    if (global.io) {
      global.io.emit("refreshServices");
    }

    io.to(chatRoomId).emit("bookingUpdate", populatedBooking);

    res.status(201).json(populatedBooking);

  } catch (err) {
    console.error("❌ Create Booking Error:", err);
    res.status(500).json({ message: err.message });
  }
};

// =======================================================
// ✅ GET MY BOOKINGS ✅ (FIX FOR YOUR ERROR)
// =======================================================
export const getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({
      user: req.user.id,
    })
      .populate("service")
      .populate("user", "firstName lastName")
      .sort({ createdAt: -1 });

    res.json(bookings);

  } catch (err) {
    console.error("❌ Get My Bookings Error:", err);
    res.status(500).json({ message: err.message });
  }
};
  export const rateBooking = async (req, res) => {
    try {
      const { rating, review } = req.body;
      let booking = await Booking.findById(req.params.id);
      if (!booking) {
        return res.status(404).json({
          message: "Booking not found",
        });
      }
      if (booking.status !== "completed") {
        return res.status(400).json({
          message: "You can only rate completed bookings",
        });
      }
      if (booking.rating) {
        return res.status(400).json({
          message: "Already rated",
        });
      }
      booking.rating = rating;
      booking.review = review;
      await booking.save();
      res.json({
        message: "✅ Rating submitted successfully",
        booking,
      });
    } catch (err) {
      console.error("❌ Rating Error:", err);
      res.status(500).json({ message: err.message });
    }
  };


// =======================================================
// ✅ UPDATE BOOKING STATUS
// =======================================================
export const updateBookingStatus = async (req, res) => {
  try {
    const { status } = req.body;

    let booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        message: "Booking not found",
      });
    }

    booking.status = status;

    if (status === "accepted") booking.acceptedAt = new Date();
    if (status === "in_progress") booking.startedAt = new Date();
    if (status === "completed") {
      booking.completedAt = new Date();
      booking.paymentStatus = "paid";
    }

    await booking.save();

    booking = await Booking.findById(booking._id)
      .populate("user")
      .populate("service");

    /// ✅ STATUS NOTIFICATION
    try {
      const user = booking.user;

      if (user?.fcmToken) {
        await sendNotification(
          user.fcmToken,
          "Booking Update",
          `Your booking is ${status}`
        );
      }
    } catch (err) {
      console.log("❌ Status notification error:", err.message);
    }

    /// ✅ TRACKING NOTIFICATION
    if (status === "in_progress") {
      try {
        const user = booking.user;

        if (user?.fcmToken) {
          await sendNotification(
            user.fcmToken,
            "Provider is moving 🚗",
            "Live tracking started"
          );
        }
      } catch (err) {
        console.log("❌ Tracking notification error:", err.message);
      }
    }

    io.emit("bookingUpdate", booking);

    if (booking.chatRoomId) {
      io.to(booking.chatRoomId).emit("bookingUpdate", booking);
    }
    io.emit("bookingUpdated", booking);
    io.emit("refreshBookings", {
      bookingId: booking._id,
      status: booking.status,
    });
    io.emit("refreshServices");
    if (global.io) {
      global.io.emit("refreshServices");
    }
    //global.io.emit("refreshServices");

    res.json(booking);

  } catch (err) {
    console.error("❌ Update Booking Error:", err);
    res.status(500).json({ message: err.message });
  }
};

// =======================================================
// ✅ CHAT MESSAGE NOTIFICATION
// =======================================================
export const sendMessageNotification = async (receiver, message) => {
  try {
    if (receiver?.fcmToken) {
      await sendNotification(
        receiver.fcmToken,
        "New Message 💬",
        message
      );
    }
  } catch (err) {
    console.log("❌ Chat notification error:", err.message);
  }
};

// =======================================================
// ✅ GET BOOKINGS (LEGACY / OPTIONAL)
// =======================================================
export const getBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.user.id })
      .populate("service")
      .sort({ createdAt: -1 });

    res.json(bookings);

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// =======================================================
// ✅ PROVIDER BOOKINGS
// =======================================================
export const getProviderBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ provider: req.user.id })
      .populate("user")
      .populate("service")
      .sort({ createdAt: -1 });

    res.json(bookings);

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// =======================================================
// ✅ CANCEL BOOKING
// =======================================================
export const cancelBooking = async (req, res) => {
  try {
    let booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({ message: "Booking not found" });
    }

    booking.status = "cancelled";
    booking.cancelledAt = new Date();

    await booking.save();

    io.emit("bookingUpdate", booking);
    io.emit("bookingUpdated", booking);
    io.emit("refreshBookings", {
      bookingId: booking._id,
      status: booking.status,
    });
    io.emit("refreshServices");
    if (global.io) {
      global.io.emit("refreshServices");
    }
    res.json(booking);

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};