import mongoose from "mongoose";

const { Schema } = mongoose;

// =====================================================
// CONSTANTS
// =====================================================

export const MESSAGE_TYPES =
  Object.freeze({
    TEXT: "text",
    IMAGE: "image",
    FILE: "file",
    LOCATION: "location",
    SYSTEM: "system",
  });

export const MESSAGE_SENDER_ROLES =
  Object.freeze([
    "user",
    "customer",
    "provider",
    "admin",
    "system",
  ]);

// =====================================================
// MESSAGE SCHEMA
// =====================================================

const messageSchema = new Schema(
  {
    // =================================================
    // BOOKING CHAT
    // =================================================

    bookingId: {
      type: Schema.Types.ObjectId,
      ref: "Booking",
      required: [
        true,
        "Booking ID is required",
      ],
      index: true,
    },

    roomId: {
      type: String,
      trim: true,
      required: [
        true,
        "Chat room ID is required",
      ],
      index: true,
    },

    // =================================================
    // PARTICIPANTS
    // =================================================

    senderId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [
        true,
        "Message sender is required",
      ],
      index: true,
    },

    receiverId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [
        true,
        "Message receiver is required",
      ],
      index: true,
    },

    /*
     * Compatibility fields used by older code and
     * populateRoomMessageQuery().
     */
    sender: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
      index: true,
    },

    receiver: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
      index: true,
    },

    senderRole: {
      type: String,
      enum: {
        values:
          MESSAGE_SENDER_ROLES,
        message:
          "Invalid message sender role",
      },
      trim: true,
      lowercase: true,
      default: "user",
    },

    // =================================================
    // MESSAGE CONTENT
    // =================================================

    message: {
      type: String,
      trim: true,
      required: [
        true,
        "Message is required",
      ],
      maxlength: [
        5000,
        "Message cannot exceed 5000 characters",
      ],
    },

    /*
     * Compatibility fields. These allow Customer and
     * Provider applications to read message, text, or
     * content without losing older chat data.
     */
    text: {
      type: String,
      trim: true,
      default: "",
      maxlength: [
        5000,
        "Message text cannot exceed 5000 characters",
      ],
    },

    content: {
      type: String,
      trim: true,
      default: "",
      maxlength: [
        5000,
        "Message content cannot exceed 5000 characters",
      ],
    },

    messageType: {
      type: String,
      enum: {
        values:
          Object.values(
            MESSAGE_TYPES
          ),
        message:
          "Invalid message type",
      },
      trim: true,
      lowercase: true,
      default:
        MESSAGE_TYPES.TEXT,
    },

    // =================================================
    // OPTIONAL ATTACHMENT
    // =================================================

    attachmentUrl: {
      type: String,
      trim: true,
      default: "",
    },

    attachmentName: {
      type: String,
      trim: true,
      default: "",
      maxlength: [
        500,
        "Attachment name cannot exceed 500 characters",
      ],
    },

    attachmentMimeType: {
      type: String,
      trim: true,
      default: "",
    },

    attachmentSize: {
      type: Number,
      default: 0,
      min: [
        0,
        "Attachment size cannot be negative",
      ],
    },

    // =================================================
    // DELIVERY STATUS
    // =================================================

    delivered: {
      type: Boolean,
      default: false,
      index: true,
    },

    deliveredAt: {
      type: Date,
      default: null,
    },

    isRead: {
      type: Boolean,
      default: false,
      index: true,
    },

    /*
     * Compatibility field used by existing backend code.
     */
    read: {
      type: Boolean,
      default: false,
      index: true,
    },

    readAt: {
      type: Date,
      default: null,
    },

    // =================================================
    // CLIENT MESSAGE DEDUPLICATION
    // =================================================

    clientMessageId: {
      type: String,
      trim: true,
      default: "",
    },

    // =================================================
    // MESSAGE EDITING
    // =================================================

    isEdited: {
      type: Boolean,
      default: false,
    },

    editedAt: {
      type: Date,
      default: null,
    },

    // =================================================
    // MESSAGE DELETION
    // =================================================

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
      index: true,
    },
  },
  {
    timestamps: true,

    optimisticConcurrency:
      true,

    toJSON: {
      virtuals: true,
    },

    toObject: {
      virtuals: true,
    },
  }
);

// =====================================================
// VIRTUAL FIELDS
// =====================================================

messageSchema
  .virtual("id")
  .get(function getId() {
    return this._id
      ?.toString() || "";
  });

messageSchema
  .virtual("chatRoomId")
  .get(function getChatRoomId() {
    return this.roomId || "";
  });

messageSchema
  .virtual("booking")
  .get(function getBooking() {
    return this.bookingId || null;
  });

