import User from "../models/User.js";
import Service from "../models/Service.js";
import Booking from "../models/Booking.js";
import Order from "../models/Order.js";

// =====================================================
// CREATE PROVIDER
// =====================================================

export const createProvider = async (
  req,
  res,
  next
) => {
  try {
    const provider = await User.create({
      ...req.body,
      role: "provider",
    });

    res.status(201).json({
      success: true,
      provider,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// GET ALL PROVIDERS
// =====================================================

export const getProviders = async (
  req,
  res,
  next
) => {
  try {
    const providers = await User.find({
      role: "provider",
    }).select("-password");

    res.json({
      success: true,
      count: providers.length,
      providers,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// PROVIDER DASHBOARD
// =====================================================

export const getProviderDashboard =
  async (req, res, next) => {
    try {
      const providerId = req.user._id;

      const totalServices =
        await Service.countDocuments({
          provider: providerId,
        });

      const totalBookings =
        await Booking.countDocuments({
          provider: providerId,
        });

      const totalOrders =
        await Order.countDocuments({
          provider: providerId,
        });

      res.json({
        success: true,
        dashboard: {
          totalServices,
          totalBookings,
          totalOrders,
        },
      });
    } catch (error) {
      next(error);
    }
  };