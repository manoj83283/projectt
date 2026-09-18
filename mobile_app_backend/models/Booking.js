import mongoose from "mongoose";

const { Schema } = mongoose;

// =====================================================
// CONSTANTS
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

const TERMINAL_BOOKING_STATUSES = Object.freeze([
  BOOKING_STATUSES.COMPLETED,
  BOOKING_STATUSES.REJECTED,
  BOOKING_STATUSES.CANCELLED,
]);

// =====================================================
// STATUS HISTORY SCHEMA
// =====================================================

const statusHistorySchema = new Schema(
  {
    status: {
      type: String,
      enum: Object.values(
        BOOKING_STATUSES
      ),
      required: [
        true,
        "Booking history status is required",
      ],
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
      maxlength: [
        1000,
        "Status history note cannot exceed 1000 characters",
      ],
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
// GEOJSON LOCATION SCHEMA
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

          const longitude =
            Number(value[0]);

          const latitude =
            Number(value[1]);

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
    // -------------------------------------------------
    // CUSTOMER
    // -------------------------------------------------

    user: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [
        true,
        "Customer is required",
      ],
      index: true,
    },

    customer: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
      index: true,
    },

    // -------------------------------------------------
    // SERVICE AND PROVIDER
    // -------------------------------------------------

    service: {
      type: Schema.Types.ObjectId,
      ref: "Service",
      required: [
        true,
        "Service is required",
      ],
      index: true,
    },

    provider: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [
        true,
        "Service provider is required",
      ],
      index: true,
    },

    // -------------------------------------------------
    // BOOKING IDENTIFICATION
    // -------------------------------------------------

    bookingNumber: {
      type: String,
      trim: true,
      uppercase: true,
      unique: true,
      sparse: true,
      index: true,
    },

    // -------------------------------------------------
    // BOOKING SCHEDULE
    // -------------------------------------------------

    bookingDate: {
      type: Date,
      required: [
        true,
        "Booking date is required",
      ],
      index: true,
    },

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

    // -------------------------------------------------
    // CUSTOMER BOOKING DETAILS
    // -------------------------------------------------

    contactNumber: {
      type: String,
      trim: true,
      default: "",
    },

    alternateContactNumber: {
      type: String,
      trim: true,
      default: "",
    },

    guestCount: {
      type: Number,
      default: 0,
      min: [
        0,
        "Guest count cannot be negative",
      ],
    },

    locationType: {
      type: String,
      trim: true,
      default: "",
    },

    serviceLocationType: {
      type: String,
      trim: true,
      default: "",
    },

    landmark: {
      type: String,
      trim: true,
      default: "",
    },

    nearbyLocation: {
      type: String,
      trim: true,
      default: "",
    },

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

    // -------------------------------------------------
    // ADDRESS AND LOCATION
    // -------------------------------------------------

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

    // -------------------------------------------------
    // PRICING
    // -------------------------------------------------

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

    // -------------------------------------------------
    // PAYMENT
    // -------------------------------------------------

    paymentMethod: {
      type: String,
      enum: Object.values(
        PAYMENT_METHODS
      ),
      default:
        PAYMENT_METHODS.COD,
      uppercase: true,
    },

    paymentStatus: {
      type: String,
      enum: Object.values(
        PAYMENT_STATUSES
      ),
      default:
        PAYMENT_STATUSES.PENDING,
      lowercase: true,
      index: true,
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

    // -------------------------------------------------
    // BOOKING STATUS
    // -------------------------------------------------

    status: {
      type: String,
      enum: Object.values(
        BOOKING_STATUSES
      ),
      default:
        BOOKING_STATUSES.PENDING,
      lowercase: true,
      index: true,
    },

    statusHistory: {
      type: [statusHistorySchema],
      default: [],
    },

    rejectionReason: {
      type: String,
      trim: true,
      default: "",
      maxlength: [
        1000,
        "Rejection reason cannot exceed 1000 characters",
      ],
    },

    cancellationReason: {
      type: String,
      trim: true,
      default: "",
      maxlength: [
        1000,
        "Cancellation reason cannot exceed 1000 characters",
      ],
    },

    // -------------------------------------------------
    // STATUS TIMELINE
    // -------------------------------------------------

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

    // -------------------------------------------------
    // RATING AND REVIEW
    // -------------------------------------------------

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

    // -------------------------------------------------
    // CHAT
    // -------------------------------------------------

    chatRoomId: {
      type: String,
      trim: true,
      default: "",
      index: true,
    },

    chatEnabled: {
      type: Boolean,
      default: true,
    },

    // -------------------------------------------------
    // SOFT DELETE
    // -------------------------------------------------

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
      index: true,
    },
  },
  {
    timestamps: true,

    optimisticConcurrency: true,

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
      this.customer?._id?.toString() ||
      this.customer?.toString() ||
      this.user?._id?.toString() ||
      this.user?.toString() ||
      ""
    );
  });