messageSchema
  .virtual("isMine")
  .get(function getIsMine() {
    return false;
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
      if (
        !this.senderId &&
        this.sender
      ) {
        this.senderId =
          this.sender;
      }

      if (
        !this.sender &&
        this.senderId
      ) {
        this.sender =
          this.senderId;
      }

      if (
        !this.receiverId &&
        this.receiver
      ) {
        this.receiverId =
          this.receiver;
      }

      if (
        !this.receiver &&
        this.receiverId
      ) {
        this.receiver =
          this.receiverId;
      }

      const resolvedMessage =
        (
          this.message ||
          this.text ||
          this.content ||
          ""
        )
          .toString()
          .trim();

      this.message =
        resolvedMessage;

      this.text =
        resolvedMessage;

      this.content =
        resolvedMessage;

      if (
        this.bookingId
      ) {
        const bookingId =
          this.bookingId
            ._id
            ?.toString() ||
          this.bookingId
            .toString();

        if (
          !this.roomId
        ) {
          this.roomId =
            `booking:${bookingId}`;
        }
      }

      if (
        this.roomId &&
        !this.roomId.startsWith(
          "booking:"
        )
      ) {
        const normalizedRoomId =
          this.roomId
            .toString()
            .trim();

        if (
          mongoose.Types.ObjectId
            .isValid(
              normalizedRoomId
            )
        ) {
          this.roomId =
            `booking:${normalizedRoomId}`;
        }
      }

      this.messageType =
        (
          this.messageType ||
          MESSAGE_TYPES.TEXT
        )
          .toString()
          .trim()
          .toLowerCase();

      this.senderRole =
        (
          this.senderRole ||
          "user"
        )
          .toString()
          .trim()
          .toLowerCase();

      if (
        this.senderRole ===
        "customer"
      ) {
        this.senderRole =
          "customer";
      }

      if (
        this.delivered ===
          true &&
        !this.deliveredAt
      ) {
        this.deliveredAt =
          new Date();
      }

      if (
        this.isRead === true ||
        this.read === true
      ) {
        this.isRead = true;
        this.read = true;

        this.readAt =
          this.readAt ||
          new Date();

        this.delivered =
          true;

        this.deliveredAt =
          this.deliveredAt ||
          this.readAt;
      } else {
        this.isRead = false;
        this.read = false;
      }

      this.attachmentSize =
        Math.max(
          0,
          Number(
            this.attachmentSize ||
            0
          )
        );

      return next();
    } catch (error) {
      return next(error);
    }
  }
);

// =====================================================
// INSTANCE METHODS
// =====================================================

messageSchema.methods.markDelivered =
  async function markDelivered() {
    if (
      this.delivered !== true
    ) {
      this.delivered = true;

      this.deliveredAt =
        this.deliveredAt ||
        new Date();

      await this.save();
    }

    return this;
  };

messageSchema.methods.markRead =
  async function markRead() {
    const now = new Date();

    this.isRead = true;
    this.read = true;

    this.readAt =
      this.readAt ||
      now;

    this.delivered = true;

    this.deliveredAt =
      this.deliveredAt ||
      now;

    await this.save();

    return this;
  };

messageSchema.methods.softDeleteFor =
  async function softDeleteFor(
    userId
  ) {
    if (!userId) {
      return this;
    }

    const normalizedUserId =
      userId.toString();

    if (
      this.senderId
        ?.toString() ===
      normalizedUserId
    ) {
      this.deletedForSender =
        true;
    }

    if (
      this.receiverId
        ?.toString() ===
      normalizedUserId
    ) {
      this.deletedForReceiver =
        true;
    }

    if (
      this.deletedForSender &&
      this.deletedForReceiver
    ) {
      this.deletedAt =
        this.deletedAt ||
        new Date();
    }

    await this.save();

    return this;
  };

// =====================================================
// QUERY MIDDLEWARE
// =====================================================

messageSchema.pre(
  /^find/,
  function excludeDeletedMessages(
    next
  ) {
    const options =
      this.getOptions?.() || {};

    const query =
      this.getQuery();

    if (
      !options.includeDeleted &&
      query.deletedAt ===
        undefined
    ) {
      this.where({
        deletedAt: null,
      });
    }

    return next();
  }
);

// =====================================================
// INDEXES
// =====================================================

messageSchema.index({
  bookingId: 1,
  createdAt: 1,
});

messageSchema.index({
  roomId: 1,
  createdAt: 1,
});

messageSchema.index({
  receiverId: 1,
  isRead: 1,
  createdAt: -1,
});

messageSchema.index({
  receiverId: 1,
  read: 1,
  createdAt: -1,
});

messageSchema.index({
  senderId: 1,
  receiverId: 1,
  createdAt: -1,
});

messageSchema.index({
  bookingId: 1,
  receiverId: 1,
  isRead: 1,
  createdAt: -1,
});

messageSchema.index({
  bookingId: 1,
  senderId: 1,
  receiverId: 1,
  createdAt: 1,
});

messageSchema.index(
  {
    senderId: 1,
    clientMessageId: 1,
  },
  {
    unique: true,
    sparse: true,
    partialFilterExpression: {
      clientMessageId: {
        $type: "string",
        $ne: "",
      },
    },
  }
);

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