import mongoose from "mongoose";

const serviceSchema = new mongoose.Schema(
  {
    /// ✅ BASIC INFO
    name: {
      type: String,
      required: true,
      trim: true,
    },

    category: {
      type: String,
      required: true,
      lowercase: true,
      trim: true,
    },

    /// ✅ MULTI CATEGORY SUPPORT
    categories: [
      {
        type: String,
      },
    ],

    description: {
      type: String,
      default: "",
      trim: true,
    },

    serviceType: {
      type: String,
      default: "fixed",
    },

    /// ✅ PRICING
    price: {
      type: Number,
      default: 0,
    },

    pricePerHour: {
      type: Number,
      default: 0,
    },

    pricePerDay: {
      type: Number,
      default: 0,
    },

    basePrice: {
      type: Number,
      default: 0,
    },

    /// ✅ LOCATION NAME (KEEP EXISTING)
    location: {
      type: String,
      required: true,
      trim: true,
    },

    /// ✅ EXISTING GEO SUPPORT
    geoLocation: {
      type: {
        type: String,
        enum: ["Point"],
      },
      coordinates: {
        type: [Number],
      },
    },

    /// ✅ EXISTING LOCATION GEO
    locationGeo: {
      type: {
        type: String,
        enum: ["Point"],
        default: "Point",
      },
      coordinates: {
        type: [Number],
        default: [0, 0],
      },
    },

    /// ✅ NEW LOCATION POINT (REQUESTED)
    locationPoint: {
      type: {
        type: String,
        default: "Point",
      },
      coordinates: {
        type: [Number],
        default: [0, 0],
      },
    },

    /// ✅ MEDIA
    image: {
      type: String,
      default: "",
    },

    imageUrl: {
      type: String,
      default: "",
    },

    images: [
      {
        type: String,
      },
    ],

    /// ✅ SEARCH TAGS
    tags: [
      {
        type: String,
        lowercase: true,
      },
    ],

    /// ✅ PROVIDER
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    providerName: {
      type: String,
      default: "",
    },

    /// ✅ RATINGS
    rating: {
      type: Number,
      default: 0,
    },

    totalReviews: {
      type: Number,
      default: 0,
    },

    /// ✅ AVAILABILITY
    isAvailable: {
      type: Boolean,
      default: true,
    },

    isActive: {
      type: Boolean,
      default: true,
    },

    /// ✅ FEATURE FLAGS
    isPopular: {
      type: Boolean,
      default: false,
    },

    isRecommended: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);
/// ✅ INDEXES
serviceSchema.index({ category: 1 });
serviceSchema.index({ categories: 1 });
serviceSchema.index({
  name: "text",
  description: "text",
  tags: "text",
});
serviceSchema.index({
  location: "2dsphere",
});
/// ✅ EXISTING GEO INDEX
serviceSchema.index({
  locationGeo: "2dsphere",
});
/// ✅ NEW GEO INDEX
serviceSchema.index({
  locationPoint: "2dsphere",
});
const Service =
  mongoose.models.Service ||
  mongoose.model(
    "Service",
    serviceSchema
  );

export default Service;