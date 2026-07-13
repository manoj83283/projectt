import Order from "../models/Order.js";
import Service from "../models/Service.js";
import User from "../models/User.js";
import Notification from "../models/Notification.js";

// =====================================================
// CREATE ORDER
// =====================================================

export const createOrder = async (
  req,
  res,
  next
) => {
  try {
    const {
      providerId,
      serviceId,
      orderType,
      quantity,
      price,
      bookingDate,
      notes,
      deliveryAddress,
    } = req.body;

    const order = await Order.create({
      customer: req.user._id,
      provider: providerId,
      service: serviceId,

      orderType:
        orderType || "service",

      quantity: quantity || 1,

      price,

      totalAmount:
        Number(price) *
        Number(quantity || 1),

      bookingDate,

      notes,

      deliveryAddress,

      status: "pending",
    });

    const populatedOrder =
      await Order.findById(order._id)
        .populate(
          "customer",
          "name email phone"
        )
        .populate(
          "provider",
          "name email phone"
        )
        .populate(
          "service",
          "name price"
        );

    if (global.io) {
      global.io.emit(
        "newOrder",
        populatedOrder
      );
    }

    res.status(201).json({
      success: true,
      message:
        "Order created successfully",
      order: populatedOrder,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// GET MY ORDERS (CUSTOMER)
// =====================================================

export const getMyOrders = async (
  req,
  res,
  next
) => {
  try {
    const orders = await Order.find({
      customer: req.user._id,
    })
      .populate(
        "provider",
        "name email phone"
      )
      .populate(
        "service",
        "name image price"
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

// =====================================================
// PROVIDER ORDERS
// =====================================================

export const getProviderOrders =
  async (req, res, next) => {
    try {
      const orders =
        await Order.find({
          provider: req.user._id,
        })
          .populate(
            "customer",
            "name email phone"
          )
          .populate(
            "service",
            "name image price"
          )
          .sort({
            createdAt: -1,
          });

      res.json({
        success: true,
        count: orders.length,
        orders,
      });
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// GET ORDER BY ID
// =====================================================

export const getOrderById =
  async (req, res, next) => {
    try {
      const order =
        await Order.findById(
          req.params.id
        )
          .populate(
            "customer",
            "name email phone"
          )
          .populate(
            "provider",
            "name email phone"
          )
          .populate(
            "service"
          );

      if (!order) {
        res.status(404);
        throw new Error(
          "Order not found"
        );
      }

      res.json({
        success: true,
        order,
      });
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// UPDATE ORDER STATUS
// =====================================================

export const updateOrderStatus =
  async (req, res, next) => {
    try {
      const { status } = req.body;

      const order =
        await Order.findById(
          req.params.id
        );

      if (!order) {
        res.status(404);
        throw new Error(
          "Order not found"
        );
      }

      order.status = status;

      await order.save();

      const updated =
        await Order.findById(
          order._id
        )
          .populate(
            "customer",
            "name email"
          )
          .populate(
            "provider",
            "name email"
          );

      if (global.io) {
        global.io.emit(
          "orderUpdated",
          updated
        );
      }

      res.json({
        success: true,
        message:
          "Order updated successfully",
        order: updated,
      });
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// ACCEPT ORDER
// =====================================================

export const acceptOrder =
  async (req, res, next) => {
    try {
      req.body.status = "accepted";

      return updateOrderStatus(
        req,
        res,
        next
      );
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// REJECT ORDER
// =====================================================

export const rejectOrder =
  async (req, res, next) => {
    try {
      req.body.status = "rejected";

      return updateOrderStatus(
        req,
        res,
        next
      );
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// COMPLETE ORDER
// =====================================================

export const completeOrder =
  async (req, res, next) => {
    try {
      req.body.status = "completed";

      return updateOrderStatus(
        req,
        res,
        next
      );
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// CANCEL ORDER
// =====================================================

export const cancelOrder =
  async (req, res, next) => {
    try {
      const order =
        await Order.findById(
          req.params.id
        );

      if (!order) {
        res.status(404);
        throw new Error(
          "Order not found"
        );
      }

      order.status = "cancelled";

      await order.save();

      res.json({
        success: true,
        message:
          "Order cancelled successfully",
      });
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// DELETE ORDER
// =====================================================

export const deleteOrder =
  async (req, res, next) => {
    try {
      const order =
        await Order.findById(
          req.params.id
        );

      if (!order) {
        res.status(404);
        throw new Error(
          "Order not found"
        );
      }

      await order.deleteOne();

      res.json({
        success: true,
        message:
          "Order deleted successfully",
      });
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// ADMIN - ALL ORDERS
// =====================================================

export const getAllOrders =
  async (req, res, next) => {
    try {
      const orders =
        await Order.find()
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
          .sort({
            createdAt: -1,
          });

      res.json({
        success: true,
        count: orders.length,
        orders,
      });
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// ORDER ANALYTICS
// =====================================================

export const getOrderAnalytics =
  async (req, res, next) => {
    try {
      const totalOrders =
        await Order.countDocuments();

      const pendingOrders =
        await Order.countDocuments({
          status: "pending",
        });

      const acceptedOrders =
        await Order.countDocuments({
          status: "accepted",
        });

      const completedOrders =
        await Order.countDocuments({
          status: "completed",
        });

      const cancelledOrders =
        await Order.countDocuments({
          status: "cancelled",
        });

      res.json({
        success: true,
        analytics: {
          totalOrders,
          pendingOrders,
          acceptedOrders,
          completedOrders,
          cancelledOrders,
        },
      });
    } catch (error) {
      next(error);
    }
  };