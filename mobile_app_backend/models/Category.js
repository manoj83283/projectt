import mongoose from "mongoose";

const categorySchema = new mongoose.Schema(
  {
    // =====================================================
    // CATEGORY NAME
    // =====================================================
    name: {
      type: String,
      required: true,
      trim: true,
      unique: true,
    },

    // =====================================================
    // SLUG
    // =====================================================
    slug: {
      type: String,
      required: true,
      trim: true,
      unique: true,
      lowercase: true,
    },

    // =====================================================
    // DESCRIPTION
    // =====================================================
    description: {
      type: String,
      default: "",
      trim: true,
    },

    // =====================================================
    // ICON
    // =====================================================
    icon: {
      type: String,
      default: "",
    },

    // =====================================================
    // IMAGE
    // =====================================================
    image: {
      type: String,
      default: "",
    },

    // =====================================================
    // CATEGORY TYPE
    // =====================================================
    type: {
      type: String,
      enum: [
        "venue",
        "professional",
        "service",
        "product",
      ],
      required: true,
    },

    // =====================================================
    // PARENT CATEGORY
    // =====================================================
    parentCategory: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      default: null,
    },

    // =====================================================
    // ACTIVE
    // =====================================================
    isActive: {
      type: Boolean,
      default: true,
    },

    // =====================================================
    // FEATURED
    // =====================================================
    isFeatured: {
      type: Boolean,
      default: false,
    },

    // =====================================================
    // SORT ORDER
    // =====================================================
    sortOrder: {
      type: Number,
      default: 0,
    },

    // =====================================================
    // SEO
    // =====================================================
    seoTitle: {
      type: String,
      default: "",
    },

    seoDescription: {
      type: String,
      default: "",
    },
  },
  {
    timestamps: true,
  }
);

// =====================================================
// INDEXES
// =====================================================

categorySchema.index({
  name: 1,
});

categorySchema.index({
  slug: 1,
});

categorySchema.index({
  type: 1,
});

categorySchema.index({
  isActive: 1,
});

// =====================================================
// MODEL
// =====================================================

const Category = mongoose.model(
  "Category",
  categorySchema
);

export default Category;