import mongoose from "mongoose";

const { Schema } = mongoose;

// =====================================================
// BOOKING CONSTANTS
// =====================================================

export const BOOKING_STATUSES = Object.freeze({
  PENDING: "pending",
  ACCEPTED: "accepted",
  REJECTED: "rejected",
  IN_PROGRESS: "in_progress",
  COMPLETED: "completed",
  CANCELLED: "cancelled",
});

export const PAYMENT_STATUSES = Object.freeze({
  PENDING: "pending",
  PAID: "paid",
  FAILED: "failed",
  REFUNDED: "refunded",
});

export const PAYMENT_METHODS = Object.freeze({
  COD: "COD",
  ONLINE: "ONLINE",
});

// =====================================================
// STATUS HISTORY
// =====================================================

const statusHistorySchema = new Schema(
  {
    status: {
      type: String,
      enum: Object.values(BOOKING_STATUSES),
      required: true,
    },

    changedBy: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    note: {
      type: String,
      trim: true,
      default: "",
    },

    changedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    _id: false,
  }
);

// =====================================================
// GEOJSON LOCATION
// =====================================================

const locationPointSchema = new Schema(
  {
    type: {
      type: String,
      enum: ["Point"],
      default: "Point",
    },

    coordinates: {
      type: [Number],
      default: [0, 0],

      validate: {
        validator(value) {
          if (
            !Array.isArray(value) ||
            value.length !== 2
          ) {
            return false;
          }

          const longitude = Number(value[0]);
          const latitude = Number(value[1]);

          return (
            Number.isFinite(longitude) &&
            Number.isFinite(latitude) &&
            longitude >= -180 &&
            longitude <= 180 &&
            latitude >= -90 &&
            latitude <= 90
          );
        },

        message:
          "Location coordinates must use [longitude, latitude]",
      },
    },
  },
  {
    _id: false,
  }
);

// =====================================================
// BOOKING SCHEMA
// =====================================================

