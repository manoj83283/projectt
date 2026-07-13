import mongoose from "mongoose";

const orderSchema = new mongoose.Schema(
  {
    // =====================================================
    // CUSTOMER
    // =====================================================
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // =====================================================
    // PROVIDER
    // =====================================================
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // =====================================================
    // SERVICE
    // =====================================================
    service: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
    },

    // =====================================================
    // ORDER TYPE
    // =====================================================
    orderType: {
      type: String,
      enum: [
        "service",
        "product",
      ],
      default: "service",
    },

    // =====================================================
    // CATEGORY
    // =====================================================
    category: {
      type: String,
      default: "",
    },

    // =====================================================
    // PRODUCT DETAILS
    // =====================================================
    productName: {
      type: String,
      default: "",
    },

    quantity: {
      type: Number,
      default: 1,
    },

    unit: {
      type: String,
      default: "",
    },

    // =====================================================
    // PRICING
    // =====================================================
    price: {
      type: Number,
      required: true,
    },

    totalAmount: {
      type: Number,
      required: true,
    },

    advanceAmount: {
      type: Number,
      default: 0,
    },

    // =====================================================
    // BOOKING DATE
    // =====================================================
    bookingDate: {
      type: Date,
    },

    eventDate: {
      type: Date,
    },

    // =====================================================
    // DELIVERY
    // =====================================================
    deliveryAddress: {
      fullAddress: {
        type: String,
        default: "",
      },

      city: {
        type: String,
        default: "",
      },

      state: {
        type: String,
        default: "",
      },

      pincode: {
        type: String,
        default: "",
      },

      latitude: Number,
      longitude: Number,
    },

    // =====================================================
    // NOTES
    // =====================================================
    notes: {
      type: String,
      default: "",
    },

    providerNotes: {
      type: String,
      default: "",
    },

    // =====================================================
    // PAYMENT
    // =====================================================
    paymentMethod: {
      type: String,
      enum: [
        "COD",
        "Razorpay",
        "UPI",
        "Card",
      ],
      default: "COD",
    },

    paymentStatus: {
      type: String,
      enum: [
        "pending",
        "paid",
        "failed",
        "refunded",
      ],
      default: "pending",
    },

    transactionId: {
      type: String,
      default: "",
    },

    // =====================================================
    // ORDER STATUS
    // =====================================================
    status: {
      type: String,
      enum: [
        "pending",
        "accepted",
        "rejected",
        "processing",
        "out_for_delivery",
        "completed",
        "cancelled",
      ],
      default: "pending",
    },

    // =====================================================
    // RATING
    // =====================================================
    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },

    review: {
      type: String,
      default: "",
    },

    // =====================================================
    // CANCELLATION
    // =====================================================
    cancelledBy: {
      type: String,
      enum: [
        "customer",
        "provider",
        "admin",
      ],
    },

    cancelReason: {
      type: String,
      default: "",
    },

    // =====================================================
    // DELIVERY TRACKING
    // =====================================================
    tracking: {
      currentLat: Number,
      currentLng: Number,
      updatedAt: Date,
    },
  },
  {
    timestamps: true,
  }
);

// =====================================================
// INDEXES
// =====================================================

orderSchema.index({
  customer: 1,
});

orderSchema.index({
  provider: 1,
});

orderSchema.index({
  status: 1,
});

orderSchema.index({
  orderType: 1,
});

orderSchema.index({
  createdAt: -1,
});

// =====================================================
// EXPORT
// =====================================================

const Order = mongoose.model(
  "Order",
  orderSchema
);

export default Order;