import Cart from "../models/Cart.js";
import Service from "../models/Service.js";
import Notification from "../models/Notification.js";

// =====================================================
// GET MY CART
// =====================================================

export const getMyCart = async (
  req,
  res,
  next
) => {
  try {
    let cart = await Cart.findOne({
      user: req.user._id,
    })
      .populate("items.service")
      .populate(
        "items.provider",
        "name email phone"
      );

    if (!cart) {
      cart = await Cart.create({
        user: req.user._id,
        items: [],
      });
    }

    res.json({
      success: true,
      cart,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// ADD TO CART
// =====================================================

export const addToCart = async (
  req,
  res,
  next
) => {
  try {
    const {
      serviceId,
      providerId,
      itemType = "service",
      productName,
      category,
      price,
      quantity = 1,
      image,
      eventDate,
      notes,
    } = req.body;

    let cart = await Cart.findOne({
      user: req.user._id,
    });

    if (!cart) {
      cart = await Cart.create({
        user: req.user._id,
        items: [],
      });
    }

    const existingItem =
      cart.items.find(
        (item) =>
          item.service?.toString() ===
          serviceId
      );

    if (existingItem) {
      existingItem.quantity +=
        Number(quantity);

      existingItem.total =
        existingItem.price *
        existingItem.quantity;
    } else {
      cart.items.push({
        service: serviceId,
        provider: providerId,

        itemType,

        productName:
          productName || "",

        category:
          category || "",

        price,

        quantity,

        image,

        eventDate,

        notes,

        total:
          Number(price) *
          Number(quantity),
      });
    }

    await cart.save();

    const updatedCart =
      await Cart.findById(cart._id)
        .populate("items.service")
        .populate(
          "items.provider",
          "name email phone"
        );

    res.status(201).json({
      success: true,
      message:
        "Item added to cart",
      cart: updatedCart,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// UPDATE CART ITEM
// =====================================================

export const updateCartItem =
  async (req, res, next) => {
    try {
      const { quantity } = req.body;

      const cart =
        await Cart.findOne({
          user: req.user._id,
        });

      if (!cart) {
        res.status(404);
        throw new Error(
          "Cart not found"
        );
      }

      const item = cart.items.id(
        req.params.itemId
      );

      if (!item) {
        res.status(404);
        throw new Error(
          "Cart item not found"
        );
      }

      item.quantity =
        Number(quantity);

      item.total =
        item.price *
        item.quantity;

      await cart.save();

      res.json({
        success: true,
        message:
          "Cart updated successfully",
        cart,
      });
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// REMOVE ITEM
// =====================================================

export const removeCartItem =
  async (req, res, next) => {
    try {
      const cart =
        await Cart.findOne({
          user: req.user._id,
        });

      if (!cart) {
        res.status(404);
        throw new Error(
          "Cart not found"
        );
      }

      cart.items =
        cart.items.filter(
          (item) =>
            item._id.toString() !==
            req.params.itemId
        );

      await cart.save();

      res.json({
        success: true,
        message:
          "Item removed from cart",
        cart,
      });
    } catch (error) {
      next(error);
    }
  };

// =====================================================
// CLEAR CART
// =====================================================

export const clearCart = async (
  req,
  res,
  next
) => {
  try {
    const cart =
      await Cart.findOne({
        user: req.user._id,
      });

    if (!cart) {
      res.status(404);
      throw new Error(
        "Cart not found"
      );
    }

    cart.items = [];
    cart.totalItems = 0;
    cart.subtotal = 0;
    cart.tax = 0;
    cart.discountAmount = 0;
    cart.grandTotal = 0;

    await cart.save();

    res.json({
      success: true,
      message:
        "Cart cleared successfully",
      cart,
    });
  } catch (error) {
    next(error);
  }
};

// =====================================================
// CART SUMMARY
// =====================================================

export const getCartSummary =
  async (req, res, next) => {
    try {
      const cart =
        await Cart.findOne({
          user: req.user._id,
        });

      if (!cart) {
        return res.json({
          success: true,
          summary: {
            totalItems: 0,
            subtotal: 0,
            tax: 0,
            discount: 0,
            grandTotal: 0,
          },
        });
      }

      res.json({
        success: true,
        summary: {
          totalItems:
            cart.totalItems,
          subtotal:
            cart.subtotal,
          tax: cart.tax,
          discount:
            cart.discountAmount,
          grandTotal:
            cart.grandTotal,
        },
      });
    } catch (error) {
      next(error);
    }
  };