const bookingSchema = new Schema(
  {
    // =================================================
    // CUSTOMER
    // =================================================

    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [
        true,
        "Customer is required",
      ],
    },

    // Compatibility field for controllers using customer.
    customer: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    // =================================================
    // SERVICE AND PROVIDER
    // =================================================

    service: {
      type: Schema.Types.ObjectId,
      ref: "Service",
      required: [
        true,
        "Service is required",
      ],
    },

    // This must be copied from Service.provider.
    provider: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [
        true,
        "Service provider is required",
      ],
    },

    // =================================================
    // BOOKING REFERENCE
    // =================================================

    bookingNumber: {
      type: String,
      trim: true,
      unique: true,
      sparse: true,
    },

    // =================================================
    // BOOKING SCHEDULE
    // =================================================

    bookingDate: {
      type: Date,
      required: [
        true,
        "Booking date is required",
      ],
    },

    // Compatibility field for old code using date.
    date: {
      type: Date,
      default: null,
    },

    bookingTime: {
      type: String,
      trim: true,
      default: "",
    },

    endDate: {
      type: Date,
      default: null,
    },

    duration: {
      type: String,
      trim: true,
      default: "",
    },

    hoursBooked: {
      type: Number,
      default: 1,
      min: [
        1,
        "Hours booked must be at least one",
      ],
    },

    // =================================================
    // CUSTOMER DETAILS
    // =================================================

    notes: {
      type: String,
      trim: true,
      default: "",
      maxlength: [
        2000,
        "Notes cannot exceed 2000 characters",
      ],
    },

    specialInstructions: {
      type: String,
      trim: true,
      default: "",
      maxlength: [
        2000,
        "Special instructions cannot exceed 2000 characters",
      ],
    },

    // =================================================
    // ADDRESS AND LOCATION
    // =================================================

    address: {
      type: String,
      required: [
        true,
        "Service address is required",
      ],
      trim: true,
      maxlength: [
        500,
        "Address cannot exceed 500 characters",
      ],
    },

    location: {
      type: String,
      trim: true,
      default: "",
    },

    locationPoint: {
      type: locationPointSchema,
      default: () => ({
        type: "Point",
        coordinates: [0, 0],
      }),
    },

    // =================================================
    // PRICING
    // =================================================

    pricePerHour: {
      type: Number,
      default: 0,
      min: [
        0,
        "Price per hour cannot be negative",
      ],
    },

    basePrice: {
      type: Number,
      default: 0,
      min: [
        0,
        "Base price cannot be negative",
      ],
    },

    subtotal: {
      type: Number,
      default: 0,
      min: [
        0,
        "Subtotal cannot be negative",
      ],
    },

    platformFee: {
      type: Number,
      default: 0,
      min: [
        0,
        "Platform fee cannot be negative",
      ],
    },

    taxAmount: {
      type: Number,
      default: 0,
      min: [
        0,
        "Tax amount cannot be negative",
      ],
    },

    discountAmount: {
      type: Number,
      default: 0,
      min: [
        0,
        "Discount amount cannot be negative",
      ],
    },

    totalPrice: {
      type: Number,
      required: [
        true,
        "Total booking price is required",
      ],
      default: 0,
      min: [
        0,
        "Total price cannot be negative",
      ],
    },

    // Compatibility field for Flutter totalAmount.
    totalAmount: {
      type: Number,
      default: 0,
      min: [
        0,
        "Total amount cannot be negative",
      ],
    },

    currency: {
      type: String,
      trim: true,
      uppercase: true,
      default: "INR",
    },

    couponCode: {
      type: String,
      trim: true,
      uppercase: true,
      default: "",
    },

    // =================================================
    // PAYMENT
    // =================================================

    paymentMethod: {
      type: String,
      enum: Object.values(PAYMENT_METHODS),
      default: PAYMENT_METHODS.COD,
      uppercase: true,
    },

    paymentStatus: {
      type: String,
      enum: Object.values(PAYMENT_STATUSES),
      default: PAYMENT_STATUSES.PENDING,
      lowercase: true,
    },

    paymentId: {
      type: String,
      trim: true,
      default: "",
    },

    transactionId: {
      type: String,
      trim: true,
      default: "",
    },

    paidAt: {
      type: Date,
      default: null,
    },

    // =================================================
    // BOOKING STATUS
    // =================================================

    status: {
      type: String,
      enum: Object.values(BOOKING_STATUSES),
      default: BOOKING_STATUSES.PENDING,
      lowercase: true,
    },

    statusHistory: {
      type: [statusHistorySchema],
      default: [],
    },

    rejectionReason: {
      type: String,
      trim: true,
      default: "",
    },

    cancellationReason: {
      type: String,
      trim: true,
      default: "",
    },

    // =================================================
    // TIMELINE
    // =================================================

    acceptedAt: {
      type: Date,
      default: null,
    },

    rejectedAt: {
      type: Date,
      default: null,
    },

    startedAt: {
      type: Date,
      default: null,
    },

    completedAt: {
      type: Date,
      default: null,
    },

    cancelledAt: {
      type: Date,
      default: null,
    },

    // =================================================
    // RATING AND REVIEW
    // =================================================

    rating: {
      type: Number,
      min: [
        1,
        "Rating must be at least one",
      ],
      max: [
        5,
        "Rating cannot exceed five",
      ],
      default: null,
    },

    review: {
      type: String,
      trim: true,
      default: "",
      maxlength: [
        2000,
        "Review cannot exceed 2000 characters",
      ],
    },

    reviewedAt: {
      type: Date,
      default: null,
    },

    // =================================================
    // CHAT
    // =================================================

    // The booking ID is used as the shared chat room ID.
    chatRoomId: {
      type: String,
      trim: true,
      default: "",
    },

    chatEnabled: {
      type: Boolean,
      default: true,
    },

    // =================================================
    // SOFT DELETE
    // =================================================

    isCustomerDeleted: {
      type: Boolean,
      default: false,
    },

    isProviderDeleted: {
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
// VIRTUAL FIELDS
// =====================================================

bookingSchema
  .virtual("customerId")
  .get(function getCustomerId() {
    return (
      this.customer?.toString() ||
      this.user?.toString() ||
      ""
    );
  });

bookingSchema
  .virtual("providerId")
  .get(function getProviderId() {
    return this.provider?.toString() || "";
  });

bookingSchema
  .virtual("serviceId")
  .get(function getServiceId() {
    return this.service?.toString() || "";
  });

bookingSchema
  .virtual("amount")
  .get(function getAmount() {
    return (
      Number(this.totalAmount || 0) ||
      Number(this.totalPrice || 0)
    );
  });

bookingSchema
  .virtual("canCustomerCancel")
  .get(function canCustomerCancel() {
    return [
      BOOKING_STATUSES.PENDING,
      BOOKING_STATUSES.ACCEPTED,
    ].includes(this.status);
  });

bookingSchema
  .virtual("canProviderAccept")
  .get(function canProviderAccept() {
    return (
      this.status ===
      BOOKING_STATUSES.PENDING
    );
  });

bookingSchema
  .virtual("canProviderReject")
  .get(function canProviderReject() {
    return (
      this.status ===
      BOOKING_STATUSES.PENDING
    );
  });

bookingSchema
  .virtual("canStart")
  .get(function canStart() {
    return (
      this.status ===
      BOOKING_STATUSES.ACCEPTED
    );
  });

bookingSchema
  .virtual("canComplete")
  .get(function canComplete() {
    return (
      this.status ===
      BOOKING_STATUSES.IN_PROGRESS
    );
  });

// =====================================================
// NORMALIZATION
// =====================================================

bookingSchema.pre(
  "validate",
  function normalizeBooking(next) {
    try {
      // Keep customer and user synchronized.
      if (!this.customer && this.user) {
        this.customer = this.user;
      }

      if (!this.user && this.customer) {
        this.user = this.customer;
      }

      // Keep bookingDate and date synchronized.
      if (
        !this.bookingDate &&
        this.date
      ) {
        this.bookingDate = this.date;
      }

      if (
        !this.date &&
        this.bookingDate
      ) {
        this.date = this.bookingDate;
      }

      // Normalize text.
      this.bookingTime =
        typeof this.bookingTime === "string"
          ? this.bookingTime.trim()
          : "";

      this.duration =
        typeof this.duration === "string"
          ? this.duration.trim()
          : "";

      this.address =
        typeof this.address === "string"
          ? this.address.trim()
          : "";

      this.location =
        typeof this.location === "string"
          ? this.location.trim()
          : "";

      this.notes =
        typeof this.notes === "string"
          ? this.notes.trim()
          : "";

      this.specialInstructions =
        typeof this.specialInstructions ===
        "string"
          ? this.specialInstructions.trim()
          : "";

      // Normalize numeric values.
      this.hoursBooked = Math.max(
        1,
        Number(this.hoursBooked || 1)
      );

      this.pricePerHour = Math.max(
        0,
        Number(this.pricePerHour || 0)
      );

      this.basePrice = Math.max(
        0,
        Number(this.basePrice || 0)
      );

      this.platformFee = Math.max(
        0,
        Number(this.platformFee || 0)
      );

      this.taxAmount = Math.max(
        0,
        Number(this.taxAmount || 0)
      );

      this.discountAmount = Math.max(
        0,
        Number(this.discountAmount || 0)
      );

      // Calculate subtotal if missing.
      if (
        !this.subtotal ||
        Number(this.subtotal) <= 0
      ) {
        if (this.pricePerHour > 0) {
          this.subtotal =
            this.pricePerHour *
            this.hoursBooked;
        } else {
          this.subtotal =
            this.basePrice ||
            this.totalPrice ||
            this.totalAmount ||
            0;
        }
      }

      this.subtotal = Math.max(
        0,
        Number(this.subtotal || 0)
      );

      const calculatedTotal = Math.max(
        0,
        this.subtotal +
          this.platformFee +
          this.taxAmount -
          this.discountAmount
      );

      // Synchronize totalPrice and totalAmount.
      if (
        !this.totalPrice ||
        Number(this.totalPrice) <= 0
      ) {
        this.totalPrice = Number(
          this.totalAmount ||
            calculatedTotal
        );
      }

      if (
        !this.totalAmount ||
        Number(this.totalAmount) <= 0
      ) {
        this.totalAmount = Number(
          this.totalPrice ||
            calculatedTotal
        );
      }

      this.totalPrice = Math.max(
        0,
        Number(this.totalPrice || 0)
      );

      this.totalAmount = Math.max(
        0,
        Number(this.totalAmount || 0)
      );

      // Use booking ID as the shared chat room ID.
      if (
        !this.chatRoomId &&
        this._id
      ) {
        this.chatRoomId =
          this._id.toString();
      }

      // Generate readable booking number.
      if (
        !this.bookingNumber &&
        this._id
      ) {
        const suffix = this._id
          .toString()
          .slice(-8)
          .toUpperCase();

        this.bookingNumber =
          `EB-${suffix}`;
      }

      // Add initial booking history.
      if (
        !Array.isArray(
          this.statusHistory
        ) ||
        this.statusHistory.length === 0
      ) {
        this.statusHistory = [
          {
            status:
              this.status ||
              BOOKING_STATUSES.PENDING,

            changedBy:
              this.user || null,

            note:
              "Booking created",

            changedAt:
              new Date(),
          },
        ];
      }

      next();
    } catch (error) {
      next(error);
    }
  }
);

// =====================================================
// STATUS TIMESTAMP SYNCHRONIZATION
// =====================================================

bookingSchema.pre(
  "save",
  function synchronizeStatusTimestamp(next) {
    try {
      if (!this.isModified("status")) {
        return next();
      }

      const now = new Date();

      switch (this.status) {
        case BOOKING_STATUSES.ACCEPTED:
          this.acceptedAt =
            this.acceptedAt || now;
          break;

        case BOOKING_STATUSES.REJECTED:
          this.rejectedAt =
            this.rejectedAt || now;
          break;

        case BOOKING_STATUSES.IN_PROGRESS:
          this.startedAt =
            this.startedAt || now;
          break;

        case BOOKING_STATUSES.COMPLETED:
          this.completedAt =
            this.completedAt || now;
          break;

        case BOOKING_STATUSES.CANCELLED:
          this.cancelledAt =
            this.cancelledAt || now;
          break;

        default:
          break;
      }

      next();
    } catch (error) {
      next(error);
    }
  }
);

// =====================================================
// QUERY MIDDLEWARE
// =====================================================

bookingSchema.pre(
  /^find/,
  function excludeDeletedBookings(next) {
    const options =
      this.getOptions?.() || {};

    const currentQuery =
      this.getQuery();

    if (
      !options.includeDeleted &&
      currentQuery.deletedAt === undefined
    ) {
      this.where({
        deletedAt: null,
      });
    }

    next();
  }
);

// =====================================================
// INDEXES
// =====================================================

bookingSchema.index({
  user: 1,
  createdAt: -1,
});

bookingSchema.index({
  customer: 1,
  createdAt: -1,
});

bookingSchema.index({
  provider: 1,
  createdAt: -1,
});

bookingSchema.index({
  provider: 1,
  status: 1,
  bookingDate: 1,
});

bookingSchema.index({
  user: 1,
  status: 1,
  createdAt: -1,
});

bookingSchema.index({
  customer: 1,
  status: 1,
  createdAt: -1,
});

bookingSchema.index({
  service: 1,
  createdAt: -1,
});

bookingSchema.index({
  bookingDate: 1,
  status: 1,
});

bookingSchema.index({
  paymentStatus: 1,
  createdAt: -1,
});

bookingSchema.index({
  provider: 1,
  paymentStatus: 1,
  createdAt: -1,
});

bookingSchema.index({
  chatRoomId: 1,
});

bookingSchema.index({
  locationPoint: "2dsphere",
});

// =====================================================
// MODEL
// =====================================================

const Booking =
  mongoose.models.Booking ||
  mongoose.model(
    "Booking",
    bookingSchema
  );

export default Booking;