import mongoose from "mongoose";

const { Schema } = mongoose;

// =====================================================
// GEOJSON POINT SCHEMA
// =====================================================

const geoPointSchema = new Schema(
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
          if (!Array.isArray(value) || value.length !== 2) {
            return false;
          }

          const [longitude, latitude] = value;

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
          "Coordinates must contain valid [longitude, latitude] values",
      },
    },
  },
  {
    _id: false,
  }
);

// =====================================================
// SERVICE SCHEMA
// =====================================================

const serviceSchema = new Schema(
  {
    // =================================================
    // BASIC INFORMATION
    // =================================================

    name: {
      type: String,
      required: [true, "Service name is required"],
      trim: true,
      minlength: [2, "Service name must contain at least 2 characters"],
      maxlength: [150, "Service name cannot exceed 150 characters"],
    },

    category: {
      type: String,
      required: [true, "Service category is required"],
      lowercase: true,
      trim: true,
      maxlength: [100, "Category cannot exceed 100 characters"],
      index: true,
    },

    categories: {
      type: [
        {
          type: String,
          lowercase: true,
          trim: true,
        },
      ],
      default: [],
    },

    description: {
      type: String,
      default: "",
      trim: true,
      maxlength: [
        5000,
        "Service description cannot exceed 5000 characters",
      ],
    },

    serviceType: {
      type: String,
      enum: [
        "fixed",
        "hourly",
        "daily",
        "package",
        "custom",
      ],
      default: "fixed",
      lowercase: true,
      trim: true,
    },

    // =================================================
    // PRICING
    // =================================================

    price: {
      type: Number,
      default: 0,
      min: [0, "Price cannot be negative"],
    },

    basePrice: {
      type: Number,
      default: 0,
      min: [0, "Base price cannot be negative"],
    },

    pricePerHour: {
      type: Number,
      default: 0,
      min: [0, "Hourly price cannot be negative"],
    },

    pricePerDay: {
      type: Number,
      default: 0,
      min: [0, "Daily price cannot be negative"],
    },

    currency: {
      type: String,
      default: "INR",
      uppercase: true,
      trim: true,
    },

    // =================================================
    // LOCATION
    // =================================================

    /**
     * Human-readable location.
     *
     * Example:
     * Hyderabad, Telangana
     *
     * Do not create a 2dsphere index on this String field.
     */
    location: {
      type: String,
      required: [true, "Service location is required"],
      trim: true,
      maxlength: [250, "Location cannot exceed 250 characters"],
      index: true,
    },

    /**
     * Canonical GeoJSON location used for geographical queries.
     *
     * Coordinates order:
     * [longitude, latitude]
     */
    locationPoint: {
      type: geoPointSchema,
      default: () => ({
        type: "Point",
        coordinates: [0, 0],
      }),
    },

    /**
     * Legacy compatibility fields.
     *
     * Keep these temporarily if existing frontend/backend code
     * still sends geoLocation or locationGeo.
     */
    geoLocation: {
      type: geoPointSchema,
      default: undefined,
    },

    locationGeo: {
      type: geoPointSchema,
      default: undefined,
    },

    // =================================================
    // MEDIA
    // =================================================

    image: {
      type: String,
      default: "",
      trim: true,
    },

    imageUrl: {
      type: String,
      default: "",
      trim: true,
    },

    images: {
      type: [
        {
          type: String,
          trim: true,
        },
      ],
      default: [],
    },

    // =================================================
    // SEARCH AND FEATURES
    // =================================================

    tags: {
      type: [
        {
          type: String,
          lowercase: true,
          trim: true,
        },
      ],
      default: [],
    },

    features: {
      type: [
        {
          type: String,
          trim: true,
        },
      ],
      default: [],
    },

    // =================================================
    // PROVIDER
    // =================================================

    provider: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: [true, "Provider is required"],
      index: true,
    },

    providerName: {
      type: String,
      default: "",
      trim: true,
    },

    businessName: {
      type: String,
      default: "",
      trim: true,
    },

    // =================================================
    // RATINGS
    // =================================================

    rating: {
      type: Number,
      default: 0,
      min: [0, "Rating cannot be less than zero"],
      max: [5, "Rating cannot be greater than five"],
    },

    totalReviews: {
      type: Number,
      default: 0,
      min: [0, "Total reviews cannot be negative"],
    },

    // =================================================
    // AVAILABILITY
    // =================================================

    isAvailable: {
      type: Boolean,
      default: true,
      index: true,
    },

    isActive: {
      type: Boolean,
      default: true,
      index: true,
    },

    // =================================================
    // APPROVAL
    // =================================================

    approvalStatus: {
      type: String,
      enum: [
        "pending",
        "approved",
        "rejected",
      ],
      default: "approved",
      lowercase: true,
      index: true,
    },

    rejectionReason: {
      type: String,
      default: "",
      trim: true,
    },

    approvedAt: {
      type: Date,
      default: null,
    },

    approvedBy: {
      type: Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    // =================================================
    // FEATURE FLAGS
    // =================================================

    isPopular: {
      type: Boolean,
      default: false,
      index: true,
    },

    isRecommended: {
      type: Boolean,
      default: false,
      index: true,
    },

    isFeatured: {
      type: Boolean,
      default: false,
      index: true,
    },

    // =================================================
    // AUDIT
    // =================================================

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

serviceSchema.virtual("displayPrice").get(function displayPrice() {
  if (this.serviceType === "hourly" && this.pricePerHour > 0) {
    return this.pricePerHour;
  }

  if (this.serviceType === "daily" && this.pricePerDay > 0) {
    return this.pricePerDay;
  }

  if (this.basePrice > 0) {
    return this.basePrice;
  }

  return this.price || 0;
});

// =====================================================
// NORMALIZATION
// =====================================================

serviceSchema.pre("validate", function normalizeService(next) {
  try {
    if (typeof this.name === "string") {
      this.name = this.name.trim();
    }

    if (typeof this.category === "string") {
      this.category = this.category.trim().toLowerCase();
    }

    if (typeof this.location === "string") {
      this.location = this.location.trim();
    }

    if (typeof this.providerName === "string") {
      this.providerName = this.providerName.trim();
    }

    if (typeof this.businessName === "string") {
      this.businessName = this.businessName.trim();
    }

    this.categories = Array.from(
      new Set(
        [
          this.category,
          ...(Array.isArray(this.categories)
            ? this.categories
            : []),
        ]
          .map((value) =>
            typeof value === "string"
              ? value.trim().toLowerCase()
              : ""
          )
          .filter(Boolean)
      )
    );

    this.tags = Array.from(
      new Set(
        (Array.isArray(this.tags) ? this.tags : [])
          .map((value) =>
            typeof value === "string"
              ? value.trim().toLowerCase()
              : ""
          )
          .filter(Boolean)
      )
    );

    this.features = Array.from(
      new Set(
        (Array.isArray(this.features) ? this.features : [])
          .map((value) =>
            typeof value === "string"
              ? value.trim()
              : ""
          )
          .filter(Boolean)
      )
    );

    this.images = Array.from(
      new Set(
        (Array.isArray(this.images) ? this.images : [])
          .map((value) =>
            typeof value === "string"
              ? value.trim()
              : ""
          )
          .filter(Boolean)
      )
    );

    if (
      (!this.imageUrl || this.imageUrl.trim() === "") &&
      this.image &&
      this.image.trim() !== ""
    ) {
      this.imageUrl = this.image.trim();
    }

    if (
      (!this.image || this.image.trim() === "") &&
      this.imageUrl &&
      this.imageUrl.trim() !== ""
    ) {
      this.image = this.imageUrl.trim();
    }

    if (
      this.images.length === 0 &&
      this.imageUrl &&
      this.imageUrl.trim() !== ""
    ) {
      this.images = [this.imageUrl.trim()];
    }

    const normalizedPrice = Number(this.price || 0);
    const normalizedBasePrice = Number(this.basePrice || 0);

    if (normalizedPrice <= 0 && normalizedBasePrice > 0) {
      this.price = normalizedBasePrice;
    }

    if (normalizedBasePrice <= 0 && normalizedPrice > 0) {
      this.basePrice = normalizedPrice;
    }

    /**
     * Copy a legacy valid location into the canonical locationPoint.
     */
    const canonicalCoordinates =
      this.locationPoint?.coordinates ?? [0, 0];

    const hasCanonicalCoordinates =
      Array.isArray(canonicalCoordinates) &&
      canonicalCoordinates.length === 2 &&
      !(
        Number(canonicalCoordinates[0]) === 0 &&
        Number(canonicalCoordinates[1]) === 0
      );

    if (!hasCanonicalCoordinates) {
      const legacyCoordinates =
        this.locationGeo?.coordinates ??
        this.geoLocation?.coordinates;

      if (
        Array.isArray(legacyCoordinates) &&
        legacyCoordinates.length === 2
      ) {
        this.locationPoint = {
          type: "Point",
          coordinates: [
            Number(legacyCoordinates[0]),
            Number(legacyCoordinates[1]),
          ],
        };
      }
    }

    next();
  } catch (error) {
    next(error);
  }
});

// =====================================================
// QUERY MIDDLEWARE
// =====================================================

serviceSchema.pre(/^find/, function excludeDeleted(next) {
  const options = this.getOptions();

  if (!options?.includeDeleted) {
    this.where({
      deletedAt: null,
    });
  }

  next();
});

// =====================================================
// INDEXES
// =====================================================

/**
 * Do not add 2dsphere to the String-based location field.
 */
serviceSchema.index({
  name: "text",
  description: "text",
  tags: "text",
  providerName: "text",
  businessName: "text",
});

serviceSchema.index({
  provider: 1,
  createdAt: -1,
});

serviceSchema.index({
  category: 1,
  isActive: 1,
  isAvailable: 1,
  approvalStatus: 1,
});

serviceSchema.index({
  categories: 1,
  isActive: 1,
});

serviceSchema.index({
  isFeatured: 1,
  isPopular: 1,
  isRecommended: 1,
  createdAt: -1,
});

serviceSchema.index({
  price: 1,
  rating: -1,
});

serviceSchema.index({
  locationPoint: "2dsphere",
});

// =====================================================
// MODEL
// =====================================================

const Service =
  mongoose.models.Service ||
  mongoose.model(
    "Service",
    serviceSchema
  );

export default Service;