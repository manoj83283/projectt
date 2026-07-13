import Category from "../models/Category.js";

// =====================================================
// CREATE CATEGORY
// =====================================================

export const createCategory = async (req, res, next) => {
  try {
    const {
      name,
      slug,
      description,
      icon,
      image,
      type,
      parentCategory,
      isFeatured,
      sortOrder,
      seoTitle,
      seoDescription,
    } = req.body;

    const existingCategory = await Category.findOne({
      $or: [{ name }, { slug }],
    });

    if (existingCategory) {
      res.status(400);
      throw new Error("Category already exists");
    }

    const category = await Category.create({
      name,
      slug,
      description,
      icon,
      image,
      type,
      parentCategory,
      isFeatured,
      sortOrder,
      seoTitle,
      seoDescription,
    });

    res.status(201).json({
      success: true,
      message: "Category created successfully",
      category,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// GET CATEGORY BY SLUG
// =====================================================

export const getCategoryBySlug = async (
  req,
  res,
  next
) => {
  try {
    const category = await Category.findOne({
      slug: req.params.slug,
    }).populate(
      "parentCategory",
      "name slug"
    );

    if (!category) {
      res.status(404);
      throw new Error("Category not found");
    }

    res.json({
      success: true,
      category,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// GET ALL CATEGORIES
// =====================================================

export const getAllCategories = async (req, res, next) => {
  try {
    const categories = await Category.find()
      .populate("parentCategory", "name slug")
      .sort({
        sortOrder: 1,
        name: 1,
      });

    res.json({
      success: true,
      count: categories.length,
      categories,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// GET ACTIVE CATEGORIES
// =====================================================

export const getActiveCategories = async (req, res, next) => {
  try {
    const categories = await Category.find({
      isActive: true,
    }).sort({
      sortOrder: 1,
      name: 1,
    });

    res.json({
      success: true,
      count: categories.length,
      categories,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// GET FEATURED CATEGORIES
// =====================================================

export const getFeaturedCategories = async (req, res, next) => {
  try {
    const categories = await Category.find({
      isFeatured: true,
      isActive: true,
    }).sort({
      sortOrder: 1,
    });

    res.json({
      success: true,
      count: categories.length,
      categories,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// GET CATEGORY BY TYPE
// =====================================================

export const getCategoriesByType = async (
  req,
  res,
  next
) => {
  try {
    const categories = await Category.find({
      type: req.params.type,
      isActive: true,
    }).sort({
      sortOrder: 1,
    });

    res.json({
      success: true,
      count: categories.length,
      categories,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// GET CATEGORY BY ID
// =====================================================

export const getCategoryById = async (req, res, next) => {
  try {
    const category = await Category.findById(
      req.params.id
    ).populate("parentCategory", "name slug");

    if (!category) {
      res.status(404);
      throw new Error("Category not found");
    }

    res.json({
      success: true,
      category,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// UPDATE CATEGORY
// =====================================================

export const updateCategory = async (
  req,
  res,
  next
) => {
  try {
    const category = await Category.findById(
      req.params.id
    );

    if (!category) {
      res.status(404);
      throw new Error("Category not found");
    }

    const updatedCategory =
      await Category.findByIdAndUpdate(
        req.params.id,
        req.body,
        {
          new: true,
          runValidators: true,
        }
      );

    res.json({
      success: true,
      message: "Category updated successfully",
      category: updatedCategory,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// TOGGLE ACTIVE STATUS
// =====================================================

export const toggleCategoryStatus = async (
  req,
  res,
  next
) => {
  try {
    const category = await Category.findById(
      req.params.id
    );

    if (!category) {
      res.status(404);
      throw new Error("Category not found");
    }

    category.isActive = !category.isActive;

    await category.save();

    res.json({
      success: true,
      message: category.isActive
        ? "Category activated"
        : "Category deactivated",
      category,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// ACTIVATE CATEGORY
// =====================================================

export const activateCategory = async (
  req,
  res,
  next
) => {
  try {
    const category =
      await Category.findByIdAndUpdate(
        req.params.id,
        {
          isActive: true,
        },
        {
          new: true,
        }
      );

    if (!category) {
      res.status(404);
      throw new Error("Category not found");
    }

    res.json({
      success: true,
      message: "Category activated successfully",
      category,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// DEACTIVATE CATEGORY
// =====================================================

export const deactivateCategory = async (
  req,
  res,
  next
) => {
  try {
    const category =
      await Category.findByIdAndUpdate(
        req.params.id,
        {
          isActive: false,
        },
        {
          new: true,
        }
      );

    if (!category) {
      res.status(404);
      throw new Error("Category not found");
    }

    res.json({
      success: true,
      message: "Category deactivated successfully",
      category,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// TOGGLE FEATURED
// =====================================================

export const toggleFeaturedCategory = async (
  req,
  res,
  next
) => {
  try {
    const category = await Category.findById(
      req.params.id
    );

    if (!category) {
      res.status(404);
      throw new Error("Category not found");
    }

    category.isFeatured = !category.isFeatured;

    await category.save();

    res.json({
      success: true,
      message: "Featured status updated",
      category,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// DELETE CATEGORY
// =====================================================

export const deleteCategory = async (
  req,
  res,
  next
) => {
  try {
    const category = await Category.findById(
      req.params.id
    );

    if (!category) {
      res.status(404);
      throw new Error("Category not found");
    }

    await category.deleteOne();

    res.json({
      success: true,
      message: "Category deleted successfully",
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// CATEGORY ANALYTICS
// =====================================================

export const getCategoryAnalytics = async (
  req,
  res,
  next
) => {
  try {
    const totalCategories =
      await Category.countDocuments();

    const activeCategories =
      await Category.countDocuments({
        isActive: true,
      });

    const featuredCategories =
      await Category.countDocuments({
        isFeatured: true,
      });

    const venueCategories =
      await Category.countDocuments({
        type: "venue",
      });

    const serviceCategories =
      await Category.countDocuments({
        type: "service",
      });

    const professionalCategories =
      await Category.countDocuments({
        type: "professional",
      });

    const productCategories =
      await Category.countDocuments({
        type: "product",
      });

    res.json({
      success: true,
      analytics: {
        totalCategories,
        activeCategories,
        featuredCategories,
        venueCategories,
        serviceCategories,
        professionalCategories,
        productCategories,
      },
    });
  } catch (error) {
    next(error);
  }
};