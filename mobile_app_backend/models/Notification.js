import mongoose from "mongoose";

const notificationSchema = new mongoose.Schema(
  {
    // =====================================================
    // RECEIVER
    // =====================================================
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    // =====================================================
    // SENDER (OPTIONAL)
    // =====================================================
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    // =====================================================
    // TITLE
    // =====================================================
    title: {
      type: String,
      required: true,
      trim: true,
    },

    // =====================================================
    // MESSAGE
    // =====================================================
    message: {
      type: String,
      required: true,
      trim: true,
    },

    // =====================================================
    // TYPE
    // =====================================================
    type: {
      type: String,
      enum: [
        "booking",
        "order",
        "service",
        "payment",
        "review",
        "chat",
        "system",
        "promotion",
        "admin",
      ],
      default: "system",
    },

    // =====================================================
    // RELATED RECORDS
    // =====================================================
    bookingId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Booking",
      default: null,
    },

    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      default: null,
    },

    serviceId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
      default: null,
    },

    reviewId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Review",
      default: null,
    },

    // =====================================================
    // FCM
    // =====================================================
    fcmToken: {
      type: String,
      default: "",
    },

    // =====================================================
    // ACTION URL / SCREEN
    // =====================================================
    action: {
      type: String,
      default: "",
    },

    // Example:
    // booking_details
    // order_details
    // service_details

    // =====================================================
    // PAYLOAD
    // =====================================================
    data: {
      type: Object,
      default: {},
    },

    // =====================================================
    // STATUS
    // =====================================================
    isRead: {
      type: Boolean,
      default: false,
    },

    readAt: {
      type: Date,
      default: null,
    },

    // =====================================================
    // SOFT DELETE
    // =====================================================
    isDeleted: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// =====================================================
// INDEXES
// =====================================================

notificationSchema.index({
  user: 1,
  createdAt: -1,
});

notificationSchema.index({
  isRead: 1,
});

notificationSchema.index({
  type: 1,
});

// =====================================================
// INSTANCE METHODS
// =====================================================

notificationSchema.methods.markAsRead =
  async function () {
    this.isRead = true;
    this.readAt = new Date();

    return await this.save();
  };

// =====================================================
// MODEL
// =====================================================

const Notification = mongoose.model(
  "Notification",
  notificationSchema
);

export default Notification;