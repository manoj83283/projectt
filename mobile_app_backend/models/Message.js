import mongoose from "mongoose";

const { Schema } = mongoose;

const messageSchema = new Schema(
  {
    // =====================================================
    // BOOKING
    // =====================================================

    bookingId: {
      type: Schema.Types.ObjectId,
      ref: "Booking",
      required: true,
      index: true,
    },

    // =====================================================
    // CHAT ROOM
    // =====================================================

    roomId: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },

    // =====================================================
    // USERS
    // =====================================================

    senderId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    receiverId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    sender: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    receiver: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    // =====================================================
    // MESSAGE
    // =====================================================

    message: {
      type: String,
      required: true,
      trim: true,
      maxlength: 5000,
    },

    text: {
      type: String,
      trim: true,
      default: "",
    },

    content: {
      type: String,
      trim: true,
      default: "",
    },

    messageType: {
      type: String,
      enum: [
        "text",
        "image",
        "location",
        "system",
      ],
      default: "text",
      lowercase: true,
    },

    // =====================================================
    // ROLE
    // =====================================================

    senderRole: {
      type: String,
      enum: [
        "customer",
        "provider",
        "admin",
      ],
      default: "customer",
      lowercase: true,
    },

    // =====================================================
    // READ STATUS
    // =====================================================

    isRead: {
      type: Boolean,
      default: false,
      index: true,
    },

    read: {
      type: Boolean,
      default: false,
    },

    readAt: {
      type: Date,
      default: null,
    },

    // =====================================================
    // DELIVERY STATUS
    // =====================================================

    delivered: {
      type: Boolean,
      default: false,
    },

    deliveredAt: {
      type: Date,
      default: null,
    },

    // =====================================================
    // DELETE
    // =====================================================

    deletedForSender: {
      type: Boolean,
      default: false,
    },

    deletedForReceiver: {
      type: Boolean,
      default: false,
    },

    deletedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,

    toJSON: {
      virtuals: true,
    },

    toObject: {
      virtuals: true,
    },
  }
);

// =====================================================
// VIRTUALS
// =====================================================

messageSchema
  .virtual("id")
  .get(function getId() {
    return this._id.toString();
  });

// =====================================================
// NORMALIZATION
// =====================================================

messageSchema.pre(
  "validate",
  function normalizeMessage(
    next
  ) {
    try {
      this.roomId =
        this.roomId?.toString().trim() ||
        "";

      this.message =
        this.message
          ?.toString()
          .trim() || "";

      if (!this.text) {
        this.text = this.message;
      }

      if (!this.content) {
        this.content = this.message;
      }

      if (!this.sender && this.senderId) {
        this.sender = this.senderId;
      }

      if (
        !this.receiver &&
        this.receiverId
      ) {
        this.receiver =
          this.receiverId;
      }

      return next();
    } catch (error) {
      return next(error);
    }
  }
);

// =====================================================
// INDEXES
// =====================================================

messageSchema.index({
  bookingId: 1,
  createdAt: -1,
});

messageSchema.index({
  roomId: 1,
  createdAt: -1,
});

messageSchema.index({
  senderId: 1,
  receiverId: 1,
  createdAt: -1,
});

messageSchema.index({
  receiverId: 1,
  isRead: 1,
});

messageSchema.index({
  bookingId: 1,
  roomId: 1,
  createdAt: -1,
});

// =====================================================
// MODEL
// =====================================================

const Message =
  mongoose.models.Message ||
  mongoose.model(
    "Message",
    messageSchema
  );

export default Message;