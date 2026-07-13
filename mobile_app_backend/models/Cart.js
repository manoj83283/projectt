import mongoose from "mongoose";

const cartItemSchema = new mongoose.Schema(
  {
    // =====================================================
    // SERVICE (OPTIONAL)
    // =====================================================
    service: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Service",
      default: null,
    },

    // =====================================================
    // PRODUCT INFO
    // =====================================================
    productName: {
      type: String,
      default: "",
    },

    category: {
      type: String,
      default: "",
    },

    itemType: {
      type: String,
      enum: ["service", "product"],
      default: "service",
    },

    // =====================================================
    // PRICE
    // =====================================================
    price: {
      type: Number,
      required: true,
      min: 0,
    },

    quantity: {
      type: Number,
      default: 1,
      min: 1,
    },

    total: {
      type: Number,
      default: 0,
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
    // OPTIONAL IMAGE
    // =====================================================
    image: {
      type: String,
      default: "",
    },

    // =====================================================
    // EVENT DATE (SERVICE BOOKINGS)
    // =====================================================
    eventDate: {
      type: Date,
      default: null,
    },

    notes: {
      type: String,
      default: "",
    },
  },
  {
    _id: true,
  }
);

const cartSchema = new mongoose.Schema(
  {
    // =====================================================
    // CUSTOMER
    // =====================================================
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
      index: true,
    },

    // =====================================================
    // ITEMS
    // =====================================================
    items: [cartItemSchema],

    // =====================================================
    // TOTALS
    // =====================================================
    totalItems: {
      type: Number,
      default: 0,
    },

    subtotal: {
      type: Number,
      default: 0,
    },

    tax: {
      type: Number,
      default: 0,
    },

    grandTotal: {
      type: Number,
      default: 0,
    },

    // =====================================================
    // COUPON SUPPORT
    // =====================================================
    couponCode: {
      type: String,
      default: "",
    },

    discountAmount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// =====================================================
// AUTO CALCULATE TOTALS
// =====================================================

cartSchema.pre("save", function (next) {
  this.totalItems = this.items.reduce(
    (sum, item) => sum + item.quantity,
    0
  );

  this.subtotal = this.items.reduce(
    (sum, item) =>
      sum + item.price * item.quantity,
    0
  );

  this.grandTotal =
    this.subtotal +
    this.tax -
    this.discountAmount;

  next();
});

// =====================================================
// INDEXES
// =====================================================

cartSchema.index({
  user: 1,
});

cartSchema.index({
  updatedAt: -1,
});

// =====================================================
// MODEL
// =====================================================

const Cart = mongoose.model(
  "Cart",
  cartSchema
);

export default Cart;