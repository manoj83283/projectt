import User from "../models/User.js";
import Service from "../models/Service.js";
import Booking from "../models/Booking.js";
import Order from "../models/Order.js";
import Review from "../models/Review.js";
import Notification from "../models/Notification.js";

// ======================================================
// ADMIN DASHBOARD
// ======================================================

export const getDashboardStats = async (
  req,
  res,
  next
) => {
  try {
    const totalUsers = await User.countDocuments({
      role: "user",
    });

    const totalProviders =
      await User.countDocuments({
        role: "provider",
      });

    const totalServices =
      await Service.countDocuments();

    const totalBookings =
      await Booking.countDocuments();

    const totalOrders =
      await Order.countDocuments();

    const completedBookings =
      await Booking.countDocuments({
        status: "completed",
      });

    const pendingBookings =
      await Booking.countDocuments({
        status: "pending",
      });

    res.json({
      success: true,
      stats: {
        totalUsers,
        totalProviders,
        totalServices,
        totalBookings,
        totalOrders,
        completedBookings,
        pendingBookings,
      },
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// GET ALL USERS
// ======================================================

export const getAllUsers = async (
  req,
  res,
  next
) => {
  try {
    const users = await User.find()
      .select("-password")
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: users.length,
      users,
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// GET ALL PROVIDERS
// ======================================================

export const getAllProviders = async (
  req,
  res,
  next
) => {
  try {
    const providers = await User.find({
      role: "provider",
    })
      .select("-password")
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: providers.length,
      providers,
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// GET ALL SERVICES
// ======================================================

export const getAllServices = async (
  req,
  res,
  next
) => {
  try {
    const services = await Service.find()
      .populate(
        "provider",
        "name email phone"
      )
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: services.length,
      services,
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// GET ALL BOOKINGS
// ======================================================

export const getAllBookings = async (
  req,
  res,
  next
) => {
  try {
    const bookings = await Booking.find()
      .populate(
        "customer",
        "name email"
      )
      .populate(
        "provider",
        "name email"
      )
      .populate(
        "service",
        "name"
      )
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: bookings.length,
      bookings,
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// GET ALL ORDERS
// ======================================================

export const getAllOrders = async (
  req,
  res,
  next
) => {
  try {
    const orders = await Order.find()
      .populate(
        "customer",
        "name email"
      )
      .populate(
        "provider",
        "name email"
      )
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: orders.length,
      orders,
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// APPROVE SERVICE
// ======================================================

export const approveService = async (
  req,
  res,
  next
) => {
  try {
    const service =
      await Service.findByIdAndUpdate(
        req.params.id,
        {
          isApproved: true,
          status: "approved",
        },
        {
          new: true,
        }
      );

    if (!service) {
      res.status(404);
      throw new Error(
        "Service not found"
      );
    }

    res.json({
      success: true,
      message:
        "Service approved successfully",
      service,
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// REJECT / BLOCK SERVICE
// ======================================================

export const blockService = async (
  req,
  res,
  next
) => {
  try {
    const service =
      await Service.findByIdAndUpdate(
        req.params.id,
        {
          isApproved: false,
          status: "blocked",
        },
        {
          new: true,
        }
      );

    if (!service) {
      res.status(404);
      throw new Error(
        "Service not found"
      );
    }

    res.json({
      success: true,
      message:
        "Service blocked successfully",
      service,
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// BLOCK USER
// ======================================================

export const blockUser = async (
  req,
  res,
  next
) => {
  try {
    const user =
      await User.findByIdAndUpdate(
        req.params.id,
        {
          isBlocked: true,
        },
        {
          new: true,
        }
      ).select("-password");

    if (!user) {
      res.status(404);
      throw new Error(
        "User not found"
      );
    }

    res.json({
      success: true,
      message:
        "User blocked successfully",
      user,
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// UNBLOCK USER
// ======================================================

export const unblockUser = async (
  req,
  res,
  next
) => {
  try {
    const user =
      await User.findByIdAndUpdate(
        req.params.id,
        {
          isBlocked: false,
        },
        {
          new: true,
        }
      ).select("-password");

    if (!user) {
      res.status(404);
      throw new Error(
        "User not found"
      );
    }

    res.json({
      success: true,
      message:
        "User unblocked successfully",
      user,
    });
  } catch (error) {
    next(error);
  }
};

// ======================================================
// DELETE SERVICE
// ======================================================

export const deleteServiceByAdmin =
  async (req, res, next) => {
    try {
      const service =
        await Service.findById(
          req.params.id
        );

      if (!service) {
        res.status(404);
        throw new Error(
          "Service not found"
        );
      }

      await service.deleteOne();

      res.json({
        success: true,
        message:
          "Service deleted successfully",
      });
    } catch (error) {
      next(error);
    }
  };

// ======================================================
// DELETE USER
// ======================================================

export const deleteUserByAdmin =
  async (req, res, next) => {
    try {
      const user =
        await User.findById(
          req.params.id
        );

      if (!user) {
        res.status(404);
        throw new Error(
          "User not found"
        );
      }

      await user.deleteOne();

      res.json({
        success: true,
        message:
          "User deleted successfully",
      });
    } catch (error) {
      next(error);
    }
  };

// ======================================================
// PLATFORM ANALYTICS
// ======================================================

export const getPlatformAnalytics =
  async (req, res, next) => {
    try {
      const totalReviews =
        await Review.countDocuments();

      const avgRating =
        await Review.aggregate([
          {
            $group: {
              _id: null,
              avgRating: {
                $avg: "$rating",
              },
            },
          },
        ]);

      res.json({
        success: true,
        analytics: {
          totalReviews,
          averageRating:
            avgRating[0]?.avgRating || 0,
        },
      });
    } catch (error) {
      next(error);
    }
  };