bookingSchema
  .virtual("providerId")
  .get(function getProviderId() {
    return (
      this.provider?._id?.toString() ||
      this.provider?.toString() ||
      ""
    );
  });

bookingSchema
  .virtual("serviceId")
  .get(function getServiceId() {
    return (
      this.service?._id?.toString() ||
      this.service?.toString() ||
      ""
    );
  });

bookingSchema
  .virtual("amount")
  .get(function getAmount() {
    return (
      Number(
        this.totalAmount || 0
      ) ||
      Number(
        this.totalPrice || 0
      )
    );
  });

bookingSchema
  .virtual("bookingStatus")
  .get(function getBookingStatus() {
    return (
      this.status ||
      BOOKING_STATUSES.PENDING
    );
  });

bookingSchema
  .virtual("isTerminal")
  .get(function getIsTerminal() {
    return TERMINAL_BOOKING_STATUSES
      .includes(this.status);
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
// DOCUMENT METHODS
// =====================================================

bookingSchema.methods.addStatusHistory =
  function addStatusHistory({
    status,
    changedBy = null,
    note = "",
    changedAt = new Date(),
  }) {
    if (
      !Array.isArray(
        this.statusHistory
      )
    ) {
      this.statusHistory = [];
    }

    const normalizedStatus =
      status
        ?.toString()
        .trim()
        .toLowerCase()
        .replaceAll("-", "_")
        .replaceAll(" ", "_");

    if (
      !Object.values(
        BOOKING_STATUSES
      ).includes(normalizedStatus)
    ) {
      throw new Error(
        `Invalid booking status: ${normalizedStatus}`
      );
    }

    this.statusHistory.push({
      status:
        normalizedStatus,

      changedBy:
        changedBy || null,

      note:
        note?.toString().trim() ||
        "",

      changedAt,
    });

    return this;
  };

bookingSchema.methods.isOwnedByCustomer =
  function isOwnedByCustomer(
    customerId
  ) {
    if (!customerId) {
      return false;
    }

    const normalizedCustomerId =
      customerId.toString();

    return (
      this.customer?.toString() ===
        normalizedCustomerId ||
      this.user?.toString() ===
        normalizedCustomerId
    );
  };

bookingSchema.methods.isAssignedToProvider =
  function isAssignedToProvider(
    providerId
  ) {
    if (!providerId) {
      return false;
    }

    return (
      this.provider?.toString() ===
      providerId.toString()
    );
  };

// =====================================================
// NORMALIZATION BEFORE VALIDATION
// =====================================================

bookingSchema.pre(
  "validate",
  function normalizeBooking(next) {
    try {
      if (
        !this.customer &&
        this.user
      ) {
        this.customer =
          this.user;
      }

      if (
        !this.user &&
        this.customer
      ) {
        this.user =
          this.customer;
      }

      if (
        !this.bookingDate &&
        this.date
      ) {
        this.bookingDate =
          this.date;
      }

      if (
        !this.date &&
        this.bookingDate
      ) {
        this.date =
          this.bookingDate;
      }

      const stringFields = [
        "bookingTime",
        "duration",
        "address",
        "location",
        "contactNumber",
        "alternateContactNumber",
        "locationType",
        "serviceLocationType",
        "landmark",
        "nearbyLocation",
        "notes",
        "specialInstructions",
        "couponCode",
        "rejectionReason",
        "cancellationReason",
      ];

      for (const field of stringFields) {
        this[field] =
          typeof this[field] ===
          "string"
            ? this[field].trim()
            : "";
      }

      this.hoursBooked =
        Math.max(
          1,
          Number(
            this.hoursBooked || 1
          )
        );

      this.guestCount =
        Math.max(
          0,
          Number(
            this.guestCount || 0
          )
        );

      this.pricePerHour =
        Math.max(
          0,
          Number(
            this.pricePerHour || 0
          )
        );

      this.basePrice =
        Math.max(
          0,
          Number(
            this.basePrice || 0
          )
        );

      this.platformFee =
        Math.max(
          0,
          Number(
            this.platformFee || 0
          )
        );

      this.taxAmount =
        Math.max(
          0,
          Number(
            this.taxAmount || 0
          )
        );

      this.discountAmount =
        Math.max(
          0,
          Number(
            this.discountAmount || 0
          )
        );

      if (
        !this.subtotal ||
        Number(this.subtotal) <= 0
      ) {
        if (
          this.pricePerHour > 0
        ) {
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

      this.subtotal =
        Math.max(
          0,
          Number(
            this.subtotal || 0
          )
        );

      const calculatedTotal =
        Math.max(
          0,
          this.subtotal +
            this.platformFee +
            this.taxAmount -
            this.discountAmount
        );

      if (
        !this.totalPrice ||
        Number(this.totalPrice) <= 0
      ) {
        this.totalPrice =
          Number(
            this.totalAmount ||
            calculatedTotal
          );
      }

      if (
        !this.totalAmount ||
        Number(this.totalAmount) <= 0
      ) {
        this.totalAmount =
          Number(
            this.totalPrice ||
            calculatedTotal
          );
      }

      this.totalPrice =
        Math.max(
          0,
          Number(
            this.totalPrice || 0
          )
        );

      this.totalAmount =
        Math.max(
          0,
          Number(
            this.totalAmount || 0
          )
        );

      this.status =
        this.status
          ?.toString()
          .trim()
          .toLowerCase()
          .replaceAll("-", "_")
          .replaceAll(" ", "_") ||
        BOOKING_STATUSES.PENDING;

      this.paymentMethod =
        this.paymentMethod
          ?.toString()
          .trim()
          .toUpperCase() ||
        PAYMENT_METHODS.COD;

      this.paymentStatus =
        this.paymentStatus
          ?.toString()
          .trim()
          .toLowerCase() ||
        PAYMENT_STATUSES.PENDING;

      this.currency =
        this.currency
          ?.toString()
          .trim()
          .toUpperCase() ||
        "INR";

      this.couponCode =
        this.couponCode
          ?.toString()
          .trim()
          .toUpperCase() ||
        "";

      if (
        !this.chatRoomId &&
        this._id
      ) {
        this.chatRoomId =
          this._id.toString();
      }

      if (
        !this.bookingNumber &&
        this._id
      ) {
        const suffix =
          this._id
            .toString()
            .slice(-8)
            .toUpperCase();

        this.bookingNumber =
          `EB-${suffix}`;
      }

      if (
        !Array.isArray(
          this.statusHistory
        )
      ) {
        this.statusHistory = [];
      }

      if (
        this.isNew &&
        this.statusHistory.length === 0
      ) {
        this.statusHistory.push({
          status:
            this.status ||
            BOOKING_STATUSES.PENDING,

          changedBy:
            this.user || null,

          note:
            "Booking created",

          changedAt:
            new Date(),
        });
      }

      return next();
    } catch (error) {
      return next(error);
    }
  }
);

// =====================================================
// STATUS TIMESTAMP SYNCHRONIZATION
// =====================================================

bookingSchema.pre(
  "save",
  function synchronizeStatusTimestamp(
    next
  ) {
    try {
      if (
        !this.isModified("status")
      ) {
        return next();
      }

      const now = new Date();

      switch (this.status) {
        case BOOKING_STATUSES.PENDING:
          break;

        case BOOKING_STATUSES.ACCEPTED:
          this.acceptedAt =
            this.acceptedAt || now;

          this.rejectionReason = "";
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

          if (
            this.paymentMethod ===
              PAYMENT_METHODS.COD &&
            this.paymentStatus ===
              PAYMENT_STATUSES.PENDING
          ) {
            this.paymentStatus =
              PAYMENT_STATUSES.PAID;

            this.paidAt =
              this.paidAt || now;
          }
          break;

        case BOOKING_STATUSES.CANCELLED:
          this.cancelledAt =
            this.cancelledAt || now;
          break;

        default:
          break;
      }

      return next();
    } catch (error) {
      return next(error);
    }
  }
);

// =====================================================
// SOFT-DELETE QUERY MIDDLEWARE
// =====================================================

bookingSchema.pre(
  /^find/,
  function excludeDeletedBookings(
    next
  ) {
    const options =
      this.getOptions?.() || {};

    const currentQuery =
      this.getQuery();

    if (
      !options.includeDeleted &&
      currentQuery.deletedAt ===
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
  provider: 1,
  status: 1,
  createdAt: -1,
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
  provider: 1,
  bookingDate: 1,
  bookingTime: 1,
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