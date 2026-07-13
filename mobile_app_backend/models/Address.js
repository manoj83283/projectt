import mongoose from "mongoose";

const addressSchema = new mongoose.Schema(
  {
    // =====================================================
    // USER
    // =====================================================
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    // =====================================================
    // ADDRESS TYPE
    // =====================================================
    addressType: {
      type: String,
      enum: [
        "home",
        "work",
        "event",
        "other",
      ],
      default: "home",
    },

    // =====================================================
    // CONTACT
    // =====================================================
    fullName: {
      type: String,
      required: true,
      trim: true,
    },

    phone: {
      type: String,
      required: true,
      trim: true,
    },

    alternatePhone: {
      type: String,
      default: "",
    },

    // =====================================================
    // ADDRESS DETAILS
    // =====================================================
    houseNo: {
      type: String,
      default: "",
    },

    apartment: {
      type: String,
      default: "",
    },

    landmark: {
      type: String,
      default: "",
    },

    street: {
      type: String,
      default: "",
    },

    area: {
      type: String,
      required: true,
    },

    city: {
      type: String,
      required: true,
    },

    district: {
      type: String,
      default: "",
    },

    state: {
      type: String,
      required: true,
    },

    country: {
      type: String,
      default: "India",
    },

    pincode: {
      type: String,
      required: true,
    },

    // =====================================================
    // FULL ADDRESS
    // =====================================================
    fullAddress: {
      type: String,
      required: true,
    },

    // =====================================================
    // LOCATION
    // =====================================================
    location: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point",
      },

      coordinates: {
        type: [Number], // [lng, lat]
        default: [0, 0],
      },
    },

    latitude: {
      type: Number,
      default: 0,
    },

    longitude: {
      type: Number,
      default: 0,
    },

    // =====================================================
    // DEFAULT ADDRESS
    // =====================================================
    isDefault: {
      type: Boolean,
      default: false,
    },

    // =====================================================
    // ACTIVE
    // =====================================================
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// =====================================================
// GEO INDEX
// =====================================================

addressSchema.index({
  location: "2dsphere",
});

// =====================================================
// USER INDEX
// =====================================================

addressSchema.index({
  user: 1,
});

// =====================================================
// MODEL
// =====================================================

const Address = mongoose.model(
  "Address",
  addressSchema
);

export default Address;